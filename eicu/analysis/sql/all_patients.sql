SELECT 
  patientunitstayid
, hospitalid
, wardid
, hospitaldischargeyear
FROM
  `physionet-data.eicu_crd.patient` 
ORDER BY
  patientunitstayid
