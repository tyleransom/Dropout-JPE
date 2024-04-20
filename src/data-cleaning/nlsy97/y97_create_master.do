version 13.0
clear all
set more off
capture log close

log using "y97_create_master.log", replace

**************************************************
* Create all permanent variables and save all data
**************************************************

global rawloc ../../../data/nlsy97/raw/
global cpsloc ../../../data/cps/cleaned/
use ${rawloc}y97_raw.dta

xtset ID year
* Bring in CPI and min_wage
do cpi_min_wage.do

* Create age, foreignBorn, race, sex, family background measures, missed interview history, etc.
do y97_create_demographics.do

* No need to create HS transcript variables, this is done in y97_create_demographics

* Create schooling variables
do y97_create_school.do

* No need to create college transcript variables, this is done in y97_import_college_transcript

* Create college variables
do y97_create_college.do

* Create primary activity variables and wages
do y97_create_work.do

sort ID year
compress
save ${rawloc}y97_master.dta, replace

log close
