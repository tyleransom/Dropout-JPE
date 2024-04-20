clear all
version 15.1
set more off
capture log close

global data_loc "../../../data/sipp/raw/"
global here_loc "../../../src/data-cleaning/sipp/"

local idvars  id hhid ssuid epppnum shhadid
local demogs  esex erace eorigin rhcalyr rhcalmn eppintvw eeducate tage
local incvars thtotinc thtrninc
local taxvars itaxflyn itaxcopy tfilst ttotexmp ifilform tsapgain tadjincm tnettax iproptax ttaxbill
local asstvrs thhtnw thhtwlth thhtheq thhbeq thhdebt thhintbk thhintot thhira thhmortg thhore thhotast thhscdbt thhtheq thhthrif thhtnw thhtwlth thhvehcl 

/* VARIABLES OF INTEREST TO COMPUTE EFC:
thhbeqre  :Business Equity1116 -1125 
thhdebtre :Total debt recode 1196 -1205 
thhintbkre:Interest Earning assets held in banking institutions1126 -1135 
thhintotre:Interest Earning assets held in other Institutions1136 -1145 
thhirare  :Equity in IRA and KEOGH accounts1176 -1185 
thhmortgre:Total Debt owed on Home 1096 -1105 
thhorere  :Equity in real estate that is not your own home 1156 -1165 
thhotastre:Equity in other assets1166 -1175 
thhscdbtre:Total secured debt recode 1206 -1215 
thhtheqre :Home Equity recode 1086 -1095 
thhthrifre:Equity in 401K and Thrift savings accounts1186 -1195 
thhtnwre  :Total Net Worth Recode 1066 -1075 
thhtwlthre:Total Wealth recode 1076 -1085 
thhvehclre:Net equity in vehicles1106 -1115 
*/

/* THE FOLLOWING CODE IS TO REPRODUCE THE DTA FILES THAT ALREADY EXIST
cd ${data_loc}

capture log close
do wave3cr.do
clear all
capture log close
do wave4cr.do
clear all
capture log close
do wave3tm.do
clear all
capture log close
do wave4tm.do

clear all
capture log close

cd ${here_loc}

*/

log using create_sipp.log, replace

* Combine core and topic modules
use ${data_loc}/sippl04puw3.dta, clear
keep `idvars' `demogs' `incvars' srefmon ehrefper
merge m:1 ssuid epppnum using ${data_loc}/sippp04putm3.dta, keep(match master) nogen keepusing(`idvars' `asstvrs')
merge m:1 ssuid epppnum using ${data_loc}/sippp04putm4.dta, keep(match master) nogen keepusing(`idvars' `taxvars')

* Restrict to reference month
keep if srefmon==4

* Find head of HH
destring epppnum, force replace
gen head = ehrefper==epppnum

* Generate race variable
gen hispanic = (eorigin==1)
gen white = (erace == 1 & hispanic != 1)
gen black = (erace == 2 & hispanic != 1)
gen other = !hispanic & !white & !black

generat race = .
replace race=1 if white
replace race=2 if black
replace race=3 if hispanic
replace race=4 if other
lab def vlrace 1 "White" 2 "Black" 3 "Hispanic" 4 "Other"
lab val race vlrace

* Generate education variable
generat educlev = .
replace educlev = 1 if eeducate<=38
replace educlev = 2 if eeducate==39
replace educlev = 3 if inrange(eeducate,40,43)
replace educlev = 4 if inrange(eeducate,44,47)
lab def vleduc 1 "HS Dropout" 2 "HS Grad" 3 "Some College" 4 "BA or higher"
lab val educlev vleduc

* Convert monthly income to annual
replace thtotinc = 0 if thtotinc<=0
replace thtotinc = 12*thtotinc

* Identify households with teenagers
gen hasteenA = inrange(tage,15,18)
bys hhid: egen hasteen = mean(hasteenA)
gen hasTeen = hasteen>0
drop hasteenA hasteen

* Restrict only to household heads who have teenagers in home
keep if head & hasTeen

* Create assets that only contribute to EFC
sum thhintbk thhintot thhore thhotast thhvehcl, d

replace thhintbk = 0 if thhintbk < 0
replace thhintot = 0 if thhintot < 0
replace thhore   = 0 if thhore   < 0
replace thhotast = 0 if thhotast < 0
replace thhvehcl = 0 if thhvehcl < 0

sum thhintbk thhintot thhore thhotast thhvehcl, d

gen EFCassets = thhintbk+thhintot+thhore+thhotast+thhvehcl
gen netWorth = thhtnw
gen famInc = thtotinc

foreach var in EFCassets netWorth famInc {
    gen `var'000 = `var'/1000
}
gen netWorthM = netWorth/1000000

mdesc EFCassets000 thhintbk thhintot thhore thhotast thhvehcl
sum EFCassets000, d
sum famInc000, d
count
count if EFCassets000==0 & famInc000<=0
kdensity EFCassets000, graphregion(color(white))
// graph export EFCkdens.eps, replace
// graph export EFCkdens.pdf, replace

tab race educlev
tab race educlev, sum(EFCassets000) mean nofreq
tab race educlev, sum(netWorth000 ) mean nofreq
tab race educlev, sum(famInc000   ) mean nofreq

* Now estimate the imputation regression
gen lnEFCassets = log(EFCassets) if inrange(EFCassets,1,680000)
gen lnFamInc    = log(famInc)    if inrange(famInc,1,450000)
reg lnEFCassets c.netWorthM##c.netWorthM lnFamInc b1.race##b1.educlev
reg lnEFCassets b1.race##b1.educlev#(c.netWorth000##c.netWorth000 c.lnFamInc)

log close

