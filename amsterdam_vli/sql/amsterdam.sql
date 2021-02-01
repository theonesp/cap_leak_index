-------------------------
-- Amsterdam DB query
-------------------------

CREATE OR REPLACE TABLE `amsterdam-translation.amsterdam_custom.capleakmaster` AS (
WITH adm as (
    SELECT 
    admissionid,
    patientid,
    agegroup,
    CASE WHEN gender = 'Vrouw' THEN 'Female' WHEN gender = 'Man' THEN 'Male' ELSE gender END AS gender,
    CASE WHEN location = 'MC' THEN 'High Dependency' WHEN location = 'IC' THEN 'ICU' END AS location,
    CASE WHEN origin IN ('Eerste Hulp afdeling zelfde ziekenhuis','Eerste Hulp afdeling ander ziekenhuis') THEN 'emergency'
            WHEN origin IN ('Recovery zelfde ziekenhuis (alleen bij niet geplande IC-opname)','Recovery ander ziekenhuis') THEN 'recovery'
            WHEN origin IN ('Operatiekamer vanaf verpleegafdeling zelfde ziekenhuis','Operatiekamer vanaf Eerste Hulp afdeling zelfde ziekenhuis') THEN 'operating_room'
            WHEN origin IN ('Special/Medium care zelfde ziekenhuis','Special/Medium care ander ziekenhuis') THEN 'special_medium_care'
            WHEN origin IN ('CCU/IC zelfde ziekenhuis','CCU/IC ander ziekenhuis') THEN 'other_icu'
            WHEN origin IN ('Verpleegafdeling zelfde ziekenhuis','Verpleegafdeling ander ziekenhuis') THEN 'floor'
            WHEN origin IN ('Andere locatie zelfde ziekenhuis, transport per ambulance','Huis','Anders') THEN 'other' 
            ELSE origin END AS origin,
    CASE WHEN origin IN ('Verpleegafdeling zelfde ziekenhuis',
                            'Eerste Hulp afdeling zelfde ziekenhuis',
                            'CCU/IC zelfde ziekenhuis',
                            'Recovery zelfde ziekenhuis (alleen bij niet geplande IC-opname)',
                            'Special/Medium care zelfde ziekenhuis',
                            'Andere locatie zelfde ziekenhuis, transport per ambulance',
                        'Operatiekamer vanaf Eerste Hulp afdeling zelfde ziekenhuis') THEN true ELSE false END AS origin_same_hospital, 
    CEIL(dischargedat/3600000) as hospital_los_hours, -- dischargedat = number of milliseconds from hospital admission to hospital discharge; 1 hour = 3.6 million milliseconds
    CASE WHEN destination = 'Overleden' THEN true ELSE false END as icu_mortality,
    -- CASE WHEN dateofdeath BETWEEN admittedat AND (admittedat+lengthofstay) THEN true ELSE false END AS icu_mortality, -- admittedat = milliseconds since first admission
    CASE WHEN dateofdeath < dischargedat THEN true ELSE false END AS hospital_mortality, -- dischargedat = milliseconds since hospital admission
    CASE WHEN dateofdeath IS NOT NULL THEN true ELSE false END AS all_mortality, -- dateofdeath = milliseconds since admission
    lengthofstay as icu_los_hours, -- lengthofstay = milliseconds since ICU admission
    CASE WHEN specialty = 'Cardiologie' THEN 'Medical - Cardiology'
             WHEN specialty = 'Neurologie' THEN 'Medical - Neurology'
             WHEN specialty = 'Cardiochirurgie' THEN 'Cardiac Surgery'
             WHEN specialty = 'Inwendig' THEN 'Medical - Internal Medicine'
             WHEN specialty = 'Longziekte' THEN 'Medical - Pulmonology'
             WHEN specialty = 'Nefrologie' THEN 'Medical - Nephrology'
             WHEN specialty = 'Hematologie' THEN 'Medical - Hematology'
             WHEN specialty = 'Reumatologie' THEN 'Medical - Rheumatology'
             WHEN specialty = 'Oncologie Inwendig' THEN 'Medical - Oncology'
             WHEN specialty = 'Maag-,Darm-,Leverziekten' THEN 'Medical - Gastroenterology and Hepatology'
             WHEN specialty = 'Intensive Care Volwassenen' THEN 'Medical - Intensive Care Medicine'
             WHEN specialty = 'Urologie' THEN 'Surgical - Urology'
             WHEN specialty IN('Obstetrie','Gynaecologie','Verloskunde') THEN 'Surgical - OBGYN'
             WHEN specialty = 'Orthopedie' THEN 'Surgical - Orthopedics'
             WHEN specialty = 'Oogheelkunde' THEN 'Surgical - Ophthalmology'
             WHEN specialty = 'Mondheelkunde' THEN 'Surgical - Oral Surgery'
             WHEN specialty = 'Traumatologie' THEN 'Surgical - Trauma Surgery'
             WHEN specialty = 'Vaatchirurgie' THEN 'Surgical - Vascular surgery'
             WHEN specialty = 'Heelkunde Oncologie' THEN 'Surgical - Oncology'
             WHEN specialty = 'Keel, Neus & Oorarts' THEN 'Surgical - ENT'
             WHEN specialty = 'Plastische chirurgie' THEN 'Surgical - Plastic Surgery'
             WHEN specialty = 'Heelkunde Longen/Oncologie' THEN 'Surgical - Thoracic Surgery'
             WHEN specialty = 'Heelkunde Gastro-enterologie' THEN 'Surgical - GI Surgery'
             WHEN specialty = 'Neurochirurgie' THEN 'Surgical - Neurosurgery'
             ELSE 'Other' -- also contains 'ders'
             END AS unitType
    FROM `physionet-data.amsterdamdb.admissions`
),  numeric_height_weight as (
    SELECT
    admissionid,
    height,
    weight,
    SAFE_DIVIDE(weight,(height*height)) AS BMI
    FROM (
        SELECT 
        admissionid,
        CASE WHEN weight IS NOT NULL THEN weight
                   WHEN weightgroup = '59-' THEN 59
                   WHEN weightgroup = '60-69' THEN 65
                   WHEN weightgroup = '70-79' THEN 75
                   WHEN weightgroup = '80-89' THEN 85
                   WHEN weightgroup = '90-99' THEN 95
                   WHEN weightgroup = '100-109' THEN 105
                   WHEN weightgroup = '110+' THEN 110
                   ELSE NULL END AS weight,
        CASE WHEN height IS NOT NULL THEN height
                    WHEN lengthgroup = '159-' THEN 159
                    WHEN lengthgroup = '160-169' THEN 165
                    WHEN lengthgroup = '170-179' THEN 175
                    WHEN lengthgroup = '180-189' THEN 185
                    WHEN lengthgroup = '190+' THEN 190
                    ELSE NULL END AS height,
        FROM (
            SELECT 
            a.admissionid,
            ANY_VALUE(a.weightgroup) as weightgroup,
            ANY_VALUE(a.lengthgroup) as lengthgroup,
            MAX(CASE WHEN n.item IN('PatiëntGewicht','Gewicht bij opname') THEN n.value ELSE NULL END) as weight,
            MAX(CASE WHEN n.item = 'PatiëntLengte' THEN n.value ELSE NULL END) as height
            FROM `physionet-data.amsterdamdb.numericitems` n
            LEFT JOIN `physionet-data.amsterdamdb.admissions` a
            ON n.admissionid = a.admissionid
            WHERE item IN('PatiëntGewicht','Gewicht bij opname','PatiëntLengte')
            GROUP BY a.admissionid
        )
    ) 
),  drug as (
    SELECT 
    admissionid, 
    fluidin,
    ordercategory,
    stop/86400000 as stop
    FROM `physionet-data.amsterdamdb.drugitems`
),  numitems as (
    SELECT
    admissionid,
    item,
    value,
    fluidout,
    measuredat/86400000 as measuredat
    FROM  `physionet-data.amsterdamdb.numericitems`
),  first_hct as (
    SELECT 
    admissionid,
    item,
    CASE WHEN value > 0.1 AND value < 1.0 THEN value WHEN value > 10 AND value < 100 THEN value/100 ELSE NULL END AS value,
    measuredat/86400000 as measuredat 
    FROM `physionet-data.amsterdamdb.numericitems`
    WHERE item IN ('Hematocriet','A_Hematocriet(%)','RA_Hematocriet(%)','MCA_Hematocriet(%)','Ht(v.Bgs) (bloed)','Ht (bloed)') AND measuredat BETWEEN -21600000 AND 21600000
),  second_hct as (
    SELECT 
    admissionid,
    item,
    CASE WHEN value > 0.1 AND value < 1.0 THEN value WHEN value > 10 AND value < 100 THEN value/100 ELSE NULL END AS value,
    measuredat/86400000 as measuredat 
    FROM `physionet-data.amsterdamdb.numericitems`
    WHERE item IN ('Hematocriet','A_Hematocriet(%)','RA_Hematocriet(%)','MCA_Hematocriet(%)','Ht(v.Bgs) (bloed)','Ht (bloed)') AND measuredat BETWEEN 86400000 AND 172800000
),  all_days as (
    SELECT
    admissionid
    , 0 as endoffset
    , lengthofstay as startoffset
    , GENERATE_ARRAY(0, CAST(ceil(lengthofstay/24.0) AS INT64)) as days
   from `physionet-data.amsterdamdb.admissions`
), daily as (
    SELECT
    admissionid
    , CAST(days AS INT64) as days
    , endoffset + days-1 as startoffset
    , endoffset + days as endoffset
    FROM all_days
    CROSS JOIN UNNEST(all_days.days) AS days
), blood_colloid as (
    SELECT 
    admissionid
    FROM `physionet-data.amsterdamdb.drugitems`
    WHERE ordercategory IN('Infuus - Colloid','Infuus - Bloedproducten') --exclude patients who received colloids or blood products
    AND stop < 86400000 -- within first 24h
    AND dose IS NOT NULL
), ventilation as (
    SELECT
    admissionid,
    CEIL(duration/1440) as unabridgedactualventdays
    FROM `physionet-data.amsterdamdb.processitems` 
    WHERE item = 'Beademen'
), sofa_scores as (
    SELECT
    admissionid,
    sofatotal_day1,
    sofatotal_day2,
    CASE WHEN sofatotal_day3 IS NOT NULL THEN sofatotal_day3 
         WHEN sofatotal_day3 IS NULL AND sofatotal_day2 IS NOT NULL THEN sofatotal_day2
         ELSE NULL END as sofatotal_day3,
    CASE WHEN sofatotal_day4 IS NOT NULL THEN sofatotal_day4
         WHEN sofatotal_day4 IS NULL AND sofatotal_day3 IS NOT NULL THEN sofatotal_day3
         WHEN sofatotal_day4 IS NULL AND sofatotal_day2 IS NOT NULL THEN sofatotal_day3
         ELSE NULL END AS sofatotal_day4,
    1 as dummykey
    FROM (
        SELECT
        admissionid,
        MAX(CASE WHEN day = 1 THEN sofa_score ELSE NULL END) as sofatotal_day1,
        MAX(CASE WHEN day = 2 THEN sofa_score ELSE NULL END) as sofatotal_day2,
        MAX(CASE WHEN day = 3 THEN sofa_score ELSE NULL END) as sofatotal_day3,
        MAX(CASE WHEN day = 4 THEN sofa_score ELSE NULL END) as sofatotal_day4,
        FROM `amsterdam-translation.amsterdam_custom.daily_sofa_labs`
        GROUP BY admissionid
    )
), sofa_quantiles AS (
    SELECT 
    --day of lowest Hb
    sofatotal_day1_quantiles[OFFSET(0)] AS sofatotal_day1_q1_min,
    sofatotal_day1_quantiles[OFFSET(1)] AS sofatotal_day1_q1_max,
    sofatotal_day1_quantiles[OFFSET(1)] + 1 AS sofatotal_day1_q2_min,
    sofatotal_day1_quantiles[OFFSET(2)] AS sofatotal_day1_q2_max,
    sofatotal_day1_quantiles[OFFSET(2)] + 1 AS sofatotal_day1_q3_min,
    sofatotal_day1_quantiles[OFFSET(3)] as sofatotal_day1_q3_max,
    --day after lowest Hb
    sofatotal_day4_quantiles[OFFSET(0)] AS sofatotal_day4_q1_min,
    sofatotal_day4_quantiles[OFFSET(1)] AS sofatotal_day4_q1_max,
    sofatotal_day4_quantiles[OFFSET(1)] + 1 AS sofatotal_day4_q2_min,
    sofatotal_day4_quantiles[OFFSET(2)] AS sofatotal_day4_q2_max,
    sofatotal_day4_quantiles[OFFSET(2)] + 1 AS sofatotal_day4_q3_min,
    sofatotal_day4_quantiles[OFFSET(3)] as sofatotal_day4_q3_max,
    1 AS dummykey
    FROM (
        SELECT 
        APPROX_QUANTILES(sofatotal_day1, 3) AS sofatotal_day1_quantiles,
        APPROX_QUANTILES(sofatotal_day4, 3) AS sofatotal_day4_quantiles
        FROM sofa_scores
    )
), sofa_q as (
    SELECT
    admissionid,
    sofatotal_day1,
    sofatotal_day2,
    sofatotal_day3,
    sofatotal_day4,
    sofatotal_day1_quantile,
    sofatotal_day4_quantile,
    -- t_sofatotal_day1 == 3 & sofatotal_day2 == sofatotal_day1 ~ 1,
    -- t_sofatotal_day1 == 3 & sofatotal_day2 >  sofatotal_day1 ~ 1,
    -- t_sofatotal_day1 == 3 & sofatotal_day2 <  sofatotal_day1 ~ 0,
    -- t_sofatotal_day1 == 2 & sofatotal_day2 == sofatotal_day1 ~ 1,
    -- t_sofatotal_day1 == 2 & sofatotal_day2 >  sofatotal_day1 ~ 1,
    -- t_sofatotal_day1 == 2 & sofatotal_day2 <  sofatotal_day1 ~ 0,     
    -- t_sofatotal_day1 == 1 & sofatotal_day2 == sofatotal_day1 ~ 0,
    -- t_sofatotal_day1 == 1 & sofatotal_day2 >  sofatotal_day1 ~ 1,
    -- t_sofatotal_day1 == 1 & sofatotal_day2 <  sofatotal_day1 ~ 0, 
    CASE WHEN sofatotal_day1_quantile = 3 AND sofatotal_day4_quantile = sofatotal_day1_quantile THEN 1
         WHEN sofatotal_day1_quantile = 3 AND sofatotal_day4_quantile > sofatotal_day1_quantile THEN 1
         WHEN sofatotal_day1_quantile = 3 AND sofatotal_day4_quantile < sofatotal_day1_quantile THEN 0
         WHEN sofatotal_day1_quantile = 2 AND sofatotal_day4_quantile = sofatotal_day1_quantile THEN 1
         WHEN sofatotal_day1_quantile = 2 AND sofatotal_day4_quantile > sofatotal_day1_quantile THEN 1
         WHEN sofatotal_day1_quantile = 2 AND sofatotal_day4_quantile < sofatotal_day1_quantile THEN 0
         WHEN sofatotal_day1_quantile = 1 AND sofatotal_day4_quantile = sofatotal_day1_quantile THEN 0
         WHEN sofatotal_day1_quantile = 1 AND sofatotal_day4_quantile > sofatotal_day1_quantile THEN 1
         WHEN sofatotal_day1_quantile = 1 AND sofatotal_day4_quantile < sofatotal_day1_quantile THEN 0
         ELSE NULL
         END AS delta_sofa
    FROM (
        SELECT 
        sofa.admissionid,
        sofa.sofatotal_day1,
        sofa.sofatotal_day2,
        sofa.sofatotal_day3,
        sofa.sofatotal_day4,
        CASE WHEN sofatotal_day1 BETWEEN sofa_quantiles.sofatotal_day1_q1_min AND sofa_quantiles.sofatotal_day1_q1_max THEN 1
            WHEN sofatotal_day1 BETWEEN sofa_quantiles.sofatotal_day1_q2_min AND sofa_quantiles.sofatotal_day1_q2_max THEN 2
            WHEN sofatotal_day1 BETWEEN sofa_quantiles.sofatotal_day1_q2_min AND sofa_quantiles.sofatotal_day1_q3_max THEN 2
            ELSE NULL
            END AS sofatotal_day1_quantile,
        CASE WHEN sofatotal_day4 BETWEEN sofa_quantiles.sofatotal_day4_q1_min AND sofa_quantiles.sofatotal_day4_q1_max THEN 1
            WHEN sofatotal_day4 BETWEEN sofa_quantiles.sofatotal_day4_q2_min AND sofa_quantiles.sofatotal_day4_q2_max THEN 2
            WHEN sofatotal_day4 BETWEEN sofa_quantiles.sofatotal_day4_q2_min AND sofa_quantiles.sofatotal_day4_q3_max THEN 2
            ELSE NULL
            END AS sofatotal_day4_quantile,
        FROM sofa_scores sofa
        LEFT JOIN sofa_quantiles
            ON sofa.dummykey=sofa_quantiles.dummykey
    ) 
), fluids as (
    SELECT 
    fluidin_daily.admissionid,
    daily_fluid_in,
    daily_fluid_out,
    daily_fluid_in - daily_fluid_out AS totalFluid
    FROM  (
        SELECT 
        d.admissionid,
        d.days,
        SUM(dr.fluidin) as daily_fluid_in
        FROM daily d
        LEFT JOIN drug dr
        ON d.admissionid = dr.admissionid
        AND stop BETWEEN 0 AND 1 --first 24 hours
        WHERE ordercategory = "Infuus - Crystalloid"
        GROUP BY d.admissionid, d.days
    ) fluidin_daily
    LEFT JOIN (
        SELECT
        d.admissionid,
        d.days,
        SUM(n.fluidout) as daily_fluid_out
        FROM daily d
        LEFT JOIN numitems n
        ON d.admissionid = n.admissionid
        AND measuredat BETWEEN 0 AND 1 --first 24 hours
        GROUP BY d.admissionid, d.days
    ) fluidout_daily
    ON fluidin_daily.admissionid=fluidout_daily.admissionid
), hct as (
    SELECT 
    first.admissionid,
    first.value as hematocrit_first_6,
    second.value as mean_hct_24_36hrs,
    second.value - first.value as delta_hct
    FROM first_hct first
    LEFT JOIN second_hct second
    ON first.admissionid = second.admissionid
), apache as (
    SELECT
    d.admissionid,
    MAX(value) as apachescore
    FROM daily d
    LEFT JOIN `physionet-data.amsterdamdb.numericitems` n
    ON d.admissionid = n.admissionid
    AND measuredat/86400000 BETWEEN 0 AND 1 --first 24 hours
    WHERE item = 'A_Apache_Score'
    GROUP BY d.admissionid, d.days
)
SELECT 
    ANY_VALUE(adm.admissionid) as patientunitstayid,		
    ANY_VALUE(adm.agegroup) as age_fixed,
    ANY_VALUE(adm.gender) as gender,
    ANY_VALUE(hw.weight) as weight,
    MAX(adm.hospital_los_hours) as HospitalLOS,
    ANY_VALUE(hw.height) as height,
    ANY_VALUE(hw.BMI) as BMI,
    ANY_VALUE(CASE WHEN hw.BMI < 18 THEN 'underweight'
                   WHEN hw.BMI >= 18 AND hw.BMI <25 THEN 'normal'
                   WHEN hw.BMI >= 25 AND hw.BMI <30 THEN 'overweight'
                   WHEN hw.BMI >30 THEN 'obese'
                   ELSE NULL END) as BMI_group,
    ANY_VALUE(adm.unitType) as unitType,
    ANY_VALUE(adm.origin) as hospitalAdmitSource,
    ANY_VALUE(NULL) as hospLOS_prior_ICUadm_days,
    ANY_VALUE(hw.body_surface_area) as body_surface_area,
    ANY_VALUE(apache.apachescore) as apachescore,
    --mortality outcomes
    MAX(adm.icu_mortality) as actualicumortality,
    MAX(adm.hospital_mortality) as actualhospitalmortality,
    --length of stay outcomes
    MAX(adm.icu_los_hours) as unabridgedunitlos,
    MAX(adm.hospital_los_hours) as unabridgedhosplos,
    MAX(vent.unabridgedactualventdays) as unabridgedactualventdays, 
    --hematocrit levels
    MAX(hct.hematocrit_first_6) as first_hct_6hrs,
    MAX(hct.mean_hct_24_36hrs) as mean_hct_24_36hrs,
    --fluids in out
    MAX(fluids.daily_fluid_in) as intakes,
    MAX(fluids.daily_fluid_out) as outputs,
    MAX(fluids.totalFluid) as totalFluid,
    --charlson components
    MAX(chl.mets_score) as mets6,
    MAX(chl.aids_score) as aids6,
    MAX(chl.liver_score) as liver1,
    MAX(chl.stroke_score) as stroke2,
    MAX(chl.renal_score) as renal2,
    MAX(chl.dm_score) as dm,
    MAX(chl.cancer_score) as cancer2,
    MAX(chl.leukemia_score) as leukemia2,
    MAX(chl.lymphoma_score) as lymphoma2,
    MAX(chl.mi_score) as mi1,
    MAX(chl.chf_score) as chf1,
    MAX(chl.pvd_score) as pvd1,
    MAX(chl.dem_score) as dementia1,
    MAX(chl.copd_score) as copd1,
    MAX(chl.ctd_score) as ctd1,
    MAX(chl.pud_score) as pud1,
    MAX(chl.age_score_charlson) as age_score_charlson,
    MAX(chl.charlson_score) as final_charlson_score,
    MAX(sofa_q.sofatotal_day1) as sofatotal_day1,
    MAX(sofa_q.sofatotal_day2) as sofatotal_day2,
    MAX(sofa_q.sofatotal_day3) as sofatotal_day3,
    MAX(sofa_q.sofatotal_day4) as sofatotal_day4,
    MAX((SAFE_DIVIDE(hct.delta_hct,fluids.totalFluid))*body_surface_area) as leaking_index,
    MAX(sofa_q.delta_sofa) AS delta_sofa,
FROM adm
LEFT JOIN (
    SELECT 
    *,
    SQRT((height*weight)/3600) as body_surface_area
    FROM numeric_height_weight
) hw
    ON adm.admissionid = hw.admissionid
LEFT JOIN apache
    ON adm.admissionid = apache.admissionid
LEFT JOIN fluids
    ON adm.admissionid=fluids.admissionid
LEFT JOIN hct
    ON adm.admissionid=hct.admissionid
LEFT JOIN (
    SELECT 
    *
    FROM `amsterdam-translation.amsterdam_custom.charlson`
) chl
    ON adm.admissionid = chl.admissionid
LEFT JOIN ventilation vent 
    ON adm.admissionid = vent.admissionid
LEFT JOIN sofa_q
    ON adm.admissionid = sofa_q.admissionid
GROUP BY adm.admissionid
ORDER BY adm.admissionid
)
