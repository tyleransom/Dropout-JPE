clear all
version 13.0
capture log close
set more off
set maxvar 25000

log using "descriptives.log", replace

global data_loc "../../data/nlsy97/cleaned/"
global tbl_loc  "../../exhibits/tables/"

!unzip -u ${data_loc}y97_all_tscrGPA.dta.zip
use                  y97_all_tscrGPA.dta, clear
!rm                  y97_all_tscrGPA.dta
*=================================================
* Generate flags for various sample selection schemes
* NOTE THAT FEMALES ARE EXCLUDED, BECAUSE anyFlag==0 FOR FEMALES
*=================================================
* throw out obs once missing majors, grades, or wages once they are encountered

gen major_s=1 if (choice25==6 | choice25==7 | choice25==8 | choice25==9 | choice25==10 )
replace major_s=0 if (choice25==11 | choice25==12 | choice25==13 | choice25==14 | choice25==15 )

sort ID year
gen long obsno = _n
gen missing = missing(major_s)
bysort ID (missing obsno) : gen firstnonmissing_maj = major_s[1]


capture drop m_wage
capture drop m_GPA
capture drop m_maj
capture drop bad_wage
capture drop bad_grade
capture drop bad_maj
capture drop sum_m_wage
capture drop sum_m_GPA
capture drop sum_m_maj
gen m_wage = anyFlag==0 & mi(log_comp) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
gen m_GPA  = anyFlag==0 & mi(GPA)      & (inlist(choice15,-2) | inrange(choice15,1,9))
gen m_maj  = anyFlag==0 & choice15==-2

sum m_wage if ~anyFlag

bys ID (year): gen sum_m_wage = sum(m_wage)
bys ID (year): gen sum_m_GPA  = sum(m_GPA )
bys ID (year): gen sum_m_maj  = sum(m_maj )

gen bad_wage  = sum_m_wage>=1
gen bad_grade = sum_m_GPA >=2
gen bad_major = sum_m_maj >=2

xtsum ID if anyFlag==0
xtsum ID if anyFlag==0 & bad_major==0
xtsum ID if anyFlag==0 & bad_major==0 & bad_wage==0
xtsum ID if anyFlag==0 & bad_major==0 & bad_wage==0 & bad_grade==0

replace cum_2yr=cum_2yr-1 if ID==2121 & cum_2yr>0


*=================================================
* Generate other helpful variables
*=================================================
* gen Parent_college = Peduc>=16 & ~mi(Peduc)
gen HS_grades = Grades_HS_best
gen age18 = age<=0
gen age19 = age==1
gen age20 = age==2
gen age21 = age==3

gen y04 = year<=2004
gen y05 = year==2005
gen y06 = year==2006
gen y07 = year==2007
gen y08 = year==2008
gen y09 = year==2009
gen y10 = year==2010
gen y11 = year==2011
gen y12 = year==2012
gen y13 = year==2013
gen y14 = year==2014
gen y15 = year==2015
gen y16 = year==2016

forv x=1/3 {
gen cum_col_`x' = cum_college==`x'
gen cum_gs_`x'  = cum_grad_school==`x'
}
gen cum_col_4 = cum_college>=4 & !mi(cum_college)
gen cum_gs_4  = cum_grad_school>=4 & !mi(cum_grad_school)

gen yr2plus = cum_college>=2 & !mi(cum_college)


*============================================================================
* Create variables of interest from data file "Estimation_data_[date]"
*============================================================================
keep if male==1 & ~anyFlag & ~bad_wage & ~bad_grade & ~bad_major

tab choice25 if grad_4yr==0
tab choice25 if grad_4yr==1
*asdfasdf

* Descriptive regressions
reg log_comp black hispanic Parent_college Grades_HS_best age exper exper_white_collar cum_col_1 cum_col_2 cum_col_3 cum_col_4 cum_gs_1 cum_gs_2 cum_gs_3 cum_gs_4 grad_4yr finalSciMajor y04 y05 y06 y07 y08 y09 y10 y11 y12 y13 y14 y15 y16 workPT if inlist(choice25,2,4,7,9,12,14,17,19,22,24)
reg log_comp black hispanic Parent_college Grades_HS_best age exper exper_white_collar cum_col_1 cum_col_2 cum_col_3 cum_col_4 cum_gs_1 cum_gs_2 cum_gs_3 cum_gs_4 grad_4yr finalSciMajor i.year workPT                                      if inlist(choice25,1,3,6,8,11,13,16,18,21,23)
reg GPA black hispanic Parent_college Grades_HS_best workFT workPT age18 age19 age20 age21 if inrange(choice25,6,10)
reg GPA black hispanic Parent_college Grades_HS_best workFT workPT age18 age19 age20 age21 if inrange(choice25,11,15)
reg GPA black hispanic Parent_college Grades_HS_best workFT workPT age18 age19 age20 age21 yr2plus if inrange(choice25,1,5)

mdesc GPA black hispanic Parent_college Grades_HS_best workFT workPT age18 age19 age20 age21 if inrange(choice25,6,10)
mdesc GPA black hispanic Parent_college Grades_HS_best workFT workPT age18 age19 age20 age21 if inrange(choice25,11,15)
mdesc GPA black hispanic Parent_college Grades_HS_best workFT workPT age18 age19 age20 age21 yr2plus if inrange(choice25,1,5)

summarize log_comp black hispanic Parent_college Grades_HS_best age exper exper_white_collar cum_col_1 cum_col_2 cum_col_3 cum_col_4 cum_gs_1 cum_gs_2 cum_gs_3 cum_gs_4 grad_4yr finalSciMajor y04 y05 y06 y07 y08 y09 y10 y11 y12 y13 y14 y15 y16 workPT if inlist(choice25,2,4,7,9,12,14,17,19,22,24), sep(0)
summarize log_comp black hispanic Parent_college Grades_HS_best age exper exper_white_collar cum_col_1 cum_col_2 cum_col_3 cum_col_4 cum_gs_1 cum_gs_2 cum_gs_3 cum_gs_4 grad_4yr finalSciMajor i.year workPT                                      if inlist(choice25,1,3,6,8,11,13,16,18,21,23), sep(0)



gen grades=GPA

bys ID (year): egen gperiod = seq() if in_college & anyFlag==0

capture drop period
bys ID: gen period = _n

foreach x of numlist 1/4 {
    gen dummy_2yr`x'      = (gperiod==`x' & inrange(choice15,1,3))
    gen dummy_4yr`x'      = (gperiod==`x' & (inlist(choice15,-2) | inrange(choice15,4,9)))
    gen full_time_work`x' = (gperiod==`x' & (inlist(choice15,1,4,7) | (inlist(choice15,-2) & workFT==1)))
    gen part_time_work`x' = (gperiod==`x' & (inlist(choice15,2,5,8) | (inlist(choice15,-2) & workPT==1)))
    gen age_col`x'        = age if gperiod==`x'
    
}

bys ID (year): generat left_all_after_first_yr          = (in_college[_n]==1 & in_college[_n+1]==0 & gperiod[_n]==1)
bys ID (year): replace left_all_after_first_yr          = 2-left_all_after_first_yr

bys ID (year): generat left_all_next_yr                 = (in_college[_n]==1 & in_college[_n+1]==0 & grad_4yr[_n+1]==0)
bys ID (year): replace left_all_next_yr                 = 2-left_all_next_yr

bys ID (year): generat left_all_next_yr2                = (in_college[_n]==1 & in_college[_n+1]==0 & grad_2yr[_n+1]==0)
bys ID (year): replace left_all_next_yr2                = 2-left_all_next_yr2

bys ID (year): generat switch_maj_next_yr               = (inrange(choice15[_n],7,9) & inrange(choice15[_n+1],1,6) & grad_4yr[_n+1]==0) | (inrange(choice15[_n],4,6) & inlist(choice15[_n+1],1,2,3,7,8,9) & grad_4yr[_n+1]==0)
bys ID (year): replace switch_maj_next_yr               = 2-switch_maj_next_yr

bys ID (year): generat left_for_sci_maj_next_yr         = (inrange(choice15[_n],7,9) & inrange(choice15[_n+1],4,6) & grad_4yr[_n+1]==0)
bys ID (year): replace left_for_sci_maj_next_yr         = 2-left_for_sci_maj_next_yr

bys ID (year): generat left_for_hum_maj_next_yr         = (inrange(choice15[_n],4,6) & inrange(choice15[_n+1],7,9) & grad_4yr[_n+1]==0)
bys ID (year): replace left_for_hum_maj_next_yr         = 2-left_for_hum_maj_next_yr

bys ID (year): generat left_for_sci_maj_next_yr_from_2y = (inrange(choice15[_n],1,3) & inrange(choice15[_n+1],4,6) & grad_4yr[_n+1]==0)
bys ID (year): replace left_for_sci_maj_next_yr_from_2y = 2-left_for_sci_maj_next_yr_from_2y

bys ID (year): generat left_for_hum_maj_next_yr_from_2y = (inrange(choice15[_n],1,3) & inrange(choice15[_n+1],7,9) & grad_4yr[_n+1]==0)
bys ID (year): replace left_for_hum_maj_next_yr_from_2y = 2-left_for_hum_maj_next_yr_from_2y

bys ID (year): generat left_for_2yr_next_yr             = (inlist(choice15[_n],-2,4,5,6,7,8,9) & inrange(choice15[_n+1],1,3))
bys ID (year): replace left_for_2yr_next_yr             = 2-left_for_2yr_next_yr

bys ID (year): generat left_for_4yr_next_yr             = (inrange(choice15[_n],1,3) & inlist(choice15[_n+1],-2,4,5,6,7,8,9))
bys ID (year): replace left_for_4yr_next_yr             = 2-left_for_4yr_next_yr

***************************************************************************
***************************************************************************

*=============================================================================
* Overeducation spells
*=============================================================================
gen bCollar=1 if (choice25==1 | choice25==3 | choice25==6 | choice25==8 | choice25==11 | choice25==13 | choice25==16 | choice25==18 | choice25==21 | choice25==23)

gen wCollar=1 if (choice25==2 | choice25==4 | choice25==7 | choice25==9 | choice25==12 | choice25==14 | choice25==17 | choice25==19 | choice25==22 | choice25==24)

replace bCollar=0 if  wCollar==1
replace wCollar=0 if  bCollar==1


tab bCollar if grad_4yr==0
tab bCollar if grad_4yr==1

gen FamIncRaw = famIncAsTeen*1000
bys ID (year): egen evCol = max(inlist(choice25,-2,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,21,22,23,24,25))
gen nevCol = ~evCol

bys ID (year): egen avgColGPA1 = mean(GPA) if inlist(choice25,-2,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)
bys ID (year): egen avgColGPA  = mean(avgColGPA1)
drop avgColGPA1

capture drop period
sort ID year
bys ID: gen period = _n

**********
* Table 1
**********

*Start 2 year college
sum predSATmath    if inrange(choice25,1,5) & (cum_2yr+cum_4yr)==0
local satm1 = `r(mean)'
local satm1sd = `r(sd)' 
sum predSATverb    if inrange(choice25,1,5) & (cum_2yr+cum_4yr)==0
local satv1 = `r(mean)'
local satv1sd = `r(sd)'
sum HS_grades      if inrange(choice25,1,5) & (cum_2yr+cum_4yr)==0
local hs_grades1 = `r(mean)'
local hs_grades1sd = `r(sd)'
sum black          if inrange(choice25,1,5) & (cum_2yr+cum_4yr)==0
local black1 = `r(mean)'
local black1sd = `r(sd)'
sum hispanic       if inrange(choice25,1,5) & (cum_2yr+cum_4yr)==0
local hisp1 = `r(mean)'
local hisp1sd = `r(sd)'
sum Parent_college if inrange(choice25,1,5) & (cum_2yr+cum_4yr)==0
local pc1 = `r(mean)'
local pc1sd = `r(sd)'
sum FamIncRaw      if inrange(choice25,1,5) & (cum_2yr+cum_4yr)==0
local inc1 = `r(mean)'/1000
local inc1sd = `r(sd)'/1000
local ob1= `r(N)'

*Start 4 year science
sum predSATmath    if inrange(choice25,6,10) & (cum_2yr+cum_4yr)==0
local satm2 = `r(mean)'
local satm2sd = `r(sd)'
sum predSATverb    if inrange(choice25,6,10) & (cum_2yr+cum_4yr)==0
local satv2 = `r(mean)'
local satv2sd = `r(sd)'
sum HS_grades      if inrange(choice25,6,10) & (cum_2yr+cum_4yr)==0
local hs_grades2 = `r(mean)'
local hs_grades2sd = `r(sd)'
sum black          if inrange(choice25,6,10) & (cum_2yr+cum_4yr)==0
local black2 = `r(mean)'
local black2sd = `r(sd)'
sum hispanic       if inrange(choice25,6,10) & (cum_2yr+cum_4yr)==0
local hisp2 = `r(mean)'
local hisp2sd = `r(sd)'
sum Parent_college if inrange(choice25,6,10) & (cum_2yr+cum_4yr)==0
local pc2 = `r(mean)'
local pc2sd = `r(sd)'
sum FamIncRaw      if inrange(choice25,6,10) & (cum_2yr+cum_4yr)==0
local inc2 = `r(mean)'/1000
local inc2sd = `r(sd)'/1000 
local ob2= `r(N)'

*Start 4 year hum
sum predSATmath    if inrange(choice25,11,15) & (cum_2yr+cum_4yr)==0
local satm3 = `r(mean)'
local satm3sd = `r(sd)'
sum predSATverb    if inrange(choice25,11,15) & (cum_2yr+cum_4yr)==0
local satv3 = `r(mean)'
local satv3sd = `r(sd)'
sum HS_grades      if inrange(choice25,11,15) & (cum_2yr+cum_4yr)==0
local hs_grades3 = `r(mean)'
local hs_grades3sd = `r(sd)'
sum black          if inrange(choice25,11,15) & (cum_2yr+cum_4yr)==0
local black3 = `r(mean)'
local black3sd = `r(sd)'
sum hispanic       if inrange(choice25,11,15) & (cum_2yr+cum_4yr)==0
local hisp3 = `r(mean)'
local hisp3sd = `r(sd)'
sum Parent_college if inrange(choice25,11,15) & (cum_2yr+cum_4yr)==0
local pc3 = `r(mean)'
local pc3sd = `r(sd)'
sum FamIncRaw      if inrange(choice25,11,15) & (cum_2yr+cum_4yr)==0
local inc3 = `r(mean)'/1000
local inc3sd = `r(sd)'/1000 
local ob3= `r(N)'

*Start 4 Missing Major
sum predSATmath    if inrange(choice25,-2,-2) & (cum_2yr+cum_4yr)==0
local satm4 = `r(mean)'
local satm4sd = `r(sd)'
sum predSATverb    if inrange(choice25,-2,-2) & (cum_2yr+cum_4yr)==0
local satv4 = `r(mean)'
local satv4sd = `r(sd)'
sum HS_grades      if inrange(choice25,-2,-2) & (cum_2yr+cum_4yr)==0
local hs_grades4 = `r(mean)'
local hs_grades4sd = `r(sd)'
sum black          if inrange(choice25,-2,-2) & (cum_2yr+cum_4yr)==0
local black4 = `r(mean)'
local black4sd = `r(sd)'
sum hispanic       if inrange(choice25,-2,-2) & (cum_2yr+cum_4yr)==0
local hisp4 = `r(mean)'
local hisp4sd = `r(sd)'
sum Parent_college if inrange(choice25,-2,-2) & (cum_2yr+cum_4yr)==0
local pc4 = `r(mean)'
local pc4sd = `r(sd)'
sum FamIncRaw      if inrange(choice25,-2,-2) & (cum_2yr+cum_4yr)==0
local inc4 = `r(mean)'/1000 
local inc4sd = `r(sd)'/1000 
local ob4= `r(N)'

*Start 4 Neve college
sum predSATmath    if period==1 & nevCol
local satm5 = `r(mean)'
local satm5sd = `r(sd)'
sum predSATverb    if period==1 & nevCol
local satv5 = `r(mean)'
local satv5sd = `r(sd)'
sum HS_grades      if period==1 & nevCol
local hs_grades5 = `r(mean)'
local hs_grades5sd = `r(sd)'
sum black          if period==1 & nevCol
local black5 = `r(mean)'
local black5sd = `r(sd)'
sum hispanic       if period==1 & nevCol
local hisp5 = `r(mean)'
local hisp5sd = `r(sd)'
sum Parent_college if period==1 & nevCol
local pc5 = `r(mean)'
local pc5sd = `r(sd)'
sum FamIncRaw      if period==1 & nevCol
local inc5 = `r(mean)'/1000 
local inc5sd = `r(sd)'/1000 
local ob5= `r(N)'


*All
sum predSATmath    if period==1 
local satm6 = `r(mean)'
local satm6sd = `r(sd)'
sum predSATverb    if period==1 
local satv6 = `r(mean)'
local satv6sd = `r(sd)'
sum HS_grades      if period==1 
local hs_grades6 = `r(mean)'
local hs_grades6sd = `r(sd)'
sum black          if period==1 
local black6 = `r(mean)'
local black6sd = `r(sd)'
sum hispanic       if period==1 
local hisp6 = `r(mean)'
local hisp6sd = `r(sd)'
sum Parent_college if period==1 
local pc6 = `r(mean)'
local pc6sd = `r(sd)'
sum FamIncRaw      if period==1 
local inc6 = `r(mean)'/1000 
local inc6sd = `r(sd)'/1000 
local ob6= `r(N)'

capture file close Ttemp
file open Ttemp using "${tbl_loc}table_1.tex", write replace
file write Ttemp "\begin{table}[ht]" _n 
file write Ttemp "\caption{Background characteristics of estimation sample by college enrollment status}" _n 
file write Ttemp "\label{tab:sumStatsPost}" _n 
file write Ttemp "\centering" _n 
file write Ttemp "\begin{threeparttable}" _n 
file write Ttemp "\begin{tabular}{lcccccc}" _n 
file write Ttemp "\toprule " _n 
file write Ttemp " & \multicolumn{4}{Starting College Type} & & \\" _n 
file write Ttemp "\midrule " _n 
file write Ttemp "Two-year & Four-year Sci. & Four-year Non-Sci. & Four-year Missing Major & No college & Total \\" _n 
file write Ttemp "\midrule " _n 
file write Ttemp "Black                           " " &  " %4.3f (`black1')       " & " %4.3f (`black2') " & " %4.3f (`black3') " & " %4.3f (`black4') " & " %4.3f (`black5') " & " %4.3f (`black6') " \\ "  _n 
file write Ttemp "                                " " & (" %4.3f (`black1sd')     ") & (" %4.3f (`black2sd') ") & (" %4.3f (`black3sd') ") & (" %4.3f (`black4sd') ") & (" %4.3f (`black5sd') ") & (" %4.3f (`black6sd') ") \\ "  _n 
file write Ttemp "Hispanic                        " " &  " %4.3f (`hisp1')        " & " %4.3f (`hisp2') " & " %4.3f (`hisp3') " & " %4.3f (`hisp4') " & " %4.3f (`hisp5') " & " %4.3f (`hisp6') " \\ "  _n 
file write Ttemp "                                " " & (" %4.3f (`hisp1sd')      ") & (" %4.3f (`hisp2sd') ") & (" %4.3f (`hisp3sd') ") & (" %4.3f (`hisp4sd') ") & (" %4.3f (`hisp5sd') ") & (" %4.3f (`hisp6sd') ") \\ "  _n 
file write Ttemp "SAT Math                        " " &  " %4.0f (`satm1')        " & " %4.0f (`satm2') " & " %4.0f (`satm3') " & " %4.0f (`satm4') " & " %4.0f (`satm5') " & " %4.0f (`satm6') " \\ "  _n 
file write Ttemp "                                " " & (" %4.0f (`satm1sd')      ") & (" %4.0f (`satm2sd') ") & (" %4.0f (`satm3sd') ") & (" %4.0f (`satm4sd') ") & (" %4.0f (`satm5sd') ") & (" %4.0f (`satm6sd') ") \\ "  _n 
file write Ttemp "SAT Verbal                      " " &  " %4.0f (`satv1')        " & " %4.0f (`satv2') " & " %4.0f (`satv3') " & " %4.0f (`satv4') " & " %4.0f (`satv5') " & " %4.0f (`satv6') " \\ "  _n 
file write Ttemp "                                " " & (" %4.0f (`satv1sd')      ") & (" %4.0f (`satv2sd') ") & (" %4.0f (`satv3sd') ") & (" %4.0f (`satv4sd') ") & (" %4.0f (`satv5sd') ") & (" %4.0f (`satv6sd') ") \\ "  _n 
file write Ttemp "HS GPA                          " " &  " %4.3f (`hs_grades1')   " & " %4.3f (`hs_grades2') " & " %4.3f (`hs_grades3') " & " %4.3f (`hs_grades4') " & " %4.3f (`hs_grades5') " & " %4.3f (`hs_grades6') " \\ "  _n 
file write Ttemp "                                " " & (" %4.3f (`hs_grades1sd') ") & (" %4.3f (`hs_grades2sd') ") & (" %4.3f (`hs_grades3sd') ") & (" %4.3f (`hs_grades4sd') ") & (" %4.3f (`hs_grades5sd') ") & (" %4.3f (`hs_grades6sd') ") \\ "  _n 
file write Ttemp "Parent Graduated College        " " &  " %4.3f (`pc1') " & " %4.3f (`pc2') " & " %4.3f (`pc3') " & " %4.3f (`pc4') " & " %4.3f (`pc5') " & " %4.3f (`pc6') " \\ "  _n 
file write Ttemp "                                " " & (" %4.3f (`pc1sd') ") & (" %4.3f (`pc2sd') ") & (" %4.3f (`pc3sd') ") & (" %4.3f (`pc4sd') ") & (" %4.3f (`pc5sd') ") & (" %4.3f (`pc6sd') ") \\ "  _n 
file write Ttemp "Family Income (\\$1996) (000's)  " " &  " %4.3f (`inc1') " & " %4.3f (`inc2') " & " %4.3f (`inc3') " & " %4.3f (`inc4') " & " %4.3f (`inc5') " & " %4.3f (`inc6') " \\ "  _n 
file write Ttemp "                                " " & (" %4.3f (`inc1sd') ") & (" %4.3f (`inc2sd') ") & (" %4.3f (`inc3sd') ") & (" %4.3f (`inc4sd') ") & (" %4.3f (`inc5sd') ") & (" %4.3f (`inc6sd') ") \\ "  _n 
file write Ttemp "Observations  " " & " %7.0fc (`ob1') " & " %7.0fc (`ob2') " & " %7.0fc (`ob3') " & " %7.0fc (`ob4') " & " %7.0fc (`ob5') " & " %7.0fc (`ob6') " \\ "  _n
file write Ttemp "\bottomrule " _n 
file write Ttemp "\end{tabular} " _n 
file write Ttemp "\end{threeparttable} " _n 
file write Ttemp "\end{table} " _n 
file close Ttemp



gen     group=1 if bCollar==1 & grad_4yr==0
replace group=2 if bCollar==0 & grad_4yr==0
replace group=3 if bCollar==1 & grad_4yr==1
replace group=4 if bCollar==0 & grad_4yr==1

gen     ageustd = age+18

**********
* Table 2
***********

*BC no graduate
sum ageustd    if group==1 
local ageustd7= `r(mean)'
local ageustd7sd = `r(sd)'
sum predSATmath    if group==1 
local satm7= `r(mean)'
local satm7sd = `r(sd)'
sum predSATverb    if group==1 
local satv7 = `r(mean)'
local satv7sd = `r(sd)'
sum HS_grades      if group==1 
local hs_grades7 = `r(mean)'
local hs_grades7sd = `r(sd)'
sum black          if group==1 
local black7 = `r(mean)'
local black7sd = `r(sd)'
sum hispanic       if group==1 
local hisp7 = `r(mean)'
local hisp7sd = `r(sd)'
sum Parent_college if group==1 
local pc7 = `r(mean)'
local pc7sd = `r(sd)'
sum FamIncRaw      if group==1 
local inc7 = `r(mean)'/1000 
local inc7sd = `r(sd)'/1000 
local ob7= `r(N)'

*WC no graduate
sum ageustd    if group==2 
local ageustd8= `r(mean)'
local ageustd8sd = `r(sd)'
sum predSATmath    if group==2 
local satm8= `r(mean)'
local satm8sd = `r(sd)'
sum predSATverb    if group==2 
local satv8 = `r(mean)'
local satv8sd = `r(sd)'
sum HS_grades      if group==2
local hs_grades8 = `r(mean)'
local hs_grades8sd = `r(sd)'
sum black          if group==2 
local black8 = `r(mean)'
local black8sd = `r(sd)'
sum hispanic       if group==2 
local hisp8 = `r(mean)'
local hisp8sd = `r(sd)'
sum Parent_college if group==2 
local pc8 = `r(mean)'
local pc8sd = `r(sd)'
sum FamIncRaw      if group==2
local inc8 = `r(mean)'/1000 
local inc8sd = `r(sd)'/1000 
local ob8= `r(N)'

*BC graduate
sum ageustd    if group==3 
local ageustd9= `r(mean)'
local ageustd9sd = `r(sd)'
sum predSATmath    if group==3 
local satm9= `r(mean)'
local satm9sd = `r(sd)'
sum predSATverb    if group==3 
local satv9 = `r(mean)'
local satv9sd = `r(sd)'
sum HS_grades      if group==3
local hs_grades9 = `r(mean)'
local hs_grades9sd = `r(sd)'
sum black          if group==3 
local black9 = `r(mean)'
local black9sd = `r(sd)'
sum hispanic       if group==3 
local hisp9 = `r(mean)'
local hisp9sd = `r(sd)'
sum Parent_college if group==3 
local pc9 = `r(mean)'
local pc9sd = `r(sd)'
sum FamIncRaw      if group==3
local inc9 = `r(mean)'/1000 
local inc9sd = `r(sd)'/1000 
local ob9= `r(N)'

*WC graduate
sum ageustd    if group==4 
local ageustd10= `r(mean)'
local ageustd10sd = `r(sd)'
sum predSATmath    if group==4 
local satm10= `r(mean)'
local satm10sd = `r(sd)'
sum predSATverb    if group==4 
local satv10 = `r(mean)'
local satv10sd = `r(sd)'
sum HS_grades      if group==4
local hs_grades10 = `r(mean)'
local hs_grades10sd = `r(sd)'
sum black          if group==4 
local black10 = `r(mean)'
local black10sd = `r(sd)'
sum hispanic       if group==4 
local hisp10 = `r(mean)'
local hisp10sd = `r(sd)'
sum Parent_college if group==4 
local pc10 = `r(mean)'
local pc10sd = `r(sd)'
sum FamIncRaw      if group==4
local inc10 = `r(mean)'/1000 
local inc10sd = `r(sd)'/1000 
local ob10= `r(N)'

sum bCollar if grad_4yr==0
local sharebcng = `r(mean)'
sum bCollar if grad_4yr==0
local sharewcng = 1-`r(mean)'
sum bCollar if grad_4yr==1
local sharebcg = `r(mean)'
sum bCollar if grad_4yr==1
local sharewcg = 1-`r(mean)'


capture file close Ttemp
file open Ttemp using "${tbl_loc}table_2.tex", write replace
file write Ttemp "\begin{table}[ht]" _n 
file write Ttemp "\caption{Background characteristics of estimation sample by college enrollment status}" _n 
file write Ttemp "\label{tab:sumStatsPost}" _n 
file write Ttemp "\centering" _n 
file write Ttemp "\begin{threeparttable}" _n 
file write Ttemp "\begin{tabular}{lcccc}" _n 
file write Ttemp "\toprule " _n 
file write Ttemp "Blue Collar Non-Grad. & White Collar Non-Grad. & Blue Collar Grad. & White Collar Grad. \\" _n 
file write Ttemp "Blue Collar Non-Grad. & White Collar Non-Grad. & Blue Collar Grad. & White Collar Grad. \\" _n 
file write Ttemp "                               & \multicolumn{2}{c}{Non-graduates} & \multicolumn{2}{c}{Graduates} \\ \cmidrule(r){2-3}\cmidrule(l){4-5} " _n
file write Ttemp "                               & Blue Collar & White Collar & Blue Collar & White Collar \\" _n
file write Ttemp "\midrule " _n 
file write Ttemp "Age (years)   " " & " %4.3f (`ageustd7') " & " %4.3f (`ageustd8') " & " %4.3f (`ageustd9') " & " %4.3f (`ageustd10') " \\ "  _n 
file write Ttemp "    " " & (" %4.3f (`ageustd7sd') ") & (" %4.3f (`ageustd8sd') ") & (" %4.3f (`ageustd9sd') ") & (" %4.3f (`ageustd10sd') ") \\ "  _n 
file write Ttemp "Black    " " & " %4.3f (`black7') " & " %4.3f (`black8') " & " %4.3f (`black9') " & " %4.3f (`black10') " \\ "  _n 
file write Ttemp "    " " & (" %4.3f (`black7sd') ") & (" %4.3f (`black8sd') ") & (" %4.3f (`black9sd') ") & (" %4.3f (`black10sd') ") \\ "  _n 
file write Ttemp "Hispanic  " " & " %4.3f (`hisp7') " & " %4.3f (`hisp8') " & " %4.3f (`hisp9') " & " %4.3f (`hisp10') " \\ "  _n 
file write Ttemp "  " " & (" %4.3f (`hisp7sd') ") & (" %4.3f (`hisp8sd') ") & (" %4.3f (`hisp9sd') ") & (" %4.3f (`hisp10sd') ") \\ "  _n 
file write Ttemp "SAT Math    " " & " %4.0f (`satm7') " & " %4.0f (`satm8') " & " %4.0f (`satm9') " & " %4.0f (`satm10') " \\ "  _n 
file write Ttemp "    " " & (" %2.0f (`satm7sd') ") & (" %2.0f (`satm8sd') ") & (" %2.0f (`satm9sd') ") & (" %2.0f (`satm10sd') ") \\ "  _n 
file write Ttemp "SAT Verbal  " " & " %4.0f (`satv7') " & " %4.0f (`satv8') " & " %4.0f (`satv9') " & " %4.0f (`satv10') " \\ "  _n 
file write Ttemp "  " " & (" %2.0f (`satv7sd') ") & (" %2.0f (`satv8sd') ") & (" %2.0f (`satv9sd') ") & (" %2.0f (`satv10sd') ") \\ "  _n 
file write Ttemp "High School GPA (z-score) " " & " %4.3f (`hs_grades7') " & " %4.3f (`hs_grades8') " & " %4.3f (`hs_grades9') " & " %4.3f (`hs_grades10') " \\ "  _n 
file write Ttemp " " " & (" %4.3f (`hs_grades7sd') ") & (" %4.3f (`hs_grades8sd') ") & (" %4.3f (`hs_grades9sd') ") & (" %4.3f (`hs_grades10sd') " ) \\ "  _n 
file write Ttemp "Parent Graduated College  " " & " %4.3f (`pc7') " & " %4.3f (`pc8') " & " %4.3f (`pc9') " & " %4.3f (`pc10') " \\ "  _n 
file write Ttemp "  " " & (" %4.3f (`pc7sd') ") & (" %4.3f (`pc8sd') ") & (" %4.3f (`pc9sd') ") & (" %4.3f (`pc10sd') ") \\ "  _n 
file write Ttemp "Family Income (\\$1996) (000's)  " " & " %4.3f (`inc7') " & " %4.3f (`inc8') " & " %4.3f (`inc9') " & " %4.3f (`inc10') " \\ "  _n 
file write Ttemp " " " & (" %4.3f (`inc7sd') ") & (" %4.3f (`inc8sd') ") & (" %4.3f (`inc9sd') ") & (" %4.3f (`inc10sd') ") \\ "  _n 
file write Ttemp "Observations  " " & " %7.0fc (`ob7') " & " %7.0fc (`ob8') " & " %7.0fc (`ob9') " & " %7.0fc (`ob10') " \\ "  _n
file write Ttemp "Share Conditional on Graduation Outcome  " " & " %4.3f (`sharebcng') " & " %4.3f (`sharewcng') " & " %4.3f (`sharebcg') " & " %4.3f (`sharewcg') " \\ "  _n
file write Ttemp "\bottomrule " _n 
file write Ttemp "\end{tabular} " _n 
file write Ttemp "\end{threeparttable} " _n 
file write Ttemp "\end{table} " _n 
file close Ttemp

*********
* Table 5
**********


bys ID (year): gen return_next_yr_after_stopout = (cum_2yr+cum_4yr>0) & inrange(choice25[_n],16,19) & inrange(choice25[_n+1],1,15) & grad_4yr[_n]==0 & grad_4yr[_n+1]==0
bys ID (year): gen no_return_next_yr = (cum_2yr+cum_4yr>0) & inrange(choice25[_n],16,19) & inrange(choice25[_n+1],16,19) & grad_4yr[_n]==0 & grad_4yr[_n+1]==0

replace exper_postgrad = 0 if grad_4yr==0
gen workFT2yr = (choice15==1)
gen workPT2yr = (choice15==2)
gen workFT4yr = inlist(choice15,4,7)
gen workPT4yr = inlist(choice15,5,8)
gen workPT_new    = (choice15==10)
gen workPTGS  = (choice15==13)
gen workFTGS  = (choice15==14)
capture drop y??
gen y98 = (year==1998 | year==1997) // have to merge 1997 and 1998 together
gen y99 = (year==1999)
gen y00 = (year==2000)
gen y01 = (year==2001)
gen y02 = (year==2002)
gen y03 = (year==2003)
gen y04 = (year==2004)
gen y05 = (year==2005)
gen y06 = (year==2006)
gen y07 = (year==2007)
gen y08 = (year==2008)
gen y09 = (year==2009)
gen y10 = (year==2010)
gen y11 = (year==2011)
gen y12 = (year==2012)
gen y13 = (year==2013)
gen y14 = (year==2014)
gen y15 = (year==2015)
gen y16 = (year==2016)
gen y97_y99 = (year==1998 | year==1997 | year==1999)
gen y00_y04 = (year==2000 | year==2001 | year==2002 | year==2003 | year==2004)
gen age2            = age^2
gen exper2          = exper^2
gen exper_postgrad2 = exper_postgrad^2

gen college1 = cum_2yr+cum_4yr==1 & !mi(cum_2yr)
gen college2 = cum_2yr+cum_4yr==2 & !mi(cum_2yr)
gen college3 = cum_2yr+cum_4yr==3 & !mi(cum_2yr)
gen college4p= cum_2yr+cum_4yr>=4 & !mi(cum_2yr) 

gen g0college1 = grad_4yr==0 & cum_2yr+cum_4yr==1 & !mi(cum_2yr)
gen g0college2 = grad_4yr==0 & cum_2yr+cum_4yr==2 & !mi(cum_2yr)
gen g0college3 = grad_4yr==0 & cum_2yr+cum_4yr==3 & !mi(cum_2yr)
gen g0college4p= grad_4yr==0 & cum_2yr+cum_4yr>=4 & !mi(cum_2yr) 

gen gs1 = cum_grad_school==1 & !mi(cum_grad_school)
gen gs2 = cum_grad_school==2 & !mi(cum_grad_school)
gen gs3 = cum_grad_school==3 & !mi(cum_grad_school)
gen gs4p= cum_grad_school>=4 & !mi(cum_grad_school) 

gen scigrad = finalSciMajor==1 & grad_4yr==1


foreach year in 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15{
    gen black_y`year' = black*y`year'
    gen hisp_y`year' = hispanic*y`year'
    gen male_y`year' = male*y`year'
}

foreach year in 02 03 04 05 06 07 08 09 10 11 12 13 14 15{
    gen grad4yr_y`year' = grad_4yr*y`year'
}

gen black_y97_y99     = black*y97_y99
gen hisp_y97_y99      = hispanic*y97_y99
gen male_y97_y99      = male*y97_y99
gen black_y00_y04     = black*y00_y04
gen hisp_y00_y04      = hispanic*y00_y04
gen male_y00_y04      = male*y00_y04
gen grad4yr_y97_y99   = grad_4yr*y97_y99
gen grad4yr_y00_y04   = grad_4yr*y00_y04
gen grad4yr_wc        = grad_4yr*whiteCollar
gen grad4yr_male      = grad_4yr*male
gen grad4yr_black     = grad_4yr*black
gen grad4yr_hisp      = grad_4yr*hispanic
gen grad4yr_predSATmath = grad_4yr*predSATmath
gen grad4yr_predSATverb = grad_4yr*predSATverb

gen exper_white_collar2=exper_white_collar^2
gen grad_4yr_finalSciMajor=grad_4yr*finalSciMajor

reg log_comp male Peduc m_Peduc black hispanic predSATmath predSATverb Grades_HS_best exper exper2 exper_white_collar exper_white_collar2 i.birth_year age18 age19 age20 workFT2yr workPT2yr workFT4yr workPT4yr workPT_new workPTGS workFTGS grad_4yr y98-y15 grad4yr_y?? grad4yr_wc grad4yr_male grad4yr_black grad4yr_hisp grad4yr_predS* finalSciMajor grad_4yr_finalSciMajor  if ~inlist(choice25,5,10,15,20,25)
predict residU if e(sample), resid



sum log_comp if no_return_next_yr==1  & age<=7 & age>=0
local d1 = `r(mean)' 
local d1sd = `r(sd)' 
local d1n= `r(N)'
sum log_comp if return_next_yr_after_stopout==1 & age<=7 & age>=0
local d2 = `r(mean)' 
local d2sd = `r(sd)' 
local d2n= `r(N)'
sum log_comp if age<=7 & age>=0 & (no_return_next_yr==1 | return_next_yr_after_stopout==1)
local d3 = `r(mean)' 
local d3sd = `r(sd)' 
local d3n= `r(N)'

ttesti `d1n' `d1' `d1sd' `d2n' `d2' `d2sd' 
local dt1= `r(t)' 


sum residU if no_return_next_yr==1  & age<=7 & age>=0
local d4 = `r(mean)' 
local d4sd = `r(sd)' 
local d4n= `r(N)'
sum residU if return_next_yr_after_stopout==1 & age<=7 & age>=0
local d5 = `r(mean)' 
local d5sd = `r(sd)' 
local d5n= `r(N)'
sum residU if age<=7 & age>=0 & (no_return_next_yr==1 | return_next_yr_after_stopout==1)
local d6 = `r(mean)' 
local d6sd = `r(sd)' 
local d6n= `r(N)'
 
ttesti `d4n' `d4' `d4sd' `d5n' `d5' `d5sd' 
local dt2= `r(t)' 

capture file close Ttemp
file open Ttemp using "${tbl_loc}table_5.tex", write replace
file write Ttemp "\begin{table}[ht]" _n 
file write Ttemp "\caption{Background characteristics of estimation sample by college enrollment status}" _n 
file write Ttemp "\label{tab:sumStatsPost}" _n 
file write Ttemp "\centering" _n 
file write Ttemp "\begin{threeparttable}" _n 
file write Ttemp "\begin{tabular}{lcccc}" _n 
file write Ttemp "\toprule " _n 
file write Ttemp "Mean log wage & Std. Dev. & N & $|t-stat|$ \\" _n 
file write Ttemp "\midrule " _n 
file write Ttemp "Stay in work    " " & " %4.3f (`d1') " & " %4.3f (`d1sd') " & " %7.0fc (`d1n') " & "  %4.3f (`dt1') " \\ "  _n 
file write Ttemp "Return to School  " " & " %4.3f (`d2') " & " %4.3f (`d2sd') " & " %7.0fc (`d2n') " & "  " \\ "  _n 
file write Ttemp "\midrule " _n 
file write Ttemp "Total    " " & " %4.3f (`d3') " & " %4.3f (`d3sd') " & " %7.0fc (`d3n') " & "  " \\ "  _n 
file write Ttemp "\midrule " _n 
file write Ttemp "Mean residual & Std. Dev. & N & $|t-stat|$ \\" _n 
file write Ttemp "Stay in work    " " & " %4.3f (`d4') " & " %4.3f (`d4sd') " & " %7.0fc (`d4n') " & "  %4.3f (`dt2')  " \\ "  _n 
file write Ttemp "Return to School  " " & " %4.3f (`d5') " & " %4.3f (`d5sd') " & " %7.0fc (`d5n') " & "  " \\ "  _n 
file write Ttemp "\midrule " _n 
file write Ttemp "Total    " " & " %4.3f (`d6') " & " %4.3f (`d6sd') " & " %7.0fc (`d6n') " & "  " \\ "  _n 
file write Ttemp "\bottomrule " _n 
file write Ttemp "\end{tabular} " _n 
file write Ttemp "\end{threeparttable} " _n 
file write Ttemp "\end{table} " _n 
file close Ttemp

************************************
* Table A.2 
* Most common occupations
********************************************
tab occOct if bCollar==1 & grad_4yr==0, sort
tab occOct if bCollar==1 & grad_4yr==1, sort
tab occOct if bCollar==0 & grad_4yr==0, sort
tab occOct if bCollar==0 & grad_4yr==1, sort


*============================================================================
* Table 3: Outcomes of college enrollees (Estimation subsample portion)
*============================================================================
bys ID: egen finish_4yr = max(grad_4yr)

*** "NLSY97 population ***
preserve
use "${data_loc}y97_all_tscrGPA.dta", clear
    tab CC_DO_SO, nol
    tab CC_DO_SO
    gen CC_DO_SO_temp = CC_DO_SO
    lab def vlCCDOSOtemp 1 "Continuous completion" 2 "Stopout but graduate" 3 "Stopout then dropout" 4 "Dropout"
    lab val CC_DO_SO_temp vlCCDOSOtemp
    recode CC_DO_SO_temp (5 = 1) (6 = 2)
    
    gen CC_DO_SO_verbose = CC_DO_SO
    lab def vlCCDOSOv 1 "CC Sci" 2 "CC Hum" 3 "Stopout grad Sci" 4 "Stopout grad Hum" 5 "Stopout then dropout" 6 "Dropout" 7 "CC right-censored" 8 "SO right-censored"
    lab val CC_DO_SO_verbose vlCCDOSOv
    recode CC_DO_SO_verbose (2 = 3) (3 = 5) (4 = 6) (5 = 7) (6 = 8)
    replace CC_DO_SO_verbose = 1 if CC_DO_SO==1 & finalSciMajor==1
    replace CC_DO_SO_verbose = 2 if CC_DO_SO==1 & finalSciMajor==0
    replace CC_DO_SO_verbose = 3 if CC_DO_SO==2 & finalSciMajor==1
    replace CC_DO_SO_verbose = 4 if CC_DO_SO==2 & finalSciMajor==0
    
    capture drop firstObs
    bys ID: gen firstObs = _n==1
    mdesc CC_DO_SO              if firstObs &  male & (ever_start_4yr | ever_start_2yr)
    mdesc CC_DO_SO              if firstObs & ~male & (ever_start_4yr | ever_start_2yr)
    tab ID if mi(CC_DO_SO) & (ever_start_4yr | ever_start_2yr) & firstObs
    
    tabulat CC_DO_SO if male & firstObs
    tabulat CC_DO_SO if male & firstObs, mi
    generat CC_DO_SO_uncond = CC_DO_SO
    replace CC_DO_SO_uncond = 7 if mi(CC_DO_SO) & ~ever_start_4yr & ~ever_start_2yr
    tabulat CC_DO_SO_uncond if male & firstObs
    tabulat CC_DO_SO_uncond if male & firstObs, mi
    
    generat CC_DO_SO_collapse = .
    replace CC_DO_SO_collapse = 1 if inlist(CC_DO_SO,1,5)
    replace CC_DO_SO_collapse = 2 if inlist(CC_DO_SO,2,3,6)
    replace CC_DO_SO_collapse = 3 if inlist(CC_DO_SO,4)
    lab def vlccdosocollpase 1 "CC" 2 "SO" 3 "DO"
    lab val CC_DO_SO_collapse vlccdosocollpase

use "${data_loc}y97_all_tscrGPA.dta", clear
    collapse (first) year if anyFlag==0 & bad_major==0 & bad_wage==0 & bad_grade==0, by(ID)
    keep ID
    outsheet using estSubSampIDs.csv, comma replace
restore

*** Estimation Subsample ***
tempfile estimationIDs
preserve
    * This uses data from the DSCR server to generate the list of individuals included in the structural estimation.
    insheet using estSubSampIDs.csv, comma clear
    ren id ID
    l in 1/5
    gen veevee = 1
    count
    save `estimationIDs'
restore
preserve
use "${data_loc}y97_all_tscrGPA.dta", clear
    merge m:1 ID using `estimationIDs', nogen keep(match)
    codebook ID
    tab CC_DO_SO, nol
    tab CC_DO_SO
    gen CC_DO_SO_temp = CC_DO_SO
    lab def vlCCDOSOtemp 1 "Continuous completion" 2 "Stopout but graduate" 3 "Stopout then dropout" 4 "Dropout"
    lab val CC_DO_SO_temp vlCCDOSOtemp
    recode CC_DO_SO_temp (5 = 1) (6 = 2)
    
    gen CC_DO_SO_verbose = CC_DO_SO
    lab def vlCCDOSOv 1 "CC Sci" 2 "CC Hum" 3 "Stopout grad Sci" 4 "Stopout grad Hum" 5 "Stopout then dropout" 6 "Dropout" 7 "CC right-censored" 8 "SO right-censored"
    lab val CC_DO_SO_verbose vlCCDOSOv
    recode CC_DO_SO_verbose (2 = 3) (3 = 5) (4 = 6) (5 = 7) (6 = 8)
    replace CC_DO_SO_verbose = 1 if CC_DO_SO==1 & finalSciMajor==1
    replace CC_DO_SO_verbose = 2 if CC_DO_SO==1 & finalSciMajor==0
    replace CC_DO_SO_verbose = 3 if CC_DO_SO==2 & finalSciMajor==1
    replace CC_DO_SO_verbose = 4 if CC_DO_SO==2 & finalSciMajor==0
    
    
    capture drop firstObs
    bys ID: gen firstObs = _n==1
    mdesc CC_DO_SO              if firstObs &  male & (ever_start_4yr | ever_start_2yr)
    mdesc CC_DO_SO              if firstObs & ~male & (ever_start_4yr | ever_start_2yr)
    tab ID if mi(CC_DO_SO) & (ever_start_4yr | ever_start_2yr) & firstObs
    
    tabulat CC_DO_SO if male & firstObs
    tabulat CC_DO_SO if male & firstObs, mi
    generat CC_DO_SO_uncond = CC_DO_SO
    replace CC_DO_SO_uncond = 7 if mi(CC_DO_SO) & ~ever_start_4yr & ~ever_start_2yr
    tabulat CC_DO_SO_uncond if male & firstObs
    tabulat CC_DO_SO_uncond if male & firstObs, mi
    
    generat CC_DO_SO_collapse = .
    replace CC_DO_SO_collapse = 1 if inlist(CC_DO_SO,1,5)
    replace CC_DO_SO_collapse = 2 if inlist(CC_DO_SO,2,3,6)
    replace CC_DO_SO_collapse = 3 if inlist(CC_DO_SO,4)
    lab def vlccdosocollpase 1 "CC" 2 "SO" 3 "DO"
    lab val CC_DO_SO_collapse vlccdosocollpase
restore

*** Descriptive Subsample
qui generat first_type = .
qui replace first_type = 2 if dummy_2yr1==1 
qui replace first_type = 3 if dummy_4yr1==1 & scienceMajor==1
qui replace first_type = 4 if dummy_4yr1==1 & otherMajor==1
qui replace first_type = 5 if dummy_4yr1==1 & choice15==-2
lab def vlfirsttype 2 "Started in 2yr college" 3 "Started in 4yr college & Sci" 4 "Started in 4yr college & Hum" 5 "Started in 4yr college & Missing major"
lab val first_type vlfirsttype

* Try to find the individuals who are not in the "first_type" sample but are in the "firstObs" sample
bys ID (year): egen firstTyper = mean(first_type)


gen CC_DO_SO_temp = CC_DO_SO
lab def vlCCDOSOtemp 1 "Continuous completion" 2 "Stopout but graduate" 3 "Stopout then dropout" 4 "Dropout"
lab val CC_DO_SO_temp vlCCDOSOtemp
recode CC_DO_SO_temp (5 = 1) (6 = 2)

gen CC_DO_SO_verbose = CC_DO_SO
lab def vlCCDOSOv 1 "CC Sci" 2 "CC Hum" 3 "Stopout grad Sci" 4 "Stopout grad Hum" 5 "Stopout then dropout" 6 "Dropout" 7 "CC right-censored" 8 "SO right-censored"
lab val CC_DO_SO_verbose vlCCDOSOv
recode CC_DO_SO_verbose (2 = 3) (3 = 5) (4 = 6) (5 = 7) (6 = 8)
replace CC_DO_SO_verbose = 1 if CC_DO_SO==1 & finalSciMajor==1
replace CC_DO_SO_verbose = 2 if CC_DO_SO==1 & finalSciMajor==0
replace CC_DO_SO_verbose = 3 if CC_DO_SO==2 & finalSciMajor==1
replace CC_DO_SO_verbose = 4 if CC_DO_SO==2 & finalSciMajor==0


capture drop firstObs
bys ID:  gen firstObs = _n==1
bys ID: egen everFlag = max(anyFlag)
gen CC_DO_SO_nonAttend = CC_DO_SO
replace CC_DO_SO_nonAttend = 7 if mi(CC_DO_SO_nonAttend)
lab def vlCCDOSOnonAttend 1 "Continuous completion" 2 "Stopout but graduate" 3 "Stopout then dropout" 4 "Dropout" 5 "CC trunc" 6 "SO trunc" 7 "Never college"
lab val CC_DO_SO_nonAttend vlCCDOSOnonAttend
tab CC_DO_SO           if firstObs
tab CC_DO_SO           if firstObs, mi
tab CC_DO_SO_nonAttend if firstObs, mi

qui tabout CC_DO_SO_verbose first_type using "${tbl_loc}table_3_Ns.tex", replace c(freq) f(0) style(tex) 
qui tabout CC_DO_SO_verbose first_type using "${tbl_loc}table_3_pcts.tex", replace c( col) f( 2p) style(tex) 


*Table 3 corresponds to the .tex files "table_3_pcts.tex" and for the observations "table_3_Ns.tex"



**********
*Table 4
**********
*============================================================================
* Difference between actual and expected period-t grades (by t+1 period college decision) --- any t, not just first period
*============================================================================
capture drop resid*
gen workFT_s = (inlist(choice15,1,4,7) | (inlist(choice15,-2) & workFT))
gen workPT_s = (inlist(choice15,2,5,8) | (inlist(choice15,-2) & workPT))

local cs
*--------------------------------------------------------------------------------
* Panel 3 of Table 4
*--------------------------------------------------------------------------------
capture drop resid*
qui regress grades black hispanic predSATmath predSATverb Parent_college HS_grades i.birth_year age18 age19 age20 workFT_s workPT_s if inlist(choice15,-2,4,5,6,7,8,9) `cs'
qui predict double resid4 if e(sample), resid
reg resid4 left_all_next_yr                 if inlist(choice15,4,5,6,7,8,9) `cs'
qui tabout left_all_next_yr                 if inlist(choice15,4,5,6,7,8,9) `cs' using "${tbl_loc}table_4_c_d.tex", replace c( mean resid4 sd resid4 N resid4) f(3 3 0) sum clab( Grades_residual Std_Dev N ) style(tex)

sum resid4 if left_all_next_yr==1 & inlist(choice15,4,5,6,7,8,9)
local a1 = `r(mean)' 
local a1sd = `r(sd)' 
local a1n= `r(N)'
 
sum resid4 if left_all_next_yr==2 & inlist(choice15,4,5,6,7,8,9)
local a2 = `r(mean)' 
local a2sd = `r(sd)' 
local a2n= `r(N)'

ttesti `a1n' `a1' `a1sd' `a2n' `a2' `a2sd' 
local at1= `r(t)' 
*--------------------------------------------------------------------------------
* Panel 4 of Table 4
*--------------------------------------------------------------------------------
capture drop resid*
qui regress grades black hispanic predSATmath predSATverb Parent_college HS_grades i.birth_year age18 age19 age20 workFT_s workPT_s if inlist(choice15,1,2,3)
qui predict double resid2 if e(sample), resid
reg resid2 left_all_next_yr2                 if inlist(choice15,1,2,3)
qui tabout left_all_next_yr2                if inlist(choice15,1,2,3) using "${tbl_loc}table_4_c_d.tex", append c( mean resid2 sd resid2 N resid2) f(3 3 0) sum clab( Grades_residual Std_Dev N ) style(tex)

sum resid2 if  left_all_next_yr2==1 & inlist(choice15,1,2,3)
local a5 = `r(mean)' 
local a5sd = `r(sd)' 
local a5n= `r(N)'

sum resid2 if  left_all_next_yr2==2 & inlist(choice15,1,2,3)
local a6 = `r(mean)' 
local a6sd = `r(sd)' 
local a6n= `r(N)'

ttesti `a5n' `a5' `a5sd' `a6n' `a6' `a6sd' 
local at3= `r(t)' 
 
*Levels
*============================================================================
* Table 4: Difference between actual and expected period-t grades (by t+1 period college decision) --- any t, not just first period
*============================================================================
capture drop resid* Resid*

local cs
*--------------------------------------------------------------------------------
*  Panel 1 Table 4
*--------------------------------------------------------------------------------
capture drop resid*

reg grades left_all_next_yr                 if inlist(choice15,-2,4,5,6,7,8,9) `cs'
qui tabout left_all_next_yr                  if inlist(choice15,-2,4,5,6,7,8,9) `cs' using "${tbl_loc}table_4_a_b.tex", replace c( mean grades sd grades N grades) f(3 3 0) sum clab( GPA Std_Dev N ) style(tex)

sum grades if left_all_next_yr==1 & inlist(choice15,-2,4,5,6,7,8,9)
local a9 = `r(mean)' 
local a9sd = `r(sd)' 
local a9n= `r(N)'
 
sum grades if left_all_next_yr==2 &  inlist(choice15,-2,4,5,6,7,8,9)
local a10 = `r(mean)' 
local a10sd = `r(sd)' 
local a10n= `r(N)'

ttesti `a9n' `a9' `a9sd' `a10n' `a10' `a10sd' 
local at5= `r(t)'

*--------------------------------------------------------------------------------
* Panel 2 Table 4
*--------------------------------------------------------------------------------
capture drop resid*

reg grades left_all_next_yr2                 if inlist(choice15,1,2,3)
qui tabout left_all_next_yr2                if inlist(choice15,1,2,3) using "${tbl_loc}table_4_a_b.tex", append c( mean grades sd grades N grades) f(3 3 0) sum clab( GPA Std_Dev N ) style(tex)

sum grades if  left_all_next_yr2==1 & inlist(choice15,1,2,3)
local a13 = `r(mean)' 
local a13sd = `r(sd)' 
local a13n= `r(N)'


sum grades if  left_all_next_yr2==2 & inlist(choice15,1,2,3)
local a14 = `r(mean)' 
local a14sd = `r(sd)' 
local a14n= `r(N)'

ttesti `a13n' `a13' `a13sd' `a14n' `a14' `a14sd' 
local at7= `r(t)'

*File "table_4_a_b.tex" provides the first two panels of Table 4
*File "table_4_c_d.tex" provides the last two panels of Table 4
*table needs to be created manually and t-stat needs to be entered manually

!rm -f estSubSampIDs.csv

log close

