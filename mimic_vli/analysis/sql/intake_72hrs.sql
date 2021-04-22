WITH
  t1 AS (
  SELECT
    mv.icustay_id,
    mv.starttime AS charttime
    -- standardize the units to millilitres
    -- also metavision has floating point precision.. but we only care down to the mL
    ,
    ROUND(CASE
        WHEN mv.amountuom = 'L' THEN mv.amount * 1000.0
        WHEN mv.amountuom = 'ml' THEN mv.amount
      ELSE
      NULL
    END
      ) AS amount
  FROM
    `physionet-data.mimiciii_clinical.inputevents_mv` mv
  WHERE
    mv.itemid IN (
      -- 225943 Solution
      225158,
      -- NaCl 0.9%
      225828,
      -- LR
      225944,
      -- Sterile Water
      225797,
      -- Free Water
      225159,
      -- NaCl 0.45%
      -- 225161, -- NaCl 3% (Hypertonic Saline)
      225823,
      -- D5 1/2NS
      225825,
      -- D5NS
      225827,
      -- D5LR
      225941,
      -- D5 1/4NS
      226089 -- Piggyback
      )
    AND mv.statusdescription != 'Rewritten' AND
    -- in MetaVision, these ITEMIDs appear with a null rate IFF endtime=starttime + 1 minute
    -- so it is sufficient to:
    --    (1) check the rate is > 240 if it exists or
    --    (2) ensure the rate is null and amount > 240 ml
    ( (mv.rate IS NOT NULL
        AND mv.rateuom = 'mL/hour')
      OR (mv.rate IS NOT NULL
        AND mv.rateuom = 'mL/min')
      OR (mv.rate IS NULL
        AND mv.amountuom = 'L')
      OR (mv.rate IS NULL
        AND mv.amountuom = 'ml') ) ),
  t2 AS (
  SELECT
    cv.icustay_id,
    cv.charttime
    -- carevue always has units in millilitres
    ,
    ROUND(cv.amount) AS amount
  FROM
    `physionet-data.mimiciii_clinical.inputevents_cv` cv
  WHERE
    cv.itemid IN ( 30015 -- "D5/.45NS" -- mixed colloids and crystalloids
      ,
      30018 --	.9% Normal Saline
      ,
      30020 -- .45% Normal Saline
      ,
      30021 --	Lactated Ringers
      ,
      30058 --	Free Water Bolus
      ,
      30060 -- D5NS
      ,
      30061 -- D5RL
      ,
      30063 --	IV Piggyback
      ,
      30065 --	Sterile Water
      -- , 30143 -- 3% Normal Saline
      ,
      30159 -- D5 Ringers Lact.
      ,
      30160 -- D5 Normal Saline
      ,
      30169 --	Sterile H20_GU
      ,
      30190 -- NS .9%
      ,
      40850 --	ns bolus
      ,
      41491 --	fluid bolus
      ,
      42639 --	bolus
      ,
      42187 --	free h20
      ,
      43819 --	1:1 NS Repletion.
      ,
      41430 --	free water boluses
      ,
      40712 --	free H20
      ,
      44160 --	BOLUS
      ,
      42383 --	cc for cc replace
      ,
      42297 --	Fluid bolus
      ,
      42453 --	Fluid Bolus
      ,
      40872 --	free water
      ,
      41915 --	FREE WATER
      ,
      41490 --	NS bolus
      ,
      46501 --	H2O Bolus
      ,
      45045 --	WaterBolus
      ,
      41984 --	FREE H20
      ,
      41371 --	ns fluid bolus
      ,
      41582 --	free h20 bolus
      ,
      41322 --	rl bolus
      ,
      40778 --	Free H2O
      ,
      41896 --	ivf boluses
      ,
      41428 --	ns .9% bolus
      ,
      43936 --	FREE WATER BOLUSES
      ,
      44200 --	FLUID BOLUS
      ,
      41619 --	frfee water boluses
      ,
      40424 --	free H2O
      ,
      41457 --	Free H20 intake
      ,
      41581 --	Water bolus
      ,
      42844 --	NS fluid bolus
      ,
      42429 --	Free water
      ,
      41356 --	IV Bolus
      ,
      40532 --	FREE H2O
      ,
      42548 --	NS Bolus
      ,
      44184 --	LR Bolus
      ,
      44521 --	LR bolus
      ,
      44741 --	NS FLUID BOLUS
      ,
      44126 --	fl bolus
      ,
      44110 --	RL BOLUS
      ,
      44633 --	ns boluses
      ,
      44983 --	Bolus NS
      ,
      44815 --	LR BOLUS
      ,
      43986 --	iv bolus
      ,
      45079 --	500 cc ns bolus
      ,
      46781 --	lr bolus
      ,
      45155 --	ns cc/cc replacement
      ,
      43909 --	H20 BOlus
      ,
      41467 --	NS IV bolus
      ,
      44367 --	LR
      ,
      41743 --	water bolus
      ,
      40423 --	Bolus
      ,
      44263 --	fluid bolus ns
      ,
      42749 --	fluid bolus NS
      ,
      45480 --	500cc ns bolus
      ,
      44491 --	.9NS bolus
      ,
      41695 --	NS fluid boluses
      ,
      46169 --	free water bolus.
      ,
      41580 --	free h2o bolus
      ,
      41392 --	ns b
      ,
      45989 --	NS Fluid Bolus
      ,
      45137 --	NS cc/cc
      ,
      45154 --	Free H20 bolus
      ,
      44053 --	normal saline bolus
      ,
      41416 --	free h2o boluses
      ,
      44761 --	Free H20
      ,
      41237 --	ns fluid boluses
      ,
      44426 --	bolus ns
      ,
      43975 --	FREE H20 BOLUSES
      ,
      44894 --	N/s 500 ml bolus
      ,
      41380 --	nsbolus
      ,
      42671 --	free h2o
      )
    AND cv.amountuom = 'ml' ),
    
t3 AS(
  SELECT
    *
  FROM
    t1
    -- just because the rate was high enough, does *not* mean the final amount was
  WHERE
    icustay_id IS NOT NULL
  UNION DISTINCT
  SELECT
    *
  FROM
    t2
  WHERE
    icustay_id IS NOT NULL
  ORDER BY
    icustay_id),
    
  t4 AS(
  SELECT
    icustay_id,
    charttime,
    SUM(amount) AS intake_first,
    DATETIME_DIFF(charttime,
      INTIME,
      MINUTE) AS chartoffset
  FROM
    t3
  LEFT JOIN
    `physionet-data.mimiciii_clinical.icustays`
  USING
    (icustay_id)
    -- just because the rate was high enough, does *not* mean the final amount was
  WHERE
  icustay_id IS NOT NULL
  GROUP BY
    t3.icustay_id,
    t3.charttime,
    intime),
    
t5 AS (
  SELECT
    icustay_id,
    sum (intake_first) AS intakes,
  FROM
    t4
  WHERE
    intake_first IS NOT NULL
    AND chartoffset BETWEEN 36*60 AND 84*60
  GROUP BY
    icustay_id,
    chartoffset
  ORDER BY
    icustay_id)
    
SELECT
  icustay_id,
  sum (intakes) AS intakes_total_72
FROM
  t5
GROUP BY
  icustay_id
ORDER BY
  icustay_id;