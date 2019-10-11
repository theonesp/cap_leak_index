  WITH
    t1 AS (
    WITH
      tt1 AS (
      SELECT
        patientunitstayid,
        MIN(
          CASE
            WHEN noninvasivemean IS NOT NULL THEN noninvasivemean
            ELSE NULL END) AS map
      FROM
        `physionet-data.eicu_crd.vitalaperiodic`
      WHERE
        observationoffset BETWEEN -1440
        AND 1440
      GROUP BY
        patientunitstayid ),
      tt2 AS (
      SELECT
        patientunitstayid,
        MIN(
          CASE
            WHEN systemicmean IS NOT NULL THEN systemicmean
            ELSE NULL END) AS map
      FROM
        `physionet-data.eicu_crd.vitalperiodic`
      WHERE
        observationoffset BETWEEN -1440 AND 1440
      GROUP BY
        patientunitstayid )
    SELECT
      pt.patientunitstayid,
      CASE
        WHEN tt1.map IS NOT NULL THEN tt1.map
        WHEN tt2.map IS NOT NULL THEN tt2.map
        ELSE NULL
      END AS map
    FROM
      `physionet-data.eicu_crd.patient` pt
    LEFT OUTER JOIN
      tt1
    ON
      tt1.patientunitstayid=pt.patientunitstayid
    LEFT OUTER JOIN
      tt2
    ON
      tt2.patientunitstayid=pt.patientunitstayid
    ORDER BY
      pt.patientunitstayid ),
    t2 AS (
    SELECT
      DISTINCT patientunitstayid,
      MAX(
        CASE
          WHEN LOWER(drugname) LIKE '%(ml/hr)%' THEN ROUND(CAST(drugrate AS numeric)/3,3) -- rate in ml/h * 1600 mcg/ml / 80 kg / 60 min, to convert in mcg/kg/min
          WHEN LOWER(drugname) LIKE '%(mcg/kg/min)%' THEN CAST(drugrate AS numeric)
          ELSE NULL
        END ) AS dopa
    FROM
      `physionet-data.eicu_crd.infusiondrug` id
    WHERE
      LOWER(drugname) LIKE '%dopamine%'
      AND infusionoffset BETWEEN -120
      AND 1440
      AND REGEXP_CONTAINS(drugrate, '^[0-9]{0,5}$')
      AND drugrate<>''
      AND drugrate<>'.'
    GROUP BY
      patientunitstayid
    ORDER BY
      patientunitstayid ),
    t3 AS (
    SELECT
      DISTINCT patientunitstayid,
      MAX(CASE
          WHEN LOWER(drugname) LIKE '%(ml/hr)%' AND drugrate<>'' AND drugrate<>'.' THEN ROUND(CAST(drugrate AS numeric)/300,3) -- rate in ml/h * 16 mcg/ml / 80 kg / 60 min, to convert in mcg/kg/min
          WHEN LOWER(drugname) LIKE '%(mcg/min)%' AND drugrate<>'' AND drugrate<>'.' THEN ROUND(CAST(drugrate AS numeric)/80,3)-- divide by 80 kg
          WHEN LOWER(drugname) LIKE '%(mcg/kg/min)%' AND drugrate<>'' AND drugrate<>'.' THEN CAST(drugrate AS numeric)
          ELSE NULL
        END ) AS norepi
    FROM
      `physionet-data.eicu_crd.infusiondrug` id
    WHERE
      LOWER(drugname) LIKE '%epinephrine%'
      AND infusionoffset BETWEEN -120
      AND 1440
      AND REGEXP_CONTAINS(drugrate, '^[0-9]{0,5}$')
      AND drugrate<>''
      AND drugrate<>'.'-- this regex will capture norepi as well
    GROUP BY
      patientunitstayid
    ORDER BY
      patientunitstayid ),
    t4 AS (
    SELECT
      DISTINCT patientunitstayid,
      1 AS dobu
    FROM
      `physionet-data.eicu_crd.infusiondrug` id
    WHERE
      LOWER(drugname) LIKE '%dobutamin%'
      AND drugrate <>''
      AND drugrate<>'.'
      AND drugrate <>'0'
      AND REGEXP_CONTAINS(drugrate, '^[0-9]{0,5}$')
      AND infusionoffset BETWEEN -120 AND 1440
    ORDER BY
      patientunitstayid )
  SELECT
    pt.patientunitstayid,
    t1.map,
    t2.dopa,
    t3.norepi,
    t4.dobu,
    (CASE
        WHEN dopa>=15 OR norepi>0.1 THEN 4
        WHEN dopa>5
      OR (norepi>0
        AND norepi <=0.1) THEN 3
        WHEN dopa<=5 OR dobu > 0 THEN 2
        WHEN map <70 THEN 1
        ELSE 0 END) AS SOFA_cv
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
  LEFT OUTER JOIN
    t3
  ON
    t3.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t4
  ON
    t4.patientunitstayid=pt.patientunitstayid
  ORDER BY
    pt.patientunitstayid
