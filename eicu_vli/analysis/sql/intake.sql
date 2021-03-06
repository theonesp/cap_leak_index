-- this query extracts all intake fluids from intakeoutput
With
  t1 AS (
  SELECT
    patientunitstayid,
    sum(cellvaluenumeric) as intakes_total
  FROM
    `physionet-data.eicu_crd.intakeoutput`
  WHERE
    intakeoutputoffset BETWEEN -6*60 AND 36*60
    AND LOWER (cellpath) LIKE '%intake%'
    AND cellvaluenumeric IS NOT NULL
--    AND ( LOWER (cellpath) LIKE '%crystalloids%'
 --   OR LOWER (cellpath) LIKE '%saline%'
 --   OR LOWER (cellpath) LIKE '%ringer%'
  --  OR LOWER (cellpath) LIKE '%ivf%'
 --   OR LOWER (cellpath) LIKE '% ns %' 
 --   OR LOWER (cellpath) LIKE '%colloid%')
      GROUP BY
      patientunitstayid),
    
    t2 as (
    SELECT
    patientunitstayid,
    sum(cellvaluenumeric) as outputs_total,
    FROM
    `physionet-data.eicu_crd.intakeoutput`
    WHERE
    intakeoutputoffset BETWEEN -6*60 AND 36*60
    AND cellvaluenumeric IS NOT NULL
    AND LOWER (cellpath) LIKE '%output%'
    GROUP BY
      patientunitstayid),
    
  reliable_fluid_data AS (
    -- This subqueryquery selects only patients coming from ICUs with reliable fluids data.
    -- This  query should be used every time fluids data is required on a given project.
  SELECT
    patientunitstayid
  FROM
    `physionet-data.eicu_crd.patient`
  WHERE
    hospitaldischargeyear = 2014
    AND hospitalid = 300
    AND wardid = 822
    OR hospitaldischargeyear = 2014
    AND hospitalid = 144
    AND wardid = 267
    OR hospitaldischargeyear = 2014
    AND hospitalid = 452
    AND wardid = 1074
    OR hospitaldischargeyear = 2014
    AND hospitalid = 338
    AND wardid = 841
    OR hospitaldischargeyear = 2014
    AND hospitalid = 155
    AND wardid = 362
    OR hospitaldischargeyear = 2014
    AND hospitalid = 183
    AND wardid = 431
    OR hospitaldischargeyear = 2014
    AND hospitalid = 300
    AND wardid = 829
    OR hospitaldischargeyear = 2014
    AND hospitalid = 142
    AND wardid = 290
    OR hospitaldischargeyear = 2014
    AND hospitalid = 188
    AND wardid = 445
    OR hospitaldischargeyear = 2014
    AND hospitalid = 167
    AND wardid = 413
    OR hospitaldischargeyear = 2014
    AND hospitalid = 171
    AND wardid = 335
    OR hospitaldischargeyear = 2014
    AND hospitalid = 165
    AND wardid = 402
    OR hospitaldischargeyear = 2014
    AND hospitalid = 416
    AND wardid = 1020
    OR hospitaldischargeyear = 2014
    AND hospitalid = 420
    AND wardid = 1026
    OR hospitaldischargeyear = 2014
    AND hospitalid = 176
    AND wardid = 376
    OR hospitaldischargeyear = 2014
    AND hospitalid = 445
    AND wardid = 1087
    OR hospitaldischargeyear = 2014
    AND hospitalid = 188
    AND wardid = 451
    OR hospitaldischargeyear = 2014
    AND hospitalid = 307
    AND wardid = 804
    OR hospitaldischargeyear = 2014
    AND hospitalid = 420
    AND wardid = 1039
    OR hospitaldischargeyear = 2014
    AND hospitalid = 143
    AND wardid = 259
    OR hospitaldischargeyear = 2014
    AND hospitalid = 167
    AND wardid = 408
    OR hospitaldischargeyear = 2014
    AND hospitalid = 420
    AND wardid = 1027
    OR hospitaldischargeyear = 2014
    AND hospitalid = 307
    AND wardid = 766
    OR hospitaldischargeyear = 2014
    AND hospitalid = 243
    AND wardid = 609
    OR hospitaldischargeyear = 2014
    AND hospitalid = 141
    AND wardid = 286
    OR hospitaldischargeyear = 2014
    AND hospitalid = 181
    AND wardid = 425
    OR hospitaldischargeyear = 2014
    AND hospitalid = 420
    AND wardid = 1029
    OR hospitaldischargeyear = 2014
    AND hospitalid = 416
    AND wardid = 1017
    OR hospitaldischargeyear = 2014
    AND hospitalid = 171
    AND wardid = 377
    OR hospitaldischargeyear = 2014
    AND hospitalid = 141
    AND wardid = 307
    OR hospitaldischargeyear = 2014
    AND hospitalid = 154
    AND wardid = 317
    OR hospitaldischargeyear = 2014
    AND hospitalid = 148
    AND wardid = 347
    OR hospitaldischargeyear = 2014
    AND hospitalid = 243
    AND wardid = 607
    OR hospitaldischargeyear = 2014
    AND hospitalid = 422
    AND wardid = 1025
    OR hospitaldischargeyear = 2014
    AND hospitalid = 345
    AND wardid = 876
    OR hospitaldischargeyear = 2014
    AND hospitalid = 148
    AND wardid = 347
    OR hospitaldischargeyear = 2014
    AND hospitalid = 243
    AND wardid = 607
    OR hospitaldischargeyear = 2014
    AND hospitalid = 422
    AND wardid = 1025
    OR hospitaldischargeyear = 2014
    AND hospitalid = 345
    AND wardid = 876
    OR hospitaldischargeyear = 2014
    AND hospitalid = 148
    AND wardid = 384
    OR hospitaldischargeyear = 2014
    AND hospitalid = 206
    AND wardid = 489
    OR hospitaldischargeyear = 2014
    AND hospitalid = 183
    AND wardid = 430
    OR hospitaldischargeyear = 2014
    AND hospitalid = 246
    AND wardid = 602
    OR hospitaldischargeyear = 2014
    AND hospitalid = 142
    AND wardid = 256
    OR hospitaldischargeyear = 2014
    AND hospitalid = 416
    AND wardid = 1021
    OR hospitaldischargeyear = 2014
    AND hospitalid = 165
    AND wardid = 337
    OR hospitaldischargeyear = 2014
    AND hospitalid = 188
    AND wardid = 434
    OR hospitaldischargeyear = 2014
    AND hospitalid = 420
    AND wardid = 1037
    OR hospitaldischargeyear = 2014
    AND hospitalid = 300
    AND wardid = 809
    OR hospitaldischargeyear = 2014
    AND hospitalid = 337
    AND wardid = 888
    OR hospitaldischargeyear = 2014
    AND hospitalid = 390
    AND wardid = 953
    OR hospitaldischargeyear = 2014
    AND hospitalid = 181
    AND wardid = 428
    OR hospitaldischargeyear = 2014
    AND hospitalid = 420
    AND wardid = 1032
    OR hospitaldischargeyear = 2014
    AND hospitalid = 171
    AND wardid = 386
    OR hospitaldischargeyear = 2014
    AND hospitalid = 244
    AND wardid = 608
    OR hospitaldischargeyear = 2014
    AND hospitalid = 175
    AND wardid = 417
    OR hospitaldischargeyear = 2014
    AND hospitalid = 142
    AND wardid = 285
    OR hospitaldischargeyear = 2014
    AND hospitalid = 176
    AND wardid = 391
    OR hospitaldischargeyear = 2014
    AND hospitalid = 154
    AND wardid = 394
    OR hospitaldischargeyear = 2014
    AND hospitalid = 252
    AND wardid = 622
    OR hospitaldischargeyear = 2014
    AND hospitalid = 188
    AND wardid = 464
    OR hospitaldischargeyear = 2014
    AND hospitalid = 140
    AND wardid = 261
    OR hospitaldischargeyear = 2014
    AND hospitalid = 248
    AND wardid = 619
    OR hospitaldischargeyear = 2014
    AND hospitalid = 171
    AND wardid = 364
    OR hospitaldischargeyear = 2014
    AND hospitalid = 420
    AND wardid = 1035
    OR hospitaldischargeyear = 2014
    AND hospitalid = 167
    AND wardid = 345
    OR hospitaldischargeyear = 2014
    AND hospitalid = 142
    AND wardid = 273
    OR hospitaldischargeyear = 2014
    AND hospitalid = 436
    AND wardid = 1053
    OR hospitaldischargeyear = 2014
    AND hospitalid = 312
    AND wardid = 814
    OR hospitaldischargeyear = 2014
    AND hospitalid = 157
    AND wardid = 369
    OR hospitaldischargeyear = 2014
    AND hospitalid = 440
    AND wardid = 1043
    OR hospitaldischargeyear = 2014
    AND hospitalid = 243
    AND wardid = 601
    OR hospitaldischargeyear = 2014
    AND hospitalid = 394
    AND wardid = 996
    OR hospitaldischargeyear = 2014
    AND hospitalid = 420
    AND wardid = 1032
    OR hospitaldischargeyear = 2015
    AND hospitalid = 140
    AND wardid = 261
    OR hospitaldischargeyear = 2015
    AND hospitalid = 141
    AND wardid = 286
    OR hospitaldischargeyear = 2015
    AND hospitalid = 141
    AND wardid = 307
    OR hospitaldischargeyear = 2015
    AND hospitalid = 142
    AND wardid = 273
    OR hospitaldischargeyear = 2015
    AND hospitalid = 142
    AND wardid = 285
    OR hospitaldischargeyear = 2015
    AND hospitalid = 142
    AND wardid = 290
    OR hospitaldischargeyear = 2015
    AND hospitalid = 143
    AND wardid = 259
    OR hospitaldischargeyear = 2015
    AND hospitalid = 144
    AND wardid = 267
    OR hospitaldischargeyear = 2015
    AND hospitalid = 148
    AND wardid = 347
    OR hospitaldischargeyear = 2015
    AND hospitalid = 148
    AND wardid = 384
    OR hospitaldischargeyear = 2015
    AND hospitalid = 154
    AND wardid = 317
    OR hospitaldischargeyear = 2015
    AND hospitalid = 154
    AND wardid = 394
    OR hospitaldischargeyear = 2015
    AND hospitalid = 155
    AND wardid = 362
    OR hospitaldischargeyear = 2015
    AND hospitalid = 157
    AND wardid = 369
    OR hospitaldischargeyear = 2015
    AND hospitalid = 165
    AND wardid = 337
    OR hospitaldischargeyear = 2015
    AND hospitalid = 165
    AND wardid = 402
    OR hospitaldischargeyear = 2015
    AND hospitalid = 167
    AND wardid = 345
    OR hospitaldischargeyear = 2015
    AND hospitalid = 167
    AND wardid = 408
    OR hospitaldischargeyear = 2015
    AND hospitalid = 167
    AND wardid = 413
    OR hospitaldischargeyear = 2015
    AND hospitalid = 171
    AND wardid = 335
    OR hospitaldischargeyear = 2015
    AND hospitalid = 171
    AND wardid = 377
    OR hospitaldischargeyear = 2015
    AND hospitalid = 175
    AND wardid = 417
    OR hospitaldischargeyear = 2015
    AND hospitalid = 176
    AND wardid = 376
    OR hospitaldischargeyear = 2015
    AND hospitalid = 176
    AND wardid = 391
    OR hospitaldischargeyear = 2015
    AND hospitalid = 180
    AND wardid = 427
    OR hospitaldischargeyear = 2015
    AND hospitalid = 181
    AND wardid = 425
    OR hospitaldischargeyear = 2015
    AND hospitalid = 181
    AND wardid = 428
    OR hospitaldischargeyear = 2015
    AND hospitalid = 183
    AND wardid = 430
    OR hospitaldischargeyear = 2015
    AND hospitalid = 183
    AND wardid = 431
    OR hospitaldischargeyear = 2015
    AND hospitalid = 184
    AND wardid = 429
    OR hospitaldischargeyear = 2015
    AND hospitalid = 188
    AND wardid = 434
    OR hospitaldischargeyear = 2015
    AND hospitalid = 188
    AND wardid = 445
    OR hospitaldischargeyear = 2015
    AND hospitalid = 188
    AND wardid = 451
    OR hospitaldischargeyear = 2015
    AND hospitalid = 188
    AND wardid = 464
    OR hospitaldischargeyear = 2015
    AND hospitalid = 199
    AND wardid = 491
    OR hospitaldischargeyear = 2015
    AND hospitalid = 202
    AND wardid = 498
    OR hospitaldischargeyear = 2015
    AND hospitalid = 206
    AND wardid = 489
    OR hospitaldischargeyear = 2015
    AND hospitalid = 209
    AND wardid = 506
    OR hospitaldischargeyear = 2015
    AND hospitalid = 243
    AND wardid = 601
    OR hospitaldischargeyear = 2015
    AND hospitalid = 243
    AND wardid = 607
    OR hospitaldischargeyear = 2015
    AND hospitalid = 243
    AND wardid = 609
    OR hospitaldischargeyear = 2015
    AND hospitalid = 244
    AND wardid = 608
    OR hospitaldischargeyear = 2015
    AND hospitalid = 246
    AND wardid = 602
    OR hospitaldischargeyear = 2015
    AND hospitalid = 248
    AND wardid = 619
    OR hospitaldischargeyear = 2015
    AND hospitalid = 252
    AND wardid = 611
    OR hospitaldischargeyear = 2015
    AND hospitalid = 252
    AND wardid = 622
    OR hospitaldischargeyear = 2015
    AND hospitalid = 252
    AND wardid = 628
    OR hospitaldischargeyear = 2015
    AND hospitalid = 253
    AND wardid = 613
    OR hospitaldischargeyear = 2015
    AND hospitalid = 300
    AND wardid = 772
    OR hospitaldischargeyear = 2015
    AND hospitalid = 300
    AND wardid = 809
    OR hospitaldischargeyear = 2015
    AND hospitalid = 300
    AND wardid = 822
    OR hospitaldischargeyear = 2015
    AND hospitalid = 300
    AND wardid = 829
    OR hospitaldischargeyear = 2015
    AND hospitalid = 300
    AND wardid = 831
    OR hospitaldischargeyear = 2015
    AND hospitalid = 312
    AND wardid = 814
    OR hospitaldischargeyear = 2015
    AND hospitalid = 338
    AND wardid = 840
    OR hospitaldischargeyear = 2015
    AND hospitalid = 338
    AND wardid = 841
    OR hospitaldischargeyear = 2015
    AND hospitalid = 345
    AND wardid = 876
    OR hospitaldischargeyear = 2015
    AND hospitalid = 383
    AND wardid = 983
    OR hospitaldischargeyear = 2015
    AND hospitalid = 384
    AND wardid = 991
    OR hospitaldischargeyear = 2015
    AND hospitalid = 388
    AND wardid = 962
    OR hospitaldischargeyear = 2015
    AND hospitalid = 390
    AND wardid = 953
    OR hospitaldischargeyear = 2015
    AND hospitalid = 390
    AND wardid = 966
    OR hospitaldischargeyear = 2015
    AND hospitalid = 416
    AND wardid = 1017
    OR hospitaldischargeyear = 2015
    AND hospitalid = 416
    AND wardid = 1020
    OR hospitaldischargeyear = 2015
    AND hospitalid = 416
    AND wardid = 1021
    OR hospitaldischargeyear = 2015
    AND hospitalid = 419
    AND wardid = 1030
    OR hospitaldischargeyear = 2015
    AND hospitalid = 420
    AND wardid = 1026
    OR hospitaldischargeyear = 2015
    AND hospitalid = 420
    AND wardid = 1027
    OR hospitaldischargeyear = 2015
    AND hospitalid = 420
    AND wardid = 1032
    OR hospitaldischargeyear = 2015
    AND hospitalid = 420
    AND wardid = 1035
    OR hospitaldischargeyear = 2015
    AND hospitalid = 420
    AND wardid = 1037
    OR hospitaldischargeyear = 2015
    AND hospitalid = 422
    AND wardid = 1025
    OR hospitaldischargeyear = 2015
    AND hospitalid = 428
    AND wardid = 1048
    OR hospitaldischargeyear = 2015
    AND hospitalid = 436
    AND wardid = 1053
    OR hospitaldischargeyear = 2015
    AND hospitalid = 440
    AND wardid = 1043
    OR hospitaldischargeyear = 2015
    AND hospitalid = 445
    AND wardid = 1087
    OR hospitaldischargeyear = 2015
    AND hospitalid = 452
    AND wardid = 1074 )
    
    SELECT
    *
    FROM
    t1
    LEFT JOIN 
    t2
    USING (patientunitstayid)
    INNER JOIN
    reliable_fluid_data
    USING (patientunitstayid)
    WHERE intakes_total IS NOT NULL
    ORDER BY patientunitstayid
    