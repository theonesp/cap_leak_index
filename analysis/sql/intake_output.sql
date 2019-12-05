with t1 as (
SELECT
distinct patientunitstayid
FROM
`physionet-data.eicu_crd.intakeoutput`
WHERE LOWER (cellpath) LIKE '%crystalloids%' 
OR LOWER (cellpath) LIKE '%saline%' 
OR LOWER (cellpath) LIKE '%ringer%' 
OR LOWER (cellpath) LIKE '%ivf%' 
OR LOWER (cellpath) LIKE  '% ns %'
OR LOWER (cellpath) LIKE '%nacl%'
OR LOWER (cellpath) LIKE '%free%'
OR LOWER (cellpath) LIKE '%kcl%'
OR LOWER (cellpath) LIKE '%dextrose%'
OR LOWER (cellpath) LIKE '%potassium%'
OR LOWER (cellpath) LIKE '%sodium%'
OR LOWER (cellpath) LIKE '%calcium%'
OR LOWER (cellpath) LIKE '%d5%'
OR LOWER (cellpath) LIKE '%lr%'),

t2 as (
SELECT
*
FROM
`physionet-data.eicu_crd.intakeoutput`
WHERE
intakeoutputoffset BETWEEN -6*60 AND 36*60),

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
USING (patientunitstayid)
LEFT JOIN
t4
USING (patientunitstayid)
WHERE intakes IS NOT NULL
ORDER BY patientunitstayid
