-- ------------------------------------------------------------------
-- Title: Select patients from apachepatientresult 
-- Notes: cap_leak_index/analysis/sql/apache_related.sql
--        cap_leak_index, 20190511 NYU Datathon
--        eICU Collaborative Research Database v2.0.
-- ------------------------------------------------------------------
SELECT 
  patientunitstayid
, MAX(apachescore) AS apachescore
, MAX(actualicumortality) AS actualicumortality
, MAX(actualhospitalmortality) AS actualhospitalmortality
, MAX(unabridgedunitlos) AS unabridgedunitlos
, MAX(unabridgedhosplos) AS unabridgedhosplos
, MAX(unabridgedactualventdays) AS unabridgedactualventdays

FROM `physionet-data.eicu_crd.apachepatientresult`

GROUP BY patientunitstayid
