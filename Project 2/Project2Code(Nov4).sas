/* Replace this with our own folder name and user ID******************************************************************************
libname epi207 "/home/u64409551/EPI207_temp";
OPTIONS NOFMTERR;
/*************************************************************************************************************************/

/*Change of Plan: Use only 2025 data*/

/*Restrict to population*/
DATA evape;
    SET all;
    WHERE (SRAGE_P1 = 18 OR SRAGE_P1 = 26) AND ESMKCUR = 1;
RUN;

PROC CONTENTS data=evape;
RUN;

/*Recodes*/
DATA evape_recode;
	SET evape;
	
	/*Recode exposure - age first used e-vape*/
	IF 12 <= AC223 <= 19 THEN AC223_2CAT = 1;
	ELSE IF 20 <= AC223 <= 27 THEN AC223_2CAT = 2;
	ELSE AC223_2CAT = .;

	/*Recode outcome - nicotine pouch use excl. e-vape use*/
	IF 	    AC135_P1 in (2,3) OR 
	   		AC137_P1 in (2,3) OR 
	   		AC139_P1 in (2,3) OR 
	   		AC141_P1 in (2,3) OR 
	   		AC276 in (2:7) 
	THEN Noncigpro_excl_evape= 1;
				
	ELSE IF 
	   		AC135_P1 =1 AND 
			AC137_P1 =1 AND 
			AC139_P1 =1 AND 
			AC141_P1 =1 AND 
			AC276 =1 
	THEN Noncigpro_excl_evape = 2; 
	ELSE Noncigpro_excl_evape= .;
	
    /*Race/ethnicity*/
    IF RACEDF_P1 = 6 THEN RACEDF_4cat = 1;
    ELSE IF RACEDF_P1 = 5 THEN RACEDF_4cat = 2;
    ELSE IF RACEDF_P1 = 1 THEN RACEDF_4cat = 3;
    ELSE IF RACEDF_P1 IN (2,3,4,8) THEN RACEDF_4cat = 4;
    ELSE RACEDF_4cat = .;

	/*Education*/
	IF AHEDC_P1 IN (1,2) THEN AHEDC_4cat = 1;
    ELSE IF AHEDC_P1 = 3 THEN AHEDC_4cat = 2;
    ELSE IF AHEDC_P1 IN (4,5,6) THEN AHEDC_4cat = 3;
    ELSE IF AHEDC_P1 IN (7,8,9) THEN AHEDC_4cat = 4;
    ELSE AHEDC_4cat = .;

	LABEL AC223_2CAT = "Age first used e-vape (binary: 1=12-19 years, 2=20-27 years)"
	      NONCIGPRO_EXCL_EVAPE = "Non-cigarette Nicotine Product use excluding e-vape (binary: 1=Yes, 2=No)"
		  RACEDF_4cat = "Race/ethnicity"
		  AHEDC_4cat = "Education (recoded)";
		  
	/*More variables to be added*/	  
		  
RUN;

/*Checking*/
PROC FREQ data=evape_recode;
TABLES AC223_2cat Noncigpro_excl_evape RACEDF_4cat AHEDC_4cat; 
RUN;
	
	
/*Variable formats*/

PROC FORMAT;
	
	VALUE agevapefmt
        1 = "12-17"
        2 = "18-22"
        3 = "23-27";
        
    VALUE yesnofmt
    	1 = "Yes"
    	2 = "No";
    	
   	VALUE ecigfmt
   		1 = "Current E-Cigarette Smoker"
   		2 = "Not a Current E-Ciagarette Smoker";
   		
   	VALUE agefmt 
   		1 = "18-24"
   		2 = "25-34";
        
    VALUE sexfmt
        1 = "Male"
        2 = "Female";

    VALUE racefmt
        1 = "NH White"
        2 = "NH Black"
        3 = "Latino"
        4 = "NH Other";
        
    VALUE educfmt
        1 = "Below high school"
        2 = "High School/GED"
        3 = "Some college"
        4 = "College or higher";
    
    VALUE acefmt
    	1 = "0 ACE"
    	2 = "1 ACE"
    	3 = "2 ACE"
    	4 = "3 ACE"
    	5 = "4+ ACE";
    	
   	VALUE ruralurbfmt
   		1 = "Urban"
   		2 = "Rural";
   		
   	VALUE fplfmt
   		1 = "0-99% FPL"
   		2 = "100-199% FPL"
   		3 = "200-299% FPL"
   		4 = "300% FPL AND ABOVE";
   		
   VALUE nicconcfmt
   		1 = "I DON'T KNOW THE CONCENTRATION" 
		2 = "0 MG/ML OR 0% (NICOTINE-FREE)"
		3 = "1-12 MG/ML OR 0.1-1.2%"
		4 = "13-17 MG/ML OR 1.3-1.7%"
		5 = "18-24 MG/ML OR 1.8-2.4%"
		6 = "25-49 MG/ML OR 2.5-4.9%"
		7 = "50 MG/ML OR MORE OR 5% OR MORE";
    
    /*More variables to be added*/	
   	
RUN;


/*Table 1: Weighted means, N(%)*/

PROC SURVEYFREQ DATA=evape_recode
    VARMETHOD=JACKKNIFE;

    WEIGHT RAKEDW0;

    REPWEIGHTS RAKEDW1-RAKEDW80 / JKCOEFS=1;

    TABLES
       
        / CL;

    FORMAT
       ;

RUN;


/* TABLE 2: Logistic regression*/

/*Crude OR*/
%MACRO crude(var, ref=1);                                  
PROC SURVEYLOGISTIC DATA = evape_recode
     VARMETHOD=JACKKNIFE;  
     WEIGHT RAKEDW0;                                      
     REPWEIGHTS RAKEDW1-RAKEDW80 / JKCOEFS=1;   
     CLASS &var (REF="&ref") / PARAM=REF;                  
     MODEL Noncigpro_excl_evape (EVENT='1') = &var;
RUN;
%MEND;

%crude ();

                            
/* Adjusted OR*/
PROC SURVEYLOGISTIC DATA = evape_recode
     VARMETHOD=JACKKNIFE;
     WEIGHT fnwgt0;                                        
     REPWEIGHTS fnwgt1-fnwgt160 / JKCOEFS=1;
     CLASS 
        SRAGE_P1 (REF='1')
        /*More variables to be added*/	/                           
           / PARAM=REF;
     MODEL Noncigpro_excl_evape (EVENT='1') = SRAGE_P1 /*More variables to be added*/	 ;   
RUN;


