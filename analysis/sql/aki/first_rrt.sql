-- ------------------------------------------------------------------
-- Title: First rrt treatment (from treatment and intakeoutput tables)
-- Notes: cap_leak_index/analysis/sql/aki/first_rrt.sql 
--        cap_leak_index, 20190511 NYU Datathon
--        eICU Collaborative Research Database v2.0.
-- ------------------------------------------------------------------
WITH first_rrt_treatment AS
  (SELECT DISTINCT patientunitstayid,
   MIN (treatmentoffset) AS treatmentoffset
   FROM `physionet-data.eicu_crd.treatment`
   WHERE   LOWER(treatmentstring) LIKE '%rrt%'
    OR LOWER(treatmentstring) LIKE '%dialysis%'
    OR LOWER(treatmentstring) LIKE '%ultrafiltration%'
    OR LOWER(treatmentstring) LIKE '%cavhd%' 
    OR LOWER(treatmentstring) LIKE '%cvvh%' 
    OR LOWER(treatmentstring) LIKE '%sled%'
    AND Lower(treatmentstring) NOT LIKE '%chronic%'
   GROUP BY patientunitstayid),
   
  first_rrt_intakeoutput AS
  (SELECT DISTINCT patientunitstayid,
   MIN (intakeoutputoffset) AS intakeoutputoffset
   FROM `physionet-data.eicu_crd.intakeoutput`
   WHERE LOWER(cellpath) LIKE '%rrt%'
    OR LOWER(cellpath) LIKE '%dialysis%'
    OR LOWER(cellpath) LIKE '%ultrafiltration%'
    OR LOWER(cellpath) LIKE '%cavhd%' 
    OR LOWER(cellpath) LIKE '%cvvh%' 
    OR LOWER(cellpath) LIKE '%sled%'
   GROUP BY patientunitstayid)
   
SELECT patientunitstayid
,LEAST (first_rrt_treatment.treatmentoffset, first_rrt_intakeoutput.intakeoutputoffset) AS first_rrtoffset
,1 AS rrt_bin
FROM `physionet-data.eicu_crd.patient`
LEFT JOIN first_rrt_treatment USING (patientunitstayid)
LEFT JOIN first_rrt_intakeoutput USING (patientunitstayid)
WHERE LEAST(first_rrt_treatment.treatmentoffset, first_rrt_intakeoutput.intakeoutputoffset) IS NOT NULL
ORDER BY patientunitstayid


