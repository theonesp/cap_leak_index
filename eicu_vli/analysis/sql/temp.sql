  -- ------------------------------------------------------------------
  -- Title: Temperature for Each Patient
  -- Notes: vol_leak_index/analysis/sql/temp.sql
  --        eICU Collaborative Research Database v2.0.
  -- ------------------------------------------------------------------
SELECT patientunitstayid, max(temperature) as max_temp 
FROM `physionet-data.eicu_crd.vitalperiodic` 
group by patientunitstayid
order by patientunitstayid
