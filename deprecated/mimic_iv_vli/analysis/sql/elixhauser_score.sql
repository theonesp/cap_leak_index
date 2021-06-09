-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

  -- This query extracts the final elixhauser score using a methods called "vanWalRaven", there are other options called and "SID30", and "SID29"
  -- More info about the vanWalRaven methodlogy below:
  -- Recently, van Walraven developed a weighted summary score (VW) based on the 30 comorbidities from the Elixhauser comorbidity system.
  -- One of the 30 comorbidities, cardiac arrhythmia, is currently excluded as a comorbidity indicator in administrative datasets such as the Nationwide Inpatient Sample (NIS),
  -- prompting us to examine the validity of the VW score and its use in the NIS.
  -- Recently, van Walraven developed a weighted summary score (VW) based on the 30 comorbidities from the Elixhauser comorbidity system. One of the 30 comorbidities
  --, cardiac arrhythmia, is currently excluded as a comorbidity indicator in administrative datasets such as the Nationwide Inpatient Sample (NIS)
  --, prompting us to examine the validity of the VW score and its use in the NIS.
  -- Ref.: A New Elixhauser-based Comorbidity Summary Measure to Predict In-Hospital Mortality
SELECT
  icustays.stay_id,
  MAX(elixhauser_vanwalraven) AS final_elixhauser_score
FROM
  `physionet-data.mimic_derived.elixhauser_quan_score`
JOIN
  `physionet-data.mimic_icu.icustays` icustays
USING
    (hadm_id)  
GROUP BY
  stay_id
