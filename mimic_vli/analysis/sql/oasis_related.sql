-- Extracts oasis severity score.

SELECT
  subject_id,
  hadm_id,
  icustay_id,
  OASIS
FROM
  `physionet-data.mimiciii_derived.oasis`
