libname samproj '/folders/myfolders/BIOS 664/SamplingProject';
libname analysis '/folders/myfolders/BIOS 664/SamplingProject/Analysis';
** import schools list with weights and totals **;

data school_weight;
	set samproj.school_list_pps_final;
	rename college=School;
	length college $ 60;
	schoolnum=_N_;
	keep division total samplingweight college schoolnum;
run;

** import height data **;
FILENAME REFFILE 
	'/folders/myfolders/BIOS 664/SamplingProject/Analysis/FinalSample.xlsx';

PROC IMPORT DATAFILE=REFFILE DBMS=XLSX OUT=WORK.IMPORT replace;
	GETNAMES=YES;
RUN;

proc sort data=import;
	by school;
run;

** transpose height data to get player, school, division **;

proc transpose data=import out=heights_school;
	by school;
run;

** clean up transposed data **;

data heights_school;
	set heights_school;
	length school2 $ 60;

	/**if cmiss(of _all_) then delete;**/
	rename COL1=Height _NAME_=Player;
	school2=school;
	drop _LABEL_ school;
run;

** rename variables with new length **;

data heights_school;
	set heights_school;
	rename school2=school;
run;

data school_division;
	set import;
	keep school division;
run;

** sort for merging **;

proc sort data=heights_school;
	by school;
run;

proc sort data=school_weight;
	by school;
run;

** merge height and weights data and clean up data ** (remove missing, correct transpose vars, etc...);

data school_division_height;
	merge heights_school school_weight;
	by school;

	if cmiss(of _all_) then
		delete;

	if Player eq 'Division' then
		delete;

	if division eq 1 then
		SamplingWeight=9.00000;
	else if division eq 2 then
		SamplingWeight=8.97143;
	else if division eq 3 then
		SamplingWeight=8.97959;

	if division eq 1 then
		popcount=351;
	else if division eq 2 then
		popcount=314;
	else if division eq 3 then
		popcount=440;
run;

** sort datasets for merging **;

proc sort data=school_division_height;
	by school;
run;

proc sort data=school_weight;
	by school;
run;

** final merge **;

data analysis.final_data;
	merge school_division_height school_weight;
	by school;

	if height eq . then
		delete;
run;

** RETURN FROM SUDAAN **;

** analysis by strata (division) **;
ods pdf file='/folders/myfolders/BIOS 664/SamplingProject/Analysis/Results/PerDivisionResults.pdf'startpage=no;
proc surveymeans data=analysis.final_data mean stderr clm plots=none;
	var height;
	weight SamplingWeight;
	cluster school;
	where division=1;
run;

proc surveymeans data=analysis.final_data mean stderr clm plots=none;
	var height;
	weight SamplingWeight;
	cluster school;
	where division=2;
run;

proc surveymeans data=analysis.final_data mean stderr clm plots=none;
	var height;
	weight SamplingWeight;
	cluster school;
	where division=3;
run;

ods pdf close;