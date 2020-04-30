-- Query extracting the todal sofa for the first 4 days of admissions.
-- requires sofa_3others_day1_to_day4.sql, sofa_cv_day1_to_day4.sql, sofa_renal_day1_to_day4.sql & sofa_respi_day1_to_day4.sql

SELECT demographic.patientunitstayid,

max(sofa_cv_day1_to_day4.sofa_cv_day1 + sofa_respi_day1_to_day4.sofa_respi_day1 + sofa_renal_day1_to_day4.sofarenal_day1 + sofa_3others_day1_to_day4.sofacoag_day1 + sofa_3others_day1_to_day4.sofaliver_day1 + sofa_3others_day1_to_day4.sofacns_day1) AS sofatotal_day1,

max(sofa_cv_day1_to_day4.sofa_cv_day2 + sofa_respi_day1_to_day4.sofa_respi_day2 + sofa_renal_day1_to_day4.sofarenal_day2 + sofa_3others_day1_to_day4.sofacoag_day2 + sofa_3others_day1_to_day4.sofaliver_day2 + sofa_3others_day1_to_day4.sofacns_day2) AS sofatotal_day2,

max(sofa_cv_day1_to_day4.sofa_cv_day3 + sofa_respi_day1_to_day4.sofa_respi_day3 + sofa_renal_day1_to_day4.sofarenal_day3 + sofa_3others_day1_to_day4.sofacoag_day3 + sofa_3others_day1_to_day4.sofaliver_day3 + sofa_3others_day1_to_day4.sofacns_day3) AS sofatotal_day3,

max(sofa_cv_day1_to_day4.sofa_cv_day4 + sofa_respi_day1_to_day4.sofa_respi_day4 + sofa_renal_day1_to_day4.sofarenal_day4 + sofa_3others_day1_to_day4.sofacoag_day4 + sofa_3others_day1_to_day4.sofaliver_day4 + sofa_3others_day1_to_day4.sofacns_day4) AS sofatotal_day4

FROM 
demographic
INNER JOIN sofa_cv_day1_to_day4 ON  demographic.patientunitstayid = sofa_cv_day1_to_day4.patientunitstayid
INNER JOIN sofa_respi_day1_to_day4  ON demographic.patientunitstayid = sofa_renal_day1_to_day4.patientunitstayid
INNER JOIN sofa_renal_day1_to_day4  ON demographic.patientunitstayid = sofa_respi_day1_to_day4.patientunitstayid
INNER JOIN sofa_3others_day1_to_day4  ON demographic.patientunitstayid = sofa_3others_day1_to_day4.patientunitstayid
GROUP BY demographic.patientunitstayid
ORDER BY demographic.patientunitstayid
