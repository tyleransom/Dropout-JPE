clear all
version 13.0
set more off
capture log close
log using "y97_import_all.log", replace
set maxvar 32767
set matsize 11000

**********************************************************
* Import and save the data (either to file or to tempfile)
**********************************************************

global rawloc ../../../data/nlsy97/raw/
global others 1
global college 0


if ${others}==1 {
    * HS transcripts
    do y97_import_HStranscript.do
    sort ID
    tempfile holder0
    save `holder0', replace
    compress
    save ${rawloc}y97_HStranscript_raw.dta, replace
    
    * Demographics
    do y97_import_demographics.do
    sort ID year
    tempfile holder1
    save `holder1', replace
    compress
    save ${rawloc}y97_demographics_raw.dta, replace

    * School
    do y97_import_school.do
    sort ID year
    tempfile holder2
    save `holder2', replace
    compress
    save ${rawloc}y97_school_raw.dta, replace

    * Work
    do y97_import_work.do
    sort ID year
    tempfile holder3
    save `holder3', replace
    compress
    save ${rawloc}y97_work_raw.dta, replace

    * College transcripts
    do y97_import_college_transcript.do
    sort ID year
    tempfile holder4
    save `holder4', replace
    compress
    save ${rawloc}y97_college_transcript_raw.dta, replace
}
else {
    tempfile holder0
    use ${rawloc}y97_HStranscript_raw.dta, clear
    save `holder0', replace

    tempfile holder1
    use ${rawloc}y97_demographics_raw.dta, clear
    save `holder1', replace

    tempfile holder2
    use ${rawloc}y97_school_raw.dta, clear
    save `holder2', replace

    tempfile holder3
    use ${rawloc}y97_work_raw.dta, clear
    save `holder3', replace

    tempfile holder4
    use ${rawloc}y97_college_transcript_raw.dta, clear
    save `holder4', replace
}

if ${college}==1 {
    * College
    do y97_import_college.do
    sort ID year
    tempfile holder5
    save `holder5', replace
    compress
    save ${rawloc}y97_college_raw.dta, replace
}
else {
    tempfile holder5
    use ${rawloc}y97_college_raw.dta, clear
    save `holder5', replace
}
***********************************
* Merge and save the data
***********************************

use `holder1', clear

merge m:1 ID using `holder0'
assert _merge==3
drop _merge

merge 1:1 ID year using `holder2'
assert _merge==3
drop _merge

merge 1:1 ID year using `holder3'
assert _merge==3
drop _merge

merge 1:1 ID year using `holder4'
assert _merge==3
drop _merge

if "`holder5'"!="" {
    merge 1:1 ID year using `holder5'
    assert _merge==3
    drop _merge
}

capture drop R0536300 R0536401 R0536402 R1235800 R1482600 // multiply-imported demographic variables

* Merge in ASVAB age-adjusted scores from Altonji, Bharadwaj, and Lange (2009)
merge     m:1 ID using ${rawloc}AFQT_MATCHING/afqt_adjusted_final97, keepusing(ID afqt_std)
assert    _merge!=2
drop      _merge
merge     m:1 ID using ${rawloc}AFQT_MATCHING_MATH/afqt_adjusted_final97, keepusing(ID asvabMath_std)
assert    _merge!=2
drop      _merge
merge     m:1 ID using ${rawloc}AFQT_MATCHING_MATH_NOT_NO/afqt_adjusted_final97, keepusing(ID asvabMathNotNO_std)
assert    _merge!=2
drop      _merge
merge     m:1 ID using ${rawloc}AFQT_MATCHING_VERB/afqt_adjusted_final97, keepusing(ID asvabVerb_std)
assert    _merge!=2
drop      _merge
merge     m:1 ID using ${rawloc}AFQT_MATCHING_AR/afqt_adjusted_final97, keepusing(ID asvabAR_std)
assert    _merge!=2
drop      _merge
merge     m:1 ID using ${rawloc}AFQT_MATCHING_CS/afqt_adjusted_final97, keepusing(ID asvabCS_std)
assert    _merge!=2
drop      _merge
merge     m:1 ID using ${rawloc}AFQT_MATCHING_MK/afqt_adjusted_final97, keepusing(ID asvabMK_std)
assert    _merge!=2
drop      _merge
merge     m:1 ID using ${rawloc}AFQT_MATCHING_NO/afqt_adjusted_final97, keepusing(ID asvabNO_std)
assert    _merge!=2
drop      _merge
merge     m:1 ID using ${rawloc}AFQT_MATCHING_PC/afqt_adjusted_final97, keepusing(ID asvabPC_std)
assert    _merge!=2
drop      _merge
merge     m:1 ID using ${rawloc}AFQT_MATCHING_WK/afqt_adjusted_final97, keepusing(ID asvabWK_std)
assert    _merge!=2
drop      _merge

compress
save ${rawloc}y97_raw.dta, replace

log close
