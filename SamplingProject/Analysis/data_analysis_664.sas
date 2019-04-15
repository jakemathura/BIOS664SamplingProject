libname analysis 'C:\Users\jakemath\Desktop\SamplingProject\Analysis\';
libname samproj 'C:\Users\jakemath\Desktop\SamplingProject\';

data school_weight;
	set samproj.school_list_pps_final;
	rename college=School;
	length college $ 60;
	schoolnum = _N_;
	keep division total samplingweight college schoolnum;
run;

FILENAME REFFILE 
	'C:\Users\jakemath\Desktop\SamplingProject\Analysis\FinalSample.xlsx';

PROC IMPORT DATAFILE=REFFILE DBMS=XLSX OUT=WORK.IMPORT replace;
	GETNAMES=YES;
RUN;

proc sort data=import;
	by school;
run;

proc transpose data=import out=heights_school;
	by school;
run;

data heights_school;
	set heights_school;
	length school2 $ 60;
	
	/**if cmiss(of _all_) then delete;**/
	rename COL1=Height _NAME_=Player;
	school2 = school;
	drop _LABEL_ school;
run;

data heights_school;
	set heights_school;
	rename school2=school;
run;

data school_division;
	set import;
	keep school division;
run;

data school_division_height;
	merge heights_school school_weight;
	by school;

	if cmiss(of _all_) then
		delete;

	if Player eq 'Division' then
		delete;

	if division eq 1 then SamplingWeight = 9.00000;
	else if division eq 2 then SamplingWeight = 8.97143;
	else if division eq 3 then SamplingWeight = 8.97959;

	if division eq 1 then popcount = 351;
	else if division eq 2 then popcount = 314;
	else if division eq 3 then popcount = 440;
run;

proc sort data=school_division_height;
	by school;
run;
proc sort data=school_weight;
	by school;
run;

data analysis.final_data;
	merge school_division_height school_weight;
	by school;
	if height eq . then delete;
run;



