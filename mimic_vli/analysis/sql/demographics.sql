-- Patients demographics
SELECT
  icustay_id,
  gender,
  admission_age,
  hospital_expire_flag
FROM
  `physionet-data.mimiciii_derived.icustay_detail`
WHERE  
  admission_age >=16
