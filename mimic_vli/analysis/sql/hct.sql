-- ------------------------------------------------------------------
-- Description: Patients hematocrit in -6~+6 and 24~36 hours.
-- Notes: /analysis/sql/hct.sql 
--        MIMICIII
-- A +-12 hours safety time window was introduced to the timepoints to increase sample size
-- ------------------------------------------------------------------

WITH
  first_hct_6hrs_pivoted_lab AS (
  SELECT
    icustays.subject_id,
    icustays.hadm_id,
    DATETIME_DIFF(charttime, INTIME, MINUTE) AS chartoffset,
    HEMATOCRIT AS first_hct_6hrs,
    ROW_NUMBER() OVER (PARTITION BY hadm_id ORDER BY charttime ASC) AS position
  FROM
    `physionet-data.mimiciii_clinical.icustays` icustays
  JOIN
    `physionet-data.mimiciii_derived.pivoted_lab` pivoted_lab
  USING
    (hadm_id)
  WHERE
    DATETIME_DIFF(charttime,
      INTIME,
      MINUTE) BETWEEN -12*60  AND 18*60
    AND hematocrit IS NOT NULL ),
  mean_hct_24_36hrs_lab AS (
  SELECT
    icustays.hadm_id,
    ROUND( AVG(HEMATOCRIT),2) AS mean_hct_24_36hrs
  FROM
    `physionet-data.mimiciii_clinical.icustays` icustays
  JOIN
    `physionet-data.mimiciii_derived.pivoted_lab` pivoted_lab
  USING
    (hadm_id)
  WHERE
    DATETIME_DIFF(charttime,
      INTIME,
      MINUTE) BETWEEN 18*60
    AND 318*60
    AND hematocrit IS NOT NULL
  GROUP BY
    hadm_id )
SELECT
  icustays.hadm_id,
  first_hct_6hrs,
  mean_hct_24_36hrs
FROM
  `physionet-data.mimiciii_clinical.icustays` icustays
LEFT JOIN
  first_hct_6hrs_pivoted_lab
USING
  (hadm_id)
LEFT JOIN
  mean_hct_24_36hrs_lab
USING
  (hadm_id) 
WHERE position = 1  
