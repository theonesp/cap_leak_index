with t1 as (
SELECT
*
FROM
`physionet-data.eicu_crd.intakeoutput`
WHERE
intakeoutputoffset BETWEEN -6*60
AND 30*60),
t2 as (
SELECT
*
FROM
t1
WHERE
LOWER (cellpath) LIKE '%crystalloids%' OR LOWER (cellpath) LIKE '%saline%' OR LOWER (cellpath) LIKE '%ringer%' OR LOWER (cellpath) LIKE '%ivf%' OR LOWER (cellpath) LIKE  '% ns %')

SELECT
patientunitstayid,
SUM(cellvaluenumeric)
FROM
t2
WHERE
LOWER (cellpath) LIKE '%crystalloids%' OR LOWER (cellpath) LIKE '%saline%' OR LOWER (cellpath) LIKE '%ringer%' OR LOWER (cellpath) LIKE '%ivf%' OR LOWER (cellpath) LIKE  '% ns %'
GROUP BY patientunitstayid
ORDER BY patientunitstayid