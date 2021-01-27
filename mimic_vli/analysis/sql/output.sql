WITH outputfirst AS
(
    SELECT
    oe.icustay_id
    , oe.charttime
    ,DATETIME_DIFF(oe.charttime,
        INTIME,
        MINUTE) AS chartoffset
    , ROUND(CASE
    WHEN oe.itemid = 227488 and oe.value > 0 then -1*oe.value
    WHEN oe.valueuom = 'L' THEN oe.value * 1000.0
    WHEN oe.valueuom = 'ml' THEN oe.value
    ELSE
    NULL END
  ) AS amount
    from `physionet-data.mimiciii_clinical.outputevents` oe
    LEFT JOIN
    `physionet-data.mimiciii_clinical.icustays`
    USING
    (icustay_id)
    WHERE itemid in
        (
        -- these are the most frequently occurring urine output observations in CareVue
        40055, -- "Urine Out Foley"
        43175, -- "Urine ."
        40069, -- "Urine Out Void"
        40094, -- "Urine Out Condom Cath"
        40715, -- "Urine Out Suprapubic"
        40473, -- "Urine Out IleoConduit"
        40085, -- "Urine Out Incontinent"
        40057, -- "Urine Out Rt Nephrostomy"
        40056, -- "Urine Out Lt Nephrostomy"
        40405, -- "Urine Out Other"
        40428, -- "Urine Out Straight Cath"
        40086,--	Urine Out Incontinent
        40096, -- "Urine Out Ureteral Stent #1"
        40651, -- "Urine Out Ureteral Stent #2"

        -- these are the most frequently occurring urine output observations in CareVue
        226559, -- "Foley"
        226560, -- "Void"
        226561, -- "Condom Cath"
        226584, -- "Ileoconduit"
        226563, -- "Suprapubic"
        226564, -- "R Nephrostomy"
        226565, -- "L Nephrostomy"
        226567, --	Straight Cath
        226557, -- R Ureteral Stent
        226558, -- L Ureteral Stent
        227488, -- GU Irrigant Volume In
        227489  -- GU Irrigant/Urine Volume Out
        )
    
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