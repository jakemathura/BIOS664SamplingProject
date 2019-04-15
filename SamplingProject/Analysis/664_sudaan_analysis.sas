libname analysis 'C:\Users\jakemath\Desktop\SamplingProject\Analysis\';

data school_division_height_totals;
	set analysis.final_data;
run;

proc print data=school_division_height_totals;
run;

proc descript data=school_division_height_totals filetype=sas design=wor notsorted;
	nest division schoolnum; /*stratification and cluster variables go here*/
	weight SamplingWeight;
	/*need to add a class variable?*/
	var height;
	totcnt _ZERO_ popcount; /*use to specify total population size for fpc adjustment*/
	print nsum="Sample Size" wsum="Est Pop Size" mean semean lowmean upmean; 
	/*print sample size, sum of weights, and estimates of mean, SE, and 95% CI for logsal*/
run;

proc surveymeans data = school_division_height_totals N = 1833 mean clm plots=none;
	stratum division;
	var height;
	weight SamplingWeight;
run;
