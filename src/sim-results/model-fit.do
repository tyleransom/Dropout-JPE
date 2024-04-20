version 13.0
clear all
set more off
capture log close
set seed 32

log using "model-fit.log", replace


* paths to results
global figpath  "../../exhibits/figures/" 
global tblpath  "../../exhibits/tables/" 
global tbljunk  "../../exhibits/tables/junk/" 
global Fwdpath  "../../output/model-fit/" 
global Cfl1path "../../output/cfl/baseline/" 
global Cfl2path "../../output/cfl/no-frictions/" 
global Cfl3path "../../output/cfl/no-cred-cons/" 

*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
* Prepare raw data to be compatible with model fit calculations
*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
tempfile dataPrepped
preserve
    insheet using ${Fwdpath}data.csv, comma clear
    ren v1  ID
    ren v2  badt
    ren v3  year
    ren v4  utype
    ren v5  umaj
    ren v6  ugpa
    ren v7  q
    ren v8  lambda
    ren v9  choice
    ren v10 grad_4yr
    ren v11 GPA
    ren v12 GPAraw
    recode GPA GPAraw (-999 = .)
    
    // merge m:1 ID using `demogsdata', keep(match master) nogen

    lab def vlchoice 1  "2-year & work FT blue collar" 2  "2-year & work FT white collar" 3  "2-year & work PT blue collar" 4  "2-year & work PT white collar" 5  "2-year only" 6  "4-year Science & work FT blue collar" 7  "4-year Science & work FT white collar" 8  "4-year Science & work PT blue collar" 9  "4-year Science & work PT white collar" 10 "4-year Science only" 11 "4-year Non-Science & work FT blue collar" 12 "4-year Non-Science & work FT white collar" 13 "4-year Non-Science & work PT blue collar" 14 "4-year Non-Science & work PT white collar" 15 "4-year Non-Science only" 16 "Work PT blue collar" 17 "Work PT white collar" 18 "Work FT blue collar" 19 "Work FT white collar" 20 "Home production"
    lab val choice vlchoice

    * check that imputed grades are lining up properly
    tab ugpa if ugpa>0 & mi(GPAraw), sum(GPA)

    * re-sort the data and create unique ID
    egen uID = group(ID utype ugpa umaj)
    bys ID ugpa umaj utype (badt): egen min_t = min(badt)
    gen t = badt-(min_t-1)
    sort ID ugpa umaj utype t
    order ID t utype ugpa umaj year
    drop min_t

    * check panel dimension of the data
    xtset uID t
    xtsum uID
    xtsum uID if utype==1 & (ugpa<=1) & (umaj<=1)

    * create variables
    bys uID (t): egen max_t = max(t)
    bys uID (t): gen  Lchoice = L.choice
    replace Lchoice = 20 if t==1
    l if inlist(ID,1,2,9), sepby(ID)
    lab val Lchoice vlchoice
    gen choiceCoarse  = 1*inrange(choice,1,5)  + 2*inrange(choice,6,10)  + 3*inrange(choice,11,15)  + 4*inlist(choice,16,18)  + 5*inlist(choice,17,19)  + 6*(choice==20)
    gen LchoiceCoarse = 1*inrange(Lchoice,1,5) + 2*inrange(Lchoice,6,10) + 3*inrange(Lchoice,11,15) + 4*inlist(Lchoice,16,18) + 5*inlist(Lchoice,17,19) + 6*(Lchoice==20)
    lab def vlchoicecoarse 1 "2yr" 2 "4yr Sci" 3 "4yr Hum" 4 "Work BC" 5 "Work WC" 6 "Home"
    lab val choiceCoarse  vlchoicecoarse
    lab val LchoiceCoarse vlchoicecoarse

    * create table like in model fit
    * Running cumulative choice variables
    gen in_2yr      = inrange(choice,1 ,5 )
    gen in_4yr      = inrange(choice,6 ,15)
    gen in_4yrS     = inrange(choice,6 ,10)
    gen in_4yrH     = inrange(choice,11,15)
    gen in_college  = inrange(choice,1 ,15)
    gen workFT      = inlist( choice,1,2,6,7,11,12,18,19)
    gen workPT      = inlist( choice,3,4,8,9,13,14,16,17)
    gen whiteCollar = inlist( choice,2,4,7,9,12,14,17,19)
    bys uID (t): gen prev_grad_4yr        =     L.grad_4yr
    bys uID (t): gen prev_PT              =     L.workPT
    bys uID (t): gen prev_FT              =     L.workFT
    bys uID (t): gen prev_WC              =     L.whiteCollar
    bys uID (t): gen cum_2yr              = sum(L.in_2yr)
    bys uID (t): gen cum_4yr              = sum(L.in_4yr)
    bys uID (t): gen cum_4yrS             = sum(L.in_4yrS)
    bys uID (t): gen cum_4yrH             = sum(L.in_4yrH)
    bys uID (t): gen cum_college          = sum(L.in_college)
    bys uID (t): gen cum_college_wrong    = sum(in_college)
    bys uID (t): gen experFT              = sum(L.workFT)
    bys uID (t): gen experPT              = sum(L.workPT)
                 gen exper                = experFT+.5*experPT
    bys uID (t): gen experFT_white_collar = sum((L.workFT==1)*(L.whiteCollar==1))
    bys uID (t): gen experPT_white_collar = sum((L.workPT==1)*(L.whiteCollar==1))
                 gen exper_white_collar   = experFT_white_collar+.5*experPT_white_collar

    * identify final major for those who graduated
    gen finalSci  = inrange(Lchoice,6,10) & prev_grad_4yr==0 & grad_4yr==1
    bys uID (t): egen finalSciMaj = max(finalSci)

    * compute work in school likelihood
    gen nw2yr  = 100*(inlist(choice,5    ))
    gen wc2yr  = 100*(inlist(choice,2 ,4 ))
    gen bc2yr  = 100*(inlist(choice,1 ,3 ))
    gen nw4yrS = 100*(inlist(choice,10   ))
    gen wc4yrS = 100*(inlist(choice,7 ,9 ))
    gen bc4yrS = 100*(inlist(choice,6 ,8 ))
    gen nw4yrH = 100*(inlist(choice,15   ))
    gen wc4yrH = 100*(inlist(choice,12,14))
    gen bc4yrH = 100*(inlist(choice,11,13))

    * compute entry, attrition, re-entry, and graduation events
    gen firstCol  = 100*(inrange(choice,1 ,15) & cum_2yr==0 & cum_4yr==0)
    gen first2yr  = 100*(inrange(choice,1 ,5 ) & cum_2yr==0 & cum_4yr==0)
    gen first4yr  = 100*(inrange(choice,6 ,15) & cum_2yr==0 & cum_4yr==0)
    gen first4yrS = 100*(inrange(choice,6 ,10) & cum_2yr==0 & cum_4yr==0)
    gen first4yrH = 100*(inrange(choice,11,15) & cum_2yr==0 & cum_4yr==0)
    gen contiCol  = 100*(inrange(choice,1 ,15) & inrange(Lchoice,1 ,15) & grad_4yr==0)
    gen conti2yr  = 100*(inrange(choice,1 ,5 ) & inrange(Lchoice,1 ,5 ) & grad_4yr==0)
    gen conti4yr  = 100*(inrange(choice,6 ,15) & inrange(Lchoice,6 ,15) & grad_4yr==0)
    gen conti4yrS = 100*(inrange(choice,6 ,10) & inrange(Lchoice,6 ,10) & grad_4yr==0)
    gen conti4yrH = 100*(inrange(choice,11,15) & inrange(Lchoice,11,15) & grad_4yr==0)
    gen truncCol  = 100*(inrange(choice,1 ,15) & t==max_t               & grad_4yr==0)
    gen trunc2yr  = 100*(inrange(choice,1 ,5 ) & t==max_t               & grad_4yr==0)
    gen trunc4yr  = 100*(inrange(choice,6 ,15) & t==max_t               & grad_4yr==0)
    gen trunc4yrS = 100*(inrange(choice,6 ,10) & t==max_t               & grad_4yr==0)
    gen trunc4yrH = 100*(inrange(choice,11,15) & t==max_t               & grad_4yr==0)
    gen leaveCol  = 100*(inrange(choice,16,20) & inrange(Lchoice,1 ,15) & grad_4yr==0)
    gen leave2yr  = 100*(inrange(choice,16,20) & inrange(Lchoice,1 ,5 ) & grad_4yr==0)
    gen leave4yr  = 100*(inrange(choice,16,20) & inrange(Lchoice,6 ,15) & grad_4yr==0)
    gen leave4yrS = 100*(inrange(choice,16,20) & inrange(Lchoice,6 ,10) & grad_4yr==0)
    gen leave4yrH = 100*(inrange(choice,16,20) & inrange(Lchoice,11,15) & grad_4yr==0)
    gen reentCol  = 100*(inrange(choice,1 ,15) & inrange(Lchoice,16,20) & ((cum_2yr+cum_4yr)>=1) & grad_4yr==0)
    gen reent2yr  = 100*(inrange(choice,1 ,5 ) & inrange(Lchoice,16,20) & ((cum_2yr+cum_4yr)>=1) & grad_4yr==0)
    gen reent4yr  = 100*(inrange(choice,6 ,15) & inrange(Lchoice,16,20) & ((cum_2yr+cum_4yr)>=1) & grad_4yr==0)
    gen reent4yrS = 100*(inrange(choice,6 ,10) & inrange(Lchoice,16,20) & ((cum_2yr+cum_4yr)>=1) & grad_4yr==0)
    gen reent4yrH = 100*(inrange(choice,11,15) & inrange(Lchoice,16,20) & ((cum_2yr+cum_4yr)>=1) & grad_4yr==0)
    gen grad100   = 100*grad_4yr
    gen gradS100  = 100*grad_4yr*finalSciMaj
    gen gradH100  = 100*grad_4yr*(1-finalSciMaj)

    * compute major switching rates
    gen switch2yr_to_4yr = 100*(inrange(choice,1 ,5 ) & inrange(Lchoice,6 ,15) & grad_4yr==0)
    gen switch4yr_to_2yr = 100*(inrange(choice,6 ,15) & inrange(Lchoice,1 ,5 ) & grad_4yr==0)
    gen switch4yrS_to_H  = 100*(inrange(choice,6 ,10) & inrange(Lchoice,11,15) & grad_4yr==0)
    gen switch4yrH_to_S  = 100*(inrange(choice,11,15) & inrange(Lchoice,6 ,10) & grad_4yr==0)

    save `dataPrepped', replace
restore


*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
* Prepare forward sim data (2 ways) to be compatible with model fit calcs
*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
foreach Dat in Fwd FwdStatic { 
    tempfile `Dat'SimPrepped
    preserve
        if "`Dat'"=="Fwd"       insheet using ${Fwdpath}fwdsimdata.csv,      comma clear
        if "`Dat'"=="FwdStatic" insheet using ${Fwdpath}fwdsimdataRFCCP.csv, comma clear 

        ren v1  ID
        ren v2  t
        ren v3  simno
        ren v4  year
        ren v5  num_periods_in_data
        ren v6  utype
        ren v7  WCoffer
        ren v8  choice
        ren v9  grad_4yr
        ren v10 trueAbilWC
        ren v11 trueAbilBC
        ren v12 trueAbil4S
        ren v13 trueAbil4H
        ren v14 trueAbil2 
        ren v15 posteriorAbilWC
        ren v16 posteriorAbilBC
        ren v17 posteriorAbil4S
        ren v18 posteriorAbil4H
        ren v19 posteriorAbil2 
        ren v20 famInc
    
        // merge m:1 ID using `demogsdata', keep(match master) keepusing(black hispanic HS_grades Parent_college birthYr) nogen
        // merge m:1 ID using `dataevergrad', keep(match master) nogen

        * convert abilities to SD units
        generat trueAbilWC_nsd  = trueAbilWC
        generat trueAbilBC_nsd  = trueAbilBC
        generat trueAbil4S_nsd  = trueAbil4S
        generat trueAbil4H_nsd  = trueAbil4H
        generat trueAbil2_nsd   = trueAbil2
        replace trueAbilWC      = trueAbilWC/sqrt(.16742)
        replace trueAbilBC      = trueAbilBC/sqrt(.083509)
        replace trueAbil4S      = trueAbil4S/sqrt(.41329)
        replace trueAbil4H      = trueAbil4H/sqrt(.40164)
        replace trueAbil2       = trueAbil2 /sqrt(.26046)
        replace posteriorAbilWC = posteriorAbilWC/sqrt(.16742)
        replace posteriorAbilBC = posteriorAbilBC/sqrt(.083509)
        replace posteriorAbil4S = posteriorAbil4S/sqrt(.41329)
        replace posteriorAbil4H = posteriorAbil4H/sqrt(.40164)
        replace posteriorAbil2  = posteriorAbil2 /sqrt(.26046)

        lab def vlchoice 1  "2-year & work FT blue collar" 2  "2-year & work FT white collar" 3  "2-year & work PT blue collar" 4  "2-year & work PT white collar" 5  "2-year only" 6  "4-year Science & work FT blue collar" 7  "4-year Science & work FT white collar" 8  "4-year Science & work PT blue collar" 9  "4-year Science & work PT white collar" 10 "4-year Science only" 11 "4-year Non-Science & work FT blue collar" 12 "4-year Non-Science & work FT white collar" 13 "4-year Non-Science & work PT blue collar" 14 "4-year Non-Science & work PT white collar" 15 "4-year Non-Science only" 16 "Work PT blue collar" 17 "Work PT white collar" 18 "Work FT blue collar" 19 "Work FT white collar" 20 "Home production"
        lab val choice vlchoice

        * sort the data
        egen uID = group(ID simno)
        sort ID simno t
        order ID t simno year utype

        * check panel dimension of the data
        xtset uID t
        xtsum uID
        xtsum uID if simno==1

        * create variables
        bys uID (t): gen  Lchoice = L.choice
        replace Lchoice = 20 if t==1
        l if inlist(ID,1,2,9), sepby(ID)
        lab val Lchoice vlchoice
        gen choiceCoarse  = 1*inrange(choice,1,5)  + 2*inrange(choice,6,10)  + 3*inrange(choice,11,15)  + 4*inlist(choice,16,18)  + 5*inlist(choice,17,19)  + 6*(choice==20)
        gen LchoiceCoarse = 1*inrange(Lchoice,1,5) + 2*inrange(Lchoice,6,10) + 3*inrange(Lchoice,11,15) + 4*inlist(Lchoice,16,18) + 5*inlist(Lchoice,17,19) + 6*(Lchoice==20)
        lab def vlchoicecoarse 1 "2yr" 2 "4yr Sci" 3 "4yr Hum" 4 "Work BC" 5 "Work WC" 6 "Home"
        lab val choiceCoarse  vlchoicecoarse
        lab val LchoiceCoarse vlchoicecoarse

        * create table like in model fit
        * Running cumulative choice variables
        gen in_2yr      = inrange(choice,1 ,5 )
        gen in_4yr      = inrange(choice,6 ,15)
        gen in_4yrS     = inrange(choice,6 ,10)
        gen in_4yrH     = inrange(choice,11,15)
        gen in_college  = inrange(choice,1 ,15)
        gen workFT      = inlist( choice,1,2,6,7,11,12,18,19)
        gen workPT      = inlist( choice,3,4,8,9,13,14,16,17)
        gen whiteCollar = inlist( choice,2,4,7,9,12,14,17,19)
        bys uID (t): gen prev_grad_4yr        =     L.grad_4yr
        bys uID (t): gen prev_PT              =     L.workPT
        bys uID (t): gen prev_FT              =     L.workFT
        bys uID (t): gen prev_WC              =     L.whiteCollar
        bys uID (t): gen cum_2yr              = sum(L.in_2yr)
        bys uID (t): gen cum_4yr              = sum(L.in_4yr)
        bys uID (t): gen cum_4yrS             = sum(L.in_4yrS)
        bys uID (t): gen cum_4yrH             = sum(L.in_4yrH)
        bys uID (t): gen cum_college          = sum(L.in_college)
        bys uID (t): gen cum_college_wrong    = sum(in_college)
        bys uID (t): gen experFT              = sum(L.workFT)
        bys uID (t): gen experPT              = sum(L.workPT)
                     gen exper                = experFT+.5*experPT
        bys uID (t): gen experFT_white_collar = sum((L.workFT==1)*(L.whiteCollar==1))
        bys uID (t): gen experPT_white_collar = sum((L.workPT==1)*(L.whiteCollar==1))
                     gen exper_white_collar   = experFT_white_collar+.5*experPT_white_collar

        * identify final major for those who graduated
        gen finalSci  = inrange(Lchoice,6,10) & prev_grad_4yr==0 & grad_4yr==1
        bys uID (t): egen finalSciMaj = max(finalSci)

        * compute work in school likelihood
        gen nw2yr  = 100*(inlist(choice,5    ))
        gen wc2yr  = 100*(inlist(choice,2 ,4 ))
        gen bc2yr  = 100*(inlist(choice,1 ,3 ))
        gen nw4yrS = 100*(inlist(choice,10   ))
        gen wc4yrS = 100*(inlist(choice,7 ,9 ))
        gen bc4yrS = 100*(inlist(choice,6 ,8 ))
        gen nw4yrH = 100*(inlist(choice,15   ))
        gen wc4yrH = 100*(inlist(choice,12,14))
        gen bc4yrH = 100*(inlist(choice,11,13))

        * compute entry, attrition, re-entry, and graduation events
        gen firstCol  = 100*(inrange(choice,1 ,15) & cum_2yr==0 & cum_4yr==0)
        gen first2yr  = 100*(inrange(choice,1 ,5 ) & cum_2yr==0 & cum_4yr==0)
        gen first4yr  = 100*(inrange(choice,6 ,15) & cum_2yr==0 & cum_4yr==0)
        gen first4yrS = 100*(inrange(choice,6 ,10) & cum_2yr==0 & cum_4yr==0)
        gen first4yrH = 100*(inrange(choice,11,15) & cum_2yr==0 & cum_4yr==0)
        gen contiCol  = 100*(inrange(choice,1 ,15) & inrange(Lchoice,1 ,15) & grad_4yr==0)
        gen conti2yr  = 100*(inrange(choice,1 ,5 ) & inrange(Lchoice,1 ,5 ) & grad_4yr==0)
        gen conti4yr  = 100*(inrange(choice,6 ,15) & inrange(Lchoice,6 ,15) & grad_4yr==0)
        gen conti4yrS = 100*(inrange(choice,6 ,10) & inrange(Lchoice,6 ,10) & grad_4yr==0)
        gen conti4yrH = 100*(inrange(choice,11,15) & inrange(Lchoice,11,15) & grad_4yr==0)
        gen truncCol  = 100*(inrange(choice,1 ,15) & t==num_periods_in_data & grad_4yr==0)
        gen trunc2yr  = 100*(inrange(choice,1 ,5 ) & t==num_periods_in_data & grad_4yr==0)
        gen trunc4yr  = 100*(inrange(choice,6 ,15) & t==num_periods_in_data & grad_4yr==0)
        gen trunc4yrS = 100*(inrange(choice,6 ,10) & t==num_periods_in_data & grad_4yr==0)
        gen trunc4yrH = 100*(inrange(choice,11,15) & t==num_periods_in_data & grad_4yr==0)
        gen leaveCol  = 100*(inrange(choice,16,20) & inrange(Lchoice,1 ,15) & grad_4yr==0)
        gen leave2yr  = 100*(inrange(choice,16,20) & inrange(Lchoice,1 ,5 ) & grad_4yr==0)
        gen leave4yr  = 100*(inrange(choice,16,20) & inrange(Lchoice,6 ,15) & grad_4yr==0)
        gen leave4yrS = 100*(inrange(choice,16,20) & inrange(Lchoice,6 ,10) & grad_4yr==0)
        gen leave4yrH = 100*(inrange(choice,16,20) & inrange(Lchoice,11,15) & grad_4yr==0)
        gen reentCol  = 100*(inrange(choice,1 ,15) & inrange(Lchoice,16,20) & ((cum_2yr+cum_4yr)>=1) & grad_4yr==0)
        gen reent2yr  = 100*(inrange(choice,1 ,5 ) & inrange(Lchoice,16,20) & ((cum_2yr+cum_4yr)>=1) & grad_4yr==0)
        gen reent4yr  = 100*(inrange(choice,6 ,15) & inrange(Lchoice,16,20) & ((cum_2yr+cum_4yr)>=1) & grad_4yr==0)
        gen reent4yrS = 100*(inrange(choice,6 ,10) & inrange(Lchoice,16,20) & ((cum_2yr+cum_4yr)>=1) & grad_4yr==0)
        gen reent4yrH = 100*(inrange(choice,11,15) & inrange(Lchoice,16,20) & ((cum_2yr+cum_4yr)>=1) & grad_4yr==0)
        gen grad100   = 100*grad_4yr
        gen gradS100  = 100*grad_4yr*finalSciMaj
        gen gradH100  = 100*grad_4yr*(1-finalSciMaj)

        * compute major switching rates
        gen switch2yr_to_4yr = 100*(inrange(choice,1 ,5 ) & inrange(Lchoice,6 ,15) & grad_4yr==0)
        gen switch4yr_to_2yr = 100*(inrange(choice,6 ,15) & inrange(Lchoice,1 ,5 ) & grad_4yr==0)
        gen switch4yrS_to_H  = 100*(inrange(choice,6 ,10) & inrange(Lchoice,11,15) & grad_4yr==0)
        gen switch4yrH_to_S  = 100*(inrange(choice,11,15) & inrange(Lchoice,6 ,10) & grad_4yr==0)

        * check correlation and covariance matrices
        corr trueAbilWC_nsd trueAbilBC_nsd trueAbil4S_nsd trueAbil4H_nsd trueAbil2_nsd if t==1
        corr trueAbilWC_nsd trueAbilBC_nsd trueAbil4S_nsd trueAbil4H_nsd trueAbil2_nsd if t==1, covariance

        drop *_nsd

        save ``Dat'SimPrepped', replace
    restore

    tempfile `Dat'SimPreppedT1
    preserve
        use ``Dat'SimPrepped', clear
        keep if t==1 & simno==1
        keep ID t num_periods_in_data
        codebook ID
        save ``Dat'SimPreppedT1', replace
    restore
}



*------------------------------------------------------------------------------
* summary stats on lambda
*------------------------------------------------------------------------------
preserve
    use `dataPrepped', clear
    count
    sum lambda [aw=q]
    local datalambda: di %5.4f `r(mean)'
    sum lambda if grad_4yr==1 [aw=q]
    local datalambdaG: di %5.4f `r(mean)'
    sum lambda if t<=10 [aw=q]
    sum lambda if grad_4yr==1 & t<=10 [aw=q]
    sum finalSciMaj [aw=q] if grad_4yr==1 & prev_grad_4yr==0
    tab prev_WC  [aw=q], sum(lambda) mean
    tab grad_4yr [aw=q], sum(lambda) mean
restore

foreach Dat in Fwd FwdStatic {
    preserve
        use ``Dat'SimPrepped', clear
        keep if t<=num_periods_in_data
        count
        sum WCoffer 
        local modllambda: di %5.4f `r(mean)'
        sum WCoffer if grad_4yr==1 
        local modllambdaG: di %5.4f `r(mean)'
        sum WCoffer if t<=10 
        sum WCoffer if grad_4yr==1 & t<=10 
        sum finalSciMaj  if grad_4yr==1 & prev_grad_4yr==0
        tab prev_WC  , sum(WCoffer) mean
        tab grad_4yr , sum(WCoffer) mean
    restore
}



*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
* Now do the comparisons we want
*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

*------------------------------------------------------------------------------
* Period-by-period college attrition and graduation (Table 10 from 2016 paper)
*------------------------------------------------------------------------------
* Collapse the raw data
tempfile dataT10
preserve
    use `dataPrepped', clear
    collapse (mean) first??? first???? leave??? leave???? reent??? reent???? grad*100 switch* nw??? bc??? wc??? nw???? bc???? wc???? [aw=q], by(t)
    l firstCol leaveCol reentCol grad100, sep(0)
    foreach v of varlist first??? first???? leave??? leave???? reent??? reent???? grad*100 switch* nw??? bc??? wc??? nw???? bc???? wc???? {
        ren `v' data`v'
    }
    save `dataT10', replace
restore

* Collapse the forward sim data
tempfile modelT10
preserve
    use `FwdSimPrepped', clear
    keep if t<=num_periods_in_data
    sum grad*
    xtsum uID
    collapse (mean) first??? first???? leave??? leave???? reent??? reent???? grad*100 switch* nw??? bc??? wc??? nw???? bc???? wc???? , by(t)
    foreach v of varlist first??? first???? leave??? leave???? reent??? reent???? grad*100 switch* nw??? bc??? wc??? nw???? bc???? wc???? {
        ren `v' model`v'
    }
    l modelfirstCol modelleaveCol modelreentCol modelgrad100, sep(0)
    save `modelT10', replace
restore


* make a model fit figure
preserve
    use `dataT10', clear
    merge 1:1 t using `modelT10', nogen
    collapse data1 = datafirstCol model1 = modelfirstCol data2 = dataleaveCol model2 = modelleaveCol data3 = datareentCol model3 = modelreentCol data4 = datagradS100 model4 = modelgradS100 data5 = datagradH100 model5 = modelgradH100 if t<=10, by(t)
    l
    reshape long data model, i(t) j(source)
    ren data Data
    ren model Model
    lab def vlsource 1 "College Entry" 2 "College Attrition" 3 "College Re-entry" 4 "Ever Graduate in Science" 5 "Ever Grad in Non-Science"
    lab val source vlsource
    l
    graph twoway (line Data Model t if t>=1 & source!=3, ytitle("Percentage") xtitle("Time Period" " ") ylabel(#6) xlabel(#10) xscale(range(1 10)) lpattern("-")), by(source, note("") yrescale ixaxes) scheme(s1mono) legend(size(*0.6))
    graph export "${figpath}modelFitByT.eps", replace
restore


* make a model fit figure of college sector-specific switching
preserve
    use `dataT10', clear
    merge 1:1 t using `modelT10', nogen
    collapse data1 = dataswitch2yr_to_4yr model1 = modelswitch2yr_to_4yr data2 = dataswitch4yr_to_2yr model2 = modelswitch4yr_to_2yr data3 = dataswitch4yrS_to_H model3 = modelswitch4yrS_to_H data4 = dataswitch4yrH_to_S model4 = modelswitch4yrH_to_S if t<=10, by(t)
    l
    reshape long data model, i(t) j(source)
    ren data Data
    ren model Model
    lab def vlsource 1 "2yr -> 4yr" 2 "4yr -> 2yr" 3 "Sci -> Non-Sci" 4 "Non-Sci -> Sci"
    lab val source vlsource
    l
    graph twoway (line Data Model t if t>=1, ytitle("Percentage") xtitle("Time Period" " ") ylabel(#6) xlabel(#10) xscale(range(1 10)) lpattern("-")), by(source, note("") yrescale ixaxes) scheme(s1mono) legend(size(*0.6))
    graph export "${figpath}modelFitColSwitchByT.eps", replace
restore


* make a model fit figure of college sector-specific entry
preserve
    use `dataT10', clear
    merge 1:1 t using `modelT10', nogen
    collapse data1 = datafirst2yr model1 = modelfirst2yr data2 = datafirst4yr model2 = modelfirst4yr data3 = datafirst4yrS model3 = modelfirst4yrS data4 = datafirst4yrH model4 = modelfirst4yrH if t<=10, by(t)
    l
    reshape long data model, i(t) j(source)
    ren data Data
    ren model Model
    lab def vlsource 1 "Never College -> 2yr" 2 "Never College -> 4yr" 3 "Never College -> Sci" 4 "Never College -> Non-Sci"
    lab val source vlsource
    l
    graph twoway (line Data Model t if t>=1, ytitle("Percentage") xtitle("Time Period" " ") ylabel(#6) xlabel(#10) xscale(range(1 10)) lpattern("-")), by(source, note("") yrescale ixaxes) scheme(s1mono) legend(size(*0.6))
    graph export "${figpath}modelFitColFirstEntryByT.eps", replace
restore


* make a model fit figure of college sector-specific re-entry
preserve
    use `dataT10', clear
    merge 1:1 t using `modelT10', nogen
    collapse data1 = datareent2yr model1 = modelreent2yr data2 = datareent4yr model2 = modelreent4yr data3 = datareent4yrS model3 = modelreent4yrS data4 = datareent4yrH model4 = modelreent4yrH if t<=10, by(t)
    l
    reshape long data model, i(t) j(source)
    ren data Data
    ren model Model
    lab def vlsource 1 "No College -> 2yr" 2 "No College -> 4yr" 3 "No College -> Sci" 4 "No College -> Non-Sci"
    lab val source vlsource
    l
    graph twoway (line Data Model t if t>=1, ytitle("Percentage") xtitle("Time Period" " ") ylabel(#6) xlabel(#10) xscale(range(1 10)) lpattern("-")), by(source, note("") yrescale ixaxes) scheme(s1mono) legend(size(*0.6))
    graph export "${figpath}modelFitColReentryByT.eps", replace
restore


* make a model fit figure of college sector-specific attrition
preserve
    use `dataT10', clear
    merge 1:1 t using `modelT10', nogen
    collapse data1 = dataleave2yr model1 = modelleave2yr data2 = dataleave4yr model2 = modelleave4yr data3 = dataleave4yrS model3 = modelleave4yrS data4 = dataleave4yrH model4 = modelleave4yrH if t<=10, by(t)
    l
    reshape long data model, i(t) j(source)
    ren data Data
    ren model Model
    lab def vlsource 1 "2yr -> No College" 2 "4yr -> No College" 3 "Sci -> No College" 4 "Non-Sci -> No College"
    lab val source vlsource
    l
    graph twoway (line Data Model t if t>=1, ytitle("Percentage") xtitle("Time Period" " ") ylabel(#6) xlabel(#10) xscale(range(1 10)) lpattern("-")), by(source, note("") yrescale ixaxes) scheme(s1mono) legend(size(*0.6))
    graph export "${figpath}modelFitColAttritByT.eps", replace
restore




*------------------------------------------------------------------------------
* Choice shares (Table 11 from 2016 paper)
*------------------------------------------------------------------------------
* Collapse the raw data
tempfile dataT11
preserve
    use `dataPrepped', clear
    gen ones = 1
    collapse (percent) ones [aw=q], by(choice)
    ren ones dataones
    save `dataT11', replace
restore
tempfile dataT11G
preserve
    use `dataPrepped', clear
    gen ones = 1
    collapse (percent) ones if grad_4yr==1 [aw=q], by(choice)
    ren ones dataones
    save `dataT11G', replace
restore
tempfile dataT11t10
preserve
    use `dataPrepped', clear
    gen ones = 1
    collapse (percent) ones if t<=10 [aw=q], by(choice)
    ren ones dataones
    save `dataT11t10', replace
restore
tempfile dataT11t10G
preserve
    use `dataPrepped', clear
    gen ones = 1
    collapse (percent) ones if t<=10 & grad_4yr==1 [aw=q], by(choice)
    ren ones dataones
    save `dataT11t10G', replace
restore
tempfile dataT11t1_2
preserve
    use `dataPrepped', clear
    gen ones = 1
    collapse (percent) ones if t<=2 [aw=q], by(choice)
    ren ones dataones
    save `dataT11t1_2', replace
restore
tempfile dataT11t3_5
preserve
    use `dataPrepped', clear
    gen ones = 1
    collapse (percent) ones if inrange(t,3,5) & grad_4yr==0 [aw=q], by(choice)
    ren ones dataones
    save `dataT11t3_5', replace
restore

* Collapse the forward sim data
tempfile modelT11
preserve
    use `FwdSimPrepped', clear
    keep if t<=num_periods_in_data
    gen ones = 1
    collapse (percent) ones (mean) trueAbil*, by(choice)
    foreach var of varlist ones trueAbil* {
        ren `var' model`var'
    }
    save `modelT11', replace
restore
tempfile modelT11G
preserve
    use `FwdSimPrepped', clear
    keep if t<=num_periods_in_data
    gen ones = 1
    collapse (percent) ones (mean) trueAbil* if grad_4yr==1, by(choice)
    foreach var of varlist ones trueAbil* {
        ren `var' model`var'
    }
    save `modelT11G', replace
restore
tempfile modelT11t10
preserve
    use `FwdSimPrepped', clear
    keep if t<=num_periods_in_data
    gen ones = 1
    collapse (percent) ones (mean) trueAbil* if t<=10, by(choice)
    foreach var of varlist ones trueAbil* {
        ren `var' model`var'
    }
    save `modelT11t10', replace
restore
tempfile modelT11t10G
preserve
    use `FwdSimPrepped', clear
    keep if t<=num_periods_in_data
    gen ones = 1
    collapse (percent) ones (mean) trueAbil* if t<=10 & grad_4yr==1, by(choice)
    foreach var of varlist ones trueAbil* {
        ren `var' model`var'
    }
    save `modelT11t10G', replace
restore
tempfile modelT11t1_2
preserve
    use `FwdSimPrepped', clear
    keep if t<=num_periods_in_data
    gen ones = 1
    collapse (percent) ones (mean) trueAbil* if t<=2, by(choice)
    foreach var of varlist ones trueAbil* {
        ren `var' model`var'
    }
    save `modelT11t1_2', replace
restore
tempfile modelT11t3_5
preserve
    use `FwdSimPrepped', clear
    keep if t<=num_periods_in_data
    gen ones = 1
    collapse (percent) ones (mean) trueAbil* if inrange(t,3,5) & grad_4yr==0 , by(choice)
    foreach var of varlist ones trueAbil* {
        ren `var' model`var'
    }
    save `modelT11t3_5', replace
restore

* Create the Model Fit Table
preserve
    use `dataT11', clear
    merge 1:1 choice using `modelT11', nogen
    qui tabout choice using "${tbljunk}T11stata.tex", replace c( mean dataones mean modelones) f(2) sum clab( datafreq modelfreq ) style(tex)
restore

* Create the Model Fit Table (grads only)
preserve
    use `dataT11G', clear
    merge 1:1 choice using `modelT11G', nogen
    qui tabout choice using "${tbljunk}T11stataG.tex", replace c( mean dataones mean modelones) f(2) sum clab( datafreq modelfreq ) style(tex)
restore

* export to prettier latex files
* full sample
!echo "% T11stata.tex" > ${tblpath}table-fit-choice-shrs.tex
!echo "\begin{table}[ht]" >> ${tblpath}table-fit-choice-shrs.tex
!echo "\caption{Model fit: Overall choice frequencies}" >> ${tblpath}table-fit-choice-shrs.tex
!echo "\label{tab:modelfit}" >> ${tblpath}table-fit-choice-shrs.tex
!echo "\centering{}" >> ${tblpath}table-fit-choice-shrs.tex
!echo "\begin{threeparttable}" >> ${tblpath}table-fit-choice-shrs.tex
!echo "\begin{tabular}{lcc}" >> ${tblpath}table-fit-choice-shrs.tex
!echo "\toprule" >> ${tblpath}table-fit-choice-shrs.tex
!echo "Choice alternative     & Data Frequency (\%) & Model Frequency (\%)\\\\" >> ${tblpath}table-fit-choice-shrs.tex
!echo "\midrule" >> ${tblpath}table-fit-choice-shrs.tex
!cat ${tbljunk}T11stata.tex | tail -21 | head -20 >> ${tblpath}table-fit-choice-shrs.tex
!echo "\bottomrule" >> ${tblpath}table-fit-choice-shrs.tex
!echo "\end{tabular}" >> ${tblpath}table-fit-choice-shrs.tex
!echo "\footnotesize Note: Model frequencies are constructed using 10 simulations of the structural model for each individual included in the estimation.  We set the panel length in the model to be the same as the panel length in the data. This is because the model assumes random attrition conditional on all observables and unobservables." >> ${tblpath}table-fit-choice-shrs.tex
!echo "" >> ${tblpath}table-fit-choice-shrs.tex
!echo "White collar offer probability in simulation is `modllambda' and in estimation is `datalambda'." >> ${tblpath}table-fit-choice-shrs.tex
!echo "\end{threeparttable}" >> ${tblpath}table-fit-choice-shrs.tex
!echo "\end{table}" >> ${tblpath}table-fit-choice-shrs.tex

* college graduates
!echo "% T11stataG.tex" > ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\clearpage" >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\begin{table}[ht]" >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\caption{Model fit: Graduate choice frequencies}" >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\label{tab:modelfitG}" >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\centering{}" >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\begin{threeparttable}" >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\begin{tabular}{lcc}" >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\toprule" >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "Choice alternative     & Data Frequency (\%) & Model Frequency (\%)\\\\" >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\midrule" >> ${tblpath}table-fit-choice-shrs-grad.tex
!cat ${tbljunk}T11stataG.tex | tail -6 | head -5 >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\bottomrule" >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\end{tabular}" >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\footnotesize Note: Model frequencies are constructed using 10 simulations of the structural model for each individual included in the estimation." >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "" >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "White collar offer probability in simulation is `modllambdaG' and in estimation is `datalambdaG'." >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\end{threeparttable}" >> ${tblpath}table-fit-choice-shrs-grad.tex
!echo "\end{table}" >> ${tblpath}table-fit-choice-shrs-grad.tex




*------------------------------------------------------------------------------
* Completion profiles (Table 14 from 2016 paper)
*------------------------------------------------------------------------------
* Collapse the raw data
tempfile dataT14
preserve
    use `dataPrepped', clear
    gen ones = 1
    drop if t>10
    generate           truncated = 100*( inrange(choice,1,15) & ((t==10 & max_t>=10) | (t==max_t)) )
    generate      work_in_school = 100*( !inlist(choice,5,10,15,16,17,18,19,20) )
    generate      work_BC_school = 100*(  inlist(choice,1,3,6,8,11,13) )
    generate      work_WC_school = 100*(  inlist(choice,2,4,7,9,12,14) )
    generate             work_BC = 100*(  inlist(choice,1,3,6,8,11,13,16,18) )
    generate             work_WC = 100*(  inlist(choice,2,4,7,9,12,14,17,19) )
    bys uID (t): egen ever_col   = max(firstCol)
    bys uID (t): egen ever_grad  = max(grad100)
    bys uID (t): egen ever_gradS = max(gradS100)
    bys uID (t): egen ever_gradH = max(gradH100)
    bys uID (t): egen ever_leave = max(leaveCol)
    bys uID (t): egen ever_reent = max(reentCol)
    bys uID (t): egen ever_trunc = max(truncated)
    bys uID (t): egen ever_BCsch = max(work_BC_school)
    bys uID (t): egen ever_WCsch = max(work_WC_school)
    bys uID (t): egen ever_BC    = max(work_BC)
    bys uID (t): egen ever_WC    = max(work_WC)
    bys uID (t): egen  num_BC    = sum(work_BC)
    bys uID (t): egen  num_WC    = sum(work_WC)

    * get period of last college enrollment
    gen lastcolA = t*inrange(choice,1,15)
    bys uID (t): egen last_col = max(lastcolA)
    replace last_col = max_t if last_col==0
    drop lastcolA
    
    * get sector of college entry
    gen first2yrA  = t if inrange(choice,1,5)
    bys uID (t): egen first_2yr = min(first2yrA)
    gen first4yrSA = t if inrange(choice,6,10)
    bys uID (t): egen first_4yrS = min(first4yrSA)
    gen first4yrHA = t if inrange(choice,11,15)
    bys uID (t): egen first_4yrH = min(first4yrHA)
    gen enter_2yr  = first_2yr  < first_4yrS & first_2yr  < first_4yrH
    gen enter_4yrS = first_4yrS < first_2yr  & first_4yrS < first_4yrH
    gen enter_4yrH = first_4yrH < first_2yr  & first_4yrH < first_4yrS
    drop first?yr*A
    
    * get years of schooling completed as of last year of college
    bys uID (t): egen dox = mean(cum_college_wrong) if t==last_col
    bys uID (t): egen tot_yrs_col = mean(dox)
    drop dox
    
    * get years of work as of last year in data
    bys uID (t): egen dbx = max(num_BC)
    bys uID (t): egen dwx = max(num_WC)
    gen mostly_WC = 100*(dwx>=dbx & ever_BC==100 & ever_WC==100)
    drop dbx dwx
    
    generat CCDOSO = .
    replace CCDOSO = 1 if ever_gradS==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0
    replace CCDOSO = 2 if ever_gradH==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0
    replace CCDOSO = 3 if ever_gradS==100 & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0
    replace CCDOSO = 4 if ever_gradH==100 & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0
    replace CCDOSO = 5 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0
    replace CCDOSO = 6 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0
    replace CCDOSO = 7 if ever_col==0
    replace CCDOSO = 8 if ever_trunc==100
    replace CCDOSO = 2 if ever_gradH==100 & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 // one person with mis-timed graduation (ID==108)
    lab def vlCCDOSO 1  "Continuous completion (CC), Science" 2  "Continuous completion (CC), Non-Science" 3  "Stop out (SO) but graduated Science" 4  "Stop out (SO) but graduated Non-Science" 5  "Stop out (SO) then drop out" 6  "Drop out (DO)" 7  "Never went to college" 8  "Truncated"
    lab val CCDOSO vlCCDOSO
    mdesc CCDOSO

    generat CCDOSOdetail = .
    replace CCDOSOdetail = 1  if ever_gradS==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==0   & ever_WCsch==0
    replace CCDOSOdetail = 2  if ever_gradS==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==0   & ever_WCsch==100
    replace CCDOSOdetail = 3  if ever_gradS==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==100 & ever_WCsch==0  
    replace CCDOSOdetail = 4  if ever_gradS==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==100 & ever_WCsch==100
    replace CCDOSOdetail = 5  if ever_gradH==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==0   & ever_WCsch==0  
    replace CCDOSOdetail = 6  if ever_gradH==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==0   & ever_WCsch==100 
    replace CCDOSOdetail = 7  if ever_gradH==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==100 & ever_WCsch==0   
    replace CCDOSOdetail = 8  if ever_gradH==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==100 & ever_WCsch==100 
    replace CCDOSOdetail = 9  if ever_gradS==100 & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0
    replace CCDOSOdetail = 10 if ever_gradH==100 & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0
    replace CCDOSOdetail = 11 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0 & enter_2yr
    replace CCDOSOdetail = 12 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0 & enter_4yrS
    replace CCDOSOdetail = 13 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0 & enter_4yrH
    replace CCDOSOdetail = 14 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==1
    replace CCDOSOdetail = 15 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==2
    replace CCDOSOdetail = 16 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==3
    replace CCDOSOdetail = 17 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==4
    replace CCDOSOdetail = 18 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col>=5
    replace CCDOSOdetail = 19 if ever_col==0
    replace CCDOSOdetail = 20 if ever_trunc==100
    replace CCDOSOdetail = 6  if ever_gradH==100 & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 // one person with mis-timed graduation (ID==108)
    lab def vlCCDOSOdetail 1  "\\$x=0\$" 2  "\\$x>0\$, white collar only" 3  "\\$x>0\$, blue collar only" 4  "\\$x>0\$, mixture" 5  "\\$x=0\$"                    6  "\\$x>0\$, white collar only"  7  "\\$x>0\$, blue collar only"   8  "\\$x>0\$, mixture"            9  "SO, graduate in science" 10 "SO, graduate in non-science" 11 "SO then DO, start in 2yr" 12 "SO then DO, start in science" 13 "SO then DO, start in non-science" 14 "\\$x=1\$" 15 "\\$x=2\$" 16 "\\$x=3\$" 17 "\\$x=4\$" 18 "\\$x\geq5\$" 19 "Never attend college" 20 "Truncated"
    lab val CCDOSOdetail vlCCDOSOdetail
    mdesc CCDOSOdetail
    tab CCDOSOdetail CCDOSO, mi
    l ID t choice grad_4yr ever_col ever_leave ever_reent ever_grad if mi(CCDOSO), sepby(uID)
    generat workpath = .
    replace workpath = 1 if ever_WC==100 & ever_BC==0   & ever_trunc==0
    replace workpath = 2 if ever_WC==0   & ever_BC==100 & ever_trunc==0 
    replace workpath = 3 if ever_WC==100 & ever_BC==100 & mostly_WC==100 & ever_trunc==0
    replace workpath = 4 if ever_WC==100 & ever_BC==100 & mostly_WC==0   & ever_trunc==0
    replace workpath = 5 if ever_WC==0   & ever_BC==0   & ever_trunc==0
    replace workpath = 6 if ever_trunc==100
    lab def vlworkpath 1  "White collar only" 2  "Blue collar only" 3  "Mixture, white collar modal" 4  "Mixture, blue collar modal" 5  "Never worked" 6  "Truncated"
    lab val workpath vlworkpath
    tab workpath
    mdesc workpath
    save `dataT14', replace
restore

tempfile dataT14c
tempfile dataT14ctrunc
preserve
    use `dataT14', clear
    collapse (percent) ones if t==1 & CCDOSO<8 [aw=q], by(CCDOSO) // 36.3% of people are truncated! (because of how we impose missing major/GPA) 
    ren ones dataones
    save `dataT14c', replace
    use `dataT14', clear
    collapse (percent) ones if t==1 [aw=q], by(CCDOSO) 
    ren ones dataones
    save `dataT14ctrunc', replace
restore

* Collapse the forward sim data (two ways)
foreach Dat in Fwd FwdStatic { 
    tempfile model`Dat'T14
    preserve
        use ``Dat'SimPrepped', clear
        keep if t<=num_periods_in_data
        gen ones = 1
        drop if t>10
        generate           truncated = 100*( inrange(choice,1,15) & ((t==10 & num_periods_in_data>=10) | (t==num_periods_in_data)) )
        generate      work_in_school = 100*( !inlist(choice,5,10,15,16,17,18,19,20) )
        generate      work_BC_school = 100*(  inlist(choice,1,3,6,8,11,13) )
        generate      work_WC_school = 100*(  inlist(choice,2,4,7,9,12,14) )
        generate             work_BC = 100*(  inlist(choice,1,3,6,8,11,13,16,18) )
        generate             work_WC = 100*(  inlist(choice,2,4,7,9,12,14,17,19) )
        bys uID (t): egen ever_col   = max(firstCol)
        bys uID (t): egen ever_grad  = max(grad100)
        bys uID (t): egen ever_gradS = max(gradS100)
        bys uID (t): egen ever_gradH = max(gradH100)
        bys uID (t): egen ever_leave = max(leaveCol)
        bys uID (t): egen ever_reent = max(reentCol)
        bys uID (t): egen ever_trunc = max(truncated)
        bys uID (t): egen ever_BCsch = max(work_BC_school)
        bys uID (t): egen ever_WCsch = max(work_WC_school)
        bys uID (t): egen ever_BC    = max(work_BC)
        bys uID (t): egen ever_WC    = max(work_WC)
        bys uID (t): egen  num_BC    = sum(work_BC)
        bys uID (t): egen  num_WC    = sum(work_WC)

        * get period of last college enrollment
        gen lastcolA = t*inrange(choice,1,15)
        bys uID (t): egen last_col = max(lastcolA)
        replace last_col = num_periods_in_data if last_col==0
        drop lastcolA
        
        * get sector of college entry
        gen first2yrA  = t if inrange(choice,1,5)
        bys uID (t): egen first_2yr = min(first2yrA)
        gen first4yrSA = t if inrange(choice,6,10)
        bys uID (t): egen first_4yrS = min(first4yrSA)
        gen first4yrHA = t if inrange(choice,11,15)
        bys uID (t): egen first_4yrH = min(first4yrHA)
        gen enter_2yr  = first_2yr  < first_4yrS & first_2yr  < first_4yrH
        gen enter_4yrS = first_4yrS < first_2yr  & first_4yrS < first_4yrH
        gen enter_4yrH = first_4yrH < first_2yr  & first_4yrH < first_4yrS
        drop first?yr*A
        
        * get years of schooling completed as of last year of college
        bys uID (t): egen dox = mean(cum_college_wrong) if t==last_col
        bys uID (t): egen tot_yrs_col = mean(dox)
        drop dox
        
        * get years of work as of last year in data
        bys uID (t): egen dbx = max(num_BC)
        bys uID (t): egen dwx = max(num_WC)
        gen mostly_WC = 100*(dwx>=dbx & ever_BC==100 & ever_WC==100)
        drop dbx dwx
        
        generat CCDOSO = .
        replace CCDOSO = 1 if ever_gradS==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0
        replace CCDOSO = 2 if ever_gradH==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0
        replace CCDOSO = 3 if ever_gradS==100 & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0
        replace CCDOSO = 4 if ever_gradH==100 & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0
        replace CCDOSO = 5 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0
        replace CCDOSO = 6 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0
        replace CCDOSO = 7 if ever_col==0
        replace CCDOSO = 8 if ever_trunc==100
        replace CCDOSO = 2 if ever_gradH==100 & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 // one person with mis-timed graduation (ID==108)
        lab def vlCCDOSO 1  "Continuous completion (CC), Science" 2  "Continuous completion (CC), Non-Science" 3  "Stop out (SO) but graduated Science" 4  "Stop out (SO) but graduated Non-Science" 5  "Stop out (SO) then drop out" 6  "Drop out (DO)" 7  "Never went to college" 8  "Truncated"
        lab val CCDOSO vlCCDOSO
        mdesc CCDOSO

        generat CCDOSOdetail = .
        replace CCDOSOdetail = 1  if ever_gradS==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==0   & ever_WCsch==0
        replace CCDOSOdetail = 2  if ever_gradS==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==0   & ever_WCsch==100
        replace CCDOSOdetail = 3  if ever_gradS==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==100 & ever_WCsch==0  
        replace CCDOSOdetail = 4  if ever_gradS==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==100 & ever_WCsch==100
        replace CCDOSOdetail = 5  if ever_gradH==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==0   & ever_WCsch==0  
        replace CCDOSOdetail = 6  if ever_gradH==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==0   & ever_WCsch==100 
        replace CCDOSOdetail = 7  if ever_gradH==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==100 & ever_WCsch==0   
        replace CCDOSOdetail = 8  if ever_gradH==100 & ever_col==100 & ever_leave==0   & ever_reent==0   & ever_trunc==0 & ever_BCsch==100 & ever_WCsch==100 
        replace CCDOSOdetail = 9  if ever_gradS==100 & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0
        replace CCDOSOdetail = 10 if ever_gradH==100 & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0
        replace CCDOSOdetail = 11 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0 & enter_2yr
        replace CCDOSOdetail = 12 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0 & enter_4yrS
        replace CCDOSOdetail = 13 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==100 & ever_trunc==0 & enter_4yrH
        replace CCDOSOdetail = 14 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==1
        replace CCDOSOdetail = 15 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==2
        replace CCDOSOdetail = 16 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==3
        replace CCDOSOdetail = 17 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==4
        replace CCDOSOdetail = 18 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col>=5
        replace CCDOSOdetail = 19 if ever_col==0
        replace CCDOSOdetail = 20 if ever_trunc==100
        replace CCDOSOdetail = 6  if ever_gradH==100 & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 // one person with mis-timed graduation (ID==108)
        lab def vlCCDOSOdetail 1  "\\$x=0\$" 2  "\\$x>0\$, white collar only" 3  "\\$x>0\$, blue collar only" 4  "\\$x>0\$, mixture" 5  "\\$x=0\$"                    6  "\\$x>0\$, white collar only"  7  "\\$x>0\$, blue collar only"   8  "\\$x>0\$, mixture"            9  "SO, graduate in science" 10 "SO, graduate in non-science" 11 "SO then DO, start in 2yr" 12 "SO then DO, start in science" 13 "SO then DO, start in non-science" 14 "\\$x=1\$" 15 "\\$x=2\$" 16 "\\$x=3\$" 17 "\\$x=4\$" 18 "\\$x\geq5\$" 19 "Never attend college" 20 "Truncated"
        lab val CCDOSOdetail vlCCDOSOdetail
        mdesc CCDOSOdetail
        tab CCDOSOdetail CCDOSO, mi
        l ID t choice grad_4yr ever_col ever_leave ever_reent ever_grad if mi(CCDOSO), sepby(uID)
        generat workpath = .
        replace workpath = 1 if ever_WC==100 & ever_BC==0   & ever_trunc==0
        replace workpath = 2 if ever_WC==0   & ever_BC==100 & ever_trunc==0 
        replace workpath = 3 if ever_WC==100 & ever_BC==100 & mostly_WC==100 & ever_trunc==0
        replace workpath = 4 if ever_WC==100 & ever_BC==100 & mostly_WC==0   & ever_trunc==0
        replace workpath = 5 if ever_WC==0   & ever_BC==0   & ever_trunc==0
        replace workpath = 6 if ever_trunc==100
        lab def vlworkpath 1  "White collar only" 2  "Blue collar only" 3  "Mixture, white collar modal" 4  "Mixture, blue collar modal" 5  "Never worked" 6  "Truncated"
        lab val workpath vlworkpath
        tab workpath
        mdesc workpath
        save `model`Dat'T14', replace
    restore

    tempfile model`Dat'T14c
    tempfile model`Dat'T14ctrunc
    preserve
        use `model`Dat'T14', clear
        collapse (percent) ones if t==1 & CCDOSO<8 , by(CCDOSO) 
        ren ones model`Dat'ones
        save `model`Dat'T14c', replace
        use `model`Dat'T14', clear
        collapse (percent) ones if t==1 , by(CCDOSO) 
        ren ones model`Dat'ones
        save `model`Dat'T14ctrunc', replace
    restore
}

* Create the Table (excluding "truncated" category)
preserve
    use `dataT14c', clear
    merge 1:1 CCDOSO using `modelFwdT14c', nogen
    merge 1:1 CCDOSO using `modelFwdStaticT14c', nogen
    qui tabout CCDOSO using "${tbljunk}T14stata.tex", replace c( mean dataones mean modelFwdones mean modelFwdStaticones) f(2) sum clab( datafreq modelFwdfreq modelFwdStaticfreq ) style(tex)
restore

* Create the Table (including "truncated" category)
preserve
    use `dataT14ctrunc', clear
    merge 1:1 CCDOSO using `modelFwdT14ctrunc', nogen
    merge 1:1 CCDOSO using `modelFwdStaticT14ctrunc', nogen
    qui tabout CCDOSO using "${tbljunk}T14truncstata.tex", replace c( mean dataones mean modelFwdones mean modelFwdStaticones) f(2) sum clab( datafreq modelFwdfreq modelFwdStaticfreq ) style(tex)
restore

* export to prettier latex version
!echo "% source is T14truncstata.tex" > ${tblpath}table-comp-status-fit.tex
!echo "\begin{table}[ht]" >> ${tblpath}table-comp-status-fit.tex
!echo "\caption{College completion status frequencies: data, baseline model, static model}" >> ${tblpath}table-comp-status-fit.tex
!echo "\label{tab:CCDOSOfit}" >> ${tblpath}table-comp-status-fit.tex
!echo "\centering{}" >> ${tblpath}table-comp-status-fit.tex
!echo "\begin{threeparttable}" >> ${tblpath}table-comp-status-fit.tex
!echo "\begin{tabular}{lccc}" >> ${tblpath}table-comp-status-fit.tex
!echo "\toprule" >> ${tblpath}table-comp-status-fit.tex
!echo "                                          &      & Baseline & Static \\\\" >> ${tblpath}table-comp-status-fit.tex
!echo "Status                                    & Data & model    & model  \\\\" >> ${tblpath}table-comp-status-fit.tex
!echo "\midrule" >> ${tblpath}table-comp-status-fit.tex
!cat ${tbljunk}T14truncstata.tex | tail -9 | head -8 >> ${tblpath}table-comp-status-fit.tex
!echo "\bottomrule" >> ${tblpath}table-comp-status-fit.tex
!echo "\end{tabular}" >> ${tblpath}table-comp-status-fit.tex
!echo "\footnotesize Notes: Model frequencies are constructed using 10 simulations of the structural model for each individual included in the estimation. Counterfactual frequencies use 10 simulations of each counterfactual model. We set the panel length in the model to be the same as the panel length in the data. This is because the model assumes random attrition conditional on all observables and unobservables. " >> ${tblpath}table-comp-status-fit.tex
!echo "" >> ${tblpath}table-comp-status-fit.tex
!echo "\medskip" >> ${tblpath}table-comp-status-fit.tex
!echo "" >> ${tblpath}table-comp-status-fit.tex
!echo "Completion status is computed on the first 10 periods of data (i.e. assuming that college is not an option after period 10)." >> ${tblpath}table-comp-status-fit.tex
!echo "" >> ${tblpath}table-comp-status-fit.tex
!echo "\medskip" >> ${tblpath}table-comp-status-fit.tex
!echo "" >> ${tblpath}table-comp-status-fit.tex
!echo "`=char(92)'`=char(96)'""`=char(92)'`=char(96)'""Truncated'' refers to those who were enrolled in period 10." >> ${tblpath}table-comp-status-fit.tex
!echo "\end{threeparttable}" >> ${tblpath}table-comp-status-fit.tex
!echo "\end{table}" >> ${tblpath}table-comp-status-fit.tex


log close

