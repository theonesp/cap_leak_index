-- This query extracts Real-time input from carevue MIMICIII on the first 24 hrs of admission
-- In CAREVUE, all records are considered STAT doses!!
-- fluids corrected for tonicity
-- volume is in ML

WITH
  t1 AS (
  SELECT
    icustay_id,
    DATETIME_DIFF(charttime, INTIME, MINUTE) AS chartoffset,
    itemid,
    amount,
    CASE
      WHEN itemid IN (30176, 30315) THEN amount *0.25
      WHEN itemid IN (30161) THEN amount *0.3
      WHEN itemid IN (30020, 30321, 30015, 225823, 30186, 30211, 30353, 42742, 42244, 225159, 225159, 225159) THEN amount *0.5
      WHEN itemid IN (227531) THEN amount *2.75
      WHEN itemid IN (30143, 225161) THEN amount *3
      WHEN itemid IN (30009, 220862) THEN amount *5
      WHEN itemid IN (30030, 220995, 227533) THEN amount *6.66
      WHEN itemid IN (228341) THEN amount *8
    ELSE
    amount
  END
    AS tev -- total equivalent volume
  FROM
    `physionet-data.mimiciii_clinical.inputevents_cv` inputevents_cv
    -- only RT itemids
  LEFT JOIN
    `physionet-data.mimiciii_clinical.icustays`
  USING
    (icustay_id)      
  WHERE
    amount IS NOT NULL
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
      42244)
  ORDER BY
    icustay_id,
    charttime,
    itemid )
SELECT
  icustay_id,
  chartoffset,
  itemid,
  ROUND(CAST(amount AS numeric),3) AS amount,
  ROUND(CAST(tev AS numeric),3) AS tev -- total equivalent volume
FROM
  t1
WHERE
chartoffset BETWEEN -6*60 AND 36*60 -- only 1st day intake
