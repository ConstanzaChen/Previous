version 18

cd "C:\Users\11208\Desktop\Intro to Biostat\files"

*Final

import excel using "ResponseFinal.xlsx", firstrow clear


**************table1*****************

/*install the estout package */
ssc install estout, replace

/*Summarize variables*/
estpost sum

/*1.Continuous variables: Age BMI*/
/*Test whether continuous variables satisfy the normal distribution*/

/*Shapiro_wilk test:
H0:data is normally distributed*
H1:data is not normally distributed*/

swilk Age if Response=="Yes"  //p=0.93>0.05, normal
swilk Age if Response=="No"   //p=0.22>0.05, normal

swilk BMI if Response=="Yes"  //p=0.78>0.05, normal
swilk BMI if Response=="No"   //p=0.97>0.05, normal

/*Then we test whether the variance of case group is equal to that of control group*/

sdtest Age, by(Response)  //p=0.27>0.05, t-test
sdtest BMI, by(Response)  //p=0.23>0.05, t-test

/*student's unpaired t-test:
H0:There is no significant difference between the means of the two independent groups*
H1:There is a significant difference between the means of the two independent groups*/

estpost ttest Age BMI, by(Response) 
esttab, cells("p(fmt(2))") nonumber 


/*2.Categorical variables*/
/*Create table for all categorical variables.*/
tab Race Response //chi-square test
tab Sex Response  //4x2 chi-square test
tab HistoryofCancer Response  //chi-square test
tab CVD Response //chi-square test
   

/*chi-square test:
H0:There is no association between the two categorical variables.*
H1:There is a significant association between the two categorical variables*/

tab Race Response, chi2 col
tab Sex Response, chi2 col
tab HistoryofCancer Response, chi2 col
tab CVD Response, chi2 col

/*combine into one table*/
ssc install table1_mc
table1_mc, by(Response) vars( ///
Age contn %9.2f \ ///
Race cat \ ///
BMI contn %9.2f \ ///
HistoryofCancer cat \ ///
Sex cat \ ///
CVD cat \ ///
) ///
onecol nospace pdp(4) total(after) sdleft("±") sdright("") ///
saving("Table 1.xlsx", replace)



*************regression******************

cap drop response_num
gen response_num=.
replace response_num=0 if Response=="No"
replace response_num=1 if Response=="Yes"

cap drop race_num
gen race_num=.
replace race_num=0 if Race=="White"
replace race_num=1 if Race=="Black"
replace race_num=2 if Race=="Hispanic"
replace race_num=3 if Race=="Other"

cap drop sex_num
gen sex_num=.
replace sex_num=0 if Sex=="F"
replace sex_num=1 if Sex=="M"

cap drop history_num
gen history_num=.
replace history_num=0 if HistoryofCancer=="No"
replace history_num=1 if HistoryofCancer=="Yes"

cap drop cvd_num
gen cvd_num=.
replace cvd_num=0 if CVD=="No"
replace cvd_num=1 if CVD=="Yes"

logistic response_num c.Age i.race_num c.BMI i.history_num i.sex_num##i.cvd_num

/*
Logistic regression                                     Number of obs =    921
                                                        LR chi2(9)    =  21.99
                                                        Prob > chi2   = 0.0089
Log likelihood = -570.98968                             Pseudo R2     = 0.0189

---------------------------------------------------------------------------------
   response_num | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
----------------+----------------------------------------------------------------
            Age |   1.003851   .0069964     0.55   0.581     .9902314    1.017658
                |
       race_num |
             1  |   .7721381   .1431161    -1.40   0.163     .5369383    1.110364
             2  |   1.201896    .236158     0.94   0.349     .8177413    1.766516
             3  |   1.090683   .2341418     0.40   0.686     .7160893     1.66123
                |
            BMI |   1.159766   .0863764     1.99   0.047     1.002248    1.342041
  1.history_num |   1.347618   .3288136     1.22   0.221     .8353661    2.173986
      1.sex_num |   .9327037   .1411603    -0.46   0.645     .6932955    1.254784
      1.cvd_num |   .4626751   .1416724    -2.52   0.012     .2538843    .8431726
                |
sex_num#cvd_num |
           1 1  |   1.003802   .4567294     0.01   0.993     .4114832     2.44875
                |
          _cons |   .0619283   .1088054    -1.58   0.113     .0019786    1.938273
---------------------------------------------------------------------------------
Note: _cons estimates baseline odds.
*/


logistic response_num c.Age i.race_num c.BMI i.history_num i.sex_num##i.cvd_num, coef


/*
Logistic regression                                     Number of obs =    921
                                                        LR chi2(9)    =  21.99
                                                        Prob > chi2   = 0.0089
Log likelihood = -570.98968                             Pseudo R2     = 0.0189

---------------------------------------------------------------------------------
   response_num | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
----------------+----------------------------------------------------------------
            Age |   .0038436   .0069696     0.55   0.581    -.0098166    .0175038
                |
       race_num |
             1  |  -.2585919   .1853504    -1.40   0.163    -.6218721    .1046883
             2  |      .1839   .1964879     0.94   0.349    -.2012093    .5690093
             3  |    .086804   .2146745     0.40   0.686    -.3339504    .5075584
                |
            BMI |   .1482186   .0744774     1.99   0.047     .0022455    .2941916
  1.history_num |   .2983385   .2439962     1.22   0.221    -.1798852    .7765623
      1.sex_num |  -.0696677   .1513453    -0.46   0.645     -.366299    .2269636
      1.cvd_num |  -.7707301   .3062028    -2.52   0.012    -1.370877   -.1705836
                |
sex_num#cvd_num |
           1 1  |   .0037953   .4549993     0.01   0.993     -.887987    .8955775
                |
          _cons |  -2.781778   1.756959    -1.58   0.113    -6.225353    .6617973
---------------------------------------------------------------------------------
*/

reg response_num c.Age i.race_num c.BMI i.history_num i.sex_num##i.cvd_num

estat vif

/*
estat vif     

    Variable |       VIF       1/VIF  
-------------+----------------------
         Age |      1.01    0.994682
    race_num |
          1  |      1.17    0.855924
          2  |      1.16    0.859437
          3  |      1.15    0.873187
         BMI |      1.01    0.990396
1.history_~m |      1.01    0.992124
   1.sex_num |      1.11    0.898606
   1.cvd_num |      1.83    0.545020
     sex_num#|
     cvd_num |
        1 1  |      1.92    0.520322
-------------+----------------------
    Mean VIF |      1.26
*/
//no multicolinearity




/*Report*/
/*We performed a logistic regression with response as dependent variable, and age, race, bmi, sex, history of cancer, cvd, and the interaction term between sex and CVD as independent variables. BMI and having CVD were found to be significantly associated with response (p-value<0.05).

Holding other factors constant, on average, one unit increase in BMI was found to be associated with an increase in odds of positive response by a factor of 1.16. This was a statistically significant association. (p-value=0.047)

Holding other factors constant, on average, one more person having cardiovascular disease was found to be associated with a decrease in odds of positive response by a factor of 0.46. This was a statistically significant association. (p-value=0.012)

Estimated logistic regression model: 
logit(Pr(Response= "Yes")) = - 3.04 + 0.004*Age - 0.26*1i[race_black] + 0.18*1i[race_hispanic] + 0.09*1i[race_other] + 0.15*BMI + 0.3*1i[history_yes] - 0.07*1i[male] - 0.77*1i[cvd_yes] + 0.004*1i[male*cvd_yes]
*/








