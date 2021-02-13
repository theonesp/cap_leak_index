--------------------------------------------------------
-- Description: Calculate daily SOFA score and key labs
--------------------------------------------------------
with all_days as (
    SELECT
    admissionid
    , 0 as endoffset
    , lengthofstay as startoffset
    , GENERATE_ARRAY(0, CAST(ceil(lengthofstay/24.0) AS INT64)) as day
   from `physionet-data.amsterdamdb.admissions`
), daily as (
    SELECT
    admissionid
    , CAST(day AS INT64) as day
    , endoffset + day-1 as startoffset
    , endoffset + day as endoffset
    FROM all_days
    CROSS JOIN UNNEST(all_days.day) AS day
), gcs as (
    SELECT 
    admissionid,
    measuredat/86400000 as day,
    CASE WHEN item = 'Actief openen van de ogen' AND value = 'Geen reactie' THEN 1 -- not reactive
        WHEN item = 'Actief openen van de ogen' AND value = 'Reactie op pijnprikkel' THEN 2 -- opens to painful stimuli
        WHEN item = 'Actief openen van de ogen' AND value = 'Reactie op verbale prikkel' THEN 3 -- opens to verbal stimuli
        WHEN item = 'Actief openen van de ogen' AND value = 'Spontane reactie' THEN 4 -- opens spontaneously
        ELSE NULL
        END AS gcs_eye,
    CASE WHEN item = 'Beste verbale reactie' AND value = 'Geen reactie (geen zichtbare poging tot praten)' THEN 1 -- no response (no visible attempt to speak)
        WHEN item = 'Beste verbale reactie' AND value = 'Geïntubeerd' THEN 1 --intubated
        WHEN item = 'Beste verbale reactie' AND value = 'Onbegrijpelijke geluiden' THEN 2 -- incomprehensible sounds
        WHEN item = 'Beste verbale reactie' AND value = 'Onduidelijke woorden (pogingen tot communicatie, maar onduidelijk)' THEN 3 -- unclear words (attempts at communication, but unclear)
        WHEN item = 'Beste verbale reactie' AND value = 'Verwarde conversatie' THEN 4 -- confused conversation
        WHEN item = 'Beste verbale reactie' AND value = 'Helder en adequaat (communicatie mogelijk)' THEN 5 -- clear and adequate communication 
        ELSE NULL
        END AS gcs_verbal,
    CASE WHEN item = 'Beste motore reactie van de armen' AND value = 'Geen reactie' THEN 1 -- no response 
        WHEN item = 'Beste motore reactie van de armen' AND value = 'Strekken' THEN 2 -- stretching (?extension to pain)
        WHEN item = 'Beste motore reactie van de armen' AND value = 'Decortatie reflex (abnormaal buigen)' THEN 3 -- Abnormal flexion
        WHEN item = 'Beste motore reactie van de armen' AND value = 'Spastische reactie (terugtrekken)' THEN 4 -- Spastic reaction (withdrawal)
        WHEN item = 'Beste motore reactie van de armen' AND value = 'Localiseert pijn' THEN 5 -- locates pain
        WHEN item = 'Beste motore reactie van de armen' AND value = "Volgt verbale commando's op" THEN 6 -- follows verbal commands
        ELSE NULL 
        END AS gcs_motor
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE item IN('Actief openen van de ogen','Beste verbale reactie','Beste motore reactie van de armen')
),
sofa_table as(
SELECT
d.admissionid,
sofa_gcs_score,
sofa_resp_score,
sofa_circ_score,
sofa_liver_score,
sofa_hematology_score,
(sofa_gcs_score + sofa_resp_score + sofa_circ_score + sofa_liver_score + sofa_hematology_score + sofa_renal_score) AS sofa_score, 
hgb_min as hgbmin, 
trop_max, 
creatinine_max,
ph_min, 
lactate_max,
d.day
FROM daily d
LEFT JOIN(
    SELECT
    admissionid,
    day,
    CASE WHEN MIN(gcs_eye) + MIN(gcs_verbal) + MIN(gcs_motor) =  15 THEN 0
         WHEN MIN(gcs_eye) + MIN(gcs_verbal) + MIN(gcs_motor) BETWEEN 13 AND 14 THEN 1
         WHEN MIN(gcs_eye) + MIN(gcs_verbal) + MIN(gcs_motor) BETWEEN 10 AND 12 THEN 2
         WHEN MIN(gcs_eye) + MIN(gcs_verbal) + MIN(gcs_motor) BETWEEN 6 AND 9 THEN 3
         WHEN MIN(gcs_eye) + MIN(gcs_verbal) + MIN(gcs_motor) < 6 THEN 4
         END AS sofa_gcs_score
    FROM (
        SELECT 
        d.admissionid,
        d.day,
        -- Neurology
        -- Glasgow coma scale	SOFA score
        -- 15	0
        -- 13–14	+1
        -- 10–12	+2
        -- 6–9	+3
        -- < 6	+4
        CASE WHEN gcs_eye IS NOT NULL THEN gcs_eye
             ELSE (SELECT MIN(gcs.gcs_eye) 
                   FROM gcs 
                   WHERE d.admissionid = gcs.admissionid 
                   AND gcs.day < d.day) 
             END AS gcs_eye,
        CASE WHEN gcs_verbal IS NOT NULL THEN gcs_verbal
             ELSE (SELECT MIN(gcs.gcs_verbal) 
                   FROM gcs 
                   WHERE d.admissionid = gcs.admissionid 
                   AND gcs.day < d.day) 
             END AS gcs_verbal,
        CASE WHEN gcs_motor IS NOT NULL THEN gcs_motor
             ELSE (SELECT MIN(gcs.gcs_motor) 
                   FROM gcs 
                   WHERE d.admissionid = gcs.admissionid 
                   AND gcs.day < d.day) 
             END AS gcs_motor
        FROM daily d
        LEFT JOIN gcs
            ON d.admissionid = gcs.admissionid
            AND gcs.day BETWEEN d.startoffset AND d.endoffset
    )
    GROUP BY admissionid, day
) gcs_daily
ON d.admissionid = gcs_daily.admissionid
AND d.day = gcs_daily.day
LEFT JOIN (
    SELECT 
    d.admissionid,
    d.day,
    -- Respiratory
    -- PaO2/FiO2 [mmHg (kPa)]	SOFA score
    -- ≥ 400 (53.3)	0
    -- < 400 (53.3)	+1
    -- < 300 (40)	+2
    -- < 200 (26.7) and mechanically ventilated	+3
    -- < 100 (13.3) and mechanically ventilated	+4
    CASE WHEN MIN(pao2)/MIN(fio2) >= 400 THEN 0
        WHEN MIN(pao2)/MIN(fio2) BETWEEN 300 AND 399 THEN 1
        WHEN MIN(pao2)/MIN(fio2) BETWEEN 200 AND 299 THEN 2
        WHEN MIN(pao2)/MIN(fio2) BETWEEN 100 AND 199 THEN 3
        WHEN MIN(pao2)/MIN(fio2) < 100 THEN 4
        ELSE NULL
        END as sofa_resp_score
    FROM daily d
    LEFT JOIN (
        SELECT 
        admissionid,
        measuredat/86400000 as day,
        CASE WHEN item IN('PO2 (bloed)','PO2') AND value > 20 THEN value 
             WHEN item IN('PO2 (bloed) - kPa') AND value > 20/7.50062 THEN value * 7.50062 ELSE NULL END AS pao2,
        CASE WHEN item IN('O2 concentratie (Set)','O2 concentratie','FiO2 %','SET %O2','A_FiO2','MCA_FiO2') AND value > 1 AND value <= 100 THEN value/100 
             WHEN item IN('O2 concentratie (Set)','O2 concentratie','FiO2 %','SET %O2','A_FiO2','MCA_FiO2') AND value BETWEEN 0.2 AND 1 THEN value ELSE NULL END AS fio2, -- recorded as percentage
        FROM 
        `physionet-data.amsterdamdb.numericitems` 
        WHERE item IN('PO2 (bloed)','PO2','PO2 (bloed) - kPa','O2 concentratie (Set)','O2 concentratie','FiO2 %','SET %O2','A_FiO2','MCA_FiO2')
    ) pf
        ON d.admissionid = pf.admissionid
        AND pf.day BETWEEN d.startoffset AND d.endoffset
    GROUP BY d.admissionid, d.day
) pf_daily
ON d.admissionid = pf_daily.admissionid
AND d.day = pf_daily.day
LEFT JOIN (
    SELECT 
    d.admissionid,
    d.day,
    -- Circulatory
    -- Mean arterial pressure OR administration of vasopressors required	SOFA score
    -- MAP ≥ 70 mmHg	0
    -- MAP < 70 mmHg	+1
    -- dopamine ≤ 5 μg/kg/min or dobutamine (any dose)	+2
    -- dopamine > 5 μg/kg/min OR epinephrine ≤ 0.1 μg/kg/min OR norepinephrine ≤ 0.1 μg/kg/min	+3
    -- dopamine > 15 μg/kg/min OR epinephrine > 0.1 μg/kg/min OR norepinephrine > 0.1 μg/kg/min	+4
    CASE WHEN MIN(map) >= 70.0 THEN 0
        WHEN MIN(map) < 70.0 THEN 1
        WHEN MAX(dopamine_dose) <= 5.0 OR MAX(dobutamine_dose) IS NOT NULL THEN 2
        WHEN MAX(dopamine_dose) BETWEEN 6.0 AND 15.0 OR MAX(epinephrine_dose) <= 0.1 OR MAX(norepinephrine_dose) < 0.1 THEN 3
        WHEN MAX(dopamine_dose) > 15.0 OR MAX(epinephrine_dose) > 0.1 OR MAX(norepinephrine_dose) > 0.1 THEN 4
        ELSE NULL
        END as sofa_circ_score
    FROM daily d
    LEFT JOIN (
        SELECT 
        admissionid,
        measuredat/86400000 as day,
        CASE WHEN item IN('ABP gemiddeld','Niet invasieve bloeddruk gemiddeld','IABP Mean Blood Pressure') AND value > 20 THEN value ELSE NULL END AS map
        FROM `physionet-data.amsterdamdb.numericitems` 
        WHERE item IN('ABP gemiddeld','Niet invasieve bloeddruk gemiddeld','IABP Mean Blood Pressure')
    ) map_daily
        ON d.admissionid = map_daily.admissionid
        AND map_daily.day BETWEEN d.startoffset AND d.endoffset
    LEFT JOIN (
        SELECT 
        drug.admissionid,
        drug.start/86400000 as day,
        CASE WHEN item = 'Dopamine (Inotropin)' AND doseunit = 'mg' AND doserateunit = 'uur' THEN dose * 1000/(adm.weight*60) ELSE NULL END AS dopamine_dose,
        CASE WHEN item = 'Dobutamine (Dobutrex)' AND doseunit = 'mg' AND doserateunit = 'uur' THEN dose * 1000/(adm.weight*60) ELSE NULL END AS dobutamine_dose,
        CASE WHEN item = 'Noradrenaline (Norepinefrine)' AND doseunit = 'mg' AND doserateunit = 'uur' THEN dose * 1000/(adm.weight*60) ELSE NULL END AS epinephrine_dose,
        CASE WHEN item = 'Adrenaline (Epinefrine)' AND doseunit = 'mg' AND doserateunit = 'uur' THEN dose * 1000/(adm.weight*60) ELSE NULL END as norepinephrine_dose
        FROM `physionet-data.amsterdamdb.drugitems` drug 
        LEFT JOIN (
            SELECT
            admissionid,
            weight
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
                FROM (
                    SELECT 
                    a.admissionid,
                    ANY_VALUE(a.weightgroup) as weightgroup,
                    MAX(CASE WHEN n.item IN('PatiëntGewicht','Gewicht bij opname') THEN n.value ELSE NULL END) as weight
                    FROM `physionet-data.amsterdamdb.numericitems` n
                    LEFT JOIN `physionet-data.amsterdamdb.admissions` a
                    ON n.admissionid = a.admissionid
                    WHERE item IN('PatiëntGewicht','Gewicht bij opname')
                    GROUP BY a.admissionid
                )
            ) 
        ) adm
        ON drug.admissionid = adm.admissionid
        WHERE drug.item IN('Dopamine (Inotropin)','Dobutamine (Dobutrex)','Noradrenaline (Norepinefrine)','Adrenaline (Epinefrine)')
    ) vasopressors
        ON d.admissionid = vasopressors.admissionid
        AND vasopressors.day BETWEEN d.startoffset AND d.endoffset
    GROUP BY d.admissionid, d.day
) circ_daily
ON d.admissionid = circ_daily.admissionid
AND d.day = circ_daily.day
LEFT JOIN (
    SELECT
    d.admissionid,
    d.day,
    -- Liver
    -- Bilirubin (mg/dl) [μmol/L]	SOFA score
    -- < 1.2 [< 20]	0
    -- 1.2–1.9 [20-32]	+1
    -- 2.0–5.9 [33-101]	+2
    -- 6.0–11.9 [102-204]	+3
    -- > 12.0 [> 204]	+4
    -- units are in umol/L for amsterdamdb
    CASE WHEN MAX(bilirubin) < 20 THEN 0
        WHEN MAX(bilirubin) BETWEEN 20 AND 32 THEN 1
        WHEN MAX(bilirubin) BETWEEN 33 AND 101 THEN 2
        WHEN MAX(bilirubin) BETWEEN 102 AND 204 THEN 3
        WHEN MAX(bilirubin) > 204 THEN 4
        ELSE 0
        END AS sofa_liver_score
    FROM daily d
    LEFT JOIN (
        SELECT 
        admissionid,
        measuredat/86400000 as day,
        CASE WHEN item IN('Bilirubine (bloed)','Bili Totaal') THEN value END AS bilirubin
        FROM `physionet-data.amsterdamdb.numericitems`
        WHERE item IN('Bilirubine (bloed)','Bili Totaal')
        AND islabresult
    ) bil
        ON d.admissionid = bil.admissionid
        AND bil.day BETWEEN d.startoffset AND d.endoffset
    GROUP BY d.admissionid, d.day
) liver_daily
    ON d.admissionid = liver_daily.admissionid
    AND d.day = liver_daily.day
LEFT JOIN (
    SELECT
    d.admissionid,
    d.day,
    -- Hematology
    -- Platelets×103/μl	SOFA score
    -- ≥ 150	0
    -- < 150	+1
    -- < 100	+2
    -- < 50	+3
    -- < 20	+4
    CASE WHEN MIN(platelets) >= 150 THEN 0
        WHEN MIN(platelets) BETWEEN 100 AND 149 THEN 1
        WHEN MIN(platelets) BETWEEN 50 AND 99 THEN 2
        WHEN MIN(platelets) BETWEEN 20 AND 49 THEN 3
        WHEN MIN(platelets) BETWEEN 0 AND 20 THEN 4
        ELSE NULL
        END AS sofa_hematology_score 
    FROM daily d
    LEFT JOIN (
        SELECT 
        admissionid,
        measuredat/86400000 as day,
        value as platelets
        FROM `physionet-data.amsterdamdb.numericitems`
        WHERE item = "Thrombo's (bloed)" AND islabresult
    ) plt
        ON d.admissionid=plt.admissionid
        AND plt.day BETWEEN d.startoffset AND d.endoffset
    GROUP BY d.admissionid, d.day
) hematology_daily
    ON d.admissionid = hematology_daily.admissionid
    AND d.day = hematology_daily.day
LEFT JOIN (
    SELECT
    d.admissionid,
    d.day,
    -- Renal 
    -- Creatinine (mg/dl) [μmol/L] (or urine output)	SOFA score
    -- < 1.2 [< 110]	0
    -- 1.2–1.9 [110-170]	+1
    -- 2.0–3.4 [171-299]	+2
    -- 3.5–4.9 [300-440] (or < 500 ml/d)	+3
    -- > 5.0 [> 440] (or < 200 ml/d)	+4
    -- units in amsterdamdb are umol/L
    CASE WHEN MAX(creatinine) < 110 THEN 0
        WHEN MAX(creatinine) BETWEEN 110 AND 170 THEN 1
        WHEN MAX(creatinine) BETWEEN 171 AND 299 THEN 2
        WHEN MAX(creatinine) BETWEEN 300 AND 440 THEN 3
        WHEN MAX(creatinine) > 440 THEN 4
        ELSE NULL
        END AS sofa_renal_score
    FROM daily d
    LEFT JOIN (
        SELECT
        admissionid,
        measuredat/86400000 as day,
        value as creatinine
        FROM `physionet-data.amsterdamdb.numericitems`
        WHERE item = 'Kreatinine (bloed)' AND islabresult
    ) cr
        ON d.admissionid=cr.admissionid
        AND cr.day BETWEEN d.startoffset AND d.endoffset
    GROUP BY d.admissionid, d.day
) daily_renal
    ON d.admissionid=daily_renal.admissionid
    AND d.day=daily_renal.day
LEFT JOIN (
    SELECT 
    d.admissionid,
    d.day,
    MIN(hemoglobin) as hgb_min,
    MAX(trop) as trop_max,
    MAX(creatinine) as creatinine_max,
    MIN(ph) as ph_min,
    MAX(lactate) as lactate_max
    FROM daily d
    LEFT JOIN (
        SELECT
        admissionid,
        measuredat/86400000 as day,
        CASE WHEN item IN('Hb (bloed)','Hb(v.Bgs) (bloed)') THEN value ELSE NULL END AS hemoglobin,
        CASE WHEN item IN('TroponineT (bloed)','Troponine') THEN value ELSE NULL END AS trop,
        CASE WHEN item IN('Kreatinine (bloed)') THEN value ELSE NULL END AS creatinine,
        CASE WHEN item IN('pH (bloed)') THEN value ELSE NULL END AS ph,
        CASE WHEN item IN('Lactaat (bloed)') THEN value ELSE NULL END AS lactate
        FROM `physionet-data.amsterdamdb.numericitems`
        WHERE islabresult
    ) lab
        ON d.admissionid = lab.admissionid
        AND lab.day BETWEEN d.startoffset AND d.endoffset
    GROUP BY d.admissionid, d.day
) daily_labs
    ON d.admissionid=daily_labs.admissionid
    AND d.day=daily_labs.day
ORDER BY d.admissionid, d.day),

sofa_scores as (
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
        FROM sofa_table
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
    )) 
    
SELECT 
admissionid,
MAX(sofa_q.sofatotal_day1) as sofatotal_day1,
MAX(sofa_q.sofatotal_day2) as sofatotal_day2,
MAX(sofa_q.sofatotal_day3) as sofatotal_day3,
MAX(sofa_q.sofatotal_day4) as sofatotal_day4,
MAX(sofa_q.delta_sofa) AS delta_sofa
FROM sofa_q
GROUP BY sofa_q.admissionid
ORDER BY sofa_q.admissionid