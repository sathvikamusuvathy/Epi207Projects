/*************************************************************************************************************************/
LIBNAME epi207 "/home/u64374363/EPI207";
OPTIONS NOFMTERR;
/*************************************************************************************************************************/

DATA all; /*Stack datasets from 2021-2025*/
 SET epi207.adult21 epi207.adult22 epi207.adult23 epi207.adult21 epi207.adult24 epi207.adult25;
RUN;


DATA all;
 SET epi207.adult21 (IN=a)
 	 epi207.adult22 (IN=b)
 	 epi207.adult23	(IN=c)
 	 epi207.adult24 (IN=d)
 	 epi207.adult25 (IN=e);
 	 
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
 	 ELSE IF c THEN DO;
 		fnw{i} = rakedw0 / 2;
 		fnw{i + 80} = orig{i} / 2;
 		END;
 	 ELSE IF d THEN DO;
 		fnw{i} = rakedw0 / 2;
 		fnw{i + 80} = orig{i} / 2;
 		END;
 	 ELSE IF e THEN DO;
 		fnw{i} = rakedw0 / 2;
 		fnw{i + 80} = orig{i} / 2;
 		END;
 	END;
 	
 	IF a THEN year = 2021;
 	ELSE IF b THEN year = 2022;
 	ELSE IF c THEN year = 2023;
 	ELSE IF d THEN year = 2024;
 	ELSE IF e THEN year = 2025;
 	
 DROP i;
 
RUN;

/*Population:*/
DATA evape;
    SET all;
    WHERE (SRAGE_P1 = 18 OR SRAGE_P1 = 26) AND ESMKCUR = 1;
RUN;

PROC SQL;
    SELECT COUNT(*) AS evape_sample_size
    FROM evape;
QUIT;

PROC FREQ data=evape;
TABLES AC117V2;
WHERE AC117V2 NOT=-1;
RUN;
