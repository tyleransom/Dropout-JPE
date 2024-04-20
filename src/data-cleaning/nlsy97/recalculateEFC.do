*---------------------------------------------------------
* EFC calculation (only change taxes and income/asset protections)
*---------------------------------------------------------
generat `efcvarname' = .
replace `efcvarname' = 0 if famIncAsTeenEFC<=(20000/cpi_06)

capture drop index mean_income_pre mean_income share_m_income*
capture drop lambda_* tau_* tax2_*

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


**********************
*Parental Contribution
**********************
capture drop allowance_* tot_allowances available_parent_income parent_assets asset_protection parent_contr_assets AAI_pre AAI parent_contribution

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

gen parent_contribution= AAI/HH_size_under_18_in_college


**********************
*Student Contribution
**********************
capture drop s_allowance_* s_tot_allowances available_student_income student_contr_assets student_contr_income student_contribution

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
replace `efcvarname'=parent_contribution+student_contribution if `efcvarname'~=0


*---------------------------------------------------------
* Net cost of college (given EFC)
*---------------------------------------------------------
capture drop net_cost_*
gen     net_cost_4yr = .
replace net_cost_4yr = 18966   if inrange(`efcvarname',0,405.303100585937)
replace net_cost_4yr = 19185.1 if inrange(`efcvarname',405.303100585937,822.078186035156)
replace net_cost_4yr = 19411.3 if inrange(`efcvarname',822.078186035156,1221.94873046875)
replace net_cost_4yr = 19627.9 if inrange(`efcvarname',1221.94873046875,1564.91296386718)
replace net_cost_4yr = 19813.9 if inrange(`efcvarname',1564.91296386718,1823.0068359375)
replace net_cost_4yr = 19954.3 if inrange(`efcvarname',1823.0068359375,2168.40991210937)
replace net_cost_4yr = 20141.4 if inrange(`efcvarname',2168.40991210937,2354.84375)
replace net_cost_4yr = 20242.1 if inrange(`efcvarname',2354.84375,2637.3212890625)
replace net_cost_4yr = 20395.7 if inrange(`efcvarname',2637.3212890625,2830.279296875)
replace net_cost_4yr = 20500.4 if inrange(`efcvarname',2830.279296875,3063.10009765625)
replace net_cost_4yr = 20626.7 if inrange(`efcvarname',3063.10009765625,3282.6748046875)
replace net_cost_4yr = 20745.6 if inrange(`efcvarname',3282.6748046875,3503.779296875)
replace net_cost_4yr = 20865.3 if inrange(`efcvarname',3503.779296875,3661.20849609375)
replace net_cost_4yr = 20951.2 if inrange(`efcvarname',3661.20849609375,3825.427734375)
replace net_cost_4yr = 21039.8 if inrange(`efcvarname',3825.427734375,3985.17944335937)
replace net_cost_4yr = 21126.6 if inrange(`efcvarname',3985.17944335937,4184.78125)
replace net_cost_4yr = 21234.8 if inrange(`efcvarname',4184.78125,4370.8671875)
replace net_cost_4yr = 21335.5 if inrange(`efcvarname',4370.8671875,4557.115234375)
replace net_cost_4yr = 21437   if inrange(`efcvarname',4557.115234375,4729.46923828125)
replace net_cost_4yr = 21530.2 if inrange(`efcvarname',4729.46923828125,4905.13818359375)
replace net_cost_4yr = 21625.5 if inrange(`efcvarname',4905.13818359375,5071.37060546875)
replace net_cost_4yr = 21715.6 if inrange(`efcvarname',5071.37060546875,5194.51220703125)
replace net_cost_4yr = 21782.5 if inrange(`efcvarname',5194.51220703125,5374.283203125)
replace net_cost_4yr = 21880   if inrange(`efcvarname',5374.283203125,5553.9658203125)
replace net_cost_4yr = 21976.9 if inrange(`efcvarname',5553.9658203125,5736.57885742187)
replace net_cost_4yr = 22076.3 if inrange(`efcvarname',5736.57885742187,5878.37451171875)
replace net_cost_4yr = 22153.4 if inrange(`efcvarname',5878.37451171875,6005.994140625)
replace net_cost_4yr = 22222.1 if inrange(`efcvarname',6005.994140625,6133.2353515625)
replace net_cost_4yr = 22291.6 if inrange(`efcvarname',6133.2353515625,6344.32275390625)
replace net_cost_4yr = 22406.1 if inrange(`efcvarname',6344.32275390625,6462.888671875)
replace net_cost_4yr = 22469.8 if inrange(`efcvarname',6462.888671875,6671.2373046875)
replace net_cost_4yr = 22583.2 if inrange(`efcvarname',6671.2373046875,6868.8974609375)
replace net_cost_4yr = 22690   if inrange(`efcvarname',6868.8974609375,7012.421875)
replace net_cost_4yr = 22768.1 if inrange(`efcvarname',7012.421875,7181.83837890625)
replace net_cost_4yr = 22859.7 if inrange(`efcvarname',7181.83837890625,7355.22998046875)
replace net_cost_4yr = 22954.3 if inrange(`efcvarname',7355.22998046875,7574.85400390625)
replace net_cost_4yr = 23073.1 if inrange(`efcvarname',7574.85400390625,7794.40234375)
replace net_cost_4yr = 23192.5 if inrange(`efcvarname',7794.40234375,8036.275390625)
replace net_cost_4yr = 23323.7 if inrange(`efcvarname',8036.275390625,8278.0703125)
replace net_cost_4yr = 23454.8 if inrange(`efcvarname',8278.0703125,8500.205078125)
replace net_cost_4yr = 23575.1 if inrange(`efcvarname',8500.205078125,8713.158203125)
replace net_cost_4yr = 23690.6 if inrange(`efcvarname',8713.158203125,8953.9599609375)
replace net_cost_4yr = 23820.9 if inrange(`efcvarname',8953.9599609375,9244.095703125)
replace net_cost_4yr = 23978.6 if inrange(`efcvarname',9244.095703125,9545.515625)
replace net_cost_4yr = 24141.9 if inrange(`efcvarname',9545.515625,9876.1103515625)
replace net_cost_4yr = 24321.5 if inrange(`efcvarname',9876.1103515625,10170.9404296875)
replace net_cost_4yr = 24480.8 if inrange(`efcvarname',10170.9404296875,10493.701171875)
replace net_cost_4yr = 24655.8 if inrange(`efcvarname',10493.701171875,10725.28515625)
replace net_cost_4yr = 24781.7 if inrange(`efcvarname',10725.28515625,11085.814453125)
replace net_cost_4yr = 24977.1 if inrange(`efcvarname',11085.814453125,11408.5522460937)
replace net_cost_4yr = 25152   if inrange(`efcvarname',11408.5522460937,11757.89453125)
replace net_cost_4yr = 25341.7 if inrange(`efcvarname',11757.89453125,11993.751953125)
replace net_cost_4yr = 25469.3 if inrange(`efcvarname',11993.751953125,12310.1484375)
replace net_cost_4yr = 25641.6 if inrange(`efcvarname',12310.1484375,12605.6259765625)
replace net_cost_4yr = 25801.2 if inrange(`efcvarname',12605.6259765625,12959.626953125)
replace net_cost_4yr = 25993.2 if inrange(`efcvarname',12959.626953125,13322.759765625)
replace net_cost_4yr = 26190.1 if inrange(`efcvarname',13322.759765625,13642.462890625)
replace net_cost_4yr = 26363.6 if inrange(`efcvarname',13642.462890625,14000.1708984375)
replace net_cost_4yr = 26548.6 if inrange(`efcvarname',14000.1708984375,14404.3994140625)
replace net_cost_4yr = 26750.7 if inrange(`efcvarname',14404.3994140625,14808.23828125)
replace net_cost_4yr = 26952.9 if inrange(`efcvarname',14808.23828125,15102.2509765625)
replace net_cost_4yr = 27099.8 if inrange(`efcvarname',15102.2509765625,15429.140625)
replace net_cost_4yr = 27263.1 if inrange(`efcvarname',15429.140625,15815.296875)
replace net_cost_4yr = 27456.2 if inrange(`efcvarname',15815.296875,16225.3193359375)
replace net_cost_4yr = 27661.1 if inrange(`efcvarname',16225.3193359375,16585.048828125)
replace net_cost_4yr = 27841.1 if inrange(`efcvarname',16585.048828125,16876.72265625)
replace net_cost_4yr = 27986.6 if inrange(`efcvarname',16876.72265625,17187.19921875)
replace net_cost_4yr = 28142.1 if inrange(`efcvarname',17187.19921875,17510.40234375)
replace net_cost_4yr = 28303.7 if inrange(`efcvarname',17510.40234375,17883.107421875)
replace net_cost_4yr = 28490.1 if inrange(`efcvarname',17883.107421875,18246.21484375)
replace net_cost_4yr = 28671.6 if inrange(`efcvarname',18246.21484375,18620.40234375)
replace net_cost_4yr = 28858.4 if inrange(`efcvarname',18620.40234375,18944.01171875)
replace net_cost_4yr = 29020.7 if inrange(`efcvarname',18944.01171875,19307.21484375)
replace net_cost_4yr = 29202.2 if inrange(`efcvarname',19307.21484375,19806.55078125)
replace net_cost_4yr = 29451.6 if inrange(`efcvarname',19806.55078125,20232.8818359375)
replace net_cost_4yr = 29664.5 if inrange(`efcvarname',20232.8818359375,20663.234375)
replace net_cost_4yr = 29879.9 if inrange(`efcvarname',20663.234375,21115.30078125)
replace net_cost_4yr = 30106.1 if inrange(`efcvarname',21115.30078125,21510.1015625)
replace net_cost_4yr = 30303.6 if inrange(`efcvarname',21510.1015625,21886.10546875)
replace net_cost_4yr = 30491.5 if inrange(`efcvarname',21886.10546875,22311.62109375)
replace net_cost_4yr = 30703.9 if inrange(`efcvarname',22311.62109375,22918.037109375)
replace net_cost_4yr = 31007.7 if inrange(`efcvarname',22918.037109375,23487.943359375)
replace net_cost_4yr = 31292   if inrange(`efcvarname',23487.943359375,24003.546875)
replace net_cost_4yr = 31550   if inrange(`efcvarname',24003.546875,24849.220703125)
replace net_cost_4yr = 31973.1 if inrange(`efcvarname',24849.220703125,25563.427734375)
replace net_cost_4yr = 32330   if inrange(`efcvarname',25563.427734375,26248.775390625)
replace net_cost_4yr = 32672.5 if inrange(`efcvarname',26248.775390625,27139.1171875)
replace net_cost_4yr = 33117.8 if inrange(`efcvarname',27139.1171875,28176.517578125)
replace net_cost_4yr = 33636.5 if inrange(`efcvarname',28176.517578125,29303.02734375)
replace net_cost_4yr = 34171.3 if inrange(`efcvarname',29303.02734375,30241.74609375)
replace net_cost_4yr = 34589.2 if inrange(`efcvarname',30241.74609375,31416.3125)
replace net_cost_4yr = 35112.4 if inrange(`efcvarname',31416.3125,32901.046875)
replace net_cost_4yr = 35773.9 if inrange(`efcvarname',32901.046875,34649.0546875)
replace net_cost_4yr = 36552.5 if inrange(`efcvarname',34649.0546875,36580.7265625)
replace net_cost_4yr = 37412.7 if inrange(`efcvarname',36580.7265625,39063.515625)
replace net_cost_4yr = 38518.5 if inrange(`efcvarname',39063.515625,42061.65625)
replace net_cost_4yr = 39575.1 if inrange(`efcvarname',42061.65625,46831.9921875)
replace net_cost_4yr = 40855.7 if inrange(`efcvarname',46831.9921875,75620.109375)
replace net_cost_4yr = 44932.4 if inrange(`efcvarname',75620.109375,80406.859375)
replace net_cost_4yr = 44932.4 if inrange(`efcvarname',80406.859375,85562.28125)
replace net_cost_4yr = 44932.4 if inrange(`efcvarname',85562.28125,.)


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
local efcvars `efcvarname' student_lag_income tax2_rate tax2_unmarried_0_ch famIncAsTeenEFC HHsize1997 HH_size_under_18 assets_tot age_older_parent married
mdesc `efcvars' if in_4yr
mdesc `efcvars' if in_2yr

mdesc `efcvars' if in_4yr & ~anyFlag
mdesc `efcvars' if in_2yr & ~anyFlag

mdesc `efcvars' if in_4yr & mi(`efcvarname')
mdesc `efcvars' if in_2yr & mi(`efcvarname')

count if in_college
sum `efcvarname' if in_college, d

