SELECT 
admissionid
FROM `physionet-data.amsterdamdb.drugitems`
WHERE (ordercategory = 'Infuus - Bloedproducten')
AND stop < 86400000 -- within first 24h
AND dose IS NOT NULL