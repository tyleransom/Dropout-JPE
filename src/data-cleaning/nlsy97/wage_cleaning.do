***************************************************
***************************************************
** 4 cases for filling in missing wages in 2012
** (due to the biennial structure of the survey)
***************************************************
***************************************************
gen wflg = (workPT | workFT) & in_secondary_school==0
*=================================================
* Case 1: Interpolate 2012 wages for those in same spell in '11, '12, and '13
*=================================================
mdesc comp_job_main if year==2012 & wflg
* First create a dummy for if the job was same in all three years
bys ID (year): generat empTemp    = Emp_Status_Week_40_
bys ID (year): generat empTempLag = L.Emp_Status_Week_40_
bys ID (year): generat empTempFut = F.Emp_Status_Week_40_

bys ID (year): replace empTemp    = Emp_Status_Week_41_   if !inrange(  Emp_Status_Week_40_,1000,.) & (  workPT |   workFT) &   in_secondary_school==0
bys ID (year): replace empTempLag = L.Emp_Status_Week_41_ if !inrange(L.Emp_Status_Week_40_,1000,.) & (L.workPT | L.workFT) & L.in_secondary_school==0
bys ID (year): replace empTempFut = F.Emp_Status_Week_41_ if !inrange(F.Emp_Status_Week_40_,1000,.) & (F.workPT | F.workFT) & F.in_secondary_school==0

generat same3jobs = 0
replace same3jobs = 1 if empTemp==empTempLag & empTemp==empTempFut & year==2012 & inrange(empTempLag,1000,.) & inrange(empTemp,1000,.) & inrange(empTempFut,1000,.)
bys ID (year): replace same3jobs = same3jobs[_n+1] if year<=2011
bys ID (year): replace same3jobs = same3jobs[_n-1] if year==2013

* Now interpolate and use the interpolated wage as the 2012 wage
bys ID (year): ipolate comp_job_main year if same3jobs, gen(comp_job_main_ipolate)
replace comp_job_main = comp_job_main_ipolate if same3jobs & year==2012
drop comp_job_main_ipolate
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local interp2012 = ${initmisswage}-`r(N)' // Interpolate year 2012 wages for those in same job in 2011, 2012, and 2013

*=================================================
* Case 2: Use 2013 reported wage if 2012 was end of a job spell
*=================================================
mdesc comp_job_main if year==2012 & wflg
* First create a dummy for if the person was transitioning out of the job in 2012
generat oldjob2012 = 0
replace oldjob2012 = 1 if empTemp!=empTempFut & empTemp==empTempLag & year==2012 & inrange(empTemp,1000,.) & inrange(empTempLag,1000,.)

* Now use the reported wage from the 2013 interview as the 2012 wage
replace comp_job_main = compOct if oldjob2012 & year==2012
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local rep2013 = ${initmisswage}-`interp2012'-`r(N)' // Use 2013 reported wage as year 2012 wage for those where 2012 was the end of a job spell 

*=================================================
* Case 3: Use 2013 reported wage if 2012 was single job spell
*=================================================
mdesc comp_job_main if year==2012 & wflg
* First create a dummy for if the person was in a single-year spell in 2012
generat singlejob2012 = 0
replace singlejob2012 = 1 if empTemp!=empTempFut & empTemp!=empTempLag & year==2012 & inrange(empTemp,1000,.)

* Now use the reported wage from the 2013 interview as the 2012 wage
replace comp_job_main = compOct if singlejob2012 & year==2012
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local s2013 = ${initmisswage}-`interp2012'-`rep2013'-`r(N)' // Use 2013 reported wage as year 2012 wage for those where 2012 was a single job spell 


*=================================================
* Case 4: Use regression to predict 2012 wage if same employer in 2012 and 2013
*=================================================
mdesc comp_job_main if year==2012 & wflg
* Create dummy for if person was in a job that started in 2012 and continued in 2013
generat newjob2012 = 0
replace newjob2012 = 1 if empTemp==empTempFut & empTemp!=empTempLag & year==2012 & inrange(empTemp,1000,.) & inrange(empTempFut,1000,.)
summari newjob2012 if year==2012 & wflg

* Check that these 4 cases form an exhaustive set of 2012 workers
sum same3jobs oldjob2012 singlejob2012 newjob2012 if year==2012 & wflg
tab ID if !same3jobs & !oldjob2012 & !singlejob2012 & !newjob2012 & year==2012 & wflg

* Estimate regressions, separately by gender
clonevar comp_job_mein = comp_job_main
generat wagetemp = log(comp_job_mein/100)
xtreg   wagetemp c.exper c.age c.cum_2yr c.cum_4yr b1997.year i.in_2yr i.in_4yr i.in_grad_school i.workPT i.grad_2yr i.grad_4yr if wflg & female==1, fe
predict wagepredF if year==2012 & newjob2012 & wflg & female==1
replace wagepredF = wagepredF + `e(sigma_e)'*rnormal() if !mi(wagepredF)
xtreg   wagetemp c.exper c.age c.cum_2yr c.cum_4yr b1997.year i.in_2yr i.in_4yr i.in_grad_school i.workPT i.grad_2yr i.grad_4yr if wflg & female==0, fe
predict wagepred  if year==2012 & newjob2012 & wflg & female==0
replace wagepred  = wagepred + `e(sigma_e)'*rnormal() if !mi(wagepred)

* Use the predicted wages from the regressions as the 2012 wage
replace comp_job_main = 100*exp(wagepredF) if female==1 & year==2012 & newjob2012 & !mi(compOct) & wflg
replace comp_job_main = 100*exp(wagepred)  if female==0 & year==2012 & newjob2012 & !mi(compOct) & wflg
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local fe2013 = ${initmisswage}-`interp2012'-`rep2013'-`s2013'-`r(N)' // Impute (via FE regression) 2012 wage for those who were at the same employer in 2012 and 2013  

mdesc comp_job_main if year==2012 & wflg

* * Missingness over time and by job type
* gen m_comp_job_main = mi(comp_job_main) if wflg

* tab year     if in_secondary_school==0 & female==0, sum(m_comp_job_main)
* tab exper    if in_secondary_school==0 & female==0, sum(m_comp_job_main)

* l ID year choice15 comp_job_main compOct Main_job Hrly_comp_Job1_ Hrly_comp_Job2_ if female==0 & inrange(ID,1,50) & wflg, sepby(ID)

drop empTemp* wagepred* wagetemp same3jobs oldjob2012 singlejob2012 newjob2012 comp_job_mein

***************************************************
***************************************************
** 4 cases for filling in missing wages in 2014
** (due to the biennial structure of the survey)
***************************************************
***************************************************
*=================================================
* Case 1: Interpolate 2014 wages for those in same spell in '13, '14, and '15
*=================================================
mdesc comp_job_main if year==2014 & wflg
* First create a dummy for if the job was same in all three years
bys ID (year): generat empTemp    = Emp_Status_Week_40_
bys ID (year): generat empTempLag = L.Emp_Status_Week_40_
bys ID (year): generat empTempFut = F.Emp_Status_Week_40_

bys ID (year): replace empTemp    = Emp_Status_Week_41_   if !inrange(  Emp_Status_Week_40_,1000,.) & (  workPT |   workFT) &   in_secondary_school==0
bys ID (year): replace empTempLag = L.Emp_Status_Week_41_ if !inrange(L.Emp_Status_Week_40_,1000,.) & (L.workPT | L.workFT) & L.in_secondary_school==0
bys ID (year): replace empTempFut = F.Emp_Status_Week_41_ if !inrange(F.Emp_Status_Week_40_,1000,.) & (F.workPT | F.workFT) & F.in_secondary_school==0

generat same3jobs = 0
replace same3jobs = 1 if empTemp==empTempLag & empTemp==empTempFut & year==2014 & inrange(empTempLag,1000,.) & inrange(empTemp,1000,.) & inrange(empTempFut,1000,.)
bys ID (year): replace same3jobs = same3jobs[_n+1] if year<=2013
bys ID (year): replace same3jobs = same3jobs[_n-1] if year==2015

* Now interpolate and use the interpolated wage as the 2014 wage
bys ID (year): ipolate comp_job_main year if same3jobs, gen(comp_job_main_ipolate)
replace comp_job_main = comp_job_main_ipolate if same3jobs & year==2014
drop comp_job_main_ipolate
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local interp2014 = ${initmisswage}-`interp2012'-`rep2013'-`s2013'-`fe2013'-`r(N)' // Interpolate year 2012 wages for those in same job in 2011, 2012, and 2013 

*=================================================
* Case 2: Use 2015 reported wage if 2014 was end of a job spell
*=================================================
mdesc comp_job_main if year==2014 & wflg
* First create a dummy for if the person was transitioning out of the job in 2014
generat oldjob2014 = 0
replace oldjob2014 = 1 if empTemp!=empTempFut & empTemp==empTempLag & year==2014 & inrange(empTemp,1000,.) & inrange(empTempLag,1000,.)

* Now use the reported wage from the 2015 interview as the 2014 wage
replace comp_job_main = compOct if oldjob2014 & year==2014
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local rep2015 = ${initmisswage}-`interp2012'-`rep2013'-`s2013'-`fe2013'-`interp2014'-`r(N)' // Use 2015 reported wage as year 2014 wage for those where 2014 was the end of a job spell  


*=================================================
* Case 3: Use 2015 reported wage if 2014 was single job spell
*=================================================
mdesc comp_job_main if year==2014 & wflg
* First create a dummy for if the person was in a single-year spell in 2014
generat singlejob2014 = 0
replace singlejob2014 = 1 if empTemp!=empTempFut & empTemp!=empTempLag & year==2014 & inrange(empTemp,1000,.)

* Now use the reported wage from the 2015 interview as the 2014 wage
replace comp_job_main = compOct if singlejob2014 & year==2014
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local s2015 = ${initmisswage}-`interp2012'-`rep2013'-`s2013'-`fe2013'-`interp2014'-`rep2015'-`r(N)' // Use 2015 reported wage as year 2014 wage for those where 2014 was a single job spell  


*=================================================
* Case 4: Use regression to predict 2014 wage if same employer in 2014 and 2015
*=================================================
mdesc comp_job_main if year==2014 & wflg
* Create dummy for if person was in a job that started in 2014 and continued in 2015
generat newjob2014 = 0
replace newjob2014 = 1 if empTemp==empTempFut & empTemp!=empTempLag & year==2014 & inrange(empTemp,1000,.) & inrange(empTempFut,1000,.)
summari newjob2014 if year==2014 & wflg

* Check that these 4 cases form an exhaustive set of 2014 workers
sum same3jobs oldjob2014 singlejob2014 newjob2014 if year==2014 & wflg
tab ID if !same3jobs & !oldjob2014 & !singlejob2014 & !newjob2014 & year==2014 & wflg

* Estimate regressions, separately by gender
clonevar comp_job_mein = comp_job_main
generat wagetemp = log(comp_job_mein/100)
xtreg   wagetemp c.exper c.age c.cum_2yr c.cum_4yr b1997.year i.in_2yr i.in_4yr i.in_grad_school i.workPT i.grad_2yr i.grad_4yr if wflg & female==1, fe
predict wagepredF if year==2014 & newjob2014 & wflg & female==1
replace wagepredF = wagepredF + `e(sigma_e)'*rnormal() if !mi(wagepredF)
xtreg   wagetemp c.exper c.age c.cum_2yr c.cum_4yr b1997.year i.in_2yr i.in_4yr i.in_grad_school i.workPT i.grad_2yr i.grad_4yr if wflg & female==0, fe
predict wagepred  if year==2014 & newjob2014 & wflg & female==0
replace wagepred  = wagepred + `e(sigma_e)'*rnormal() if !mi(wagepred)

* Use the predicted wages from the regressions as the 2014 wage
replace comp_job_main = 100*exp(wagepredF) if female==1 & year==2014 & newjob2014 & !mi(compOct) & wflg
replace comp_job_main = 100*exp(wagepred)  if female==0 & year==2014 & newjob2014 & !mi(compOct) & wflg
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local fe2014 = ${initmisswage}-`interp2012'-`rep2013'-`s2013'-`fe2013'-`interp2014'-`rep2015'-`s2015'-`r(N)' // Impute (via FE regression) 2012 wage for those who were at the same employer in 2012 and 2013  

mdesc comp_job_main if year==2014 & wflg

* * Missingness over time and by job type
* gen m_comp_job_main = mi(comp_job_main) if wflg

* tab year     if in_secondary_school==0 & female==0, sum(m_comp_job_main)
* tab exper    if in_secondary_school==0 & female==0, sum(m_comp_job_main)

* l ID year choice15 comp_job_main compOct Main_job Hrly_comp_Job1_ Hrly_comp_Job2_ if female==0 & inrange(ID,1,50) & wflg, sepby(ID)

drop empTemp* wagepred* wagetemp same3jobs oldjob2014 singlejob2014 newjob2014 comp_job_mein

***************************************************
***************************************************
** 4 cases for filling in missing wages in years
** respondent missed interview (Main_job==.n)
***************************************************
***************************************************
* Create missed interview spell identifiers
sort ID year
spell if ~missIntLastSpell & year<2016 & year!=2012, by(ID) cond(Interview_date==.n) spell(MIspell) end(MIend) seq(MIseq) censor(MIcensorl MIcensorr)
bys ID MIspell (year): egen MIspellLength = max(MIseq)
bys ID (year): egen numMIspells = max(MIspell)
sort ID year

* Create October employer identifiers
generat tempemp = Emp_Status_Week_40_ if wflg
replace tempemp = Emp_Status_Week_41_ if wflg & !inrange(tempemp,1000,.)

* Create employment spell identifiers
sort ID year
spell tempemp if ~missIntLastSpell & year<2016 & wflg, by(ID) spell(emp_spell) end(emp_spell_end) seq(emp_spell_seq) censor(emp_spell_censor_l emp_spell_censor_r)
sort ID year

*=================================================
* Case 1: Interpolate missed interview wages for those
* in same empl. spell for all periods of missed intvw spell
*=================================================
bys ID (year): generat samejob = 0
bys ID (year): replace samejob = 1 if tempemp==F1.tempemp & tempemp==F2.tempemp & MIseq==0 & F1.MIseq==1 & F1.MIspellLength==1 & inrange(tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L1.tempemp & tempemp==F1.tempemp & MIseq==1               &    MIspellLength==1 & inrange(tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L2.tempemp & tempemp==L1.tempemp & MIseq==0 & L1.MIseq==1 & L1.MIspellLength==1 & inrange(tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.)

bys ID (year): replace samejob = 1 if tempemp==F1.tempemp & tempemp==F2.tempemp & tempemp==F3.tempemp & MIseq==0 & F1.MIseq==1 & F1.MIspellLength==2 & inrange(tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.) & inrange(F3.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L1.tempemp & tempemp==F1.tempemp & tempemp==F2.tempemp & MIseq==1 &                  MIspellLength==2 & inrange(tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L2.tempemp & tempemp==L1.tempemp & tempemp==F1.tempemp & MIseq==2 &                  MIspellLength==2 & inrange(tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L3.tempemp & tempemp==L2.tempemp & tempemp==L1.tempemp & MIseq==0 & L1.MIseq==2 & L1.MIspellLength==2 & inrange(tempemp,1000,.) & inrange(L3.tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.)

bys ID (year): replace samejob = 1 if tempemp==F1.tempemp & tempemp==F2.tempemp & tempemp==F3.tempemp & tempemp==F4.tempemp & MIseq==0 & F1.MIseq==1 & F1.MIspellLength==3 & inrange(tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.) & inrange(F3.tempemp,1000,.) & inrange(F4.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L1.tempemp & tempemp==F1.tempemp & tempemp==F2.tempemp & tempemp==F3.tempemp & MIseq==1 &                  MIspellLength==3 & inrange(tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.) & inrange(F3.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L2.tempemp & tempemp==L1.tempemp & tempemp==F1.tempemp & tempemp==F2.tempemp & MIseq==2 &                  MIspellLength==3 & inrange(tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L3.tempemp & tempemp==L2.tempemp & tempemp==L1.tempemp & tempemp==F1.tempemp & MIseq==3 &                  MIspellLength==3 & inrange(tempemp,1000,.) & inrange(L3.tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L4.tempemp & tempemp==L3.tempemp & tempemp==L2.tempemp & tempemp==L1.tempemp & MIseq==0 & L1.MIseq==3 & L1.MIspellLength==3 & inrange(tempemp,1000,.) & inrange(L4.tempemp,1000,.) & inrange(L3.tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.)

bys ID (year): replace samejob = 1 if tempemp==F1.tempemp & tempemp==F2.tempemp & tempemp==F3.tempemp & tempemp==F4.tempemp & tempemp==F5.tempemp & MIseq==0 & F1.MIseq==1 & F1.MIspellLength==4 & inrange(tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.) & inrange(F3.tempemp,1000,.) & inrange(F4.tempemp,1000,.) & inrange(F5.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L1.tempemp & tempemp==F1.tempemp & tempemp==F2.tempemp & tempemp==F3.tempemp & tempemp==F4.tempemp & MIseq==1 &                  MIspellLength==4 & inrange(tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.) & inrange(F3.tempemp,1000,.) & inrange(F4.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L2.tempemp & tempemp==L1.tempemp & tempemp==F1.tempemp & tempemp==F2.tempemp & tempemp==F3.tempemp & MIseq==2 &                  MIspellLength==4 & inrange(tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.) & inrange(F3.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L3.tempemp & tempemp==L2.tempemp & tempemp==L1.tempemp & tempemp==F1.tempemp & tempemp==F2.tempemp & MIseq==3 &                  MIspellLength==4 & inrange(tempemp,1000,.) & inrange(L3.tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L4.tempemp & tempemp==L3.tempemp & tempemp==L2.tempemp & tempemp==L1.tempemp & tempemp==F1.tempemp & MIseq==4 &                  MIspellLength==4 & inrange(tempemp,1000,.) & inrange(L4.tempemp,1000,.) & inrange(L3.tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L5.tempemp & tempemp==L4.tempemp & tempemp==L3.tempemp & tempemp==L2.tempemp & tempemp==L1.tempemp & MIseq==0 & L1.MIseq==4 & L1.MIspellLength==4 & inrange(tempemp,1000,.) & inrange(L5.tempemp,1000,.) & inrange(L4.tempemp,1000,.) & inrange(L3.tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.)

bys ID (year): replace samejob = 1 if tempemp==F1.tempemp & tempemp==F2.tempemp & tempemp==F3.tempemp & tempemp==F4.tempemp & tempemp==F5.tempemp & tempemp==F6.tempemp & MIseq==0 & F1.MIseq==1 & F1.MIspellLength==5 & inrange(tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.) & inrange(F3.tempemp,1000,.) & inrange(F4.tempemp,1000,.) & inrange(F5.tempemp,1000,.) & inrange(F6.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L1.tempemp & tempemp==F1.tempemp & tempemp==F2.tempemp & tempemp==F3.tempemp & tempemp==F4.tempemp & tempemp==F5.tempemp & MIseq==1 &                  MIspellLength==5 & inrange(tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.) & inrange(F3.tempemp,1000,.) & inrange(F4.tempemp,1000,.) & inrange(F5.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L2.tempemp & tempemp==L1.tempemp & tempemp==F1.tempemp & tempemp==F2.tempemp & tempemp==F3.tempemp & tempemp==F4.tempemp & MIseq==2 &                  MIspellLength==5 & inrange(tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.) & inrange(F3.tempemp,1000,.) & inrange(F4.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L3.tempemp & tempemp==L2.tempemp & tempemp==L1.tempemp & tempemp==F1.tempemp & tempemp==F2.tempemp & tempemp==F3.tempemp & MIseq==3 &                  MIspellLength==5 & inrange(tempemp,1000,.) & inrange(L3.tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.) & inrange(F3.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L4.tempemp & tempemp==L3.tempemp & tempemp==L2.tempemp & tempemp==L1.tempemp & tempemp==F1.tempemp & tempemp==F2.tempemp & MIseq==4 &                  MIspellLength==5 & inrange(tempemp,1000,.) & inrange(L4.tempemp,1000,.) & inrange(L3.tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & inrange(F2.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L5.tempemp & tempemp==L4.tempemp & tempemp==L3.tempemp & tempemp==L2.tempemp & tempemp==L1.tempemp & tempemp==F1.tempemp & MIseq==5 &                  MIspellLength==5 & inrange(tempemp,1000,.) & inrange(L5.tempemp,1000,.) & inrange(L4.tempemp,1000,.) & inrange(L3.tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.)
bys ID (year): replace samejob = 1 if tempemp==L6.tempemp & tempemp==L5.tempemp & tempemp==L4.tempemp & tempemp==L3.tempemp & tempemp==L2.tempemp & tempemp==L1.tempemp & MIseq==0 & L1.MIseq==5 & L1.MIspellLength==5 & inrange(tempemp,1000,.) & inrange(L6.tempemp,1000,.) & inrange(L5.tempemp,1000,.) & inrange(L4.tempemp,1000,.) & inrange(L3.tempemp,1000,.) & inrange(L2.tempemp,1000,.) & inrange(L1.tempemp,1000,.)

* Specific cases
bys ID (year): replace samejob = 1 if inlist(year,2013,2015) & samejob==0 & L.samejob==1 & tempemp==L.tempemp & inrange(tempemp,1000,.) & inrange(L.tempemp,1000,.)

* Now interpolate and use the interpolated wage as the 2012 wage
bys ID (year): ipolate comp_job_main year if samejob, gen(comp_job_main_ipolate)
replace comp_job_main = comp_job_main_ipolate if samejob & mi(comp_job_main) & !mi(comp_job_main_ipolate)
drop comp_job_main_ipolate
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local interpall = ${initmisswage}-`interp2012'-`rep2013'-`s2013'-`fe2013'-`interp2014'-`rep2015'-`s2015'-`fe2014'-`r(N)' // Interpolate missing wages for those with missing interviews but in the same job before, during, and after missing the interview(s)  

*=================================================
* Case 2: Use next valid interview wage if
* missed intvw was end of a job spell
*=================================================
generat oldjob = 0
replace oldjob = 1 if tempemp!=F1.tempemp & tempemp==L1.tempemp                                                                                         & Main_job==.n & inrange(tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & MIspellLength==1
replace oldjob = 1 if tempemp!=F1.tempemp & tempemp==L1.tempemp & tempemp==L2.tempemp                                                                   & Main_job==.n & inrange(tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & MIspellLength==2
replace oldjob = 1 if tempemp!=F1.tempemp & tempemp==L1.tempemp & tempemp==L2.tempemp & tempemp==L3.tempemp                                             & Main_job==.n & inrange(tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & MIspellLength==3
replace oldjob = 1 if tempemp!=F1.tempemp & tempemp==L1.tempemp & tempemp==L2.tempemp & tempemp==L3.tempemp & tempemp==L4.tempemp                       & Main_job==.n & inrange(tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & MIspellLength==4
replace oldjob = 1 if tempemp!=F1.tempemp & tempemp==L1.tempemp & tempemp==L2.tempemp & tempemp==L3.tempemp & tempemp==L4.tempemp & tempemp==L5.tempemp & Main_job==.n & inrange(tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & MIspellLength==5

* Now use the reported wage from the next non-missed interview as the wage
replace comp_job_main = compOct if oldjob
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local interpvi = ${initmisswage}-`interp2012'-`rep2013'-`s2013'-`fe2013'-`interp2014'-`rep2015'-`s2015'-`fe2014'-`interpall'-`r(N)' // Interpolate missing wages using the next valid interview wage if the missed interview was at the end of a job spell  


*=================================================
* Case 3: Use next valid interview wage if
* missed intvw was single job spell
*=================================================
* First create a dummy for if the person was in a single-year spell in 2012
generat singlejob = 0
replace singlejob = 1 if tempemp!=F1.tempemp & tempemp!=L1.tempemp & Main_job==.n & inrange(tempemp,1000,.) & inrange(L1.tempemp,1000,.) & inrange(F1.tempemp,1000,.) & MIspellLength==1

* Now use the reported wage from the 2015 interview as the 2012 wage
replace comp_job_main = compOct if singlejob
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local interpni = ${initmisswage}-`interp2012'-`rep2013'-`s2013'-`fe2013'-`interp2014'-`rep2015'-`s2015'-`fe2014'-`interpall'-`interpvi'-`r(N)' // Interpolate missing wages using the next valid interview wage if the missed interview was at the end of a job spell  


*=================================================
* Case 5: Interpolate wages within same employment spell
*=================================================
bys ID emp_spell (year): ipolate comp_job_main year, gen(comp_job_main_ipolate)
replace comp_job_main = comp_job_main_ipolate if mi(comp_job_main) & wflg & !mi(comp_job_main_ipolate)
drop comp_job_main_ipolate
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local interpwi = ${initmisswage}-`interp2012'-`rep2013'-`s2013'-`fe2013'-`interp2014'-`rep2015'-`s2015'-`fe2014'-`interpall'-`interpvi'-`interpni'-`r(N)' // Interpolate missing wages within the same job spell 


*=================================================
* Case 4: Use regression to predict missed intvw spell wages
* if same start of employer spell and start of missed interview spell coincide
*=================================================
gen tempflag = emp_spell_seq==1 & mi(comp_job_main) & wflg
* Estimate regressions, separately by gender
clonevar comp_job_mein = comp_job_main
generat wagetemp = log(comp_job_mein/100)
xtreg   wagetemp c.exper c.age c.cum_2yr c.cum_4yr b1997.year i.in_2yr i.in_4yr i.in_grad_school i.workPT i.grad_2yr i.grad_4yr if wflg & female==1, fe
predict wagepredF if emp_spell_seq==1 & mi(comp_job_main) & wflg & female==1
replace wagepredF = wagepredF + `e(sigma_e)'*rnormal() if !mi(wagepredF)
xtreg   wagetemp c.exper c.age c.cum_2yr c.cum_4yr b1997.year i.in_2yr i.in_4yr i.in_grad_school i.workPT i.grad_2yr i.grad_4yr if wflg & female==0, fe
predict wagepred  if emp_spell_seq==1 & mi(comp_job_main) & wflg & female==0
replace wagepred  = wagepred + `e(sigma_e)'*rnormal() if !mi(wagepred)
gen IDempspell = ID*100+emp_spell
xtset IDempspell year
xtreg   wagetemp c.exper c.age c.cum_2yr c.cum_4yr b1997.year i.in_2yr i.in_4yr i.in_grad_school i.workPT i.grad_2yr i.grad_4yr if wflg & female==1, fe
predict wagepredspF if emp_spell_seq==1 & mi(comp_job_main) & wflg & female==1
replace wagepredspF = wagepredspF + `e(sigma_e)'*rnormal() if !mi(wagepredspF)
xtreg   wagetemp c.exper c.age c.cum_2yr c.cum_4yr b1997.year i.in_2yr i.in_4yr i.in_grad_school i.workPT i.grad_2yr i.grad_4yr if wflg & female==0, fe
predict wagepredsp  if emp_spell_seq==1 & mi(comp_job_main) & wflg & female==0
replace wagepredsp  = wagepredsp + `e(sigma_e)'*rnormal() if !mi(wagepredsp)
xtset ID year
drop IDempspell
corr wagepredsp wagepred if female==0 & emp_spell_seq==1 & mi(comp_job_main) & wflg

* Use the predicted wages from the regressions as the 2012 or 2016 wage
replace comp_job_main = 100*exp(wagepredspF) if female==1 & emp_spell_seq==1 & mi(comp_job_main) & wflg
replace comp_job_main = 100*exp(wagepredsp)  if female==0 & emp_spell_seq==1 & mi(comp_job_main) & wflg
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local feall = ${initmisswage}-`interp2012'-`rep2013'-`s2013'-`fe2013'-`interp2014'-`rep2015'-`s2015'-`fe2014'-`interpall'-`interpvi'-`interpni'-`interpwi'-`r(N)' // Impute (via FE regression) 2012 wage for those who were at the same employer in 2012 and 2013  

*=================================================
* Case 5 (again): Interpolate wages within same employment spell
*=================================================
bys ID emp_spell (year): ipolate comp_job_main year, gen(comp_job_main_ipolate)
replace comp_job_main = comp_job_main_ipolate if mi(comp_job_main) & wflg & !mi(comp_job_main_ipolate)
drop comp_job_main_ipolate
* l ID year choice15 tempemp Main_job comp_job_main comp_job_main_ipolate Income wagepred MIseq MIspell MIspellLength samejob same3jobs oldjob2012 singlejob2012 newjob2012 if inlist(ID,58,95,180,1547,2341,2660,5698,8452) &  female==0, sepby(ID)
* l ID year choice15 tempemp Main_job comp_job_main compOct Income wagepred* emp_spell_seq MIseq tempflag  if inlist(ID,8896,8916,6667,6766), sepby(ID) nol
count if ~anyFlag & mi(comp_job_main) & (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,.) & inlist(choice15,-2,1,2,4,5,7,8,10,11,13,14)
local interpfinal = ${initmisswage}-`interp2012'-`rep2013'-`s2013'-`fe2013'-`interp2014'-`rep2015'-`s2015'-`fe2014'-`interpall'-`interpvi'-`interpni'-`interpwi'-`feall'-`r(N)' // (Again) interpolate missing wages within the same job spell 

*=================================================
* Write results to file
*=================================================
* interpolation
di "`interpfinal'"
di "`interpvi'"
di "`interpni'"
di "`interpwi'"
di "`interp2012'"
di "`interp2014'"
di "`interpall'"
local ia = ${initmisswage}-(`interpfinal'+`interpvi'+`interpni'+`interpwi'+`interp2012'+`interp2014'+`interpall')
di "`ia'"
file write wageappdx " & Remainder missing after interpolating missing wages within the same job spell\tnote{b} &" %7.0fc (`ia') " & " %4.2f (`=100*`ia'/${numworkobs}') " \\ "  _n

* next year wage if missing wage was end of job spell
di "`s2013'"
di "`s2015'"
di "`rep2013'"
di "`rep2015'"
local ra = `ia'-(`s2013'+`s2015'+`rep2013'+`rep2015')
di "`ra'"
file write wageappdx " & Remainder missing after using next-period reported wage for some of the missing wages\tnote{c} &" %7.0fc (`ra') " & " %4.2f (`=100*`ra'/${numworkobs}') " \\ "  _n

* imputation via FE regression
di "`fe2012'"
di "`fe2014'"
di "`feall'"
local fa = `ra'-(`fe2012'+`fe2014'+`feall')
di "`fa'"
file write wageappdx " & Remainder missing after imputing (via FE regression) prior-period wage for missing current-period wage under certain conditions\tnote{d}  &" %7.0fc (`fa') " & " %4.2f (`=100*`fa'/${numworkobs}') " \\ "  _n


