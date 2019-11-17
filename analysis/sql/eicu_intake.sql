-- ------------------------------------------------------------------
-- Title: Patients intake (ml)
-- Notes: cap_leak_index/analysis/sql/eicu_intake.sql 
--        cap_leak_index, 20190511 NYU Datathon
--        eICU Collaborative Research Database v2.0.
-- ------------------------------------------------------------------

-- attempt 3 (most accurate- however, the intake values seem to be off significantly
with t1 as (
SELECT
*
FROM
`physionet-data.eicu_crd.intakeoutput`
WHERE
intakeoutputoffset BETWEEN -6*60
AND 6*60),
t2 as (
SELECT
*
FROM
`physionet-data.eicu_crd.intakeoutput`
WHERE
intakeoutputoffset BETWEEN 24*60
AND 30*60),
first_intake_6hrs AS (
  SELECT
  patientunitstayid,
  intaketotal AS intake_6hrs,
  intakeoutputoffset AS intakeoutputoffset1,
  cellpath
  FROM
  t1
  WHERE
  LOWER (cellpath) LIKE '%crystalloids%' OR LOWER (cellpath) LIKE '%saline%' OR LOWER (cellpath) LIKE '%ringer%' OR LOWER (cellpath) LIKE '%ivf%' OR LOWER (cellpath) LIKE  '% ns %'),
  first_intake_24hrs AS (
  SELECT
  patientunitstayid,
  intakeoutputoffset AS intakeoutputoffset2, 
  intaketotal AS intake_24hrs,
  cellpath
  FROM
  t2
  WHERE
  LOWER (cellpath) LIKE '%crystalloids%' OR LOWER (cellpath) LIKE '%saline%' OR LOWER (cellpath) LIKE '%ringer%' OR LOWER (cellpath) LIKE '%ivf%' OR LOWER (cellpath) LIKE  '% ns %'),
inter_6hrs AS (
SELECT patientunitstayid,
  intake_6hrs,
  intakeoutputoffset1,
  cellpath, 
  ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY intakeoutputoffset1 ASC) AS position1 
  FROM first_intake_6hrs ),
inter_24hrs AS (
SELECT patientunitstayid,
  intakeoutputoffset2, 
  intake_24hrs,
  cellpath, ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY intakeoutputoffset2 ASC) AS position2 
  FROM first_intake_24hrs), 
real_6hrs AS (SELECT * FROM inter_6hrs WHERE position1 = 1),
real_24hrs AS (SELECT * FROM inter_24hrs WHERE position2 = 1)
SELECT
patientunitstayid, intake_24hrs, intake_6hrs, intakeoutputoffset2, intakeoutputoffset1, intake_24hrs + intake_6hrs AS added
FROM
real_6hrs
INNER JOIN
real_24hrs
USING
(patientunitstayid) 
ORDER BY patientunitstayid