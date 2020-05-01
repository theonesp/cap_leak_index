-- Extracts oasis severity score.

SELECT
  icustay_id,
  MAX(OASIS) AS oasis
FROM
  `physionet-data.mimiciii_derived.oasis`
GROUP BY
  icustay_id
