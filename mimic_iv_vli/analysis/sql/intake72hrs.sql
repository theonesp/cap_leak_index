-- there are two types of intake extaction: plain intake and real time.
-- we extract intake both ways and then we add them, in the end we combine mv and cv prioritizing metavision data
--
-- # About real time intake extraction:
-- This query extracts Real-time input from metavision MIMICIII on the first 24 hrs of admission
-- Records with no rate = STAT
-- Records with rate = INFUSION
-- fluids corrected for tonicity
-- This code is based on the notebook by Komorowski available at https://github.com/matthieukomorowski/AI_Clinician/blob/0438a66de7c5270e84a7fa51d78f56cd934ad240/AIClinician_Data_extract_MIMIC3_140219.ipynb
-- total equiv volume is in ML
-- rate units is mL/hour
--
--
--################### METAVISION query starts here
WITH
  metavision_intake_one AS (
  SELECT
    inputevents.stay_id,
    inputevents.starttime AS charttime
    -- standardize the units to millilitres
    -- also metavision has floating point precision.. but we only care down to the mL
    ,
    ROUND(CASE
        WHEN inputevents.amountuom = 'L' THEN inputevents.amount * 1000.0
        WHEN inputevents.amountuom = 'ml' THEN inputevents.amount
      ELSE
      NULL
    END
      ,2) AS amount
  FROM
    `physionet-data.mimic_icu.inputevents` inputevents
  WHERE
    inputevents.itemid IN (
      225943, -- Solution
      225158, -- NaCl 0.9%
      225828, -- LR
      225944,-- Sterile Water
      225797, -- Free Water
      225159,-- NaCl 0.45%
      225161, -- NaCl 3% (Hypertonic Saline)
      225823, -- D5 1/2NS
      225825, -- D5NS
      225827, -- D5LR
      225941, -- D5 1/4NS
      226089 -- Piggyback
      )
    AND inputevents.statusdescription != 'Rewritten' AND
    -- in MetaVision, these ITEMIDs appear with a null rate IFF endtime=starttime + 1 minute
    -- so it is sufficient to:
    --    (1) check the rate is > 240 if it exists or
    --    (2) ensure the rate is null and amount > 240 ml
    ( (inputevents.rate IS NOT NULL
        AND inputevents.rateuom = 'mL/hour')
      OR (inputevents.rate IS NOT NULL
        AND inputevents.rateuom = 'mL/min')
      OR (inputevents.rate IS NULL
        AND inputevents.amountuom = 'L')
      OR (inputevents.rate IS NULL
        AND inputevents.amountuom = 'ml') ) ),
    
  metavision_intake_final AS(
  SELECT
    stay_id,
    charttime,
    SUM(amount) AS intake_first,
    DATETIME_DIFF(charttime, INTIME, MINUTE) AS chartoffset
  FROM
    metavision_intake_one
  LEFT JOIN
    `physionet-data.mimic_icu.icustays`
  USING
    (stay_id)
    -- just because the rate was high enough, does *not* mean the final amount was
  WHERE
  stay_id IS NOT NULL
  GROUP BY
    metavision_intake_one.stay_id,
    metavision_intake_one.charttime,
    INTIME),


-- metavision realtime starts here
metavision_realtime_one AS (
  SELECT
    stay_id,
    DATETIME_DIFF(starttime, INTIME, MINUTE) AS starttime,
    DATETIME_DIFF(endtime, INTIME, MINUTE) AS endtime,
    itemid,
    amount,
    rate,
    CASE
      WHEN itemid IN (30176, 30315) THEN amount *0.25
      WHEN itemid IN (30161) THEN amount *0.3
      WHEN itemid IN (30020, 30015
      --, 225823
      , 30321, 30186, 30211, 30353, 42742, 42244
      --, 225159
      ) THEN amount*0.5 --
      WHEN itemid IN (227531) THEN amount *2.75
      WHEN itemid IN (30143
      --, 225161
      ) THEN amount*3
      WHEN itemid IN (30009, 220862) THEN amount *5
      WHEN itemid IN (30030, 220995, 227533) THEN amount *6.66
      WHEN itemid IN (228341) THEN amount *8
    ELSE
    amount
  END
    AS tev, -- total equivalent volume
    DATETIME_DIFF(starttime, INTIME, MINUTE) AS chartoffset
  FROM
    `physionet-data.mimic_icu.inputevents` inputevents
  LEFT JOIN
    `physionet-data.mimic_icu.icustays`
  USING
    (stay_id)  
    -- only real time items !!
  WHERE
    stay_id IS NOT NULL
    AND amount IS NOT NULL
    AND itemid IN (
    -- we are comenting the items appearing in metavision_intake_one
    --225158
    --,225943
    --,226089
       225168
    --,225828
    ,225823,220862,220970,220864,225159,220995,225170,
    --225825,
    227533,225161,227531,225171
    --,225827
    --,225941
    ,225823,225825,225941,225825,228341,225827,30018,30021,30015,30296,30020,30066,30001,30030,30060,30005,30321,30006,30061,30009,30179,30190,30143,30160,30008,30168,30186,30211,30353,30159,30007,30185,30063,30094,30352,30014,30011,30210,46493,45399,46516,40850,30176,30161,30381,30315,42742,30180,46087,41491,30004,42698,42244)
    ), 
real_time_derived_infusion AS(      
SELECT
  stay_id,
  starttime,
  endtime,
  endtime - starttime AS infusion_duration_hrs,
  chartoffset,
  itemid,
  ROUND(CAST(amount AS numeric),3) AS amount,
  ROUND(CAST(rate AS numeric),3) AS rate,
  ROUND(CAST(tev AS numeric),3) AS tev, -- total equiv volume
  ROUND(CASE WHEN rate IS NOT NULL THEN (rate/1000)*((endtime-starttime)/60) 
       ELSE NULL
  END,2) AS intake_ltrs_per_hr
FROM
  metavision_realtime_one
ORDER BY
  stay_id,
  starttime,
  itemid
  ), metavision_realtime_final AS (
 SELECT
    stay_id,
    chartoffset,
    SUM(CASE WHEN rate IS NULL THEN tev ELSE rate*((endtime-starttime)/60) END) AS intake_real_time_mv
 FROM 
    real_time_derived_infusion
 WHERE
 intake_ltrs_per_hr <= 10 --extreme INTAKE = outliers = to be deleted (>10 litres of intake per 4h!!
 GROUP BY
    stay_id,
    chartoffset
 ORDER BY  
    stay_id,
    chartoffset
),
-- BEGINING OF metavision_two_ways
 metavision_two_ways AS(
 SELECT
 icustays.stay_id,
  -- we are prioritizing intake first data over real time data
  -- in the end we decided to get rid of real time data
/* null + a = null so coalesce does the trick */
 ROUND(
 --COALESCE (
 SUM(COALESCE(intake_first,0))
 --, SUM (COALESCE(intake_real_time_mv,0) )
 ,2)
 --)
 AS intake_mv 
FROM
 `physionet-data.mimic_icu.icustays` icustays
LEFT JOIN
 metavision_realtime_final
ON
  (icustays.stay_id = metavision_realtime_final.stay_id) AND metavision_realtime_final.chartoffset BETWEEN 36*60 AND 84*60 
LEFT JOIN
 metavision_intake_final
ON
  (icustays.stay_id = metavision_intake_final.stay_id) AND metavision_intake_final.chartoffset BETWEEN 36*60 AND 84*60
WHERE
  intake_real_time_mv IS NOT NULL 
OR
  intake_first IS NOT NULL 
GROUP BY 
    icustays.stay_id
    )
SELECT 
    stay_id,
    -- we prefer mv data whenever it is available
    intake_mv AS intakes_total
FROM
 `physionet-data.mimic_icu.icustays` icustays
LEFT JOIN
    metavision_two_ways
USING 
    (stay_id)
