-- ------------------------------------------------------------------
-- Title: Patients demographics
-- Notes: cap_leak_index/analysis/sql/demographics.sql 
--        cap_leak_index, 20190511 NYU Datathon
--        eICU Collaborative Research Database v2.0.
-- ------------------------------------------------------------------
WITH
  weight AS (
  WITH
    t1 AS (
    SELECT
      patientunitstayid
      -- all of the below weights are measured in kg
      ,
      CAST(nursingchartvalue AS NUMERIC) AS weight
    FROM
      `physionet-data.eicu_crd.nursecharting`
    WHERE
      nursingchartcelltypecat = 'Other Vital Signs and Infusions'
      AND nursingchartcelltypevallabel IN ( 'Admission Weight',
        'Admit weight',
        'WEIGHT in Kg' )
      -- ensure that nursingchartvalue is numeric
      AND REGEXP_CONTAINS(nursingchartvalue, '^([0-9]+\\.?[0-9]*|\\.[0-9]+)$')
      AND NURSINGCHARTOFFSET >= -60
      AND NURSINGCHARTOFFSET < 60*24 )
    -- weight from intake/output table
    ,
    t2 AS (
    SELECT
      patientunitstayid,
      CASE
        WHEN CELLPATH = 'flowsheet|Flowsheet Cell Labels|I&O|Weight|Bodyweight (kg)' THEN CELLVALUENUMERIC
        ELSE CELLVALUENUMERIC*0.453592
      END AS weight
    FROM
      `physionet-data.eicu_crd.intakeoutput`
      -- there are ~300 extra (lb) measurements, so we include both
      -- worth considering that this biases the median of all three tables towards these values..
    WHERE
      CELLPATH IN ( 'flowsheet|Flowsheet Cell Labels|I&O|Weight|Bodyweight (kg)',
        'flowsheet|Flowsheet Cell Labels|I&O|Weight|Bodyweight (lb)' )
      AND INTAKEOUTPUTOFFSET >= -60
      AND INTAKEOUTPUTOFFSET < 60*24 )
    -- weight from infusiondrug
    ,
    t3 AS (
    SELECT
      patientunitstayid,
      CAST(PATIENTWEIGHT AS NUMERIC) AS weight
    FROM
      `physionet-data.eicu_crd.infusiondrug`
    WHERE
      PATIENTWEIGHT IS NOT NULL
      AND INFUSIONOFFSET >= -60
      AND INFUSIONOFFSET < 60*24 ),
    unioned AS (
    SELECT
      patientunitstayid,
      admissionweight AS weight
    FROM
      `physionet-data.eicu_crd.patient` pt
    UNION ALL
    SELECT
      patientunitstayid,
      weight
    FROM
      t1
    UNION ALL
    SELECT
      patientunitstayid,
      weight
    FROM
      t2
    UNION ALL
    SELECT
      patientunitstayid,
      weight
    FROM
      t3 )
  SELECT
    patientunitstayid,
    ROUND(AVG(weight), 2) AS weight_avg
  FROM
    unioned
  WHERE
    weight >= 30
    AND weight <= 300
  GROUP BY
    patientunitstayid
  ORDER BY
    patientunitstayid ),
  demographics AS (
  SELECT
    p.patientUnitStayID,
    CASE -- fixing age >89 to 93
      WHEN p.age = '> 89' THEN 93 -- age avg of eicu patients >89
      WHEN p.age IS NOT NULL AND p.age !='' THEN CAST (p.age AS INT64)
    END AS age_fixed,
    p.gender,
    w.weight_avg,
    (CASE
        WHEN p.admissionHeight >90 AND p.admissionHeight <300 THEN p.admissionHeight
        ELSE NULL END) AS height,
    ROUND(CASE
        WHEN p.admissionHeight >90 AND p.admissionHeight < 300 THEN (10000*w.weight_avg/(p.admissionHeight*p.admissionHeight))
        ELSE NULL END) AS BMI,
    p.unitDischargeOffset
  FROM
    `physionet-data.eicu_crd.patient` p
  LEFT JOIN
    weight w
  ON
    w.patientunitstayid = p.patientUnitStayID
  ORDER BY
    p.patientUnitStayID )
SELECT
  DISTINCT demographics.patientunitstayid,
  demographics.age_fixed,
  demographics.gender,
  weight_avg AS weight,
  (hospitalDischargeOffset - hospitalAdmitOffset) / (60 * 24) AS HospitalLOS,
  height,
  BMI,
  -- categorizes BMI values into categories
  CASE
    WHEN BMI < 18 THEN "underweight"
    WHEN BMI >= 18
  AND BMI < 25 THEN "normal"
    WHEN BMI >= 25 THEN "overweight"
    WHEN BMI >= 30 THEN "obese"
    ELSE NULL
  END AS BMI_group,
  -- the picklist unit type of the unit e.g.: MICU,Cardiovascular ICU,SDU/Step down,VICU,Neuro ICU,CCU,Virtual ICU,SICU,ICU,CCUCTICU, Mobile ICU,CTICU,CSICU,Test ICU,Vent ICU,Burn- Trauma ICU
  patient.unitType,
  --location from where the patient was admitted to the hospital e.g.: Direct Admit, Floor, Chest Pain Center. etc.
  hospitalAdmitSource,
  -- length of hospital stay prior to ICU admission (days)
  ROUND(actualHospitalLOS - actualICULOS,2) AS hospLOS_prior_ICUadm_days
FROM
  demographics
LEFT JOIN
  `physionet-data.eicu_crd.apachepatientresult` apachepatientresult
ON
  demographics.patientunitstayid = apachepatientresult.patientunitstayid
LEFT JOIN
  `physionet-data.eicu_crd.patient` patient
ON
  demographics.patientunitstayid = patient.patientunitstayid
WHERE 
  age_fixed >= 18  


