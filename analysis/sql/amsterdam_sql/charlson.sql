-------------------------------------------------------------
--  Description: Calculate Charlson Comorbidity Index
--  To do: add codes for cirrhosis, TIA and dementia
--
--Python code used to generate part of the query:
--components_list = [('mets','6'),('aids','6'),('stroke','2'),('renal','2'),('dm','1'),('cancer','2'),('leukemia','2'),('lymphoma','2'),('mi','1'),('chf','1'),('pvd','1'),('copd','1'),('ctd','1'),('pud','1')]
--for item,score in components_list:
--    print(f'MAX(CASE WHEN {item}_flag THEN {score} ELSE 0 END) as {item}_score,')
--print()
--combined_scores = ' + '.join([item+'_score' for item,_ in components_list])
--print(combined_scores)
--print()
--for item,_ in components_list:
--    print(f'LEFT JOIN {item} ')
--    print(f' ON a.admissionid = {item}.admissionid')
-------------------------------------------------------------

CREATE OR REPLACE TABLE  `amsterdam-translation.amsterdam_custom.charlson` AS (
WITH mets AS (
    SELECT 
    DISTINCT(a.admissionid),
    TRUE as mets_flag
    FROM `physionet-data.amsterdamdb.admissions` a
    LEFT JOIN `physionet-data.amsterdamdb.listitems` li
        ON a.admissionid = li.admissionid
    WHERE a.specialty IN('Heelkunde Oncologie', 'Heelkunde Longen/Oncologie', 'Oncologie Inwendig')
        OR li.value IN('HON - Heelkunde Oncologie', 'HLO - Heelkunde Longen/Oncologie', 'ONI - Oncologie Inwendig')
), aids AS (
    SELECT
    DISTINCT(fi.admissionid),
    TRUE as aids_flag
    FROM `physionet-data.amsterdamdb.freetextitems` fi
    LEFT JOIN `physionet-data.amsterdamdb.listitems` li
        ON fi.admissionid = li.admissionid
    WHERE fi.value IN('aids en verdere motivatie niet te lezen', 'Nee omdat: Bewezen HIV infectie',
                              'HIV Ag+As (bloed)', 'HIV blot (bloed)', 'HIV imm.blot (bloed)')
        OR li.value IN('Nee omdat: Bewezen HIV infectie')
), liver AS (
    SELECT
    DISTINCT(admissionid),
    TRUE as liver_flag
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE value IN('Non-operative genitourinary - Hepato-renal syndrome','Hepatorenaal syndroom','Hepato-renal syndrome',
                   'Non-operative Gastro-intestinal - Encephalopathy, hepatic','Encephalopathy, hepatic',
                   'Ascitespunctie','Non-operative Gastro-intestinal - Bleeding, GI from esophageal varices/portal hypertension',
                   'Bleeding, GI from esophageal varices/portal hypertension',
                   'Post-operative gastro-intestinal - Bleeding-variceal, surgery for (excluding vascular shuntingsee surgery for',
                   'Bleeding-variceal, surgery for (excluding vascular shuntingsee surgery for')
), stroke AS (
    SELECT 
    DISTINCT(admissionid),
    TRUE as stroke_flag
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE value IN('Non-operative neurologic - CVA, cerebrovascular accident/stroke',
                'CVA, cerebrovascular accident/stroke','Non-operative neurologic - CVA, cerebrovascular accident/stroke',
                   'Vasculair neurologisch','DMC_Neurologie_Vasculair neurologisch','D_Neurologie_Vasculair neurologisch')
), renal AS (
    SELECT
    DISTINCT(pi.admissionid),
    TRUE as renal_flag
    FROM `physionet-data.amsterdamdb.processitems` pi
    LEFT JOIN `physionet-data.amsterdamdb.listitems` li
        ON pi.admissionid = li.admissionid
    WHERE pi.item IN('Dialyselijn Femoralis' , 'Dialyselijn Jugularis', 'Dialyselijn Subclavia')
    OR li.value IN('Renal failure, acute', 'D_Interne Geneeskunde_Renaal', 'Renaal', 'Non-operatief Renaal',
                       'Non-operative genitourinary - Renal failure, acute', 'Dialyselijn Subclavia', 
                       'Dialyselijn', 'Graft for dialysis, insertion of', 
                       'Post-operative cardiovascular - Graft for dialysis, insertion of')
), dm as (
    SELECT
    DISTINCT(admissionid),
    TRUE as dm_flag
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE value IN('Non-operative metabolic - Diabetic hyperglycemic hyperosmolar nonketotic coma (HHNC)',
                              'Diabetic hyperglycemic hyperosmolar nonketotic coma (HHNC)',
                              'Diabetische keto-acidose', 'Non-operatief Metabolisme - Diabetische keto-acidose', 
                              'Non-operative metabolic - Diabetic ketoacidosis', 'Diabetic ketoacidosis')
), cancer AS (
    SELECT 
    DISTINCT(a.admissionid),
    TRUE as cancer_flag
    FROM `physionet-data.amsterdamdb.admissions` a
    LEFT JOIN `physionet-data.amsterdamdb.listitems` li
        ON a.admissionid = li.admissionid
    WHERE a.specialty IN('Heelkunde Oncologie', 'Heelkunde Longen/Oncologie', 'Oncologie Inwendig')
    OR li.value IN('HON - Heelkunde Oncologie', 'HLO - Heelkunde Longen/Oncologie', 'ONI - Oncologie Inwendig',
                       'Nee, omdat: Chemotherapie in de laatste 3 maanden gehad', 'Na halschirurgie/Radiotherapie',
                       'Operatief Neurologisch - Craniotomie voor neoplasma', 
                       'Post-operative neurologic - Neoplasm-cranial, surgery for (excluding transphenoidal)',
                       'Craniotomie voor neoplasma', 'Neoplasm-cranial, surgery for (excluding transphenoidal)',
                       'Operatief Respiratoir - Thoraxchirurgie voor respiratoir neoplasm', 
                       'Thoraxchirurgie voor respiratoir neoplasm','Respiratoir neoplasma', 
                       'Non-operatief Respiratoir - Respiratoir neoplasma', 'Operatief Renaal - Renaal neoplasma',
                       'Nefrectomie (neoplasma)', 'Post-operative neurologic - Neoplasm-spinal cord surgery or other related procedures',
                       'Renaal neoplasma', 'Non-operative neurologic - Neoplasm, neurologic', 
                       'Post-operative genitourinary - Cystectomy for neoplasm', 
                       'Post-operative genitourinary - Nephrectomy for neoplasm', 
                       'Neoplasm, neurologic’, ‘Nephrectomy for neoplasm',
                       'Cystectomy for neoplasm', 'Renal neoplasm, cancer', 'Gastro-intestinaal voor neoplasma', 
                       'Operatief Gastro-Intestinaal - Gastro-intestinaal voor neoplasma')
), leukemia AS (
    SELECT
    DISTINCT(fi.admissionid),
    TRUE as leukemia_flag
    FROM `physionet-data.amsterdamdb.freetextitems` fi
    LEFT JOIN `physionet-data.amsterdamdb.listitems` li
        ON fi.admissionid = li.admissionid
    WHERE fi.value IN('(Controle) leukemie', 'controle leukemnie', '(Controle) leukemie (AML)')
    OR li.value IN('Non-operative hematological - Leukemia, acute myelocytic',
                       'Non-operative hematological - Leukemia, acute lymphocytic',
                       'Non-operative hematological - Leukemia, chronic lymphocytic',
                       'Leukemia, acute myelocytic', 'Nee, omdat: Leukemie en maligne lymfomen',
                       'Leukemia, acute lymphocytic', 'Non-operative hematological - Leukemia, other',
                       'Non-operative hematological - Leukemia, chronic myelocytic',
                       'Leukemia, chronic lymphocytic', 'Leukemia, other', 'Leukemia, chronic myelocytic')
), lymphoma AS (
    SELECT 
    DISTINCT(fi.admissionid),
    TRUE as lymphoma_flag
    FROM `physionet-data.amsterdamdb.freetextitems` fi
    LEFT JOIN `physionet-data.amsterdamdb.listitems` li
        ON fi.admissionid = li.admissionid 
    WHERE fi.value IN('Controle Lymfoom')
    OR li.value IN ('Nee, omdat: Leukemie en maligne lymfomen',
                        'Non-operative hematological - Lymphoma, non-Hodgkins',
                        'Lymphoma, non-Hodgkins', 'Non-operative hematological - Lymphoma, Hodgkins',
                        'Lymphoma, Hodgkins', 'Lymphoma Hodgkins, surgery for (including staging)',
                        'Post-operative hematology - Lymphoma Hodgkins, surgery for (including staging)')
), mi AS (
    SELECT
    DISTINCT(admissionid),
    TRUE as mi_flag
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE value IN('Infarction, acute myocardial (MI), none of the above', 
                              'Non-operative cardiovascular - Infarction, acute myocardial (MI), NON Q Wave',
                              'Infarction, acute myocardial (MI), NON Q Wave', 
                              'Non-operative cardiovascular - Contusion, myocardial (include R/O)',
                              'Contusion, myocardial (include R/O)', 'Cardiovasculair - Myocard infarct',
                              'Angina pectoris/myocardinfarct', 'Non-operative cardiovascular - Infarction, acute myocardial (MI), ANTERIOR',
                              'Non-operative cardiovascular - Infarction, acute myocardial (MI), INFEROLATERAL',
                              'Infarction, acute myocardial (MI), ANTERIOR',
                              'Non-operative cardiovascular - Infarction, acute myocardial (MI), none of the above',
                              'Infarction, acute myocardial (MI), INFEROLATERAL',
                              'Infarction, acute myocardial (MI), none of the above',
                              'Non-operative cardiovascular - Infarction, acute myocardial (MI), NON Q Wave',
                              'Infarction, acute myocardial (MI), NON Q Wave',
                              'Non-operative cardiovascular - Contusion, myocardial (include R/O)',
                              'Contusion, myocardial (include R/O)',
                              'Cardiovasculair - Myocard infarct')
), chf AS (
    SELECT
    DISTINCT(admissionid),
    TRUE as chf_flag
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE value IN('Non-operatief Cardiovasculair - Congestief hart falen',
                  'Non-operative cardiovascular - CHF, congestive heart failure',
                  'Congestief hart falen', 'CHF, congestive heart failure')
), pvd AS (
    SELECT 
    DISTINCT(admissionid),
    TRUE as pvd_flag
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE value IN('Non-operative cardiovascular - Cardiovascular medical, other',
                              'Post-operative cardiovascular - Endarterectomy (other vessels)',
                              'PTCA (perifere vaten)')
), dem AS (
    SELECT 
    DISTINCT(admissionid),
    FALSE as dementia_flag
    FROM `physionet-data.amsterdamdb.listitems`
), copd AS (
    SELECT
    DISTINCT(admissionid),
    TRUE as copd_flag
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE value IN('NChronisch obstructieve longziekte', 'Non-operatief Respiratoir - Chronisch obstructieve longziekte')
), ctd AS (
    SELECT
    DISTINCT(admissionid),
    TRUE as ctd_flag
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE value IN('REU - Reumatologie', 'Arthritis, rheumatoid', 'Non-operative musculo-skeletal - Arthritis, rheumatoid')
), pud AS (
    SELECT
    DISTINCT(admissionid),
    TRUE as pud_flag
    FROM `physionet-data.amsterdamdb.listitems`
    WHERE value IN('Non-operative Gastro-intestinal - Ulcer disease, peptic', 'Ulcer disease, peptic')
), combined AS (
    SELECT 
    a.admissionid,
    MAX(CASE WHEN mets_flag THEN 6 ELSE 0 END) as mets_score,
    MAX(CASE WHEN aids_flag THEN 6 ELSE 0 END) as aids_score,
    MAX(CASE WHEN liver_flag THEN 1 ELSE 0 END) as liver_score,
    MAX(CASE WHEN stroke_flag THEN 2 ELSE 0 END) as stroke_score,
    MAX(CASE WHEN renal_flag THEN 2 ELSE 0 END) as renal_score,
    MAX(CASE WHEN dm_flag THEN 1 ELSE 0 END) as dm_score,
    MAX(CASE WHEN cancer_flag THEN 2 ELSE 0 END) as cancer_score,
    MAX(CASE WHEN leukemia_flag THEN 2 ELSE 0 END) as leukemia_score,
    MAX(CASE WHEN lymphoma_flag THEN 2 ELSE 0 END) as lymphoma_score,
    MAX(CASE WHEN mi_flag THEN 1 ELSE 0 END) as mi_score,
    MAX(CASE WHEN chf_flag THEN 1 ELSE 0 END) as chf_score,
    MAX(CASE WHEN pvd_flag THEN 1 ELSE 0 END) as pvd_score,
    MAX(CASE WHEN dementia_flag THEN 1 ELSE 0 END) as dem_score,
    MAX(CASE WHEN copd_flag THEN 1 ELSE 0 END) as copd_score,
    MAX(CASE WHEN ctd_flag THEN 1 ELSE 0 END) as ctd_score,
    MAX(CASE WHEN pud_flag THEN 1 ELSE 0 END) as pud_score,
    MAX(CASE WHEN a.agegroup LIKE '80+' THEN 4
            WHEN a.agegroup LIKE '70-79' THEN 3
            WHEN a.agegroup LIKE '60-69' THEN 2
            WHEN a.agegroup LIKE '50-59' THEN 1
            ELSE 0 END) AS age_score_charlson,
    FROM `physionet-data.amsterdamdb.admissions` a
    LEFT JOIN mets 
    ON a.admissionid = mets.admissionid
    LEFT JOIN aids 
    ON a.admissionid = aids.admissionid
    LEFT JOIN liver
    ON a.admissionid = liver.admissionid
    LEFT JOIN stroke 
    ON a.admissionid = stroke.admissionid
    LEFT JOIN renal 
    ON a.admissionid = renal.admissionid
    LEFT JOIN dm 
    ON a.admissionid = dm.admissionid
    LEFT JOIN cancer 
    ON a.admissionid = cancer.admissionid
    LEFT JOIN leukemia 
    ON a.admissionid = leukemia.admissionid
    LEFT JOIN lymphoma 
    ON a.admissionid = lymphoma.admissionid
    LEFT JOIN mi 
    ON a.admissionid = mi.admissionid
    LEFT JOIN chf 
    ON a.admissionid = chf.admissionid
    LEFT JOIN pvd 
    ON a.admissionid = pvd.admissionid
    LEFT JOIN dem 
    ON a.admissionid = dem.admissionid
    LEFT JOIN copd 
    ON a.admissionid = copd.admissionid
    LEFT JOIN ctd 
    ON a.admissionid = ctd.admissionid
    LEFT JOIN pud 
    ON a.admissionid = pud.admissionid
    GROUP BY a.admissionid
)
SELECT
*,
(mets_score + aids_score + liver_score + stroke_score + renal_score + dm_score + cancer_score + leukemia_score + lymphoma_score + mi_score + chf_score + pvd_score + dem_score + copd_score + ctd_score + pud_score + age_score_charlson) AS charlson_score
FROM combined
ORDER BY admissionid
)
