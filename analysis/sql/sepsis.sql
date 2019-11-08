  -- ------------------------------------------------------------------
  -- Title: Select patients from diagnosis which are included & excluded by icd9codes
  -- Notes: cap_leak_index/analysis/sql/Alistair_sepsis.sql
  --        cap_leak_index, 20190511 NYU Datathon
  --        eICU Collaborative Research Database v2.0.
  -- ------------------------------------------------------------------
WITH
  SeInOr AS (
  WITH
    dx1 AS (
    SELECT
      patientunitstayid,
      MAX(CASE
          WHEN category = 'sepsis' THEN 1
        ELSE
        0
      END
        ) AS sepsis,
      MAX(CASE
          WHEN category = 'infection' THEN 1
        ELSE
        0
      END
        ) AS infection,
      MAX(CASE
          WHEN category = 'organfailure' THEN 1
        ELSE
        0
      END
        ) AS organfailure
      -- priorities
      -- only three types: Primary, Major, and Other. Priority is NOT NULLABLE !
      ,
      coalesce(MIN(CASE
            WHEN category = 'sepsis' AND diagnosispriority = 'Primary' THEN 1
            WHEN category = 'sepsis'
          AND diagnosispriority = 'Major' THEN 2
            WHEN category = 'sepsis' AND diagnosispriority = 'Other' THEN 3
          ELSE
          NULL
        END
          ),
        0) AS sepsis_priority,
      coalesce(MIN(CASE
            WHEN category = 'infection' AND diagnosispriority = 'Primary' THEN 1
            WHEN category = 'infection'
          AND diagnosispriority = 'Major' THEN 2
            WHEN category = 'infection' AND diagnosispriority = 'Other' THEN 3
          ELSE
          NULL
        END
          ),
        0) AS infection_priority,
      coalesce(MIN(CASE
            WHEN category = 'organfailure' AND diagnosispriority = 'Primary' THEN 1
            WHEN category = 'organfailure'
          AND diagnosispriority = 'Major' THEN 2
            WHEN category = 'organfailure' AND diagnosispriority = 'Other' THEN 3
          ELSE
          NULL
        END
          ),
        0) AS organfailure_priority
    FROM
      `physionet-data.eicu_crd.diagnosis` dx
    LEFT JOIN
      `physionet-data.eicu_crd_derived.diagnosis_categories` dxlist
    ON
      dx.diagnosisstring = dxlist.dx
    WHERE
      diagnosisoffset >= -60
      AND diagnosisoffset < 60*24
    GROUP BY
      patientunitstayid ),
    dx2 AS (
    SELECT
      patientunitstayid,
      MAX(CASE
          WHEN category = 'sepsis' THEN 1
        ELSE
        0
      END
        ) AS sepsis,
      MAX(CASE
          WHEN category = 'infection' THEN 1
        ELSE
        0
      END
        ) AS infection,
      MAX(CASE
          WHEN category = 'organfailure' THEN 1
        ELSE
        0
      END
        ) AS organfailure
    FROM
      `physionet-data.eicu_crd.apachepredvar` apv
    LEFT JOIN
      `physionet-data.eicu_crd_derived.apachedx_categories` a
    ON
      apv.admitdiagnosis = a.dx
    GROUP BY
      patientunitstayid )
  SELECT
    pt.patientunitstayid,
    -- rule for sepsis
    CASE
      WHEN dx1.sepsis = 1 THEN 1
      WHEN dx2.sepsis = 1 THEN 1
    -- diagnosis + apache dx
      WHEN GREATEST(dx1.infection, dx2.infection) = 1 AND GREATEST(dx1.organfailure, dx2.organfailure) = 1 THEN 1
    ELSE
    0
  END
    AS sepsis
    -- from problem list
    ,
    dx1.sepsis AS sepsis_dx,
    dx1.sepsis_priority,
    dx1.infection AS infection_dx,
    dx1.infection_priority,
    dx1.organfailure AS organfailure_dx,
    dx1.organfailure_priority,
    dx2.sepsis AS sepsis_apache,
    dx2.infection AS infection_apache,
    dx2.organfailure AS organfailure_apache
  FROM
    `physionet-data.eicu_crd.patient` pt
  LEFT JOIN
    dx1
  ON
    pt.patientunitstayid = dx1.patientunitstayid
  LEFT JOIN
    dx2
  ON
    pt.patientunitstayid = dx2.patientunitstayid
  ORDER BY
    pt.patientunitstayid )
SELECT
  patientunitstayid
FROM
  SeInOr
WHERE (sepsis = 1)