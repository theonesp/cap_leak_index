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
    mv.statusdescription != 'Rewritten' AND
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
    cv.amountuom = 'ml' ),
    
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
    AND chartoffset BETWEEN -6*60 AND 36*60
  GROUP BY
    icustay_id,
    chartoffset
  ORDER BY
    icustay_id)
    
SELECT
  icustay_id,
  sum (intakes) AS intakes_total
FROM
  t5
GROUP BY
  icustay_id
ORDER BY
  icustay_id;