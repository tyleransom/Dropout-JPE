version 13.0
set more off
capture log close
capture log using y97_create_matlab_data_tscrGPA.log, replace

clear all

* This do-file creates a rectangularized panel (wide format) in CSV format, for importing into Matlab

global clnloc ../../../data/nlsy97/cleaned/
use ${clnloc}y97_all_tscrGPA.dta, clear

local schAbilMeasures      asvab?? SATmath SATverb
local schAbilPrefMeasures  numAPs lateForSchoolNoExcuse breakRulesRegularly R1ExtraClass R1WeekdaysExtraClass HrsExtraClass tookClassDuringBreak reasonTookClassDuringBreak
local workAbilPrefMeasures highStandardsWork doMoreThanExpected pctChanceWork20Hrs30 parPctChanceWork20Hrs30
local consumpMeasures      tui4imp grant4pr grant4impPos grant4impPosRMSE loan4pr loan4impPos loan4impPosRMSE tui2imp grant2pr grant2impPos grant2impPosRMSE loan2pr loan2impPos loan2impPosRMSE ParTrans2RMSE ParTrans4RMSE loan18_4pr loan18_4impPos loan18_4impPosRMSE loan18_2pr loan18_2impPos loan18_2impPosRMSE loan18_4imp loan18_2imp

* drop log_wage log_comp
ren GPA grades
ren log_wage    log_wageJobMain
ren log_comp    log_compJobMain
ren log_wageOct log_wage
ren log_compOct log_comp
ren avgHrsOct hours_per_week_Oct
ren DKMajor DKmajor
keep ID year Choice choice15 choice15A choice15B choice25 whiteCollar male black hispanic age AFQT ASVAB* predSAT*Z efc `schAbilMeasures' `schAbilPrefMeasures' `workAbilPrefMeasures' `consumpMeasures' cum_2yr cum_4yr BA_year AA_year BA_month AA_month grad_2yr grad_4yr CC_DO_SO Grades_HS_best famIncAsTeen grades log_wage log_comp log_wageJobMain log_compJobMain hours_per_week_Oct weeks_worked_Oct Peduc m_Peduc Parent_college famIncAsTeen m_famIncAsTeen anyFlag anyFlagFemale in_grad_school scienceMajor* DKmajor missingMajor otherMajor* finalSciMajor* final_major Major lnParTransHat4 lnParTransHat2 prParTrans2 prParTrans4 E_ParTrans2 E_ParTrans4

generat yearw = year
replace year  = year-1996

ren Choice choice
order ID male black hispanic AFQT ASVABmath ASVABverb predSAT*Z efc `schAbilMeasures' `schAbilPrefMeasures' `workAbilPrefMeasures' `consumpMeasures' BA_year AA_year BA_month AA_month CC_DO_SO Grades_HS_best Peduc m_Peduc Parent_college famIncAsTeen m_famIncAsTeen finalSciMajor* final_major yearw choice age cum_2yr cum_4yr grad_2yr grad_4yr grades log_wage log_comp log_wageJobMain log_compJobMain hours_per_week_Oct weeks_worked_Oct anyFlag anyFlagFemale in_grad_school scienceMajor* DKmajor missingMajor otherMajor* Major lnParTransHat4 lnParTransHat2 prParTrans2 prParTrans4 E_ParTrans2 E_ParTrans4
drop ASVAB ASVABmathNotNO 
reshape wide yearw age choice15 choice15A choice15B choice25 whiteCollar choice cum_2yr cum_4yr grad_2yr grad_4yr grades log_wage log_comp log_wageJobMain log_compJobMain hours_per_week_Oct weeks_worked_Oct anyFlag anyFlagFemale in_grad_school scienceMajor DKmajor missingMajor otherMajor scienceMajorA otherMajorA scienceMajorB otherMajorB Major lnParTransHat4 lnParTransHat2 prParTrans2 prParTrans4 E_ParTrans2 E_ParTrans4, i(ID) j(year)
order ID male black hispanic AFQT ASVABmath ASVABverb predSAT*Z efc `schAbilMeasures' `schAbilPrefMeasures' `workAbilPrefMeasures' `consumpMeasures' BA_year AA_year BA_month AA_month CC_DO_SO Grades_HS_best Peduc m_Peduc Parent_college famIncAsTeen m_famIncAsTeen finalSciMajor finalSciMajorA finalSciMajorB final_major
desc

save ${clnloc}y97_all_wide, replace

recode _all (.r .d .n .v .i = .)

outsheet using ${clnloc}y97_tscrGPA.csv, comma nolabel replace
outsheet using ${clnloc}y97_male_tscrGPA.csv if male==1, comma nolabel replace

log close
