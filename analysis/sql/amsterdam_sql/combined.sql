---------------------------------------------------------------
-- Queries the capleakmaster table, applying exclusion criteria
---------------------------------------------------------------

WITH blood_colloid as (
    SELECT 
    admissionid
    FROM `physionet-data.amsterdamdb.drugitems`
    WHERE ordercategory IN('Infuus - Colloid','Infuus - Bloedproducten') --exclude patients who received colloids or blood products
    AND stop < 86400000 -- within first 24h
    AND dose IS NOT NULL
)
SELECT 
*
FROM `amsterdam-translation.amsterdam_custom.capleakmaster`
WHERE patientunitstayid IN ( --include: sepsis patients by search term sepsis in notes
    SELECT 
    DISTINCT(admissionid)
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE LOWER(item) LIKE '%sepsis%'
)
AND patientunitstayid NOT IN ( --exclude: any patient who had bleeding 
    SELECT 
    DISTINCT(admissionid)
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE LOWER(item) LIKE '%bloeding%'
    OR LOWER(item) LIKE '%bleed%'
    OR LOWER(item) LIKE '%hemorr%'
    OR LOWER(value) LIKE '%bloeding%'
    OR LOWER(value) LIKE '%bleed%'
    OR LOWER(value) LIKE '%hemorr%'
)
AND patientunitstayid NOT IN ( --exclude: any patients who receivedblood transfusions or blood infusions
    SELECT admissionid FROM blood_colloid
)
--exclude any missing CLI related variables
AND leaking_index IS NOT NULL
AND delta_sofa IS NOT NULL
