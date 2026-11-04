/*************************************************************************************************************************/
libname epi207 "/home/u64374363/EPI207";
OPTIONS NOFMTERR;
/*************************************************************************************************************************/

/*Stack datasets from 2021-2025*/
/*'fnwgt' should be in total 80*5=400 columns for 5-year data*/

DATA all;
 SET epi207.adult21 (IN=a)
 	 epi207.adult22 (IN=b)
 	 epi207.adult23	(IN=c)
 	 epi207.adult24 (IN=d)
 	 epi207.adult25 (IN=e);
 	 
 ARRAY orig{80} rakedw1-rakedw80;
 ARRAY fnw{400} fnwgt1-fnwgt400;
 
 fnwgt0 = rakedw0 / 5;
 
 DO i = 1 TO 80;
 
 	IF a THEN DO;
 		fnw{i} = orig{i} / 5;
 		fnw{i + 80}  = rakedw0 / 5;
    fnw{i + 160} = rakedw0 / 5;
    fnw{i + 240} = rakedw0 / 5;
    fnw{i + 320} = rakedw0 / 5;
 		END;
	 ELSE IF b THEN DO;
 		fnw{i} = rakedw0 / 5;
 		fnw{i + 80}  = orig{i} / 5;
    fnw{i + 160} = rakedw0 / 5;
    fnw{i + 240} = rakedw0 / 5;
    fnw{i + 320} = rakedw0 / 5;
 		END;
 	 ELSE IF c THEN DO;
 		fnw{i} = rakedw0 / 5;
 		fnw{i + 80}  = rakedw0 / 5;
    fnw{i + 160} = orig{i} / 5;
    fnw{i + 240} = rakedw0 / 5;
    fnw{i + 320} = rakedw0 / 5;
 		END;
 	 ELSE IF d THEN DO;
 		fnw{i} = rakedw0 / 5;
 		fnw{i + 80}  = rakedw0 / 5;
    fnw{i + 160} = rakedw0 / 5;
    fnw{i + 240} = orig{i} / 5;
    fnw{i + 320} = rakedw0 / 5;
 		END;
 	 ELSE IF e THEN DO;
 		fnw{i} = rakedw0 / 5;
 		fnw{i + 80}  = rakedw0 / 5;
    fnw{i + 160} = rakedw0 / 5;
    fnw{i + 240} = rakedw0 / 5;
    fnw{i + 320} = orig{i} / 5;
 		END;
 	END;
 	
 	IF a THEN year = 2021;
 	ELSE IF b THEN year = 2022;
 	ELSE IF c THEN year = 2023;
 	ELSE IF d THEN year = 2024;
 	ELSE IF e THEN year = 2025;
 	
 DROP i;
 
RUN;

/*Restrict to population:*/
DATA evape;
    SET all;
    WHERE (SRAGE_P1 = 18 OR SRAGE_P1 = 26) AND ESMKCUR = 1;
RUN;

PROC SQL;
    SELECT COUNT(*) AS evape_sample_size
    FROM evape;
QUIT;

/*Recodes*/
DATA evape_recode;
	SET evape;
	
	/*Recode age first used e-vape:*/
	IF AC223 IN (12,17) THEN AC223_3CAT = 1;
	ELSE IF AC223 IN (18,22) THEN AC223_3CAT = 2;
	ELSE IF AC223 IN (23, 27) THEN AC223_3CAT = 3; 
	ELSE AC223_3CAT = .;
	
	/*Recode nicotine pouch use:*/
	IF AC276 IN (2,8) THEN AC276_2CAT = 1;
	ELSE IF AC276 = -2 OR 1 THEN AC276_2CAT = 2; /*Recode skipped as 'no'*/
	ELSE AC276_2CAT = .;
	
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
		
RUN;
