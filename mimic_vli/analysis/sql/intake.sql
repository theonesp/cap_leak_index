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
        AND mv.rateuom = 'mL/hour'
        AND mv.rate > 248)
      OR (mv.rate IS NOT NULL
        AND mv.rateuom = 'mL/min'
        AND mv.rate > (248/60.0))
      OR (mv.rate IS NULL
        AND mv.amountuom = 'L'
        AND mv.amount > 0.248)
      OR (mv.rate IS NULL
        AND mv.amountuom = 'ml'
        AND mv.amount > 248) ) ),
    
t3 AS(
  SELECT
    *
  FROM
    t1
    -- just because the rate was high enough, does *not* mean the final amount was
  WHERE
    amount > 248
    AND icustay_id IS NOT NULL
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
    amount > 248
    AND icustay_id IS NOT NULL
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
    AND chartoffset BETWEEN -6*60 AND 24*60
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
