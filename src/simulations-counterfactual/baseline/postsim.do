version 15.1
clear all
set more off
capture log close

log using "postsim.log", replace
global datloc "../../../output/cfl/baseline/"

* read in counterfactual CSVs
tempfile master
save `master', replace empty
forv i=1/2300 {
    capture confirm file ${datloc}CflData`i'.csv
    if !_rc {
        di "`i'"
        insheet using ${datloc}CflData`i'.csv, comma case clear
        gen id = `i'
        append using `master'
        save `master', replace
    }
}

use `master', clear
order id simno
sort id simno

l if id==970
tempfile nls_id
preserve
    insheet using "demogs_with_NLS_ID.csv", comma case clear
    ren rownum id
    ren NLS_ID nls_id
    l if id==970
    save `nls_id', replace
restore

merge m:1 id using `nls_id', keep(match master) keepusing(nls_id) nogen
order id nls_id

//save CflDataWideEMA.dta, replace

d, f

lab def vlchoice 1  "2yr FT BC" 2  "2yr FT WC" 3  "2yr PT BC" 4  "2yr PT WC" 5  "2yr only" 6  "4yr S FT BC" 7  "4yr S FT WC" 8  "4yr S PT BC" 9  "4yr S PT WC" 10 "4yr S only" 11 "4yr H FT BC" 12 "4yr H FT WC" 13 "4yr H PT BC" 14 "4yr H PT WC" 15 "4yr H only" 16 "work PT only BC" 17 "work PT only WC" 18 "work FT only BC" 19 "work FT only WC" 20 "home production" 21 "grad school FT BC" 22 "grad school FT WC" 23 "grad school PT BC" 24 "grad school PT WC" 25 "grad school only"

forv t=1/10 {
    replace choice`t' = 18 if choice`t'==1  & grad_4yr`t'==1
    replace choice`t' = 19 if choice`t'==2  & grad_4yr`t'==1
    replace choice`t' = 16 if choice`t'==3  & grad_4yr`t'==1
    replace choice`t' = 17 if choice`t'==4  & grad_4yr`t'==1
    replace choice`t' = 20 if choice`t'==5  & grad_4yr`t'==1
    lab val choice`t' vlchoice
}

//save CflDataWide.dta, replace
//outsheet using CflDataWide.csv, comma replace

egen id_draw = group(id simno)
reshape long choice lmstate WCoffer grad_4yr, i(id_draw) j(t)
xtset id_draw t
sort id simno t

ren abil1 abil2yr 
ren abil2 abil4yrS
ren abil3 abil4yrH
ren abil4 abilWC  
ren abil5 abilBC  

gen prev_grad_4yr = 0
bys id_draw (t): replace prev_grad_4yr = grad_4yr[_n-1]
gen  fut_grad_4yr = 0
bys id_draw (t): replace  fut_grad_4yr = grad_4yr[_n+1]

* check correlation and covariance matrices
corr abilWC abilBC abil4yrS abil4yrH abil2yr if t==1
corr abilWC abilBC abil4yrS abil4yrH abil2yr if t==1, covariance

sum abil* if t==1
sum abil* if t==10 & grad_4yr==1

tab unobtype
tab unobtype if grad_4yr==1
tab unobtype if t==10, sum(grad_4yr)

tab choice
tab choice if grad_4yr==1
tab choice if grad_4yr==0
tab choice if fut_grad_4yr==1 & grad_4yr==0
tab choice if grad_4yr==1 & prev_grad_4yr==0

qui tabout choice                using "${datloc}choiceAbilsOvrl.tex", replace c( mean abilWC mean abilBC mean abil4yrS mean abil4yrH mean abil2yr) f(4) sum clab( mean_abilWC mean_abilBC mean_abil4yrS mean_abil4yrH mean_abil2yr ) style(tex)
qui tabout choice if grad_4yr==1 using "${datloc}choiceAbilsGrad.tex", replace c( mean abilWC mean abilBC mean abil4yrS mean abil4yrH mean abil2yr) f(4) sum clab( mean_abilWC mean_abilBC mean_abil4yrS mean_abil4yrH mean_abil2yr ) style(tex)

tab choice               , sum(abilWC)
tab choice if grad_4yr==1, sum(abilWC)
tab choice if grad_4yr==0, sum(abilWC)
tab choice               , sum(abilBC)
tab choice if grad_4yr==1, sum(abilBC)
tab choice if grad_4yr==0, sum(abilBC)
tab choice               , sum(abil4yrS)
tab choice if grad_4yr==1, sum(abil4yrS)
tab choice if grad_4yr==0, sum(abil4yrS)
tab choice               , sum(abil4yrH)
tab choice if grad_4yr==1, sum(abil4yrH)
tab choice if grad_4yr==0, sum(abil4yrH)
tab choice               , sum(abil2yr)
tab choice if grad_4yr==1, sum(abil2yr)
tab choice if grad_4yr==0, sum(abil2yr)

sum WCoffer
sum WCoffer if grad_4yr==1
sum WCoffer if grad_4yr==0
gen prev_WC = 0
bys id_draw (t): replace prev_WC = inlist(choice[_n-1],2,4,7,9,12,14,17,19) if grad_4yr==0
bys id_draw (t): replace prev_WC = inlist(choice[_n-1],17,19,22,24)         if grad_4yr==1
sum WCoffer if prev_WC==1
sum WCoffer if prev_WC==0
sum WCoffer if prev_WC==1 & grad_4yr==0
sum WCoffer if prev_WC==0 & grad_4yr==0
sum WCoffer if prev_WC==1 & grad_4yr==1
sum WCoffer if prev_WC==0 & grad_4yr==1

save ${datloc}CflData.dta, replace

* create table like in model fit
* Running cumulative choice variables
gen in_2yr      = inrange(choice,1,5)
gen in_4yr      = inrange(choice,6,15)
gen in_college  = inrange(choice,1,15)
gen workFT      = inlist( choice,1,2,6,7,11,12,18,19)
gen workPT      = inlist( choice,3,4,8,9,13,14,16,17)
gen whiteCollar = inlist( choice,2,4,7,9,12,14,17,19)
bys id_draw (t): gen Lchoice              =     L.choice 
bys id_draw (t): gen cum_2yr              = sum(L.in_2yr)
bys id_draw (t): gen cum_4yr              = sum(L.in_4yr)
bys id_draw (t): gen cum_college          = sum(L.in_college)
bys id_draw (t): gen experFT              = sum(L.workFT)
bys id_draw (t): gen experPT              = sum(L.workPT)
            gen exper                = experFT+.5*experPT
bys id_draw (t): gen experFT_white_collar = sum((L.workFT==1)*(L.whiteCollar==1))
bys id_draw (t): gen experPT_white_collar = sum((L.workPT==1)*(L.whiteCollar==1))
            gen exper_white_collar   = experFT_white_collar+.5*experPT_white_collar

gen firstCol = 100*(choice>0  & choice<16 & cum_2yr==0 & cum_4yr==0)
gen first2yr = 100*(choice>0  & choice<6  & cum_2yr==0 & cum_4yr==0)
gen first4yr = 100*(choice>5  & choice<16 & cum_2yr==0 & cum_4yr==0)
gen leaveCol = 100*(choice>15 & ((cum_2yr+cum_4yr)>=1) & Lchoice>0  & Lchoice<16 & grad_4yr==0)
gen leave2yr = 100*(choice>15 & ((cum_2yr+cum_4yr)>=1) & Lchoice>0  & Lchoice<6  & grad_4yr==0)
gen leave4yr = 100*(choice>15 & ((cum_2yr+cum_4yr)>=1) & Lchoice>5  & Lchoice<16 & grad_4yr==0)
gen reentCol = 100*(choice>0  & choice<16 & ((cum_2yr+cum_4yr)>=1) & Lchoice>15 & grad_4yr==0)
gen reent2yr = 100*(choice>0  & choice<6  & ((cum_2yr+cum_4yr)>=1) & Lchoice>15 & grad_4yr==0)
gen reent4yr = 100*(choice>5  & choice<16 & ((cum_2yr+cum_4yr)>=1) & Lchoice>15 & grad_4yr==0)
gen grad100  = 100*grad_4yr

tab Lchoice choice, row nofreq

tab t, sum(firstCol) mean
tab t, sum(leaveCol) mean
tab t, sum(reentCol) mean
tab t, sum(grad100 ) mean

qui tabout t using "${datloc}modelFitCfl.tex", replace c( mean firstCol mean leaveCol mean reentCol mean grad100) f(2) sum clab( entry attrition reentry graduation ) style(tex)
qui tabout t using "${datloc}modelFitCflExt.tex", replace c( mean first2yr mean first4yr mean leave2yr mean leave4yr mean reent2yr mean reent4yr mean grad100) f(2) sum clab( entry2 entry4 attrition2 attrition4 reentry2 reentry4 graduation ) style(tex)
qui tabout t if WCoffer==1 using "${datloc}modelFitCflExtWC.tex", replace c( mean first2yr mean first4yr mean leave2yr mean leave4yr mean reent2yr mean reent4yr mean grad100) f(2) sum clab( entry2 entry4 attrition2 attrition4 reentry2 reentry4 graduation ) style(tex)
qui tabout t if WCoffer==0 using "${datloc}modelFitCflExtBC.tex", replace c( mean first2yr mean first4yr mean leave2yr mean leave4yr mean reent2yr mean reent4yr mean grad100) f(2) sum clab( entry2 entry4 attrition2 attrition4 reentry2 reentry4 graduation ) style(tex)

log close

