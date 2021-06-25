-- 86400000 day 1, 259200000 day 3
-- 129600000 day 1.5, 302400000 day 3.5
With intake as (SELECT d.admissionid,
round((sum(CASE
    WHEN (
      d.start <= 129600000
      AND d.stop >= 302400000
      AND d.fluidin <> 0
    ) THEN (((302400000- 129600000) / ((d.duration * 1000) * 60)) * d.fluidin)
    WHEN (
      d.start < 129600000
      AND d.stop > 129600000
      AND d.stop <= 302400000
      AND d.fluidin <> 0
    ) THEN (((d.stop - 129600000) / ((d.duration * 1000) * 60)) * d.fluidin)
    WHEN (
      d.start >= 129600000
      AND d.start < 302400000
      AND d.stop > 129600000
      AND d.stop <= 302400000
      AND d.fluidin <> 0
    ) THEN CASE
      WHEN (
        d.rate = 0
        AND d.dose <> 0
        AND d.solutionadministered <> 0
        AND d.duration = 1
      ) THEN round((d.solutionadministered),
        1
      )
      ELSE d.fluidin
    END
    WHEN (
      d.start >= 129600000
      AND d.start < 302400000
      AND d.stop > 302400000
      AND d.fluidin <> 0
    ) THEN (((302400000 - d.start) / ((d.duration * 1000) * 60)) * d.fluidin)
  END)),
  0
) AS fluidin_72
FROM `physionet-data.amsterdamdb.drugitems` AS d
WHERE d.iscontinuous = TRUE-- and ordercategory = "Infuus - Crystalloid"
group by d.admissionid),

output as(
SELECT num.admissionid,
round((
  sum(num.fluidout)), 0
) AS fluidout_72
FROM `physionet-data.amsterdamdb.numericitems` AS num
WHERE (
  num.fluidout <> 0
  AND num.fluidout IS NOT NULL
  AND num.measuredat >= 129600000
  AND num.measuredat < 302400000
)
group by num.admissionid)

SELECT
intake.admissionid,
fluidin_72,
fluidout_72,
ifnull(fluidin_72, 0) - ifnull(fluidout_72, 0) as fluid_balance_72
from
intake
left join
output on
intake.admissionid = output.admissionid
order by admissionid