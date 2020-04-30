-- Query extracting the todal sofa for the first 4 days of admissions.

WITH
  sofa_ref AS (
  SELECT
    icustays.icustay_id,
    DATETIME_DIFF(starttime, INTIME, MINUTE) AS chartoffset,
    SOFA_24hours
  FROM
    `physionet-data.mimiciii_clinical.icustays` icustays
  JOIN
    `physionet-data.mimiciii_derived.pivoted_sofa` pivoted_sofa
  USING
    (icustay_id)
  ORDER BY
    icustay_id, starttime, endtime),
  sofa_day1 AS (
  SELECT
    icustay_id,
    MAX(SOFA_24hours) AS sofatotal_day1
  FROM
    sofa_ref
  WHERE
    chartoffset BETWEEN -1440 AND 1440
  GROUP BY
    icustay_id ),
  sofa_day2 AS (
  SELECT
    icustay_id,
    MAX(SOFA_24hours) AS sofatotal_day2
  FROM
    sofa_ref
  WHERE
    chartoffset BETWEEN 1440 AND 2*1440
  GROUP BY
    icustay_id),
  sofa_day3 AS (
  SELECT
    icustay_id,
    MAX(SOFA_24hours) AS sofatotal_day3
  FROM
    sofa_ref
  WHERE
    chartoffset BETWEEN 2*1440 AND 3*1440
  GROUP BY
    icustay_id),
  sofa_day4 AS (
  SELECT
    icustay_id,
    MAX(SOFA_24hours) AS sofatotal_day4
  FROM
    sofa_ref
  WHERE
    chartoffset BETWEEN 3*1440 AND 4*1440
  GROUP BY
    icustay_id)
SELECT
  icustays.icustay_id,
  sofatotal_day1,
  sofatotal_day2,
  sofatotal_day3,
  sofatotal_day4
FROM
  `physionet-data.mimiciii_clinical.icustays` icustays
LEFT JOIN
  sofa_day1
USING
  (icustay_id)
LEFT JOIN
  sofa_day2
USING
  (icustay_id)
LEFT JOIN
  sofa_day3
USING
  (icustay_id)
LEFT JOIN
  sofa_day4
USING
  (icustay_id)  
ORDER BY
  icustay_id
