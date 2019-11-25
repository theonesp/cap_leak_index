with t1 as (
SELECT
distinct patientunitstayid
FROM
`physionet-data.eicu_crd.intakeoutput`
WHERE LOWER (cellpath) LIKE '%crystalloids%' OR LOWER (cellpath) LIKE '%saline%' OR LOWER (cellpath) LIKE '%ringer%' OR LOWER (cellpath) LIKE '%ivf%' OR LOWER (cellpath) LIKE  '% ns %'),

t2 as (
SELECT
*
FROM
`physionet-data.eicu_crd.intakeoutput`
WHERE
intakeoutputoffset BETWEEN -6*60
AND 30*60),

t3 as (
SELECT
patientunitstayid,
SUM(cellvaluenumeric) AS intakes
FROM
t2
WHERE
LOWER (cellpath) LIKE '%intake%'
GROUP BY patientunitstayid), 

t4 as (
SELECT
patientunitstayid,
SUM(cellvaluenumeric) AS outputs
FROM
t2
WHERE
LOWER (cellpath) LIKE '%output%'
GROUP BY patientunitstayid)

SELECT
*
FROM
t1
LEFT JOIN 
t3
using (patientunitstayid)
LEFT JOIN
t4
using (patientunitstayid)
WHERE intakes is not NULL or outputs is not null
ORDER BY patientunitstayid