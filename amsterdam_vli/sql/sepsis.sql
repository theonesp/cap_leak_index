SELECT 
    DISTINCT(admissionid)
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE LOWER(item) LIKE '%sepsis%'