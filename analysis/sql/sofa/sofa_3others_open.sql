WITH
    t1f AS (
    SELECT
      patientunitstayid,
      physicalexamoffset,
      MIN(CASE
          WHEN LOWER(physicalexampath) LIKE '%gcs/eyes%' THEN CAST(physicalexamvalue AS INT64)
          ELSE NULL END) AS gcs_eyes,
      MIN(CASE
          WHEN LOWER(physicalexampath) LIKE '%gcs/verbal%' THEN CAST(physicalexamvalue AS INT64)
          ELSE NULL END) AS gcs_verbal,
      MIN(CASE
          WHEN LOWER(physicalexampath) LIKE '%gcs/motor%' THEN CAST(physicalexamvalue AS INT64)
          ELSE NULL END) AS gcs_motor
    FROM
      `physionet-data.eicu_crd.physicalexam` pe
    WHERE
      (LOWER(physicalexampath) LIKE '%gcs/eyes%'
        OR LOWER(physicalexampath) LIKE '%gcs/verbal%'
        OR LOWER(physicalexampath) LIKE '%gcs/motor%')
      AND physicalexamoffset BETWEEN -1440
      AND 1440
    GROUP BY
      patientunitstayid,
      physicalexamoffset ),
    t1 AS (
    SELECT
      patientunitstayid,
      MIN(coalesce(gcs_eyes,
          4) + coalesce(gcs_verbal,
          5) + coalesce(gcs_motor,
          6)) AS gcs
    FROM
      t1f
    GROUP BY
      patientunitstayid ),
    t2 AS (
    SELECT
      pt.patientunitstayid,
      MAX(CASE
          WHEN LOWER(labname) LIKE 'total bili%' THEN labresult
          ELSE NULL END) AS bili,
      MIN(CASE
          WHEN LOWER(labname) LIKE 'platelet%' THEN labresult
          ELSE NULL END) AS plt
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
      pt.patientunitstayid )
  SELECT
    DISTINCT pt.patientunitstayid,
    MIN(t1.gcs) AS gcs,
    MAX(t2.bili) AS bili,
    MIN(t2.plt) AS plt,
    MAX(CASE
        WHEN plt<20 THEN 4
        WHEN plt<50 THEN 3
        WHEN plt<100 THEN 2
        WHEN plt<150 THEN 1
        ELSE 0 END) AS sofacoag,
    MAX(CASE
        WHEN bili>12 THEN 4
        WHEN bili>6 THEN 3
        WHEN bili>2 THEN 2
        WHEN bili>1.2 THEN 1
        ELSE 0 END) AS sofaliver,
    MAX(CASE
        WHEN gcs=15 THEN 0
        WHEN gcs>=13 THEN 1
        WHEN gcs>=10 THEN 2
        WHEN gcs>=6 THEN 3
        WHEN gcs>=3 THEN 4
        ELSE 0 END) AS sofacns
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
  GROUP BY
    pt.patientunitstayid,
    t1.gcs,
    t2.bili,
    t2.plt
  ORDER BY
    pt.patientunitstayid