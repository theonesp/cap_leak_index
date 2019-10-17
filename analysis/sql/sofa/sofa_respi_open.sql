 WITH
    tempo2 AS (
    WITH
      tempo1 AS (
      WITH
        t1 AS (
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
        t2 AS (
        SELECT
          DISTINCT patientunitstayid,
          MAX(CAST(nursingchartvalue AS INT64)) AS ncfio2
        FROM
          `physionet-data.eicu_crd.nursecharting` nc
        WHERE
          LOWER(nursingchartcelltypevallabel) LIKE '%fio2%'
          AND REGEXP_CONTAINS(nursingchartvalue, '^[0-9]{0,2}$')
          AND nursingchartentryoffset BETWEEN -120 AND 1440
        GROUP BY
          patientunitstayid ),
        t3 AS (
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
        t4 AS (
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
        t5 AS (
        WITH
          t1 AS (
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
          t2 AS (
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
          t3 AS (
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
            WHEN t1.airway IS NOT NULL OR t2.ventilator IS NOT NULL OR t3.interface IS NOT NULL THEN 1
            ELSE NULL
          END AS mechvent
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
        ORDER BY
          pt.patientunitstayid )
      SELECT
        pt.patientunitstayid,
        t3.sao2,
        t4.pao2,
        (CASE
            WHEN t1.rcfio2>20 THEN t1.rcfio2
            WHEN t2.ncfio2 >20 THEN t2.ncfio2
            WHEN t1.rcfio2=1 OR t2.ncfio2=1 THEN 100
            ELSE NULL END) AS fio2,
        t5.mechvent
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
      LEFT OUTER JOIN
        t5
      ON
        t5.patientunitstayid=pt.patientunitstayid
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
      tempo1
      -- order by fio2
      )
  SELECT
    patientunitstayid,
    (CASE
        WHEN pf <1 OR sf <0.67 THEN 4
        WHEN pf BETWEEN 1
      AND 2
      OR sf BETWEEN 0.67
      AND 1.41 THEN 3
        WHEN pf BETWEEN 2 AND 3 OR sf BETWEEN 1.42 AND 2.2 THEN 2
        WHEN pf BETWEEN 3
      AND 4
      OR sf BETWEEN 2.21
      AND 3.01 THEN 1
        WHEN pf > 4 OR sf> 3.01 THEN 0
        ELSE 0
      END ) AS SOFA_respi
  FROM
    tempo2
  ORDER BY
    patientunitstayid