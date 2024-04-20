* Create age, foreignBorn, race, sex, female, afqt, high school grades, family income, parental co-residence status, missed interview, etc.

*---------------------------
* Create sex dummies
*---------------------------
capture noisily drop male female
gen male   = (sex==1)
gen female = (sex==2)


*---------------------------
* Generate race dummies
*---------------------------
renam race_ethnicity race
gener white    = (race==4)
gener black    = (race==1)
gener hispanic = (race==2)
gener mixed    = (race==3)
label val race vl_race


*---------------------------
* Recode parental education variables
*---------------------------
recode  Bio_father_highest_educ (95 = .)
recode  Bio_mother_highest_educ (95 = .)
rename  Bio_mother_highest_educ Meduc
generat m_Meduc = mi(Meduc)
replace Meduc = 0 if mi(Meduc)
rename  Bio_father_highest_educ Feduc
generat m_Feduc = mi(Feduc)
replace Feduc = 0 if mi(Feduc)
* create dummy for if at least 1 parent attended college
generat Peduc = max(Meduc,Feduc)
generat m_Peduc = (Peduc==0)
generat Parent_college = inrange(Peduc,16,.)


*---------------------------
* Recode lagged income variable
*---------------------------
recode IncomePvs (.v = 0)


*---------------------------
* Fix Born_abroad variable, etc.
*---------------------------
bys ID: egen born_here = mean(Born_in_US)
replace born_here=1 if born_here>0 & born_here<1
generat foreignBorn = 1-born_here
drop    born_here


*---------------------------
* Fix AFQT (from Altonji et al.)
*---------------------------
foreach var in afqt asvabMath asvabMathNotNO asvabVerb asvabAR asvabCS asvabMK asvabNO asvabPC asvabWK {
    local varnew = upper("`var'")
    generat m_`var'   = mi(`var'_std)
    replace `var'_std = 0 if mi(`var'_std)
    zscore  `var'_std if year==1997 & ~m_`var'
    rename  `var'_std `var'_Altonji
    bys ID (year): egen `varnew' = mean(z_`var'_std)
    drop z_`var'_std
}

ren ASVABMATH      ASVABmath
ren ASVABMATHNOTNO ASVABmathNotNO
ren ASVABVERB      ASVABverb
ren ASVABAR        asvabAR
ren ASVABCS        asvabCS
ren ASVABMK        asvabMK
ren ASVABNO        asvabNO
ren ASVABPC        asvabPC
ren ASVABWK        asvabWK


*---------------------------
* Create SAT, ACT scores
*---------------------------
drop surveyACT
foreach var in english math science reading {
    bys ID (year): egen surveyACT`var'Max = max(surveyACT`var')
    drop surveyACT`var'
}
gen surveyACTmath = round((surveyACTmath+surveyACTscience)/2)
gen surveyACTverb = round((surveyACTreading+surveyACTenglish)/2)
recode surveySATmath surveySATverb (1 = 250) (2 = 350) (3 = 450) (4 = 550) (5 = 650) (6 = 750) 
recode surveyACTmath surveyACTverb (1 = 3)  (2 = 9.5) (3 = 15.5) (4 = 21.5) (5 = 27.5) (6 = 33.5)

* Use information from transcripts
generat SATmath = transcriptSATmath
generat SATverb = transcriptSATmath
generat ACTmath = transcriptACTmath
generat ACTverb = (transcriptACTread+transcriptACTengl)/2

* Use information from survey if missing transcript information
replace SATmath = surveySATmath if mi(SATmath) & !mi(surveySATmath)
replace SATverb = surveySATverb if mi(SATverb) & !mi(surveySATverb)
replace ACTmath = surveyACTmath if mi(ACTmath) & !mi(surveyACTmath)
replace ACTverb = surveyACTverb if mi(ACTverb) & !mi(surveyACTverb)

* Crosswalk ACT scores into SAT scores for those who only took ACT
* Taken from http://catalog.usu.edu/content.php?catoid=12&navoid=7347
foreach var in ACTmath ACTverb {
    replace `var' = 800 if `var'==36
    replace `var' = 790 if `var'==35
    replace `var' = 780 if `var'==34
    replace `var' = 760 if `var'==33
    replace `var' = 730 if `var'==32
    replace `var' = 700 if `var'==31
    replace `var' = 680 if `var'==30
    replace `var' = 660 if `var'==29
    replace `var' = 640 if `var'==28
    replace `var' = 620 if `var'==27
    replace `var' = 600 if `var'==26
    replace `var' = 580 if `var'==25
    replace `var' = 560 if `var'==24
    replace `var' = 540 if `var'==23
    replace `var' = 520 if `var'==22
    replace `var' = 500 if `var'==21
    replace `var' = 480 if `var'==20
    replace `var' = 460 if `var'==19
    replace `var' = 440 if `var'==18
    replace `var' = 410 if `var'==17
    replace `var' = 390 if `var'==16
    replace `var' = 360 if `var'==15
    replace `var' = 330 if `var'==14
    replace `var' = 300 if `var'==13
    replace `var' = 280 if `var'==12
    replace `var' = 260 if `var'==11
    replace `var' = 200 if inrange(`var',0.01,10.99)
}

replace SATmath = ACTmath if ACTmath>SATmath & !mi(ACTmath)
replace SATverb = ACTverb if ACTverb>SATverb & !mi(ACTverb)

replace SATmath = ACTmath if mi(SATmath) & !mi(ACTmath)
replace SATverb = ACTverb if mi(SATverb) & !mi(ACTverb)

drop ACTmath ACTverb transcriptACT* transcriptSAT* surveyACT???? surveyACT??? surveySAT????

* Z-score the resulting variables
zscore  SATmath if year==1997 & ~mi(SATmath)
rename  SATmath SATmath_unscaled
replace SATmath_unscaled = 200 if SATmath_unscaled < 200
bys ID (year): egen SATmath = mean(z_SATmath)
drop z_SATmath
zscore  SATverb if year==1997 & ~mi(SATverb)
rename  SATverb SATverb_unscaled
replace SATverb_unscaled = 200 if SATverb_unscaled < 200
bys ID (year): egen SATverb = mean(z_SATverb)
drop z_SATverb

mdesc SATmath SATverb if year==1997


*---------------------------
* Create High School Grades
*---------------------------
* Use information from transcripts
generat Grades_HS_best = transcriptGPAoverall/100
sum transcriptGPAoverall, d
sum Grades_HS_best, d

* Create continuous survey measure as midpoints of discrete survey measures
recode Grades_HS Grades_8th_grade (1 = 0.5) (2 = 1.0) (3 = 1.5) (4 = 2.0) (5 = 2.5) (6 = 3.0) (7 = 3.5) (8 = 4.0) (9 12 13 999 = .) (10 = 3.0) (11 = 2.0) 
sum Grades_HS Grades_8th_grade, d
* Take max over time within individual
bys ID: egen Grades_8th_grade_max = max(Grades_8th_grade)
bys ID: egen Grades_HS_max        = max(Grades_HS)
sum Grades_HS_max Grades_8th_grade_max, d

* Supplement transcripts with survey data if missing transcript data
replace Grades_HS_best = Grades_HS_max        if mi(Grades_HS_best)
//replace Grades_HS_best = Grades_8th_grade_max if mi(Grades_HS_best)
replace Grades_HS_best = 4                    if inrange(Grades_HS_best,4,.)

* Treatment of missings
mdesc Grades_HS_best if year==1997
count if mi(Grades_HS_best) & year==1997
generat m_Grades_HS_best = mi(Grades_HS_best)
replace Grades_HS_best   = 0 if m_Grades_HS_best
* Z-score the resulting variable
zscore  Grades_HS_best if year==1997 & ~m_Grades_HS_best
rename  Grades_HS_best Grades_HS_best_unscaled
bys ID (year): egen Grades_HS_best = mean(z_Grades_HS_best)
drop z_Grades_HS_best


*---------------------------
* Create AP exams
*---------------------------
* transcripts
recode  transcriptNumOthAPscoreEq1 transcriptNumOthAPscoreEq2 transcriptNumOthAPscoreEq3 transcriptNumOthAPscoreEq4 transcriptNumOthAPscoreEq5 (. .v = 0)
generat transcriptNumAPs = !mi(transcriptAPbio) + !mi(transcriptAPcalc) + !mi(transcriptAPchem) + !mi(transcriptAPeng) + !mi(transcriptAPhistEU) + !mi(transcriptAPgovt) + !mi(transcriptAPphysics) + !mi(transcriptAPpsych) + !mi(transcriptAPspanish) + !mi(transcriptAPhistUS) + transcriptNumOthAPscoreEq1 + transcriptNumOthAPscoreEq2 + transcriptNumOthAPscoreEq3 + transcriptNumOthAPscoreEq4 + transcriptNumOthAPscoreEq5
replace transcriptNumAPs = .v if inlist(transcriptHasProblem,1,.v)

* survey
foreach subj in art bio chem compSci econ eng french german gov history latin math music physics psychology spanish {
    replace tookAP`subj' = 1 if DLItookAP`subj'==1
    bys ID (year): egen everTookAP`subj' = max(tookAP`subj')
    recode everTookAP`subj' (. = 0)
}
egen surveyNumAPs = rowtotal(everTookAP*), mi

generat numAPs = transcriptNumAPs
replace numAPs = surveyNumAPs if mi(transcriptNumAPs)


/*
Cognitive measures:
1. ASVAB subject tests
2. HS GPA
3. SAT math, verbal

Schooling abilities/preferences
1. Num APs
2. "I was late for school without an excuse", 
3. "When I was in school, I used to break rules quite regularly", 
4. "In that week, on how many weekdays did you spend time taking extra classes or lessons?", 
4. "On those weekdays, about how much time did you spend per day taking extra classes or lessons?", 
5. "Since [this youth] started the ninth grade, has [he/she] ever taken any academic classes during a school break, including summers?" 
6. "What was the main reason [he/she] attended classes during a school break that year?"

Work abilities/preferences
1. "I have high standards and work toward them"
2. "I make every effort to do more than what is expected of me"
3. "What is the percent chance that [this youth] will be working for pay more than 20 hours per week when [he/she] turns 30?"
*/

*---------------------------
* "I was late for school without an excuse"
*---------------------------
sum lateForSchoolNoExcuse if year==1997

*---------------------------
* "When I was in school, I used to break rules quite regularly"
*---------------------------
egen breakRulesRegularly = rowfirst(breakRulesRegularly2008 breakRulesRegularly2010)

*---------------------------
* "How many hours per week did you spend time taking extra classes or lessons?"
*---------------------------
gen HrsExtraClass = R1WeekdaysExtraClass*(R1hoursWeekdayExtraClass+R1minsWeekdayExtraClass/60) + (R1hoursWeekendExtraClass+R1minsWeekendExtraClass/60)

sum HrsExtraClass if R1ExtraClass==0
sum HrsExtraClass if R1ExtraClass>=.

*---------------------------
* "Since [this youth] started the ninth grade, has [he/she] ever taken any academic classes during a school break, including summers?"
*---------------------------
sum tookClassDuringBreak if year==1997

*---------------------------
* "What was the main reason [he/she] attended classes during a school break that year?"
*---------------------------
gen reasonTookClassDuringBreak = reasonTookClassDuringBreak1 // N=543 for this one, which matches up with "tookClassDuringBreak" variable
tab reasonTookClassDuringBreak if tookClassDuringBreak==1, mi

*---------------------------
* "I have high standards and work toward them"
*---------------------------
egen highStandardsWork = rowfirst(highStandardsWork2008 highStandardsWork2010)

*---------------------------
* "I make every effort to do more than what is expected of me"
*---------------------------
egen doMoreThanExpected = rowfirst(doMoreThanExpected2008 doMoreThanExpected2010)

*---------------------------
* "What is the percent chance that [this youth] will be working for pay more than 20 hours per week when [he/she] turns 30?"
*---------------------------
sum pctChanceWork20Hrs30 parPctChanceWork20Hrs30 if year==1997

*---------------------------
* "What is the percent chance that [this youth] will have a four-year college degree by the time [he/she] turns 30?"
*---------------------------
egen pctChanceBAby30 = rowfirst(pctChanceBAby30_1997 pctChanceBAby30_2001)
sum pctChanceBAby30 parPctChanceBAby30 if year==1997

*---------------------------
* Fix relationship to Head of Household
*---------------------------
generat      true_rel_HH_headA = Relationship_HH_head if year==1997
replace      true_rel_HH_headA = min(Relationship_to_Par_age12_, Relationship_HH_head) if (mi(Relationship_HH_head) | mi(Relationship_to_Par_age12_)) & year==1997 & Relationship_HH_head~=Relationship_to_Par_age12_
bys ID: egen true_rel_HH_head  = mean(true_rel_HH_headA)
drop         true_rel_HH_headA
label   val  true_rel_HH_head vl_relPar


*---------------------------
* Get whether or not person lives with mom in 1997
*---------------------------
gen liveWithMom14 = inlist(true_rel_HH_head,1,2,4)


*---------------------------
* Get whether or not person lives in female-headed household in 1997
*---------------------------
gen femaleHeadHH1997 = true_rel_HH_head==4

*---------------------------
* Get Household size in 1997
*---------------------------
rename  HH_size HHsize1997


*---------------------------
* Parental transfers
*---------------------------
* 1997 - 2003 variables
replace estParGave = 500/2*(estParGave==1)+1500/2*(estParGave==2)+3500/2*(estParGave==3)+7500/2*(estParGave==4)+12500/2*(estParGave==5)+17500/2*(estParGave==6)+ 22500/2*(estParGave==7) if !mi(estParGave)
replace estMomGave = 500/2*(estMomGave==1)+1500/2*(estMomGave==2)+3500/2*(estMomGave==3)+7500/2*(estMomGave==4)+12500/2*(estMomGave==5)+17500/2*(estMomGave==6)+ 22500/2*(estMomGave==7) if !mi(estMomGave)
replace estDadGave = 500/2*(estDadGave==1)+1500/2*(estDadGave==2)+3500/2*(estDadGave==3)+7500/2*(estDadGave==4)+12500/2*(estDadGave==5)+17500/2*(estDadGave==6)+ 22500/2*(estDadGave==7) if !mi(estDadGave)

replace totParGave = estParGave if mi(totParGave) & !mi(estParGave)
replace totMomGave = estMomGave if mi(totMomGave) & !mi(estMomGave)
replace totDadGave = estDadGave if mi(totDadGave) & !mi(estDadGave)

* generat totParTransfer = totParGave if inrange(year,1997,2003)
* replace totParTransfer = totMomGave*(!mi(totMomGave)) + totDadGave*(!mi(totDadGave)) if (mi(totParGave) | (totParGave < totMomGave*(!mi(totMomGave)) + totDadGave*(!mi(totDadGave)))) & (!mi(totMomGave) | !mi(totDadGave)) & inrange(year,1997,2003)
* replace totParTransfer = totParTransfer + allowance if !mi(allowance) & inrange(year,1997,2003)

egen    totParTransfer = rowtotal(totParGave totMomGave totDadGave allowance) if inrange(year,1997,2003), mi
replace totParTransfer = .n if mi(totParTransfer) & Int_month==.n

* 2004 - 2010 variables
replace estFamTrans = 500/2*(estFamTrans==1)+1500/2*(estFamTrans==2)+3500/2*(estFamTrans==3)+7500/2*(estFamTrans==4)+12500/2*(estFamTrans==5)+17500/2*(estFamTrans==6)+ 22500/2*(estFamTrans==7) if !mi(estFamTrans)
recode  estFamTrans (.v = 0) // valid skips correspond to "R or S/P did not receive money as gifts from family/friends"

replace totParTransfer = estFamTrans if inrange(year,2004,2010)

* Heckman & Hai assume parental transfers are 0 after age 30 (i.e. year 2010 in data)
replace totParTransfer = 0 if inrange(year,2011,2015)

* Deflate by CPI
replace totParTransfer = totParTransfer/cpi if !mi(totParTransfer)
rename  totParTransfer incParTransfer
replace incParTransfer = 0 if inlist(incParTransfer,.,.d,.r)

*---------------------------
* Get parental co-residence over time
*---------------------------
generat      livesWithParents = 0
foreach var in HH1rel HH2rel HH3rel HH4rel HH5rel HH6rel HH7rel HH8rel HH9rel HH10rel HH11rel HH12rel HH13rel HH14rel HH15rel HH16rel HH17rel HH18rel {
    replace livesWithParents = 1 if inrange(`var',3,10)
}
replace livesWithParents = .n if HH1rel==.n
replace livesWithParents = .v if HH1rel==.v
replace livesWithParents = .d if HH1rel==.d
replace livesWithParents = .r if HH1rel==.r
replace livesWithParents = .i if HH1rel==.i
replace livesWithParents = 1  if year<=1997 // by construction
replace livesWithParents = 0  if inlist(livesWithParents,.r,.d,.i,.v) & year>=1998 // valid skip here means they live alone

*---------------------------
* Implied rent transfer a la Johnson (2013)
*---------------------------
generat rentParTransfer = 0
replace rentParTransfer = 650*12 if livesWithParents==1 // $650/mo in implied rent
replace rentParTransfer = .n if HH1rel==.n

*---------------------------
* Get spousal/partner co-residence over time
*---------------------------
generat     livesWithSpouse = 0
foreach var in HH1rel HH2rel HH3rel HH4rel HH5rel HH6rel HH7rel HH8rel HH9rel HH10rel HH11rel HH12rel HH13rel HH14rel HH15rel HH16rel HH17rel HH18rel {
    replace livesWithSpouse = 1 if inlist(`var',1,2,69)
}
replace livesWithSpouse = .n if HH1rel==.n
replace livesWithSpouse = .v if HH1rel==.v
replace livesWithSpouse = .d if HH1rel==.d
replace livesWithSpouse = .r if HH1rel==.r
replace livesWithSpouse = .i if HH1rel==.i
replace livesWithSpouse = 0  if year<=1997 // by construction
replace livesWithSpouse = 0  if inlist(livesWithSpouse,.r,.d,.i,.v) & year>=1998 // valid skip here means they live alone

*---------------------------
* Time use in high school (youngest 3 cohorts)
*---------------------------
* Homework
generat didHomeworkInHS = R1Homework==1 if !mi(R1Homework)
replace didHomeworkInHS = R1Homework    if  mi(R1Homework)

generat HrsWeekHomeworkInHS = R1Homework if  mi(R1Homework)
replace HrsWeekHomeworkInHS = 0          if R1Homework==0
replace HrsWeekHomeworkInHS = R1WeekdaysHomework*(R1hoursWeekdayHomework+R1minsWeekdayHomework/60) + R1hoursWeekendHomework+R1minsWeekendHomework/60 if R1Homework==1 & !mi(R1WeekdaysHomework) & !mi(R1hoursWeekdayHomework) & !mi(R1minsWeekdayHomework) & !mi(R1hoursWeekendHomework) & !mi(R1minsWeekendHomework)
replace HrsWeekHomeworkInHS = 30 if inrange(HrsWeekHomeworkInHS,30,.)

* TV viewing
generat didWatchTVInHS = R1WatchTV==1 if !mi(R1WatchTV)
replace didWatchTVInHS = R1WatchTV    if  mi(R1WatchTV)

generat HrsWeekWatchTVInHS = R1WatchTV if  mi(R1WatchTV)
replace HrsWeekWatchTVInHS = 0          if R1WatchTV==0
replace HrsWeekWatchTVInHS = R1WeekdaysWatchTV*(R1hoursWeekdayWatchTV+R1minsWeekdayWatchTV/60) + R1hoursWeekendWatchTV+R1minsWeekendWatchTV/60 if R1WatchTV==1 & !mi(R1WeekdaysWatchTV) & !mi(R1hoursWeekdayWatchTV) & !mi(R1minsWeekdayWatchTV) & !mi(R1hoursWeekendWatchTV) & !mi(R1minsWeekendWatchTV)
replace HrsWeekWatchTVInHS = 80 if inrange(HrsWeekWatchTVInHS,80,.)

*---------------------------
* Time use in adulthood (all respondents)
*---------------------------
* Computer use
replace HrsWeekUseComputer = 0*(HrsWeekUseComputer==1) + (1/2)*(HrsWeekUseComputer==2) + (4/2)*(HrsWeekUseComputer==3) + (10/2)*(HrsWeekUseComputer==4) + (16/2)*(HrsWeekUseComputer==5) + (25/2)*(HrsWeekUseComputer==6) if !mi(HrsWeekUseComputer)

* TV
replace HrsWeekWatchTV = (2/2)*(HrsWeekWatchTV==1) + (13/2)*(HrsWeekWatchTV==2) + (31/2)*(HrsWeekWatchTV==3) + (51/2)*(HrsWeekWatchTV==4) + (71/2)*(HrsWeekWatchTV==5) + (95/2)*(HrsWeekWatchTV==6) if !mi(HrsWeekWatchTV)

* Sleep
replace HrsNightSleep = 13 if inrange(HrsNightSleep,13,.)
replace HrsNightSleep = 1  if inrange(HrsNightSleep,0 ,1)

*---------------------------
* Fix Weights Variable
*---------------------------
replace weight_panel = . if year~=1997
bys ID: egen weight  = mean(weight_panel)
drop weight_panel

*---------------------------
* Generate birth year dummies
*---------------------------
capture noisily drop age_now
generat born_1980 = (birth_year==1980)
generat born_1981 = (birth_year==1981)
generat born_1982 = (birth_year==1982)
generat born_1983 = (birth_year==1983)
generat born_1984 = (birth_year==1984)

*---------------------------
* Generate age
*---------------------------
genera now_1997 = (1997-1960)*12
genera DOB = (birth_year-1960)*12+birth_month-1
format now_1997 %tm
format DOB %tm
genera age      = (now_1997-DOB)/12
genera age_now  = year-birth_year

*---------------------------
* Family Income
*---------------------------
* family income in survey round 1 is already imported from before
d Family_income

* Grab family income from parent supplement (for round 2, since it's missing at high rates in rounds 3-5)
egen    Family_income_alt = rowtotal(parIncome parSpIncome parSpOthIncome), mi
replace Family_income_alt = .n if Family_income==.n
replace Family_income_alt = .d if Family_income==.d
replace Family_income_alt = .i if Family_income==.i
replace Family_income_alt = .r if Family_income==.r
replace Family_income_alt = .v if Family_income==.v

* Family income in survey round 1
generat FincTest96 = Family_income if year==1996
replace FincTest96 = FincTest96/cpi 
bys ID: egen famIncTest96 = mean(FincTest96)

* Parent supplement reported income in survey round 2
generat FincAltTest97 = Family_income_alt if year==1997
replace FincAltTest97 = FincAltTest97/cpi 
bys ID: egen famIncAltTest97 = mean(FincAltTest97)

* Parent supplement reported income in survey round 3
generat FincAltTest98 = Family_income_alt if year==1998
replace FincAltTest98 = FincAltTest98/cpi 
bys ID: egen famIncAltTest98 = mean(FincAltTest98)

* Parent supplement reported income in survey round 4
generat FincAltTest99 = Family_income_alt if year==1999
replace FincAltTest99 = FincAltTest99/cpi 
bys ID: egen famIncAltTest99 = mean(FincAltTest99)

* Parent supplement reported income in survey round 4
generat FincAltTest00 = Family_income_alt if year==2000
replace FincAltTest00 = FincAltTest00/cpi 
bys ID: egen famIncAltTest00 = mean(FincAltTest00)

* Pre-college family income = survey round 1 income OR round 2 parent supplement reported income if missing round 1 data
generat famIncAsTeen = famIncTest96
replace famIncAsTeen = famIncAltTest97 if mi(famIncAsTeen)
replace famIncAsTeen = famIncAltTest98 if mi(famIncAsTeen)
replace famIncAsTeen = famIncAltTest99 if mi(famIncAsTeen)
replace famIncAsTeen = famIncAltTest00 if mi(famIncAsTeen)


*---------------------------------------------------------
* Adjust slightly the family income variable
*---------------------------------------------------------
* Express family income in 1000s of dollars
replace famIncAsTeen   = famIncAsTeen/1000

mdesc famIncAsTeen if year==1997
generat m_famIncAsTeen = mi(famIncAsTeen)
generat m_all_famIncs = mi(famIncTest96) & mi(famIncAltTest97) & mi(famIncAltTest98) & mi(famIncAltTest99) & mi(famIncAltTest00)
replace famIncAsTeen   = 1 if famIncAsTeen<=0
replace famIncAsTeen   = 0 if mi(famIncAsTeen)
drop FincTest96 famIncTest96 FincAltTest97 famIncAltTest97

*---------------------------
* survey rounds by year
*---------------------------
generat svyRound = .
replace svyRound =  1 if year==1997
replace svyRound =  2 if year==1998
replace svyRound =  3 if year==1999
replace svyRound =  4 if year==2000
replace svyRound =  5 if year==2001
replace svyRound =  6 if year==2002
replace svyRound =  7 if year==2003
replace svyRound =  8 if year==2004
replace svyRound =  9 if year==2005
replace svyRound = 10 if year==2006
replace svyRound = 11 if year==2007
replace svyRound = 12 if year==2008
replace svyRound = 13 if year==2009
replace svyRound = 14 if year==2010
replace svyRound = 15 if year==2011
replace svyRound = 16 if year==2012
replace svyRound = 16 if year==2013
replace svyRound = 16 if year==2014

*---------------------------
* missed interviews
*---------------------------
* variables that flag if the year is missing, how long the missing has 
*  gone on, how long the missing lasts, if it's the last missing spell
*  and if it's the first long missing spell (long = 3+ missed interviews)
generat Interview_date = Int_month+239 // add 239 to convert from NLSY base month (Dec 1979) to Stata base month (Jan 1960)
format  Interview_date %tm
replace Interview_date = .n if Int_month==.n

foreach x of numlist 1/17 {
    if (`x'<=15) {
        local temp=`x'+17
    }
    else if (`x'==16) {
        local temp=`x'+18
    }
    else if (`x'==17) {
        local temp=`x'+19
    }
    bys ID: gen R`x'interviewDate  = Interview_date[`temp']
    bys ID: gen R`x'interviewDay   = mdy(InterviewM[`temp'],1,InterviewY[`temp'])
    bys ID: gen R`x'interviewWeek  = wofd(mdy(InterviewM[`temp'],1,InterviewY[`temp']))
    format R`x'interviewDate %tm
    format R`x'interviewDay  %td
    format R`x'interviewWeek %tw
}
gen flag1 = yofd(dofm(R1interviewDate)) ==1998 // create flag for imputing schooling before first interview
gen flag2 = yofd(dofm(R17interviewDate))==2016 // create flag for dropping observations after last interview

gen Interview_day                           = mdy(InterviewM,1,InterviewY)
gen Interview_month                         = month(dofm(Interview_date))
replace Interview_month                     = .n if Interview_date==.n
replace Interview_month                     = .  if Interview_date==.

gen miss_interview                          = (Interview_date==.n)
bys ID: egen miss_interview_dumB            = mean(miss_interview)
gen ever_miss_interview                     = (miss_interview_dumB > 0)
drop miss_interview_dumB

gen age_at_miss_int                         = age_now*miss_interview
gen year_miss_int                           = year*miss_interview

gen miss_interview_cum                      = 0
by ID: replace miss_interview_cum           = miss_interview_cum[_n-1] + 1 if miss_interview[_n]==1

gsort +ID -year
gen miss_interview_length                   = miss_interview_cum
by ID: replace miss_interview_length        = miss_interview_length[_n-1] if miss_interview_cum[_n]!=0 & miss_interview_cum[_n-1]!=0 & year~=2014

sort ID year
* create flag for long missed interview spell
generate year_first_long_spellA             = year*(miss_interview_length>2)
replace  year_first_long_spellA             = . if year_first_long_spellA==0
bys ID (year): egen year_first_long_spell   = min(year_first_long_spellA)
drop year_first_long_spellA
gen long_miss_flag                          = year>=year_first_long_spell

* create flag for any missed interview spell
generate year_first_short_spellA             = year*(miss_interview_length>0)
replace  year_first_short_spellA             = . if year_first_short_spellA==0
bys ID (year): egen year_first_short_spell   = min(year_first_short_spellA)
drop year_first_short_spellA
gen short_miss_flag                          = year>=year_first_short_spell

gsort +ID -year
gen miss_interview_last_spell               = 0
by ID: replace miss_interview_last_spell    = 1 if miss_interview_cum[_n]!=0 & ( (year==2015 & ~flag2) | miss_interview_last_spell[_n-1]==1)
sort ID year
label var miss_interview            "Missed Interview In Current Year"
label var miss_interview_cum        "Running Tally Of Current Missed Interview Spell"
label var miss_interview_length     "Length Of Current Missed Interview Spell"
label var miss_interview_last_spell "Element Of Last Missed Interview Spell"

* identify right-censored interview spells -- no one in 2016 should enter the data (since they are all interviewed before October)
generat not_missing_interview               = 1-miss_interview if year<2016
replace not_missing_interview               = 0 if year==2016 & R17interviewDate>=ym(2016,1 ) // don't use 2016 data for anyone interviewed in 2016, since no one in R16 was interviewed after Jul 2016
* replace not_missing_interview               = 0 if year==2015 & R15interviewDate< ym(2015,10) // we don't have data on those interviewed in R16 before Oct 2015 for latest round
generat nonmissing_int_year                 = year*not_missing_interview
bys ID (year): egen max_nonmissing_int_year = max(nonmissing_int_year)
generat missIntLastSpell                    = (year>max_nonmissing_int_year)

* interview month of last survey year (either the last year before a 3+ missed spell, the last year before a right-censored spell, or 2015)
generat last_survey_yearA                   = year_first_long_spell-1 if year==year_first_long_spell
replace last_survey_yearA                   = max_nonmissing_int_year if year==2015

generat last_survey_year_hastyA             = year_first_short_spell-1 if year==year_first_short_spell
replace last_survey_year_hastyA             = max_nonmissing_int_year if year==2015

bys ID (year): egen last_survey_year        = min(last_survey_yearA)
bys ID (year): egen last_survey_year_hasty  = min(last_survey_year_hastyA)

gen last_int_dayA                           = Interview_day if year==last_survey_year
bys ID (year): egen last_int_day            = mean(last_int_dayA)
format last_int_day %td


*--------------------------------------------------------------------------------
* Some summary stats on people's missing interview behavior throughout the survey
*--------------------------------------------------------------------------------
* get proportion of people who ever missed any number of consecutive interviews
foreach x of numlist 1/14 {
    by ID: gen miss_`x'_intA  = (miss_interview_length==`x')
}
foreach x of numlist 1/14 {
    by ID: egen miss_`x'_intB  = mean(miss_`x'_intA )
}
foreach x of numlist 1/14 {
    by ID: gen ever_miss_`x'_int  = (miss_`x'_intB >0)
}
drop miss_*intA miss_*intB

gen ever_miss_3plus_int = ((ever_miss_3_int)|(ever_miss_4_int)|(ever_miss_5_int)|(ever_miss_6_int)|(ever_miss_7_int)|(ever_miss_8_int)|(ever_miss_9_int)|(ever_miss_10_int)|(ever_miss_11_int)|(ever_miss_12_int))

* get proportion of people who return after missing any number of consecutive interviews
foreach x of numlist 1/14 {
    by ID: gen return_after_`x'_miss_intA  = (miss_interview_length[_n-1]==`x'  & miss_interview_length[_n]==0)
}
foreach x of numlist 1/14 {
    by ID: egen return_after_`x'_miss_intB  = mean(return_after_`x'_miss_intA )
}
foreach x of numlist 1/14 {
    by ID: gen ever_return_after_`x'_miss_int  = (return_after_`x'_miss_intB >0)
}
drop return_after*A return_after*B

gen ever_return_after_3plus_miss_int = ((ever_return_after_3_miss_int)|(ever_return_after_4_miss_int)|(ever_return_after_5_miss_int)|(ever_return_after_6_miss_int)|(ever_return_after_7_miss_int)|(ever_return_after_8_miss_int)|(ever_return_after_9_miss_int)|(ever_return_after_10_miss_int)|(ever_return_after_11_miss_int)|(ever_return_after_12_miss_int)|(ever_return_after_13_miss_int))

* Count number of people who have multiple missing interview spells lasting different lengths
foreach x of numlist 1/14 {
    count if ever_return_after_1_miss_int ==1 & ever_return_after_`x'_miss_int==1 & year==1997
}
foreach x of numlist 2/14 {
    count if ever_return_after_2_miss_int ==1 & ever_return_after_`x'_miss_int==1 & year==1997
}
foreach x of numlist 3/14 {
    count if ever_return_after_3_miss_int ==1 & ever_return_after_`x'_miss_int==1 & year==1997
}
foreach x of numlist 4/14 {
    count if ever_return_after_4_miss_int ==1 & ever_return_after_`x'_miss_int==1 & year==1997
}
foreach x of numlist 5/14 {
    count if ever_return_after_5_miss_int ==1 & ever_return_after_`x'_miss_int==1 & year==1997
}
foreach x of numlist 6/14 {
    count if ever_return_after_6_miss_int ==1 & ever_return_after_`x'_miss_int==1 & year==1997
}
foreach x of numlist 7/14 {
    count if ever_return_after_7_miss_int ==1 & ever_return_after_`x'_miss_int==1 & year==1997
}
foreach x of numlist 8/14 {
    count if ever_return_after_8_miss_int ==1 & ever_return_after_`x'_miss_int==1 & year==1997
}
foreach x of numlist 9/14 {
    count if ever_return_after_9_miss_int ==1 & ever_return_after_`x'_miss_int==1 & year==1997
}
foreach x of numlist 10/14 {
    count if ever_return_after_10_miss_int ==1 & ever_return_after_`x'_miss_int==1 & year==1997
}
foreach x of numlist 11/14 {
    count if ever_return_after_11_miss_int ==1 & ever_return_after_`x'_miss_int==1 & year==1997
}
foreach x of numlist 12/14 {
    count if ever_return_after_12_miss_int ==1 & ever_return_after_`x'_miss_int==1 & year==1997
}
foreach x of numlist 13/14 {
    count if ever_return_after_13_miss_int ==1 & ever_return_after_`x'_miss_int==1 & year==1997
}

foreach x of numlist 1/14 {
    sum ever_return_after_`x'_miss_int if ever_miss_`x'_int==1 & year==1997
}

sum ever_return_after_3plus_miss_int if ever_miss_3plus_int==1 & year==1997

tab age_at_miss_int            if age_at_miss_int>0, mi
tab age_at_miss_int birth_year if age_at_miss_int>0, mi col nofreq
tab year_miss_int              if year_miss_int>0, mi // show momentary interview missers
tab last_survey_year           if  year==2015 // show cumulative attrition in our sample (either because of permanent attrition from NLSY or having missed 3+ interviews)
tab last_survey_year_hasty     if  year==2015 // show cumulative attrition in our sample if we never made use of backfilled observations
tab max_nonmissing_int_year    if year==2015 // show cumulative attrition in our sample if we always used backfilled obs (i.e. if we kept super-long missed spells)
/* See ../NLSY97AttritionSummary.xlsx for spreadsheet of last four lines */
