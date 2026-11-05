/***********************************************************************
Epi 207 Assignment 2
RQ:Among California adults 18-29, is low income (<200% FPL) associated
with current use of any non-cigarette tobacco/nicotine product (incl. e-cigarettes)?
Data: CHIS 2021-2025 adult, pooled
************************************************************************/
/* Assign library */
libname epi207 "path/to/chis/data";

options nofmterr;

/* Stack datasets and create pooled survey weights */

DATA all;
    SET epi207.adult21 (IN=a)
        epi207.adult22 (IN=b)
        epi207.adult23 (IN=c)
        epi207.adult24 (IN=d)
        epi207.adult25 (IN=e);

    /* Original 80 replicate weights */
    ARRAY orig{80} rakedw1-rakedw80;

    /* New 400 pooled replicate weights */
    ARRAY fnw{400} fnwgt1-fnwgt400;

    /* Pooled final weight */
    fnwgt0 = rakedw0 / 5;

    /* Initialize all 400 replicate weights */
    DO i = 1 TO 400;
        fnw{i} = rakedw0 / 5;
    END;

    /* Determine replicate weight offset by year */
    IF a THEN offset = 0;
    ELSE IF b THEN offset = 80;
    ELSE IF c THEN offset = 160;
    ELSE IF d THEN offset = 240;
    ELSE IF e THEN offset = 320;

    /* Assign year-specific replicate weights */
    DO i = 1 TO 80;
        fnw{i + offset} = orig{i} / 5;
    END;

    /* Create survey year variable */
    year = 2021 + offset/80;

    DROP i offset;

RUN;

/*Restrict to population: age 18-29*/
DATA ya;
 SET all;
 WHERE SRAGE_P1 IN (18, 26);
RUN;

/*Recodes*/
DATA ya_recode;
 SET ya;

 /*Exposure - low income (<200% FPL)*/
 IF POVLL IN (1,2) THEN POVLL_2CAT = 1;
 ELSE IF POVLL IN (3,4) THEN POVLL_2CAT = 2;
 ELSE POVLL_2CAT = .;

 /*Outcome - any current non-cig tobacco/nicotine use, incl. e-vape*/
 IF AC135_P1 IN (2,3) OR /*Smokeless tobacco*/
 AC137_P1 IN (2,3) OR /*Cigarillo/little cigar*/
 AC139_P1 IN (2,3) OR /*Big cigar*/
 AC141_P1 IN (2,3) OR /*Hookah*/
 ESMKCUR = 1 /*Current e-cig use*/

 THEN Noncigpro_recode = 1;
 ELSE IF AC135_P1 IN (1,-1) AND
 AC137_P1 IN (1,-1) AND
 AC139_P1 IN (1,-1) AND
 AC141_P1 IN (1,-1) AND
 ESMKCUR = 2
 THEN Noncigpro_recode = 2;
 ELSE Noncigpro_recode = .;

 /*Race/ethnicity*/
 IF RACEDF_P1 = 6 THEN RACEDF_4cat = 1;
 ELSE IF RACEDF_P1 = 5 THEN RACEDF_4cat = 2;
 ELSE IF RACEDF_P1 = 1 THEN RACEDF_4cat = 3;
 ELSE IF RACEDF_P1 IN (2,3,4,7,8) THEN RACEDF_4cat = 4;
 ELSE RACEDF_4cat = .;

 /*Education*/
 IF AHEDC_P1 IN (1,2,3) THEN AHEDC_3cat = 1;
 ELSE IF AHEDC_P1 IN (4,5,6) THEN AHEDC_3cat = 2;
 ELSE IF AHEDC_P1 IN (7,8,9) THEN AHEDC_3cat = 3;
 ELSE AHEDC_3cat = .;

 /*ACEs*/
 IF ACE_A = 1 THEN ACE_3cat = 1;
 ELSE IF ACE_A IN (2,3,4) THEN ACE_3cat = 2;
 ELSE IF ACE_A = 5 THEN ACE_3cat = 3;
 ELSE ACE_3cat = .;

 /*Serious psychological distress (mediator; Table 1 only)*/
 IF DSTRS30 = 1 THEN spd = 1;
 ELSE IF DSTRS30 = 2 THEN spd = 2;
 ELSE spd = .;

 /*Occupation (Table 1 only)*/
 IF OCCMAIN2 IN (1:4) THEN occ_5cat = 1;
 ELSE IF OCCMAIN2 = 5 THEN occ_5cat = 2;
 ELSE IF OCCMAIN2 IN (6,7) THEN occ_5cat = 3;
 ELSE IF OCCMAIN2 IN (8:13) THEN occ_5cat = 4;
 ELSE IF OCCMAIN2 IN (-1,14) THEN occ_5cat = 5;
 ELSE occ_5cat = .;
 LABEL POVLL_2CAT = "Low-income status (1=<200% FPL, 2=200%+ FPL)"
 Noncigpro_recode = "Non-cigarette nicotine product use incl. e-vape (1=Yes, 2=No)"
 RACEDF_4cat = "Race/ethnicity"
 AHEDC_3cat = "Education"
 ACE_3cat = "Adverse childhood experiences"
 spd = "Serious psychological distress"
 occ_5cat = "Occupation"
 year = "Survey year";
RUN;

/*Formats*/
PROC FORMAT;
 VALUE yesnofmt
 1 = "Yes"
 2 = "No";
 VALUE agefmt
 18 = "18-25"
 26 = "26-29";
 VALUE sexfmt
 1 = "Male"
 2 = "Female";
 VALUE racefmt
 1 = "NH White"
 2 = "NH Black" 
 3 = "Latino"
 4 = "NH Other";
 VALUE educfmt
 1 = "HS/GED or less"
 2 = "Some college"
 3 = "College or higher";
 VALUE ace3fmt
 1 = "0 ACEs"
 2 = "1-3 ACEs"
 3 = "4+ ACEs";
 VALUE ruralurbfmt
 1 = "Urban"
 2 = "Rural";
 VALUE fplfmt
 1 = "0-199% FPL"
 2 = "200% OR ABOVE FPL";
 VALUE occfmt
 1 = "Management/professional"
 2 = "Service"
 3 = "Sales/office"
 4 = "Construction/production/transport"
 5 = "Not working";
RUN;

/* Checks: recodes vs. originals, and missingness by year */
PROC FREQ DATA=ya_recode;
    TABLES
        POVLL*POVLL_2CAT
        RACEDF_P1*RACEDF_4cat
        AHEDC_P1*AHEDC_3cat
        ACE_A*ACE_3cat
        DSTRS30*spd
        OCCMAIN2*occ_5cat
        AC135_P1*AC137_P1*AC139_P1*AC141_P1*ESMKCUR*Noncigpro_recode
        / LIST MISSING;

    TABLES
        year*(Noncigpro_recode ACE_3cat spd POVLL_2CAT)
        / MISSING NOROW NOCOL NOPERCENT;
RUN;

/* Table 1: Variables and formats */
%LET t1vars =
    Noncigpro_recode
    SRAGE_P1
    SRSEX
    RACEDF_4cat
    AHEDC_3cat
    ACE_3cat
    UR_CLRT2
    occ_5cat
    spd
    year;

%LET t1fmts =
    POVLL_2CAT fplfmt.
    Noncigpro_recode yesnofmt.
    SRAGE_P1 agefmt.
    SRSEX sexfmt.
    RACEDF_4cat racefmt.
    AHEDC_3cat educfmt.
    ACE_3cat ace3fmt.
    UR_CLRT2 ruralurbfmt.
    occ_5cat occfmt.
    spd yesnofmt.;
/* Table 1: Overall */

PROC SURVEYFREQ DATA=ya_recode VARMETHOD=JACKKNIFE;
    WEIGHT fnwgt0;
    REPWEIGHTS fnwgt1-fnwgt400 / JKCOEFS=1;
    TABLES &t1vars / NOWT;
    FORMAT &t1fmts;
RUN;

/* Table 1: By exposure */
PROC SURVEYFREQ DATA=ya_recode VARMETHOD=JACKKNIFE;
    WEIGHT fnwgt0;
    REPWEIGHTS fnwgt1-fnwgt400 / JKCOEFS=1;
    TABLES POVLL_2CAT*(&t1vars) / ROW NOWT;
    FORMAT &t1fmts;
RUN;


/* TABLE 2: Logistic Regression */

/* Crude OR */
PROC SURVEYLOGISTIC DATA=ya_recode VARMETHOD=JACKKNIFE;
    WEIGHT fnwgt0;
    REPWEIGHTS fnwgt1-fnwgt400 / JKCOEFS=1;
    CLASS POVLL_2CAT (REF='2') / PARAM=REF;
    MODEL Noncigpro_recode (EVENT='1') = POVLL_2CAT;
RUN;


/* Adjusted OR */
PROC SURVEYLOGISTIC DATA=ya_recode VARMETHOD=JACKKNIFE;
    WEIGHT fnwgt0;
    REPWEIGHTS fnwgt1-fnwgt400 / JKCOEFS=1;
    CLASS
        POVLL_2CAT (REF='2')
        SRAGE_P1 (REF='18')
        SRSEX (REF='1')
        RACEDF_4cat (REF='1')
        AHEDC_3cat (REF='3')
        ACE_3cat (REF='1')
        UR_CLRT2 (REF='1')
        year (REF='2021')
        / PARAM=REF;

    MODEL Noncigpro_recode (EVENT='1') =
        POVLL_2CAT
        SRAGE_P1
        SRSEX
        RACEDF_4cat
        AHEDC_3cat
        ACE_3cat
        UR_CLRT2
        year;
RUN;


