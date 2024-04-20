*---------------------------------------------------------
* EFC calculation
*---------------------------------------------------------
generat cpi_92 = 0.89420012
generat cpi_97 = 1.0229446
generat cpi_06 = 1.2848948

replace age_mom_born = . if age_mom_born<15
generat age_older_parent = age_mom_born+18

generat famIncAsTeenEFC = famIncAsTeen*1000/cpi_97

generat efc = .
replace efc = 0 if famIncAsTeenEFC<=(20000/cpi_06)

replace HHsize1997 = . if HHsize1997<1

* binned parental education for asset imputation
generat father_educ = 1 if ((Feduc>0 & Feduc<12) | Feduc==95)
replace father_educ = 2 if Feduc==12
replace father_educ = 3 if (Feduc>=13 & Feduc<16)
replace father_educ = 4 if (Feduc>=16 & Feduc<=20)

generat mother_educ = 1 if ((Meduc>0 & Meduc<12) | Meduc==95)
replace mother_educ = 2 if Meduc==12
replace mother_educ = 3 if (Meduc>=13 & Meduc<16)
replace mother_educ = 4 if (Meduc>=16 & Meduc<=20)

egen max_educ = rowmax(father_educ mother_educ)
tab max_educ, gen(educ_)
rename educ_2 hsgrad
rename educ_3 some_college
rename educ_4 college

* parents marital status
generat mar_status = 1 if (marriedSp1==1 | marriedSp2==1 | marriedSp3==1)
replace mar_status = 0 if mar_status==.

generat rp1997 = Relationship_HH_head if year==1997
bys ID (year): egen rel_par = mean(rp1997)
drop rp1997
generat married = 1 if mar_status==1 & rel_par==1
replace married = 1 if mar_status==1 & rel_par==6
replace married = 0 if mar_status==0
replace married = 0 if mar_status==1 & (rel_par==2 | rel_par==3 | rel_par==4 | rel_par==5 | rel_par==7 | rel_par==8 | rel_par==9 | rel_par==10) 

gen netWorthM=Family_net_worth1996/1000000
gen netWorthM_sq=netWorthM^2

gen lnfamIncAsTeenEFC=log(famIncAsTeenEFC)

gen real_income=IncomePvs/cpi

gen prev_college = prev_4yr | prev_2yr
tempfile pvinc
preserve
    collapse real_income, by(prev_FT prev_PT prev_college)
    replace real_income = 0 if prev_FT==0 & prev_PT==0 
    l
    ren real_income student_lag_income
    save `pvinc', replace
restore

merge m:1 prev_FT prev_PT prev_college using `pvinc', keep(match master) nogen
*HSV Average tax data
sort ID year
by ID: gen index=1 if _n==1
egen mean_income_pre=mean(famIncAsTeenEFC) if index==1
egen mean_income=mean(mean_income_pre)
gen share_m_income=famIncAsTeenEFC/mean_income
***************
gen lambda_m1=0.910
gen tau_m1=0.064
gen tax2_married_1_ch = 1-lambda_m1*(share_m_income)^(-tau_m1) if married==1 & HH_size_under_18==1
***************
gen lambda_m2=0.925
gen tau_m2=0.070
gen tax2_married_2_ch = 1-lambda_m2*(share_m_income)^(-tau_m2) if married==1 & HH_size_under_18==2
***************
gen lambda_m3=0.940
gen tau_m3=0.058
gen tax2_married_3_ch = 1-lambda_m3*(share_m_income)^(-tau_m3) if married==1 & HH_size_under_18>=3
***************
gen lambda_um1=0.926
gen tau_um1=0.042
gen tax2_unmarried_1_ch = 1-lambda_um1*(share_m_income)^(-tau_um1) if married==0 & HH_size_under_18==1
***************
gen lambda_um2=0.954
gen tau_um2=0.027
gen tax2_unmarried_2_ch = 1-lambda_um2*(share_m_income)^(-tau_um2) if married==0 & HH_size_under_18==2
***************
gen lambda_um3=0.965
gen tau_um3=0.021
gen tax2_unmarried_3_ch = 1-lambda_um3*(share_m_income)^(-tau_um3) if married==0 & HH_size_under_18>=3
***************
gen share_m_income_stud=student_lag_income/mean_income
gen lambda_um0=0.882
gen tau_um0=0.036
gen tax2_unmarried_0_ch = 1-lambda_um0*(share_m_income_stud)^(-tau_um0) 
replace tax2_unmarried_0_ch=0 if student_lag_income==0
************

***************
*ALL MARRIED, JUST TO CHECK
gen lambda_m_all=0.902
gen tau_m_all=0.036
gen tax2_married_all = 1-lambda_m_all*(share_m_income)^(-tau_m_all) if married==1
************

gen tax2_rate=tax2_married_1_ch
replace tax2_rate=tax2_married_2_ch if tax2_rate==.
replace tax2_rate=tax2_married_3_ch if tax2_rate==.
replace tax2_rate=tax2_unmarried_1_ch if tax2_rate==.
replace tax2_rate=tax2_unmarried_2_ch if tax2_rate==.
replace tax2_rate=tax2_unmarried_3_ch if tax2_rate==.

replace tax2_rate=0 if tax2_rate<0
replace tax2_unmarried_0_ch=0 if tax2_unmarried_0_ch<0

gen black_hsgrad=black*hsgrad
gen black_some_college=black*some_college
gen black_college=black*college

gen hispanic_hsgrad=hispanic*hsgrad
gen hispanic_some_college=hispanic*some_college
gen hispanic_college=hispanic*college

gen other = mixed
gen other_hsgrad=other*hsgrad
gen other_some_college=other*some_college
gen other_college=other*college

reg age_mom_born i.father_educ
predict age_mom_born_f, xb

reg age_mom_born i.mother_educ
predict age_mom_born_p, xb

replace age_mom_born = age_mom_born_p if mi(age_mom_born)
replace age_older_parent = age_mom_born_p +18 if mi(age_older_parent)
replace age_older_parent = age_mom_born_f +18 if mi(age_older_parent)

mdesc age_older_parent 
mdesc age_older_parent if ~anyFlag

reg netWorthM lnfamIncAsTeen black hispanic other hsgrad some_college college black_hsgrad black_some_college black_college hispanic_hsgrad hispanic_some_college hispanic_college other_hsgrad other_college other_some_college
estimates save ${clnloc}netw.ster, replace
predict netWorthM_p, xb

replace netWorthM = netWorthM_p if netWorthM==.
replace netWorthM_sq = netWorthM_p^2 if netWorthM_sq==.

mdesc netWorthM lnfamIncAsTeen black hispanic other hsgrad some_college college black_hsgrad black_some_college black_college hispanic_hsgrad hispanic_some_college hispanic_college other_hsgrad other_college other_some_college

// this next line comes from the estimated regression coefficients of "reg lnEFCassets c.netWorthM##c.netWorthM lnFamInc b1.race##b1.educlev" in "create_sipp.do"
gen log_assets =  4.677884+netWorthM*5.255093+netWorthM_sq*(-1.913535)+lnfamIncAsTeenEFC*0.3113251+black*(-0.1909873)+hispanic*(-0.348915)+other*(-0.8345145)+ ///
                  hsgrad*0.1705307+some_college*0.2982295+college*0.5590433+black_hsgrad*(-0.3508782)+black_some_college*(-0.3372525)+black_college*0.0192319+ ///
                  hispanic_hsgrad*0.3629062+hispanic_some_college*0.0815695+hispanic_college*(-0.0038466)+other_hsgrad*0.806685+other_some_college*0.8694467+ ///
                  other_college*0.7000476

mdesc log_assets netWorthM lnfamIncAsTeen black hispanic other hsgrad some_college college black_hsgrad black_some_college black_college hispanic_hsgrad hispanic_some_college hispanic_college other_hsgrad other_college other_some_college if ~anyFlag

gen assets_tot=exp(log_assets)/cpi_97

replace assets_tot=0 if famIncAsTeenEFC<50000/cpi_06

**********************
*Parental Contribution
**********************
*Assume that number HH_size_under_18 in college is equal to 1 but we could change this using the variable hh_size_under_18_97 (number of HH_size_under_18 under age 18 in 1997)
gen HH_size_under_18_in_college=1

gen allowance_1=0.0765*famIncAsTeenEFC if famIncAsTeenEFC<(94200/cpi_06)
replace allowance_1=0.0765*(94200/cpi_06) if famIncAsTeenEFC>=(94200/cpi_06)
gen allowance_2=tax2_rate*famIncAsTeenEFC
gen allowance_3=0.06*famIncAsTeenEFC
gen allowance_4=(10000/cpi_06)+HHsize1997*(3460/cpi_06)-HH_size_under_18*(2460/cpi_06)
gen allowance_5_pre=0.35*famIncAsTeenEFC
gen allowance_5=(3100/cpi_06) if allowance_5_pre>=(3100/cpi_06)
replace allowance_5=allowance_5_pre if allowance_5_pre<(3100/cpi_06)

gen tot_allowances=allowance_1+allowance_2+allowance_3+allowance_4+allowance_5 

gen available_parent_income=famIncAsTeenEFC-tot_allowances
replace available_parent_income=0 if available_parent_income<0

gen parent_assets=assets_tot/cpi_97
gen asset_protection=(1732/cpi_06)*(age_older_parent-23) 
replace asset_protection=asset_protection/2.3 if married==0
gen parent_contr_assets=(parent_assets-asset_protection)*0.12
replace parent_contr_assets=0 if parent_contr_assets<0

gen AAI_pre=parent_contr_assets+available_parent_income
gen AAI=0.32*AAI_pre if AAI_pre<=(26000/cpi_06)
replace AAI=0.47*AAI_pre if AAI_pre>(26000/cpi_06)

gen parent_contribution= AAI/HH_size_under_18


**********************
*Student Contribution
**********************

gen s_allowance_1=0.0765*student_lag_income if student_lag_income<(94200/cpi_06)
replace s_allowance_1=0.0765*(94200/cpi_06) if student_lag_income>=(94200/cpi_06)
gen s_allowance_2=tax2_unmarried_0_ch*student_lag_income
gen s_allowance_3=0.03*student_lag_income
gen s_tot_allowances=(2550/cpi_06)+s_allowance_1+s_allowance_2+s_allowance_3


gen available_student_income=student_lag_income-s_tot_allowances
replace available_student_income=0 if available_student_income<0

gen student_contr_assets=0

gen student_contr_income=0.5*available_student_income

gen student_contribution=student_contr_income+student_contr_assets

* Final EFC number
replace efc=parent_contribution+student_contribution if efc~=0


*---------------------------------------------------------
* Net cost of college (given EFC)
*---------------------------------------------------------
gen     net_cost_4yr = .
replace net_cost_4yr = 18966 if inrange(efc,0,405.303100585937)
replace net_cost_4yr = 19185.1 if inrange(efc,405.303100585937,822.078186035156)
replace net_cost_4yr = 19411.3 if inrange(efc,822.078186035156,1221.94873046875)
replace net_cost_4yr = 19627.9 if inrange(efc,1221.94873046875,1564.91296386718)
replace net_cost_4yr = 19813.9 if inrange(efc,1564.91296386718,1823.0068359375)
replace net_cost_4yr = 19954.3 if inrange(efc,1823.0068359375,2168.40991210937)
replace net_cost_4yr = 20141.4 if inrange(efc,2168.40991210937,2354.84375)
replace net_cost_4yr = 20242.1 if inrange(efc,2354.84375,2637.3212890625)
replace net_cost_4yr = 20395.7 if inrange(efc,2637.3212890625,2830.279296875)
replace net_cost_4yr = 20500.4 if inrange(efc,2830.279296875,3063.10009765625)
replace net_cost_4yr = 20626.7 if inrange(efc,3063.10009765625,3282.6748046875)
replace net_cost_4yr = 20745.6 if inrange(efc,3282.6748046875,3503.779296875)
replace net_cost_4yr = 20865.3 if inrange(efc,3503.779296875,3661.20849609375)
replace net_cost_4yr = 20951.2 if inrange(efc,3661.20849609375,3825.427734375)
replace net_cost_4yr = 21039.8 if inrange(efc,3825.427734375,3985.17944335937)
replace net_cost_4yr = 21126.6 if inrange(efc,3985.17944335937,4184.78125)
replace net_cost_4yr = 21234.8 if inrange(efc,4184.78125,4370.8671875)
replace net_cost_4yr = 21335.5 if inrange(efc,4370.8671875,4557.115234375)
replace net_cost_4yr = 21437 if inrange(efc,4557.115234375,4729.46923828125)
replace net_cost_4yr = 21530.2 if inrange(efc,4729.46923828125,4905.13818359375)
replace net_cost_4yr = 21625.5 if inrange(efc,4905.13818359375,5071.37060546875)
replace net_cost_4yr = 21715.6 if inrange(efc,5071.37060546875,5194.51220703125)
replace net_cost_4yr = 21782.5 if inrange(efc,5194.51220703125,5374.283203125)
replace net_cost_4yr = 21880 if inrange(efc,5374.283203125,5553.9658203125)
replace net_cost_4yr = 21976.9 if inrange(efc,5553.9658203125,5736.57885742187)
replace net_cost_4yr = 22076.3 if inrange(efc,5736.57885742187,5878.37451171875)
replace net_cost_4yr = 22153.4 if inrange(efc,5878.37451171875,6005.994140625)
replace net_cost_4yr = 22222.1 if inrange(efc,6005.994140625,6133.2353515625)
replace net_cost_4yr = 22291.6 if inrange(efc,6133.2353515625,6344.32275390625)
replace net_cost_4yr = 22406.1 if inrange(efc,6344.32275390625,6462.888671875)
replace net_cost_4yr = 22469.8 if inrange(efc,6462.888671875,6671.2373046875)
replace net_cost_4yr = 22583.2 if inrange(efc,6671.2373046875,6868.8974609375)
replace net_cost_4yr = 22690 if inrange(efc,6868.8974609375,7012.421875)
replace net_cost_4yr = 22768.1 if inrange(efc,7012.421875,7181.83837890625)
replace net_cost_4yr = 22859.7 if inrange(efc,7181.83837890625,7355.22998046875)
replace net_cost_4yr = 22954.3 if inrange(efc,7355.22998046875,7574.85400390625)
replace net_cost_4yr = 23073.1 if inrange(efc,7574.85400390625,7794.40234375)
replace net_cost_4yr = 23192.5 if inrange(efc,7794.40234375,8036.275390625)
replace net_cost_4yr = 23323.7 if inrange(efc,8036.275390625,8278.0703125)
replace net_cost_4yr = 23454.8 if inrange(efc,8278.0703125,8500.205078125)
replace net_cost_4yr = 23575.1 if inrange(efc,8500.205078125,8713.158203125)
replace net_cost_4yr = 23690.6 if inrange(efc,8713.158203125,8953.9599609375)
replace net_cost_4yr = 23820.9 if inrange(efc,8953.9599609375,9244.095703125)
replace net_cost_4yr = 23978.6 if inrange(efc,9244.095703125,9545.515625)
replace net_cost_4yr = 24141.9 if inrange(efc,9545.515625,9876.1103515625)
replace net_cost_4yr = 24321.5 if inrange(efc,9876.1103515625,10170.9404296875)
replace net_cost_4yr = 24480.8 if inrange(efc,10170.9404296875,10493.701171875)
replace net_cost_4yr = 24655.8 if inrange(efc,10493.701171875,10725.28515625)
replace net_cost_4yr = 24781.7 if inrange(efc,10725.28515625,11085.814453125)
replace net_cost_4yr = 24977.1 if inrange(efc,11085.814453125,11408.5522460937)
replace net_cost_4yr = 25152 if inrange(efc,11408.5522460937,11757.89453125)
replace net_cost_4yr = 25341.7 if inrange(efc,11757.89453125,11993.751953125)
replace net_cost_4yr = 25469.3 if inrange(efc,11993.751953125,12310.1484375)
replace net_cost_4yr = 25641.6 if inrange(efc,12310.1484375,12605.6259765625)
replace net_cost_4yr = 25801.2 if inrange(efc,12605.6259765625,12959.626953125)
replace net_cost_4yr = 25993.2 if inrange(efc,12959.626953125,13322.759765625)
replace net_cost_4yr = 26190.1 if inrange(efc,13322.759765625,13642.462890625)
replace net_cost_4yr = 26363.6 if inrange(efc,13642.462890625,14000.1708984375)
replace net_cost_4yr = 26548.6 if inrange(efc,14000.1708984375,14404.3994140625)
replace net_cost_4yr = 26750.7 if inrange(efc,14404.3994140625,14808.23828125)
replace net_cost_4yr = 26952.9 if inrange(efc,14808.23828125,15102.2509765625)
replace net_cost_4yr = 27099.8 if inrange(efc,15102.2509765625,15429.140625)
replace net_cost_4yr = 27263.1 if inrange(efc,15429.140625,15815.296875)
replace net_cost_4yr = 27456.2 if inrange(efc,15815.296875,16225.3193359375)
replace net_cost_4yr = 27661.1 if inrange(efc,16225.3193359375,16585.048828125)
replace net_cost_4yr = 27841.1 if inrange(efc,16585.048828125,16876.72265625)
replace net_cost_4yr = 27986.6 if inrange(efc,16876.72265625,17187.19921875)
replace net_cost_4yr = 28142.1 if inrange(efc,17187.19921875,17510.40234375)
replace net_cost_4yr = 28303.7 if inrange(efc,17510.40234375,17883.107421875)
replace net_cost_4yr = 28490.1 if inrange(efc,17883.107421875,18246.21484375)
replace net_cost_4yr = 28671.6 if inrange(efc,18246.21484375,18620.40234375)
replace net_cost_4yr = 28858.4 if inrange(efc,18620.40234375,18944.01171875)
replace net_cost_4yr = 29020.7 if inrange(efc,18944.01171875,19307.21484375)
replace net_cost_4yr = 29202.2 if inrange(efc,19307.21484375,19806.55078125)
replace net_cost_4yr = 29451.6 if inrange(efc,19806.55078125,20232.8818359375)
replace net_cost_4yr = 29664.5 if inrange(efc,20232.8818359375,20663.234375)
replace net_cost_4yr = 29879.9 if inrange(efc,20663.234375,21115.30078125)
replace net_cost_4yr = 30106.1 if inrange(efc,21115.30078125,21510.1015625)
replace net_cost_4yr = 30303.6 if inrange(efc,21510.1015625,21886.10546875)
replace net_cost_4yr = 30491.5 if inrange(efc,21886.10546875,22311.62109375)
replace net_cost_4yr = 30703.9 if inrange(efc,22311.62109375,22918.037109375)
replace net_cost_4yr = 31007.7 if inrange(efc,22918.037109375,23487.943359375)
replace net_cost_4yr = 31292 if inrange(efc,23487.943359375,24003.546875)
replace net_cost_4yr = 31550 if inrange(efc,24003.546875,24849.220703125)
replace net_cost_4yr = 31973.1 if inrange(efc,24849.220703125,25563.427734375)
replace net_cost_4yr = 32330 if inrange(efc,25563.427734375,26248.775390625)
replace net_cost_4yr = 32672.5 if inrange(efc,26248.775390625,27139.1171875)
replace net_cost_4yr = 33117.8 if inrange(efc,27139.1171875,28176.517578125)
replace net_cost_4yr = 33636.5 if inrange(efc,28176.517578125,29303.02734375)
replace net_cost_4yr = 34171.3 if inrange(efc,29303.02734375,30241.74609375)
replace net_cost_4yr = 34589.2 if inrange(efc,30241.74609375,31416.3125)
replace net_cost_4yr = 35112.4 if inrange(efc,31416.3125,32901.046875)
replace net_cost_4yr = 35773.9 if inrange(efc,32901.046875,34649.0546875)
replace net_cost_4yr = 36552.5 if inrange(efc,34649.0546875,36580.7265625)
replace net_cost_4yr = 37412.7 if inrange(efc,36580.7265625,39063.515625)
replace net_cost_4yr = 38518.5 if inrange(efc,39063.515625,42061.65625)
replace net_cost_4yr = 39575.1 if inrange(efc,42061.65625,46831.9921875)
replace net_cost_4yr = 40855.7 if inrange(efc,46831.9921875,75620.109375)
replace net_cost_4yr = 44932.4 if inrange(efc,75620.109375,80406.859375)
replace net_cost_4yr = 44932.4 if inrange(efc,80406.859375,85562.28125)
replace net_cost_4yr = 44932.4 if inrange(efc,85562.28125,.)


gen     net_cost_2yr = .
replace net_cost_2yr = 4007.1 if inrange(famIncAsTeenEFC,0,30000)
replace net_cost_2yr = 4441.4 if inrange(famIncAsTeenEFC,30000,39999)
replace net_cost_2yr = 5545.6 if inrange(famIncAsTeenEFC,40000,49999)
replace net_cost_2yr = 5545.6 if inrange(famIncAsTeenEFC,50000,59999)
replace net_cost_2yr = 6496.5 if inrange(famIncAsTeenEFC,60000,699999)
replace net_cost_2yr = 6696.8 if inrange(famIncAsTeenEFC,70000,79999)
replace net_cost_2yr = 6862.2 if inrange(famIncAsTeenEFC,80000,89999)
replace net_cost_2yr = 7030.2 if inrange(famIncAsTeenEFC,90000,99999)
replace net_cost_2yr = 6739.8 if inrange(famIncAsTeenEFC,100000,.)

*** figure out what missings are ***
local efcvars efc student_lag_income tax2_rate tax2_unmarried_0_ch famIncAsTeenEFC HHsize1997 HH_size_under_18 assets_tot age_older_parent married
mdesc `efcvars' if in_4yr & ~anyFlag
mdesc `efcvars' if in_2yr & ~anyFlag

mdesc `efcvars' if in_4yr & mi(efc) & ~anyFlag
mdesc `efcvars' if in_2yr & mi(efc) & ~anyFlag

count if in_college & ~anyFlag
sum efc if in_college & ~anyFlag, d
sum efc if in_4yr & ~anyFlag, d
sum efc if in_2yr & ~anyFlag, d

