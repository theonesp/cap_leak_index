with t1 as (
SELECT
distinct patientunitstayid
FROM
`physionet-data.eicu_crd.infusiondrug`
WHERE LOWER (drugname) LIKE '%crystalloids%' 
OR LOWER (drugname) LIKE '%saline%' 
OR LOWER (drugname) LIKE '%ringer%' 
OR LOWER (drugname) LIKE '%ivf%' 
OR LOWER (drugname) LIKE  '% ns %'),

t2 as (
SELECT
*
FROM
`physionet-data.eicu_crd.infusiondrug`
WHERE
infusionoffset BETWEEN -6*60 AND 36*60),

t3 as (
SELECT
patientunitstayid,
SUM(volumeoffluid) AS intakes
FROM
t2
GROUP BY patientunitstayid)


SELECT
*
FROM
t1
LEFT JOIN 
t3
USING (patientunitstayid)
WHERE intakes IS NOT NULL
ORDER BY patientunitstayid
