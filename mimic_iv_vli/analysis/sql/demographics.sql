-- Patients demographics
SELECT
  stay_id,
  icustay_detail.gender,
  icustay_detail.los_hospital,
  icustay_detail.los_icu,
  oasis.icustay_expire_flag AS icu_mortality,
  CASE WHEN admission_age > 89 THEN 91.4 ELSE admission_age END AS age_fixed,
  icustay_detail.hospital_expire_flag AS hosp_mortality ,
  CASE WHEN icustay_detail.hospital_expire_flag = 1 THEN DATETIME_DIFF(dod_hosp, INTIME, MINUTE) ELSE 0 END AS hosp_mortality_offset,
  CAST(ROUND(SQRT((height_max*weight_max) / 3600),2) AS INT64) AS body_surface_area
FROM
  `physionet-data.mimic_derived.icustay_detail` icustay_detail
LEFT JOIN
  `physionet-data.mimic_derived.heightweight`
USING
  (stay_id)
LEFT JOIN
  `physionet-data.mimic_core.patients` patients
USING
    (subject_id)
LEFT JOIN
  `physionet-data.mimic_derived.oasis` oasis
USING
  (stay_id)    
WHERE  
  admission_age >=16
