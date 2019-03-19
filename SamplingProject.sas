/** Author: Jake Mathura **/
/** IMPORT SAMPLING FRAME **/
FILENAME dataset 
	'/folders/myfolders/BIOS 664/SamplingProject/BIOS664Samplingframe - Sheet1.csv';

PROC IMPORT DATAFILE=dataset DBMS=CSV OUT=WORK.school_list;
	GETNAMES=YES;
	GUESSINGROWS=32767;
RUN;

/** SELECT TEAMS WITH STRAT-PROP SEED = 664 **/
proc surveyselect data=school_list method=srs sampsize=123 out=school_list_pps 
		seed=664 stats;
	strata Division / alloc=proportional;
run;

/** ASSIGN 30/31 TEAMS PER GROUP MEMEBER **/
data school_list_pps_final;
	set school_list_pps;
	length Assignment $ 20;

	if _n_ >=1 and _n_ <=31 then
		Assignment="Jake";

	if _n_ >=32 and _n_ <=62 then
		Assignment="Alice";

	if _n_ >=63 and _n_ <=93 then
		Assignment="Megan";

	if _n_ >=94 and _n_ <=123 then
		Assignment="Sequoia";
run;

data school_list_pps_final_simple;
	set school_list_pps_final;
	keep division college assignment;
run;

proc freq data=school_list_pps_final;
	tables Division;
run;

/** OUTPUT AS EXCEL FILE **/
proc export 
  data=work.school_list_pps_final 
  dbms=xlsx 
  outfile='/folders/myfolders/BIOS 664/SamplingProject/Sample.xlsx'
  replace;
run;

proc export 
  data=work.school_list_pps_final_simple 
  dbms=xlsx 
  outfile='/folders/myfolders/BIOS 664/SamplingProject/Sample_Simple.xlsx'
  replace;
run;