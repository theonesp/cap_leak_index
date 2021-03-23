  -- ------------------------------------------------------------------
  -- Title: Ventilation Patients
  -- Notes: vol_leak_index/analysis/sql/vent.sql
  --        eICU Collaborative Research Database v2.0.
  -- ------------------------------------------------------------------
SELECT
  patient.patientunitstayid,
  MAX(CASE WHEN patient.patientunitstayid = respiratorycare.patientunitstayid THEN 1
    ELSE 0 END) AS mech_vent
FROM
  `physionet-data.eicu_crd.patient` patient
LEFT JOIN
  `physionet-data.eicu_crd.respiratorycare` respiratorycare
USING
  (patientunitstayid)
GROUP BY
  patientunitstayid