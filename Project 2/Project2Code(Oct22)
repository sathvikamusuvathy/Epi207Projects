/*************************************************************************************************************************/
LIBNAME epi207 "/home/u64374363/EPI207";
OPTIONS NOFMTERR;
/*************************************************************************************************************************/

DATA all;
 SET epi207.adult25;
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
