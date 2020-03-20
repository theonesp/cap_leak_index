WITH
    t1_day1 AS (
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
    t2_day1 AS (
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
              WHEN (intakeoutputoffset) BETWEEN -1440 AND 1440 THEN 1
              ELSE NULL END) AS dayz
        FROM
          `physionet-data.eicu_crd.intakeoutput`
          -- what does this account for?
        WHERE
          intakeoutputoffset BETWEEN -1440
          AND 1440
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
      pt.patientunitstayid ),
      
-- ------------ day2 --------------
    t1_day2 AS (
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
        labresultoffset BETWEEN 1440
        AND 1440*2
      GROUP BY
        pt.patientunitstayid ),
    t2_day2 AS (
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
                WHEN (intakeoutputoffset) BETWEEN 1440 AND 1440*2 THEN 1
                ELSE NULL END) AS dayz
          FROM
            `physionet-data.eicu_crd.intakeoutput`
          WHERE
            intakeoutputoffset BETWEEN 1440
            AND 1440*2
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
        pt.patientunitstayid ),

-- ----------- day3 -------------        
 
     t1_day3 AS (
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
        labresultoffset BETWEEN 1440*2
        AND 1440*3
      GROUP BY
        pt.patientunitstayid ),
    t2_day3 AS (
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
                WHEN (intakeoutputoffset) BETWEEN 1440*2 AND 1440*3 THEN 1
                ELSE NULL END) AS dayz
          FROM
            `physionet-data.eicu_crd.intakeoutput`
          WHERE
            intakeoutputoffset BETWEEN 1440*2
            AND 1440*3
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
        pt.patientunitstayid ),


-- ----------- day3 -------------        
 
     t1_day4 AS (
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
        labresultoffset BETWEEN 1440*3
        AND 1440*4
      GROUP BY
        pt.patientunitstayid ),
    t2_day4 AS (
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
                WHEN (intakeoutputoffset) BETWEEN 1440*3 AND 1440*4 THEN 1
                ELSE NULL END) AS dayz
          FROM
            `physionet-data.eicu_crd.intakeoutput`
          WHERE
            intakeoutputoffset BETWEEN 1440*3
            AND 1440*4
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
        WHEN t2_day1.uo <200 OR t1_day1.creat>5 THEN 4
        WHEN t2_day1.uo <500
      OR t1_day1.creat >3.5 THEN 3
        WHEN t1_day1.creat BETWEEN 2 AND 3.5 THEN 2
        WHEN t1_day1.creat BETWEEN 1.2
      AND 2 THEN 1
        ELSE 0 END) AS sofarenal_day1,
        
    (CASE
        WHEN t2_day2.uo <200 OR t1_day2.creat>5 THEN 4
        WHEN t2_day2.uo <500
      OR t1_day2.creat >3.5 THEN 3
        WHEN t1_day2.creat BETWEEN 2 AND 3.5 THEN 2
        WHEN t1_day2.creat BETWEEN 1.2
      AND 2 THEN 1
        ELSE 0 END) AS sofarenal_day2,
    (CASE
        WHEN t2_day3.uo <200 OR t1_day3.creat>5 THEN 4
        WHEN t2_day3.uo <500
      OR t1_day3.creat >3.5 THEN 3
        WHEN t1_day3.creat BETWEEN 2 AND 3.5 THEN 2
        WHEN t1_day3.creat BETWEEN 1.2
      AND 2 THEN 1
        ELSE 0 END) AS sofarenal_day3,
    (CASE
        WHEN t2_day4.uo <200 OR t1_day4.creat>5 THEN 4
        WHEN t2_day4.uo <500
      OR t1_day4.creat >3.5 THEN 3
        WHEN t1_day4.creat BETWEEN 2 AND 3.5 THEN 2
        WHEN t1_day4.creat BETWEEN 1.2
      AND 2 THEN 1
        ELSE 0 END) AS sofarenal_day4
  FROM
    `physionet-data.eicu_crd.patient` pt
  LEFT OUTER JOIN
    t1_day1
  ON
    t1_day1.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t2_day1
  ON
    t2_day1.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t1_day2
  ON
    t1_day2.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t2_day2
  ON
    t2_day2.patientunitstayid=pt.patientunitstayid
    LEFT OUTER JOIN
    t1_day3
  ON
    t1_day3.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t2_day3
  ON
    t2_day3.patientunitstayid=pt.patientunitstayid
    LEFT OUTER JOIN
    t1_day4
  ON
    t1_day4.patientunitstayid=pt.patientunitstayid
  LEFT OUTER JOIN
    t2_day4
  ON
    t2_day4.patientunitstayid=pt.patientunitstayid
  ORDER BY
    pt.patientunitstayid