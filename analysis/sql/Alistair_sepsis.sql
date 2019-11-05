-- ------------------------------------------------------------------
-- Title: Select patients from diagnosis which are included & excluded by icd9codes
-- Notes: cap_leak_index/analysis/sql/Alistair_sepsis.sql 
--        cap_leak_index, 20190511 NYU Datathon
--        eICU Collaborative Research Database v2.0.
-- ------------------------------------------------------------------
WITH SeInOr AS
(
  WITH dx1 AS
  (
    SELECT
      patientunitstayid
      , MAX(CASE WHEN category = 'sepsis' THEN 1 else 0 end) as sepsis
      , MAX(CASE WHEN category = 'infection' then 1 else 0 end) as infection
      , MAX(CASE WHEN category = 'organfailure' then 1 else 0 end) as organfailure
      -- priorities
      -- only three types: Primary, Major, and Other. Priority is NOT NULLABLE !
      , coalesce(min(case when category = 'sepsis' and diagnosispriority = 'Primary' then 1
              when category = 'sepsis' and diagnosispriority = 'Major' then 2
              when category = 'sepsis' and diagnosispriority = 'Other' then 3
            else NULL end),0) as sepsis_priority
      , coalesce(min(case when category = 'infection' and diagnosispriority = 'Primary' then 1
              when category = 'infection' and diagnosispriority = 'Major' then 2
              when category = 'infection' and diagnosispriority = 'Other' then 3
            else NULL end),0) as infection_priority
      , coalesce(min(case when category = 'organfailure' and diagnosispriority = 'Primary' then 1
              when category = 'organfailure' and diagnosispriority = 'Major' then 2
              when category = 'organfailure' and diagnosispriority = 'Other' then 3
            else NULL end),0) as organfailure_priority
    FROM `physionet-data.eicu_crd.diagnosis` dx
    LEFT JOIN `physionet-data.eicu_crd_derived.diagnosis_categories` dxlist
      on dx.diagnosisstring = dxlist.dx
    where diagnosisoffset >= -60 and diagnosisoffset < 60*24
    group by patientunitstayid
  ), 
  dx2 AS
  (
    SELECT
      patientunitstayid
      , MAX(CASE WHEN category = 'sepsis' then 1 else 0 end) as sepsis
      , MAX(CASE WHEN category = 'infection' then 1 else 0 end) as infection
      , MAX(CASE WHEN category = 'organfailure' then 1 else 0 end) as organfailure
    from `physionet-data.eicu_crd.apachepredvar` apv
    left join `physionet-data.eicu_crd_derived.apachedx_categories` a
      on apv.admitdiagnosis = a.dx
    group by patientunitstayid
  )
  select
    pt.patientunitstayid,
    -- rule for sepsis
      CASE
      WHEN dx1.sepsis = 1 THEN 1
      WHEN dx2.sepsis = 1 THEN 1
      -- diagnosis + apache dx
      WHEN GREATEST(dx1.infection, dx2.infection) = 1
        AND GREATEST(dx1.organfailure, dx2.organfailure) = 1 THEN 1
    ELSE 0 END as sepsis 
    -- from problem list
    , dx1.sepsis as sepsis_dx, dx1.sepsis_priority
    , dx1.infection as infection_dx, dx1.infection_priority
    , dx1.organfailure as organfailure_dx, dx1.organfailure_priority 
    , dx2.sepsis as sepsis_apache
    , dx2.infection as infection_apache
    , dx2.organfailure as organfailure_apache
  from `physionet-data.eicu_crd.patient` pt
  left join dx1
    on pt.patientunitstayid = dx1.patientunitstayid
  left join dx2
    on pt.patientunitstayid = dx2.patientunitstayid
  order by pt.patientunitstayid
)
SELECT patientunitstayid
FROM SeInOr
WHERE (sepsis = 1);
