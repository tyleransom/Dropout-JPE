*-------------------------------------
* Generate date Graduated High School 
*-------------------------------------
genera Diploma_date = 239+Months_to_HS_diploma
genera GED_date     = 239+Months_to_GED

format GED_date     %tm
format Diploma_date %tm
label  variable Diploma_date "Date received HS Diploma"
label  variable GED_date     "Date received GED"

gen Diploma_year = 1960+floor(Diploma_date/12)
gen GED_year     = 1960+floor(GED_date/12)

generat HS_date = min(Diploma_date,GED_date)
replace HS_date = Diploma_date if ~mi(Diploma_date) &  mi(GED_date)
replace HS_date = GED_date     if  mi(Diploma_date) & ~mi(GED_date)

format  HS_date %tm
label   variable HS_date "Date received HS Diploma OR GED (or earliest one if both)"

gen HS_year = 1960+floor(HS_date/12)

* Do I need these lines of code???
* gen first_int_missed_range = First_year_missed_int-Diploma_year
* gen last_int_missed_range = Last_year_missed_int-Diploma_year

*------------------------------------------
* Generate date received degree variables  
*------------------------------------------
genera BA_date   = 239+Months_to_BA_degree
genera AA_date   = 239+Months_to_AA_degree
genera Prof_date = 239+Months_to_Prof_degree
genera PhD_date  = 239+Months_to_PhD_degree
genera MA_date   = 239+Months_to_MA_degree

generat Grad_date = min(MA_date,Prof_date,PhD_date)
replace Grad_date = min(MA_date,Prof_date         ) if ~mi(MA_date) & ~mi(Prof_date) &  mi(PhD_date)
replace Grad_date = min(MA_date          ,PhD_date) if ~mi(MA_date) &  mi(Prof_date) & ~mi(PhD_date)
replace Grad_date = min(        Prof_date,PhD_date) if  mi(MA_date) & ~mi(Prof_date) & ~mi(PhD_date)
replace Grad_date = MA_date                         if ~mi(MA_date) &  mi(Prof_date) &  mi(PhD_date)
replace Grad_date = Prof_date                       if  mi(MA_date) & ~mi(Prof_date) &  mi(PhD_date)
replace Grad_date = PhD_date                        if  mi(MA_date) &  mi(Prof_date) & ~mi(PhD_date)

format Grad_date %tm
format BA_date   %tm
format AA_date   %tm
format Prof_date %tm
format PhD_date  %tm
format MA_date   %tm
label variable Grad_date "Date received Graduate Degree (or earliest of graduate degrees if multiple)"
label variable age       "Age (in years) on Jan 1, 1997"
label variable BA_date   "Date received BA degree"
label variable AA_date   "Date received AA degree"
label variable MA_date   "Date received MA degree"
label variable PhD_date  "Date received PhD degree"
label variable Prof_date "Date received Professional degree"

gener BA_year   = floor(BA_date/12+1960)
gener AA_year   = floor(AA_date/12+1960)
gener PhD_year  = floor(PhD_date/12+1960)
gener MA_year   = floor(MA_date/12+1960)
gener Prof_year = floor(Prof_date/12+1960)
gener Grad_year = floor(Grad_date/12+1960)
label variable AA_year   "Year received AA degree"
label variable BA_year   "Year received BA degree"
label variable MA_year   "Year received MA degree"
label variable Prof_year "Year received Prof degree"
label variable PhD_year  "Year received PhD degree"
label variable Grad_year "Year received 1st advanced (graduate) degree"

format BA_date %10.0g
format AA_date %10.0g

gen BA_month      = mod(BA_date,12)+1
gen AA_month      = mod(AA_date,12)+1
gen GED_month     = mod(GED_date,12)+1
gen Diploma_month = mod(Diploma_date,12)+1
gen HS_month      = mod(HS_date,12)+1
gen PhD_month     = mod(PhD_date,12)+1
gen MA_month      = mod(MA_date,12)+1
gen Prof_month    = mod(Prof_date,12)+1
gen Grad_month    = mod(Grad_date,12)+1

format BA_date %tm
format AA_date %tm

drop Months_to_BA_degree Months_to_AA_degree Months_to_MA_degree Months_to_Prof_degree Months_to_PhD_degree Months_to_HS_diploma

do BA_impute // this file imputes BA date for those who reported receiving a BA or higher, but who didn't report a specific date

* Anyone who reports concurrent enrollment in HS and college is assumed to be only in HS
foreach x in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec {
	replace College_enrollment_`x' = 1 if School_Enrollment_Status_`x'==2 & inlist(College_enrollment_`x',2,3)
}

*-------------------------------------------------------------
* Get the Schooling Status for each person in October
*-------------------------------------------------------------
gen in_secondary_school = School_Enrollment_Status_Oct==2
gen in_2yr              = College_enrollment_Oct==2
gen in_4yr              = College_enrollment_Oct==3
gen in_college          = in_2yr | in_4yr
gen in_grad_school      = College_enrollment_Oct==4

*-------------------------------------------------------------
* Get schooling "experience"
*-------------------------------------------------------------
bys ID (year): gen colexper = sum(L.in_college)

*-------------------------------------------------------------
* Get flag for HS dropout status (to be dropped later)
*-------------------------------------------------------------
gen HS_dropout = Highest_degree_ever_cum==0 | (mi(Highest_degree_ever_cum) & mi(HS_date))

*-------------------------------------------------------
* Absorbing indicators for attainment of various degrees 
*-------------------------------------------------------
bys ID (year): gen grad_Graduate = (mdy(11,1,year)>=dofm(Grad_date   ))
bys ID (year): gen grad_4yr      = (mdy(11,1,year)>=dofm(BA_date     ))
bys ID (year): gen grad_2yr      = (mdy(11,1,year)>=dofm(AA_date     ))
bys ID (year): gen grad_Diploma  = (mdy(11,1,year)>=dofm(Diploma_date))
bys ID (year): gen grad_GED      = (mdy(11,1,year)>=dofm(GED_date    ))
bys ID (year): gen grad_HS       = (mdy(11,1,year)>=dofm(HS_date     ))

bys ID (year): replace grad_Graduate = 0 if year==2016 & grad_Graduate[_n-1]==0
bys ID (year): replace grad_4yr      = 0 if year==2016 & grad_4yr[_n-1]==0
bys ID (year): replace grad_2yr      = 0 if year==2016 & grad_2yr[_n-1]==0
bys ID (year): replace grad_Diploma  = 0 if year==2016 & grad_Diploma[_n-1]==0
bys ID (year): replace grad_GED      = 0 if year==2016 & grad_GED[_n-1]==0
bys ID (year): replace grad_HS       = 0 if year==2016 & grad_HS[_n-1]==0

*-------------------------------------------------------
* Anyone who reports college graduation but never reports
* college enrollment should not be a college graduate
* 5 IDs: 133, 380, 598, 2848, 8072
* [to get these IDs, type tab ID if grad_4yr==1 & colexper==0]
*-------------------------------------------------------
replace grad_4yr = 0 if inlist(ID,133,380,598,2848,8072)
replace BA_date  = . if inlist(ID,133,380,598,2848,8072)
replace BA_year  = . if inlist(ID,133,380,598,2848,8072)
replace BA_month = . if inlist(ID,133,380,598,2848,8072)

*-------------------------------------------------------
* Indicators for ever attaining certain degrees
*-------------------------------------------------------
bys ID (year): egen ever_grad_Graduate = max(grad_Graduate)
bys ID (year): egen ever_grad_4yr      = max(grad_4yr     )
bys ID (year): egen ever_grad_2yr      = max(grad_2yr     )
bys ID (year): egen ever_grad_Diploma  = max(grad_Diploma )
bys ID (year): egen ever_grad_GED      = max(grad_GED     )
bys ID (year): egen ever_grad_HS       = max(grad_HS      )

bys ID (year): egen ever_start_grad    = max(in_grad_school)
bys ID (year): egen ever_start_4yr     = max(in_4yr        )
bys ID (year): egen ever_start_2yr     = max(in_2yr        )
bys ID (year): egen ever_start_college = max(in_college    )
