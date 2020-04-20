-- ------------------------------------------------------------------
-- Title: Peak creatinine within 48hrs.
-- Notes: cap_leak_index/analysis/sql/aki/peakcreat48h.sql 
--        cap_leak_index, 20190511 NYU Datathon
--        eICU Collaborative Research Database v2.0.
-- ------------------------------------------------------------------
WITH peakcr AS
  (SELECT patientunitstayid,
          labresultoffset AS peakcreat48h_offset,
          labresult AS peakcreat48h,
          Row_number() OVER (PARTITION BY patientunitstayid
                             ORDER BY labresult DESC) AS POSITION
   FROM `physionet-data.eicu_crd.lab`
   WHERE labname LIKE 'creatinine%'
     AND labresultoffset >= 0
     AND labresultoffset <= (48 * 60) --Within 48hrs

   GROUP BY patientunitstayid,
            labresultoffset,
            labresult
   ORDER BY patientunitstayid,
            labresultoffset)
SELECT patientunitstayid
, peakcreat48h_offset
, peakcreat48h
FROM peakcr
WHERE POSITION = 1


