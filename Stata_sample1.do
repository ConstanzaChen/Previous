* set working directory
version 18
cd "C:\Users\Intro to Biostat\files"

*import dataset
import excel "Base_continuous_lite.xlsx", firstrow clear

//Age
*check for normality by Q-Q plot
gen Age_1 = Age if Treatment == "Enacidin"
gen Age_2 = Age if Treatment == "Placebo" 
qnorm Age
qnorm Age_1
qnorm Age_2

//Normal

*equality of variances
*H0: sigma2_Age_1 == sigma2_Age_2
*H1: sigma2_Age_1 != sigma2_Age_2
sdtest Age_1=Age_2

//p-value=0.1665>0.05, we cannot reject the null hypothesis. These two variables have equal variances. We perform student's t-test.

*H0: μ_Age_1 == μ_Age_2
*H1: μ_Age_1 != μ_Age_2
ttest Age_1==Age_2, unpaired

//The subject's age with Enacidin was found not to be significantly different from the subject's age with Placebo (p-value=0.9586>0.05)



//BMI
*check for normality
gen BMI_1 = BMI if Treatment == "Enacidin"
gen BMI_2 = BMI if Treatment == "Placebo" 
qnorm BMI
qnorm BMI_1
qnorm BMI_2

//Normal

*equality of variances
sdtest BMI_1=BMI_2

//p-value=0.2158>0.05, we cannot reject the null hypothesis. These two variables have equal variances. We perform student's t-test.

ttest BMI_1==BMI_2, unpaired

//The subject's BMI with Enacidin was found not to be significantly different from the subject's age with Placebo. (p-value=0.7872>0.05)



//TNFa
*check for normality
gen TNFa_1 = TNFa if Treatment == "Enacidin"
gen TNFa_2 = TNFa if Treatment == "Placebo" 
qnorm TNFa
qnorm TNFa_1
qnorm TNFa_2

//not normal, do log transformation

gen log_TNFa_1=log(TNFa) if Treatment == "Enacidin"
gen log_TNFa_2=log(TNFa) if Treatment == "Placebo"

qnorm log_TNFa_1
qnorm log_TNFa_2

//still not normal

*equality of variances
sdtest log_TNFa_1=log_TNFa_2

//p-value=0.8043>0.05, we cannot reject the null hypothesis. These two variables have equal variances. 

//We perform Unpaired Wilcoxon test.
*H0: P(TNFa_1 > TNFa_2) == 0.5
*H1: P(TNFa_1 > TNFa_2) != 0.5
ranksum TNFa, by(Treatment)

//p-value=0.1292>0.05, we cannot reject the null hypothesis. The subject's TNFa with Enacidin was found not to be significantly different from the subject's age with Placebo, that is, TNFa is considered equal in these two groups.
