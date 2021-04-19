-- This query extracts Real-time input from metavision MIMICIII on the first 24 hrs of admission
-- Records with no rate = STAT
-- Records with rate = INFUSION
-- fluids corrected for tonicity
-- This code is based on the notebook by Komorowski available at https://github.com/matthieukomorowski/AI_Clinician/blob/0438a66de7c5270e84a7fa51d78f56cd934ad240/AIClinician_Data_extract_MIMIC3_140219.ipynb
-- total equiv volume is in ML
-- rate units is mL/hour

WITH
  t1 AS (
  SELECT
    icustay_id,
    DATETIME_DIFF(starttime, INTIME, MINUTE) AS starttime,
    DATETIME_DIFF(endtime, INTIME, MINUTE) AS endtime,
    itemid,
    amount,
    rate,
    CASE
      WHEN itemid IN (30176, 30315) THEN amount *0.25
      WHEN itemid IN (30161) THEN amount *0.3
      WHEN itemid IN (30020, 30015, 225823, 30321, 30186, 30211, 30353, 42742, 42244, 225159) THEN amount*0.5 --
      WHEN itemid IN (227531) THEN amount *2.75
      WHEN itemid IN (30143, 225161) THEN amount*3
      WHEN itemid IN (30009, 220862) THEN amount *5
      WHEN itemid IN (30030, 220995, 227533) THEN amount *6.66
      WHEN itemid IN (228341) THEN amount *8
    ELSE
    amount
  END
    AS tev, -- total equivalent volume
    DATETIME_DIFF(starttime, INTIME, MINUTE) AS chartoffset
  FROM
    `physionet-data.mimiciii_clinical.inputevents_mv` inputevents_mv
  LEFT JOIN
    `physionet-data.mimiciii_clinical.icustays`
  USING
    (icustay_id)  
    -- only real time items !!
  WHERE
    icustay_id IS NOT NULL
    AND amount IS NOT NULL
    AND itemid IN (225158,
      225943,
      226089,
      225168,
      225828,
      225823,
      220862,
      220970,
      220864,
      225159,
      220995,
      225170,
      225825,
      227533,
      225161,
      227531,
      225171,
      225827,
      225941,
      225823,
      225825,
      225941,
      225825,
      228341,
      225827,
      30018,
      30021,
      30015,
      30296,
      30020,
      30066,
      30001,
      30030,
      30060,
      30005,
      30321,
      30006,
      30061,
      30009,
      30179,
      30190,
      30143,
      30160,
      30008,
      30168,
      30186,
      30211,
      30353,
      30159,
      30007,
      30185,
      30063,
      30094,
      30352,
      30014,
      30011,
      30210,
      46493,
      45399,
      46516,
      40850,
      30176,
      30161,
      30381,
      30315,
      42742,
      30180,
      46087,
      41491,
      30004,
      42698,
      42244) ), real_time_derived_infusion
AS(      
SELECT
  icustay_id,
  starttime,
  endtime,
  endtime - starttime AS infusion_duration_hrs,
  itemid,
  ROUND(CAST(amount AS numeric),3) AS amount,
  ROUND(CAST(rate AS numeric),3) AS rate,
  ROUND(CAST(tev AS numeric),3) AS tev, -- total equiv volume
  ROUND(CASE WHEN rate IS NOT NULL THEN (rate/1000)*((endtime-starttime)/60) 
       ELSE NULL
  END,2) AS intake_ltrs_per_hr
FROM
  t1
WHERE
  chartoffset BETWEEN 24*60 AND 84*60 -- 72hrs + safety window intake
ORDER BY
  icustay_id,
  starttime,
  itemid
  )SELECT
 icustay_id 
 ,SUM(CASE WHEN rate IS NULL THEN tev ELSE rate*((endtime-starttime)/60) END) AS intake_72_mv
 FROM real_time_derived_infusion
 WHERE intake_ltrs_per_hr <= 10 --extreme INTAKE = outliers = to be deleted (>10 litres of intake per 4h!!
 GROUP BY icustay_id
 ORDER BY icustay_id
