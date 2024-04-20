version 13.0
clear all
set more off
capture log close

log using "cfl.log", replace

* paths to results
global tblpath  "../../exhibits/tables/" 
global tbljunk  "../../exhibits/tables/junk/" 
global Fwdpath  "../../output/model-fit/" 
global Cfl1path "../../output/cfl/baseline/" 
global Cfl2path "../../output/cfl/no-frictions/" 
global Cfl3path "../../output/cfl/no-cred-cons/" 

* put estimated ability variances in macros for later use
local varWC 0.12991
local varBC 0.07238
local var4S 0.20748
local var4H 0.27352
local var2  0.35283

local var2WC: di %3.2f `varWC'
local var2BC: di %3.2f `varBC'
local var24S: di %3.2f `var4S'
local var24H: di %3.2f `var4H'
local var22 : di %3.2f `var2'

*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
* Prepare forward sim data to be compatible with model fit calculations
*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
foreach Dat in Fwd FwdStatic { 
tempfile `Dat'SimPrepped
tempfile `Dat'SimPreppedrich
tempfile `Dat'SimPreppedpoor
preserve
    if "`Dat'"=="Fwd"       insheet using ${Fwdpath}fwdsimdata.csv,      comma clear
    if "`Dat'"=="FwdStatic" insheet using ${Fwdpath}fwdsimdataRFCCP.csv, comma clear 
    if "`Dat'"=="Fwd" {
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
    ren v20 posteriorVarWC
    ren v21 posteriorVarBC
    ren v22 posteriorVar4S
    ren v23 posteriorVar4H
    ren v24 posteriorVar2 
    ren v25 black
    ren v26 hispanic
    ren v27 HS_grades
    ren v28 Parent_college
    ren v29 birthYr
    ren v30 famInc
    }
    else if "`Dat'"=="FwdStatic" {
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
        gen posteriorVarWC = rnormal()
        gen posteriorVarBC = rnormal()
        gen posteriorVar4S = rnormal()
        gen posteriorVar4H = rnormal()
        gen posteriorVar2  = rnormal()
    }

    * generate rich/poor variable
    qui sum famInc, d
    local   tempFI = `r(p50)'
    generat rich   = famInc > `tempFI'
    di "how many rich?"
    count
    count if rich
    count if rich

    * only use first 10 periods
    keep if t<=10

    * convert abilities to SD units
    generat trueAbilWC_nsd  = trueAbilWC
    generat trueAbilBC_nsd  = trueAbilBC
    generat trueAbil4S_nsd  = trueAbil4S
    generat trueAbil4H_nsd  = trueAbil4H
    generat trueAbil2_nsd   = trueAbil2
    replace trueAbilWC      = trueAbilWC/sqrt(`varWC')
    replace trueAbilBC      = trueAbilBC/sqrt(`varBC')
    replace trueAbil4S      = trueAbil4S/sqrt(`var4S')
    replace trueAbil4H      = trueAbil4H/sqrt(`var4H')
    replace trueAbil2       = trueAbil2 /sqrt(`var2')
    replace posteriorAbilWC = posteriorAbilWC/sqrt(`varWC')
    replace posteriorAbilBC = posteriorAbilBC/sqrt(`varBC')
    replace posteriorAbil4S = posteriorAbil4S/sqrt(`var4S')
    replace posteriorAbil4H = posteriorAbil4H/sqrt(`var4H')
    replace posteriorAbil2  = posteriorAbil2 /sqrt(`var2')

    * generate posterior SDs instead of posterior variances
    gen posteriorSDWC = sqrt(posteriorVarWC)
    gen posteriorSDBC = sqrt(posteriorVarBC)
    gen posteriorSD4S = sqrt(posteriorVar4S)
    gen posteriorSD4H = sqrt(posteriorVar4H)
    gen posteriorSD2  = sqrt(posteriorVar2 )

    * generate deciles of blue collar ability
    xtile bcDecile = trueAbilBC, nq(10)

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

    * create variable for if ever switched major
    bys uID (t): egen ever_sci = max(in_4yrS)
    bys uID (t): egen ever_hum = max(in_4yrH)
    bys uID (t): egen ever4    = max(in_4yr)
                  gen switch_major = (ever_sci==1 & ever_hum==1)
    sum switch_major if ever4 & t==10
    global `Dat'SwiMaj = `=100*`r(mean)''
    sum switch_major if ever4 & t==10 &  rich
    global `Dat'SwiMajrich = `=100*`r(mean)''
    sum switch_major if ever4 & t==10 & !rich
    global `Dat'SwiMajpoor = `=100*`r(mean)''

    * measure time to degree
    bys uID (t): gen per_first_colA = t*(inrange(choice ,1 ,15) & cum_2yr==0 & cum_4yr==0)
    bys uID (t): gen per_last_colA  = t*(inrange(Lchoice,6 ,15) & grad_4yr==1)
    recode per_first_colA per_last_colA (0 = .)
    bys uID (t): egen per_first_col = mean(per_first_colA)
    bys uID (t): egen per_last_col  = mean(per_last_colA)
    gen time_to_degree = per_last_col - per_first_col
    drop per_first_colA per_last_colA
    sum time_to_degree if t==1
    sum time_to_degree if t==10
    global `Dat'TTD = `r(mean)'
    sum time_to_degree if t==10 &  rich
    global `Dat'TTDrich = `r(mean)'
    sum time_to_degree if t==10 & !rich
    global `Dat'TTDpoor = `r(mean)'

    * measure college graduation rate
    sum grad_4yr if t==10
    global `Dat'Grad4 = `=100*`r(mean)''
    sum grad_4yr if t==10 &  rich
    global `Dat'Grad4rich = `=100*`r(mean)''
    sum grad_4yr if t==10 & !rich
    global `Dat'Grad4poor = `=100*`r(mean)''

    * measure white collar offer arrival rate
    sum WCoffer if t<=10
    global `Dat'Lamb = `r(mean)'
    sum WCoffer if t<=10 & grad_4yr==0
    global `Dat'LambNG = `r(mean)'
    sum WCoffer if t<=10 & grad_4yr==1
    global `Dat'LambG = `r(mean)'

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
    gen truncCol  = 100*(inrange(choice,1 ,15) & t==10                  & grad_4yr==0)
    gen trunc2yr  = 100*(inrange(choice,1 ,5 ) & t==10                  & grad_4yr==0)
    gen trunc4yr  = 100*(inrange(choice,6 ,15) & t==10                  & grad_4yr==0)
    gen trunc4yrS = 100*(inrange(choice,6 ,10) & t==10                  & grad_4yr==0)
    gen trunc4yrH = 100*(inrange(choice,11,15) & t==10                  & grad_4yr==0)
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

    * check correlation and covariance matrices
    sum  trueAbilWC_nsd trueAbilBC_nsd trueAbil4S_nsd trueAbil4H_nsd trueAbil2_nsd if t==1
    sum  trueAbilWC     trueAbilBC     trueAbil4S     trueAbil4H     trueAbil2     if t==10
    corr trueAbilWC_nsd trueAbilBC_nsd trueAbil4S_nsd trueAbil4H_nsd trueAbil2_nsd if t==1
    corr trueAbilWC_nsd trueAbilBC_nsd trueAbil4S_nsd trueAbil4H_nsd trueAbil2_nsd if t==1, covariance

    * check magnitude of posterior SD over time
    sum  posteriorSDWC posteriorSDBC posteriorSD4S posteriorSD4H posteriorSD2 if t==1
    sum  posteriorSDWC posteriorSDBC posteriorSD4S posteriorSD4H posteriorSD2 if t==10

    save ``Dat'SimPrepped', replace
restore

preserve
    use  ``Dat'SimPrepped', clear
    keep if rich
    save ``Dat'SimPreppedrich', replace
restore

preserve
    use  ``Dat'SimPrepped', clear
    keep if !rich
    save ``Dat'SimPreppedpoor', replace
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


*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
* Prepare counterfactual data to be compatible with model fit calculations
*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
foreach Dat in Cfl CflNoFric CflNoCred { 
tempfile `Dat'SimPrepped
tempfile `Dat'SimPreppedrich
tempfile `Dat'SimPreppedpoor
preserve
    if "`Dat'"=="Cfl"       use ${Cfl1path}CflData, clear
    if "`Dat'"=="CflNoFric" use ${Cfl2path}CflData, clear
    if "`Dat'"=="CflNoCred" use ${Cfl3path}CflData, clear

    * generate rich/poor variable
    qui sum famInc, d
    local   tempFI = `r(p50)'
    generat rich   = famInc > `tempFI'
    di "how many rich?"
    count
    count if rich

    capture label drop vlchoice
    lab def vlchoice 1  "2-year & work FT blue collar" 2  "2-year & work FT white collar" 3  "2-year & work PT blue collar" 4  "2-year & work PT white collar" 5  "2-year only" 6  "4-year Science & work FT blue collar" 7  "4-year Science & work FT white collar" 8  "4-year Science & work PT blue collar" 9  "4-year Science & work PT white collar" 10 "4-year Science only" 11 "4-year Non-Science & work FT blue collar" 12 "4-year Non-Science & work FT white collar" 13 "4-year Non-Science & work PT blue collar" 14 "4-year Non-Science & work PT white collar" 15 "4-year Non-Science only" 16 "Work PT blue collar" 17 "Work PT white collar" 18 "Work FT blue collar" 19 "Work FT white collar" 20 "Home production"
    lab val choice vlchoice
    
    gen year = .
    drop id prev_grad_4yr fut_grad_4yr prev_WC
    ren nls_id    ID
    ren abilWC    trueAbilWC
    ren abilBC    trueAbilBC
    ren abil4yrS  trueAbil4S
    ren abil4yrH  trueAbil4H
    ren abil2yr   trueAbil2 
    ren unobtype  utype

    * only use first 10 periods
    keep if t<=10

    * convert true ability to SD units
    generat trueAbilWC_nsd = trueAbilWC
    generat trueAbilBC_nsd = trueAbilBC
    generat trueAbil4S_nsd = trueAbil4S
    generat trueAbil4H_nsd = trueAbil4H
    generat trueAbil2_nsd  = trueAbil2
    replace trueAbilWC = trueAbilWC/sqrt(`varWC')
    replace trueAbilBC = trueAbilBC/sqrt(`varBC')
    replace trueAbil4S = trueAbil4S/sqrt(`var4S')
    replace trueAbil4H = trueAbil4H/sqrt(`var4H')
    replace trueAbil2  = trueAbil2 /sqrt(`var2')

    * generate posterior SDs instead of posterior variances
    gen posteriorSDWC = 0
    gen posteriorSDBC = 0
    gen posteriorSD4S = 0
    gen posteriorSD4H = 0
    gen posteriorSD2  = 0

    * generate deciles of blue collar ability
    xtile bcDecile = trueAbilBC_nsd, nq(10)
    
    * merge in info on number of periods per person (in estimation data)
    codebook ID if t==1
    merge m:1 ID using `FwdSimPreppedT1', keepusing(num_periods_in_data) nogen
    ren num_periods_in_data npid
    bys ID (simno t): egen num_periods_in_data = max(npid)
    drop npid

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

    * create variable for if ever switched major
    bys uID (t): egen ever_sci = max(in_4yrS)
    bys uID (t): egen ever_hum = max(in_4yrH)
    bys uID (t): egen ever4    = max(in_4yr)
                  gen switch_major = (ever_sci==1 & ever_hum==1)
    sum switch_major if ever4 & t==10
    global `Dat'SwiMaj = `=100*`r(mean)''
    sum switch_major if ever4 & t==10 &  rich
    global `Dat'SwiMajrich = `=100*`r(mean)''
    sum switch_major if ever4 & t==10 & !rich
    global `Dat'SwiMajpoor = `=100*`r(mean)''

    * measure time to degree
    bys uID (t): gen per_first_colA = t*(inrange(choice ,1 ,15) & cum_2yr==0 & cum_4yr==0)
    bys uID (t): gen per_last_colA  = t*(inrange(Lchoice,6 ,15) & grad_4yr==1)
    recode per_first_colA per_last_colA (0 = .)
    bys uID (t): egen per_first_col = mean(per_first_colA)
    bys uID (t): egen per_last_col  = mean(per_last_colA)
    gen time_to_degree = per_last_col - per_first_col
    drop per_first_colA per_last_colA
    sum time_to_degree if t==1
    sum time_to_degree if t==10
    global `Dat'TTD = `r(mean)'
    sum time_to_degree if t==10 &  rich
    global `Dat'TTDrich = `r(mean)'
    sum time_to_degree if t==10 & !rich
    global `Dat'TTDpoor = `r(mean)'

    * measure college graduation rate
    sum grad_4yr if t==10
    global `Dat'Grad4 = `=100*`r(mean)''
    sum grad_4yr if t==10 &  rich
    global `Dat'Grad4rich = `=100*`r(mean)''
    sum grad_4yr if t==10 & !rich
    global `Dat'Grad4poor = `=100*`r(mean)''

    * measure white collar offer arrival rate
    sum WCoffer if t<=10
    global `Dat'Lamb = `r(mean)'
    sum WCoffer if t<=10 & grad_4yr==0
    global `Dat'LambNG = `r(mean)'
    sum WCoffer if t<=10 & grad_4yr==1
    global `Dat'LambG = `r(mean)'

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
    gen truncCol  = 100*(inrange(choice,1 ,15) & t==10                  & grad_4yr==0)
    gen trunc2yr  = 100*(inrange(choice,1 ,5 ) & t==10                  & grad_4yr==0)
    gen trunc4yr  = 100*(inrange(choice,6 ,15) & t==10                  & grad_4yr==0)
    gen trunc4yrS = 100*(inrange(choice,6 ,10) & t==10                  & grad_4yr==0)
    gen trunc4yrH = 100*(inrange(choice,11,15) & t==10                  & grad_4yr==0)
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

    * check correlation and covariance matrices
    sum  trueAbilWC_nsd trueAbilBC_nsd trueAbil4S_nsd trueAbil4H_nsd trueAbil2_nsd if t==1
    sum  trueAbilWC     trueAbilBC     trueAbil4S     trueAbil4H     trueAbil2     if t==10
    corr trueAbilWC_nsd trueAbilBC_nsd trueAbil4S_nsd trueAbil4H_nsd trueAbil2_nsd if t==1
    corr trueAbilWC_nsd trueAbilBC_nsd trueAbil4S_nsd trueAbil4H_nsd trueAbil2_nsd if t==1, covariance

    save ``Dat'SimPrepped', replace
restore

preserve
    use ``Dat'SimPrepped', clear
    keep if rich
    save ``Dat'SimPreppedrich', replace
restore

preserve
    use ``Dat'SimPrepped', clear
    keep if !rich
    save ``Dat'SimPreppedpoor', replace
restore
}


*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
* Now do the comparisons we want
*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

*------------------------------------------------------------------------------
* Table 14 from 2016 paper
*------------------------------------------------------------------------------
foreach Dat in Fwd FwdStatic Cfl CflNoFric CflNoCred { 
* Collapse the data
tempfile `Dat'T14
preserve
    use ``Dat'SimPrepped', clear
    gen ones = 1
    drop if t>10
    generate           truncated = 100*( inrange(choice,1,15) & t==10 )
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
    replace last_col = 10 if last_col==0
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
    replace CCDOSO = 7 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0
    replace CCDOSO = 8 if ever_col==0
    replace CCDOSO = 6 if ever_trunc==100
    replace CCDOSO = 2 if ever_gradH==100 & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 // one person with mis-timed graduation (ID==108)
    lab def vlCCDOSO 1  "Continuous completion (CC), Science" 2  "Continuous completion (CC), Non-Science" 3  "Stop out (SO) but graduated Science" 4  "Stop out (SO) but graduated Non-Science" 5  "Stop out (SO) then drop out" 6  "Truncated" 7  "Drop out (DO)" 8  "Never went to college"
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
    replace CCDOSOdetail = 15 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==1
    replace CCDOSOdetail = 16 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==2
    replace CCDOSOdetail = 17 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==3
    replace CCDOSOdetail = 18 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==4
    replace CCDOSOdetail = 19 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col>=5
    replace CCDOSOdetail = 20 if ever_col==0
    replace CCDOSOdetail = 14 if ever_trunc==100
    replace CCDOSOdetail = 6  if ever_gradH==100 & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 // one person with mis-timed graduation (ID==108)
    lab def vlCCDOSOdetail 1  "\\$x=0\$" 2  "\\$x>0\$, white collar only" 3  "\\$x>0\$, blue collar only" 4  "\\$x>0\$, mixture" 5  "\\$x=0\$"                    6  "\\$x>0\$, white collar only"  7  "\\$x>0\$, blue collar only"   8  "\\$x>0\$, mixture"            9  "SO, graduate in science" 10 "SO, graduate in non-science" 11 "SO then DO, start in 2yr" 12 "SO then DO, start in science" 13 "SO then DO, start in non-science" 14 "Truncated" 15 "\\$x=1\$" 16 "\\$x=2\$" 17 "\\$x=3\$" 18 "\\$x=4\$" 19 "\\$x\geq5\$" 20 "Never attend college" 
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
    save ``Dat'T14', replace
restore

tempfile `Dat'T14c
tempfile `Dat'T14ctrunc
preserve
    use ``Dat'T14', clear
    collapse (percent) ones if t==1 & CCDOSO<8 , by(CCDOSO) 
    ren ones `Dat'ones
    save ``Dat'T14c', replace
    use ``Dat'T14', clear
    collapse (percent) ones if t==1 , by(CCDOSO) 
    ren ones `Dat'ones
    save ``Dat'T14ctrunc', replace
restore
}

* Create the Counterfactual Tables (excluding "truncated" category)
foreach Dat in FwdStatic Cfl CflNoFric CflNoCred { 
preserve
    use `FwdT14c', clear
    merge 1:1 CCDOSO using ``Dat'T14c', nogen
    qui tabout CCDOSO using "${tbljunk}T14`Dat'stata.tex", replace c( mean Fwdones mean `Dat'ones) f(2) sum clab( Fwdfreq `Dat'freq ) style(tex)
    capture file close tf
    file open tf using "${tbljunk}T14`Dat'stata.tex", write append
    file write tf "\midrule"  _n
    file write tf "Graduate from 4-year college" " & " %4.2f (${FwdGrad4}) " & " %4.2f (${`Dat'Grad4}) " \\ "  _n
    file write tf "Ever Switch Major" " & " %4.2f (${FwdSwiMaj}) " & " %4.2f (${`Dat'SwiMaj}) " \\ "  _n
    file write tf "Time to degree" " & " %4.2f (${FwdTTD}) " & " %4.2f (${`Dat'TTD}) " \\ "  _n
    file close tf
restore
!sed -i '/^Total/d' ${tbljunk}T14`Dat'stata.tex

* Create the Counterfactual Table (including "truncated" category)
preserve
    use `FwdT14ctrunc', clear
    merge 1:1 CCDOSO using ``Dat'T14ctrunc', nogen
    qui tabout CCDOSO using "${tbljunk}T14`Dat'truncstata.tex", replace c( mean Fwdones mean `Dat'ones) f(2) sum clab( Fwdfreq `Dat'freq ) style(tex)
    capture file close tft
    file open tft using "${tbljunk}T14`Dat'truncstata.tex", write append
    file write tft "\midrule"  _n
    file write tft "Graduate from 4-year college" " & " %4.2f (${FwdGrad4}) " & " %4.2f (${`Dat'Grad4}) " \\ "  _n
    file write tft "Ever Switch Major" " & " %4.2f (${FwdSwiMaj}) " & " %4.2f (${`Dat'SwiMaj}) " \\ "  _n
    file write tft "Time to degree" " & " %4.2f (${FwdTTD}) " & " %4.2f (${`Dat'TTD}) " \\ "  _n
    file close tft
restore
!sed -i '/^Total/d' ${tbljunk}T14`Dat'truncstata.tex
}

* Create the Counterfactual Table with all counterfactuals side-by-side (including "truncated" category)
preserve
    use `FwdT14ctrunc', clear
    merge 1:1 CCDOSO using `FwdStaticT14ctrunc', nogen
    qui tabout CCDOSO using "${tbljunk}T14fwdjointtruncstata.tex", replace c( mean Fwdones mean FwdStaticones) f(2) sum clab( Fwdfreq FwdStaticfreq) style(tex)
    capture file close tft
    file open tft using "${tbljunk}T14fwdjointtruncstata.tex", write append
    file write tft "\midrule"  _n
    file write tft "Graduate from 4-year college" " & " %4.2f (${FwdGrad4}) " & " %4.2f (${FwdStaticGrad4}) " \\ "  _n
    file write tft "Ever Switch Major" " & " %4.2f (${FwdSwiMaj}) " & " %4.2f (${FwdStaticSwiMaj}) " \\ "  _n
    file write tft "Time to degree" " & " %4.2f (${FwdTTD}) " & " %4.2f (${FwdStaticTTD}) " \\ "  _n
    file close tft
restore
!sed -i '/^Total/d' ${tbljunk}T14fwdjointtruncstata.tex


* export to prettier latex version
!echo "% source is T14fwdjointtruncstata.tex" > ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\begin{table}[ht]" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\caption{College completion status frequencies: baseline model, static model}" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\label{tab:CCDOSOfwd-compare-fit}" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\centering{}" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\begin{threeparttable}" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\begin{tabular}{lcc}" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\toprule" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "                                          & Baseline & Static \\\\" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "Status                                    & model    & model  \\\\" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\midrule" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!cat ${tbljunk}T14fwdjointtruncstata.tex | tail -12 >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\bottomrule" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\end{tabular}" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\footnotesize Notes: Model frequencies are constructed using 10 simulations of the structural model for each individual included in the estimation. ""`=char(92)'`=char(96)'""`=char(92)'`=char(96)'""Baseline model'' refers to the forward simulation of the model using the structural flow utilities and CCP future value adjustment terms in the choice probabilities. ""`=char(92)'`=char(96)'""`=char(92)'`=char(96)'""Static model'' refers to an analogous forward simulation that instead uses a more flexible, static random utility model for the choice probabilities. " >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\medskip" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "We set the panel length in all columns to be 10 periods. Completion status is computed on the first 10 periods of data (i.e. assuming that college is not an option after period 10)." >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\medskip" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "`=char(92)'`=char(96)'""`=char(92)'`=char(96)'""Truncated'' refers to those who were enrolled in period 10." >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\end{threeparttable}" >> ${tblpath}table-comp-status-fwd-compare-static.tex
!echo "\end{table}" >> ${tblpath}table-comp-status-fwd-compare-static.tex



* Create the Counterfactual Table with all counterfactuals side-by-side (including "truncated" category)
preserve
    use `FwdT14ctrunc', clear
    merge 1:1 CCDOSO using `CflT14ctrunc', nogen
    merge 1:1 CCDOSO using `CflNoFricT14ctrunc', nogen
    merge 1:1 CCDOSO using `CflNoCredT14ctrunc', nogen
    qui tabout CCDOSO using "${tbljunk}T14jointtruncstata.tex", replace c( mean Fwdones mean Cflones mean CflNoFricones mean CflNoCredones) f(2) sum clab( Fwdfreq Cflfreq CflNoFricfreq CflNoCredfreq ) style(tex)
    capture file close tft
    file open tft using "${tbljunk}T14jointtruncstata.tex", write append
    file write tft "\midrule"  _n
    file write tft "Graduate from 4-year college" " & " %4.2f (${FwdGrad4}) " & " %4.2f (${CflGrad4}) " & " %4.2f (${CflNoFricGrad4}) " & " %4.2f (${CflNoCredGrad4}) " \\ "  _n
    file write tft "Ever Switch Major" " & " %4.2f (${FwdSwiMaj}) " & " %4.2f (${CflSwiMaj}) " & " %4.2f (${CflNoFricSwiMaj}) " & " %4.2f (${CflNoCredSwiMaj}) " \\ "  _n
    file write tft "Time to degree" " & " %4.2f (${FwdTTD}) " & " %4.2f (${CflTTD}) " & " %4.2f (${CflNoFricTTD}) " & " %4.2f (${CflNoCredTTD}) " \\ "  _n
    file close tft
restore
!sed -i '/^Total/d' ${tbljunk}T14jointtruncstata.tex


* export to prettier latex version
!echo "% source is T14jointtruncstata.tex" > ${tblpath}table-comp-status-cfl.tex
!echo "\begin{table}[ht]" >> ${tblpath}table-comp-status-cfl.tex
!echo "\caption{College completion status frequencies: baseline and counterfactual}" >> ${tblpath}table-comp-status-cfl.tex
!echo "\label{tab:CCDOSOcfl}" >> ${tblpath}table-comp-status-cfl.tex
!echo "\centering{}" >> ${tblpath}table-comp-status-cfl.tex
!echo "\resizebox{\textwidth}{!}{" >> ${tblpath}table-comp-status-cfl.tex
!echo "\begin{threeparttable}" >> ${tblpath}table-comp-status-cfl.tex
!echo "\begin{tabular}{lcccc}" >> ${tblpath}table-comp-status-cfl.tex
!echo "\toprule" >> ${tblpath}table-comp-status-cfl.tex
!echo "                                          &          & \multicolumn{3}{c}{Counterfactuals} \\\\" >> ${tblpath}table-comp-status-cfl.tex
!echo "\\cmidrule(l){3-5}" >> ${tblpath}table-comp-status-cfl.tex
!echo "                                          &          &            & Full info. \\& & Full info. \\& \\\\" >> ${tblpath}table-comp-status-cfl.tex
!echo "                                          & Baseline & Full info. & no search      & reduced credit \\\\" >> ${tblpath}table-comp-status-cfl.tex
!echo "Status                                    & model    & alone      & frictions      & constraints     \\\\" >> ${tblpath}table-comp-status-cfl.tex
!echo "\midrule" >> ${tblpath}table-comp-status-cfl.tex
!cat ${tbljunk}T14jointtruncstata.tex | tail -12 >> ${tblpath}table-comp-status-cfl.tex
!echo "\bottomrule" >> ${tblpath}table-comp-status-cfl.tex
!echo "\end{tabular}" >> ${tblpath}table-comp-status-cfl.tex
!echo "\footnotesize Notes: Model frequencies are constructed using 10 simulations of the structural model for each individual included in the estimation. Counterfactual frequencies use 10 simulations of each counterfactual model. ""`=char(92)'`=char(96)'""`=char(92)'`=char(96)'""Full info. alone'' refers to our counterfactual where individuals have complete information about their abilities. ""`=char(92)'`=char(96)'""`=char(92)'`=char(96)'""Full info. \& no search frictions'' maintains full information and sets to 1 the white collar job offer arrival rate for everyone in every period. ""`=char(92)'`=char(96)'""`=char(92)'`=char(96)'""Full info. \& reduced credit constraints'' maintains full information, removes college loans, and sets in-college non-wage consumption to its 75th percentile for all individuals. " >> ${tblpath}table-comp-status-cfl.tex
!echo "" >> ${tblpath}table-comp-status-cfl.tex
!echo "\medskip" >> ${tblpath}table-comp-status-cfl.tex
!echo "" >> ${tblpath}table-comp-status-cfl.tex
!echo "We set the panel length in all columns to be 10 periods. Completion status is computed on the first 10 periods of data (i.e. assuming that college is not an option after period 10)." >> ${tblpath}table-comp-status-cfl.tex
!echo "" >> ${tblpath}table-comp-status-cfl.tex
!echo "\medskip" >> ${tblpath}table-comp-status-cfl.tex
!echo "" >> ${tblpath}table-comp-status-cfl.tex
!echo "`=char(92)'`=char(96)'""`=char(92)'`=char(96)'""Truncated'' refers to those who were enrolled in period 10." >> ${tblpath}table-comp-status-cfl.tex
!echo "\end{threeparttable}" >> ${tblpath}table-comp-status-cfl.tex
!echo "}" >> ${tblpath}table-comp-status-cfl.tex
!echo "\end{table}" >> ${tblpath}table-comp-status-cfl.tex


*------------------------------------------------------------------------------
* Completion status table by fam income
*------------------------------------------------------------------------------
foreach inc in rich poor { 
    foreach Dat in Fwd Cfl CflNoFric CflNoCred { 
    * Collapse the data
    tempfile `Dat'`inc'T14
    preserve
        use ``Dat'SimPrepped`inc'', clear
        gen ones = 1
        drop if t>10
        generate           truncated = 100*( inrange(choice,1,15) & t==10 )
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
        replace last_col = 10 if last_col==0
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
        replace CCDOSO = 7 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0
        replace CCDOSO = 8 if ever_col==0
        replace CCDOSO = 6 if ever_trunc==100
        replace CCDOSO = 2 if ever_gradH==100 & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 // one person with mis-timed graduation (ID==108)
        lab def vlCCDOSO 1  "Continuous completion (CC), Science" 2  "Continuous completion (CC), Non-Science" 3  "Stop out (SO) but graduated Science" 4  "Stop out (SO) but graduated Non-Science" 5  "Stop out (SO) then drop out" 6  "Truncated" 7  "Drop out (DO)" 8  "Never went to college"
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
        replace CCDOSOdetail = 15 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==1
        replace CCDOSOdetail = 16 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==2
        replace CCDOSOdetail = 17 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==3
        replace CCDOSOdetail = 18 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col==4
        replace CCDOSOdetail = 19 if ever_grad==0    & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 & tot_yrs_col>=5
        replace CCDOSOdetail = 20 if ever_col==0
        replace CCDOSOdetail = 14 if ever_trunc==100
        replace CCDOSOdetail = 6  if ever_gradH==100 & ever_col==100 & ever_leave==100 & ever_reent==0   & ever_trunc==0 // one person with mis-timed graduation (ID==108)
        lab def vlCCDOSOdetail 1  "\\$x=0\$" 2  "\\$x>0\$, white collar only" 3  "\\$x>0\$, blue collar only" 4  "\\$x>0\$, mixture" 5  "\\$x=0\$"                    6  "\\$x>0\$, white collar only"  7  "\\$x>0\$, blue collar only"   8  "\\$x>0\$, mixture"            9  "SO, graduate in science" 10 "SO, graduate in non-science" 11 "SO then DO, start in 2yr" 12 "SO then DO, start in science" 13 "SO then DO, start in non-science" 14 "Truncated" 15 "\\$x=1\$" 16 "\\$x=2\$" 17 "\\$x=3\$" 18 "\\$x=4\$" 19 "\\$x\geq5\$" 20 "Never attend college" 
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
        save ``Dat'`inc'T14', replace
    restore

    tempfile `Dat'`inc'T14c
    tempfile `Dat'`inc'T14ctrunc
    preserve
        use ``Dat'`inc'T14', clear
        collapse (percent) ones if t==1 & CCDOSO<8 , by(CCDOSO) 
        ren ones `Dat'`inc'ones
        save ``Dat'`inc'T14c', replace
        use ``Dat'`inc'T14', clear
        collapse (percent) ones if t==1 , by(CCDOSO) 
        ren ones `Dat'`inc'ones
        save ``Dat'`inc'T14ctrunc', replace
    restore
    }

    // LEFT OFF HERE: NEED TO CONSULT HOW THIS TABLE WAS CREATED IN THE CREDCONS DO-FILE
    * Create the Counterfactual Table with all counterfactuals side-by-side (including "truncated" category)
    preserve
        use `Fwd`inc'T14ctrunc', clear
        merge 1:1 CCDOSO using `Cfl`inc'T14ctrunc', nogen
        merge 1:1 CCDOSO using `CflNoFric`inc'T14ctrunc', nogen
        merge 1:1 CCDOSO using `CflNoCred`inc'T14ctrunc', nogen
        l
        l, nol
        keep if inlist(CCDOSO,7,8)
        lab val CCDOSO .
        lab def vlnewcc 7 "\qquad Dropout" 8 "\qquad Never went to college"
        lab val CCDOSO vlnewcc
        qui tabout CCDOSO using "${tbljunk}T14`inc'truncstata.tex", replace c( mean Fwd`inc'ones mean Cfl`inc'ones mean CflNoFric`inc'ones mean CflNoCred`inc'ones) f(2) sum clab( Fwdfreq Cflfreq CflNoFricfreq CflNoCredfreq ) style(tex)
        capture file close tft
        file open tft using "${tbljunk}T14`inc'truncstata.tex", write append
        file write tft "\qquad Graduate from 4-year college" " & " %4.2f (${FwdGrad4`inc'}) " & " %4.2f (${CflGrad4`inc'}) " & " %4.2f (${CflNoFricGrad4`inc'}) " & " %4.2f (${CflNoCredGrad4`inc'}) " \\ "  _n
        file write tft "\qquad Ever Switch Major" " & " %4.2f (${FwdSwiMaj`inc'}) " & " %4.2f (${CflSwiMaj`inc'}) " & " %4.2f (${CflNoFricSwiMaj`inc'}) " & " %4.2f (${CflNoCredSwiMaj`inc'}) " \\ "  _n
        file close tft
    restore
    !sed -i '/^Total/d' ${tbljunk}T14`inc'truncstata.tex
}



* export to prettier latex version
!echo "% source is T14richtruncstata.tex and T14poortruncstata.tex" > ${tblpath}table-comp-status-cfl-inc.tex
!echo "\begin{table}[ht]" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\caption{College completion status in model and counterfactuals: heterogeneity by level of family income}" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\label{tab:CCDOSOcflbyinc}" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\centering{}" >> ${tblpath}table-comp-status-cfl-inc.tex
//!echo "\resizebox{\textwidth}{!}{" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\begin{threeparttable}" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\begin{tabular}{lcccc}" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\toprule" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "                                          &          & \multicolumn{3}{c}{Counterfactuals} \\\\" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\\cmidrule(l){3-5}" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "                                          &          &            & Full info. \\& & Full info. \\& \\\\" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "                                          & Baseline & Full info. & no search      & reduced credit \\\\" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "Status                                    & model    & alone      & frictions      & constraints     \\\\" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\midrule" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\multicolumn{5}{l}{\textit{Panel A: Above-median family income in high school}} \\\\" >> ${tblpath}table-comp-status-cfl-inc.tex
!cat ${tbljunk}T14richtruncstata.tex | tail -4 >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "&&&&\\\\" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\multicolumn{5}{l}{\textit{Panel B: Below-median family income in high school}} \\\\" >> ${tblpath}table-comp-status-cfl-inc.tex
!cat ${tbljunk}T14poortruncstata.tex | tail -4 >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\bottomrule" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\end{tabular}" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\footnotesize Notes: Model frequencies are constructed using 10 simulations of the structural model for each individual included in the estimation. Counterfactual frequencies use 10 simulations of each counterfactual model. ""`=char(92)'`=char(96)'""`=char(92)'`=char(96)'""Full info. alone'' refers to our counterfactual where individuals have complete information about their abilities. ""`=char(92)'`=char(96)'""`=char(92)'`=char(96)'""Full info. \& no search frictions'' maintains full information and sets to 1 the white collar job offer arrival rate for everyone in every period. ""`=char(92)'`=char(96)'""`=char(92)'`=char(96)'""Full info. \& reduced credit constraints'' maintains full information, removes college loans, and sets in-college non-wage consumption to its 75th percentile for all individuals. " >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\medskip" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "We set the panel length in all columns to be 10 periods. Completion status is computed on the first 10 periods of data (i.e. assuming that college is not an option after period 10)." >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\end{threeparttable}" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "}" >> ${tblpath}table-comp-status-cfl-inc.tex
!echo "\end{table}" >> ${tblpath}table-comp-status-cfl-inc.tex



*------------------------------------------------------------------------------
* Tables 12 and 15 from 2016 paper (labled "T12`Dat'" in loop)
*------------------------------------------------------------------------------
foreach Dat in Fwd Cfl CflNoFric CflNoCred { 
local dat = lower("`Dat'")
tempfile `Dat'T12c
tempfile `Dat'T12ctrunc
if "`Dat'"=="Fwd" local postt "posterior"
if "`Dat'"!="Fwd" local postt "true"
preserve
    use ``Dat'T14', clear
    collapse (count) N=ones (percent) ones (mean) `postt'Abil* if t==last_col & CCDOSOdetail!=14 , by(CCDOSOdetail) 
    foreach var of varlist N ones `postt'Abil* {
        ren `var' `Dat'`var'
    }
    save ``Dat'T12c', replace
    use ``Dat'T14', clear
    collapse (count) N=ones (percent) ones (mean) `postt'Abil* if t==last_col , by(CCDOSOdetail) 
    foreach var of varlist N ones `postt'Abil* {
        ren `var' `Dat'`var'
    }
    save ``Dat'T12ctrunc', replace
restore

* Create the Sorting Table (excluding "truncated" category)
preserve
    use ``Dat'T12c', clear
    qui tabout CCDOSOdetail using "${tbljunk}T12`Dat'stata.tex", replace c( mean `Dat'`postt'AbilWC mean `Dat'`postt'AbilBC mean `Dat'`postt'Abil4S mean `Dat'`postt'Abil4H mean `Dat'`postt'Abil2 mean `Dat'ones ) f(2) sum clab( PAWC PABC PA4S PA4H PA2 `Dat'freq ) style(tex)
restore
!sed -i 's/.00 / /g' ${tbljunk}T12`Dat'stata.tex
!sed -i 's/\\=/\$x=/g' ${tbljunk}T12`Dat'stata.tex
!sed -i 's/\\>/\$x>/g' ${tbljunk}T12`Dat'stata.tex
!sed -i 's/\\\\geq/\$x\\geq/g' ${tbljunk}T12`Dat'stata.tex
!sed -i 's/0\\/0/g' ${tbljunk}T12`Dat'stata.tex
!sed -i 's/1\\/1/g' ${tbljunk}T12`Dat'stata.tex
!sed -i 's/2\\/2/g' ${tbljunk}T12`Dat'stata.tex
!sed -i 's/3\\/3/g' ${tbljunk}T12`Dat'stata.tex
!sed -i 's/4\\/4/g' ${tbljunk}T12`Dat'stata.tex
!sed -i 's/5\\/5/g' ${tbljunk}T12`Dat'stata.tex

* Create the Model Table (including "truncated" category)
preserve
    use ``Dat'T12ctrunc', clear
    qui tabout CCDOSOdetail using "${tbljunk}T12`Dat'truncstata.tex", replace c( mean `Dat'`postt'AbilWC mean `Dat'`postt'AbilBC mean `Dat'`postt'Abil4S mean `Dat'`postt'Abil4H mean `Dat'`postt'Abil2 mean `Dat'ones ) f(2) sum clab( PAWC PABC PA4S PA4H PA2 `Dat'freq ) style(tex)
restore
!sed -i 's/.00 / /g' ${tbljunk}T12`Dat'truncstata.tex
!sed -i 's/\\=/\$x=/g' ${tbljunk}T12`Dat'truncstata.tex
!sed -i 's/\\>/\$x>/g' ${tbljunk}T12`Dat'truncstata.tex
!sed -i 's/\\\\geq/\$x\\geq/g' ${tbljunk}T12`Dat'truncstata.tex
!sed -i 's/0\\/0/g' ${tbljunk}T12`Dat'truncstata.tex
!sed -i 's/1\\/1/g' ${tbljunk}T12`Dat'truncstata.tex
!sed -i 's/2\\/2/g' ${tbljunk}T12`Dat'truncstata.tex
!sed -i 's/3\\/3/g' ${tbljunk}T12`Dat'truncstata.tex
!sed -i 's/4\\/4/g' ${tbljunk}T12`Dat'truncstata.tex
!sed -i 's/5\\/5/g' ${tbljunk}T12`Dat'truncstata.tex

* output to latex file in prettier format:
!echo "% source is T12`Dat'truncstata.tex" > ${tblpath}table-sorting-abil-`dat'.tex
!echo "\begin{table}[ht]" >> ${tblpath}table-sorting-abil-`dat'.tex
if "`Dat'"=="Fwd" {
    !echo "\caption{Average posterior abilities after last period of college for different choice paths in baseline model}" >> ${tblpath}table-sorting-abil-`dat'.tex
}
if "`Dat'"=="Cfl" {
    !echo "\caption{Average abilities for different choice paths in full-information counterfactual scenario}" >> ${tblpath}table-sorting-abil-`dat'.tex
}
if "`Dat'"=="CflNoFric" {
    !echo "\caption{Average abilities for different choice paths in full-information no-search-frictions counterfactual scenario}" >> ${tblpath}table-sorting-abil-`dat'.tex
}
if "`Dat'"=="CflNoCred" {
    !echo "\caption{Average abilities for different choice paths in full-information reduced-credit-constraints counterfactual scenario}" >> ${tblpath}table-sorting-abil-`dat'.tex
}
!echo "\label{tab:trueAbility`Dat'}" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\centering{}" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\resizebox{.95\textwidth}{!}{" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\begin{threeparttable}" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\begin{tabular}{lcccccc}" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\toprule" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "Choice Path  & White Collar  & Blue Collar  & Science  & Non-Science  & 2-year  & Share(\%)\\\\" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\midrule" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\multicolumn{7}{l}{\emph{Continuous enrollment, graduate in science with \$ x\$ years of in-school work experience}}\\\\" >> ${tblpath}table-sorting-abil-`dat'.tex
!cat ${tbljunk}T12`Dat'truncstata.tex | head -7 | tail -4 >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\midrule" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\multicolumn{7}{l}{\emph{Continuous enrollment, graduate in non-science with \$ x\$ years of in-school work experience}}\\\\" >> ${tblpath}table-sorting-abil-`dat'.tex
!cat ${tbljunk}T12`Dat'truncstata.tex | head -11 | tail -4 >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\midrule" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\multicolumn{7}{l}{\emph{Stop out (SO)}}\\\\" >> ${tblpath}table-sorting-abil-`dat'.tex
!cat ${tbljunk}T12`Dat'truncstata.tex | head -17 | tail -6 >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\midrule" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\multicolumn{7}{l}{\emph{Drop out (DO) after \$ x\$ years of school}}\\\\" >> ${tblpath}table-sorting-abil-`dat'.tex
!cat ${tbljunk}T12`Dat'truncstata.tex | head -22 | tail -5 >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\midrule" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\multicolumn{7}{l}{\emph{Never attended college}}\\\\" >> ${tblpath}table-sorting-abil-`dat'.tex
!cat ${tbljunk}T12`Dat'truncstata.tex | tail -2 | head -1 >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\bottomrule" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\end{tabular}" >> ${tblpath}table-sorting-abil-`dat'.tex
if "`Dat'"=="Fwd" {
    !echo "\footnotesize Notes: Abilities are reported in standard deviation units. This table is constructed using 10 simulations of the baseline model for each individual included in the estimation." >> ${tblpath}table-sorting-abil-`dat'.tex
}
if "`Dat'"!="Fwd" {
    !echo "\footnotesize Notes: Abilities are reported in standard deviation units. This table is constructed using 10 simulations of the counterfactual model described in the title for each individual included in the estimation." >> ${tblpath}table-sorting-abil-`dat'.tex
}
!echo "" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\medskip" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "`=char(92)'`=char(96)'""`=char(92)'`=char(96)'""Truncated'' refers to those who were enrolled in period 10." >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\end{threeparttable}" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "}" >> ${tblpath}table-sorting-abil-`dat'.tex
!echo "\end{table}" >> ${tblpath}table-sorting-abil-`dat'.tex

}



*------------------------------------------------------------------------------
* Table 13 from 2016 paper (labled "T13`Dat'" in loop)
*------------------------------------------------------------------------------
foreach Dat in Fwd { 
local dat = lower("`Dat'")
tempfile `Dat'T13c
tempfile `Dat'T13ctrunc
if "`Dat'"=="Fwd" local postt "posterior"
if "`Dat'"!="Fwd" local postt "true"
preserve
    use ``Dat'T14', clear
    collapse (count) N=ones (percent) ones (mean) `postt'Var* if t==last_col & CCDOSOdetail!=14 , by(CCDOSOdetail) 
    foreach var of varlist N ones `postt'Var* {
        ren `var' `Dat'`var'
    }
    save ``Dat'T13c', replace
    use ``Dat'T14', clear
    collapse (count) N=ones (percent) ones (mean) `postt'Var* if t==last_col , by(CCDOSOdetail) 
    foreach var of varlist N ones `postt'Var* {
        ren `var' `Dat'`var'
    }
    save ``Dat'T13ctrunc', replace
restore

* Create the Sorting Table (excluding "truncated" category)
preserve
    use ``Dat'T13c', clear
    qui tabout CCDOSOdetail using "${tbljunk}T13`Dat'stata.tex", replace c( mean `Dat'`postt'VarWC mean `Dat'`postt'VarBC mean `Dat'`postt'Var4S mean `Dat'`postt'Var4H mean `Dat'`postt'Var2 mean `Dat'ones ) f(2) sum clab( PVWC PVBC PV4S PV4H PV2 `Dat'freq ) style(tex)
restore
!sed -i 's/.00 / /g' ${tbljunk}T13`Dat'stata.tex
!sed -i 's/\\=/\$x=/g' ${tbljunk}T13`Dat'stata.tex
!sed -i 's/\\>/\$x>/g' ${tbljunk}T13`Dat'stata.tex
!sed -i 's/\\\\geq/\$x\\geq/g' ${tbljunk}T13`Dat'stata.tex
!sed -i 's/0\\/0/g' ${tbljunk}T13`Dat'stata.tex
!sed -i 's/1\\/1/g' ${tbljunk}T13`Dat'stata.tex
!sed -i 's/2\\/2/g' ${tbljunk}T13`Dat'stata.tex
!sed -i 's/3\\/3/g' ${tbljunk}T13`Dat'stata.tex
!sed -i 's/4\\/4/g' ${tbljunk}T13`Dat'stata.tex
!sed -i 's/5\\/5/g' ${tbljunk}T13`Dat'stata.tex

* Create the Model Table (including "truncated" category)
preserve
    use ``Dat'T13ctrunc', clear
    qui tabout CCDOSOdetail using "${tbljunk}T13`Dat'truncstata.tex", replace c( mean `Dat'`postt'VarWC mean `Dat'`postt'VarBC mean `Dat'`postt'Var4S mean `Dat'`postt'Var4H mean `Dat'`postt'Var2 mean `Dat'ones ) f(2) sum clab( PVWC PVBC PV4S PV4H PV2 `Dat'freq ) style(tex)
restore
!sed -i 's/.00 / /g' ${tbljunk}T13`Dat'truncstata.tex
!sed -i 's/\\=/\$x=/g' ${tbljunk}T13`Dat'truncstata.tex
!sed -i 's/\\>/\$x>/g' ${tbljunk}T13`Dat'truncstata.tex
!sed -i 's/\\\\geq/\$x\\geq/g' ${tbljunk}T13`Dat'truncstata.tex
!sed -i 's/0\\/0/g' ${tbljunk}T13`Dat'truncstata.tex
!sed -i 's/1\\/1/g' ${tbljunk}T13`Dat'truncstata.tex
!sed -i 's/2\\/2/g' ${tbljunk}T13`Dat'truncstata.tex
!sed -i 's/3\\/3/g' ${tbljunk}T13`Dat'truncstata.tex
!sed -i 's/4\\/4/g' ${tbljunk}T13`Dat'truncstata.tex
!sed -i 's/5\\/5/g' ${tbljunk}T13`Dat'truncstata.tex

* output to latex file in prettier format:
!echo "% source is T13`Dat'truncstata.tex" > ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\begin{table}[ht]" >> ${tblpath}table-sorting-postvar-`dat'.tex
if "`Dat'"=="Fwd" {
    !echo "\caption{Average posterior variances after last period of college for different choice paths in baseline model}" >> ${tblpath}table-sorting-postvar-`dat'.tex
}
!echo "\label{tab:postVar`Dat'}" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\centering{}" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\resizebox{.95\textwidth}{!}{" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\begin{threeparttable}" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\begin{tabular}{lcccccc}" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\toprule" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "Choice Path  & White Collar  & Blue Collar  & Science  & Non-Science  & 2-year  & Share(\%)\\\\" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\midrule" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\multicolumn{7}{l}{\emph{Continuous enrollment, graduate in science with \$ x\$ years of in-school work experience}}\\\\" >> ${tblpath}table-sorting-postvar-`dat'.tex
!cat ${tbljunk}T13`Dat'truncstata.tex | head -7 | tail -4 >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\midrule" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\multicolumn{7}{l}{\emph{Continuous enrollment, graduate in non-science with \$ x\$ years of in-school work experience}}\\\\" >> ${tblpath}table-sorting-postvar-`dat'.tex
!cat ${tbljunk}T13`Dat'truncstata.tex | head -11 | tail -4 >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\midrule" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\multicolumn{7}{l}{\emph{Stop out (SO)}}\\\\" >> ${tblpath}table-sorting-postvar-`dat'.tex
!cat ${tbljunk}T13`Dat'truncstata.tex | head -17 | tail -6 >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\midrule" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\multicolumn{7}{l}{\emph{Drop out (DO) after \$ x\$ years of school}}\\\\" >> ${tblpath}table-sorting-postvar-`dat'.tex
!cat ${tbljunk}T13`Dat'truncstata.tex | head -22 | tail -5 >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\midrule" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\multicolumn{7}{l}{\emph{Never attended college}}\\\\" >> ${tblpath}table-sorting-postvar-`dat'.tex
!cat ${tbljunk}T13`Dat'truncstata.tex | tail -2 | head -1 >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\midrule" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "Time 0 population variance & `var2WC' & `var2BC' & `var24S' & `var24H' & `var22' & \\\\" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\bottomrule" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\end{tabular}" >> ${tblpath}table-sorting-postvar-`dat'.tex
if "`Dat'"=="Fwd" {
    !echo "\footnotesize Notes: Average posterior variances of ability across individuals are reported in each cell. This table is constructed using 10 simulations of the baseline model for each individual included in the estimation." >> ${tblpath}table-sorting-postvar-`dat'.tex
}
!echo "" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\medskip" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "`=char(92)'`=char(96)'""`=char(92)'`=char(96)'""Truncated'' refers to those who were enrolled in period 10." >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\end{threeparttable}" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "}" >> ${tblpath}table-sorting-postvar-`dat'.tex
!echo "\end{table}" >> ${tblpath}table-sorting-postvar-`dat'.tex

}



*------------------------------------------------------------------------------
* summary stats on lambda
*------------------------------------------------------------------------------
foreach Dat in Fwd Cfl CflNoFric CflNoCred { 
di "`Dat' summary stats on lambda"
preserve
    use ``Dat'SimPrepped', clear
    count
    sum WCoffer 
    sum WCoffer if grad_4yr==1 
    sum WCoffer 
    sum WCoffer if grad_4yr==1 & t<=10 
    sum finalSciMaj  if grad_4yr==1 & prev_grad_4yr==0
    tab prev_WC  , sum(WCoffer) mean
    tab grad_4yr , sum(WCoffer) mean
restore
}


*------------------------------------------------------------------------------
* wage decomposition
*------------------------------------------------------------------------------
*:::::::::::::::::::::::::::::::::::::::
* Generate expected log wages
*:::::::::::::::::::::::::::::::::::::::
foreach Dat in Fwd Cfl CflNoFric { 
tempfile `Dat'WageDecomp
preserve
    use ``Dat'SimPrepped', clear
    if "`Dat'"!="Fwd" {
        ren Parent_col Parent_college
        ren HS_GPA HS_grades
    }
    gen age_18 = (t<=1)
    gen age_19 = (t==2) 
    gen age_20 = (t==3)
    gen sci_maj_grad_4yr = grad_4yr*finalSciMaj
    
    gen workAny = workFT | workPT

    *White Collar Wage Parameters
    local b_wc_intercept          =  2.07090
    local b_wc_black              = -0.09160
    local b_wc_hispanic           =  0.04246
    local b_wc_Parent_college     = -0.00086
    local b_wc_HS_grades          = -0.02595
    local b_wc_born1980           = -0.07217
    local b_wc_born1981           = -0.12153
    local b_wc_born1982           = -0.03919
    local b_wc_born1983           = -0.06169
    local b_wc_age_18             = -0.09005
    local b_wc_age_19             = -0.05655
    local b_wc_age_20             = -0.02731
    local b_wc_exper              =  0.03469
    local b_wc_exper_white_collar =  0.01877
    local b_wc_cum_college        =  0.02924
    local b_wc_grad_4yr           =  0.12030
    local b_wc_sci_maj_grad_4yr   =  0.14904
    local b_wc_workPT             =  0.01160
    local b_wc_type_sch_abil      =  0.08534
    local b_wc_type_sch_pref      =  0.00000
    local b_wc_type_wrk_abpf      =  0.43799


    gen e_lnwage_wc_pre = `b_wc_intercept' + `b_wc_black'*black + `b_wc_hispanic'*hispanic + `b_wc_Parent_college'*Parent_college + `b_wc_HS_grades'*HS_grades + `b_wc_born1980'*(birthYr==1980) + `b_wc_born1981'*(birthYr==1981) + `b_wc_born1982'*(birthYr==1982) + `b_wc_born1983'*(birthYr==1983) + `b_wc_age_18'*age_18 + `b_wc_age_19'*age_19 + `b_wc_age_20'*age_20 + `b_wc_exper'*exper + `b_wc_exper_white_collar'*exper_white_collar + `b_wc_cum_college'*cum_college + `b_wc_grad_4yr'*grad_4yr + `b_wc_sci_maj_grad_4yr'*sci_maj_grad_4yr + `b_wc_workPT'*workPT + `b_wc_type_sch_abil'*inlist(utype,1,2,3,4) + `b_wc_type_sch_pref'*inlist(utype,1,2,5,6) + `b_wc_type_wrk_abpf'*inlist(utype,1,3,5,7) + trueAbilWC_nsd
    gen e_lnwage_wc_pre_ng = `b_wc_intercept' + `b_wc_black'*black + `b_wc_hispanic'*hispanic + `b_wc_Parent_college'*Parent_college + `b_wc_HS_grades'*HS_grades + `b_wc_born1980'*(birthYr==1980) + `b_wc_born1981'*(birthYr==1981) + `b_wc_born1982'*(birthYr==1982) + `b_wc_born1983'*(birthYr==1983) + `b_wc_age_18'*age_18 + `b_wc_age_19'*age_19 + `b_wc_age_20'*age_20 + `b_wc_exper'*exper + `b_wc_exper_white_collar'*exper_white_collar + `b_wc_cum_college'*cum_college + `b_wc_grad_4yr'*0 + `b_wc_sci_maj_grad_4yr'*0 + `b_wc_workPT'*workPT + `b_wc_type_sch_abil'*inlist(utype,1,2,3,4) + `b_wc_type_sch_pref'*inlist(utype,1,2,5,6) + `b_wc_type_wrk_abpf'*inlist(utype,1,3,5,7) + trueAbilWC_nsd
    gen e_lnwage_wc_pre_g_s  = `b_wc_intercept' + `b_wc_black'*black + `b_wc_hispanic'*hispanic + `b_wc_Parent_college'*Parent_college + `b_wc_HS_grades'*HS_grades + `b_wc_born1980'*(birthYr==1980) + `b_wc_born1981'*(birthYr==1981) + `b_wc_born1982'*(birthYr==1982) + `b_wc_born1983'*(birthYr==1983) + `b_wc_age_18'*age_18 + `b_wc_age_19'*age_19 + `b_wc_age_20'*age_20 + `b_wc_exper'*exper + `b_wc_exper_white_collar'*exper_white_collar + `b_wc_cum_college'*cum_college + `b_wc_grad_4yr'*1 + `b_wc_sci_maj_grad_4yr'*1 + `b_wc_workPT'*workPT + `b_wc_type_sch_abil'*inlist(utype,1,2,3,4) + `b_wc_type_sch_pref'*inlist(utype,1,2,5,6) + `b_wc_type_wrk_abpf'*inlist(utype,1,3,5,7) + trueAbilWC_nsd
    gen e_lnwage_wc_pre_g_ns  = `b_wc_intercept' + `b_wc_black'*black + `b_wc_hispanic'*hispanic + `b_wc_Parent_college'*Parent_college + `b_wc_HS_grades'*HS_grades + `b_wc_born1980'*(birthYr==1980) + `b_wc_born1981'*(birthYr==1981) + `b_wc_born1982'*(birthYr==1982) + `b_wc_born1983'*(birthYr==1983) + `b_wc_age_18'*age_18 + `b_wc_age_19'*age_19 + `b_wc_age_20'*age_20 + `b_wc_exper'*exper + `b_wc_exper_white_collar'*exper_white_collar + `b_wc_cum_college'*cum_college + `b_wc_grad_4yr'*1 + `b_wc_sci_maj_grad_4yr'*0 + `b_wc_workPT'*workPT + `b_wc_type_sch_abil'*inlist(utype,1,2,3,4) + `b_wc_type_sch_pref'*inlist(utype,1,2,5,6) + `b_wc_type_wrk_abpf'*inlist(utype,1,3,5,7) + trueAbilWC_nsd

    local intercept_wc = 0.37542
    local lambda_wc    = 0.76740


    *WC Expected wage for in school and out of school
    gen e_lnwage_wc = in_college*(`intercept_wc' + `lambda_wc'*e_lnwage_wc_pre) + (1-in_college)*e_lnwage_wc_pre if workAny
    gen e_lnwage_wc_ng = in_college*(`intercept_wc' + `lambda_wc'*e_lnwage_wc_pre_ng) + (1-in_college)*e_lnwage_wc_pre_ng if workAny
    gen e_lnwage_wc_g_s  = in_college*(`intercept_wc' + `lambda_wc'*e_lnwage_wc_pre_g_s) + (1-in_college)*e_lnwage_wc_pre_g_s if workAny
    gen e_lnwage_wc_g_ns  = in_college*(`intercept_wc' + `lambda_wc'*e_lnwage_wc_pre_g_ns) + (1-in_college)*e_lnwage_wc_pre_g_ns if workAny
    drop e_lnwage_wc_pre*

    *Blue Collar Wage Parameters
    local b_bc_intercept          =  1.97500
    local b_bc_black              = -0.12452
    local b_bc_hispanic           =  0.01577
    local b_bc_Parent_college     =  0.01503
    local b_bc_HS_grades          = -0.02762
    local b_bc_born1980           = -0.00783
    local b_bc_born1981           =  0.00847
    local b_bc_born1982           =  0.02436
    local b_bc_born1983           = -0.02326
    local b_bc_age_18             = -0.09711
    local b_bc_age_19             = -0.08792
    local b_bc_age_20             = -0.04310
    local b_bc_exper              =  0.03833
    local b_bc_exper_white_collar =  0.00989
    local b_bc_cum_college        =  0.02290
    local b_bc_grad_4yr           =  0.04373
    local b_bc_sci_maj_grad_4yr   =  0.09235
    local b_bc_workPT             = -0.04548
    local b_bc_type_sch_abil      =  0.13498
    local b_bc_type_sch_pref      =  0.00000
    local b_bc_type_wrk_abpf      =  0.33648


    gen e_lnwage_bc_pre = `b_bc_intercept' + `b_bc_black'*black + `b_bc_hispanic'*hispanic + `b_bc_Parent_college'*Parent_college + `b_bc_HS_grades'*HS_grades + `b_bc_born1980'*(birthYr==1980) + `b_bc_born1981'*(birthYr==1981) + `b_bc_born1982'*(birthYr==1982) + `b_bc_born1983'*(birthYr==1983) + `b_bc_age_18'*age_18 + `b_bc_age_19'*age_19 + `b_bc_age_20'*age_20 + `b_bc_exper'*exper + `b_bc_exper_white_collar'*exper_white_collar + `b_bc_cum_college'*cum_college + `b_bc_grad_4yr'*grad_4yr + `b_bc_sci_maj_grad_4yr'*sci_maj_grad_4yr + `b_bc_workPT'*workPT + `b_bc_type_sch_abil'*inlist(utype,1,2,3,4) + `b_bc_type_sch_pref'*inlist(utype,1,2,5,6) + `b_bc_type_wrk_abpf'*inlist(utype,1,3,5,7) + trueAbilBC_nsd
    gen e_lnwage_bc_pre_ng = `b_bc_intercept' + `b_bc_black'*black + `b_bc_hispanic'*hispanic + `b_bc_Parent_college'*Parent_college + `b_bc_HS_grades'*HS_grades + `b_bc_born1980'*(birthYr==1980) + `b_bc_born1981'*(birthYr==1981) + `b_bc_born1982'*(birthYr==1982) + `b_bc_born1983'*(birthYr==1983) + `b_bc_age_18'*age_18 + `b_bc_age_19'*age_19 + `b_bc_age_20'*age_20 + `b_bc_exper'*exper + `b_bc_exper_white_collar'*exper_white_collar + `b_bc_cum_college'*cum_college + `b_bc_grad_4yr'*0 + `b_bc_sci_maj_grad_4yr'*0 + `b_bc_workPT'*workPT + `b_bc_type_sch_abil'*inlist(utype,1,2,3,4) + `b_bc_type_sch_pref'*inlist(utype,1,2,5,6) + `b_bc_type_wrk_abpf'*inlist(utype,1,3,5,7) + trueAbilBC_nsd
    gen e_lnwage_bc_pre_g_s  = `b_bc_intercept' + `b_bc_black'*black + `b_bc_hispanic'*hispanic + `b_bc_Parent_college'*Parent_college + `b_bc_HS_grades'*HS_grades + `b_bc_born1980'*(birthYr==1980) + `b_bc_born1981'*(birthYr==1981) + `b_bc_born1982'*(birthYr==1982) + `b_bc_born1983'*(birthYr==1983) + `b_bc_age_18'*age_18 + `b_bc_age_19'*age_19 + `b_bc_age_20'*age_20 + `b_bc_exper'*exper + `b_bc_exper_white_collar'*exper_white_collar + `b_bc_cum_college'*cum_college + `b_bc_grad_4yr'*1 + `b_bc_sci_maj_grad_4yr'*1 + `b_bc_workPT'*workPT + `b_bc_type_sch_abil'*inlist(utype,1,2,3,4) + `b_bc_type_sch_pref'*inlist(utype,1,2,5,6) + `b_bc_type_wrk_abpf'*inlist(utype,1,3,5,7) + trueAbilBC_nsd
    gen e_lnwage_bc_pre_g_ns  = `b_bc_intercept' + `b_bc_black'*black + `b_bc_hispanic'*hispanic + `b_bc_Parent_college'*Parent_college + `b_bc_HS_grades'*HS_grades + `b_bc_born1980'*(birthYr==1980) + `b_bc_born1981'*(birthYr==1981) + `b_bc_born1982'*(birthYr==1982) + `b_bc_born1983'*(birthYr==1983) + `b_bc_age_18'*age_18 + `b_bc_age_19'*age_19 + `b_bc_age_20'*age_20 + `b_bc_exper'*exper + `b_bc_exper_white_collar'*exper_white_collar + `b_bc_cum_college'*cum_college + `b_bc_grad_4yr'*1 + `b_bc_sci_maj_grad_4yr'*0 + `b_bc_workPT'*workPT + `b_bc_type_sch_abil'*inlist(utype,1,2,3,4) + `b_bc_type_sch_pref'*inlist(utype,1,2,5,6) + `b_bc_type_wrk_abpf'*inlist(utype,1,3,5,7) + trueAbilBC_nsd

    local intercept_bc = 0.75379
    local lambda_bc    = 0.62003


    *BC Expected wage for in school and out of school
    gen e_lnwage_bc = in_college*(`intercept_bc' + `lambda_bc'*e_lnwage_bc_pre) + (1-in_college)*e_lnwage_bc_pre if workAny
    gen e_lnwage_bc_ng = in_college*(`intercept_bc' + `lambda_bc'*e_lnwage_bc_pre_ng) + (1-in_college)*e_lnwage_bc_pre_ng if workAny
    gen e_lnwage_bc_g_s  = in_college*(`intercept_bc' + `lambda_bc'*e_lnwage_bc_pre_g_s) + (1-in_college)*e_lnwage_bc_pre_g_s if workAny
    gen e_lnwage_bc_g_ns  = in_college*(`intercept_bc' + `lambda_bc'*e_lnwage_bc_pre_g_ns) + (1-in_college)*e_lnwage_bc_pre_g_ns if workAny
    drop e_lnwage_bc_pre*

    generat e_lnwage = e_lnwage_bc if workAny & !whiteCollar
    replace e_lnwage = e_lnwage_wc if workAny &  whiteCollar

    generat e_abil = trueAbilWC_nsd*whiteCollar + trueAbilBC_nsd*(1-whiteCollar)
    save ``Dat'WageDecomp', replace
restore
}

*:::::::::::::::::::::::::::::::::::::::
* Decomposition calculations (cond'l workFT)
*:::::::::::::::::::::::::::::::::::::::
// initialize matrix
matrix table1     = J(42,60,0)
matrix table2a    = J(30,3,0)
matrix table2b    = J(30,3,0)
matrix table3     = J(10,6,0)
matrix colnames table1  = avgFwd avgCfl avgCflNoFric shrFwd shrCfl shrCflNoFric ut1Fwd ut1Cfl ut1CflNoFric ut2Fwd ut2Cfl ut2CflNoFric ut3Fwd ut3Cfl ut3CflNoFric ut4Fwd ut4Cfl ut4CflNoFric ut5Fwd ut5Cfl ut5CflNoFric ut6Fwd ut6Cfl ut6CflNoFric ut7Fwd ut7Cfl ut7CflNoFric ut8Fwd ut8Cfl ut8CflNoFric avgAbilWCFwd avgAbilWCCfl avgAbilWCCflNoFric avgAbilBCFwd avgAbilBCCfl avgAbilBCCflNoFric avgAbil4SFwd avgAbil4SCfl avgAbil4SCflNoFric avgAbil4HFwd avgAbil4HCfl avgAbil4HCflNoFric avgAbil2Fwd avgAbil2Cfl avgAbil2CflNoFric sdAbilWCFwd sdAbilWCCfl sdAbilWCCflNoFric sdAbilBCFwd sdAbilBCCfl sdAbilBCCflNoFric sdAbil4SFwd sdAbil4SCfl sdAbil4SCflNoFric sdAbil4HFwd sdAbil4HCfl sdAbil4HCflNoFric sdAbil2Fwd sdAbil2Cfl sdAbil2CflNoFric 
matrix rownames table1  = WC_grad_sci WC_grad_hum BC_grad_sci BC_grad_hum WC_ng BC_ng ovrCWP sciCWP humCWP ovrWCP WCexper sdWCexper BCexper sdBCexper WCcondExper sdWCcondExper BCcondExper sdBCcondExper WCexper_g_s sdWCexper_g_s BCexper_g_s sdBCexper_g_s WCcondExper_g_s sdWCcondExper_g_s BCcondExper_g_s sdBCcondExper_g_s WCexper_g_ns sdWCexper_g_ns BCexper_g_ns sdBCexper_g_ns WCcondExper_g_ns sdWCcondExper_g_ns BCcondExper_g_ns sdBCcondExper_g_ns WCexper_ng sdWCexper_ng BCexper_ng sdBCexper_ng WCcondExper_ng sdWCcondExper_ng BCcondExper_ng sdBCcondExper_ng
matrix colnames table2a = avgFwd avgCfl avgCflNoFric
matrix rownames table2a = wc_g_s_wc_hum wc_g_s_bc_sci wc_g_s_bc_hum wc_g_s_wc_ng wc_g_s_bc_ng wc_g_ns_wc_sci wc_g_ns_bc_sci wc_g_ns_bc_hum wc_g_ns_wc_ng wc_g_ns_bc_ng bc_g_s_wc_sci bc_g_s_wc_hum bc_g_s_bc_hum bc_g_s_wc_ng bc_g_s_bc_ng bc_g_ns_wc_sci bc_g_ns_wc_hum bc_g_ns_bc_sci bc_g_ns_wc_ng bc_g_ns_bc_ng wc_ng_wc_sci wc_ng_wc_hum wc_ng_bc_sci wc_ng_bc_hum wc_ng_bc_ng bc_ng_wc_sci bc_ng_wc_hum bc_ng_bc_sci bc_ng_bc_hum bc_ng_wc_ng 
matrix colnames table2b = avgFwd avgCfl avgCflNoFric
matrix rownames table2b = wc_g_s_wc_hum wc_g_s_bc_sci wc_g_s_bc_hum wc_g_s_wc_ng wc_g_s_bc_ng wc_g_ns_wc_sci wc_g_ns_bc_sci wc_g_ns_bc_hum wc_g_ns_wc_ng wc_g_ns_bc_ng bc_g_s_wc_sci bc_g_s_wc_hum bc_g_s_bc_hum bc_g_s_wc_ng bc_g_s_bc_ng bc_g_ns_wc_sci bc_g_ns_wc_hum bc_g_ns_bc_sci bc_g_ns_wc_ng bc_g_ns_bc_ng wc_ng_wc_sci wc_ng_wc_hum wc_ng_bc_sci wc_ng_bc_hum wc_ng_bc_ng bc_ng_wc_sci bc_ng_wc_hum bc_ng_bc_sci bc_ng_bc_hum bc_ng_wc_ng 
matrix colnames table3 = avgExperFwd avgExperCfl avgExperCflNoFric avgAbilFwd avgAbilCfl avgAbilCflNoFric
matrix rownames table3 = decile1 decile2 decile3 decile4 decile5 decile6 decile7 decile8 decile9 decile10

foreach Dat in Fwd Cfl CflNoFric {
preserve
    use ``Dat'WageDecomp', clear
    keep if t==10 & workFT
    gen exper_blue_collar = exper - exper_white_collar
    gen workWC =  whiteCollar
    gen workBC = !whiteCollar
    qui tab utype, gen(ut)

    qui sum e_lnwage
    local bigN = r(N)
    foreach sector in WC BC { 
        qui sum e_lnwage if  grad_4yr &  finalSciMaj & work`sector'
        matrix table1[rownumb(table1,"`sector'_grad_sci"), colnumb(table1,"avg`Dat'")] = `r(mean)'
        matrix table1[rownumb(table1,"`sector'_grad_sci"), colnumb(table1,"shr`Dat'")] = `r(N)'/`bigN'
        qui sum e_lnwage if  grad_4yr & !finalSciMaj & work`sector'
        matrix table1[rownumb(table1,"`sector'_grad_hum"), colnumb(table1,"avg`Dat'")] = `r(mean)'
        matrix table1[rownumb(table1,"`sector'_grad_hum"), colnumb(table1,"shr`Dat'")] = `r(N)'/`bigN'
        qui sum e_lnwage if !grad_4yr                & work`sector'
        matrix table1[rownumb(table1,"`sector'_ng"), colnumb(table1,"avg`Dat'")] = `r(mean)'
        matrix table1[rownumb(table1,"`sector'_ng"), colnumb(table1,"shr`Dat'")] = `r(N)'/`bigN'

        foreach sec in WC BC 4S 4H 2 {
            qui sum trueAbil`sec'_nsd if  grad_4yr &  finalSciMaj & work`sector'
            matrix table1[rownumb(table1,"`sector'_grad_sci"), colnumb(table1,"avgAbil`sec'`Dat'")] = `r(mean)'
            matrix table1[rownumb(table1,"`sector'_grad_sci"), colnumb(table1,"sdAbil`sec'`Dat'")]  = `r(sd)'
            qui sum trueAbil`sec'_nsd if  grad_4yr & !finalSciMaj & work`sector'
            matrix table1[rownumb(table1,"`sector'_grad_hum"), colnumb(table1,"avgAbil`sec'`Dat'")] = `r(mean)'
            matrix table1[rownumb(table1,"`sector'_grad_hum"), colnumb(table1,"sdAbil`sec'`Dat'")]  = `r(sd)'
            qui sum trueAbil`sec'_nsd if !grad_4yr                & work`sector'
            matrix table1[rownumb(table1,"`sector'_ng"), colnumb(table1,"avgAbil`sec'`Dat'")] = `r(mean)'
            matrix table1[rownumb(table1,"`sector'_ng"), colnumb(table1,"sdAbil`sec'`Dat'")]  = `r(sd)'
        }
        forv s=1/8 {
            qui sum ut`s' if  grad_4yr &  finalSciMaj & work`sector' 
            matrix table1[rownumb(table1,"`sector'_grad_sci"), colnumb(table1,"ut`s'`Dat'")] = `r(mean)'
            qui sum ut`s' if  grad_4yr & !finalSciMaj & work`sector' 
            matrix table1[rownumb(table1,"`sector'_grad_hum"), colnumb(table1,"ut`s'`Dat'")] = `r(mean)'
            qui sum ut`s' if !grad_4yr                & work`sector' 
            matrix table1[rownumb(table1,"`sector'_ng"), colnumb(table1,"ut`s'`Dat'")] = `r(mean)'
        }
    }

    * overall CWP
    qui reg e_lnwage grad_4yr
    matrix table1[rownumb(table1,"ovrCWP"), colnumb(table1,"avg`Dat'")] = _b[grad_4yr]

    * CWP by major
    qui reg e_lnwage i.grad_4yr##i.finalSciMaj
    matrix table1[rownumb(table1,"sciCWP"), colnumb(table1,"avg`Dat'")] = _b[1.grad_4yr] + _b[1.finalSciMaj]
    matrix table1[rownumb(table1,"humCWP"), colnumb(table1,"avg`Dat'")] = _b[1.grad_4yr]

    * white collar premium
    qui reg e_lnwage workWC
    matrix table1[rownumb(table1,"ovrWCP"), colnumb(table1,"avg`Dat'")] = _b[workWC]

    * overall CWP -- ability only
    qui reg e_abil grad_4yr
    local ovrCAP`Dat' = _b[grad_4yr]

    * CWP by major -- ability only
    qui reg e_abil i.grad_4yr##i.finalSciMaj
    local sciCAP`Dat' = _b[1.grad_4yr] + _b[1.finalSciMaj]
    local humCAP`Dat' = _b[1.grad_4yr]

    * white collar premium -- ability only
    qui reg e_abil workWC
    local ovrWCA`Dat' = _b[workWC]

    * mean experience levels
    qui sum exper_white_collar
    matrix table1[rownumb(table1,"WCexper"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdWCexper"), colnumb(table1,"avg`Dat'")] = r(sd)
    qui sum exper_blue_collar
    matrix table1[rownumb(table1,"BCexper"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdBCexper"), colnumb(table1,"avg`Dat'")] = r(sd)
    qui sum exper_white_collar if workWC
    matrix table1[rownumb(table1,"WCcondExper"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdWCcondExper"), colnumb(table1,"avg`Dat'")] = r(sd)
    qui sum exper_blue_collar  if workBC
    matrix table1[rownumb(table1,"BCcondExper"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdBCcondExper"), colnumb(table1,"avg`Dat'")] = r(sd)
    
    qui sum exper_white_collar if grad_4yr & finalSciMaj
    matrix table1[rownumb(table1,"WCexper_g_s"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdWCexper_g_s"), colnumb(table1,"avg`Dat'")] = r(sd)
    qui sum exper_blue_collar if grad_4yr & finalSciMaj
    matrix table1[rownumb(table1,"BCexper_g_s"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdBCexper_g_s"), colnumb(table1,"avg`Dat'")] = r(sd)
    qui sum exper_white_collar if workWC & grad_4yr & finalSciMaj
    matrix table1[rownumb(table1,"WCcondExper_g_s"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdWCcondExper_g_s"), colnumb(table1,"avg`Dat'")] = r(sd)
    qui sum exper_blue_collar  if workBC & grad_4yr & finalSciMaj
    matrix table1[rownumb(table1,"BCcondExper_g_s"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdBCcondExper_g_s"), colnumb(table1,"avg`Dat'")] = r(sd)
    
    qui sum exper_white_collar if grad_4yr & !finalSciMaj
    matrix table1[rownumb(table1,"WCexper_g_ns"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdWCexper_g_ns"), colnumb(table1,"avg`Dat'")] = r(sd)
    qui sum exper_blue_collar  if grad_4yr & !finalSciMaj 
    matrix table1[rownumb(table1,"BCexper_g_ns"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdBCexper_g_ns"), colnumb(table1,"avg`Dat'")] = r(sd)
    qui sum exper_white_collar if workWC & grad_4yr & !finalSciMaj 
    matrix table1[rownumb(table1,"WCcondExper_g_ns"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdWCcondExper_g_ns"), colnumb(table1,"avg`Dat'")] = r(sd)
    qui sum exper_blue_collar  if workBC & grad_4yr & !finalSciMaj 
    matrix table1[rownumb(table1,"BCcondExper_g_ns"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdBCcondExper_g_ns"), colnumb(table1,"avg`Dat'")] = r(sd)
    
    qui sum exper_white_collar if !grad_4yr
    matrix table1[rownumb(table1,"WCexper_ng"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdWCexper_ng"), colnumb(table1,"avg`Dat'")] = r(sd)
    qui sum exper_blue_collar if !grad_4yr
    matrix table1[rownumb(table1,"BCexper_ng"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdBCexper_ng"), colnumb(table1,"avg`Dat'")] = r(sd)
    qui sum exper_white_collar if workWC & !grad_4yr
    matrix table1[rownumb(table1,"WCcondExper_ng"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdWCcondExper_ng"), colnumb(table1,"avg`Dat'")] = r(sd)
    qui sum exper_blue_collar  if workBC & !grad_4yr
    matrix table1[rownumb(table1,"BCcondExper_ng"), colnumb(table1,"avg`Dat'")] = r(mean)
    matrix table1[rownumb(table1,"sdBCcondExper_ng"), colnumb(table1,"avg`Dat'")] = r(sd)
    
    * experience by blue collar ability decile
    forv ddd = 1/10 {
        qui sum exper if bcDecile==`ddd'
        matrix table3[rownumb(table3,"decile`ddd'"), colnumb(table3,"avgExper`Dat'")] = r(mean)
        qui sum trueAbilBC_nsd if bcDecile==`ddd'
        matrix table3[rownumb(table3,"decile`ddd'"), colnumb(table3,"avgAbil`Dat'")] = r(mean)
    }

    * create dummies for each group:
    gen wc_sci = workWC &  grad_4yr &  finalSciMaj 
    gen wc_hum = workWC &  grad_4yr & !finalSciMaj 
    gen bc_sci = workBC &  grad_4yr &  finalSciMaj 
    gen bc_hum = workBC &  grad_4yr & !finalSciMaj 
    gen wc_ng  = workWC & !grad_4yr
    gen bc_ng  = workBC & !grad_4yr

    * counterfactual characteristics
    foreach cfl_var in wc_g_s wc_g_ns bc_g_s bc_g_ns wc_ng bc_ng {
        gen tmpvar = e_lnwage_`cfl_var' - e_lnwage
        foreach group in wc_sci wc_hum bc_sci bc_hum wc_ng bc_ng {
            if !inlist("`cfl_var'_`group'","wc_g_s_wc_sci","wc_g_ns_wc_hum","bc_g_s_bc_sci","bc_g_ns_bc_hum","wc_ng_wc_ng","bc_ng_bc_ng") {
                qui sum e_lnwage_`cfl_var' if `group'
                matrix table2a[rownumb(table2a,"`cfl_var'_`group'"), colnumb(table2a,"avg`Dat'")] = r(mean)
                qui sum tmpvar             if `group'
                matrix table2b[rownumb(table2b,"`cfl_var'_`group'"), colnumb(table2b,"avg`Dat'")] = r(mean)
            }
        }
        drop tmpvar
    }
restore
}



*:::::::::::::::::::::::::::::::::::::::
* Decomposition calculations (uncond'l)
*:::::::::::::::::::::::::::::::::::::::
// initialize matrix
matrix table1uc     = J(18,6,0)
matrix table1utuc   = J(18,27,0)
matrix table1abuc   = J(18,33,0)
matrix table1absduc = J(18,18,0)
matrix colnames table1uc   = avgFwd avgCfl avgCflNoFric shrFwd shrCfl shrCflNoFric
matrix rownames table1uc   = WCFT_grad_sci WCFT_grad_hum BCFT_grad_sci BCFT_grad_hum WCFT_ng BCFT_ng WCPT_grad_sci WCPT_grad_hum BCPT_grad_sci BCPT_grad_hum WCPT_ng BCPT_ng NOhixp_grad_sci NOhixp_grad_hum NOhixp_ng NOloxp_grad_sci NOloxp_grad_hum NOloxp_ng 
matrix rownames table1abuc = WCFT_grad_sci WCFT_grad_hum BCFT_grad_sci BCFT_grad_hum WCFT_ng BCFT_ng WCPT_grad_sci WCPT_grad_hum BCPT_grad_sci BCPT_grad_hum WCPT_ng BCPT_ng NOhixp_grad_sci NOhixp_grad_hum NOhixp_ng NOloxp_grad_sci NOloxp_grad_hum NOloxp_ng  
matrix colnames table1abuc = avgFwd avgCfl avgCflNoFric avgAbilWCFwd avgAbilWCCfl avgAbilWCCflNoFric avgAbilBCFwd avgAbilBCCfl avgAbilBCCflNoFric avgAbil4SFwd avgAbil4SCfl avgAbil4SCflNoFric avgAbil4HFwd avgAbil4HCfl avgAbil4HCflNoFric avgAbil2Fwd avgAbil2Cfl avgAbil2CflNoFric sdAbilWCFwd sdAbilWCCfl sdAbilWCCflNoFric sdAbilBCFwd sdAbilBCCfl sdAbilBCCflNoFric sdAbil4SFwd sdAbil4SCfl sdAbil4SCflNoFric sdAbil4HFwd sdAbil4HCfl sdAbil4HCflNoFric sdAbil2Fwd sdAbil2Cfl sdAbil2CflNoFric 
matrix rownames table1absduc = WCFT_grad_sci WCFT_grad_hum BCFT_grad_sci BCFT_grad_hum WCFT_ng BCFT_ng WCPT_grad_sci WCPT_grad_hum BCPT_grad_sci BCPT_grad_hum WCPT_ng BCPT_ng NOhixp_grad_sci NOhixp_grad_hum NOhixp_ng NOloxp_grad_sci NOloxp_grad_hum NOloxp_ng  
matrix colnames table1absduc = avgFwd avgCfl avgCflNoFric avgPosteriorSDWCFwd avgPosteriorSDWCCfl avgPosteriorSDWCCflNoFric avgPosteriorSDBCFwd avgPosteriorSDBCCfl avgPosteriorSDBCCflNoFric avgPosteriorSD4SFwd avgPosteriorSD4SCfl avgPosteriorSD4SCflNoFric avgPosteriorSD4HFwd avgPosteriorSD4HCfl avgPosteriorSD4HCflNoFric avgPosteriorSD2Fwd avgPosteriorSD2Cfl avgPosteriorSD2CflNoFric
matrix rownames table1utuc = WCFT_grad_sci WCFT_grad_hum BCFT_grad_sci BCFT_grad_hum WCFT_ng BCFT_ng WCPT_grad_sci WCPT_grad_hum BCPT_grad_sci BCPT_grad_hum WCPT_ng BCPT_ng NOhixp_grad_sci NOhixp_grad_hum NOhixp_ng NOloxp_grad_sci NOloxp_grad_hum NOloxp_ng  
matrix colnames table1utuc = avgFwd avgCfl avgCflNoFric ut1Fwd ut1Cfl ut1CflNoFric ut2Fwd ut2Cfl ut2CflNoFric ut3Fwd ut3Cfl ut3CflNoFric ut4Fwd ut4Cfl ut4CflNoFric ut5Fwd ut5Cfl ut5CflNoFric ut6Fwd ut6Cfl ut6CflNoFric ut7Fwd ut7Cfl ut7CflNoFric ut8Fwd ut8Cfl ut8CflNoFric

foreach Dat in Fwd Cfl CflNoFric {
preserve
    use ``Dat'WageDecomp', clear
    keep if t==10
    gen exper_blue_collar = exper - exper_white_collar
    gen workWCFT   =  whiteCollar & workFT
    gen workBCFT   = !whiteCollar & workFT
    gen workWCPT   =  whiteCollar & workPT
    gen workBCPT   = !whiteCollar & workPT
    gen workNO     = !workFT & !workPT
    gen workNOhixp = !workFT & !workPT & exper>=6
    gen workNOloxp = !workFT & !workPT & exper<6
    qui tab utype, gen(ut)
    sum work*

    qui sum workFT
    local bigN = r(N)
    foreach sector in WCFT BCFT WCPT BCPT NOhixp NOloxp { 
        if inlist("`sector'","WCFT","BCFT","WCPT","BCPT") {
            qui sum e_lnwage if  grad_4yr &  finalSciMaj & work`sector'
            if `r(N)'!=0 matrix table1uc[rownumb(table1uc,"`sector'_grad_sci"), colnumb(table1uc,"avg`Dat'")] = `r(mean)'
                         matrix table1uc[rownumb(table1uc,"`sector'_grad_sci"), colnumb(table1uc,"shr`Dat'")] = `r(N)'/`bigN'
            qui sum e_lnwage if  grad_4yr & !finalSciMaj & work`sector'
            if `r(N)'!=0 matrix table1uc[rownumb(table1uc,"`sector'_grad_hum"), colnumb(table1uc,"avg`Dat'")] = `r(mean)'
                         matrix table1uc[rownumb(table1uc,"`sector'_grad_hum"), colnumb(table1uc,"shr`Dat'")] = `r(N)'/`bigN'
            qui sum e_lnwage if !grad_4yr                & work`sector'
            if `r(N)'!=0 matrix table1uc[rownumb(table1uc,"`sector'_ng"), colnumb(table1uc,"avg`Dat'")] = `r(mean)'
                         matrix table1uc[rownumb(table1uc,"`sector'_ng"), colnumb(table1uc,"shr`Dat'")] = `r(N)'/`bigN'
        }
        if inlist("`sector'","NOhixp","NOloxp") {
            qui sum exper if  grad_4yr &  finalSciMaj & work`sector'
            matrix table1uc[rownumb(table1uc,"`sector'_grad_sci"), colnumb(table1uc,"shr`Dat'")] = `r(N)'/`bigN'
            qui sum exper if  grad_4yr & !finalSciMaj & work`sector'
            matrix table1uc[rownumb(table1uc,"`sector'_grad_hum"), colnumb(table1uc,"shr`Dat'")] = `r(N)'/`bigN'
            qui sum exper if !grad_4yr                & work`sector'
            matrix table1uc[rownumb(table1uc,"`sector'_ng"), colnumb(table1uc,"shr`Dat'")] = `r(N)'/`bigN'
        }
        foreach sec in WC BC 4S 4H 2 {
            qui sum trueAbil`sec'_nsd if  grad_4yr &  finalSciMaj & work`sector'
            if `r(N)'!=0 matrix table1abuc[rownumb(table1abuc,"`sector'_grad_sci"), colnumb(table1abuc,"avgAbil`sec'`Dat'")] = `r(mean)'
                         matrix table1abuc[rownumb(table1abuc,"`sector'_grad_sci"), colnumb(table1abuc,"sdAbil`sec'`Dat'")]  = `r(sd)'
            qui sum trueAbil`sec'_nsd if  grad_4yr & !finalSciMaj & work`sector'
            if `r(N)'!=0 matrix table1abuc[rownumb(table1abuc,"`sector'_grad_hum"), colnumb(table1abuc,"avgAbil`sec'`Dat'")] = `r(mean)'
                         matrix table1abuc[rownumb(table1abuc,"`sector'_grad_hum"), colnumb(table1abuc,"sdAbil`sec'`Dat'")]  = `r(sd)'
            qui sum trueAbil`sec'_nsd if !grad_4yr                & work`sector'
            if `r(N)'!=0 matrix table1abuc[rownumb(table1abuc,"`sector'_ng"), colnumb(table1abuc,"avgAbil`sec'`Dat'")] = `r(mean)'
                         matrix table1abuc[rownumb(table1abuc,"`sector'_ng"), colnumb(table1abuc,"sdAbil`sec'`Dat'")]  = `r(sd)'

            qui sum posteriorSD`sec' if  grad_4yr &  finalSciMaj & work`sector'
            if `r(N)'!=0 matrix table1absduc[rownumb(table1absduc,"`sector'_grad_sci"), colnumb(table1absduc,"avgPosteriorSD`sec'`Dat'")] = `r(mean)'
            qui sum posteriorSD`sec' if  grad_4yr & !finalSciMaj & work`sector'
            if `r(N)'!=0 matrix table1absduc[rownumb(table1absduc,"`sector'_grad_hum"), colnumb(table1absduc,"avgPosteriorSD`sec'`Dat'")] = `r(mean)'
            qui sum posteriorSD`sec' if !grad_4yr                & work`sector'
            if `r(N)'!=0 matrix table1absduc[rownumb(table1absduc,"`sector'_ng"), colnumb(table1absduc,"avgPosteriorSD`sec'`Dat'")] = `r(mean)'
        }
        forv s=1/8 {
            qui sum ut`s' if  grad_4yr &  finalSciMaj & work`sector' 
            if `r(N)'!=0 matrix table1utuc[rownumb(table1utuc,"`sector'_grad_sci"), colnumb(table1utuc,"ut`s'`Dat'")] = `r(mean)'
            qui sum ut`s' if  grad_4yr & !finalSciMaj & work`sector' 
            if `r(N)'!=0 matrix table1utuc[rownumb(table1utuc,"`sector'_grad_hum"), colnumb(table1utuc,"ut`s'`Dat'")] = `r(mean)'
            qui sum ut`s' if !grad_4yr                & work`sector' 
            if `r(N)'!=0 matrix table1utuc[rownumb(table1utuc,"`sector'_ng"), colnumb(table1utuc,"ut`s'`Dat'")] = `r(mean)'
        }
    }


    foreach sector in WCFT BCFT WCPT BCPT NO { 
        foreach sec in WC BC 4S 4H 2 {
            qui sum trueAbil`sec'_nsd if  grad_4yr &  finalSciMaj & work`sector'
            local ab_`sec'_`sector'_sci_`Dat' = `r(mean)'
            qui sum trueAbil`sec'_nsd if  grad_4yr & !finalSciMaj & work`sector'
            local ab_`sec'_`sector'_hum_`Dat' = `r(mean)'
            qui sum trueAbil`sec'_nsd if !grad_4yr                & work`sector'
            local ab_`sec'_`sector'_ng_`Dat'  = `r(mean)'
        }
    }

restore
}




*:::::::::::::::::::::::::::::::::::::::
* Make Tables
*:::::::::::::::::::::::::::::::::::::::

* locals to be used later
local ovr_cwp_base  : di table1[rownumb(table1,"ovrCWP"), colnumb(table1,"avgFwd")]
local ovr_cwp_cfl   : di table1[rownumb(table1,"ovrCWP"), colnumb(table1,"avgCfl")]
local ovr_cwp_cflnf : di table1[rownumb(table1,"ovrCWP"), colnumb(table1,"avgCflNoFric")]
local sci_cwp_base  : di table1[rownumb(table1,"sciCWP"), colnumb(table1,"avgFwd")]
local sci_cwp_cfl   : di table1[rownumb(table1,"sciCWP"), colnumb(table1,"avgCfl")]
local sci_cwp_cflnf : di table1[rownumb(table1,"sciCWP"), colnumb(table1,"avgCflNoFric")]
local hum_cwp_base  : di table1[rownumb(table1,"humCWP"), colnumb(table1,"avgFwd")]
local hum_cwp_cfl   : di table1[rownumb(table1,"humCWP"), colnumb(table1,"avgCfl")]
local hum_cwp_cflnf : di table1[rownumb(table1,"humCWP"), colnumb(table1,"avgCflNoFric")]
local ovr_wcp_base  : di table1[rownumb(table1,"ovrWCP"), colnumb(table1,"avgFwd")]
local ovr_wcp_cfl   : di table1[rownumb(table1,"ovrWCP"), colnumb(table1,"avgCfl")]
local ovr_wcp_cflnf : di table1[rownumb(table1,"ovrWCP"), colnumb(table1,"avgCflNoFric")]

local wc_g_s_base:  di table1[rownumb(table1,"WC_grad_sci"),colnumb(table1,"avgFwd")]       - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local wc_g_s_cfl:   di table1[rownumb(table1,"WC_grad_sci"),colnumb(table1,"avgCfl")]       - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local wc_g_s_cflnf: di table1[rownumb(table1,"WC_grad_sci"),colnumb(table1,"avgCflNoFric")] - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local wc_g_h_base:  di table1[rownumb(table1,"WC_grad_hum"),colnumb(table1,"avgFwd")]       - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local wc_g_h_cfl:   di table1[rownumb(table1,"WC_grad_hum"),colnumb(table1,"avgCfl")]       - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local wc_g_h_cflnf: di table1[rownumb(table1,"WC_grad_hum"),colnumb(table1,"avgCflNoFric")] - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local bc_g_s_base:  di table1[rownumb(table1,"BC_grad_sci"),colnumb(table1,"avgFwd")]       - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local bc_g_s_cfl:   di table1[rownumb(table1,"BC_grad_sci"),colnumb(table1,"avgCfl")]       - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local bc_g_s_cflnf: di table1[rownumb(table1,"BC_grad_sci"),colnumb(table1,"avgCflNoFric")] - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local bc_g_h_base:  di table1[rownumb(table1,"BC_grad_hum"),colnumb(table1,"avgFwd")]       - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local bc_g_h_cfl:   di table1[rownumb(table1,"BC_grad_hum"),colnumb(table1,"avgCfl")]       - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local bc_g_h_cflnf: di table1[rownumb(table1,"BC_grad_hum"),colnumb(table1,"avgCflNoFric")] - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local wc_ng_base:   di table1[rownumb(table1,"WC_ng"),colnumb(table1,"avgFwd")]             - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local wc_ng_cfl:    di table1[rownumb(table1,"WC_ng"),colnumb(table1,"avgCfl")]             - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local wc_ng_cflnf:  di table1[rownumb(table1,"WC_ng"),colnumb(table1,"avgCflNoFric")]       - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local bc_ng_base:   di table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]             - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local bc_ng_cfl:    di table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgCfl")]             - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]
local bc_ng_cflnf:  di table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgCflNoFric")]       - table1[rownumb(table1,"BC_ng"),colnumb(table1,"avgFwd")]

local shr_wc_g_s_base:  di 100*table1uc[rownumb(table1uc,"WCFT_grad_sci"),colnumb(table1uc,"shrFwd")]
local shr_wc_g_s_cfl:   di 100*table1uc[rownumb(table1uc,"WCFT_grad_sci"),colnumb(table1uc,"shrCfl")]
local shr_wc_g_s_cflnf: di 100*table1uc[rownumb(table1uc,"WCFT_grad_sci"),colnumb(table1uc,"shrCflNoFric")]
local shr_wc_g_h_base:  di 100*table1uc[rownumb(table1uc,"WCFT_grad_hum"),colnumb(table1uc,"shrFwd")]
local shr_wc_g_h_cfl:   di 100*table1uc[rownumb(table1uc,"WCFT_grad_hum"),colnumb(table1uc,"shrCfl")]
local shr_wc_g_h_cflnf: di 100*table1uc[rownumb(table1uc,"WCFT_grad_hum"),colnumb(table1uc,"shrCflNoFric")]
local shr_bc_g_s_base:  di 100*table1uc[rownumb(table1uc,"BCFT_grad_sci"),colnumb(table1uc,"shrFwd")]
local shr_bc_g_s_cfl:   di 100*table1uc[rownumb(table1uc,"BCFT_grad_sci"),colnumb(table1uc,"shrCfl")]
local shr_bc_g_s_cflnf: di 100*table1uc[rownumb(table1uc,"BCFT_grad_sci"),colnumb(table1uc,"shrCflNoFric")]
local shr_bc_g_h_base:  di 100*table1uc[rownumb(table1uc,"BCFT_grad_hum"),colnumb(table1uc,"shrFwd")]
local shr_bc_g_h_cfl:   di 100*table1uc[rownumb(table1uc,"BCFT_grad_hum"),colnumb(table1uc,"shrCfl")]
local shr_bc_g_h_cflnf: di 100*table1uc[rownumb(table1uc,"BCFT_grad_hum"),colnumb(table1uc,"shrCflNoFric")]
local shr_wc_ng_base:   di 100*table1uc[rownumb(table1uc,"WCFT_ng"),colnumb(table1uc,"shrFwd")]
local shr_wc_ng_cfl:    di 100*table1uc[rownumb(table1uc,"WCFT_ng"),colnumb(table1uc,"shrCfl")]
local shr_wc_ng_cflnf:  di 100*table1uc[rownumb(table1uc,"WCFT_ng"),colnumb(table1uc,"shrCflNoFric")]
local shr_bc_ng_base:   di 100*table1uc[rownumb(table1uc,"BCFT_ng"),colnumb(table1uc,"shrFwd")]
local shr_bc_ng_cfl:    di 100*table1uc[rownumb(table1uc,"BCFT_ng"),colnumb(table1uc,"shrCfl")]
local shr_bc_ng_cflnf:  di 100*table1uc[rownumb(table1uc,"BCFT_ng"),colnumb(table1uc,"shrCflNoFric")]
local shr_other_base:   di 100*(1-table1uc[rownumb(table1uc,"WCFT_grad_sci"),colnumb(table1uc,"shrFwd")]-table1uc[rownumb(table1uc,"WCFT_grad_hum"),colnumb(table1uc,"shrFwd")]-table1uc[rownumb(table1uc,"BCFT_grad_sci"),colnumb(table1uc,"shrFwd")]-table1uc[rownumb(table1uc,"BCFT_grad_hum"),colnumb(table1uc,"shrFwd")]-table1uc[rownumb(table1uc,"WCFT_ng"),colnumb(table1uc,"shrFwd")]-table1uc[rownumb(table1uc,"BCFT_ng"),colnumb(table1uc,"shrFwd")])
local shr_other_cfl:    di 100*(1-table1uc[rownumb(table1uc,"WCFT_grad_sci"),colnumb(table1uc,"shrCfl")]-table1uc[rownumb(table1uc,"WCFT_grad_hum"),colnumb(table1uc,"shrCfl")]-table1uc[rownumb(table1uc,"BCFT_grad_sci"),colnumb(table1uc,"shrCfl")]-table1uc[rownumb(table1uc,"BCFT_grad_hum"),colnumb(table1uc,"shrCfl")]-table1uc[rownumb(table1uc,"WCFT_ng"),colnumb(table1uc,"shrCfl")]-table1uc[rownumb(table1uc,"BCFT_ng"),colnumb(table1uc,"shrCfl")])
local shr_other_cflnf:  di 100*(1-table1uc[rownumb(table1uc,"WCFT_grad_sci"),colnumb(table1uc,"shrCflNoFric")]-table1uc[rownumb(table1uc,"WCFT_grad_hum"),colnumb(table1uc,"shrCflNoFric")]-table1uc[rownumb(table1uc,"BCFT_grad_sci"),colnumb(table1uc,"shrCflNoFric")]-table1uc[rownumb(table1uc,"BCFT_grad_hum"),colnumb(table1uc,"shrCflNoFric")]-table1uc[rownumb(table1uc,"WCFT_ng"),colnumb(table1uc,"shrCflNoFric")]-table1uc[rownumb(table1uc,"BCFT_ng"),colnumb(table1uc,"shrCflNoFric")])


* Wage decomposition table -- panel (a)
file open tf using "${tblpath}table_wage_decomp.tex", write replace
file write tf "\begin{table} "_n
file write tf "\caption{Wage Decompositions} "_n
file write tf "\label{tab:wageDecomp} "_n
file write tf "\centering{} "_n
file write tf "\subfloat[Average full-time log wage and choice share by employment sector and education level at age 28 in baseline and counterfactual models]{ "_n
file write tf "\resizebox{\textwidth}{!}{ "_n
file write tf "\begin{threeparttable} "_n
file write tf "\begin{tabular}{lcccccc} "_n
file write tf "\toprule "_n
file write tf " & \multicolumn{3}{c}{Average full-time log wage, relative to} & & & \\ "_n
file write tf " & \multicolumn{3}{c}{blue-collar non-graduates in baseline} & \multicolumn{3}{c}{Choice shares (\%)} \\ "_n
file write tf "\cmidrule(r){2-4}\cmidrule(l){5-7} "_n
file write tf "Sector and Education Level & Baseline & Counterfactual & No Frictions Cfl & Baseline & Counterfactual & No Frictions Cfl \\ "_n
file write tf "\midrule "_n
file write tf "White collar, Science graduate"     " & " %4.3f (`wc_g_s_base') " & " %4.3f (`wc_g_s_cfl') " & " %4.3f (`wc_g_s_cflnf') " & " %4.3f (`shr_wc_g_s_base') " & " %4.3f (`shr_wc_g_s_cfl') " & " %4.3f (`shr_wc_g_s_cflnf') " \\ "  _n
file write tf "White collar, Non-Science graduate" " & " %4.3f (`wc_g_h_base') " & " %4.3f (`wc_g_h_cfl') " & " %4.3f (`wc_g_h_cflnf') " & " %4.3f (`shr_wc_g_h_base') " & " %4.3f (`shr_wc_g_h_cfl') " & " %4.3f (`shr_wc_g_h_cflnf') " \\ "  _n
file write tf "White collar, Non-graduate"         " & " %4.3f (`wc_ng_base')  " & " %4.3f (`wc_ng_cfl')  " & " %4.3f (`wc_ng_cflnf')  " & " %4.3f (`shr_wc_ng_base')  " & " %4.3f (`shr_wc_ng_cfl')  " & " %4.3f (`shr_wc_ng_cflnf')  " \\ "  _n 
file write tf "Blue collar, Science graduate"      " & " %4.3f (`bc_g_s_base') " & " %4.3f (`bc_g_s_cfl') " & " %4.3f (`bc_g_s_cflnf') " & " %4.3f (`shr_bc_g_s_base') " & " %4.3f (`shr_bc_g_s_cfl') " & " %4.3f (`shr_bc_g_s_cflnf') " \\ "  _n
file write tf "Blue collar, Non-Science graduate"  " & " %4.3f (`bc_g_h_base') " & " %4.3f (`bc_g_h_cfl') " & " %4.3f (`bc_g_h_cflnf') " & " %4.3f (`shr_bc_g_h_base') " & " %4.3f (`shr_bc_g_h_cfl') " & " %4.3f (`shr_bc_g_h_cflnf') " \\ "  _n 
file write tf "Blue collar, Non-graduate"          " & " %4.3f (`bc_ng_base')  " & " %4.3f (`bc_ng_cfl')  " & " %4.3f (`bc_ng_cflnf')  " & " %4.3f (`shr_bc_ng_base')  " & " %4.3f (`shr_bc_ng_cfl')  " & " %4.3f (`shr_bc_ng_cflnf')  " \\ "  _n
file write tf "Remainder & --- & --- & --- "  " & " %4.3f (`shr_other_base')  " & " %4.3f (`shr_other_cfl')  " & " %4.3f (`shr_other_cflnf') " \\ "  _n
file write tf "\bottomrule "_n
file write tf "\end{tabular} "_n
file write tf "\footnotesize Notes: " "`" "`" "No Frictions Cfl" "'" "'" " refers to the counterfactual where white-collar work is always an option. Columns in the " "`" "`" "choice shares" "'" "'" " panel sum to 100. "_n
file write tf "\end{threeparttable} "_n
file write tf "} "_n
file write tf "} "_n
file write tf "\bigskip "_n
file write tf "\bigskip "_n



* Wage decomposition table -- panel (b)
file write tf "\subfloat[Full-time log wage premia at age 28 in baseline and counterfactual models]{ "_n
file write tf "\resizebox{\textwidth}{!}{ "_n
file write tf "\begin{threeparttable} "_n
file write tf "\begin{tabular}{lcccccc} "_n
file write tf "\toprule "_n
file write tf "& & & & \multicolumn{3}{c}{Change in premium (relative to baseline)} \\"_n
file write tf " & \multicolumn{3}{c}{Full-time log wage premium} & \multicolumn{3}{c}{due to better sorting on abilities} \\ "_n
file write tf "\cmidrule(r){2-4}\cmidrule(l){5-7} "_n
file write tf "Sector & Baseline & Counterfactual & No Frictions Cfl & Baseline & Counterfactual & No Frictions Cfl \\ "_n
file write tf "\midrule "_n
file write tf "College wage premium"     " & " %4.3f (`ovr_cwp_base') " & " %4.3f (`ovr_cwp_cfl') " & " %4.3f (`ovr_cwp_cflnf') " & --- & " %4.3f (`=`ovrCAPCfl'-`ovrCAPFwd'') " & " %4.3f (`=`ovrCAPCflNoFric'-`ovrCAPFwd'') " \\ "  _n
file write tf "Science college premium"     " & " %4.3f (`sci_cwp_base') " & " %4.3f (`sci_cwp_cfl') " & " %4.3f (`sci_cwp_cflnf') " & --- & " %4.3f (`=`sciCAPCfl'-`sciCAPFwd'') " & " %4.3f (`=`sciCAPCflNoFric'-`sciCAPFwd'') " \\ "  _n 
file write tf "Non-science college premium"     " & " %4.3f (`hum_cwp_base') " & " %4.3f (`hum_cwp_cfl') " & " %4.3f (`hum_cwp_cflnf') " & --- & " %4.3f (`=`humCAPCfl'-`humCAPFwd'') " & " %4.3f (`=`humCAPCflNoFric'-`humCAPFwd'') " \\ "  _n 
file write tf "White-collar wage premium"     " & " %4.3f (`ovr_wcp_base') " & " %4.3f (`ovr_wcp_cfl') " & " %4.3f (`ovr_wcp_cflnf') " & --- & " %4.3f (`=`ovrWCACfl'-`ovrWCAFwd'') " & " %4.3f (`=`ovrWCACflNoFric'-`ovrWCAFwd'') " \\ "  _n 
file write tf "\bottomrule "_n
file write tf "\end{tabular} "_n
file write tf "\footnotesize Notes: " "`" "`" "College wage premium" "'" "'" " is the difference in average log wages between college graduates (regardless of major) and non-graduates. " "`" "`" "Science college premium" "'" "'" "  is the difference in average log wages between science graduates and non-graduates. " "`" "`" "Non-science college premium" "'" "'" "  is the difference in average log wages between non-science graduates and non-graduates. " "`" "`" "White collar premium" "'" "'" "  is the difference in average log wages between white-collar and blue-collar workers. "_n
file write tf " "_n
file write tf "\medskip{} "_n
file write tf " "_n
file write tf "For the panel on changes in premia, numbers represent differences in differences in average abilities (in log dollar units). The first difference is between sector groups (e.g. college graduates vs. non-graduates) and the second difference is between counterfactual and baseline. We compress the bivariate work ability distribution into a single ability index based on which sector each full-time worker is working in. "_n
file write tf "\end{threeparttable} "_n
file write tf "} "_n
file write tf "} "_n
file write tf "\end{table} "_n
file close tf

* Ability sorting appendix table
file open tg using "${tblpath}table_abil_sort_appendix.tex", write replace
file write tg "\begin{landscape} "_n
file write tg "\begin{table} "_n
file write tg "\caption{Average abilities by employment sector and education level at age 28 in baseline and counterfactual models} "_n
file write tg "\label{tab:abilsort28} "_n
file write tg "\centering "_n
file write tg "\resizebox{1.4\textwidth}{!}{ "_n
file write tg "\begin{threeparttable} "_n
file write tg "\begin{tabular}{cc@{\hspace{4pt}}ccccccccccccccccc} "_n
file write tg "\toprule "_n
file write tg "& & & & \multicolumn{3}{c}{White Collar} & \multicolumn{3}{c}{Blue Collar} & \multicolumn{3}{c}{4-year Science} & \multicolumn{3}{c}{4-year Non-Science} & \multicolumn{3}{c}{2-year} \\ \cmidrule(r){5-7}\cmidrule(lr){8-10}\cmidrule(r){11-13}\cmidrule(r){14-16}\cmidrule(r){17-19} "_n
file write tg "\multicolumn{4}{l}{Sector and education level} & Baseline & Cfl & N.F.  Cfl & Baseline & Cfl & N.F.  Cfl & Baseline & Cfl & N.F.  Cfl & Baseline & Cfl & N.F.  Cfl & Baseline & Cfl & N.F.  Cfl \\ "_n
file write tg "\midrule "_n
//    foreach sector in WCFT BCFT WCPT BCPT NO { 
//        foreach sec in WC BC 4S 4H 2 {
file write tg "\multirow{6}{*}{\rotatebox[origin=c]{90}{Full-time}} & \multirow{3}{*}{\rotatebox[origin=c]{90}{White}} & \multirow{3}{*}{\rotatebox[origin=c]{90}{Collar}} &  Science & " %4.2f (`ab_WC_WCFT_sci_Fwd') " & " %4.2f (`ab_WC_WCFT_sci_Cfl') " & " %4.2f (`ab_WC_WCFT_sci_CflNoFric') " & " %4.2f (`ab_BC_WCFT_sci_Fwd') " & " %4.2f (`ab_BC_WCFT_sci_Cfl') " & " %4.2f (`ab_BC_WCFT_sci_CflNoFric')  " & " %4.2f (`ab_4S_WCFT_sci_Fwd') " & " %4.2f (`ab_4S_WCFT_sci_Cfl') " & " %4.2f (`ab_4S_WCFT_sci_CflNoFric') " & " %4.2f (`ab_4H_WCFT_sci_Fwd') " & " %4.2f (`ab_4H_WCFT_sci_Cfl') " & " %4.2f (`ab_4H_WCFT_sci_CflNoFric') " & " %4.2f (`ab_2_WCFT_sci_Fwd') " & " %4.2f (`ab_2_WCFT_sci_Cfl') " & " %4.2f (`ab_2_WCFT_sci_CflNoFric') "\\ "_n
file write tg "&&& Non-Science & " %4.2f (`ab_WC_WCFT_hum_Fwd') " & " %4.2f (`ab_WC_WCFT_hum_Cfl') " & " %4.2f (`ab_WC_WCFT_hum_CflNoFric') " & " %4.2f (`ab_BC_WCFT_hum_Fwd') " & " %4.2f (`ab_BC_WCFT_hum_Cfl') " & " %4.2f (`ab_BC_WCFT_hum_CflNoFric')  " & " %4.2f (`ab_4S_WCFT_hum_Fwd') " & " %4.2f (`ab_4S_WCFT_hum_Cfl') " & " %4.2f (`ab_4S_WCFT_hum_CflNoFric') " & " %4.2f (`ab_4H_WCFT_hum_Fwd') " & " %4.2f (`ab_4H_WCFT_hum_Cfl') " & " %4.2f (`ab_4H_WCFT_hum_CflNoFric') " & " %4.2f (`ab_2_WCFT_hum_Fwd') " & " %4.2f (`ab_2_WCFT_hum_Cfl') " & " %4.2f (`ab_2_WCFT_hum_CflNoFric') "\\ "_n 
file write tg "&&& Non-graduate & " %4.2f (`ab_WC_WCFT_ng_Fwd') " & " %4.2f (`ab_WC_WCFT_ng_Cfl') " & " %4.2f (`ab_WC_WCFT_ng_CflNoFric') " & " %4.2f (`ab_BC_WCFT_ng_Fwd') " & " %4.2f (`ab_BC_WCFT_ng_Cfl') " & " %4.2f (`ab_BC_WCFT_ng_CflNoFric')  " & " %4.2f (`ab_4S_WCFT_ng_Fwd') " & " %4.2f (`ab_4S_WCFT_ng_Cfl') " & " %4.2f (`ab_4S_WCFT_ng_CflNoFric') " & " %4.2f (`ab_4H_WCFT_ng_Fwd') " & " %4.2f (`ab_4H_WCFT_ng_Cfl') " & " %4.2f (`ab_4H_WCFT_ng_CflNoFric') " & " %4.2f (`ab_2_WCFT_ng_Fwd') " & " %4.2f (`ab_2_WCFT_ng_Cfl') " & " %4.2f (`ab_2_WCFT_ng_CflNoFric') "\\ "_n  
file write tg "\cmidrule{2-19} "_n
file write tg "& \multirow{3}{*}{\rotatebox[origin=c]{90}{Blue}} & \multirow{3}{*}{\rotatebox[origin=c]{90}{Collar}} &  Science & " %4.2f (`ab_WC_BCFT_sci_Fwd') " & " %4.2f (`ab_WC_BCFT_sci_Cfl') " & " %4.2f (`ab_WC_BCFT_sci_CflNoFric') " & " %4.2f (`ab_BC_BCFT_sci_Fwd') " & " %4.2f (`ab_BC_BCFT_sci_Cfl') " & " %4.2f (`ab_BC_BCFT_sci_CflNoFric')  " & " %4.2f (`ab_4S_BCFT_sci_Fwd') " & " %4.2f (`ab_4S_BCFT_sci_Cfl') " & " %4.2f (`ab_4S_BCFT_sci_CflNoFric') " & " %4.2f (`ab_4H_BCFT_sci_Fwd') " & " %4.2f (`ab_4H_BCFT_sci_Cfl') " & " %4.2f (`ab_4H_BCFT_sci_CflNoFric') " & " %4.2f (`ab_2_BCFT_sci_Fwd') " & " %4.2f (`ab_2_BCFT_sci_Cfl') " & " %4.2f (`ab_2_BCFT_sci_CflNoFric') "\\ "_n 
file write tg "&&& Non-Science & " %4.2f (`ab_WC_BCFT_hum_Fwd') " & " %4.2f (`ab_WC_BCFT_hum_Cfl') " & " %4.2f (`ab_WC_BCFT_hum_CflNoFric') " & " %4.2f (`ab_BC_BCFT_hum_Fwd') " & " %4.2f (`ab_BC_BCFT_hum_Cfl') " & " %4.2f (`ab_BC_BCFT_hum_CflNoFric')  " & " %4.2f (`ab_4S_BCFT_hum_Fwd') " & " %4.2f (`ab_4S_BCFT_hum_Cfl') " & " %4.2f (`ab_4S_BCFT_hum_CflNoFric') " & " %4.2f (`ab_4H_BCFT_hum_Fwd') " & " %4.2f (`ab_4H_BCFT_hum_Cfl') " & " %4.2f (`ab_4H_BCFT_hum_CflNoFric') " & " %4.2f (`ab_2_BCFT_hum_Fwd') " & " %4.2f (`ab_2_BCFT_hum_Cfl') " & " %4.2f (`ab_2_BCFT_hum_CflNoFric') "\\ "_n  
file write tg "&&& Non-graduate & " %4.2f (`ab_WC_BCFT_ng_Fwd') " & " %4.2f (`ab_WC_BCFT_ng_Cfl') " & " %4.2f (`ab_WC_BCFT_ng_CflNoFric') " & " %4.2f (`ab_BC_BCFT_ng_Fwd') " & " %4.2f (`ab_BC_BCFT_ng_Cfl') " & " %4.2f (`ab_BC_BCFT_ng_CflNoFric')  " & " %4.2f (`ab_4S_BCFT_ng_Fwd') " & " %4.2f (`ab_4S_BCFT_ng_Cfl') " & " %4.2f (`ab_4S_BCFT_ng_CflNoFric') " & " %4.2f (`ab_4H_BCFT_ng_Fwd') " & " %4.2f (`ab_4H_BCFT_ng_Cfl') " & " %4.2f (`ab_4H_BCFT_ng_CflNoFric') " & " %4.2f (`ab_2_BCFT_ng_Fwd') " & " %4.2f (`ab_2_BCFT_ng_Cfl') " & " %4.2f (`ab_2_BCFT_ng_CflNoFric') "\\ "_n   
file write tg "\midrule "_n
file write tg "\multirow{6}{*}{\rotatebox[origin=c]{90}{Part-time}} & \multirow{3}{*}{\rotatebox[origin=c]{90}{White}} & \multirow{3}{*}{\rotatebox[origin=c]{90}{Collar}} &  Science & " %4.2f (`ab_WC_WCPT_sci_Fwd') " & " %4.2f (`ab_WC_WCPT_sci_Cfl') " & " %4.2f (`ab_WC_WCPT_sci_CflNoFric') " & " %4.2f (`ab_BC_WCPT_sci_Fwd') " & " %4.2f (`ab_BC_WCPT_sci_Cfl') " & " %4.2f (`ab_BC_WCPT_sci_CflNoFric')  " & " %4.2f (`ab_4S_WCPT_sci_Fwd') " & " %4.2f (`ab_4S_WCPT_sci_Cfl') " & " %4.2f (`ab_4S_WCPT_sci_CflNoFric') " & " %4.2f (`ab_4H_WCPT_sci_Fwd') " & " %4.2f (`ab_4H_WCPT_sci_Cfl') " & " %4.2f (`ab_4H_WCPT_sci_CflNoFric') " & " %4.2f (`ab_2_WCPT_sci_Fwd') " & " %4.2f (`ab_2_WCPT_sci_Cfl') " & " %4.2f (`ab_2_WCPT_sci_CflNoFric') "\\ "_n 
file write tg "&&& Non-Science & " %4.2f (`ab_WC_WCPT_hum_Fwd') " & " %4.2f (`ab_WC_WCPT_hum_Cfl') " & " %4.2f (`ab_WC_WCPT_hum_CflNoFric') " & " %4.2f (`ab_BC_WCPT_hum_Fwd') " & " %4.2f (`ab_BC_WCPT_hum_Cfl') " & " %4.2f (`ab_BC_WCPT_hum_CflNoFric')  " & " %4.2f (`ab_4S_WCPT_hum_Fwd') " & " %4.2f (`ab_4S_WCPT_hum_Cfl') " & " %4.2f (`ab_4S_WCPT_hum_CflNoFric') " & " %4.2f (`ab_4H_WCPT_hum_Fwd') " & " %4.2f (`ab_4H_WCPT_hum_Cfl') " & " %4.2f (`ab_4H_WCPT_hum_CflNoFric') " & " %4.2f (`ab_2_WCPT_hum_Fwd') " & " %4.2f (`ab_2_WCPT_hum_Cfl') " & " %4.2f (`ab_2_WCPT_hum_CflNoFric') "\\ "_n  
file write tg "&&& Non-graduate & " %4.2f (`ab_WC_WCPT_ng_Fwd') " & " %4.2f (`ab_WC_WCPT_ng_Cfl') " & " %4.2f (`ab_WC_WCPT_ng_CflNoFric') " & " %4.2f (`ab_BC_WCPT_ng_Fwd') " & " %4.2f (`ab_BC_WCPT_ng_Cfl') " & " %4.2f (`ab_BC_WCPT_ng_CflNoFric')  " & " %4.2f (`ab_4S_WCPT_ng_Fwd') " & " %4.2f (`ab_4S_WCPT_ng_Cfl') " & " %4.2f (`ab_4S_WCPT_ng_CflNoFric') " & " %4.2f (`ab_4H_WCPT_ng_Fwd') " & " %4.2f (`ab_4H_WCPT_ng_Cfl') " & " %4.2f (`ab_4H_WCPT_ng_CflNoFric') " & " %4.2f (`ab_2_WCPT_ng_Fwd') " & " %4.2f (`ab_2_WCPT_ng_Cfl') " & " %4.2f (`ab_2_WCPT_ng_CflNoFric') "\\ "_n    
file write tg "\cmidrule{2-19} "_n
file write tg "& \multirow{3}{*}{\rotatebox[origin=c]{90}{Blue}} & \multirow{3}{*}{\rotatebox[origin=c]{90}{Collar}} &  Science & " %4.2f (`ab_WC_BCPT_sci_Fwd') " & " %4.2f (`ab_WC_BCPT_sci_Cfl') " & " %4.2f (`ab_WC_BCPT_sci_CflNoFric') " & " %4.2f (`ab_BC_BCPT_sci_Fwd') " & " %4.2f (`ab_BC_BCPT_sci_Cfl') " & " %4.2f (`ab_BC_BCPT_sci_CflNoFric')  " & " %4.2f (`ab_4S_BCPT_sci_Fwd') " & " %4.2f (`ab_4S_BCPT_sci_Cfl') " & " %4.2f (`ab_4S_BCPT_sci_CflNoFric') " & " %4.2f (`ab_4H_BCPT_sci_Fwd') " & " %4.2f (`ab_4H_BCPT_sci_Cfl') " & " %4.2f (`ab_4H_BCPT_sci_CflNoFric') " & " %4.2f (`ab_2_BCPT_sci_Fwd') " & " %4.2f (`ab_2_BCPT_sci_Cfl') " & " %4.2f (`ab_2_BCPT_sci_CflNoFric') "\\ "_n 
file write tg "&&& Non-Science & " %4.2f (`ab_WC_BCPT_hum_Fwd') " & " %4.2f (`ab_WC_BCPT_hum_Cfl') " & " %4.2f (`ab_WC_BCPT_hum_CflNoFric') " & " %4.2f (`ab_BC_BCPT_hum_Fwd') " & " %4.2f (`ab_BC_BCPT_hum_Cfl') " & " %4.2f (`ab_BC_BCPT_hum_CflNoFric')  " & " %4.2f (`ab_4S_BCPT_hum_Fwd') " & " %4.2f (`ab_4S_BCPT_hum_Cfl') " & " %4.2f (`ab_4S_BCPT_hum_CflNoFric') " & " %4.2f (`ab_4H_BCPT_hum_Fwd') " & " %4.2f (`ab_4H_BCPT_hum_Cfl') " & " %4.2f (`ab_4H_BCPT_hum_CflNoFric') " & " %4.2f (`ab_2_BCPT_hum_Fwd') " & " %4.2f (`ab_2_BCPT_hum_Cfl') " & " %4.2f (`ab_2_BCPT_hum_CflNoFric') "\\ "_n  
file write tg "&&& Non-graduate & " %4.2f (`ab_WC_BCPT_ng_Fwd') " & " %4.2f (`ab_WC_BCPT_ng_Cfl') " & " %4.2f (`ab_WC_BCPT_ng_CflNoFric') " & " %4.2f (`ab_BC_BCPT_ng_Fwd') " & " %4.2f (`ab_BC_BCPT_ng_Cfl') " & " %4.2f (`ab_BC_BCPT_ng_CflNoFric')  " & " %4.2f (`ab_4S_BCPT_ng_Fwd') " & " %4.2f (`ab_4S_BCPT_ng_Cfl') " & " %4.2f (`ab_4S_BCPT_ng_CflNoFric') " & " %4.2f (`ab_4H_BCPT_ng_Fwd') " & " %4.2f (`ab_4H_BCPT_ng_Cfl') " & " %4.2f (`ab_4H_BCPT_ng_CflNoFric') " & " %4.2f (`ab_2_BCPT_ng_Fwd') " & " %4.2f (`ab_2_BCPT_ng_Cfl') " & " %4.2f (`ab_2_BCPT_ng_CflNoFric') "\\ "_n     
file write tg "\midrule "_n
file write tg "\multirow{3}{*}{\rotatebox[origin=c]{90}{Home}} & \multirow{3}{*}{\rotatebox[origin=c]{90}{}} & \multirow{3}{*}{\rotatebox[origin=c]{90}{}} &  Science & " %4.2f (`ab_WC_NO_sci_Fwd') " & " %4.2f (`ab_WC_NO_sci_Cfl') " & " %4.2f (`ab_WC_NO_sci_CflNoFric') " & " %4.2f (`ab_BC_NO_sci_Fwd') " & " %4.2f (`ab_BC_NO_sci_Cfl') " & " %4.2f (`ab_BC_NO_sci_CflNoFric')  " & " %4.2f (`ab_4S_NO_sci_Fwd') " & " %4.2f (`ab_4S_NO_sci_Cfl') " & " %4.2f (`ab_4S_NO_sci_CflNoFric') " & " %4.2f (`ab_4H_NO_sci_Fwd') " & " %4.2f (`ab_4H_NO_sci_Cfl') " & " %4.2f (`ab_4H_NO_sci_CflNoFric') " & " %4.2f (`ab_2_NO_sci_Fwd') " & " %4.2f (`ab_2_NO_sci_Cfl') " & " %4.2f (`ab_2_NO_sci_CflNoFric') "\\ "_n 
file write tg "&&& Non-Science & " %4.2f (`ab_WC_NO_hum_Fwd') " & " %4.2f (`ab_WC_NO_hum_Cfl') " & " %4.2f (`ab_WC_NO_hum_CflNoFric') " & " %4.2f (`ab_BC_NO_hum_Fwd') " & " %4.2f (`ab_BC_NO_hum_Cfl') " & " %4.2f (`ab_BC_NO_hum_CflNoFric')  " & " %4.2f (`ab_4S_NO_hum_Fwd') " & " %4.2f (`ab_4S_NO_hum_Cfl') " & " %4.2f (`ab_4S_NO_hum_CflNoFric') " & " %4.2f (`ab_4H_NO_hum_Fwd') " & " %4.2f (`ab_4H_NO_hum_Cfl') " & " %4.2f (`ab_4H_NO_hum_CflNoFric') " & " %4.2f (`ab_2_NO_hum_Fwd') " & " %4.2f (`ab_2_NO_hum_Cfl') " & " %4.2f (`ab_2_NO_hum_CflNoFric') "\\ "_n  
file write tg "&&& Non-graduate & " %4.2f (`ab_WC_NO_ng_Fwd') " & " %4.2f (`ab_WC_NO_ng_Cfl') " & " %4.2f (`ab_WC_NO_ng_CflNoFric') " & " %4.2f (`ab_BC_NO_ng_Fwd') " & " %4.2f (`ab_BC_NO_ng_Cfl') " & " %4.2f (`ab_BC_NO_ng_CflNoFric')  " & " %4.2f (`ab_4S_NO_ng_Fwd') " & " %4.2f (`ab_4S_NO_ng_Cfl') " & " %4.2f (`ab_4S_NO_ng_CflNoFric') " & " %4.2f (`ab_4H_NO_ng_Fwd') " & " %4.2f (`ab_4H_NO_ng_Cfl') " & " %4.2f (`ab_4H_NO_ng_CflNoFric') " & " %4.2f (`ab_2_NO_ng_Fwd') " & " %4.2f (`ab_2_NO_ng_Cfl') " & " %4.2f (`ab_2_NO_ng_CflNoFric') "\\ "_n      
file write tg "\bottomrule "_n
file write tg "\end{tabular} "_n
file write tg "\footnotesize Notes: " "`" "`" "Cfl'' refers to the counterfactual while " "`" "`" "N.F. Cfl'' refers to the counterfactual with no search frictions. "_n
file write tg "\end{threeparttable} "_n
file write tg "} "_n
file write tg "\end{table} "_n
file write tg "\end{landscape} "_n
file close tg

log close
 
