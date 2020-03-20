 WITH
    tempo2_day1 AS (
    WITH
      tempo1_day1 AS (
      WITH
        t1_day1 AS (
        SELECT
          *
        FROM (
          SELECT
            DISTINCT patientunitstayid,
            MAX(CAST(respchartvalue AS INT64)) AS rcfio2
            -- , max(case when respchartvaluelabel = 'FiO2' then respchartvalue else null end) as fiO2
          FROM
            `physionet-data.eicu_crd.respiratorycharting`
          WHERE
            respchartoffset BETWEEN -120
            AND 1440
            AND respchartvalue <> ''
            AND REGEXP_CONTAINS(respchartvalue, '^[0-9]{0,2}$')
          GROUP BY
            patientunitstayid ) AS tempo
        WHERE
          rcfio2 >20 -- many values are liters per minute!
        ORDER BY
          patientunitstayid ),
        t2_day1 AS (
        SELECT
          DISTINCT patientunitstayid,
          MAX(CAST(nursingchartvalue AS INT64)) AS ncfio2
        FROM
          `physionet-data.eicu_crd.nursecharting` nc
        WHERE
          LOWER(nursingchartcelltypevallabel) LIKE '%fio2%'
          AND REGEXP_CONTAINS(nursingchartvalue, '^[0-9]{0,2}$')
          AND nursingchartentryoffset BETWEEN -1440 AND 1440
        GROUP BY
          patientunitstayid ),
        t3_day1 AS (
        SELECT
          patientunitstayid,
          MIN(
            CASE
              WHEN sao2 IS NOT NULL THEN sao2
              ELSE NULL END) AS sao2
        FROM
          `physionet-data.eicu_crd.vitalperiodic`
        WHERE
          observationoffset BETWEEN -1440
          AND 1440
        GROUP BY
          patientunitstayid ),
        t4_day1 AS (
        SELECT
          patientunitstayid,
          MIN(CASE
              WHEN LOWER(labname) LIKE 'pao2%' THEN labresult
              ELSE NULL END) AS pao2
        FROM
          `physionet-data.eicu_crd.lab`
        WHERE
          labresultoffset BETWEEN -1440
          AND 1440
        GROUP BY
          patientunitstayid ),
        t5_day1 AS (
        WITH
          t1_day1 AS (
          SELECT
            DISTINCT patientunitstayid,
            MAX(CASE
                WHEN airwaytype IN ('Oral ETT', 'Nasal ETT', 'Tracheostomy') THEN 1
                ELSE NULL END) AS airway  -- either invasive airway or NULL
          FROM
            `physionet-data.eicu_crd.respiratorycare`
          WHERE
            respcarestatusoffset BETWEEN -1440
            AND 1440
          GROUP BY
            patientunitstayid-- , respcarestatusoffset
            -- order by patientunitstayid-- , respcarestatusoffset
            ),
          t2_day1 AS (
          SELECT
            DISTINCT patientunitstayid,
            1 AS ventilator
          FROM
            `physionet-data.eicu_crd.respiratorycharting` rc
          WHERE
            respchartvalue LIKE '%ventilator%'
            OR respchartvalue LIKE '%vent%'
            OR respchartvalue LIKE '%bipap%'
            OR respchartvalue LIKE '%840%'
            OR respchartvalue LIKE '%cpap%'
            OR respchartvalue LIKE '%drager%'
            OR respchartvalue LIKE 'mv%'
            OR respchartvalue LIKE '%servo%'
            OR respchartvalue LIKE '%peep%'
            AND respchartoffset BETWEEN -1440
            AND 1440
          GROUP BY
            patientunitstayid
            -- order by patientunitstayid
            ),
          t3_day1 AS (
          SELECT
            DISTINCT patientunitstayid,
            MAX(CASE
                WHEN treatmentstring IN ('pulmonary|ventilation and oxygenation|mechanical ventilation',  'pulmonary|ventilation and oxygenation|tracheal suctioning',  'pulmonary|ventilation and oxygenation|ventilator weaning',  'pulmonary|ventilation and oxygenation|mechanical ventilation|assist controlled',  'pulmonary|radiologic procedures / bronchoscopy|endotracheal tube',  'pulmonary|ventilation and oxygenation|oxygen therapy (> 60%)',  'pulmonary|ventilation and oxygenation|mechanical ventilation|tidal volume 6-10 ml/kg',  'pulmonary|ventilation and oxygenation|mechanical ventilation|volume controlled',  'surgery|pulmonary therapies|mechanical ventilation',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy',  'pulmonary|ventilation and oxygenation|mechanical ventilation|synchronized intermittent',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy|performed during current admission for ventilatory support',  'pulmonary|ventilation and oxygenation|ventilator weaning|active',  'pulmonary|ventilation and oxygenation|mechanical ventilation|pressure controlled',  'pulmonary|ventilation and oxygenation|mechanical ventilation|pressure support',  'pulmonary|ventilation and oxygenation|ventilator weaning|slow',  'surgery|pulmonary therapies|ventilator weaning',  'surgery|pulmonary therapies|tracheal suctioning',  'pulmonary|radiologic procedures / bronchoscopy|reintubation',  'pulmonary|ventilation and oxygenation|lung recruitment maneuver',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy|planned',  'surgery|pulmonary therapies|ventilator weaning|rapid',  'pulmonary|ventilation and oxygenation|prone position',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy|conventional',  'pulmonary|ventilation and oxygenation|mechanical ventilation|permissive hypercapnea',  'surgery|pulmonary therapies|mechanical ventilation|synchronized intermittent',  'pulmonary|medications|neuromuscular blocking agent',  'surgery|pulmonary therapies|mechanical ventilation|assist controlled',  'pulmonary|ventilation and oxygenation|mechanical ventilation|volume assured',  'surgery|pulmonary therapies|mechanical ventilation|tidal volume 6-10 ml/kg',  'surgery|pulmonary therapies|mechanical ventilation|pressure support',  'pulmonary|ventilation and oxygenation|non-invasive ventilation',  'pulmonary|ventilation and oxygenation|non-invasive ventilation|face mask',  'pulmonary|ventilation and oxygenation|non-invasive ventilation|nasal mask',  'pulmonary|ventilation and oxygenation|mechanical ventilation|non-invasive ventilation',  'pulmonary|ventilation and oxygenation|mechanical ventilation|non-invasive ventilation|face mask',  'surgery|pulmonary therapies|non-invasive ventilation',  'surgery|pulmonary therapies|non-invasive ventilation|face mask',  'pulmonary|ventilation and oxygenation|mechanical ventilation|non-invasive ventilation|nasal mask',  'surgery|pulmonary therapies|non-invasive ventilation|nasal mask',  'surgery|pulmonary therapies|mechanical ventilation|non-invasive ventilation',  'surgery|pulmonary therapies|mechanical ventilation|non-invasive ventilation|face mask' ) THEN 1
                ELSE NULL END) AS interface   -- either ETT/NiV or NULL
          FROM
            `physionet-data.eicu_crd.treatment`
          WHERE
            treatmentoffset BETWEEN -1440
            AND 1440
          GROUP BY
            patientunitstayid-- , treatmentoffset, interface
          ORDER BY
            patientunitstayid-- , treatmentoffset
            )
        SELECT
          pt.patientunitstayid,
          CASE
            WHEN t1_day1.airway IS NOT NULL OR t2_day1.ventilator IS NOT NULL OR t3_day1.interface IS NOT NULL THEN 1
            ELSE NULL
          END AS mechvent
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
          t3_day1
        ON
          t3_day1.patientunitstayid=pt.patientunitstayid
        ORDER BY
          pt.patientunitstayid )
      SELECT
        pt.patientunitstayid,
        t3_day1.sao2,
        t4_day1.pao2,
        (CASE
            WHEN t1_day1.rcfio2>20 THEN t1_day1.rcfio2
            WHEN t2_day1.ncfio2 >20 THEN t2_day1.ncfio2
            WHEN t1_day1.rcfio2=1 OR t2_day1.ncfio2=1 THEN 100
            ELSE NULL END) AS fio2,
        t5_day1.mechvent
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
        t3_day1
      ON
        t3_day1.patientunitstayid=pt.patientunitstayid
      LEFT OUTER JOIN
        t4_day1
      ON
        t4_day1.patientunitstayid=pt.patientunitstayid
      LEFT OUTER JOIN
        t5_day1
      ON
        t5_day1.patientunitstayid=pt.patientunitstayid
        -- order by pt.patientunitstayid
        )
    SELECT
      *,
      -- coalesce(fio2,nullif(fio2,0),21) as fn, nullif(fio2,0) as nullifzero, coalesce(coalesce(nullif(fio2,0),21),fio2,21) as ifzero21 ,
      coalesce(pao2,
        100)/coalesce(coalesce(nullif(fio2,
            0),
          21),
        fio2,
        21) AS pf,
      coalesce(sao2,
        100)/coalesce(coalesce(nullif(fio2,
            0),
          21),
        fio2,
        21) AS sf
    FROM
      tempo1_day1
      -- order by fio2
      ),
      
-- -------------- day 2 -----------------------
    tempo2_day2 AS (
    WITH
      tempo1_day2 AS (
      WITH
        t1_day2 AS (
        SELECT
          *
        FROM (
          SELECT
            DISTINCT patientunitstayid,
            MAX(CAST(respchartvalue AS INT64)) AS rcfio2
            -- , max(case when respchartvaluelabel = 'FiO2' then respchartvalue else null end) as fiO2
          FROM
            `physionet-data.eicu_crd.respiratorycharting`
          WHERE
            respchartoffset BETWEEN 1440
            AND 1440*2
            AND respchartvalue <> ''
            AND REGEXP_CONTAINS(respchartvalue, '^[0-9]{0,2}$')
          GROUP BY
            patientunitstayid ) AS tempo
        WHERE
          rcfio2 >20 -- many values are liters per minute!
        ORDER BY
          patientunitstayid ),
        t2_day2 AS (
        SELECT
          DISTINCT patientunitstayid,
          MAX(CAST(nursingchartvalue AS INT64)) AS ncfio2
        FROM
          `physionet-data.eicu_crd.nursecharting` nc
        WHERE
          LOWER(nursingchartcelltypevallabel) LIKE '%fio2%'
          AND REGEXP_CONTAINS(nursingchartvalue, '^[0-9]{0,2}$')
          AND nursingchartentryoffset BETWEEN 1440 AND 1440*2
        GROUP BY
          patientunitstayid ),
        t3_day2 AS (
        SELECT
          patientunitstayid,
          MIN(
            CASE
              WHEN sao2 IS NOT NULL THEN sao2
              ELSE NULL END) AS sao2
        FROM
          `physionet-data.eicu_crd.vitalperiodic`
        WHERE
          observationoffset BETWEEN 1440 AND 1440*2
        GROUP BY
          patientunitstayid ),
        t4_day2 AS (
        SELECT
          patientunitstayid,
          MIN(CASE
              WHEN LOWER(labname) LIKE 'pao2%' THEN labresult
              ELSE NULL END) AS pao2
        FROM
          `physionet-data.eicu_crd.lab`
        WHERE
          labresultoffset BETWEEN 1440 AND 1440*2
        GROUP BY
          patientunitstayid ),
        t5_day2 AS (
        WITH
          t1_day2 AS (
          SELECT
            DISTINCT patientunitstayid,
            MAX(CASE
                WHEN airwaytype IN ('Oral ETT', 'Nasal ETT', 'Tracheostomy') THEN 1
                ELSE NULL END) AS airway  -- either invasive airway or NULL
          FROM
            `physionet-data.eicu_crd.respiratorycare`
          WHERE
            respcarestatusoffset BETWEEN 1440 AND 1440*2
          GROUP BY
            patientunitstayid-- , respcarestatusoffset
            -- order by patientunitstayid-- , respcarestatusoffset
            ),
          t2_day2 AS (
          SELECT
            DISTINCT patientunitstayid,
            1 AS ventilator
          FROM
            `physionet-data.eicu_crd.respiratorycharting` rc
          WHERE
            respchartvalue LIKE '%ventilator%'
            OR respchartvalue LIKE '%vent%'
            OR respchartvalue LIKE '%bipap%'
            OR respchartvalue LIKE '%840%'
            OR respchartvalue LIKE '%cpap%'
            OR respchartvalue LIKE '%drager%'
            OR respchartvalue LIKE 'mv%'
            OR respchartvalue LIKE '%servo%'
            OR respchartvalue LIKE '%peep%'
            AND respchartoffset BETWEEN 1440 AND 1440*2
          GROUP BY
            patientunitstayid
            -- order by patientunitstayid
            ),
          t3_day2 AS (
          SELECT
            DISTINCT patientunitstayid,
            MAX(CASE
                WHEN treatmentstring IN ('pulmonary|ventilation and oxygenation|mechanical ventilation',  'pulmonary|ventilation and oxygenation|tracheal suctioning',  'pulmonary|ventilation and oxygenation|ventilator weaning',  'pulmonary|ventilation and oxygenation|mechanical ventilation|assist controlled',  'pulmonary|radiologic procedures / bronchoscopy|endotracheal tube',  'pulmonary|ventilation and oxygenation|oxygen therapy (> 60%)',  'pulmonary|ventilation and oxygenation|mechanical ventilation|tidal volume 6-10 ml/kg',  'pulmonary|ventilation and oxygenation|mechanical ventilation|volume controlled',  'surgery|pulmonary therapies|mechanical ventilation',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy',  'pulmonary|ventilation and oxygenation|mechanical ventilation|synchronized intermittent',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy|performed during current admission for ventilatory support',  'pulmonary|ventilation and oxygenation|ventilator weaning|active',  'pulmonary|ventilation and oxygenation|mechanical ventilation|pressure controlled',  'pulmonary|ventilation and oxygenation|mechanical ventilation|pressure support',  'pulmonary|ventilation and oxygenation|ventilator weaning|slow',  'surgery|pulmonary therapies|ventilator weaning',  'surgery|pulmonary therapies|tracheal suctioning',  'pulmonary|radiologic procedures / bronchoscopy|reintubation',  'pulmonary|ventilation and oxygenation|lung recruitment maneuver',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy|planned',  'surgery|pulmonary therapies|ventilator weaning|rapid',  'pulmonary|ventilation and oxygenation|prone position',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy|conventional',  'pulmonary|ventilation and oxygenation|mechanical ventilation|permissive hypercapnea',  'surgery|pulmonary therapies|mechanical ventilation|synchronized intermittent',  'pulmonary|medications|neuromuscular blocking agent',  'surgery|pulmonary therapies|mechanical ventilation|assist controlled',  'pulmonary|ventilation and oxygenation|mechanical ventilation|volume assured',  'surgery|pulmonary therapies|mechanical ventilation|tidal volume 6-10 ml/kg',  'surgery|pulmonary therapies|mechanical ventilation|pressure support',  'pulmonary|ventilation and oxygenation|non-invasive ventilation',  'pulmonary|ventilation and oxygenation|non-invasive ventilation|face mask',  'pulmonary|ventilation and oxygenation|non-invasive ventilation|nasal mask',  'pulmonary|ventilation and oxygenation|mechanical ventilation|non-invasive ventilation',  'pulmonary|ventilation and oxygenation|mechanical ventilation|non-invasive ventilation|face mask',  'surgery|pulmonary therapies|non-invasive ventilation',  'surgery|pulmonary therapies|non-invasive ventilation|face mask',  'pulmonary|ventilation and oxygenation|mechanical ventilation|non-invasive ventilation|nasal mask',  'surgery|pulmonary therapies|non-invasive ventilation|nasal mask',  'surgery|pulmonary therapies|mechanical ventilation|non-invasive ventilation',  'surgery|pulmonary therapies|mechanical ventilation|non-invasive ventilation|face mask' ) THEN 1
                ELSE NULL END) AS interface   -- either ETT/NiV or NULL
          FROM
            `physionet-data.eicu_crd.treatment`
          WHERE
            treatmentoffset BETWEEN 1440 AND 1440*2
          GROUP BY
            patientunitstayid-- , treatmentoffset, interface
          ORDER BY
            patientunitstayid-- , treatmentoffset
            )
        SELECT
          pt.patientunitstayid,
          CASE
            WHEN t1_day2.airway IS NOT NULL OR t2_day2.ventilator IS NOT NULL OR t3_day2.interface IS NOT NULL THEN 1
            ELSE NULL
          END AS mechvent
        FROM
          `physionet-data.eicu_crd.patient` pt
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
        ORDER BY
          pt.patientunitstayid )
      SELECT
        pt.patientunitstayid,
        t3_day2.sao2,
        t4_day2.pao2,
        (CASE
            WHEN t1_day2.rcfio2>20 THEN t1_day2.rcfio2
            WHEN t2_day2.ncfio2 >20 THEN t2_day2.ncfio2
            WHEN t1_day2.rcfio2=1 OR t2_day2.ncfio2=1 THEN 100
            ELSE NULL END) AS fio2,
        t5_day2.mechvent
      FROM
        `physionet-data.eicu_crd.patient` pt
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
      LEFT OUTER JOIN
        t5_day2
      ON
        t5_day2.patientunitstayid=pt.patientunitstayid
        -- order by pt.patientunitstayid
        )
    SELECT
      *,
      -- coalesce(fio2,nullif(fio2,0),21) as fn, nullif(fio2,0) as nullifzero, coalesce(coalesce(nullif(fio2,0),21),fio2,21) as ifzero21 ,
      coalesce(pao2,
        100)/coalesce(coalesce(nullif(fio2,
            0),
          21),
        fio2,
        21) AS pf,
      coalesce(sao2,
        100)/coalesce(coalesce(nullif(fio2,
            0),
          21),
        fio2,
        21) AS sf
    FROM
      tempo1_day2
      -- order by fio2
      ),
      
-- -------------- day 3 -----------------------      
    tempo2_day3 AS (
    WITH
      tempo1_day3 AS (
      WITH
        t1_day3 AS (
        SELECT
          *
        FROM (
          SELECT
            DISTINCT patientunitstayid,
            MAX(CAST(respchartvalue AS INT64)) AS rcfio2
            -- , max(case when respchartvaluelabel = 'FiO2' then respchartvalue else null end) as fiO2
          FROM
            `physionet-data.eicu_crd.respiratorycharting`
          WHERE
            respchartoffset BETWEEN 1440*2
            AND 1440*3
            AND respchartvalue <> ''
            AND REGEXP_CONTAINS(respchartvalue, '^[0-9]{0,2}$')
          GROUP BY
            patientunitstayid ) AS tempo
        WHERE
          rcfio2 >20 -- many values are liters per minute!
        ORDER BY
          patientunitstayid ),
        t2_day3 AS (
        SELECT
          DISTINCT patientunitstayid,
          MAX(CAST(nursingchartvalue AS INT64)) AS ncfio2
        FROM
          `physionet-data.eicu_crd.nursecharting` nc
        WHERE
          LOWER(nursingchartcelltypevallabel) LIKE '%fio2%'
          AND REGEXP_CONTAINS(nursingchartvalue, '^[0-9]{0,2}$')
          AND nursingchartentryoffset BETWEEN 1440*2 AND 1440*3
        GROUP BY
          patientunitstayid ),
        t3_day3 AS (
        SELECT
          patientunitstayid,
          MIN(
            CASE
              WHEN sao2 IS NOT NULL THEN sao2
              ELSE NULL END) AS sao2
        FROM
          `physionet-data.eicu_crd.vitalperiodic`
        WHERE
          observationoffset BETWEEN 1440*2
          AND 1440*3
        GROUP BY
          patientunitstayid ),
        t4_day3 AS (
        SELECT
          patientunitstayid,
          MIN(CASE
              WHEN LOWER(labname) LIKE 'pao2%' THEN labresult
              ELSE NULL END) AS pao2
        FROM
          `physionet-data.eicu_crd.lab`
        WHERE
          labresultoffset BETWEEN 1440*2
          AND 1440*3
        GROUP BY
          patientunitstayid ),
        t5_day3 AS (
        WITH
          t1_day3 AS (
          SELECT
            DISTINCT patientunitstayid,
            MAX(CASE
                WHEN airwaytype IN ('Oral ETT', 'Nasal ETT', 'Tracheostomy') THEN 1
                ELSE NULL END) AS airway  -- either invasive airway or NULL
          FROM
            `physionet-data.eicu_crd.respiratorycare`
          WHERE
            respcarestatusoffset BETWEEN 1440*2
            AND 1440*3
          GROUP BY
            patientunitstayid-- , respcarestatusoffset
            -- order by patientunitstayid-- , respcarestatusoffset
            ),
          t2_day3 AS (
          SELECT
            DISTINCT patientunitstayid,
            1 AS ventilator
          FROM
            `physionet-data.eicu_crd.respiratorycharting` rc
          WHERE
            respchartvalue LIKE '%ventilator%'
            OR respchartvalue LIKE '%vent%'
            OR respchartvalue LIKE '%bipap%'
            OR respchartvalue LIKE '%840%'
            OR respchartvalue LIKE '%cpap%'
            OR respchartvalue LIKE '%drager%'
            OR respchartvalue LIKE 'mv%'
            OR respchartvalue LIKE '%servo%'
            OR respchartvalue LIKE '%peep%'
            AND respchartoffset BETWEEN 1440*2
            AND 1440*3
          GROUP BY
            patientunitstayid
            -- order by patientunitstayid
            ),
          t3_day3 AS (
          SELECT
            DISTINCT patientunitstayid,
            MAX(CASE
                WHEN treatmentstring IN ('pulmonary|ventilation and oxygenation|mechanical ventilation',  'pulmonary|ventilation and oxygenation|tracheal suctioning',  'pulmonary|ventilation and oxygenation|ventilator weaning',  'pulmonary|ventilation and oxygenation|mechanical ventilation|assist controlled',  'pulmonary|radiologic procedures / bronchoscopy|endotracheal tube',  'pulmonary|ventilation and oxygenation|oxygen therapy (> 60%)',  'pulmonary|ventilation and oxygenation|mechanical ventilation|tidal volume 6-10 ml/kg',  'pulmonary|ventilation and oxygenation|mechanical ventilation|volume controlled',  'surgery|pulmonary therapies|mechanical ventilation',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy',  'pulmonary|ventilation and oxygenation|mechanical ventilation|synchronized intermittent',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy|performed during current admission for ventilatory support',  'pulmonary|ventilation and oxygenation|ventilator weaning|active',  'pulmonary|ventilation and oxygenation|mechanical ventilation|pressure controlled',  'pulmonary|ventilation and oxygenation|mechanical ventilation|pressure support',  'pulmonary|ventilation and oxygenation|ventilator weaning|slow',  'surgery|pulmonary therapies|ventilator weaning',  'surgery|pulmonary therapies|tracheal suctioning',  'pulmonary|radiologic procedures / bronchoscopy|reintubation',  'pulmonary|ventilation and oxygenation|lung recruitment maneuver',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy|planned',  'surgery|pulmonary therapies|ventilator weaning|rapid',  'pulmonary|ventilation and oxygenation|prone position',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy|conventional',  'pulmonary|ventilation and oxygenation|mechanical ventilation|permissive hypercapnea',  'surgery|pulmonary therapies|mechanical ventilation|synchronized intermittent',  'pulmonary|medications|neuromuscular blocking agent',  'surgery|pulmonary therapies|mechanical ventilation|assist controlled',  'pulmonary|ventilation and oxygenation|mechanical ventilation|volume assured',  'surgery|pulmonary therapies|mechanical ventilation|tidal volume 6-10 ml/kg',  'surgery|pulmonary therapies|mechanical ventilation|pressure support',  'pulmonary|ventilation and oxygenation|non-invasive ventilation',  'pulmonary|ventilation and oxygenation|non-invasive ventilation|face mask',  'pulmonary|ventilation and oxygenation|non-invasive ventilation|nasal mask',  'pulmonary|ventilation and oxygenation|mechanical ventilation|non-invasive ventilation',  'pulmonary|ventilation and oxygenation|mechanical ventilation|non-invasive ventilation|face mask',  'surgery|pulmonary therapies|non-invasive ventilation',  'surgery|pulmonary therapies|non-invasive ventilation|face mask',  'pulmonary|ventilation and oxygenation|mechanical ventilation|non-invasive ventilation|nasal mask',  'surgery|pulmonary therapies|non-invasive ventilation|nasal mask',  'surgery|pulmonary therapies|mechanical ventilation|non-invasive ventilation',  'surgery|pulmonary therapies|mechanical ventilation|non-invasive ventilation|face mask' ) THEN 1
                ELSE NULL END) AS interface   -- either ETT/NiV or NULL
          FROM
            `physionet-data.eicu_crd.treatment`
          WHERE
            treatmentoffset BETWEEN 1440*2
            AND 1440*3
          GROUP BY
            patientunitstayid-- , treatmentoffset, interface
          ORDER BY
            patientunitstayid-- , treatmentoffset
            )
        SELECT
          pt.patientunitstayid,
          CASE
            WHEN t1_day3.airway IS NOT NULL OR t2_day3.ventilator IS NOT NULL OR t3_day3.interface IS NOT NULL THEN 1
            ELSE NULL
          END AS mechvent
        FROM
          `physionet-data.eicu_crd.patient` pt
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
        ORDER BY
          pt.patientunitstayid )
      SELECT
        pt.patientunitstayid,
        t3_day3.sao2,
        t4_day3.pao2,
        (CASE
            WHEN t1_day3.rcfio2>20 THEN t1_day3.rcfio2
            WHEN t2_day3.ncfio2 >20 THEN t2_day3.ncfio2
            WHEN t1_day3.rcfio2=1 OR t2_day3.ncfio2=1 THEN 100
            ELSE NULL END) AS fio2,
        t5_day3.mechvent
      FROM
        `physionet-data.eicu_crd.patient` pt
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
      LEFT OUTER JOIN
        t5_day3
      ON
        t5_day3.patientunitstayid=pt.patientunitstayid
        -- order by pt.patientunitstayid
        )
    SELECT
      *,
      -- coalesce(fio2,nullif(fio2,0),21) as fn, nullif(fio2,0) as nullifzero, coalesce(coalesce(nullif(fio2,0),21),fio2,21) as ifzero21 ,
      coalesce(pao2,
        100)/coalesce(coalesce(nullif(fio2,
            0),
          21),
        fio2,
        21) AS pf,
      coalesce(sao2,
        100)/coalesce(coalesce(nullif(fio2,
            0),
          21),
        fio2,
        21) AS sf
    FROM
      tempo1_day3
      -- order by fio2
      ),

-- -------------- day 4 ----------------------- 
    tempo2_day4 AS (
    WITH
      tempo1_day4 AS (
      WITH
        t1_day4 AS (
        SELECT
          *
        FROM (
          SELECT
            DISTINCT patientunitstayid,
            MAX(CAST(respchartvalue AS INT64)) AS rcfio2
            -- , max(case when respchartvaluelabel = 'FiO2' then respchartvalue else null end) as fiO2
          FROM
            `physionet-data.eicu_crd.respiratorycharting`
          WHERE
            respchartoffset BETWEEN 1440*3
            AND 1440*4
            AND respchartvalue <> ''
            AND REGEXP_CONTAINS(respchartvalue, '^[0-9]{0,2}$')
          GROUP BY
            patientunitstayid ) AS tempo
        WHERE
          rcfio2 >20 -- many values are liters per minute!
        ORDER BY
          patientunitstayid ),
        t2_day4 AS (
        SELECT
          DISTINCT patientunitstayid,
          MAX(CAST(nursingchartvalue AS INT64)) AS ncfio2
        FROM
          `physionet-data.eicu_crd.nursecharting` nc
        WHERE
          LOWER(nursingchartcelltypevallabel) LIKE '%fio2%'
          AND REGEXP_CONTAINS(nursingchartvalue, '^[0-9]{0,2}$')
          AND nursingchartentryoffset BETWEEN 1440*3
          AND 1440*4
        GROUP BY
          patientunitstayid ),
        t3_day4 AS (
        SELECT
          patientunitstayid,
          MIN(
            CASE
              WHEN sao2 IS NOT NULL THEN sao2
              ELSE NULL END) AS sao2
        FROM
          `physionet-data.eicu_crd.vitalperiodic`
        WHERE
          observationoffset BETWEEN 1440*3
            AND 1440*4
        GROUP BY
          patientunitstayid ),
        t4_day4 AS (
        SELECT
          patientunitstayid,
          MIN(CASE
              WHEN LOWER(labname) LIKE 'pao2%' THEN labresult
              ELSE NULL END) AS pao2
        FROM
          `physionet-data.eicu_crd.lab`
        WHERE
          labresultoffset BETWEEN 1440*3
            AND 1440*4
        GROUP BY
          patientunitstayid ),
        t5_day4 AS (
        WITH
          t1_day4 AS (
          SELECT
            DISTINCT patientunitstayid,
            MAX(CASE
                WHEN airwaytype IN ('Oral ETT', 'Nasal ETT', 'Tracheostomy') THEN 1
                ELSE NULL END) AS airway  -- either invasive airway or NULL
          FROM
            `physionet-data.eicu_crd.respiratorycare`
          WHERE
            respcarestatusoffset BETWEEN -1440*3
            AND 1440*4
          GROUP BY
            patientunitstayid-- , respcarestatusoffset
            -- order by patientunitstayid-- , respcarestatusoffset
            ),
          t2_day4 AS (
          SELECT
            DISTINCT patientunitstayid,
            1 AS ventilator
          FROM
            `physionet-data.eicu_crd.respiratorycharting` rc
          WHERE
            respchartvalue LIKE '%ventilator%'
            OR respchartvalue LIKE '%vent%'
            OR respchartvalue LIKE '%bipap%'
            OR respchartvalue LIKE '%840%'
            OR respchartvalue LIKE '%cpap%'
            OR respchartvalue LIKE '%drager%'
            OR respchartvalue LIKE 'mv%'
            OR respchartvalue LIKE '%servo%'
            OR respchartvalue LIKE '%peep%'
            AND respchartoffset BETWEEN 1440*3
            AND 1440*4
          GROUP BY
            patientunitstayid
            -- order by patientunitstayid
            ),
          t3_day4 AS (
          SELECT
            DISTINCT patientunitstayid,
            MAX(CASE
                WHEN treatmentstring IN ('pulmonary|ventilation and oxygenation|mechanical ventilation',  'pulmonary|ventilation and oxygenation|tracheal suctioning',  'pulmonary|ventilation and oxygenation|ventilator weaning',  'pulmonary|ventilation and oxygenation|mechanical ventilation|assist controlled',  'pulmonary|radiologic procedures / bronchoscopy|endotracheal tube',  'pulmonary|ventilation and oxygenation|oxygen therapy (> 60%)',  'pulmonary|ventilation and oxygenation|mechanical ventilation|tidal volume 6-10 ml/kg',  'pulmonary|ventilation and oxygenation|mechanical ventilation|volume controlled',  'surgery|pulmonary therapies|mechanical ventilation',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy',  'pulmonary|ventilation and oxygenation|mechanical ventilation|synchronized intermittent',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy|performed during current admission for ventilatory support',  'pulmonary|ventilation and oxygenation|ventilator weaning|active',  'pulmonary|ventilation and oxygenation|mechanical ventilation|pressure controlled',  'pulmonary|ventilation and oxygenation|mechanical ventilation|pressure support',  'pulmonary|ventilation and oxygenation|ventilator weaning|slow',  'surgery|pulmonary therapies|ventilator weaning',  'surgery|pulmonary therapies|tracheal suctioning',  'pulmonary|radiologic procedures / bronchoscopy|reintubation',  'pulmonary|ventilation and oxygenation|lung recruitment maneuver',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy|planned',  'surgery|pulmonary therapies|ventilator weaning|rapid',  'pulmonary|ventilation and oxygenation|prone position',  'pulmonary|surgery / incision and drainage of thorax|tracheostomy|conventional',  'pulmonary|ventilation and oxygenation|mechanical ventilation|permissive hypercapnea',  'surgery|pulmonary therapies|mechanical ventilation|synchronized intermittent',  'pulmonary|medications|neuromuscular blocking agent',  'surgery|pulmonary therapies|mechanical ventilation|assist controlled',  'pulmonary|ventilation and oxygenation|mechanical ventilation|volume assured',  'surgery|pulmonary therapies|mechanical ventilation|tidal volume 6-10 ml/kg',  'surgery|pulmonary therapies|mechanical ventilation|pressure support',  'pulmonary|ventilation and oxygenation|non-invasive ventilation',  'pulmonary|ventilation and oxygenation|non-invasive ventilation|face mask',  'pulmonary|ventilation and oxygenation|non-invasive ventilation|nasal mask',  'pulmonary|ventilation and oxygenation|mechanical ventilation|non-invasive ventilation',  'pulmonary|ventilation and oxygenation|mechanical ventilation|non-invasive ventilation|face mask',  'surgery|pulmonary therapies|non-invasive ventilation',  'surgery|pulmonary therapies|non-invasive ventilation|face mask',  'pulmonary|ventilation and oxygenation|mechanical ventilation|non-invasive ventilation|nasal mask',  'surgery|pulmonary therapies|non-invasive ventilation|nasal mask',  'surgery|pulmonary therapies|mechanical ventilation|non-invasive ventilation',  'surgery|pulmonary therapies|mechanical ventilation|non-invasive ventilation|face mask' ) THEN 1
                ELSE NULL END) AS interface   -- either ETT/NiV or NULL
          FROM
            `physionet-data.eicu_crd.treatment`
          WHERE
            treatmentoffset BETWEEN 1440*3
            AND 1440*4
          GROUP BY
            patientunitstayid-- , treatmentoffset, interface
          ORDER BY
            patientunitstayid-- , treatmentoffset
            )
        SELECT
          pt.patientunitstayid,
          CASE
            WHEN t1_day4.airway IS NOT NULL OR t2_day4.ventilator IS NOT NULL OR t3_day4.interface IS NOT NULL THEN 1
            ELSE NULL
          END AS mechvent
        FROM
          `physionet-data.eicu_crd.patient` pt
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
        ORDER BY
          pt.patientunitstayid )
      SELECT
        pt.patientunitstayid,
        t3_day4.sao2,
        t4_day4.pao2,
        (CASE
            WHEN t1_day4.rcfio2>20 THEN t1_day4.rcfio2
            WHEN t2_day4.ncfio2 >20 THEN t2_day4.ncfio2
            WHEN t1_day4.rcfio2=1 OR t2_day4.ncfio2=1 THEN 100
            ELSE NULL END) AS fio2,
        t5_day4.mechvent
      FROM
        `physionet-data.eicu_crd.patient` pt
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
      LEFT OUTER JOIN
        t5_day4
      ON
        t5_day4.patientunitstayid=pt.patientunitstayid
        -- order by pt.patientunitstayid
        )
    SELECT
      *,
      -- coalesce(fio2,nullif(fio2,0),21) as fn, nullif(fio2,0) as nullifzero, coalesce(coalesce(nullif(fio2,0),21),fio2,21) as ifzero21 ,
      coalesce(pao2,
        100)/coalesce(coalesce(nullif(fio2,
            0),
          21),
        fio2,
        21) AS pf,
      coalesce(sao2,
        100)/coalesce(coalesce(nullif(fio2,
            0),
          21),
        fio2,
        21) AS sf
    FROM
      tempo1_day4
      -- order by fio2
      )
SELECT
    pt.patientunitstayid,
    (CASE
        WHEN tempo2_day1.pf <1 OR tempo2_day1.sf <0.67 THEN 4
        WHEN tempo2_day1.pf BETWEEN 1
      AND 2
      OR tempo2_day1.sf BETWEEN 0.67
      AND 1.41 THEN 3
        WHEN tempo2_day1.pf BETWEEN 2 AND 3 OR tempo2_day1.sf BETWEEN 1.42 AND 2.2 THEN 2
        WHEN tempo2_day1.pf BETWEEN 3
      AND 4
      OR tempo2_day1.sf BETWEEN 2.21
      AND 3.01 THEN 1
        WHEN tempo2_day1.pf > 4 OR tempo2_day1.sf> 3.01 THEN 0
        ELSE 0
      END ) AS SOFA_respi_day1,
      
      
      (CASE
        WHEN tempo2_day2.pf <1 OR tempo2_day2.sf <0.67 THEN 4
        WHEN tempo2_day2.pf BETWEEN 1
      AND 2
      OR tempo2_day2.sf BETWEEN 0.67
      AND 1.41 THEN 3
        WHEN tempo2_day2.pf BETWEEN 2 AND 3 OR tempo2_day2.sf BETWEEN 1.42 AND 2.2 THEN 2
        WHEN tempo2_day2.pf BETWEEN 3
      AND 4
      OR tempo2_day2.sf BETWEEN 2.21
      AND 3.01 THEN 1
        WHEN tempo2_day2.pf > 4 OR tempo2_day2.sf> 3.01 THEN 0
        ELSE 0
      END ) AS SOFA_respi_day2,
      
      
      (CASE
        WHEN tempo2_day3.pf <1 OR tempo2_day3.sf <0.67 THEN 4
        WHEN tempo2_day3.pf BETWEEN 1
      AND 2
      OR tempo2_day3.sf BETWEEN 0.67
      AND 1.41 THEN 3
        WHEN tempo2_day3.pf BETWEEN 2 AND 3 OR tempo2_day3.sf BETWEEN 1.42 AND 2.2 THEN 2
        WHEN tempo2_day3.pf BETWEEN 3
      AND 4
      OR tempo2_day3.sf BETWEEN 2.21
      AND 3.01 THEN 1
        WHEN tempo2_day3.pf > 4 OR tempo2_day3.sf> 3.01 THEN 0
        ELSE 0
      END ) AS SOFA_respi_day3,
  
      (CASE
        WHEN tempo2_day4.pf <1 OR tempo2_day4.sf <0.67 THEN 4
        WHEN tempo2_day4.pf BETWEEN 1
      AND 2
      OR tempo2_day4.sf BETWEEN 0.67
      AND 1.41 THEN 3
        WHEN tempo2_day4.pf BETWEEN 2 AND 3 OR tempo2_day4.sf BETWEEN 1.42 AND 2.2 THEN 2
        WHEN tempo2_day4.pf BETWEEN 3
      AND 4
      OR tempo2_day4.sf BETWEEN 2.21
      AND 3.01 THEN 1
        WHEN tempo2_day4.pf > 4 OR tempo2_day4.sf> 3.01 THEN 0
        ELSE 0
      END ) AS SOFA_respi_day4
  FROM
    `physionet-data.eicu_crd.patient` pt
    LEFT OUTER JOIN
    tempo2_day1 
    ON 
    tempo2_day1.patientunitstayid=pt.patientunitstayid
    LEFT OUTER JOIN
    tempo2_day2 
    ON 
    tempo2_day2.patientunitstayid=pt.patientunitstayid
    LEFT OUTER JOIN
    tempo2_day3 
    ON 
    tempo2_day3.patientunitstayid=pt.patientunitstayid
    LEFT OUTER JOIN
    tempo2_day4 
    ON 
    tempo2_day4.patientunitstayid=pt.patientunitstayid
  ORDER BY
    pt.patientunitstayid
