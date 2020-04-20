-- ------------------------------------------------------------------
-- Title: Select patients from apachepatientresult 
-- Notes: cap_leak_index/analysis/sql/apache_related.sql
--        cap_leak_index, 20190511 NYU Datathon
--        eICU Collaborative Research Database v2.0.
-- ------------------------------------------------------------------
-- IMPORTANT: ACCORDING TO THE DOCUMMENTATION -1 in Apache score or predictedHospitalMortality means missing.

SELECT 
  icustay_detail.patientunitstayid
, MAX(apachescore) AS apachescore
, MAX(actualicumortality) AS actualicumortality
, MAX(unabridgedunitlos) AS unabridgedunitlos
, MAX(unabridgedhosplos) AS unabridgedhosplos
, MAX(unabridgedactualventdays) AS unabridgedactualventdays
, MAX(apachepatientresult.predictedHospitalMortality) AS predictedHospitalMortality --calculated from Apache
, MAX(icustay_detail.apache_iv) AS apache_iv --deriverd version of Apache IV

FROM `physionet-data.eicu_crd.apachepatientresult` apachepatientresult
LEFT JOIN
  `physionet-data.eicu_crd_derived.icustay_detail` icustay_detail
ON
  apachepatientresult.patientunitstayid = icustay_detail.patientunitstayid
GROUP BY icustay_detail.patientunitstayid
