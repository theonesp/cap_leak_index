-- this query extracts preadm fluid intake from MIMICIII on the first 24 hrs of admission
-- This code is based on the notebook by Komorowski available at https://github.com/matthieukomorowski/AI_Clinician/blob/0438a66de7c5270e84a7fa51d78f56cd934ad240/AIClinician_Data_extract_MIMIC3_140219.ipynb
-- volume is in ML

WITH
  mv AS (
  SELECT
    inputevents_mv.icustay_id,
    SUM(inputevents_mv.amount) AS sum,
  FROM
    `physionet-data.mimiciii_clinical.inputevents_mv` inputevents_mv,
    `physionet-data.mimiciii_clinical.d_items` d_items
  LEFT JOIN
    `physionet-data.mimiciii_clinical.icustays`
  USING
    (icustay_id)    
  WHERE
    inputevents_mv.itemid=d_items.itemid
    AND inputevents_mv.itemid IN (30054,
      30055,
      30101,
      30102,
      30103,
      30104,
      30105,
      30108,
      226361,
      226363,
      226364,
      226365,
      226367,
      226368,
      226369,
      226370,
      226371,
      226372,
      226375,
      226376,
      227070,
      227071,
      227072)
  AND DATETIME_DIFF(starttime, INTIME, MINUTE)  BETWEEN -6*60 AND 36*60 -- only 1st day intake
  GROUP BY
    icustay_id ),
  cv AS (
  SELECT
    inputevents_cv.icustay_id,
    SUM(inputevents_cv.amount) AS sum
  FROM
    `physionet-data.mimiciii_clinical.inputevents_cv` inputevents_cv,
    `physionet-data.mimiciii_clinical.d_items` d_items
  LEFT JOIN
    `physionet-data.mimiciii_clinical.icustays`
  USING
    (icustay_id)      
  WHERE
    inputevents_cv.itemid=d_items.itemid
    AND inputevents_cv.itemid IN (30054,
      30055,
      30101,
      30102,
      30103,
      30104,
      30105,
      30108,
      226361,
      226363,
      226364,
      226365,
      226367,
      226368,
      226369,
      226370,
      226371,
      226372,
      226375,
      226376,
      227070,
      227071,
      227072)
   AND DATETIME_DIFF(charttime, INTIME, MINUTE)  BETWEEN -6*60 AND 36*60 -- only 1st day intake    
  GROUP BY
    icustay_id )
SELECT
  icustays.icustay_id,
  CASE
    WHEN mv.sum IS NOT NULL THEN mv.sum
    WHEN cv.sum IS NOT NULL THEN cv.sum
  ELSE
  NULL
END
  AS intake_preadm
FROM
  `physionet-data.mimiciii_clinical.icustays` icustays
LEFT OUTER JOIN
  mv
ON
  mv.icustay_id=icustays.icustay_id
LEFT OUTER JOIN
  cv
ON
  cv.icustay_id=icustays.icustay_id
WHERE
  mv.sum >0
  OR cv.sum > 0
ORDER BY
  icustay_id
