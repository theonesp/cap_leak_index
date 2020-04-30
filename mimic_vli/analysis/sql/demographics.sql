-- Patients demographics

SELECT
  subject_id,
  hadm_id,
  icustay_id,
  gender,
  admission_age,
  hospital_expire_flag
FROM
  `physionet-data.mimiciii_derived.icustay_detail`
