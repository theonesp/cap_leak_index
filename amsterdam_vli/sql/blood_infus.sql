SELECT 
admissionid
FROM `physionet-data.amsterdamdb.drugitems`
WHERE ordercategory IN('Infuus - Colloid','Infuus - Bloedproducten') --exclude patients who received colloids or blood products
AND stop < 86400000 -- within first 24h
AND dose IS NOT NULL