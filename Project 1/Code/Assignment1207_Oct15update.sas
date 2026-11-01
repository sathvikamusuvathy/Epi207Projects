/*************************************************************************************************************************
REVISION HISTORY:
 Date        Author      Description of Change
 ----------- ----------  -------------------------------------
 2026-10-07  Viky        Initial upload
 2026-10-11  Viky        Updated to reflect 1) adding derived varibles;
 										    2) restrict cohort to those with asthma {A AND (B OR C)}
 										       a) ever diagnosed asthma YES
 										       b) currently has asthma YES
 										       c) hospital visit due to asthma in last 12 mo YES
 2026-10-13  Suki	     Added recoded soda consumption variable (4 cats), formats
 						 Added a code block for Table 1: weighted analysis
 2026-10-14  Sofia       Replaced OVRWT variable with RBMI (3 cats)
 2026-10-15  Rebekah	 Fixed a typo in line 64 Restricion criter: "784" -> "3784"
 						 Editted age format in line 148-9 to reflect actual age cutoffs in SRAGE_P1 variable 
 						 Added code blocks for Table 2: OR
 						 ****NEED TO DECIDE ON THE CORRECT OUTCOME VARIABLE
/*************************************************************************************************************************/
        
/*************************************************************************************************************************/
LIBNAME epi207 "/home/u64374363/EPI207";
OPTIONS NOFMTERR;
/*************************************************************************************************************************/       

DATA all;

	set epi207.adult11 (in=a) 
    	epi207.adult12 (in=b); ;
 	 
	array orig{80} rakedw1-rakedw80; /* original replicate weights */ 
	array fnw{160} fnwgt1-fnwgt160; /* new pooled replicate weights */ 

	fnwgt0 = rakedw0 / 2; /* pooled final weight */ 

      do i = 1 to 80; 
		if a then do; /* CHIS 2011 */ 
		fnw{i} = orig{i} / 2; fnw{i + 80} = rakedw0 / 2; 
           end; 
      	else if b then do; /* CHIS 2012 */ 
		fnw{i} = rakedw0 / 2; fnw{i + 80} = orig{i} / 2; 
           End;
      end; 

if a then year = 2011; 
else if b then year = 2012; 

drop i; 
run;

PROC FREQ DATA=all;
 TABLES year;
RUN;

PROC CONTENTS DATA=all;
RUN;

PROC FREQ DATA=all;
 TABLES SRAGE_P1 AHEDC_P1 SRSEX RACEHP2_P1 RBMI AB1 SMOKING / MISSING;
RUN;

PROC MEANS DATA=all N NMISS MEAN STD MIN MAX;
 VAR AE_SODA;
RUN;


/*After adding restriction criteria 
Restriction Criteria: 3784 were adults who had ever been diagnosed with asthma by a
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
    
    IF RBMI = 1 THEN RBMI_3Cat = 1;
    ELSE IF RBMI = 2 THEN RBMI_3Cat = 1;
    ELSE IF RBMI = 3 THEN RBMI_3cat = 2;
	ELSE IF RBMI = 4 THEN RBMI_3CAT = 3;

/* Recoding soda consumption for Table 1 */

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
		SODA_4cat = "Soda consumption (recoded)";
RUN;

/* Formats */

PROC FORMAT;

/*Revised the age format for the first 2 groups to reflect the actual cut-offs in SRAGE_PI variable
Before revision:
        1 = "18-24"
        2 = "25-34"*/

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

/* Soda consumption categories */

    VALUE sodafmt
        1 = "0 times/week"
        2 = "1 time/week"
        3 = "2 times/week"
        4 = "3+ times/week";

RUN;

/* Data Codebook*/
/* Original Variables */

PROC CONTENTS DATA=asthma(
    KEEP=SRAGE_P1
         AHEDC_P1
         SRSEX
         RACEDF_P1
         RBMI
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
           RBMI
           AB1
           SMOKING
           AB117
           AB17
           AB41
           AB40
           AH14
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

   /* Recoding outcome varible (AH14?)*/
DATA asthma_recode_t2;
    SET  asthma_recode;
        /*Hospital overnight/longer that is NOT for asthma/diabetes or heart disease*/
    AH14_2cat=.; 
    IF AH14 = 1 THEN AH14_2cat = 1;
    ELSE IF AH14 = 2 THEN AH14_2cat = 0;
    ELSE IF AH14 = -1 THEN AH14_2cat = .;
RUN;

   /* Testing other possible outcome variables*/

DATA asthma_recode_t2;
 SET  asthma_recode_t2;
    /*Hospital overnight/longer for HEART DISEASE*/
    AB117_2cat=.; 
    IF AB117 = 1 THEN AB117_2cat = 1;
    ELSE IF AB117 = 2 THEN AB117_2cat = 0;
    ELSE IF AB117 = -1 THEN AB117_2cat = .;
    
    /*Asthma episode/attack*/
    AB41_2cat=.; 
    IF AB41 = 1 THEN AB41_2cat = 1;
    ELSE IF AB41 = 2 THEN AB41_2cat = 0;
    ELSE IF AB41 = -1 THEN AB41_2cat = .;
    
    /*ER/urgent care visit. for ashtma*/
    AH13A_2cat=.; 
    IF AH13A = 1 THEN AH13A_2cat = 1;
    ELSE IF AH13A = 2 THEN AH13A_2cat = 0;
    ELSE IF AH13A = -1 THEN AH13A_2cat = .;
RUN;

PROC FREQ data=asthma_recode_t2;
TABLES AH14_2cat AB117_2cat  AB41_2cat  AH13A_2cat; 
RUN;

   /*Attempts to find the correct outcome varible*/

   /* Table2 OR among Females (Male=1 as reference)= 1.01*/
   /* Crude OR by SEX for each outcome variable:
 		AH14_2cat  = 1.55
 		AB117_2cat = 1.66
 		AB41_2cat  = 1.43
 		AH13A_2cat = 1.80*/

   /*None of them seem close enough to Table 2 OR, but I used 'AH14' for now*/

/*Crude OR*/

%MACRO crude(var);
PROC SURVEYLOGISTIC DATA = asthma_recode_t2
     VARMETHOD=JACKKNIFE;  
     WEIGHT rakedw0;   
     REPWEIGHTS fnwgt1-fnwgt160 / JKCOEFS=1;   
     CLASS &var (REF='1') / PARAM=REF;   
     MODEL AH14_2cat /*<-Insert outcome variable*/(EVENT='1') = &var;
     
RUN;
%MEND;

%crude (SRSEX);
%crude (SRAGE_5cat);
%crude (RACEDF_4cat);
%crude (RBMI_3cat);
%crude (AB1_2cat);
%crude (SMOKING_2cat);
%crude (SODA_4cat);

/*Crude OR according to education level (REF='4')*/

PROC SURVEYLOGISTIC DATA = asthma_recode_t2
     VARMETHOD=JACKKNIFE;  
     WEIGHT rakedw0;   
     REPWEIGHTS fnwgt1-fnwgt160 / JKCOEFS=1;   
     CLASS AHEDC_4cat (REF='4') / PARAM=REF;   
     MODEL AH14_2cat /*<-Insert outcome variable*/(EVENT='1') = AHEDC_4cat;
     
RUN;

/* Adjusted OR*/

  /*Multivariable logistic regression model adjusted for age, education, sex,
  race/ethnicity,weight status,smoking status,and self-rated health*/

PROC SURVEYLOGISTIC DATA = asthma_recode_t2
     VARMETHOD=JACKKNIFE;
     WEIGHT rakedw0;
     REPWEIGHTS fnwgt1-fnwgt160 / JKCOEFS=1;
     CLASS 
        SRAGE_5cat  (REF='1')
        AHEDC_4cat  (REF='4') 
        SRSEX       (REF='1')
        RACEDF_4cat (REF='1')
        RBMI_3cat   (REF='1')
        SMOKING_2cat(REF='1')
        AB1_2cat    (REF='1')
           / PARAM=REF;
     MODEL AH14_2cat (EVENT='1') = SRAGE_5cat AHEDC_4cat SRSEX RACEDF_4cat RBMI_3cat SMOKING_2cat AB1_2cat;
RUN;
