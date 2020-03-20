WITH
------------------VARS day1------------------------
    t1_day1 AS (
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
        observationoffset BETWEEN -1440 AND 1440
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
    t2_day1 AS (
    SELECT
      DISTINCT patientunitstayid,
      MAX(
        CASE
          WHEN LOWER(drugname) LIKE '%(ml/hr)%' THEN ROUND(CAST(drugrate AS INT64)/3,3) -- rate in ml/h * 1600 mcg/ml / 80 kg / 60 min, to convert in mcg/kg/min
          WHEN LOWER(drugname) LIKE '%(mcg/kg/min)%' THEN CAST(drugrate AS INT64)
          ELSE NULL
        END ) AS dopa
    FROM
      `physionet-data.eicu_crd.infusiondrug` id
    WHERE
      LOWER(drugname) LIKE '%dopamine%'
      AND infusionoffset BETWEEN -1440 AND 1440
      AND REGEXP_CONTAINS(drugrate, '^[0-9]{0,5}$')
      AND drugrate<>''
      AND drugrate<>'.'
    GROUP BY
      patientunitstayid
    ORDER BY
      patientunitstayid ),
    t3_day1 AS (
    SELECT
      DISTINCT patientunitstayid,
      MAX(CASE
          WHEN LOWER(drugname) LIKE '%(ml/hr)%' AND drugrate<>'' AND drugrate<>'.' THEN ROUND(CAST(drugrate AS INT64)/300,3) -- rate in ml/h * 16 mcg/ml / 80 kg / 60 min, to convert in mcg/kg/min
          WHEN LOWER(drugname) LIKE '%(mcg/min)%' AND drugrate<>'' AND drugrate<>'.' THEN ROUND(CAST(drugrate AS INT64)/80,3)-- divide by 80 kg
          WHEN LOWER(drugname) LIKE '%(mcg/kg/min)%' AND drugrate<>'' AND drugrate<>'.' THEN CAST(drugrate AS INT64)
          ELSE NULL
        END ) AS norepi
    FROM
      `physionet-data.eicu_crd.infusiondrug` id
    WHERE
      LOWER(drugname) LIKE '%epinephrine%'
      AND infusionoffset BETWEEN -1440 AND 1440
      AND REGEXP_CONTAINS(drugrate, '^[0-9]{0,5}$')
      AND drugrate<>''
      AND drugrate<>'.'-- this regex will capture norepi as well
    GROUP BY
      patientunitstayid
    ORDER BY
      patientunitstayid ),
    t4_day1 AS (
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
      AND infusionoffset BETWEEN -1440 AND 1440
    ORDER BY
      patientunitstayid ),
------------------VARS day2------------------------
    t1_day2 AS (
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
        observationoffset BETWEEN 1440 AND 1440*2
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
        observationoffset BETWEEN 1440 AND 1440*2
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
    t2_day2 AS (
    SELECT
      DISTINCT patientunitstayid,
      MAX(
        CASE
          WHEN LOWER(drugname) LIKE '%(ml/hr)%' THEN ROUND(CAST(drugrate AS INT64)/3,3) -- rate in ml/h * 1600 mcg/ml / 80 kg / 60 min, to convert in mcg/kg/min
          WHEN LOWER(drugname) LIKE '%(mcg/kg/min)%' THEN CAST(drugrate AS INT64)
          ELSE NULL
        END ) AS dopa
    FROM
      `physionet-data.eicu_crd.infusiondrug` id
    WHERE
      LOWER(drugname) LIKE '%dopamine%'
      AND infusionoffset BETWEEN 1440 AND 1440*2
      AND REGEXP_CONTAINS(drugrate, '^[0-9]{0,5}$')
      AND drugrate<>''
      AND drugrate<>'.'
    GROUP BY
      patientunitstayid
    ORDER BY
      patientunitstayid ),
    t3_day2 AS (
    SELECT
      DISTINCT patientunitstayid,
      MAX(CASE
          WHEN LOWER(drugname) LIKE '%(ml/hr)%' AND drugrate<>'' AND drugrate<>'.' THEN ROUND(CAST(drugrate AS INT64)/300,3) -- rate in ml/h * 16 mcg/ml / 80 kg / 60 min, to convert in mcg/kg/min
          WHEN LOWER(drugname) LIKE '%(mcg/min)%' AND drugrate<>'' AND drugrate<>'.' THEN ROUND(CAST(drugrate AS INT64)/80,3)-- divide by 80 kg
          WHEN LOWER(drugname) LIKE '%(mcg/kg/min)%' AND drugrate<>'' AND drugrate<>'.' THEN CAST(drugrate AS INT64)
          ELSE NULL
        END ) AS norepi
    FROM
      `physionet-data.eicu_crd.infusiondrug` id
    WHERE
      LOWER(drugname) LIKE '%epinephrine%'
      AND infusionoffset BETWEEN 1440 AND 1440*2
      AND REGEXP_CONTAINS(drugrate, '^[0-9]{0,5}$')
      AND drugrate<>''
      AND drugrate<>'.'-- this regex will capture norepi as well
    GROUP BY
      patientunitstayid
    ORDER BY
      patientunitstayid ),
    t4_day2 AS (
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
      AND infusionoffset BETWEEN 1440 AND 1440*2
    ORDER BY
      patientunitstayid ),      
------------------VARS day3------------------------
    t1_day3 AS (
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
        observationoffset BETWEEN 1440*2 AND 1440*3
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
        observationoffset BETWEEN 1440*2 AND 1440*3
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
    t2_day3 AS (
    SELECT
      DISTINCT patientunitstayid,
      MAX(
        CASE
          WHEN LOWER(drugname) LIKE '%(ml/hr)%' THEN ROUND(CAST(drugrate AS INT64)/3,3) -- rate in ml/h * 1600 mcg/ml / 80 kg / 60 min, to convert in mcg/kg/min
          WHEN LOWER(drugname) LIKE '%(mcg/kg/min)%' THEN CAST(drugrate AS INT64)
          ELSE NULL
        END ) AS dopa
    FROM
      `physionet-data.eicu_crd.infusiondrug` id
    WHERE
      LOWER(drugname) LIKE '%dopamine%'
      AND infusionoffset BETWEEN 1440*2 AND 1440*3
      AND REGEXP_CONTAINS(drugrate, '^[0-9]{0,5}$')
      AND drugrate<>''
      AND drugrate<>'.'
    GROUP BY
      patientunitstayid
    ORDER BY
      patientunitstayid ),
    t3_day3 AS (
    SELECT
      DISTINCT patientunitstayid,
      MAX(CASE
          WHEN LOWER(drugname) LIKE '%(ml/hr)%' AND drugrate<>'' AND drugrate<>'.' THEN ROUND(CAST(drugrate AS INT64)/300,3) -- rate in ml/h * 16 mcg/ml / 80 kg / 60 min, to convert in mcg/kg/min
          WHEN LOWER(drugname) LIKE '%(mcg/min)%' AND drugrate<>'' AND drugrate<>'.' THEN ROUND(CAST(drugrate AS INT64)/80,3)-- divide by 80 kg
          WHEN LOWER(drugname) LIKE '%(mcg/kg/min)%' AND drugrate<>'' AND drugrate<>'.' THEN CAST(drugrate AS INT64)
          ELSE NULL
        END ) AS norepi
    FROM
      `physionet-data.eicu_crd.infusiondrug` id
    WHERE
      LOWER(drugname) LIKE '%epinephrine%'
      AND infusionoffset BETWEEN 1440*2 AND 1440*3
      AND REGEXP_CONTAINS(drugrate, '^[0-9]{0,5}$')
      AND drugrate<>''
      AND drugrate<>'.'-- this regex will capture norepi as well
    GROUP BY
      patientunitstayid
    ORDER BY
      patientunitstayid ),
    t4_day3 AS (
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
      AND infusionoffset BETWEEN 1440*2 AND 1440*3
    ORDER BY
      patientunitstayid ),         
------------------VARS day4------------------------
    t1_day4 AS (
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
        observationoffset BETWEEN 1440*3 AND 1440*4
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
        observationoffset BETWEEN 1440*3 AND 1440*4
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
    t2_day4 AS (
    SELECT
      DISTINCT patientunitstayid,
      MAX(
        CASE
          WHEN LOWER(drugname) LIKE '%(ml/hr)%' THEN ROUND(CAST(drugrate AS INT64)/3,3) -- rate in ml/h * 1600 mcg/ml / 80 kg / 60 min, to convert in mcg/kg/min
          WHEN LOWER(drugname) LIKE '%(mcg/kg/min)%' THEN CAST(drugrate AS INT64)
          ELSE NULL
        END ) AS dopa
    FROM
      `physionet-data.eicu_crd.infusiondrug` id
    WHERE
      LOWER(drugname) LIKE '%dopamine%'
      AND infusionoffset BETWEEN 1440*3 AND 1440*4
      AND REGEXP_CONTAINS(drugrate, '^[0-9]{0,5}$')
      AND drugrate<>''
      AND drugrate<>'.'
    GROUP BY
      patientunitstayid
    ORDER BY
      patientunitstayid ),
    t3_day4 AS (
    SELECT
      DISTINCT patientunitstayid,
      MAX(CASE
          WHEN LOWER(drugname) LIKE '%(ml/hr)%' AND drugrate<>'' AND drugrate<>'.' THEN ROUND(CAST(drugrate AS INT64)/300,3) -- rate in ml/h * 16 mcg/ml / 80 kg / 60 min, to convert in mcg/kg/min
          WHEN LOWER(drugname) LIKE '%(mcg/min)%' AND drugrate<>'' AND drugrate<>'.' THEN ROUND(CAST(drugrate AS INT64)/80,3)-- divide by 80 kg
          WHEN LOWER(drugname) LIKE '%(mcg/kg/min)%' AND drugrate<>'' AND drugrate<>'.' THEN CAST(drugrate AS INT64)
          ELSE NULL
        END ) AS norepi
    FROM
      `physionet-data.eicu_crd.infusiondrug` id
    WHERE
      LOWER(drugname) LIKE '%epinephrine%'
      AND infusionoffset BETWEEN 1440*3 AND 1440*4
      AND REGEXP_CONTAINS(drugrate, '^[0-9]{0,5}$')
      AND drugrate<>''
      AND drugrate<>'.'-- this regex will capture norepi as well
    GROUP BY
      patientunitstayid
    ORDER BY
      patientunitstayid ),
    t4_day4 AS (
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
      AND infusionoffset BETWEEN 1440*3 AND 1440*4
    ORDER BY
      patientunitstayid )          
  SELECT
    pt.patientunitstayid,
    ------------------VARS day1------------------------
    t1_day1.map AS map_day1,
    t2_day1.dopa AS dopa_day1,
    t3_day1.norepi AS norepi_day1,
    t4_day1.dobu AS dobu_day1,
    (CASE
        WHEN t2_day1.dopa >= 15 OR t3_day1.norepi >0.1 THEN 4
        WHEN t2_day1.dopa > 5 OR (t3_day1.norepi > 0 AND t3_day1.norepi <= 0.1) THEN 3
        WHEN t2_day1.dopa <= 5 OR t4_day1.dobu > 0 THEN 2 WHEN t1_day1.map < 70 THEN 1 
        ELSE 0
     END) AS SOFA_cv_day1, 
------------------VARS day2------------------------
    t1_day2.map AS map_day2,
    t2_day2.dopa AS dopa_day2,
    t3_day2.norepi AS norepi_day2,
    t4_day2.dobu AS dobu_day2,
    (CASE
        WHEN t2_day2.dopa >= 15 OR t3_day2.norepi >0.1 THEN 4
        WHEN t2_day2.dopa > 5 OR (t3_day2.norepi > 0 AND t3_day2.norepi <= 0.1) THEN 3
        WHEN t2_day2.dopa <= 5 OR t4_day2.dobu > 0 THEN 2 WHEN t1_day2.map < 70 THEN 1 
        ELSE 0
     END) AS SOFA_cv_day2,  
------------------VARS day3------------------------
    t1_day3.map AS map_day3,
    t2_day3.dopa AS dopa_day3,
    t3_day3.norepi AS norepi_day3,
    t4_day3.dobu AS dobu_day3,
    (CASE
        WHEN t2_day3.dopa >= 15 OR t3_day3.norepi >0.1 THEN 4
        WHEN t2_day3.dopa > 5 OR (t3_day3.norepi > 0 AND t3_day3.norepi <= 0.1) THEN 3
        WHEN t2_day3.dopa <= 5 OR t4_day3.dobu > 0 THEN 2 WHEN t1_day3.map < 70 THEN 1 
        ELSE 0
     END) AS SOFA_cv_day3,      
------------------VARS day4------------------------
    t1_day4.map AS map_day4,
    t2_day4.dopa AS dopa_day4,
    t3_day4.norepi AS norepi_day4,
    t4_day4.dobu AS dobu_day4,
    (CASE
        WHEN t2_day4.dopa >= 15 OR t3_day4.norepi >0.1 THEN 4
        WHEN t2_day4.dopa > 5 OR (t3_day4.norepi > 0 AND t3_day4.norepi <= 0.1) THEN 3
        WHEN t2_day4.dopa <= 5 OR t4_day4.dobu > 0 THEN 2 WHEN t1_day4.map < 70 THEN 1 
        ELSE 0
     END) AS SOFA_cv_day4       
  FROM
    `physionet-data.eicu_crd.patient` pt
  ------------------VARS day1------------------------  
  LEFT OUTER JOIN
    t1_day1
  ON
    t1_day1.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t2_day1
  ON
    t2_day1.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t3_day1
  ON
    t3_day1.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t4_day1
  ON
    t4_day1.patientunitstayid=pt.patientunitstayid
  ------------------VARS day2------------------------     
 LEFT OUTER JOIN
    t1_day2
  ON
    t1_day2.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t2_day2
  ON
    t2_day2.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t3_day2
  ON
    t3_day2.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t4_day2
  ON
    t4_day2.patientunitstayid=pt.patientunitstayid    
  ------------------VARS day3------------------------     
 LEFT OUTER JOIN
    t1_day3
  ON
    t1_day3.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t2_day3
  ON
    t2_day3.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t3_day3
  ON
    t3_day3.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t4_day3
  ON
    t4_day3.patientunitstayid=pt.patientunitstayid      
    ------------------VARS day4------------------------     
 LEFT OUTER JOIN
    t1_day4
  ON
    t1_day4.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t2_day4
  ON
    t2_day4.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t3_day4
  ON
    t3_day4.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t4_day4
  ON
    t4_day4.patientunitstayid=pt.patientunitstayid  
  
  
  ORDER BY
    pt.patientunitstayid
