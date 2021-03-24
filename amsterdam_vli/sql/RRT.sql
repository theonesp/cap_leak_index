-- RRT Patients --
SELECT 
        n.admissionid,
    CASE
        WHEN COUNT(*) > 0 THEN TRUE
        ELSE FALSE
    END AS renal_replacement_bool,
    MAX(n.value) AS renal_replacement_max_blood_flow
    FROM `physionet-data.amsterdamdb.numericitems` n
    WHERE n.itemid IN (
            10736, --Bloed-flow
            12460, --Bloedflow
            14850 --MFT_Bloedflow (ingesteld): Fresenius multiFiltrate blood flow
        )
        AND n.value > 0
    GROUP BY n.admissionid