WITH
    t1f_day1 AS (
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
    t1_day1 AS (
    SELECT
      patientunitstayid,
      MIN(coalesce(gcs_eyes,
          4) + coalesce(gcs_verbal,
          5) + coalesce(gcs_motor,
          6)) AS gcs
    FROM
      t1f_day1
    GROUP BY
      patientunitstayid ),
    t2_day1 AS (
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
      pt.patientunitstayid ),

t1f_day2 AS (
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
      AND physicalexamoffset BETWEEN 1440
      AND 1440*2
    GROUP BY
      patientunitstayid,
      physicalexamoffset ),
    t1_day2 AS (
    SELECT
      patientunitstayid,
      MIN(coalesce(gcs_eyes,
          4) + coalesce(gcs_verbal,
          5) + coalesce(gcs_motor,
          6)) AS gcs
    FROM
      t1f_day2
    GROUP BY
      patientunitstayid ),
    t2_day2 AS (
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
      labresultoffset BETWEEN 1440
      AND 1440*2
    GROUP BY
      pt.patientunitstayid ),

t1f_day3 AS (
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
      AND physicalexamoffset BETWEEN 1440*2
      AND 1440*3
    GROUP BY
      patientunitstayid,
      physicalexamoffset ),
    t1_day3 AS (
    SELECT
      patientunitstayid,
      MIN(coalesce(gcs_eyes,
          4) + coalesce(gcs_verbal,
          5) + coalesce(gcs_motor,
          6)) AS gcs
    FROM
      t1f_day3
    GROUP BY
      patientunitstayid ),
    t2_day3 AS (
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
      labresultoffset BETWEEN 1440*2
      AND 1440*3
    GROUP BY
      pt.patientunitstayid ),
      

t1f_day4 AS (
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
      AND physicalexamoffset BETWEEN 1440*3
      AND 1440*4
    GROUP BY
      patientunitstayid,
      physicalexamoffset ),
    t1_day4 AS (
    SELECT
      patientunitstayid,
      MIN(coalesce(gcs_eyes,
          4) + coalesce(gcs_verbal,
          5) + coalesce(gcs_motor,
          6)) AS gcs
    FROM
      t1f_day4
    GROUP BY
      patientunitstayid ),
    t2_day4 AS (
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
      labresultoffset BETWEEN 1440*3
      AND 1440*4
    GROUP BY
      pt.patientunitstayid )
      
      
  SELECT
    DISTINCT pt.patientunitstayid,
    
    
    MIN(t1_day1.gcs) AS gcs_day1,
    MAX(t2_day1.bili) AS bili_day1,
    MIN(t2_day1.plt) AS plt_day1,
    MAX(CASE
        WHEN t2_day1.plt<20 THEN 4
        WHEN t2_day1.plt<50 THEN 3
        WHEN t2_day1.plt<100 THEN 2
        WHEN t2_day1.plt<150 THEN 1
        ELSE 0 END) AS sofacoag_day1,
    MAX(CASE
        WHEN t2_day1.bili>12 THEN 4
        WHEN t2_day1.bili>6 THEN 3
        WHEN t2_day1.bili>2 THEN 2
        WHEN t2_day1.bili>1.2 THEN 1
        ELSE 0 END) AS sofaliver_day1,
    MAX(CASE
        WHEN t1_day1.gcs=15 THEN 0
        WHEN t1_day1.gcs>=13 THEN 1
        WHEN t1_day1.gcs>=10 THEN 2
        WHEN t1_day1.gcs>=6 THEN 3
        WHEN t1_day1.gcs>=3 THEN 4
        ELSE 0 END) AS sofacns_day1,
        
    
    MIN(t1_day2.gcs) AS gcs_day2,
    MAX(t2_day2.bili) AS bili_day2,
    MIN(t2_day2.plt) AS plt_day2,
    MAX(CASE
        WHEN t2_day2.plt<20 THEN 4
        WHEN t2_day2.plt<50 THEN 3
        WHEN t2_day2.plt<100 THEN 2
        WHEN t2_day2.plt<150 THEN 1
        ELSE 0 END) AS sofacoag_day2,
    MAX(CASE
        WHEN t2_day2.bili>12 THEN 4
        WHEN t2_day2.bili>6 THEN 3
        WHEN t2_day2.bili>2 THEN 2
        WHEN t2_day2.bili>1.2 THEN 1
        ELSE 0 END) AS sofaliver_day2,
    MAX(CASE
        WHEN t1_day2.gcs=15 THEN 0
        WHEN t1_day2.gcs>=13 THEN 1
        WHEN t1_day2.gcs>=10 THEN 2
        WHEN t1_day2.gcs>=6 THEN 3
        WHEN t1_day2.gcs>=3 THEN 4
        ELSE 0 END) AS sofacns_day2,
        
    MIN(t1_day3.gcs) AS gcs_day3,
    MAX(t2_day3.bili) AS bili_day3,
    MIN(t2_day3.plt) AS plt_day3,
    MAX(CASE
        WHEN t2_day3.plt<20 THEN 4
        WHEN t2_day3.plt<50 THEN 3
        WHEN t2_day3.plt<100 THEN 2
        WHEN t2_day3.plt<150 THEN 1
        ELSE 0 END) AS sofacoag_day3,
    MAX(CASE
        WHEN t2_day3.bili>12 THEN 4
        WHEN t2_day3.bili>6 THEN 3
        WHEN t2_day3.bili>2 THEN 2
        WHEN t2_day3.bili>1.2 THEN 1
        ELSE 0 END) AS sofaliver_day3,
    MAX(CASE
        WHEN t1_day3.gcs=15 THEN 0
        WHEN t1_day3.gcs>=13 THEN 1
        WHEN t1_day3.gcs>=10 THEN 2
        WHEN t1_day3.gcs>=6 THEN 3
        WHEN t1_day3.gcs>=3 THEN 4
        ELSE 0 END) AS sofacns_day3,
        
    
    MIN(t1_day4.gcs) AS gcs_day4,
    MAX(t2_day4.bili) AS bili_day4,
    MIN(t2_day4.plt) AS plt_day4,
    MAX(CASE
        WHEN t2_day4.plt<20 THEN 4
        WHEN t2_day4.plt<50 THEN 3
        WHEN t2_day4.plt<100 THEN 2
        WHEN t2_day4.plt<150 THEN 1
        ELSE 0 END) AS sofacoag_day4,
    MAX(CASE
        WHEN t2_day4.bili>12 THEN 4
        WHEN t2_day4.bili>6 THEN 3
        WHEN t2_day4.bili>2 THEN 2
        WHEN t2_day4.bili>1.2 THEN 1
        ELSE 0 END) AS sofaliver_day4,
    MAX(CASE
        WHEN t1_day4.gcs=15 THEN 0
        WHEN t1_day4.gcs>=13 THEN 1
        WHEN t1_day4.gcs>=10 THEN 2
        WHEN t1_day4.gcs>=6 THEN 3
        WHEN t1_day4.gcs>=3 THEN 4
        ELSE 0 END) AS sofacns_day4
        
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
    
  GROUP BY
    pt.patientunitstayid,
    t1_day1.gcs,
    t2_day1.bili,
    t2_day1.plt,
    
    t1_day2.gcs,
    t2_day2.bili,
    t2_day2.plt,
    
    t1_day3.gcs,
    t2_day3.bili,
    t2_day3.plt,
    
    t1_day4.gcs,
    t2_day4.bili,
    t2_day4.plt
  ORDER BY
    pt.patientunitstayid
