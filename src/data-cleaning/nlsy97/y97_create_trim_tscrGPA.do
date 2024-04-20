version 13.0
clear all
set more off
capture log close
set seed 321654

log using "y97_create_trim_tscrGPA.log", replace

global rawloc ../../../data/nlsy97/raw/
global clnloc ../../../data/nlsy97/cleaned/
global tabloc ../../../exhibits/tables/
use ${rawloc}y97_master.dta
drop GPA
ren tscriptGPA GPA

keep if inrange(year,1997,2015)
gen anyFlag = 0
gen anyFlagFemale = 0
*=================================================
* Frequency stats and droppings
*=================================================
* create .tex table with data creation steps
file open appendix using "${tabloc}dataAppendix_tscrGPA.tex", write replace
file write appendix "\begin{landscape} "_n 
file write appendix "\begin{table} "_n 
file write appendix "\caption{Sample Selection} "_n 
file write appendix "\centering{}\label{tab:Sample Selection}% "_n 
file write appendix "\resizebox{1.3\textwidth}{!}{ "_n 
file write appendix "\begin{threeparttable} "_n 
file write appendix "\begin{tabular}{lcc} "_n 
file write appendix "\toprule "_n 
file write appendix "Selection criterion                                                                & Resultant persons & Resultant person-years\\ "_n 
file write appendix "\midrule  "_n 

xtset ID year
xtsum ID
file write appendix "Full NLSY97 sample                                                                 &" %7.0fc (`r(n)') "&" %7.0fc (`r(N)') " \\ "  _n

* drop females
replace anyFlag = 1 if female==1
xtsum ID if anyFlag==0
file write appendix "Drop women                                                                         &" %7.0fc (`r(n)') "&" %7.0fc (`r(N)') " \\ "  _n
xtsum ID if anyFlagFemale==0

* drop mixed race
drop race
gen race = .
replace race = 1 if white==1
replace race = 2 if black==1
replace race = 3 if hispanic==1
replace race = 4 if mixed==1
label define vlrace_true 1 "White" 2 "Black" 3 "Hispanic" 4 "Mixed"
lab val race vlrace_true
replace anyFlag = 1 if mixed==1
replace anyFlagFemale = 1 if mixed==1
xtsum ID if anyFlag==0
file write appendix "Drop other race                                                                    &" %7.0fc (`r(n)') "&" %7.0fc (`r(N)') " \\ "  _n
xtsum ID if anyFlagFemale==0

* drop missing AFQT
replace anyFlag = 1 if m_afqt==1 & (mi(SATmath) | mi(SATverb))
replace anyFlagFemale = 1 if m_afqt==1 & (mi(SATmath) | mi(SATverb))
xtsum ID if anyFlag==0
file write appendix "Drop missing AFQT and SAT test scores                                               &" %7.0fc (`r(n)') "&" %7.0fc (`r(N)') " \\ "  _n
xtsum ID if anyFlagFemale==0

* drop missing family income
replace anyFlag = 1 if m_famIncAsTeen==1
replace anyFlagFemale = 1 if m_famIncAsTeen==1
xtsum ID if anyFlag==0
xtsum ID if anyFlagFemale==0

* drop missing HS grades
replace anyFlag = 1 if m_Grades_HS_best==1
replace anyFlagFemale = 1 if m_Grades_HS_best==1
xtsum ID if anyFlag==0
xtsum ID if anyFlagFemale==0

* drop missing parental education
replace anyFlag = 1 if m_Peduc==1
replace anyFlagFemale = 1 if m_Peduc==1
xtsum ID if anyFlag==0
file write appendix "Drop missing HS grades, Parental education, or Parental income                     &" %7.0fc (`r(n)') "&" %7.0fc (`r(N)') " \\ "  _n
xtsum ID if anyFlagFemale==0

* drop HS dropouts and GED recipients
replace anyFlag = 1 if HS_dropout==1 | ever_grad_GED==1
replace anyFlagFemale = 1 if HS_dropout==1 | ever_grad_GED==1
xtsum ID if anyFlag==0
file write appendix "Drop HS Dropouts and GED recipients                                                &" %7.0fc (`r(n)') "&" %7.0fc (`r(N)') " \\ "  _n
xtsum ID if anyFlagFemale==0

* drop obs before HS graduation
gen lateHSFlag = year*(in_secondary_school==1)
recode lateHSFlag (0 = .)
bys ID (year): egen firstLateHSFlag = max(lateHSFlag)
recode firstLateHSFlag (0 = .)
replace anyFlag = 1 if year<firstLateHSFlag
replace anyFlag = 1 if year<HS_year
replace anyFlag = 1 if choice15==-1
replace anyFlagFemale = 1 if year<firstLateHSFlag
replace anyFlagFemale = 1 if year<HS_year
replace anyFlagFemale = 1 if choice15==-1
xtsum ID if anyFlag==0
file write appendix "Drop observations before HS graduation                                             &" %7.0fc (`r(n)') "&" %7.0fc (`r(N)') " \\ "  _n
xtsum ID if anyFlagFemale==0

* drop right-censored missing interview spells
replace anyFlag = 1 if missIntLastSpell==1
replace anyFlagFemale = 1 if missIntLastSpell==1
xtsum ID if anyFlag==0
file write appendix "Drop right-censored missing interview spells                                       &" %7.0fc (`r(n)') "&" %7.0fc (`r(N)') " \\ "  _n
xtsum ID if anyFlagFemale==0

* drop all future observations for those who return to school after graduation
gen repeaterFlag = year*(grad_4yr==1 & inlist(choice15,-2,1,2,3,4,5,6,7,8,9))
recode repeaterFlag (0 = .)
bys ID (year): egen firstRepeaterFlag = min(repeaterFlag)
recode firstRepeaterFlag (0 = .)
replace anyFlag = 1 if year>=firstRepeaterFlag
replace anyFlagFemale = 1 if year>=firstRepeaterFlag
xtsum ID if anyFlag==0
file write appendix "Drop any who attend college at a young age or graduate college in 2 or fewer years &" %7.0fc (`r(n)') "&" %7.0fc (`r(N)') " \\ "  _n
xtsum ID if anyFlagFemale==0

* drop all future observations for those who attend graduate school before graduation
gen earlyGSFlag = year*(in_grad_school==1 & grad_4yr==0)
recode earlyGSFlag (0 = .)
bys ID (year): egen firstEarlyGSFlag = min(earlyGSFlag)
recode firstEarlyGSFlag (0 = .)
replace anyFlag = 1 if year>=firstEarlyGSFlag
replace anyFlagFemale = 1 if year>=firstEarlyGSFlag
xtsum ID if anyFlag==0
file write appendix "Drop any who are not in HS at age 15 or under or have other outlying data          &" %7.0fc (`r(n)') "&" %7.0fc (`r(N)') " \\ "  _n
xtsum ID if anyFlagFemale==0

* drop observations for those who graduate HS after age 20
bys ID (year): gen ageGradHSA = age_now if grad_Diploma==1 & grad_Diploma[_n-1]==0
bys ID (year): egen ageGradHS = mean(ageGradHSA)
replace anyFlag = 1 if inrange(ageGradHS,21,.) | mi(ageGradHS)
replace anyFlagFemale = 1 if inrange(ageGradHS,21,.) | mi(ageGradHS)
xtsum ID if anyFlag==0
file write appendix "Drop any who graduate HS after age 20                                              &" %7.0fc (`r(n)') "&" %7.0fc (`r(N)') " \\ "  _n
xtsum ID if anyFlagFemale==0

*=================================================
* Rename age variables
*=================================================
drop age
gen age = age_now-18
drop age_now

*=================================================
* Generate experience variables for descriptives
*=================================================
gen exper_postgrad     = 0
gen exper_white_collar = 0

* Running cumulative choice variables
bys ID (year): generat cum_2yr              = sum(L.in_2yr)
bys ID (year): generat cum_4yr              = sum(L.in_4yr)
bys ID (year): generat cum_college          = sum(L.in_college)
bys ID (year): generat experFT              = sum(L.workFT)
bys ID (year): generat experPT              = sum(L.workPT)
               generat exper                = experFT+.5*experPT
bys ID (year): generat cum_grad_school      = sum(L.in_grad_school)
bys ID (year): generat experFT_postgrad     = sum(L.workFT) if grad_4yr==1
bys ID (year): generat experPT_postgrad     = sum(L.workPT) if grad_4yr==1
               replace exper_postgrad       = experFT_postgrad+.5*experPT_postgrad if grad_4yr==1
bys ID (year): generat experFT_white_collar = sum((L.workFT==1)*(L.whiteCollar==1))
bys ID (year): generat experPT_white_collar = sum((L.workPT==1)*(L.whiteCollar==1))
               replace exper_white_collar   = experFT_white_collar+.5*experPT_white_collar
drop experFT experPT experFT_postgrad experPT_postgrad experFT_white_collar experPT_white_collar

*=================================================
* Generate previous decision dummies
*=================================================
gen prev_WC = 0
gen prev_BC = 0

bys ID (year): generat prev_HS  = L.in_secondary_school==1
bys ID (year): generat prev_2yr = L.in_2yr
bys ID (year): generat prev_4yr = L.in_4yr
bys ID (year): generat prev_PT  = L.workPT
bys ID (year): generat prev_FT  = L.workFT
bys ID (year): replace prev_WC  = L.whiteCollar==1 & (L.workPT==1 | L.workFT==1)
bys ID (year): replace prev_BC  = L.whiteCollar==0 & (L.workPT==1 | L.workFT==1)
bys ID (year): generat prev_GS  = L.in_grad_school


*=================================================
* Table summarizing wage cleaning steps
*=================================================
* create .tex table with wage cleaning steps
file open wageappdx using "${tabloc}wageAppendix_tscrGPA.tex", write replace
file write wageappdx "\begin{table} "_n 
file write wageappdx "\caption{Steps taken to mitigate number of missing wage observations} "_n 
file write wageappdx "\centering{}\label{tab:wageselection}% "_n 
file write wageappdx "\begin{threeparttable} "_n 
file write wageappdx "\begin{tabular}{p{0.25in}p{3in}cc} "_n 
file write wageappdx "\toprule "_n 
file write wageappdx "\multicolumn{2}{l}{Description} & Person-years & Percentage missing \\ "_n 
file write wageappdx "\midrule  "_n 

* initial number of employment observations
qui count if ~anyFlag &                     (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
global numworkobs = `r(N)'
file write wageappdx "\multicolumn{2}{l}{Employed part- or full-time in preliminary sample\tnote{a}} &" %7.0fc (`r(N)') "& --- \\ "  _n
* initial number of employment observations with missing wages
qui count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
global initmisswage = `r(N)'
file write wageappdx "\multicolumn{2}{l}{Initial number with missing wages} &" %7.0fc (`r(N)') " & " %4.2f (`=100*`r(N)'/${numworkobs}') " \\ "  _n
file write wageappdx "\multicolumn{2}{l}{Interpolation and imputation process:} && \\ "  _n



*=================================================
* Clean up wages (i.e. interpolate for 2012,2014 
* interviews and leverage within-spell variation
* to fill in missing wages
*=================================================
do wage_cleaning


*=================================================
* Bottom- and top-code wages at 2%, 99.5% 
*=================================================
* Convert Bottom- and top-code wages
foreach wage in wageOct wageAltOct wage_job_main compOct compAltOct comp_job_main {
    replace   `wage' = `wage'/100
    qui mdesc `wage' if wflg & anyFlag==0
    di "Percent of `wage' imputed using annual income: " %3.2f `=100*`r(percent)''
    replace   `wage' = Income/annualHrsWrkUse if mi(`wage') & wflg // moved this line up to impute before top-coding
    egen upper`wage' = pctile(`wage'), p(99.5)
    egen lower`wage' = pctile(`wage'), p(2.5)
    replace   `wage' = upper`wage' if `wage'>=upper`wage' & ~mi(`wage')
    replace   `wage' = lower`wage' if `wage'<=lower`wage' & ~mi(`wage')
}

* new number of employment observations with missing wages after annual income imputation
qui count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
file write wageappdx " & Remainder missing after imputing wages as annual income / annual hours worked &" %7.0fc (`r(N)') " & " %4.2f (`=100*`r(N)'/${numworkobs}') " \\ "  _n

* comp_job_main is the wage measure that we use in our final estimation
* we use the annual income for those who are missing this variable at a rate of (5978 / (5978+83214)) = 6.7%

*=================================================
* Top-code transfers at $25,000 (to match Johnson)
*=================================================
* Convert Bottom- and top-code wages
foreach trans in incParTransfer colParTransfer rentParTransfer {
    replace   `trans' = 25000 if inrange(`trans',25000,.)
}
replace colParTransfer = . if in_college==0

*=================================================
* Rename wage variables
*=================================================
ren wage_job_main wage
ren comp_job_main comp

gen log_wage       = ln(wage)
gen log_wageOct    = ln(wageOct)
gen log_wageAltOct = ln(wageAltOct)
gen log_comp       = ln(comp)
gen log_compOct    = ln(compOct)
gen log_compAltOct = ln(compAltOct)

drop wflg MIspellLength numMIspells samejob oldjob singlejob tempflag MI* emp_spell*

*=================================================
* Label some data that will be helpful later
*=================================================
lab def vlreasontookbreak 1 "To accelerate" 2 "To make up classes" 3 "For fun" 4 "For enrichment" 5 "Only time class was offered" 6 "For childcare" 7 "Other"
lab val reasonTookClassDuringBreak vlreasontookbreak

*=================================================
* Generate predicted SAT scores for those with missing SAT
*=================================================

bys ID (year): gen firstObs = _n==1
sum SAT???? asvab??, sep(0)
    regress SATmath_unscaled asvab?? if firstObs
qui predict predSATmath, xb
qui replace predSATmath = SATmath_unscaled if ~mi(SATmath_unscaled)

    regress SATverb_unscaled asvab?? if firstObs
qui predict predSATverb, xb
qui replace predSATverb = SATverb_unscaled if ~mi(SATverb_unscaled)

sum predSAT*

* Z-score the semi-imputed SAT variables
zscore  predSATmath if year==1997 & ~mi(predSATmath)
bys ID (year): egen predSATmathZ = mean(z_predSATmath)
drop z_predSATmath
zscore  predSATverb if year==1997 & ~mi(predSATverb)
bys ID (year): egen predSATverbZ = mean(z_predSATverb)
drop z_predSATverb

gen m_wage = !anyFlag & mi(log_comp) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
gen m_GPA  = !anyFlag & mi(GPA)      & (inlist(choice15,-2) | inrange(choice15,1,9))
gen m_maj  = !anyFlag & choice15==-2

sum m_wage if ~anyFlag

bys ID (year): gen sum_m_wage = sum(m_wage)
bys ID (year): gen sum_m_GPA  = sum(m_GPA )
bys ID (year): gen sum_m_maj  = sum(m_maj )

gen bad_wage   = sum_m_wage>=1
gen bad_grade  = sum_m_GPA >=2
gen bad_major  = sum_m_maj >=2

sum grad_4yr if anyFlag==0
xtsum ID if anyFlag==0
sum grad_4yr if anyFlag==0 & bad_wage==0
xtsum ID if anyFlag==0 & bad_wage==0
sum grad_4yr if anyFlag==0 & bad_major==0 
xtsum ID if anyFlag==0 & bad_major==0
sum grad_4yr if anyFlag==0 & bad_major==0 & bad_wage==0 
xtsum ID if anyFlag==0 & bad_major==0 & bad_wage==0
sum grad_4yr if anyFlag==0 & bad_major==0 & bad_wage==0 & bad_grade==0 
xtsum ID if anyFlag==0 & bad_major==0 & bad_wage==0 & bad_grade==0
file write appendix "Drop observations after and including the first instance of missing a wage while working, &            &       \\" _n 
file write appendix "or after the first instance of a missing college major or GPA                      &" %7.0fc (`r(n)') "&" %7.0fc (`r(N)') " \\ "  _n
file write appendix "\midrule " _n 
file write appendix "Final structural estimation subsample\tnote{a}                                     &" %7.0fc (`r(n)') "&" %7.0fc (`r(N)') " \\ "  _n
file write appendix "\bottomrule " _n 
file write appendix "\end{tabular} " _n 
file write appendix "\begin{tablenotes} " _n 
file write appendix "\item[a] \footnotesize{Our structural estimation procedure incorporates integration of missing GPA and major observations, as discussed in Section \ref{subsec:intMissOutc}.} " _n 
file write appendix "\end{tablenotes} " _n 
file write appendix "\end{threeparttable} " _n 
file write appendix "} " _n 
file write appendix "\end{table} " _n 
file write appendix " " _n 
file write appendix "\end{landscape} " _n 
file close appendix

* finish the wage table now that sample selection table is finished
count if ~anyFlag & bad_grade==0 & bad_wage==0 & bad_major==0 & inlist(choice15,1,2,4,5,7,8,10,11,13,14)
file write wageappdx "\midrule " _n 
file write wageappdx "\multicolumn{2}{l}{Employed part- or full-time in final sample} &" %7.0fc (`r(N)') " & 0.00 \\ "  _n
file write wageappdx "\bottomrule " _n 
file write wageappdx "\end{tabular} " _n 
file write wageappdx "Notes: Each row of the table lists the remaining number and percentage of employment observations that have missing wages after cumulatively taking the corresponding action described in the row and all rows above it." _n 
file write wageappdx "\begin{tablenotes}" _n 
file write wageappdx "\item[a] Preliminary sample refers to our estimation subsample prior to dropping missing wages, college grades, or college majors." _n 
file write wageappdx "\item[b] We linearly interpolate missing wages within the same job spell. This occurs most frequently in waves after the survey switched to a biennial frequency (i.e. years after 2011)." _n 
file write wageappdx "\item[c] We replace missing current-period wages with the next-period wage in years 2012 and 2014 when the job spell ended in 2012 and 2014." _n 
file write wageappdx "\item[d] We use a regression model with individual fixed effects to fill in missing wage observations within the same employment spell that cannot be interpolated due to not having two endpoints. This occurs most frequently in years 2012 and 2014 that are not directly covered by the survey due to being in the biennially administered phase." _n 
file write wageappdx "\end{tablenotes}" _n 
file write wageappdx "\end{threeparttable} " _n 
file write wageappdx "\end{table} " _n 
file close wageappdx

* Make sure everyone in the sample is coded as being in HS the year before they enter the sample
tab choice25 if anyFlag==0
bys ID (year): egen esttime  = seq() if anyFlag==0
gen esttime0 = 0
bys ID (year):  replace esttime0 = 1 if esttime==. & esttime[_n+1]==1
l ID year anyFlag esttime choice25 Choice if ID==9021, sep(0)
tab choice25 if esttime0==1
tab Choice   if esttime0==1
replace choice25 = -1 if esttime0==1 & !inrange(choice25,-1,-1)
replace Choice   =  1 if esttime0==1 & !inrange(Choice  , 1, 1)
tab choice25 if esttime0==1
tab Choice   if esttime0==1
tab choice25 if anyFlag==0
tab choice25 if anyFlag==0 & bad_major==0 & bad_wage==0 & bad_grade==0
l ID year anyFlag esttime* choice25 Choice if ID==9021, sep(0)

gen lnFamIncAsTeen = ln(famIncAsTeen)

do calculateEFC

do imputeParTrans

compress
save ${clnloc}y97_all_tscrGPA.dta, replace

log close

* * Why would wages be missing?

* * 1. failure to report earnings despite reporting a "main job" identifier
* mdesc Hrly_comp_Job1_ if Main_job==1 & wflg & year!=2012
* mdesc Hrly_comp_Job2_ if Main_job==2 & wflg & year!=2012
* mdesc Hrly_comp_Job3_ if Main_job==3 & wflg & year!=2012
* mdesc Hrly_comp_Job4_ if Main_job==4 & wflg & year!=2012

* mdesc Hrly_comp_Job1_ if Main_job==1 & wflg & year!=2012 & anyFlag==0
* mdesc Hrly_comp_Job2_ if Main_job==2 & wflg & year!=2012 & anyFlag==0
* mdesc Hrly_comp_Job3_ if Main_job==3 & wflg & year!=2012 & anyFlag==0
* mdesc Hrly_comp_Job4_ if Main_job==4 & wflg & year!=2012 & anyFlag==0

* * 2. failure to report a "main job" identifier (because interview was missed, or invalid survey skips)
* mdesc Main_job if wflg & year!=2012

* mdesc Main_job if wflg & year!=2012 & anyFlag==0

* * What is the rate of missing Main job?
* tab Main_job if  wflg & year!=2012, mi

* * What "kind" of missing is the Hourly wage data?
* * [See  
