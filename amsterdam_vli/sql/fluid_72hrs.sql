with drug as (
    SELECT 
    admissionid, 
    fluidin,
    ordercategory,
    stop/86400000 as stop
    FROM `physionet-data.amsterdamdb.drugitems`
    WHERE
    iscontinuous = false
),
all_days as (
    SELECT
    admissionid
    , 0 as endoffset
    , lengthofstay as startoffset
    , GENERATE_ARRAY(0, CAST(ceil(lengthofstay/24.0) AS INT64)) as days
   from `physionet-data.amsterdamdb.admissions`
),
numitems as (
    SELECT
    admissionid,
    item,
    value,
    fluidout,
    measuredat/86400000 as measuredat
    FROM  `physionet-data.amsterdamdb.numericitems`
),
daily as (
    SELECT
    admissionid
    , CAST(days AS INT64) as days
    , endoffset + days-1 as startoffset
    , endoffset + days as endoffset
    FROM all_days
    CROSS JOIN UNNEST(all_days.days) AS days
),
fluid as (
SELECT 
    fluidin_daily.admissionid,
    daily_fluid_in_72,
    daily_fluid_out_72,
    daily_fluid_in_72 - daily_fluid_out_72 AS totalFluid_72
    FROM  (
        SELECT 
        d.admissionid,
        d.days,
        SUM(dr.fluidin) as daily_fluid_in_72
        FROM daily d
        LEFT JOIN drug dr
        ON d.admissionid = dr.admissionid
        AND stop BETWEEN 1.5 AND 3.5-- 24h-72h
--        WHERE ordercategory = "Infuus - Crystalloid"
        GROUP BY d.admissionid, d.days
    ) fluidin_daily
    LEFT JOIN (
        SELECT
        d.admissionid,
        d.days,
        SUM(n.fluidout) as daily_fluid_out_72
        FROM daily d
        LEFT JOIN numitems n
        ON d.admissionid = n.admissionid
        AND measuredat BETWEEN 1.5 AND 3.5 -- 24h-72h
        GROUP BY d.admissionid, d.days
    ) fluidout_daily
    ON fluidin_daily.admissionid=fluidout_daily.admissionid
    )
    SELECT 
    --fluids in out
    admissionid,
    MAX(daily_fluid_in_72) as intakes_72,
    MAX(daily_fluid_out_72) as outputs_72,
    MAX(totalFluid_72) as totalFluid_72
    from fluid
    GROUP BY admissionid
    ORDER BY admissionid