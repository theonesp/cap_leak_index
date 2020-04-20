  -- selects septic patients according to different criteria in mimic derived tables
WITH
  angus_sepsis AS(
  SELECT
    DISTINCT subject_id,
    hadm_id
  FROM
    `physionet-data.mimiciii_derived.angus_sepsis`
  WHERE
    explicit_sepsis = 1
    OR angus = 1 ),
  martin_sepsis AS(
  SELECT
    DISTINCT subject_id,
    hadm_id
  FROM
    `physionet-data.mimiciii_derived.martin_sepsis`
  WHERE
    sepsis = 1 ),
  explicit_sepsis AS(
  SELECT
    DISTINCT subject_id,
    hadm_id
  FROM
    `physionet-data.mimiciii_derived.explicit_sepsis`
  WHERE
    severe_sepsis= 1
    OR septic_shock =1
    OR sepsis =1 )
SELECT
  subject_id
FROM
  angus_sepsis
UNION DISTINCT
SELECT
  subject_id
FROM
  martin_sepsis
UNION DISTINCT
SELECT
  subject_id
FROM
  explicit_sepsis