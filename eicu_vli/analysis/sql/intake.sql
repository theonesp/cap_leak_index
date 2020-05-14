-- this query extracts all intake fluids from intakeoutput 
  SELECT
    patientunitstayid,
    SUM(cellvaluenumeric) AS intakes_total
  FROM
    `physionet-data.eicu_crd.intakeoutput`
  WHERE
    intakeoutputoffset BETWEEN -6*60 AND 36*60
    AND LOWER (cellpath) LIKE '%intake%'
    AND cellvaluenumeric IS NOT NULL
    AND ( LOWER (cellpath) LIKE '%crystalloids%'
      OR LOWER (cellpath) LIKE '%saline%'
      OR LOWER (cellpath) LIKE '%ringer%'
      OR LOWER (cellpath) LIKE '%ivf%'
      OR LOWER (cellpath) LIKE '% ns %' )
  GROUP BY
    patientunitstayid