SELECT 
    DISTINCT(admissionid)
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE LOWER(item) LIKE '%bloeding%'
    OR LOWER(item) LIKE '%bleed%'
    OR LOWER(item) LIKE '%hemorr%'
    OR LOWER(value) LIKE '%bloeding%'
    OR LOWER(value) LIKE '%bleed%'
    OR LOWER(value) LIKE '%hemorr%'