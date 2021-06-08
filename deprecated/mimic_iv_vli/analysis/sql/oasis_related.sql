-- Extracts oasis severity score.

SELECT
  stay_id,
  MAX(OASIS) AS oasis
FROM
  `physionet-data.mimic_derived.oasis`
GROUP BY
  stay_id
