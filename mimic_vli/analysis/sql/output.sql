WITH outputfirst AS
(
    SELECT
    oe.icustay_id
    , oe.charttime
    ,DATETIME_DIFF(oe.charttime,
        INTIME,
        MINUTE) AS chartoffset
    , value AS amount
    from `physionet-data.mimiciii_derived.urine_output` oe
    LEFT JOIN
    `physionet-data.mimiciii_clinical.icustays`
    USING
    (icustay_id)
    ),
output2 AS (
SELECT
icustay_id,
chartoffset,
amount
from outputfirst
WHERE
chartoffset BETWEEN -6*60 AND 36*60
)
SELECT 
icustay_id,
sum(amount) as outputs_total
from output2
GROUP BY icustay_id
ORDER BY icustay_id