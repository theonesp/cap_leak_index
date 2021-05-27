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
    outputevents.stay_id
  FROM
    `physionet-data.mimic_icu.outputevents` outputevents
  JOIN
  `physionet-data.mimic_icu.icustays` icustays
USING
  (stay_id)  
JOIN
  `physionet-data.mimic_icu.d_items`
USING
  (itemid)  
  WHERE
    DATETIME_DIFF(charttime, INTIME, MINUTE) BETWEEN -6*60 AND 36*60 
    AND LOWER(label) LIKE '%blood%' ),
others AS(
SELECT
  outputevents.stay_id,
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
  `physionet-data.mimic_icu.outputevents` outputevents
JOIN
  `physionet-data.mimic_icu.d_items`
USING
  (itemid)
JOIN
  `physionet-data.mimic_icu.icustays` icustays
USING
  (stay_id)
GROUP BY
  stay_id
  )
SELECT
  stay_id
FROM
  blood
UNION DISTINCT  
 SELECT
  stay_id
FROM
  others
WHERE
  gastric >= 500
  OR stool >= 500
  OR emesis >= 500 