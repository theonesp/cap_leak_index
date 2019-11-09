-- ------------------------------------------------------------------
-- Title: Patients intake (ml)
-- Notes: cap_leak_index/analysis/sql/eicu_intake.sql 
--        cap_leak_index, 20190511 NYU Datathon
--        eICU Collaborative Research Database v2.0.
-- ------------------------------------------------------------------

-- Attempt 1/2
WITH
first_intake_6hrs AS (
  SELECT
  patientunitstayid,
  intaketotal AS first_intake_6hrs,
  ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY intakeoutputoffset ASC) AS position1,
  cellpath
  FROM
  `physionet-data.eicu_crd.intakeoutput`
  WHERE
  intakeoutputoffset BETWEEN -6*60
  AND 6*60 ),
intake_24hrs AS (
  SELECT
  patientunitstayid,
  intakeoutputoffset, 
  intaketotal AS first_intake_24hrs,
  ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY intakeoutputoffset ASC) AS position2
  FROM
  `physionet-data.eicu_crd.intakeoutput`
  WHERE
  intakeoutputoffset BETWEEN 24*60
  AND 30*60)
SELECT
io1.patientunitstayid AS patientunitstayid,
first_intake_24hrs, 
first_intake_6hrs
position2, position1, intakeoutputoffset
FROM
first_intake_6hrs io1
INNER JOIN
intake_24hrs io2
ON
io2.patientunitstayid = io1.patientunitstayid
WHERE  LOWER (cellpath) LIKE '%crystalloids%' OR LOWER (cellpath) LIKE '%saline%' OR LOWER (cellpath) LIKE '%ringer%' OR LOWER (cellpath) LIKE '%ivf%' OR LOWER (cellpath) LIKE '% ns %'
AND position1 = 1 AND position2 = 1
ORDER BY io1.patientunitstayid

-- Attemp 2/2
WITH
first_intake_6hrs AS (
  SELECT
  patientunitstayid,
  intaketotal AS first_intake_6hrs,
  intakeoutputoffset,
  ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY intakeoutputoffset ASC) AS position1,
  cellpath
  FROM
  `physionet-data.eicu_crd.intakeoutput`
  WHERE
  intakeoutputoffset BETWEEN -6*60
  AND 6*60 ),
intake_24hrs AS (
  SELECT
  patientunitstayid,
  intakeoutputoffset, 
  intaketotal AS first_intake_24hrs,
  cellpath,
  ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY intakeoutputoffset ASC) AS position2
  FROM
  `physionet-data.eicu_crd.intakeoutput`
  WHERE
  intakeoutputoffset BETWEEN 24*60
  AND 30*60)
SELECT
patientunitstayid, 
position1,
intakeoutputoffset
FROM
first_intake_6hrs
WHERE  LOWER (cellpath) LIKE '%crystalloids%' OR LOWER (cellpath) LIKE '%saline%' OR LOWER (cellpath) LIKE '%ringer%' OR LOWER (cellpath) LIKE '%ivf%' OR LOWER (cellpath) LIKE '% ns %'
AND position1 = 1
UNION ALL
SELECT
patientunitstayid,
position2, 
intakeoutputoffset
FROM
intake_24hrs
WHERE  LOWER (cellpath) LIKE '%crystalloids%' OR LOWER (cellpath) LIKE '%saline%' OR LOWER (cellpath) LIKE '%ringer%' OR LOWER (cellpath) LIKE '%ivf%' OR LOWER (cellpath) LIKE '% ns %'
AND position2 = 1
ORDER BY patientunitstayid