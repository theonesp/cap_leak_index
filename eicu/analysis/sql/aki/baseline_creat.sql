-- ------------------------------------------------------------------
-- Title: Patients first creatinine available value between -12 and +12h from admission 
-- Notes: cap_leak_index/analysis/sql/aki/baseline_creat.sql 
--        cap_leak_index, 20190511 NYU Datathon
--        eICU Collaborative Research Database v2.0.
-- ------------------------------------------------------------------
WITH tempo AS
  ( SELECT patientunitstayid,
           labname,
           labresultoffset,
           labresult,
           ROW_NUMBER() OVER (PARTITION BY patientunitstayid, labname ORDER BY labresultoffset ASC) AS POSITION
   FROM `physionet-data.eicu_crd.lab`
   WHERE ((labname) = 'creatinine')
     AND labresultoffset BETWEEN -720 AND 720 -- first creat available value between -12 and +12h from admission 
     ORDER BY patientunitstayid, labresultoffset )
SELECT patientunitstayid,
       max(CASE WHEN (labname) = 'creatinine' AND POSITION =1 THEN labresult ELSE NULL END) AS creat1,
       max(CASE WHEN (labname) = 'creatinine' AND POSITION =1 THEN labresultoffset ELSE NULL END) AS creat1offset
FROM tempo
GROUP BY patientunitstayid
ORDER BY patientunitstayid

