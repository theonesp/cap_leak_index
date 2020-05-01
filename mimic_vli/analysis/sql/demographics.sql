-- Patients demographics
SELECT
  icustay_id,
  gender,
  admission_age AS age_fixed,
  hospital_expire_flag AS hosp_mortality ,
  ROUND(SQRT((height_max*weight_max) / 3600),2) AS body_surface_area
FROM
  `physionet-data.mimiciii_derived.icustay_detail`
LEFT JOIN
  `physionet-data.mimiciii_derived.heightweight`
USING
  (icustay_id)  
WHERE  
  admission_age >=16
