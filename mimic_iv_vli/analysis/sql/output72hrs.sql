WITH outputfirst AS
(
    SELECT
    oe.stay_id
    , oe.charttime
    ,DATETIME_DIFF(oe.charttime,
        INTIME,
        MINUTE) AS chartoffset
    , urineoutput AS amount
    from `physionet-data.mimic_derived.urine_output` oe
    LEFT JOIN
    `physionet-data.mimic_icu.icustays`
    USING
    (stay_id)
    ),
output2 AS (
SELECT
stay_id,
chartoffset,
amount
from outputfirst
WHERE
chartoffset BETWEEN 36*60 AND 84*60
)
SELECT 
stay_id,
sum(amount) as outputs_total_72
from output2
GROUP BY stay_id
ORDER BY stay_id