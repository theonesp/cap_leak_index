WITH
    t1 AS (
    SELECT
      pt.patientunitstayid,
      MAX(CASE
          WHEN LOWER(labname) LIKE 'creatin%' THEN labresult
          ELSE NULL END) AS creat
    FROM
      `physionet-data.eicu_crd.patient` pt
    LEFT OUTER JOIN
      `physionet-data.eicu_crd.lab` lb
    ON
      pt.patientunitstayid=lb.patientunitstayid
    WHERE
      labresultoffset BETWEEN -1440
      AND 1440
    GROUP BY
      pt.patientunitstayid ),
    t2 AS (
    WITH
      uotemp AS (
      SELECT
        patientunitstayid,
        CASE
          WHEN dayz=1 THEN SUM(outputtotal)
          ELSE NULL
        END AS uod1
      FROM (
        SELECT
          DISTINCT patientunitstayid,
          intakeoutputoffset,
          outputtotal,
          (CASE
              WHEN (intakeoutputoffset) BETWEEN -120 AND 1440 THEN 1
              ELSE NULL END) AS dayz
        FROM
          `physionet-data.eicu_crd.intakeoutput`
        WHERE
          intakeoutputoffset BETWEEN 0
          AND 5760
        ORDER BY
          patientunitstayid,
          intakeoutputoffset ) AS temp
      GROUP BY
        patientunitstayid,
        temp.dayz )
    SELECT
      pt.patientunitstayid,
      MAX(CASE
          WHEN uod1 IS NOT NULL THEN uod1
          ELSE NULL END) AS UO
    FROM
      `physionet-data.eicu_crd.patient` pt
    LEFT OUTER JOIN
      uotemp
    ON
      uotemp.patientunitstayid=pt.patientunitstayid
    GROUP BY
      pt.patientunitstayid )
  SELECT
    pt.patientunitstayid,
    -- t1.creat, t2.uo,
    (CASE
        WHEN uo <200 OR creat>5 THEN 4
        WHEN uo <500
      OR creat >3.5 THEN 3
        WHEN creat BETWEEN 2 AND 3.5 THEN 2
        WHEN creat BETWEEN 1.2
      AND 2 THEN 1
        ELSE 0 END) AS sofarenal
  FROM
    `physionet-data.eicu_crd.patient` pt
  LEFT OUTER JOIN
    t1
  ON
    t1.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t2
  ON
    t2.patientunitstayid=pt.patientunitstayid
  ORDER BY
    pt.patientunitstayid
    -- group by pt.patientunitstayid, t1.creat, t2.uo
    --);
