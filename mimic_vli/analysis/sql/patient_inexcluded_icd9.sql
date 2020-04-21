-- This query extracts the diagnosis string for bleeding from the table diagnosis.

SELECT
COUNT(DISTINCT icustay_id)
FROM `amsterdam-translation.amsterdam_custom.mimic_transfusion`
WHERE age >= 16
AND first_icu_stay = True
AND icustay_id NOT IN (
    SELECT 
    icustays.icustay_id
    FROM `physionet-data.mimiciii_clinical.diagnoses_icd` diagnoses_icd
    INNER JOIN `physionet-data.mimiciii_clinical.icustays` icustays
        ON diagnoses_icd.hadm_id=icustays.hadm_id
    WHERE icd9_code IN (
        --ref: https://www.bmj.com/content/bmj/suppl/2015/02/03/bmj.h246.DC1/junm020747.ww1_default.pdf
        --intracranial bleeding
        '430', --Subarachnoid
        '431', --intracerebral
        '4320', --other and unspecified intracranial bleeding
        '4321', --subdural
        '4329', --unspecified intracranial bleeding
        --upper gastrointestinal
        '5310', --acute gastric ulcer with bleeding without obstruction
        '5312', --acute gastric ulcer with bleeding and perforation without obstruction
        '5314', --chronic or unspecified gastric ulcer with bleeding without obstruction
        '5316', --chronic or unspecified gastric ulcer with bleeding and perforation without obstruction
        '5320', --acute duodenal ulcer with bleeding without obstruction
        '5322', --acute duodenal ulcer with bleeding and perforation without obstruction
        '5324', --chronic or unspecified duodenal ulcer with bleeding without obstruction
        '5326', --chronic or unspecified duodenal ulcer with bleeding and perforation without obstruction
        '5330', --acute peptic ulcer of unspecified site with bleeding without obstruction
        '5332', --acute peptic ulcer of unspecified site with bleeding and perforation without obstruction
        '5334', --chronic or unspecified peptic ulcer of unspecified site with bleeding without obstruction
        '5336', --chronic or unspecified peptic ulcer of unspecified site with bleeding and perforation without obstruction
        '5340', --acute gastrojejunal ulcer with bleeding without obstruction
        '5342', --acute gastrojejunal ulcer with bleeding and perforation without obstruction
        '5344', --chronic or unspecified gastrojejunal ulcer with bleeding without obstruction
        '5346', --chronic or unspecified gastrojejunal ulcer with bleeding and perforation without obstruction
        '5780', --hematemesis
        '5781', --blood in stool
        '5789', --bleeding of gastrointestinal tract unspecified
        --Lower GI
        '5693', --bleeding of rectum and anus
        --Other Bleeding
        '2878', --other unspecified hemorrhagic conditions
        '2879', --unspecified hemorrhagic conditions
        '5967', --bleeding into bladder wall
        '7848', --bleeding from throat 
        '5997', --hematuria, unspecified
        '6271', --postmenopausal bleeding
        '4590', --bleeding unspecified
        '7191', --hemarthrosis site unspecified 
        '7863', --hemoptysis, unspecified    
        '72992' --nontraumatic hematoma soft tissue
    )
    OR icd9_code LIKE '900%' --vessel injuries
    OR icd9_code LIKE '901%' --vessel injuries
    OR icd9_code LIKE '902%' --vessel injuries
    OR icd9_code LIKE '903%' --vessel injuries
    OR icd9_code LIKE '904%' --vessel injuries
)