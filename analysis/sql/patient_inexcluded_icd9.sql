-- ------------------------------------------------------------------
-- Title: Select patients from diagnosis which are included & excluded by icd9codes
-- Notes: cap_leak_index/analysis/sql/patient_inexcluded.sql 
--        cap_leak_index, 20190511 NYU Datathon
--        eICU Collaborative Research Database v2.0.
-- ------------------------------------------------------------------
SELECT DISTINCT patientunitstayid
FROM 
`physionet-data.eicu_crd.patient` 
WHERE patientunitstayid in (
SELECT
patientunitstayid
FROM
  `physionet-data.eicu_crd.diagnosis`
WHERE
diagnosispriority = 'Major'
AND(
icd9code  LIKE '%785.5%' OR
icd9code  LIKE '%458%' OR
icd9code  LIKE '%96.7%' OR
icd9code  LIKE '%348.3%' OR
icd9code  LIKE '%293%' OR
icd9code  LIKE '%348.1%' OR
icd9code  LIKE '%287.4%' OR
icd9code  LIKE '%287.5%' OR
icd9code  LIKE '%286.9%' OR
icd9code  LIKE '%286.6%' OR
icd9code  LIKE '%570%' OR
icd9code  LIKE '%573.4%' OR
icd9code  LIKE '%584%'
)
OR patientunitstayid in (
SELECT DISTINCT patientunitstayid 
FROM `physionet-data.eicu_crd.admissiondx` 
WHERE LOWER(admitdxpath) LIKE '%sepsis%' OR LOWER(admitdxpath) LIKE '%septic%'
)
--AND patientunitstayid NOT in (
AND patientunitstayid NOT in (
SELECT
patientunitstayid
FROM
  `physionet-data.eicu_crd.diagnosis`
WHERE
diagnosispriority = 'Major'
AND(
icd9code LIKE '%280%' OR
icd9code LIKE '%283.9%' OR
icd9code LIKE '%459%' OR
icd9code LIKE '%285.1%' OR
icd9code LIKE '%785.59%' OR
icd9code LIKE '%423%' OR
icd9code LIKE '%456%' OR
icd9code LIKE '%530.7%' OR
icd9code LIKE '%530.82%' OR
icd9code LIKE '%533.2%' OR
icd9code LIKE '%535.61%' OR
icd9code LIKE '%535.61%' OR
icd9code LIKE '%578%' OR
icd9code LIKE '%578.1%' OR
icd9code LIKE '%719.1%' OR
icd9code LIKE '%719.1%' OR
icd9code LIKE '%719.16%' OR
icd9code LIKE '%719.16%' OR
icd9code LIKE '%853%' OR
icd9code LIKE '%532.4%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%784.7%' OR
icd9code LIKE '%535.11%' OR
icd9code LIKE '%562.12%' OR
icd9code LIKE '%535.51%' OR
icd9code LIKE '%455.2%' OR
icd9code LIKE '%455.5%' OR
icd9code LIKE '%455.8%' OR
icd9code LIKE '%456.2%' OR
icd9code LIKE '%459%' OR
icd9code LIKE '%531%' OR
icd9code LIKE '%531.01%' OR
icd9code LIKE '%531.2%' OR
icd9code LIKE '%531.21%' OR
icd9code LIKE '%531.4%' OR
icd9code LIKE '%531.41%' OR
icd9code LIKE '%531.6%' OR
icd9code LIKE '%531.61%' OR
icd9code LIKE '%532%' OR
icd9code LIKE '%532.01%' OR
icd9code LIKE '%532.2%' OR
icd9code LIKE '%532.21%' OR
icd9code LIKE '%532.41%' OR
icd9code LIKE '%532.6%' OR
icd9code LIKE '%532.61%' OR
icd9code LIKE '%533%' OR
icd9code LIKE '%533.01%' OR
icd9code LIKE '%533.21%' OR
icd9code LIKE '%533.4%' OR
icd9code LIKE '%533.41%' OR
icd9code LIKE '%533.6%' OR
icd9code LIKE '%533.61%' OR
icd9code LIKE '%534%' OR
icd9code LIKE '%534.01%' OR
icd9code LIKE '%534.01%' OR
icd9code LIKE '%534.2%' OR
icd9code LIKE '%534.21%' OR
icd9code LIKE '%534.4%' OR
icd9code LIKE '%534.41%' OR
icd9code LIKE '%534.6%' OR
icd9code LIKE '%534.61%' OR
icd9code LIKE '%535.01%' OR
icd9code LIKE '%535.21%' OR
icd9code LIKE '%535.31%' OR
icd9code LIKE '%535.41%' OR
icd9code LIKE '%537.83%' OR
icd9code LIKE '%537.83%' OR
icd9code LIKE '%562.02%' OR
icd9code LIKE '%562.03%' OR
icd9code LIKE '%562.13%' OR
icd9code LIKE '%568.81%' OR
icd9code LIKE '%569.3%' OR
icd9code LIKE '%569.3%' OR
icd9code LIKE '%569.85%' OR
icd9code LIKE '%596.7%' OR
icd9code LIKE '%599.7%' OR
icd9code LIKE '%719.11%' OR
icd9code LIKE '%719.12%' OR
icd9code LIKE '%719.13%' OR
icd9code LIKE '%719.14%' OR
icd9code LIKE '%719.15%' OR
icd9code LIKE '%719.17%' OR
icd9code LIKE '%719.18%' OR
icd9code LIKE '%719.19%' OR
icd9code LIKE '%784.8%' OR
icd9code LIKE '%786.3%' OR
icd9code LIKE '%853.01%' OR
icd9code LIKE '%853.02%' OR
icd9code LIKE '%853.03%' OR
icd9code LIKE '%853.04%' OR
icd9code LIKE '%853.05%' OR
icd9code LIKE '%853.06%' OR
icd9code LIKE '%853.09%' OR
icd9code LIKE '%569.3%' OR
icd9code LIKE '%455.8%' OR
icd9code LIKE '%578.1%' OR
icd9code LIKE '%599.7%' OR
icd9code LIKE '%531.2%' OR
icd9code LIKE '%531.21%' OR
icd9code LIKE '%531.6%' OR
icd9code LIKE '%531.61%' OR
icd9code LIKE '%532.2%' OR
icd9code LIKE '%532.21%' OR
icd9code LIKE '%532.6%' OR
icd9code LIKE '%532.61%' OR
icd9code LIKE '%533.21%' OR
icd9code LIKE '%533.6%' OR
icd9code LIKE '%533.6%' OR
icd9code LIKE '%533.6%' OR
icd9code LIKE '%533.6%' OR
icd9code LIKE '%533.61%' OR
icd9code LIKE '%533.61%' OR
icd9code LIKE '%533.61%' OR
icd9code LIKE '%533.61%' OR
icd9code LIKE '%534.2%' OR
icd9code LIKE '%534.2%' OR
icd9code LIKE '%534.21%' OR
icd9code LIKE '%534.21%' OR
icd9code LIKE '%534.6%' OR
icd9code LIKE '%534.6%' OR
icd9code LIKE '%534.6%' OR
icd9code LIKE '%534.6%' OR
icd9code LIKE '%534.61%' OR
icd9code LIKE '%534.61%' OR
icd9code LIKE '%534.61%' OR
icd9code LIKE '%534.61%' OR
icd9code LIKE '%577.8%' OR
icd9code LIKE '%580.9%' OR
icd9code LIKE '%785.59%' OR
icd9code LIKE '%853.01%' OR
icd9code LIKE '%853.02%' OR
icd9code LIKE '%853.03%' OR
icd9code LIKE '%853.04%' OR
icd9code LIKE '%853.05%' OR
icd9code LIKE '%853.05%' OR
icd9code LIKE '%853.06%' OR
icd9code LIKE '%853.09%' OR
icd9code LIKE '%853.04%' OR
icd9code LIKE '%569.69%' OR
icd9code LIKE '%530.21%' OR
icd9code LIKE '%423%' OR
icd9code LIKE '%578%' OR
icd9code LIKE '%784.7%' OR
icd9code LIKE '%784.7%' OR
icd9code LIKE '%599.7%' OR
icd9code LIKE '%456%' OR
icd9code LIKE '%530.7%' OR
icd9code LIKE '%530.82%' OR
icd9code LIKE '%533.2%' OR
icd9code LIKE '%535.61%' OR
icd9code LIKE '%535.61%' OR
icd9code LIKE '%578.1%' OR
icd9code LIKE '%719.1%' OR
icd9code LIKE '%719.16%' OR
icd9code LIKE '%719.16%' OR
icd9code LIKE '%853%' OR
icd9code LIKE '%532.4%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%535.11%' OR
icd9code LIKE '%535.11%' OR
icd9code LIKE '%562.12%' OR
icd9code LIKE '%562.12%' OR
icd9code LIKE '%535.41%' OR
icd9code LIKE '%535.41%' OR
icd9code LIKE '%531.4%' OR
icd9code LIKE '%533.4%' OR
icd9code LIKE '%455.5%' OR
icd9code LIKE '%455.2%' OR
icd9code LIKE '%455.2%' OR
icd9code LIKE '%455.2%' OR
icd9code LIKE '%455.5%' OR
icd9code LIKE '%455.5%' OR
icd9code LIKE '%455.2%' OR
icd9code LIKE '%596.8%' OR
icd9code LIKE '%459%' OR
icd9code LIKE '%786.3%' OR
icd9code LIKE '%786.3%' OR
icd9code LIKE '%532%' OR
icd9code LIKE '%531%' OR
icd9code LIKE '%534%' OR
icd9code LIKE '%535.01%' OR
icd9code LIKE '%535.01%' OR
icd9code LIKE '%533%' OR
icd9code LIKE '%255.41%' OR
icd9code LIKE '%569.85%' OR
icd9code LIKE '%569.85%' OR
icd9code LIKE '%537.83%' OR
icd9code LIKE '%537.83%' OR
icd9code LIKE '%459%' OR
icd9code LIKE '%456.8%' OR
icd9code LIKE '%530.21%' OR
icd9code LIKE '%531.4%' OR
icd9code LIKE '%533.4%' OR
icd9code LIKE '%562.13%' OR
icd9code LIKE '%562.13%' OR
icd9code LIKE '%562.13%' OR
icd9code LIKE '%537.89%' OR
icd9code LIKE '%532.4%' OR
icd9code LIKE '%456%' OR
icd9code LIKE '%456%' OR
icd9code LIKE '%455.5%' OR
icd9code LIKE '%599.71%' OR
icd9code LIKE '%599.71%' OR
icd9code LIKE '%531.4%' OR
icd9code LIKE '%719.13%' OR
icd9code LIKE '%719.13%' OR
icd9code LIKE '%535.41%' OR
icd9code LIKE '%535.41%' OR
icd9code LIKE '%455.2%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%455.5%' OR
icd9code LIKE '%455.8%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%534.4%' OR
icd9code LIKE '%534.41%' OR
icd9code LIKE '%534.41%' OR
icd9code LIKE '%533.01%' OR
icd9code LIKE '%533.01%' OR
icd9code LIKE '%532.41%' OR
icd9code LIKE '%532.41%' OR
icd9code LIKE '%531.41%' OR
icd9code LIKE '%531.41%' OR
icd9code LIKE '%532%' OR
icd9code LIKE '%534%' OR
icd9code LIKE '%535.31%' OR
icd9code LIKE '%535.31%' OR
icd9code LIKE '%537.84%' OR
icd9code LIKE '%562.02%' OR
icd9code LIKE '%562.02%' OR
icd9code LIKE '%719.11%' OR
icd9code LIKE '%719.11%' OR
icd9code LIKE '%719.15%' OR
icd9code LIKE '%719.15%' OR
icd9code LIKE '%719.17%' OR
icd9code LIKE '%719.17%' OR
icd9code LIKE '%784.8%' OR
icd9code LIKE '%784.8%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%578.1%' OR
icd9code LIKE '%599.7%' OR
icd9code LIKE '%599.7%' OR
icd9code LIKE '%578.1%' OR
icd9code LIKE '%535.41%' OR
icd9code LIKE '%535.41%' OR
icd9code LIKE '%535.61%' OR
icd9code LIKE '%535.61%' OR
icd9code LIKE '%569.3%' OR
icd9code LIKE '%569.3%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%578.9%' OR
icd9code LIKE '%784.7%' OR
icd9code LIKE '%784.7%' OR
icd9code LIKE '%531%' OR
icd9code LIKE '%533%' OR
icd9code LIKE '%534%' OR
icd9code LIKE '%578%' OR
icd9code LIKE '%578%' OR
icd9code LIKE '%853%' OR
icd9code LIKE '%719.1%' OR
icd9code LIKE '%719.1%' OR
icd9code LIKE '%456.8%' OR
icd9code LIKE '%531.41%' OR
icd9code LIKE '%531.41%' OR
icd9code LIKE '%532.41%' OR
icd9code LIKE '%532.41%' OR
icd9code LIKE '%533.41%' OR
icd9code LIKE '%533.41%' OR
icd9code LIKE '%533.41%' OR
icd9code LIKE '%533.41%' OR
icd9code LIKE '%534.41%' OR
icd9code LIKE '%534.41%' OR
icd9code LIKE '%534.61%' OR
icd9code LIKE '%534.61%' OR
icd9code LIKE '%569.3%' OR
icd9code LIKE '%459%' OR
icd9code LIKE '%599.7%' OR
icd9code LIKE '%853%' OR
icd9code LIKE '%501450%' OR
icd9code LIKE '%535.51%' OR
icd9code LIKE '%535.51%' OR
icd9code LIKE '%532.4%' OR
icd9code LIKE '%501451%' OR
icd9code LIKE '%532.31%' OR
icd9code LIKE '%599.7%' OR
icd9code LIKE '%599.7%' OR
icd9code LIKE '%535.71%' OR
icd9code LIKE '%535.71%' OR
icd9code LIKE '%599.71%' OR
icd9code LIKE '%599.71%' OR
icd9code LIKE '%535.71%' OR
icd9code LIKE '%535.71%' OR
icd9code LIKE '%503%' OR
icd9code LIKE '%193%' OR
icd9code LIKE '%430%' OR
icd9code LIKE '%430%' OR
icd9code LIKE '%430%' OR
icd9code LIKE '%431%' OR
icd9code LIKE '%431%' OR
icd9code LIKE '%431%' OR
icd9code LIKE '%431%' OR
icd9code LIKE '%431%' OR
icd9code LIKE '%431%' OR
icd9code LIKE '%431%' OR
icd9code LIKE '%432%' OR
icd9code LIKE '%432%' OR
icd9code LIKE '%432%' OR
icd9code LIKE '%432%' OR
icd9code LIKE '%432.1%' OR
icd9code LIKE '%432.1%' OR
icd9code LIKE '%432.1%' OR
icd9code LIKE '%432.1%' OR
icd9code LIKE '%432.9%'
)
)

)
ORDER BY patientunitstayid


