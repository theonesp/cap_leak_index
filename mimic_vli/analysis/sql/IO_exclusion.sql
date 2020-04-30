-- ------------------------------------------------------------------
-- Title: Select patientunitstayid from intakeoutput 
--        VLI, 043020 NYU Datathon
--        MIMIC III
-- We want to exclude patients based on the amount of output gastric >= 500 OR stool >= 500 OR emesis >= 500
-- We are also excluding patients with any amount of blood output
-- Units need to be in ML
-- ------------------------------------------------------------------
WITH 
  blood AS(
  SELECT
    outputevents.ICUSTAY_ID
  FROM
    `physionet-data.mimiciii_clinical.outputevents` outputevents
  JOIN
  `physionet-data.mimiciii_clinical.icustays` icustays
USING
  (icustay_id)  
JOIN
  `physionet-data.mimiciii_clinical.d_items`
USING
  (itemid)  
  WHERE
    DATETIME_DIFF(charttime, INTIME, MINUTE) BETWEEN -6*60 AND 36*60 
    AND LOWER(label) LIKE '%blood%' ),
others AS(
SELECT
  outputevents.ICUSTAY_ID,
  SUM(CASE
      WHEN LOWER(label) LIKE '%gastric%' AND DATETIME_DIFF(charttime, INTIME, MINUTE) BETWEEN -6*60 AND 6*60 THEN VALUE
    ELSE
    0
  END
    ) AS gastric,
  SUM(CASE
      WHEN LOWER(label) LIKE '%stool%' AND DATETIME_DIFF(charttime, INTIME, MINUTE) BETWEEN -6*60 AND 6*60 THEN VALUE
    ELSE
    0
  END
    ) AS stool,
  SUM(CASE
      WHEN LOWER(label) LIKE '%emesis%' AND DATETIME_DIFF(charttime, INTIME, MINUTE) BETWEEN -6*60 AND 6*60 THEN VALUE
    ELSE
    0
  END
    ) AS emesis
FROM
  `physionet-data.mimiciii_clinical.outputevents` outputevents
JOIN
  `physionet-data.mimiciii_clinical.d_items`
USING
  (itemid)
JOIN
  `physionet-data.mimiciii_clinical.icustays` icustays
USING
  (icustay_id)
GROUP BY
  ICUSTAY_ID
  )
SELECT
  ICUSTAY_ID
FROM
  blood
UNION DISTINCT  
 SELECT
  ICUSTAY_ID
FROM
  others
WHERE
  gastric >= 500
  OR stool >= 500
  OR emesis >= 500 