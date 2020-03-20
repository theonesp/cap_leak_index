-- This query extracts the diagnosis string for bleeding from the table diagnosis.
SELECT
  DISTINCT patientUnitStayID
FROM
  `physionet-data.eicu_crd.diagnosis`
WHERE
  (LOWER(diagnosisString) LIKE '%hemorrhage%')
  OR (LOWER(diagnosisString) LIKE '%blood loss%')
  OR (LOWER(diagnosisString) LIKE '%bleed%'
    AND NOT LOWER(diagnosisString) LIKE '%bleeding and red blood cell disorders%')