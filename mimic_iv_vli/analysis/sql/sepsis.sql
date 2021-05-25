  -- ------------------------------------------------------------------
  -- Description: Septic patients to be excluded.
  -- Notes: /analysis/sql/hct.sql
  --        MIMICIII  
  -- Selects septic patients according to different criteria in mimic derived tables
  -- ------------------------------------------------------------------
  WITH
  angus_sepsis AS(
  SELECT
    icustays.stay_id,
    MAX(CASE
        WHEN explicit_sepsis = 1 OR angus = 1 THEN 1
      ELSE
      0
    END
      ) AS sepsis
  FROM
    `physionet-data.mimic_derived.angus_sepsis`
  JOIN
    `physionet-data.mimic_icu.icustays` icustays
  USING
    (hadm_id)
  GROUP BY
    stay_id ),
  martin_sepsis AS(
  SELECT
    icustays.stay_id,
    MAX(CASE
        WHEN sepsis = 1 THEN 1
      ELSE
      0
    END
      ) AS sepsis
  FROM
    `physionet-data.mimic_derived.martin_sepsis`
  JOIN
    `physionet-data.mimic_icu.icustays` icustays
  USING
    (hadm_id)
  GROUP BY
    stay_id ),
  explicit_sepsis AS(
  SELECT
    icustays.stay_id,
    MAX(CASE
        WHEN severe_sepsis = 1 OR septic_shock =1 OR sepsis =1 THEN 1
      ELSE
      0
    END
      ) AS sepsis
  FROM
    `physionet-data.mimic_derived.explicit_sepsis`
  JOIN
    `physionet-data.mimic_icu.icustays` icustays
  USING
    (hadm_id)
  GROUP BY
    stay_id )
SELECT
  stay_id
FROM
  angus_sepsis
WHERE sepsis = 1  
UNION DISTINCT
SELECT
  stay_id
FROM
  martin_sepsis
WHERE sepsis = 1    
UNION DISTINCT
SELECT
  stay_id
FROM
  explicit_sepsis
WHERE sepsis = 1    