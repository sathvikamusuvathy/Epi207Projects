LIBNAME epi "~/EPI207/Assignment 1";
OPTIONS NOFMTERR;

DATA all;
 SET epi.adult2011 (IN=a)
 	 epi.adult2012 (IN=b);
 	 
 ARRAY orig{80} rakedw1-rakedw80;
 ARRAY fnw{160} fnwgt1-fnwgt160;
 
 fnwgt0 = rakedw0 / 2;
 
 DO i = 1 TO 80;
 
 	IF a THEN DO;
 		fnw{i} = orig{i} / 2;
 		fnw{i + 80} = rakedw0 / 2;
 	END;
	 ELSE IF b THEN DO;
 		fnw{i} = rakedw0 / 2;
 		fnw{i + 80} = orig{i} / 2;
 		END;
 	END;
 	
 	IF a THEN year = 2011;
 	ELSE IF b THEN year = 2012;
 	
 DROP i;
 
RUN;

PROC FREQ DATA=all;
 TABLES year;
RUN;

PROC CONTENTS DATA=all;
RUN;

PROC FREQ DATA=all;
 TABLES SRAGE_P1 AHEDC_P1 SRSEX RACEHP2_P1 OVRWT AB1 SMOKING / MISSING;
RUN;

PROC MEANS DATA=all N NMISS MEAN STD MIN MAX;
 VAR AE_SODA;
RUN;

/*After adding restriction criteria 
Restriction Criteria: 784 were adults who had ever been diagnosed with asthma by a
doctor and who currently reported either that they still had asthma, or that they had asthma, 
or that they had suffered from an asthma attack in the last 12 months */ 

/*Restriction Criteria*/
DATA asthma;
    SET all;
    WHERE AB17 = 1 AND (AB40 = 1 OR AB41 = 1);
RUN;

PROC FREQ DATA=asthma;
    TABLES year AB17 AB40 AB41 / MISSING;
RUN;

PROC SQL;
    SELECT COUNT(*) AS Asthma_Sample_Size
    FROM asthma;
QUIT;

/*Recoding Variables*/

DATA asthma_recode;
    SET asthma;

    IF SRAGE_P1 = 18 THEN SRAGE_5cat = 1;
    ELSE IF SRAGE_P1 IN (26,30) THEN SRAGE_5cat = 2;
    ELSE IF SRAGE_P1 IN (35,40) THEN SRAGE_5cat = 3;
    ELSE IF SRAGE_P1 IN (45,50,55,60) THEN SRAGE_5cat = 4;
    ELSE IF SRAGE_P1 IN (65,70,75,80,85) THEN SRAGE_5cat = 5;
    ELSE SRAGE_5cat = .;

    IF AHEDC_P1 IN (1,2) THEN AHEDC_4cat = 1;
    ELSE IF AHEDC_P1 = 3 THEN AHEDC_4cat = 2;
    ELSE IF AHEDC_P1 IN (4,5,6) THEN AHEDC_4cat = 3;
    ELSE IF AHEDC_P1 IN (7,8,9) THEN AHEDC_4cat = 4;
    ELSE AHEDC_4cat = .;

    IF RACEDF_P1 = 6 THEN RACEDF_4cat = 1;
    ELSE IF RACEDF_P1 = 5 THEN RACEDF_4cat = 2;
    ELSE IF RACEDF_P1 = 1 THEN RACEDF_4cat = 3;
    ELSE IF RACEDF_P1 IN (2,3,4,8) THEN RACEDF_4cat = 4;
    ELSE RACEDF_4cat = .;

    IF AB1 IN (4,5) THEN AB1_2cat = 1;
    ELSE IF AB1 IN (1,2,3) THEN AB1_2cat = 2;
    ELSE AB1_2cat = .;

    IF SMOKING = 1 THEN SMOKING_2cat = 1;
    ELSE IF SMOKING IN (2,3) THEN SMOKING_2cat = 2;
    ELSE SMOKING_2cat = .;
    
    IF RBMI IN (1,2) THEN RBMI_3cat = 1;
    ELSE IF RBMI = 3 THEN RBMI_3cat = 2;
    ELSE IF RBMI = 4 THEN RBMI_3cat = 3;
    ELSE RBMI_3cat = .;

    IF AE_SODA = 0 THEN SODA_4cat = 1;
    ELSE IF AE_SODA = 1 THEN SODA_4cat = 2;
    ELSE IF AE_SODA = 2 THEN SODA_4cat = 3;
    ELSE IF AE_SODA >= 3 THEN SODA_4cat = 4;
    ELSE SODA_4cat = .;

    LABEL
        SRAGE_5cat = "Age (recoded)"
        AHEDC_4cat = "Education (recoded)"
        RACEDF_4cat = "Race/ethnicity"
        AB1_2cat = "Self-rated health_2cat"
        SMOKING_2cat = "Smoking status (recoded)"
        RBMI_3cat = "Weight status (recoded)"
        SODA_4cat = "Soda consumption (recoded)";;
RUN;


/* Formats */

PROC FORMAT;

    VALUE agefmt
        1 = "18-25"
        2 = "26-34"
        3 = "35-44"
        4 = "45-64"
        5 = "65 or older";

    VALUE educfmt
        1 = "Below high school"
        2 = "High School/GED"
        3 = "Some college"
        4 = "College or higher";

    VALUE racefmt
        1 = "NH White"
        2 = "NH Black"
        3 = "Latino"
        4 = "NH Other";

    VALUE healthfmt
        1 = "Poor or fair"
        2 = "Good-to-excellent";

    VALUE smokefmt
        1 = "Smoker"
        2 = "Non-smoker";

    VALUE sexfmt
        1 = "Male"
        2 = "Female";

    VALUE yesnofmt
        1 = "Yes"
        2 = "No";

    VALUE hospitalfmt
        -1 = "Inapplicable"
         1 = "Yes"
         2 = "No";
    VALUE rbmifmt
        1 = "Under or Normal Weight"
        2 = "Overweight"
        3 = "Obese";

    VALUE sodafmt
        1 = "0 times/week"
        2 = "1 time/week"
        3 = "2 times/week"
        4 = "3+ times/week";

RUN;


/* Original Variables */

PROC CONTENTS DATA=asthma(
    KEEP=SRAGE_P1
         AHEDC_P1
         SRSEX
         RACEDF_P1
         OVRWT
         AB1
         SMOKING
         AE_SODA
         AB117
         AB17
         AB41
         AB40
) VARNUM;
RUN;

PROC FREQ DATA=asthma;
    TABLES SRAGE_P1
           AHEDC_P1
           SRSEX
           RACEDF_P1
           OVRWT
           AB1
           SMOKING
           AB117
           AB17
           AB41
           AB40
           / MISSING;
RUN;

PROC MEANS DATA=asthma N NMISS MEAN STD MIN MAX;
    VAR AE_SODA;
RUN;


/* Recoded Variables */

PROC CONTENTS DATA=asthma_recode(
    KEEP=SRAGE_5cat
         AHEDC_4cat
         SRSEX
         RACEDF_4cat
         RBMI_3cat
         AB1_2cat
         SMOKING_2cat
         AE_SODA
         AB117
) VARNUM;
RUN;

PROC FREQ DATA=asthma_recode;
    TABLES SRAGE_5cat
           AHEDC_4cat
           SRSEX
           RACEDF_4cat
           RBMI_3cat
           AB1_2cat
           SMOKING_2cat
           AB117
           / MISSING;

    FORMAT
        SRAGE_5cat agefmt.
        AHEDC_4cat educfmt.
        SRSEX sexfmt.
        RACEDF_4cat racefmt.
        RBMI_3cat rbmifmt.
        AB1_2cat healthfmt.
        SMOKING_2cat smokefmt.
        AB117 hospitalfmt.;
RUN;

PROC MEANS DATA=asthma_recode N NMISS MEAN STD MIN MAX;
    VAR AE_SODA;
RUN;

PROC MEANS DATA=asthma_recode N NMISS;
    VAR SRAGE_5cat
        AHEDC_4cat
        SRSEX
        RACEDF_4cat
        RBMI_3cat
        AB1_2cat
        SMOKING_2cat
        AE_SODA
        AB117;
RUN;
/* TABLE 1: Weighted percentages and 95% confidence intervals */

PROC SURVEYFREQ DATA=asthma_recode
    VARMETHOD=JACKKNIFE;

    WEIGHT fnwgt0;

    REPWEIGHTS fnwgt1-fnwgt160 / JKCOEFS=1;

    TABLES
        SRAGE_5cat
        AHEDC_4cat
        SRSEX
        RACEDF_4cat
        RBMI_3cat
        AB1_2cat
        SMOKING_2cat
        SODA_4cat
        / CL;

    FORMAT
        SRAGE_5cat agefmt.
        AHEDC_4cat educfmt.
        SRSEX sexfmt.
        RACEDF_4cat racefmt.
        RBMI_3cat rbmifmt.
        AB1_2cat healthfmt.
        SMOKING_2cat smokefmt.
        SODA_4cat sodafmt.;

RUN;

/* TABLE 2: Logistic regression (outcome: hospital admission d/t asthma)*/
DATA asthma_recode_t2;
    SET asthma_recode;
    /* AH14 = -1: skipped because hospitalized for asthma/diabetes/heart disease.
       Exclude heart disease hospitalizations (AB117 = 1). */
    hosp = (AH14 = -1 AND AB117 NE 1);
RUN;

PROC FREQ DATA=asthma_recode_t2;
    TABLES hosp;                                           
RUN;

/*Crude OR*/

%MACRO crude(var, ref=1);                                  
PROC SURVEYLOGISTIC DATA = asthma_recode_t2
     VARMETHOD=JACKKNIFE;  
     WEIGHT fnwgt0;                                        
     REPWEIGHTS fnwgt1-fnwgt160 / JKCOEFS=1;   
     CLASS &var (REF="&ref") / PARAM=REF;                  
     MODEL hosp(EVENT='1') = &var;
RUN;
%MEND;

%crude (SRSEX);
%crude (SRAGE_5cat);
%crude (RACEDF_4cat);
%crude (RBMI_3cat);
%crude (AB1_2cat);
%crude (SMOKING_2cat, ref=2);                             
%crude (SODA_4cat);
%crude (AHEDC_4cat, ref=4);                               
/* Adjusted OR*/

  /*Multivariable logistic regression model: soda consumption, adjusted for age,
  education, sex, race/ethnicity, weight status, smoking status, and self-rated health*/

PROC SURVEYLOGISTIC DATA = asthma_recode_t2
     VARMETHOD=JACKKNIFE;
     WEIGHT fnwgt0;                                        
     REPWEIGHTS fnwgt1-fnwgt160 / JKCOEFS=1;
     CLASS 
        SRAGE_5cat  (REF='1')
        AHEDC_4cat  (REF='4') 
        SRSEX       (REF='1')
        RACEDF_4cat (REF='1')
        RBMI_3cat   (REF='1')
        SMOKING_2cat(REF='2')                              
        AB1_2cat    (REF='1')
        SODA_4cat   (REF='1')                              
           / PARAM=REF;
     MODEL hosp(EVENT='1') = SRAGE_5cat AHEDC_4cat SRSEX RACEDF_4cat RBMI_3cat 
                             SMOKING_2cat AB1_2cat SODA_4cat;   /* CHANGED: added soda */
RUN;

/*To update codebook and data dictionary*/
PROC FREQ DATA=asthma_recode_t2;
    TABLES hosp;
RUN;