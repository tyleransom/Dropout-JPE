/*----------------------------------------------------------------------------------*\ 
|       Codes from the employment status data                                        |
|------------------------------------------------------------------------------------|
|  0: No information reported to account for week; job dates indeterminate           |
|  1: Not associated with an employer, not actively searching for an employer job    |
|  2: Not working (unemployment vs. out of labor force cannot be determined)         |
|  3: Associated with an employer, periods not working for the employer are missing  |
|  4: Unemployed                                                                     |
|  5: Out of the labor force                                                         |
|  6: Active military service                                                        |
| (): 4-8 digit employer code if employed                                            |
\*----------------------------------------------------------------------------------*/
 
* Deflate Federal Minimum wage and annual income measures
replace fedMinWage = fedMinWage/cpi // Deflate the federal minimum wage
replace Income     = Income/cpi     // Deflate annual earnings

* Fix "hours per week at Job X" variable
capture noisily drop Hrs_week_Job*
foreach x of numlist 1/13 {
    ren Hrs_per_week_Job`x'_ Hrs_week_Job`x'_
}

sum Hrs_week_Job?_ Hrs_week_Job??_

* replace "9702" etc. in Employment Status Array with "199702" etc.
foreach x of numlist 1/53 {
    qui replace Emp_Status_Week_`x'_ = 190000 + Emp_Status_Week_`x'_ if inrange(Emp_Status_Week_`x'_,9701,9899)
}

foreach y of numlist 1/13 {
    qui replace Emp`y'_ID = 190000 + Emp`y'_ID if inrange(Emp`y'_ID,9701,9899)
}

sort ID year
* Backfill the Employer ID, Wage rates, and Industry/Occupation codes for everyone in 2012/2014 (from 2013/2015, since 2013/15's interview covered two years)
foreach x of numlist 1/13 {
    by ID: replace Emp`x'_ID         = Emp`x'_ID[_n+1]         if inlist(year,2012,2014)
    by ID: replace Hrs_week_Job`x'_  = Hrs_week_Job`x'_[_n+1]  if inlist(year,2012,2014)
    by ID: replace Hrly_wage_Job`x'_ = Hrly_wage_Job`x'_[_n+1] if inlist(year,2012,2014)
    by ID: replace Hrly_comp_Job`x'_ = Hrly_comp_Job`x'_[_n+1] if inlist(year,2012,2014)
    by ID: replace Job`x'_Occupation = Job`x'_Occupation[_n+1] if inlist(year,2012,2014)
    by ID: replace Job`x'_Industry   = Job`x'_Industry[_n+1]   if inlist(year,2012,2014)
}

foreach x of numlist 1/13 {
    by ID: replace Job`x'_self_employed = Job`x'_self_employed[_n+1] if inlist(year,2012,2014)
}

* Backfill the Employer ID, Wage rates, and Industry/Occupation codes for people who missed interviews
gsort ID -year
foreach x of numlist 1/13 {
    by ID: replace Emp`x'_ID         = Emp`x'_ID[_n-1]         if ~mi(Emp`x'_ID[_n-1]) & Emp`x'_ID[_n]==.n
    by ID: replace Emp`x'_ID         = Emp`x'_ID[_n-1]         if ~mi(Emp`x'_ID[_n-1]) & inrange(year,1994,1996)
    by ID: replace Hrs_week_Job`x'_  = Hrs_week_Job`x'_[_n-1]  if ~mi(Hrs_week_Job`x'_[_n-1]) & Hrs_week_Job`x'_[_n]==.n
    by ID: replace Hrs_week_Job`x'_  = Hrs_week_Job`x'_[_n-1]  if ~mi(Hrs_week_Job`x'_[_n-1]) & inrange(year,1994,1996)
    by ID: replace Hrly_wage_Job`x'_ = Hrly_wage_Job`x'_[_n-1] if ~mi(Hrly_wage_Job`x'_[_n-1]) & Hrly_wage_Job`x'_[_n]==.n
    by ID: replace Hrly_wage_Job`x'_ = Hrly_wage_Job`x'_[_n-1] if ~mi(Hrly_wage_Job`x'_[_n-1]) & inrange(year,1994,1996)
    by ID: replace Hrly_comp_Job`x'_ = Hrly_comp_Job`x'_[_n-1] if ~mi(Hrly_comp_Job`x'_[_n-1]) & Hrly_comp_Job`x'_[_n]==.n
    by ID: replace Hrly_comp_Job`x'_ = Hrly_comp_Job`x'_[_n-1] if ~mi(Hrly_comp_Job`x'_[_n-1]) & inrange(year,1994,1996)
    by ID: replace Job`x'_Occupation = Job`x'_Occupation[_n-1] if ~mi(Job`x'_Occupation[_n-1]) & Job`x'_Occupation[_n]==.n
    by ID: replace Job`x'_Occupation = Job`x'_Occupation[_n-1] if ~mi(Job`x'_Occupation[_n-1]) & inrange(year,1994,1996)
    by ID: replace Job`x'_Industry   = Job`x'_Industry[_n-1]   if ~mi(Job`x'_Industry[_n-1]) & Job`x'_Industry[_n]==.n
    by ID: replace Job`x'_Industry   = Job`x'_Industry[_n-1]   if ~mi(Job`x'_Industry[_n-1]) & inrange(year,1994,1996)
}

tab Hrly_comp_Job1_ if Main_job==1 & Hrly_comp_Job1_ >=., mi
tab Hrly_comp_Job2_ if Main_job==2 & Hrly_comp_Job2_ >=., mi
tab Hrly_comp_Job3_ if Main_job==3 & Hrly_comp_Job3_ >=., mi
tab Hrly_comp_Job4_ if Main_job==4 & Hrly_comp_Job4_ >=., mi
tab Hrly_comp_Job5_ if Main_job==5 & Hrly_comp_Job5_ >=., mi
tab Hrly_comp_Job6_ if Main_job==6 & Hrly_comp_Job6_ >=., mi

* Deflate wages
foreach x of numlist 1/13 {
    clonevar tempcompj`x' = Hrly_comp_Job`x'_
    clonevar tempwagej`x' = Hrly_wage_Job`x'_
    qui replace Hrly_comp_Job`x'_ = Hrly_comp_Job`x'_/cpi
    qui replace Hrly_wage_Job`x'_ = Hrly_wage_Job`x'_/cpi
    qui replace Hrly_comp_Job`x'_ = tempcompj`x' if mi(Hrly_comp_Job`x'_)
    qui replace Hrly_wage_Job`x'_ = tempwagej`x' if mi(Hrly_wage_Job`x'_)
    drop tempcompj`x'
    drop tempwagej`x'
}

tab Hrly_comp_Job1_ if Main_job==1 & Hrly_comp_Job1_ >=., mi
tab Hrly_comp_Job2_ if Main_job==2 & Hrly_comp_Job2_ >=., mi
tab Hrly_comp_Job3_ if Main_job==3 & Hrly_comp_Job3_ >=., mi
tab Hrly_comp_Job4_ if Main_job==4 & Hrly_comp_Job4_ >=., mi
tab Hrly_comp_Job5_ if Main_job==5 & Hrly_comp_Job5_ >=., mi
tab Hrly_comp_Job6_ if Main_job==6 & Hrly_comp_Job6_ >=., mi

foreach x of numlist 1/13 {
    by ID: replace Job`x'_self_employed = Job`x'_self_employed[_n-1] if ~mi(Job`x'_self_employed[_n-1]) & Job`x'_self_employed[_n]==.n
    by ID: replace Job`x'_self_employed = .                          if ~mi(Job`x'_self_employed[_n-1]) & inrange(year,1994,1999)
}
sort ID year

* Generate Self Employed Weekly Status
foreach x of numlist 1/53 {
    generat Self_employed_Week`x'_ = 0
    foreach y of numlist 1/13 {
        replace Self_employed_Week`x'_ = 1 if Job`y'_self_employed==1 & Emp_Status_Week_`x'_==Emp`y'_ID
    }
}

* Generate the wage at the main job worked as defined by CV_MAINJOB_FLG
gen wage_job_main = .
gen comp_job_main = .
foreach x of numlist 1/13 {
    replace wage_job_main = Hrly_wage_Job`x'_ if Main_job==`x'
    replace comp_job_main = Hrly_comp_Job`x'_ if Main_job==`x'
}

* Generate self-employed status at the main job worked as defined by CV_MAINJOB_FLG
gen self_employed_job_main = .
foreach x of numlist 1/13 {
    replace self_employed_job_main = Job`x'_self_employed==1 if Main_job==`x'
}

* Generate Internship (based on the CV_MAINJOB_FLG variable)
gen internship_job_main = .
foreach x of numlist 1/13 {
    replace internship_job_main = Job`x'_Internship if Main_job==`x'
}

* This loop generates weekly dummies for if someone was in the labor force or not (i.e. employed or unemployed)
foreach x of numlist 1/53 {
    qui gen byte Labor_force_Week_`x' = inrange(Emp_Status_Week_`x'_,3,4) | inrange(Emp_Status_Week_`x'_,7,.)
    qui replace  Labor_force_Week_`x' = . if Emp_Status_Week_`x'_==.
}

* This loop generates weekly dummies for if someone was NOT in the labor force or not (i.e. uncertain status, military, or out of labor force)
foreach x of numlist 1/53 {
    qui gen byte No_Labor_force_Week_`x' = ~mi(Emp_Status_Week_`x'_) & inlist(Emp_Status_Week_`x'_,0,1,2,5,6)
    qui replace  No_Labor_force_Week_`x' = . if Emp_Status_Week_`x'_==.
}

* This loop generates weekly dummies for if someone was with a particular employer (>6 is the ID; 3 is 'missing' ID)
foreach x of numlist 1/53 {
    qui gen byte Employed_Week_`x' = (Emp_Status_Week_`x'_==3 | inrange(Emp_Status_Week_`x'_,7,.))
    qui replace  Employed_Week_`x' = . if Emp_Status_Week_`x'_==. | Labor_force_Week_`x' ==0
}

* This loop generates weekly dummies for if the person was missing an employer ID
foreach x of numlist 1/53 {
    qui gen byte Employed_noID_Week_`x' = Emp_Status_Week_`x'_==3
}

* This loop generates weekly dummies for if the employment status was unknown (0)
foreach x of numlist 1/53 {
    qui gen byte Emp_Status_Missing0_Week_`x' = (Emp_Status_Week_`x'_==0)
}

* This loop generates weekly dummies for if the employment status was coded as -5 (missed interview)
foreach x of numlist 1/53 {
    qui gen byte Emp_Status_MissingDotN_Week_`x' = (Emp_Status_Week_`x'_==.n)
}

* This loop generates weekly dummies for if the employment status was coded as -3 (invalid skip)
foreach x of numlist 1/53 {
    qui gen byte Emp_Status_MissingDotI_Week_`x' = (Emp_Status_Week_`x'_==.i)
}

* This loop generates weekly dummies for if the employment status was coded as -4 (valid skip)
foreach x of numlist 1/53 {
    qui gen byte Emp_Status_MissingDotV_Week_`x' = (Emp_Status_Week_`x'_==.v)
}

* This loop generates weekly dummies for if the employment status was coded as -2 (don't know)
foreach x of numlist 1/53 {
    qui gen byte Emp_Status_MissingDotD_Week_`x' = (Emp_Status_Week_`x'_==.d)
}

* This loop generates weekly dummies for if the employment status was coded as -1 (refused)
foreach x of numlist 1/53 {
    qui gen byte Emp_Status_MissingDotR_Week_`x' = (Emp_Status_Week_`x'_==.r)
}

* This loop generates weekly dummies for if the employment status was coded as . (general missing; this is a check for reshape errors)
foreach x of numlist 1/53 {
    qui gen byte Emp_Status_MissingDot_Week_`x' = (Emp_Status_Week_`x'_==.)
}

* This loop generates weekly dummies for if the person was in the military
foreach x of numlist 1/53 {
    qui gen byte Military_Week_`x' = (Emp_Status_Week_`x'_==6)
}

* These commands get total number of weeks spent in labor force status "x"
qui egen weeks_employed               = rowtotal(Employed_Week_? Employed_Week_??)
qui egen weeks_in_labor_force         = rowtotal(Labor_force_Week_? Labor_force_Week_??)
qui egen Weeks_Employed_noID          = rowtotal(Employed_noID_Week_? Employed_noID_Week_??)
qui egen Weeks_Emp_Status_Missing0    = rowtotal(Emp_Status_Missing0_Week_? Emp_Status_Missing0_Week_??)
qui egen Weeks_Emp_Status_MissingDotN = rowtotal(Emp_Status_MissingDotN_Week_? Emp_Status_MissingDotN_Week_??)
qui egen Weeks_Emp_Status_MissingDotI = rowtotal(Emp_Status_MissingDotI_Week_? Emp_Status_MissingDotI_Week_??)
qui egen Weeks_Emp_Status_MissingDotV = rowtotal(Emp_Status_MissingDotV_Week_? Emp_Status_MissingDotV_Week_??)
qui egen Weeks_Emp_Status_MissingDotD = rowtotal(Emp_Status_MissingDotD_Week_? Emp_Status_MissingDotD_Week_??)
qui egen Weeks_Emp_Status_MissingDotR = rowtotal(Emp_Status_MissingDotR_Week_? Emp_Status_MissingDotR_Week_??)
qui egen Weeks_Emp_Status_MissingDot  = rowtotal(Emp_Status_MissingDot_Week_? Emp_Status_MissingDot_Week_??)

* Need to make a slight correction for weeks employed, etc. in 2015, since the number of weeks reported depends on the interview date
qui gen potential_LF_weeks         = 52-Weeks_Emp_Status_MissingDotV                     if year==2015 & inrange(Interview_date,ym(2015,11),ym(2015,12))
qui gen weeks_employed_prime       = floor(52*(weeks_employed/potential_LF_weeks))       if year==2015 & inrange(Interview_date,ym(2015,11),ym(2015,12))
qui gen weeks_in_labor_force_prime = floor(52*(weeks_in_labor_force/potential_LF_weeks)) if year==2015 & inrange(Interview_date,ym(2015,11),ym(2015,12))
qui gen Weeks_Employed_noID_prime  = floor(52*(Weeks_Employed_noID/potential_LF_weeks))  if year==2015 & inrange(Interview_date,ym(2015,11),ym(2015,12))

replace weeks_employed       = weeks_employed_prime       if year==2015 & inrange(Interview_date,ym(2015,11),ym(2015,12))
replace weeks_in_labor_force = weeks_in_labor_force_prime if year==2015 & inrange(Interview_date,ym(2015,11),ym(2015,12))
replace Weeks_Employed_noID  = Weeks_Employed_noID_prime  if year==2015 & inrange(Interview_date,ym(2015,11),ym(2015,12))


* * * * * * * * * * * * * * * * * * * Need to adjust this for Job 13???

* Hand-code Job 11 information for year 2002 and ID 6337 (the only person to ever report 11 new jobs in one year)
capture noisily drop Hrs_week_Job11_
generat Hrs_week_Job11_ = .v
replace Hrs_week_Job11_ = .n if Hrs_week_Job10_==.n
replace Hrs_week_Job11_ = 40 if ID==6337 & year==2002

* Generate Job 1 ID
foreach x of numlist 1/53 {
    capture noisily drop Job1ID_Week`x'_
    qui gen Job1ID_Week`x'_ = Emp_Status_Week_`x'_ if inrange(Emp_Status_Week_`x'_,7,.)
}

* Create employer-week job array
forvalues x=1/53 {
    forvalues Y = 1/13 {
        qui gen byte employed_Job`Y'_week`x' = (Job1ID_Week`x'_==Emp`Y'_ID & ~mi(Job1ID_Week`x'_))
    }
}
* Get Weeks worked per job
forvalues Y=1/13 {
    gen byte weeks_employed_Job`Y' = 0
    forvalues x = 1/53 {
        qui replace weeks_employed_Job`Y' = weeks_employed_Job`Y' + (Job1ID_Week`x'_==Emp`Y'_ID & ~mi(Job1ID_Week`x'_))
    }
}
* Create Weekly Wage Array
forvalues x=1/53 {
    forvalues Y = 1/13 {
        qui generat wage_bill_week`x'_`Y' = Hrly_wage_Job`Y'_*employed_Job`Y'_week`x'*Hrs_week_Job`Y'_
        qui generat comp_bill_week`x'_`Y' = Hrly_comp_Job`Y'_*employed_Job`Y'_week`x'*Hrs_week_Job`Y'_
    }
}
forvalues x=1/53 {
    forvalues Y = 1/13 {
        qui generat total_hrs_week`x'_`Y' = employed_Job`Y'_week`x'*Hrs_week_Job`Y'_
    }
}
forvalues x=1/53 {
    egen wage_num_week`x' = rowtotal(wage_bill_week`x'_1 wage_bill_week`x'_2 wage_bill_week`x'_3 wage_bill_week`x'_4 wage_bill_week`x'_5 wage_bill_week`x'_6 wage_bill_week`x'_7 wage_bill_week`x'_8 wage_bill_week`x'_9 wage_bill_week`x'_10 wage_bill_week`x'_11 wage_bill_week`x'_12 wage_bill_week`x'_13), missing
    egen comp_num_week`x' = rowtotal(comp_bill_week`x'_1 comp_bill_week`x'_2 comp_bill_week`x'_3 comp_bill_week`x'_4 comp_bill_week`x'_5 comp_bill_week`x'_6 comp_bill_week`x'_7 comp_bill_week`x'_8 comp_bill_week`x'_9 comp_bill_week`x'_10 comp_bill_week`x'_11 comp_bill_week`x'_12 comp_bill_week`x'_13), missing
}
forvalues x=1/53 {
    egen wage_dem_week`x' = rowtotal(total_hrs_week`x'_1 total_hrs_week`x'_2 total_hrs_week`x'_3 total_hrs_week`x'_4 total_hrs_week`x'_5 total_hrs_week`x'_6 total_hrs_week`x'_7 total_hrs_week`x'_8 total_hrs_week`x'_9 total_hrs_week`x'_10 total_hrs_week`x'_11 wage_bill_week`x'_12 wage_bill_week`x'_13), missing
    egen comp_dem_week`x' = rowtotal(total_hrs_week`x'_1 total_hrs_week`x'_2 total_hrs_week`x'_3 total_hrs_week`x'_4 total_hrs_week`x'_5 total_hrs_week`x'_6 total_hrs_week`x'_7 total_hrs_week`x'_8 total_hrs_week`x'_9 total_hrs_week`x'_10 total_hrs_week`x'_11 comp_bill_week`x'_12 comp_bill_week`x'_13), missing
}
forvalues x=1/53 {
    gen wage_week`x' = wage_num_week`x'/wage_dem_week`x'
    gen comp_week`x' = comp_num_week`x'/comp_dem_week`x'
}

forvalues x=1/53 {
    gen wagerWeek`x'=.z
    gen comprWeek`x'=.z
    gen   occWeek`x'=.z
    gen   indWeek`x'=.z
    * First, rely on the job reported in 'Emp_Status_Week_X_'
    forvalues y = 1/13 {
        qui replace wagerWeek`x' = Hrly_wage_Job`y'_  if mi(wagerWeek`x') & ~mi(Hrly_wage_Job`y'_) & ~mi(Emp`y'_ID) & Emp_Status_Week_`x'_==Emp`y'_ID
        qui replace comprWeek`x' = Hrly_comp_Job`y'_  if mi(comprWeek`x') & ~mi(Hrly_comp_Job`y'_) & ~mi(Emp`y'_ID) & Emp_Status_Week_`x'_==Emp`y'_ID
        qui replace   occWeek`x' = Job`y'_Occupation  if mi(  occWeek`x') & ~mi(Job`y'_Occupation) & ~mi(Emp`y'_ID) & Emp_Status_Week_`x'_==Emp`y'_ID
        qui replace   indWeek`x' = Job`y'_Industry    if mi(  indWeek`x') & ~mi(Job`y'_Industry  ) & ~mi(Emp`y'_ID) & Emp_Status_Week_`x'_==Emp`y'_ID
    }
    * If there is no valid wage or job in that array, attempt to find any 
    *  other valid wage from the job_number2X-job_number5X arrays
    forvalues y = 1/13 {
        qui replace wagerWeek`x' = Hrly_wage_Job`y'_ if mi(wagerWeek`x') & ~mi(Hrly_wage_Job`y'_) & ~mi(Emp`y'_ID) & (Job2ID_Week`x'_==Emp`y'_ID | Job3ID_Week`x'_==Emp`y'_ID | Job4ID_Week`x'_==Emp`y'_ID | Job5ID_Week`x'_==Emp`y'_ID | Job6ID_Week`x'_==Emp`y'_ID | Job7ID_Week`x'_==Emp`y'_ID | Job8ID_Week`x'_==Emp`y'_ID )
        qui replace comprWeek`x' = Hrly_comp_Job`y'_ if mi(comprWeek`x') & ~mi(Hrly_comp_Job`y'_) & ~mi(Emp`y'_ID) & (Job2ID_Week`x'_==Emp`y'_ID | Job3ID_Week`x'_==Emp`y'_ID | Job4ID_Week`x'_==Emp`y'_ID | Job5ID_Week`x'_==Emp`y'_ID | Job6ID_Week`x'_==Emp`y'_ID | Job7ID_Week`x'_==Emp`y'_ID | Job8ID_Week`x'_==Emp`y'_ID )
        qui replace   occWeek`x' = Job`y'_Occupation if mi(  occWeek`x') & ~mi(Job`y'_Occupation) & ~mi(Emp`y'_ID) & (Job2ID_Week`x'_==Emp`y'_ID | Job3ID_Week`x'_==Emp`y'_ID | Job4ID_Week`x'_==Emp`y'_ID | Job5ID_Week`x'_==Emp`y'_ID | Job6ID_Week`x'_==Emp`y'_ID | Job7ID_Week`x'_==Emp`y'_ID | Job8ID_Week`x'_==Emp`y'_ID )
        qui replace   indWeek`x' = Job`y'_Industry   if mi(  indWeek`x') & ~mi(Job`y'_Industry  ) & ~mi(Emp`y'_ID) & (Job2ID_Week`x'_==Emp`y'_ID | Job3ID_Week`x'_==Emp`y'_ID | Job4ID_Week`x'_==Emp`y'_ID | Job5ID_Week`x'_==Emp`y'_ID | Job6ID_Week`x'_==Emp`y'_ID | Job7ID_Week`x'_==Emp`y'_ID | Job8ID_Week`x'_==Emp`y'_ID )
    }
}

drop wage_bill_week*
drop comp_bill_week*

egen mostWeeksEmployed = rowmax(weeks_employed_Job? weeks_employed_Job??)

/*-----------------------------------------*\
| Hours per week at various jobs            |
\*-----------------------------------------*/
egen total_hours_week           = rowtotal(Hrs_week_Job?_ Hrs_week_Job??_), missing
egen avg_hours_week_across_jobs = rowmean (Hrs_week_Job?_ Hrs_week_Job??_)

/*-----------------------------------------*\
| Hours per week for each year              |
\*-----------------------------------------*/
* main variable is CVC_HOURS_WK_YR_ALL -- total hours worked in the year across all jobs
egen    Hrs_worked_tot           = rowtotal(Hours_week1_ Hours_week2_ Hours_week3_ Hours_week4_ Hours_week5_ Hours_week6_ Hours_week7_ Hours_week8_ Hours_week9_ Hours_week10_ Hours_week11_ Hours_week12_ Hours_week13_ Hours_week14_ Hours_week15_ Hours_week16_ Hours_week17_ Hours_week18_ Hours_week19_ Hours_week20_ Hours_week21_ Hours_week22_ Hours_week23_ Hours_week24_ Hours_week25_ Hours_week26_ Hours_week27_ Hours_week28_ Hours_week29_ Hours_week30_ Hours_week31_ Hours_week32_ Hours_week33_ Hours_week34_ Hours_week35_ Hours_week36_ Hours_week37_ Hours_week38_ Hours_week39_ Hours_week40_ Hours_week41_ Hours_week42_ Hours_week43_ Hours_week44_ Hours_week45_ Hours_week46_ Hours_week47_ Hours_week48_ Hours_week49_ Hours_week50_ Hours_week51_ Hours_week52_ Hours_week53_)
qui gen Hrs_worked_tot_prime     = floor(52*(Hrs_worked_tot/potential_LF_weeks))     if year==2015 & inrange(Interview_date,ym(2015,11),ym(2015,12))
replace Hrs_worked_tot           = Hrs_worked_tot_prime                              if year==2015 & inrange(Interview_date,ym(2015,11),ym(2015,12))
generat Created_Hours_Worked     = Total_Hours_Worked                                                                                              // this creates an identical variable to the BLS-created annual hours worked for comparison purposes
qui gen Total_Hours_Worked_prime = floor(52*(Total_Hours_Worked/potential_LF_weeks)) if year==2015 & inrange(Interview_date,ym(2015,11),ym(2015,12))
replace Total_Hours_Worked       = Total_Hours_Worked_prime                          if year==2015 & inrange(Interview_date,ym(2015,11),ym(2015,12))
replace Total_Hours_Worked       = Hrs_worked_tot                                    if mi(Total_Hours_Worked) | Total_Hours_Worked==0              // replace the created annual hours worked with the sum of the reported weekly hours worked if the created one is missing
replace Total_Hours_Worked       = 5000                                              if Total_Hours_Worked>5000 & ~mi(Total_Hours_Worked)

* Annual Hours from weekly job and hours per week at job, using dual job info
gen annualHrsWrkCalcCalc = 0
forvalues Y = 1/13 {
    generat Hrs_week_alt_Job`Y'_ = Hrs_week_Job`Y'_
    replace Hrs_week_alt_Job`Y'_ = 0 if mi(Hrs_week_Job`Y'_)
    replace annualHrsWrkCalcCalc = annualHrsWrkCalcCalc + weeks_employed_Job`Y'*Hrs_week_alt_Job`Y'_
}

forvalues x = 1/53 {
    egen HrsWrkCalcCalc_week`x' = rowtotal(total_hrs_week`x'_1 total_hrs_week`x'_2 total_hrs_week`x'_3 total_hrs_week`x'_4 total_hrs_week`x'_5 total_hrs_week`x'_6 total_hrs_week`x'_7 total_hrs_week`x'_8 total_hrs_week`x'_9 total_hrs_week`x'_10 total_hrs_week`x'_11)
}

forvalues x = 1/53 {
    generat hours_week_use`x' = max(HrsWrkCalcCalc_week`x',Hours_week`x'_) if ~mi(Hours_week`x'_)
    replace hours_week_use`x' = HrsWrkCalcCalc_week`x'                     if  mi(Hours_week`x'_)
    replace hours_week_use`x' = 160                                        if inrange(hours_week_use`x',160,.)
}

generat annualHrsWrkUse = max(annualHrsWrkCalcCalc,Hrs_worked_tot,Created_Hours_Worked) if ~mi(Created_Hours_Worked)
replace annualHrsWrkUse = max(annualHrsWrkCalcCalc,Hrs_worked_tot)                      if  mi(Created_Hours_Worked)

generat Total_Hours_Worked_Old = Total_Hours_Worked
replace Total_Hours_Worked     = annualHrsWrkUse

genera Avg_hrs_worked = Total_Hours_Worked/weeks_employed
recode Avg_hrs_worked (. = 0)


/*-----------------------------------------*\
| Get the Primary Activity for each person  |
\*-----------------------------------------*/
lab def vlprimact 1 "School Only" 2 "School and PT" 3 "Part-Time Work" 4 "Full-Time Work" 5 "Military" 6 "Other Act." 7 "Miss Interview"

/*-------------------------*\
| Monthly stuff to get:     |
|                           |
| school enrollment status  |
| military participation    |
| weeks worked              |
| hours worked              |
| wage                      |
| graduation status         |
\*-------------------------*/
gen byte num_weeks_Jan = 4
gen byte num_weeks_Feb = 4
gen byte num_weeks_Mar = 5
gen byte num_weeks_Apr = 4
gen byte num_weeks_May = 5
gen byte num_weeks_Jun = 4
gen byte num_weeks_Jul = 5
gen byte num_weeks_Aug = 4
gen byte num_weeks_Sep = 4
gen byte num_weeks_Oct = 5
gen byte num_weeks_Nov = 4
gen byte num_weeks_Dec = 4
replace  num_weeks_Dec = 5 if inlist(year,1994,2000,2005,2011)

egen byte weeks_worked_Aug = rowtotal(Employed_Week_32 Employed_Week_33 Employed_Week_34 Employed_Week_35)
egen hours_worked_Aug      = rowtotal(hours_week_use32 hours_week_use33 hours_week_use34 hours_week_use35)
egen wageAug               = rowmean(wage_week32 wage_week33 wage_week34 wage_week35)
egen wageAltAug            = rowmean(wagerWeek32 wagerWeek33 wagerWeek34 wagerWeek35)
egen compAug               = rowmean(comp_week32 comp_week33 comp_week34 comp_week35)
egen compAltAug            = rowmean(comprWeek32 comprWeek33 comprWeek34 comprWeek35)
egen occAug                = rowfirst(occWeek32 occWeek33 occWeek34 occWeek35)
egen indAug                = rowfirst(indWeek32 indWeek33 indWeek34 indWeek35)

egen byte weeks_worked_Sep = rowtotal(Employed_Week_36 Employed_Week_37 Employed_Week_38 Employed_Week_39)
egen hours_worked_Sep      = rowtotal(hours_week_use36 hours_week_use37 hours_week_use38 hours_week_use39)
egen wageSep               = rowmean(wage_week36 wage_week37 wage_week38 wage_week39)
egen wageAltSep            = rowmean(wagerWeek36 wagerWeek37 wagerWeek38 wagerWeek39)
egen compSep               = rowmean(comp_week36 comp_week37 comp_week38 comp_week39)
egen compAltSep            = rowmean(comprWeek36 comprWeek37 comprWeek38 comprWeek39)
egen occSep                = rowfirst(occWeek36 occWeek37 occWeek38 occWeek39)
egen indSep                = rowfirst(indWeek36 indWeek37 indWeek38 indWeek39)

egen byte weeks_worked_Oct = rowtotal(Employed_Week_40 Employed_Week_41 Employed_Week_42 Employed_Week_43 Employed_Week_44)
egen hours_worked_Oct      = rowtotal(hours_week_use40 hours_week_use41 hours_week_use42 hours_week_use43 hours_week_use44)
egen wageOct               = rowmean(wage_week40 wage_week41 wage_week42 wage_week43 wage_week44)
egen wageAltOct            = rowmean(wagerWeek40 wagerWeek41 wagerWeek42 wagerWeek43 wagerWeek44)
egen compOct               = rowmean(comp_week40 comp_week41 comp_week42 comp_week43 comp_week44)
egen compAltOct            = rowmean(comprWeek40 comprWeek41 comprWeek42 comprWeek43 comprWeek44)
egen occOct                = rowfirst(occWeek40 occWeek41 occWeek42 occWeek43 occWeek44)
egen indOct                = rowfirst(indWeek40 indWeek41 indWeek42 indWeek43 indWeek44)

replace hours_worked_Oct = 500 if inrange(hours_worked_Oct,500,.)
generat avgHrsOct = hours_worked_Oct/weeks_worked_Oct

replace occAug = floor(occAug/10)
replace occSep = floor(occSep/10)
replace occOct = floor(occOct/10)

lab def vlocc3d 001 "Chief executives and legislators/public administration" 002 "General and Operations Managers" 003 "Managers in Marketing, Advertising, and Public Relations" 010 "Administrative Services Managers" 011 "Computer and Information Systems Managers" 012 "Financial Managers" 013 "Human Resources Managers" 014 "Industrial Production Managers" 015 "Purchasing Managers" 016 "Transportation, Storage, and Distribution Managers" 020 "Farmers, Ranchers, and Other Agricultural Managers" 022 "Constructions Managers" 023 "Education Administrators" 030 "Architectural and Engineering Managers" 031 "Food Service and Lodging Managers" 032 "Funeral Directors" 033 "Gaming Managers" 035 "Medical and Health Services Managers" 036 "Natural Science Managers" 041 "Property, Real Estate, and Community Association Managers" 042 "Social and Community Service Managers" 043 "Managers, nec (including Postmasters)" 050 "Agents and Business Managers of Artists, Performers, and Athletes" 051 "Buyers and Purchasing Agents, Farm Products" 052 "Wholesale and Retail Buyers, Except Farm Products" 053 "Purchasing Agents, Except Wholesale, Retail, and Farm Products" 054 "Claims Adjusters, Appraisers, Examiners, and Investigators" 056 "Compliance Officers, Except Agriculture" 060 "Cost Estimators" 062 "Human Resources, Training, and Labor Relations Specialists" 070 "Logisticians" 071 "Management Analysts" 072 "Meeting and Convention Planners" 073 "Other Business Operations and Management Specialists" 080 "Accountants and Auditors" 081 "Appraisers and Assessors of Real Estate" 082 "Budget Analysts" 083 "Credit Analysts" 084 "Financial Analysts" 085 "Personal Financial Advisors" 086 "Insurance Underwriters" 090 "Financial Examiners" 091 "Credit Counselors and Loan Officers" 093 "Tax Examiners and Collectors, and Revenue Agents" 094 "Tax Preparers" 095 "Financial Specialists, nec" 100 "Computer Scientists and Systems Analysts/Network systems Analysts/Web Developers" 101 "Computer Programmers" 102 "Software Developers, Applications and Systems Software" 105 "Computer Support Specialists" 106 "Database Administrators" 110 "Network and Computer Systems Administrators" 120 "Actuaries" 122 "Operations Research Analysts" 123 "Statisticians" 124 "Mathematical science occupations, nec" 130 "Architects, Except Naval" 131 "Surveyors, Cartographers, and Photogrammetrists" 132 "Aerospace Engineers" 135 "Chemical Engineers" 136 "Civil Engineers" 140 "Computer Hardware Engineers" 141 "Electrical and Electronics Engineers" 142 "Environmental Engineers" 143 "Industrial Engineers, including Health and Safety" 144 "Marine Engineers and Naval Architects" 145 "Materials Engineers" 146 "Mechanical Engineers" 152 "Petroleum, mining and geological engineers, including mining safety engineers" 153 "Engineers, nec" 154 "Drafters" 155 "Engineering Technicians, Except Drafters" 156 "Surveying and Mapping Technicians" 160 "Agricultural and Food Scientists" 161 "Biological Scientists" 164 "Conservation Scientists and Foresters" 165 "Medical Scientists, and Life Scientists, All Other" 170 "Astronomers and Physicists" 171 "Atmospheric and Space Scientists" 172 "Chemists and Materials Scientists" 174 "Environmental Scientists and Geoscientists" 176 "Physical Scientists, nec" 180 "Economists and market researchers" 182 "Psychologists" 183 "Urban and Regional Planners" 184 "Social Scientists, nec" 190 "Agricultural and Food Science Technicians" 191 "Biological Technicians" 192 "Chemical Technicians" 193 "Geological and Petroleum Technicians, and Nuclear Technicians" 196 "Life, Physical, and Social Science Technicians, nec" 198 "Professional, Research, or Technical Workers, nec" 200 "Counselors" 201 "Social Workers" 202 "Community and Social Service Specialists, nec" 204 "Clergy" 205 "Directors, Religious Activities and Education" 206 "Religious Workers, nec" 210 "Lawyers, and judges, magistrates, and other judicial workers" 214 "Paralegals and Legal Assistants" 215 "Legal Support Workers, nec" 220 "Postsecondary Teachers" 230 "Preschool and Kindergarten Teachers" 231 "Elementary and Middle School Teachers" 232 "Secondary School Teachers" 233 "Special Education Teachers" 234 "Other Teachers and Instructors" 240 "Archivists, Curators, and Museum Technicians" 243 "Librarians" 244 "Library Technicians" 254 "Teacher Assistants" 255 "Education, Training, and Library Workers, nec" 260 "Artists and Related Workers" 263 "Designers" 270 "Actors, Producers, and Directors" 272 "Athletes, Coaches, Umpires, and Related Workers" 274 "Dancers and Choreographers" 275 "Musicians, Singers, and Related Workers" 276 "Entertainers and Performers, Sports and Related Workers, All Other" 280 "Announcers" 281 "Editors, News Analysts, Reporters, and Correspondents" 282 "Public Relations Specialists" 284 "Technical Writers" 285 "Writers and Authors" 286 "Media and Communication Workers, nec" 290 "Broadcast and Sound Engineering Technicians and Radio Operators, and media and communication equipment workers, all other" 291 "Photographers" 292 "Television, Video, and Motion Picture Camera Operators and Editors" 300 "Chiropractors" 301 "Dentists" 303 "Dieticians and Nutritionists" 304 "Optometrists" 305 "Pharmacists" 306 "Physicians and Surgeons" 311 "Physician Assistants" 312 "Podiatrists" 313 "Registered Nurses" 314 "Audiologists" 315 "Occupational Therapists" 316 "Physical Therapists" 320 "Radiation Therapists" 321 "Recreational Therapists" 322 "Respiratory Therapists" 323 "Speech Language Pathologists" 324 "Therapists, nec" 325 "Veterinarians" 326 "Health Diagnosing and Treating Practitioners, nec" 330 "Clinical Laboratory Technologists and Technicians" 331 "Dental Hygienists" 332 "Diagnostic Related Technologists and Technicians" 340 "Emergency Medical Technicians and Paramedics" 341 "Health Diagnosing and Treating Practitioner Support Technicians" 350 "Licensed Practical and Licensed Vocational Nurses" 351 "Medical Records and Health Information Technicians" 352 "Opticians, Dispensing" 353 "Health Technologists and Technicians, nec" 354 "Healthcare Practitioners and Technical Occupations, nec" 360 "Nursing, Psychiatric, and Home Health Aides" 361 "Occupational Therapy Assistants and Aides" 362 "Physical Therapist Assistants and Aides" 363 "Massage Therapists" 364 "Dental Assistants" 365 "Medical Assistants and Other Healthcare Support Occupations, nec" 370 "First-Line Supervisors of Correctional Officers" 371 "First-Line Supervisors of Police and Detectives" 372 "First-Line Supervisors of Fire Fighting and Prevention Workers" 373 "Supervisors, Protective Service Workers, All Other" 374 "Firefighters" 375 "Fire Inspectors" 380 "Sheriffs, Bailiffs, Correctional Officers, and Jailers" 382 "Police Officers and Detectives" 390 "Animal Control" 391 "Private Detectives and Investigators" 393 "Security Guards and Gaming Surveillance Officers" 394 "Crossing Guards" 395 "Law enforcement workers, nec" 400 "Chefs and Cooks" 401 "First-Line Supervisors of Food Preparation and Serving Workers" 403 "Food Preparation Workers" 404 "Bartenders" 405 "Combined Food Preparation and Serving Workers, Including Fast Food" 406 "Counter Attendant, Cafeteria, Food Concession, and Coffee Shop" 411 "Waiters and Waitresses" 412 "Food Servers, Nonrestaurant" 413 "Food preparation and serving related workers, nec" 414 "Dishwashers" 415 "Host and Hostesses, Restaurant, Lounge, and Coffee Shop" 420 "First-Line Supervisors of Housekeeping and Janitorial Workers" 421 "First-Line Supervisors of Landscaping, Lawn Service, and Groundskeeping Workers" 422 "Janitors and Building Cleaners" 423 "Maids and Housekeeping Cleaners" 424 "Pest Control Workers" 425 "Grounds Maintenance Workers" 430 "First-Line Supervisors of Gaming Workers" 432 "First-Line Supervisors of Personal Service Workers" 434 "Animal Trainers" 435 "Nonfarm Animal Caretakers" 440 "Gaming Services Workers" 442 "Ushers, Lobby Attendants, and Ticket Takers" 443 "Entertainment Attendants and Related Workers, nec" 446 "Funeral Service Workers and Embalmers" 450 "Barbers" 451 "Hairdressers, Hairstylists, and Cosmetologists" 452 "Personal Appearance Workers, nec" 453 "Baggage Porters, Bellhops, and Concierges" 454 "Tour and Travel Guides" 460 "Childcare Workers" 461 "Personal Care Aides" 462 "Recreation and Fitness Workers" 464 "Residential Advisors" 465 "Personal Care and Service Workers, All Other" 470 "First-Line Supervisors of Sales Workers" 472 "Cashiers" 474 "Counter and Rental Clerks" 475 "Parts Salespersons" 476 "Retail Salespersons" 480 "Advertising Sales Agents" 481 "Insurance Sales Agents" 482 "Securities, Commodities, and Financial Services Sales Agents" 483 "Travel Agents" 484 "Sales Representatives, Services, All Other" 485 "Sales Representatives, Wholesale and Manufacturing" 490 "Models, Demonstrators, and Product Promoters" 492 "Real Estate Brokers and Sales Agents" 493 "Sales Engineers" 494 "Telemarketers" 495 "Sales and Related Workers" 500 "First-Line Supervisors of Office and Administrative Support Workers" 501 "Switchboard Operators, Including Answering Service" 502 "Telephone Operators" 503 "Communications Equipment Operators, All Other" 510 "Bill and Account Collectors" 511 "Billing and Posting Clerks" 512 "Bookkeeping, Accounting, and Auditing Clerks" 513 "Gaming Cage Workers" 514 "Payroll and Timekeeping Clerks" 515 "Procurement Clerks" 516 "Bank Tellers, Financial Clerks" 520 "Brokerage Clerks" 522 "Court, Municipal, and License Clerks" 523 "Credit Authorizers, Checkers, and Clerks" 524 "Customer Service Representatives" 525 "Eligibility Interviewers, Government Programs" 526 "File Clerks" 530 "Hotel, Motel, and Resort Desk Clerks" 531 "Interviewers, Except Eligibility and Loan" 532 "Library Assistants, Clerical" 533 "Loan Interviewers and Clerks" 534 "New Account Clerks" 535 "Correspondent clerks and order clerks" 536 "Human Resources Assistants, Except Payroll and Timekeeping" 540 "Receptionists and Information Clerks" 541 "Reservation and Transportation Ticket Agents and Travel Clerks" 542 "Information and Record Clerks, All Other" 550 "Cargo and Freight Agents" 551 "Couriers and Messengers" 552 "Dispatchers" 553 "Meter Readers, Utilities" 554 "Postal Service Clerks" 555 "Postal Service Mail Carriers" 556 "Postal Service Mail Sorters, Processors, and Processing Machine Operators" 560 "Production, Planning, and Expediting Clerks" 561 "Shipping, Receiving, and Traffic Clerks" 562 "Stock Clerks and Order Fillers" 563 "Weighers, Measurers, Checkers, and Samplers, Recordkeeping" 570 "Secretaries and Administrative Assistants" 580 "Computer Operators" 581 "Data Entry Keyers" 582 "Word Processors and Typists" 584 "Insurance Claims and Policy Processing Clerks" 585 "Mail Clerks and Mail Machine Operators, Except Postal Service" 586 "Office Clerks, General" 590 "Office Machine Operators, Except Computer" 591 "Proofreaders and Copy Markers" 592 "Statistical Assistants" 594 "Office and administrative support workers, nec" 600 "First-Line Supervisors of Farming, Fishing, and Forestry Workers" 601 "Agricultural Inspectors" 604 "Graders and Sorters, Agricultural Products" 605 "Agricultural workers, nec" 610 "Fishing and hunting workers" 612 "Forest and Conservation Workers" 613 "Logging Workers" 620 "First-Line Supervisors of Construction Trades and Extraction Workers" 621 "Boilermakers" 622 "Brickmasons, Blockmasons, and Stonemasons" 623 "Carpenters" 624 "Carpet, Floor, and Tile Installers and Finishers" 625 "Cement Masons, Concrete Finishers, and Terrazzo Workers" 626 "Construction Laborers" 630 "Paving, Surfacing, and Tamping Equipment Operators" 632 "Construction equipment operators except paving, surfacing, and tamping equipment operators" 633 "Drywall Installers, Ceiling Tile Installers, and Tapers" 635 "Electricians" 636 "Glaziers" 640 "Insulation Workers" 642 "Painters, Construction and Maintenance" 643 "Paperhangers" 644 "Pipelayers, Plumbers, Pipefitters, and Steamfitters" 646 "Plasterers and Stucco Masons" 650 "Reinforcing Iron and Rebar Workers" 651 "Roofers" 652 "Sheet Metal Workers, metal-working" 653 "Structural Iron and Steel Workers" 660 "Helpers, Construction Trades" 666 "Construction and Building Inspectors" 670 "Elevator Installers and Repairers" 671 "Fence Erectors" 672 "Hazardous Materials Removal Workers" 673 "Highway Maintenance Workers" 674 "Rail-Track Laying and Maintenance Equipment Operators" 676 "Construction workers, nec" 680 "Derrick, rotary drill, and service unit operators, and roustabouts, oil, gas, and mining" 682 "Earth Drillers, Except Oil and Gas" 683 "Explosives Workers, Ordnance Handling Experts, and Blasters" 684 "Mining Machine Operators" 694 "Extraction workers, nec" 700 "First-Line Supervisors of Mechanics, Installers, and Repairers" 701 "Computer, Automated Teller, and Office Machine Repairers" 702 "Radio and Telecommunications Equipment Installers and Repairers" 703 "Avionics Technicians" 704 "Electric Motor, Power Tool, and Related Repairers" 710 "Electrical and electronics repairers, transportation equipment, and industrial and utility" 711 "Electronic Equipment Installers and Repairers, Motor Vehicles" 712 "Electronic Home Entertainment Equipment Installers and Repairers" 713 "Security and Fire Alarm Systems Installers" 714 "Aircraft Mechanics and Service Technicians" 715 "Automotive Body and Related Repairers" 716 "Automotive Glass Installers and Repairers" 720 "Automotive Service Technicians and Mechanics" 721 "Bus and Truck Mechanics and Diesel Engine Specialists" 722 "Heavy Vehicle and Mobile Equipment Service Technicians and Mechanics" 724 "Small Engine Mechanics" 726 "Vehicle and Mobile Equipment Mechanics, Installers, and Repairers, nec" 730 "Control and Valve Installers and Repairers" 731 "Heating, Air Conditioning, and Refrigeration Mechanics and Installers" 732 "Home Appliance Repairers" 733 "Industrial and Refractory Machinery Mechanics" 734 "Maintenance and Repair Workers, General" 735 "Maintenance Workers, Machinery" 736 "Millwrights" 741 "Electrical Power-Line Installers and Repairers" 742 "Telecommunications Line Installers and Repairers" 743 "Precision Instrument and Equipment Repairers" 751 "Coin, Vending, and Amusement Machine Servicers and Repairers" 754 "Locksmiths and Safe Repairers" 755 "Manufactured Building and Mobile Home Installers" 756 "Riggers" 761 "Helpers--Installation, Maintenance, and Repair Workers" 763 "Other Installation, Maintenance, and Repair Workers Including Wind Turbine Service Technicians, and Commercial Divers, and Signal and Track Switch Repairers" 770 "First-Line Supervisors of Production and Operating Workers" 771 "Aircraft Structure, Surfaces, Rigging, and Systems Assemblers" 772 "Electrical, Electronics, and Electromechanical Assemblers" 773 "Engine and Other Machine Assemblers" 774 "Structural Metal Fabricators and Fitters" 775 "Assemblers and Fabricators, nec" 780 "Bakers" 781 "Butchers and Other Meat, Poultry, and Fish Processing Workers" 783 "Food and Tobacco Roasting, Baking, and Drying Machine Operators and Tenders" 784 "Food Batchmakers" 785 "Food Cooking and Processing Machine Operators and Tenders" 790 "Computer Control Programmers and Operators" 792 "Extruding and Drawing Machine Setters, Operators, and Tenders, Metal and Plastic" 793 "Forging Machine Setters, Operators, and Tenders, Metal and Plastic" 794 "Rolling Machine Setters, Operators, and Tenders, metal and Plastic" 795 "Cutting, Punching, and Press Machine Setters, Operators, and Tenders, Metal and Plastic" 796 "Drilling and Boring Machine Tool Setters, Operators, and Tenders, Metal and Plastic" 800 "Grinding, Lapping, Polishing, and Buffing Machine Tool Setters, Operators, and Tenders, Metal and Plastic" 801 "Lathe and Turning Machine Tool Setters, Operators, and Tenders, Metal and Plastic" 803 "Machinists" 804 "Metal Furnace Operators, Tenders, Pourers, and Casters" 806 "Model Makers and Patternmakers, Metal and Plastic" 810 "Molders and Molding Machine Setters, Operators, and Tenders, Metal and Plastic" 813 "Tool and Die Makers" 814 "Welding, Soldering, and Brazing Workers" 815 "Heat Treating Equipment Setters, Operators, and Tenders, Metal and Plastic" 820 "Plating and Coating Machine Setters, Operators, and Tenders, Metal and Plastic" 821 "Tool Grinders, Filers, and Sharpeners" 822 "Metal workers and plastic workers, nec" 823 "Bookbinders, Printing Machine Operators, and Job Printers" 825 "Prepress Technicians and Workers" 830 "Laundry and Dry-Cleaning Workers" 831 "Pressers, Textile, Garment, and Related Materials" 832 "Sewing Machine Operators" 833 "Shoe and Leather Workers and Repairers" 834 "Shoe Machine Operators and Tenders" 835 "Tailors, Dressmakers, and Sewers" 840 "Textile bleaching and dyeing, and cutting machine setters, operators, and tenders" 841 "Textile Knitting and Weaving Machine Setters, Operators, and Tenders" 842 "Textile Winding, Twisting, and Drawing Out Machine Setters, Operators, and Tenders" 845 "Upholsterers" 846 "Textile, Apparel, and Furnishings workers, nec" 850 "Cabinetmakers and Bench Carpenters" 851 "Furniture Finishers" 853 "Sawing Machine Setters, Operators, and Tenders, Wood" 854 "Woodworking Machine Setters, Operators, and Tenders, Except Sawing" 855 "Woodworkers including model makers and patternmakers, nec" 860 "Power Plant Operators, Distributors, and Dispatchers" 861 "Stationary Engineers and Boiler Operators" 862 "Water Wastewater Treatment Plant and System Operators" 863 "Plant and System Operators, nec" 864 "Chemical Processing Machine Setters, Operators, and Tenders" 865 "Crushing, Grinding, Polishing, Mixing, and Blending Workers" 871 "Cutting Workers" 872 "Extruding, Forming, Pressing, and Compacting Machine Setters, Operators, and Tenders" 873 "Furnace, Kiln, Oven, Drier, and Kettle Operators and Tenders" 874 "Inspectors, Testers, Sorters, Samplers, and Weighers" 875 "Jewelers and Precious Stone and Metal Workers" 876 "Medical, Dental, and Ophthalmic Laboratory Technicians" 880 "Packaging and Filling Machine Operators and Tenders" 881 "Painting Workers and Dyers" 883 "Photographic Process Workers and Processing Machine Operators" 885 "Adhesive Bonding Machine Operators and Tenders" 886 "Cleaning, Washing, and Metal Pickling Equipment Operators and Tenders" 891 "Etchers, Engravers, and Lithographers" 892 "Molders, Shapers, and Casters, Except Metal and Plastic" 893 "Paper Goods Machine Setters, Operators, and Tenders" 894 "Tire Builders" 895 "Helpers--Production Workers" 896 "Other production workers including semiconductor processors and cooling and freezing equipment operators" 900 "Supervisors of Transportation and Material Moving Workers" 903 "Aircraft Pilots and Flight Engineers" 904 "Air Traffic Controllers and Airfield Operations Specialists" 905 "Flight Attendants and Transportation Workers and Attendants" 910 "Bus and Ambulance Drivers and Attendants" 913 "Driver/Sales Workers and Truck Drivers" 914 "Taxi Drivers and Chauffeurs" 915 "Motor Vehicle Operators, All Other" 920 "Locomotive Engineers and Operators" 923 "Railroad Brake, Signal, and Switch Operators" 924 "Railroad Conductors and Yardmasters" 926 "Subway, Streetcar, and Other Rail Transportation Workers" 930 "Sailors and marine oilers, and ship engineers" 931 "Ship and Boat Captains and Operators" 935 "Parking Lot Attendants" 936 "Automotive and Watercraft Service Attendants" 941 "Transportation Inspectors" 942 "Transportation workers, nec" 951 "Crane and Tower Operators" 952 "Dredge, Excavating, and Loading Machine Operators" 956 "Conveyor operators and tenders, and hoist and winch operators" 960 "Industrial Truck and Tractor Operators" 961 "Cleaners of Vehicles and Equipment" 962 "Laborers and Freight, Stock, and Material Movers, Hand" 963 "Machine Feeders and Offbearers" 964 "Packers and Packagers, Hand" 965 "Pumping Station Operators" 972 "Refuse and Recyclable Material Collectors" 975 "Material moving workers, nec" 980 "Military Officer Special and Tactical Operations Leaders" 981 "First-Line Enlisted Military Supervisors" 982 "Military Enlisted Tactical Operations and Air/Weapons Specialists and Crew Members" 983 "Military, Rank Not Specified" 992 "Unemployed, with No Work Experience in the Last 5 Years or Earlier or Never Worked" 999 "Unknown"
lab val occAug vlocc3d
lab val occSep vlocc3d
lab val occOct vlocc3d

* recode occAug (. .a .i .n .d .r .v .z = 0)
* recode occSep (. .a .i .n .d .r .v .z = 0)
* recode occOct (. .a .i .n .d .r .v .z = 0)

/*----------------------------------------------------------*\
| Merge in blue collar occupation info from CPS              | 
\*----------------------------------------------------------*/
preserve
    tempfile cpsOccs
    use ${cpsloc}cps_occ_class18_65, clear
    clonevar whiteCollarAug = white_collar
    clonevar whiteCollarSep = white_collar
    clonevar whiteCollarOct = white_collar
    lab val occ2010_3d .
    clonevar occAug = occ2010_3d
    clonevar occSep = occ2010_3d
    clonevar occOct = occ2010_3d
    keep occ??? whiteCollar???
    save `cpsOccs', replace
restore

merge m:1 occAug using `cpsOccs', nogen keepusing(whiteCollarAug) keep(match master)
merge m:1 occSep using `cpsOccs', nogen keepusing(whiteCollarSep) keep(match master)
merge m:1 occOct using `cpsOccs',       keepusing(whiteCollarOct) keep(match master)
tab occOct if _merge==1, mi

/*----------------------------------------------------------*\
| Create the choice variable                                 | 
\*----------------------------------------------------------*/
capture drop flag1 flag2
gen flag1 = yofd(dofm(R1interviewDate)) ==1998
gen flag2 = yofd(dofm(R17interviewDate))==2016

* Create school, work, military and other dummies
gen byte workFT   = (weeks_worked_Oct>=4) & inrange(avgHrsOct,35,.)
gen byte workPT   = (weeks_worked_Oct>=4) & inrange(avgHrsOct,10,34.99)
gen byte workPTa  = (weeks_worked_Oct>=1) | hours_worked_Oct>=42
gen byte in_work  = workPT  | workFT
gen byte in_workA = workPTa | workFT
gen whiteCollar   = in_work & whiteCollarOct

* Label variables
lab var workFT      "WORKED FT"
lab var workPT      "WORKED PT"

* Create choice variable
gen int  choice15 = .
replace  choice15 = -2  if in_4yr==1 & (DKMajor==1 | missingMajor==1)
replace  choice15 = -1  if in_secondary_school==1
replace  choice15 = 1   if in_2yr==1 & workFT==1
replace  choice15 = 2   if in_2yr==1 & workPT==1
replace  choice15 = 3   if in_2yr==1 & workFT==0 & workPT==0
replace  choice15 = 4   if in_4yr==1 & scienceMajor==1 & workFT==1
replace  choice15 = 5   if in_4yr==1 & scienceMajor==1 & workPT==1
replace  choice15 = 6   if in_4yr==1 & scienceMajor==1 & workFT==0 & workPT==0
replace  choice15 = 7   if in_4yr==1 & otherMajor==1   & workFT==1
replace  choice15 = 8   if in_4yr==1 & otherMajor==1   & workPT==1
replace  choice15 = 9   if in_4yr==1 & otherMajor==1   & workFT==0 & workPT==0
replace  choice15 = 10  if workPT==1 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice15 = 11  if workFT==1 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice15 = 12  if workFT==0 & workPT==0 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice15 = 13  if in_grad_school==1 & workPT==1
replace  choice15 = 14  if in_grad_school==1 & workFT==1
replace  choice15 = 15  if in_grad_school==1 & workFT==0 & workPT==0

* Create choice variable with alternative major definition
gen int  choice15A = .
replace  choice15A = -2  if in_4yr==1 & (DKMajor==1 | missingMajor==1)
replace  choice15A = -1  if in_secondary_school==1
replace  choice15A = 1   if in_2yr==1 & workFT==1
replace  choice15A = 2   if in_2yr==1 & workPT==1
replace  choice15A = 3   if in_2yr==1 & workFT==0 & workPT==0
replace  choice15A = 4   if in_4yr==1 & scienceMajorA==1 & workFT==1
replace  choice15A = 5   if in_4yr==1 & scienceMajorA==1 & workPT==1
replace  choice15A = 6   if in_4yr==1 & scienceMajorA==1 & workFT==0 & workPT==0
replace  choice15A = 7   if in_4yr==1 & otherMajorA==1   & workFT==1
replace  choice15A = 8   if in_4yr==1 & otherMajorA==1   & workPT==1
replace  choice15A = 9   if in_4yr==1 & otherMajorA==1   & workFT==0 & workPT==0
replace  choice15A = 10  if workPT==1 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice15A = 11  if workFT==1 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice15A = 12  if workFT==0 & workPT==0 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice15A = 13  if in_grad_school==1 & workPT==1
replace  choice15A = 14  if in_grad_school==1 & workFT==1
replace  choice15A = 15  if in_grad_school==1 & workFT==0 & workPT==0

* Create choice variable with another alternative major definition
gen int  choice15B = .
replace  choice15B = -2  if in_4yr==1 & (DKMajor==1 | missingMajor==1)
replace  choice15B = -1  if in_secondary_school==1
replace  choice15B = 1   if in_2yr==1 & workFT==1
replace  choice15B = 2   if in_2yr==1 & workPT==1
replace  choice15B = 3   if in_2yr==1 & workFT==0 & workPT==0
replace  choice15B = 4   if in_4yr==1 & scienceMajorB==1 & workFT==1
replace  choice15B = 5   if in_4yr==1 & scienceMajorB==1 & workPT==1
replace  choice15B = 6   if in_4yr==1 & scienceMajorB==1 & workFT==0 & workPT==0
replace  choice15B = 7   if in_4yr==1 & otherMajorB==1   & workFT==1
replace  choice15B = 8   if in_4yr==1 & otherMajorB==1   & workPT==1
replace  choice15B = 9   if in_4yr==1 & otherMajorB==1   & workFT==0 & workPT==0
replace  choice15B = 10  if workPT==1 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice15B = 11  if workFT==1 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice15B = 12  if workFT==0 & workPT==0 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice15B = 13  if in_grad_school==1 & workPT==1
replace  choice15B = 14  if in_grad_school==1 & workFT==1
replace  choice15B = 15  if in_grad_school==1 & workFT==0 & workPT==0

lab def vl_choice15 -2 "Missing 4-year college major" -1 "Middle or HS" 1  "2yr & FT" 2  "2yr & PT" 3  "2yr & No Work"4  "4yr Science & FT" 5  "4yr Science & PT" 6  "4yr Science & No Work"7  "4yr Humanities & FT" 8  "4yr Humanities & PT" 9  "4yr Humanities & No Work"10 "Work PT only" 11 "Work FT only" 12 "Home"13 "Grad School & FT" 14 "Grad School & PT" 15 "Grad School & No Work"
lab var choice15 "Choice"
lab val choice15  vl_choice15
lab val choice15A vl_choice15
lab val choice15B vl_choice15

tab1 choice15* if inrange(year,1997,2015), mi
tab1 choice15* if inrange(year,1997,2015) & (missingMajor==1 | DKMajor==1), mi

gen Choice = choice15
recode Choice (-1 = 1) (1 2 3 = 2) (-2 4 5 6 7 8 9 = 3) (10 11 13 14 = 4) (12 15 = 5)

* Create alternative choice variable
gen int  choice25 = .
replace  choice25 = -2  if in_4yr==1 & (DKMajor==1 | missingMajor==1)
replace  choice25 = -1  if in_secondary_school==1
replace  choice25 = 1   if !whiteCollar & in_2yr==1 & workFT==1
replace  choice25 = 2   if  whiteCollar & in_2yr==1 & workFT==1
replace  choice25 = 3   if !whiteCollar & in_2yr==1 & workPT==1
replace  choice25 = 4   if  whiteCollar & in_2yr==1 & workPT==1
replace  choice25 = 5   if in_2yr==1 & workFT==0 & workPT==0
replace  choice25 = 6   if !whiteCollar & in_4yr==1 & scienceMajor==1 & workFT==1
replace  choice25 = 7   if  whiteCollar & in_4yr==1 & scienceMajor==1 & workFT==1
replace  choice25 = 8   if !whiteCollar & in_4yr==1 & scienceMajor==1 & workPT==1
replace  choice25 = 9   if  whiteCollar & in_4yr==1 & scienceMajor==1 & workPT==1
replace  choice25 = 10  if in_4yr==1 & scienceMajor==1 & workFT==0 & workPT==0
replace  choice25 = 11  if !whiteCollar & in_4yr==1 & otherMajor==1   & workFT==1
replace  choice25 = 12  if  whiteCollar & in_4yr==1 & otherMajor==1   & workFT==1
replace  choice25 = 13  if !whiteCollar & in_4yr==1 & otherMajor==1   & workPT==1
replace  choice25 = 14  if  whiteCollar & in_4yr==1 & otherMajor==1   & workPT==1
replace  choice25 = 15  if in_4yr==1 & otherMajor==1   & workFT==0 & workPT==0
replace  choice25 = 16  if !whiteCollar & workPT==1 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice25 = 17  if  whiteCollar & workPT==1 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice25 = 18  if !whiteCollar & workFT==1 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice25 = 19  if  whiteCollar & workFT==1 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice25 = 20  if workFT==0 & workPT==0 & in_2yr==0 & in_4yr==0 & in_secondary_school==0 & in_grad_school==0
replace  choice25 = 21  if !whiteCollar & in_grad_school==1 & workFT==1
replace  choice25 = 22  if  whiteCollar & in_grad_school==1 & workFT==1
replace  choice25 = 23  if !whiteCollar & in_grad_school==1 & workPT==1
replace  choice25 = 24  if  whiteCollar & in_grad_school==1 & workPT==1
replace  choice25 = 25  if in_grad_school==1 & workFT==0 & workPT==0

lab def vl_choice25 -2 "Missing 4-year college major" -1 "Middle or HS" 1  "2yr & FT, blue collar" 2  "2yr & FT, white collar" 3  "2yr & PT, blue collar" 4  "2yr & PT, white collar" 5  "2yr & No Work" 6  "4yr Science & FT, blue collar" 7  "4yr Science & FT, white collar" 8  "4yr Science & PT, blue collar" 9  "4yr Science & PT, white collar" 10 "4yr Science & No Work" 11 "4yr Humanities & FT, blue collar" 12 "4yr Humanities & FT, white collar" 13 "4yr Humanities & PT, blue collar" 14 "4yr Humanities & PT, white collar" 15 "4yr Humanities & No Work" 16 "Work PT, blue collar" 17 "Work PT, white collar" 18 "Work FT, blue collar" 19 "Work FT, white collar" 20 "Home" 21 "Grad School & FT, blue collar" 22 "Grad School & FT, white collar" 23 "Grad School & PT, blue collar" 24 "Grad School & PT, white collar" 25 "Grad School & No Work"
lab var choice25 "Choice" 
lab val choice25  vl_choice25

tab choice25, mi
