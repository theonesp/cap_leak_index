-- ------------------------------------------------------------------
-- Title: Chronic patients with AKI receiving rrt prior to ICU admission
-- Notes: cap_leak_index/analysis/sql/aki/chronicAKI.sql 
--        cap_leak_index, 20190511 NYU Datathon
--        eICU Collaborative Research Database v2.0.
-- ------------------------------------------------------------------
SELECT
  DISTINCT patientunitstayid
FROM
  `physionet-data.eicu_crd.treatment`
WHERE
  LOWER(treatmentstring) LIKE '%rrt%'
  OR LOWER(treatmentstring) LIKE '%dialysis%'
  OR LOWER(treatmentstring) LIKE '%ultrafiltration%'
  OR LOWER(treatmentstring) LIKE '%cavhd%' 
  OR LOWER(treatmentstring) LIKE '%cvvh%' 
  OR LOWER(treatmentstring) LIKE '%sled%'
  AND 
  LOWER(treatmentstring) LIKE '%chronic%'
UNION  DISTINCT

  SELECT
  DISTINCT patientunitstayid
FROM 
  `physionet-data.eicu_crd.apacheapsvar`
WHERE
  dialysis = 1 -- chronic dialysis prior to hospital adm

