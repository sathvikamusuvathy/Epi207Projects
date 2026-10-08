
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