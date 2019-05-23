/*****************
Creating date: 2019.05.17
Author: Xiaoyue Ma
Project: Computing club, 05/23
Last date of modification: 2019.05.23
****************/
ods html close;
ods html;

%let store =O:\Research\Research_share\Xiaoyue Ma\computing club\20190521_presentation\Data\;

/***************Boxplot*******************************************/
proc import datafile="&store.toothdat.csv" dbms=csv
out=toothdat replace;
run;

proc sgplot data=toothdat;
vbox len / category=dose boxwidth=0.8 transparency=0; *boxplot;
scatter  x=dose y=len / jitter transparency=0.1 abc
         markerattrs=(symbol=CircleFilled size=10) group=dose; *scatterplot;
yaxis offsetmax=0.1;
run;


/******************Violin plot*************************************/
proc kde data=toothdat;*calculate the densitiy for violin plot;
   univar len/out=test;
   by dose;
run;
data test;
set test;
mirror=-density;*mirror the value to make a bell shape;
run;
proc sort data=test;
by dose value;
run;
proc sgpanel data=test nocycleattrs;
  panelby dose / layout=columnlattice onepanel noborder colheaderpos=bottom;
  band y=value upper=density lower=mirror/ fill outline;
  rowaxis  grid; 
  colaxis display=none ;
run;
/*ref: https://blogs.sas.com/content/graphicallyspeaking/2012/10/30/violin-plots/#prettyPhoto*/

/**********************************Finish boxplot***********************************************************************/



/*******************************Bar graph***********************************************************************************/
proc import datafile="&store.mtdat.csv" dbms=csv
out=mtdat replace;
run;

axis1 value=(a=90);
proc gchart data=mtdat;
vbar type/type=sum discrete sumvar=mpg descending /*maxis=axis1*/ /*subgroup=cyl*/ space=1;
run;
/*****************************************************************************************/




/********Lollipop chart********************/

/*https://blogs.sas.com/content/graphicallyspeaking/2017/07/24/lollipop-charts/#prettyPhoto*/
proc sort data=mtdat;
by mpg;
run;
proc sgplot data=mtdat noautolegend noborder;
needle x=type y=mpg / group=cyl lineattrs=(thickness=2) baselineattrs=(thickness=0);
bubble x=type y=mpg size=mpg/bradiusmin=8 datalabel datalabelpos=center;
xaxis display=(nolabel noticks);
*yaxis offsetmin=0 display=(nolabel noticks noline) grid;
run;

/*ref: https://communities.sas.com/t5/Graphics-Programming/Lollipop-Chart-in-SAS/td-p/206316*/
data test;
set mtdat;
zero=0;
run;
proc sgpanel data=test ;
panelby cyl/ layout=rowlattice novarname uniscale=column sort=descending;
highlow y=type low=zero high=mpg / group=type;
scatter y=type x=mpg / group=type markerattrs=(symbol=circlefilled) markerchar=mpg;
colaxis offsetmin=0;
rowaxis display=(nolabel noticks) valueattrs=(size=6);
run;





/*******************Scatterplot**************************************************************/
proc sgplot data=mtdat;
reg  y=mpg x=wt /clm group=cyl clmtransparency=0.6 markerattrs=(size=5);
run;
proc sgplot data=mtdat;
loess y=mpg x=wt /clm group=cyl degree=1 markerattrs=(size=5) CLMTRANSPARENCY=0.6;
run;

/******************Ellipse**************************************************************/
/*ref: https://blogs.sas.com/content/iml/2014/07/21/add-prediction-ellipse.html*/
data test;
set mtdat;
if cyl="4" then do; mpg_4=mpg; wt_4=wt; end;
if cyl="6" then do; mpg_6=mpg; wt_6=wt; end;
if cyl="8" then do; mpg_8=mpg; wt_8=wt; end;
run;
proc sgplot data=test noautolegend;
scatter  y=mpg x=wt /group=cyl jitter;
ellipse y=mpg_4 x=wt_4 ;
ellipse y=mpg_6 x=wt_6 ;   
ellipse y=mpg_8 x=wt_8 /lineattrs=(pattern=dot) TRANSPARENCY=0.6;   
run;
/******************************************************************************************/



/***********K-M curve*********************************/
proc import datafile="&store.colon.csv" dbms=csv
out=colon replace;
run;

proc lifetest data=colon plot=survival(cl atrisk(outside) test);
time time*status(0); /*put the censor value in the bracket*/
   strata adhere/ test=logrank;
run;




