* Import, rename, reshape, recode and label the demographic variables

infile using ${rawloc}y97_HStranscript.dct, clear

****************
* Rename
****************

ren R0000100 ID

ren R9788600 SpecialEd
ren R9788700 BilingualEd
ren R9788800 GiftedEd
ren R9792900 transcriptGPAseniorYr
ren R9793000 classRankSeniorYr
ren R9793100 classSizeSeniorYr
ren R9793200 transcriptPSATmath
ren R9793300 transcriptPSATverb
ren R9793400 transcriptACT
ren R9793500 transcriptACTengl
ren R9793600 transcriptACTmath
ren R9793700 transcriptACTread
ren R9793800 transcriptSATverb
ren R9793900 transcriptSATmath
ren R9794100 transcriptAPbio
ren R9794200 transcriptAPcalc
ren R9794300 transcriptAPchem
ren R9794400 transcriptAPeng
ren R9794500 transcriptAPhistEU
ren R9794600 transcriptAPgovt
ren R9794700 transcriptAPphysics
ren R9794800 transcriptAPpsych
ren R9794900 transcriptAPspanish
ren R9795000 transcriptAPhistUS
ren R9795100 transcriptSAT2bio
ren R9795200 transcriptSAT2math1
ren R9795300 transcriptSAT2math2
ren R9795400 transcriptSAT2chem
ren R9795500 transcriptSAT2engLit
ren R9795600 transcriptSAT2engWrite
ren R9795700 transcriptSAT2histUS
ren R9795800 transcriptSAT2histWorld
ren R9795900 transcriptNumOthAPscoreEq1
ren R9796000 transcriptNumOthAPscoreEq2
ren R9796100 transcriptNumOthAPscoreEq3
ren R9796200 transcriptNumOthAPscoreEq4
ren R9796300 transcriptNumOthAPscoreEq5
ren R9796400 transcriptNumOthSAT2score200_400
ren R9796500 transcriptNumOthSAT2score401_500
ren R9796600 transcriptNumOthSAT2score501_600
ren R9796700 transcriptNumOthSAT2score601_700
ren R9796800 transcriptNumOthSAT2score701_800
ren R9831300 transcriptAPart
ren R9831400 transcriptAPcompSci
ren R9831500 transcriptAPecon
ren R9831600 transcriptAPintlEng
ren R9831700 transcriptAPstats
ren R9831800 transcriptSAT2physics
ren R9831900 transcriptSAT2spanish
ren R9871900 transcriptGPAoverall
ren R9872000 transcriptGPAenglish
ren R9872100 transcriptGPAforeignLang
ren R9872200 transcriptGPAmath
ren R9872300 transcriptGPAsocSci
ren R9872400 transcriptGPAsci
ren R9872500 transcriptHasProblem

* List variables that didn't get renamed
capture d ????????

***************************************************
* Recode certain variables.
***************************************************

recode _all (-1 = .r) (-2 = .d) (-3 = .i) (-4 = .v) (-5 = .n) (-6 = .w) (-7 = .x) (-8 = .y) (-9 = .z)

***************************************************
* Set to missing all variables for which transcript is problematic
***************************************************
foreach var in SpecialEd BilingualEd GiftedEd transcriptGPAseniorYr classRankSeniorYr classSizeSeniorYr transcriptPSATmath transcriptPSATverb transcriptACT transcriptACTengl transcriptACTmath transcriptACTread transcriptSATverb transcriptSATmath transcriptAPbio transcriptAPcalc transcriptAPchem transcriptAPeng transcriptAPhistEU transcriptAPgovt transcriptAPphysics transcriptAPpsych transcriptAPspanish transcriptAPhistUS transcriptSAT2bio transcriptSAT2math1 transcriptSAT2math2 transcriptSAT2chem transcriptSAT2engLit transcriptSAT2engWrite transcriptSAT2histUS transcriptSAT2histWorld transcriptNumOthAPscoreEq1 transcriptNumOthAPscoreEq2 transcriptNumOthAPscoreEq3 transcriptNumOthAPscoreEq4 transcriptNumOthAPscoreEq5 transcriptNumOthSAT2score200_400 transcriptNumOthSAT2score401_500 transcriptNumOthSAT2score501_600 transcriptNumOthSAT2score601_700 transcriptNumOthSAT2score701_800 transcriptAPart transcriptAPcompSci transcriptAPecon transcriptAPintlEng transcriptAPstats transcriptSAT2physics transcriptSAT2spanish transcriptGPAoverall transcriptGPAenglish transcriptGPAforeignLang transcriptGPAmath transcriptGPAsocSci transcriptGPAsci {
    qui replace `var' = .v if transcriptHasProblem==1
}

***************************************************
* Clean up outlandish ACT scores
***************************************************
foreach var in transcriptACT transcriptACTengl transcriptACTmath transcriptACTread {
    replace `var' = 36 if inrange(`var',36,.)
    replace `var' = 1  if inrange(`var',0,1)
}

***************************************************
* Label variables and values
***************************************************
label var ID                          "ID"

label define vlsize      1 "1-100" 2 "101-220" 3 "221-330" 4 "331-470" 5 "470+   "
label values classSizeSeniorYr vlsize

order ID 
