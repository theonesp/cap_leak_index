-- ------------------------------------------------------------------
-- Title: Patients hematocrit in -6~+6 and 24~36 hours.
-- Notes: cap_leak_index/analysis/sql/hct.sql 
--        cap_leak_index, 20190511 NYU Datathon
--        eICU Collaborative Research Database v2.0.
-- A +-6 hours safety time window was introduced to the timepoints
-- ------------------------------------------------------------------
WITH
first_hct_6hrs_pivoted_lab AS (
  SELECT
  patientunitstayid,
  hematocrit AS first_hct_6hrs,
  ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY chartoffset ASC) AS position
  FROM
  `physionet-data.eicu_crd_derived.pivoted_lab` pivoted_lab
  WHERE
  chartoffset BETWEEN -6*60 AND 6*60 ),
mean_hct_24_36hrs_pivoted_lab AS (
  SELECT
  patientunitstayid,
  ROUND( AVG (CASE
              WHEN chartoffset BETWEEN 24*60 AND 36*60 AND hematocrit IS NOT NULL THEN hematocrit
              END
  ),2) AS mean_hct_24_36hrs
  FROM
  `physionet-data.eicu_crd_derived.pivoted_lab`
  GROUP BY
  patientunitstayid ),
first_hct_6hrs_lab AS(
SELECT 
 patientunitstayid,
  labresult AS first_hct_6hrs,
  ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY labresultoffset ASC) AS position
FROM `physionet-data.eicu_crd.lab` WHERE labname ='Hct'
AND  labresultoffset BETWEEN -6*60 AND 6*60 
),
mean_hct_24_36hrs_lab AS (
SELECT
  patientunitstayid,
  ROUND( AVG (CASE
        WHEN labresultoffset BETWEEN 24*60 AND 36*60 AND labname ='Hct' THEN labresult
    END
      ),2) AS mean_hct_24_36hrs
FROM
  `physionet-data.eicu_crd.lab`
GROUP BY
  patientunitstayid
)  
SELECT
patient.patientunitstayid,
COALESCE(first_hct_6hrs_pivoted_lab.first_hct_6hrs, first_hct_6hrs_lab.first_hct_6hrs) AS first_hct_6hrs,
COALESCE(mean_hct_24_36hrs_pivoted_lab.mean_hct_24_36hrs, mean_hct_24_36hrs_lab.mean_hct_24_36hrs) AS mean_hct_24_36hrs
FROM
`physionet-data.eicu_crd.patient` patient
LEFT JOIN
first_hct_6hrs_pivoted_lab
ON
first_hct_6hrs_pivoted_lab.patientunitstayid = patient.patientunitstayid AND first_hct_6hrs_pivoted_lab.position = 1 AND first_hct_6hrs_pivoted_lab.first_hct_6hrs IS NOT NULL
LEFT JOIN
mean_hct_24_36hrs_pivoted_lab
ON
mean_hct_24_36hrs_pivoted_lab.patientunitstayid = patient.patientunitstayid AND mean_hct_24_36hrs_pivoted_lab.mean_hct_24_36hrs IS NOT NULL
LEFT JOIN
first_hct_6hrs_lab
ON
first_hct_6hrs_lab.patientunitstayid = patient.patientunitstayid AND first_hct_6hrs_lab.position = 1 AND first_hct_6hrs_lab.first_hct_6hrs IS NOT NULL
LEFT JOIN
mean_hct_24_36hrs_lab
ON
mean_hct_24_36hrs_lab.patientunitstayid = patient.patientunitstayid AND mean_hct_24_36hrs_lab.mean_hct_24_36hrs IS NOT NULL
