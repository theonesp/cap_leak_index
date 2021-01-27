  -- ------------------------------------------------------------------
  -- Title: Ventilation Patients
  -- Notes: vol_leak_index/analysis/sql/vent.sql
  --        eICU Collaborative Research Database v2.0.
  -- ------------------------------------------------------------------
SELECT distinct(patientunitstayid) FROM `physionet-data.eicu_crd.respiratorycare`
