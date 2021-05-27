-- Gets RRT Patients

SELECT DISTINCT stay_id FROM `physionet-data.mimic_derived.rrt` where dialysis_present = 1
