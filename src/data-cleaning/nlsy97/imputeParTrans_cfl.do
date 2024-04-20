local efcvarname efc_new
include recalculateEFC

corr efc efc_new if in_college

gen     recParTrans = inrange(rentParTransfer,1,.) | inrange(incParTransfer,1,.) if in_college
replace recParTrans = 0 if !in_college

gen     parTrans = rentParTransfer + incParTransfer if in_college & recParTrans
gen   lnParTrans = ln(parTrans) if !mi(parTrans)

gen     incParTrans = incParTransfer if in_college & recParTrans
gen   lnIncParTrans = ln(incParTrans) if !mi(incParTrans)

bys ID (year): gen sumRecParTrans = sum(l.recParTrans)
gen everRecParTrans = sumRecParTrans>0

sum famIncAsTeenEFC if in_college, d

gen infour = in_4yr
mdesc infour in_4yr
sum in_4yr

gen aged0 = age<=0
gen aged1 = age==1
gen aged2 = age==2
gen aged3 = age==3
gen aged4 = age==4
gen aged5 = age==5
gen aged6 = age==6
gen aged7 = age==7
gen agesq = age^2
qui replace agesq = -agesq if age<0

*logit recParTrans age c.famIncAsTeen##c.famIncAsTeen prev_4yr##c.famIncAsTeen   everRecParTrans black hispanic if in_college & ~anyFlag
*logit recParTrans age lnFamIncAsTeen                 prev_4yr##c.lnFamIncAsTeen everRecParTrans black hispanic if in_college & ~anyFlag
logit recParTrans aged?       lnFamIncAsTeen black hispanic b1984.birth_year Grades_HS_best Parent_college if in_4yr & ~anyFlag
est sto pt4logit6
logit recParTrans aged0-aged2 lnFamIncAsTeen black hispanic b1984.birth_year Grades_HS_best Parent_college if in_4yr & ~anyFlag
est sto pt4logit5
logit recParTrans age agesq   lnFamIncAsTeen black hispanic b1984.birth_year Grades_HS_best Parent_college if in_4yr & ~anyFlag
est sto pt4logit4
logit recParTrans age         lnFamIncAsTeen black hispanic b1984.birth_year Grades_HS_best Parent_college if in_4yr & ~anyFlag
est sto pt4logit3
logit recParTrans age agesq   lnFamIncAsTeen black hispanic                                                if in_4yr & ~anyFlag
est sto pt4logit2
logit recParTrans age         lnFamIncAsTeen black hispanic                                                if in_4yr & ~anyFlag
est sto pt4logit1
estimates use ${clnloc}prPT4.ster
predict prParTrans4, pr                                                        
logit recParTrans aged?       lnFamIncAsTeen black hispanic b1984.birth_year Grades_HS_best Parent_college if in_2yr & ~anyFlag
est sto pt2logit6
logit recParTrans aged0-aged2 lnFamIncAsTeen black hispanic b1984.birth_year Grades_HS_best Parent_college if in_2yr & ~anyFlag
est sto pt2logit5
logit recParTrans age agesq   lnFamIncAsTeen black hispanic b1984.birth_year Grades_HS_best Parent_college if in_2yr & ~anyFlag
est sto pt2logit4
logit recParTrans age         lnFamIncAsTeen black hispanic b1984.birth_year Grades_HS_best Parent_college if in_2yr & ~anyFlag
est sto pt2logit3
logit recParTrans age agesq   lnFamIncAsTeen black hispanic                                                if in_2yr & ~anyFlag
est sto pt2logit2
logit recParTrans age         lnFamIncAsTeen black hispanic                                                if in_2yr & ~anyFlag
est sto pt2logit1
estimates use ${clnloc}prPT2.ster
predict prParTrans2, pr
est table pt4logit1 pt4logit2 pt4logit3, b(%7.3f) star stats(N r2_p)
est table pt4logit4 pt4logit5 pt4logit6, b(%7.3f) star stats(N r2_p)
est table pt2logit1 pt2logit2 pt2logit3, b(%7.3f) star stats(N r2_p)
est table pt2logit4 pt2logit5 pt2logit6, b(%7.3f) star stats(N r2_p)


*reg lnParTrans age c.famIncAsTeen##c.famIncAsTeen b0.in_4yr##c.famIncAsTeen   cum_college black hispanic if in_college & recParTrans & ~anyFlag
*reg lnParTrans age lnFamIncAsTeen                 b0.in_4yr##c.lnFamIncAsTeen cum_college black hispanic if in_college & recParTrans & ~anyFlag
*reg lnParTrans age lnFamIncAsTeen                                             cum_college black hispanic if in_4yr     & recParTrans & ~anyFlag


reg lnParTrans aged?       lnFamIncAsTeen cum_college black hispanic b1984.birth_year Grades_HS_best Parent_college if in_2yr & recParTrans & ~anyFlag
est sto pt2reg6
reg lnParTrans aged0-aged2 lnFamIncAsTeen cum_college black hispanic b1984.birth_year Grades_HS_best Parent_college if in_2yr & recParTrans & ~anyFlag
est sto pt2reg5
reg lnParTrans age agesq   lnFamIncAsTeen cum_college black hispanic b1984.birth_year Grades_HS_best Parent_college if in_2yr & recParTrans & ~anyFlag
est sto pt2reg4
reg lnParTrans age         lnFamIncAsTeen cum_college black hispanic b1984.birth_year Grades_HS_best Parent_college if in_2yr & recParTrans & ~anyFlag
est sto pt2reg3
reg lnParTrans age agesq   lnFamIncAsTeen cum_college black hispanic                                                if in_2yr & recParTrans & ~anyFlag
est sto pt2reg2
reg lnParTrans age         lnFamIncAsTeen cum_college black hispanic                                                if in_2yr & recParTrans & ~anyFlag
est sto pt2reg1
estimates use ${clnloc}lnPT2.ster
predict lnParTransHat2, xb
scalar sig2lnPT2 = `=`e(rmse)'^2'
reg lnParTrans aged?       lnFamIncAsTeen cum_college black hispanic b1984.birth_year Grades_HS_best Parent_college if in_4yr & recParTrans & ~anyFlag
est sto pt4reg6
reg lnParTrans aged0-aged2 lnFamIncAsTeen cum_college black hispanic b1984.birth_year Grades_HS_best Parent_college if in_4yr & recParTrans & ~anyFlag
est sto pt4reg5
reg lnParTrans age agesq   lnFamIncAsTeen cum_college black hispanic b1984.birth_year Grades_HS_best Parent_college if in_4yr & recParTrans & ~anyFlag
est sto pt4reg4
reg lnParTrans age         lnFamIncAsTeen cum_college black hispanic b1984.birth_year Grades_HS_best Parent_college if in_4yr & recParTrans & ~anyFlag
est sto pt4reg3
reg lnParTrans age agesq   lnFamIncAsTeen cum_college black hispanic                                                if in_4yr & recParTrans & ~anyFlag
est sto pt4reg2
reg lnParTrans age         lnFamIncAsTeen cum_college black hispanic                                                if in_4yr & recParTrans & ~anyFlag
est sto pt4reg1
estimates use ${clnloc}lnPT4.ster
predict lnParTransHat4, xb
scalar sig2lnPT4 = `=`e(rmse)'^2'
di "sig2lnPT2:"
di "`=sig2lnPT2'"
gen ParTrans2RMSE = `=sqrt(`=sig2lnPT2')'
di "sig2lnPT4:"
di "`=sig2lnPT4'"
gen ParTrans4RMSE = `=sqrt(`=sig2lnPT4')'
est table pt4reg1 pt4reg2 pt4reg3, b(%7.3f) star stats(N r2 r2_a)
est table pt4reg4 pt4reg5 pt4reg6, b(%7.3f) star stats(N r2 r2_a)
est table pt2reg1 pt2reg2 pt2reg3, b(%7.3f) star stats(N r2 r2_a)
est table pt2reg4 pt2reg5 pt2reg6, b(%7.3f) star stats(N r2 r2_a)

* Now create expected parental transfers, using predicted values from logit and OLS models
gen E_ParTrans2 = prParTrans2*exp(lnParTransHat2 + `=`=sig2lnPT2'/2')
gen E_ParTrans4 = prParTrans4*exp(lnParTransHat4 + `=`=sig2lnPT4'/2')
sum E_ParTrans2 if in_2yr & ~anyFlag, d
sum E_ParTrans4 if in_4yr & ~anyFlag, d

local efcvars efc student_lag_income tax2_rate tax2_unmarried_0_ch famIncAsTeenEFC HHsize1997 HH_size_under_18_in_college assets_tot age_older_parent married
mdesc `efcvars' if in_4yr & ~anyFlag
mdesc `efcvars' if in_2yr & ~anyFlag

sum efc if in_4yr & ~anyFlag, d
sum efc if in_2yr & ~anyFlag, d

sum famIncAsTeenEFC if in_4yr & ~anyFlag, d
sum famIncAsTeenEFC if in_2yr & ~anyFlag, d

bys ID (year): egen efcmin = min(efc)
ren efc efc_varying
ren efcmin efc

*Now impute tuition paid, loans taken out, and grants taken out, using estimates from NPSAS
gen efc1_4yr = inrange(efc,    1,  312.99999999999999999999)
gen efc2_4yr = inrange(efc,  313, 2383.99999999999999999999)
gen efc3_4yr = inrange(efc, 2384, 5100.99999999999999999999)
gen efc4_4yr = inrange(efc, 5101, 8362.99999999999999999999)
gen efc5_4yr = inrange(efc, 8363,12206.99999999999999999999)
gen efc6_4yr = inrange(efc,12207,16890.99999999999999999999)
gen efc7_4yr = inrange(efc,16891,22899.99999999999999999999)
gen efc8_4yr = inrange(efc,22900,33023.99999999999999999999)
gen efc9_4yr = inrange(efc,33024,                         .)

gen efc1_2yr = inrange(efc,    1,  1328.9999999999999999999)
gen efc2_2yr = inrange(efc, 1329,  3001.9999999999999999999)
gen efc3_2yr = inrange(efc, 3002,  5334.9999999999999999999)
gen efc4_2yr = inrange(efc, 5335,  7913.9999999999999999999)
gen efc5_2yr = inrange(efc, 7914, 11480.9999999999999999999)
gen efc6_2yr = inrange(efc,11481, 15865.9999999999999999999)
gen efc7_2yr = inrange(efc,15866, 22904.9999999999999999999)
gen efc8_2yr = inrange(efc,22905,                         .)

gen finc1_4yr = inrange(famIncAsTeenEFC, 22363, 38061.999999999999999999999)
gen finc2_4yr = inrange(famIncAsTeenEFC, 38062, 52475.999999999999999999999)
gen finc3_4yr = inrange(famIncAsTeenEFC, 52476, 66438.999999999999999999999)
gen finc4_4yr = inrange(famIncAsTeenEFC, 66439, 79895.999999999999999999999)
gen finc5_4yr = inrange(famIncAsTeenEFC, 79896, 94098.999999999999999999999)
gen finc6_4yr = inrange(famIncAsTeenEFC, 94099,110000.999999999999999999999)
gen finc7_4yr = inrange(famIncAsTeenEFC,110001,130786.999999999999999999999)
gen finc8_4yr = inrange(famIncAsTeenEFC,130787,165785.999999999999999999999)
gen finc9_4yr = inrange(famIncAsTeenEFC,165786,                           .)

gen finc1_2yr = inrange(famIncAsTeenEFC, 17066, 27314.999999999999999999999)
gen finc2_2yr = inrange(famIncAsTeenEFC, 27315, 38114.999999999999999999999)
gen finc3_2yr = inrange(famIncAsTeenEFC, 38115, 47323.999999999999999999999)
gen finc4_2yr = inrange(famIncAsTeenEFC, 47324, 57202.999999999999999999999)
gen finc5_2yr = inrange(famIncAsTeenEFC, 57203, 68846.999999999999999999999)
gen finc6_2yr = inrange(famIncAsTeenEFC, 68847, 81644.999999999999999999999)
gen finc7_2yr = inrange(famIncAsTeenEFC, 81645, 98987.999999999999999999999)
gen finc8_2yr = inrange(famIncAsTeenEFC, 98988,121971.999999999999999999999)
gen finc9_2yr = inrange(famIncAsTeenEFC,121972,                           .)

gen binsatm1 = inrange(predSATmath,400,439.999999999999) if !mi(predSATmath)
gen binsatm2 = inrange(predSATmath,440,479.999999999999) if !mi(predSATmath)
gen binsatm3 = inrange(predSATmath,480,509.999999999999) if !mi(predSATmath)
gen binsatm4 = inrange(predSATmath,510,539.999999999999) if !mi(predSATmath)
gen binsatm5 = inrange(predSATmath,540,569.999999999999) if !mi(predSATmath)
gen binsatm6 = inrange(predSATmath,570,599.999999999999) if !mi(predSATmath)
gen binsatm7 = inrange(predSATmath,600,639.999999999999) if !mi(predSATmath)
gen binsatm8 = inrange(predSATmath,640,679.999999999999) if !mi(predSATmath)
gen binsatm9 = inrange(predSATmath,680,               .) if !mi(predSATmath)

gen binsatv1 = inrange(predSATverb,400,439.999999999999) if !mi(predSATverb)
gen binsatv2 = inrange(predSATverb,440,469.999999999999) if !mi(predSATverb)
gen binsatv3 = inrange(predSATverb,470,489.999999999999) if !mi(predSATverb)
gen binsatv4 = inrange(predSATverb,490,519.999999999999) if !mi(predSATverb)
gen binsatv5 = inrange(predSATverb,520,549.999999999999) if !mi(predSATverb)
gen binsatv6 = inrange(predSATverb,550,569.999999999999) if !mi(predSATverb)
gen binsatv7 = inrange(predSATverb,570,609.999999999999) if !mi(predSATverb)
gen binsatv8 = inrange(predSATverb,610,649.999999999999) if !mi(predSATverb)
gen binsatv9 = inrange(predSATverb,650,               .) if !mi(predSATverb)

mdesc predSAT* if in_4yr & ~anyFlag
generat tui4imp = 6394.2
generat tui2imp = 1380.1

generat loan4impPosRMSE = 7046.093725
generat grant4impPosRMSE = 5372.287396
generat loan2impPosRMSE = 2770.007032
generat grant2impPosRMSE = 1823.231748

//generat loansgr_imputed = .
//replace loansgr_imputed =  5564.119 - 0.101*efc - 0.008*famIncAsTeenEFC +  4.554*predSATmath  + 6.356*predSATverb if in_4yr
//replace loansgr_imputed =  1972.367 - 0.023*efc - 0.005*famIncAsTeenEFC                                           if in_2yr
//
//sum loansgr_imputed if in_4yr, d
//sum loansgr_imputed if in_2yr, d

generat loan4idx = -0.6208 + efc1_4yr*(0.4625) + efc2_4yr*(0.5111) + efc3_4yr*(0.7334) + efc4_4yr*(0.5507) + efc5_4yr*(0.2915) + efc6_4yr*(-0.1126) + efc7_4yr*(-0.4217) + efc8_4yr*(-0.689) + efc9_4yr*(-0.817) + finc1_4yr*(-0.1345) + finc2_4yr*(-0.3208) + finc3_4yr*(-0.241) + finc4_4yr*(-0.1494) + finc5_4yr*(-0.0228) + finc6_4yr*(-0.1543) + finc7_4yr*(-0.2055) + finc8_4yr*(-0.2181) + finc9_4yr*(-0.3824) + binsatm1*(-0.0532) + binsatm2*(-0.2262) + binsatm3*(-0.2544) + binsatm4*(-0.2163) + binsatm5*(-0.4274) + binsatm6*(-0.4064) + binsatm7*(-0.5548) + binsatm8*(-0.6377) + binsatm9*(-0.9401) + binsatv1*(0.1756) + binsatv2*(0.0941) + binsatv3*(0.0385) + binsatv4*(0.0451) + binsatv5*(0.0776) + binsatv6*(0.0771) + binsatv7*(0.0768) + binsatv8*(-0.0306) + binsatv9*(-0.2145) + 1.5329
generat loan2idx = -4.0384 + efc1_2yr*(0.2302) + efc2_2yr*(0.4052) + efc3_2yr*(1.0393) + efc4_2yr*(0.6441) + efc5_2yr*(0.5859) + efc6_2yr*(0.3178) + efc7_2yr*(0.2597) + efc8_2yr*(-0.0227) + finc1_2yr*(-0.1037) + finc2_2yr*(-0.4017) + finc3_2yr*(-0.3303) + finc4_2yr*(-0.3303) + finc5_2yr*(-0.3869) + finc6_2yr*(-0.2336) + finc7_2yr*(-0.0137) + finc8_2yr*(-0.159) + finc9_2yr*(-0.2304) + 2.1207

generat loan4pr  = exp(loan4idx)/(1+exp(loan4idx))
generat loan2pr  = exp(loan2idx)/(1+exp(loan2idx))

sum loan4pr if in_4yr & ~anyFlag, d
sum loan2pr if in_2yr & ~anyFlag, d

generat loan4impPos = 3167.3688 + efc1_4yr*(13.4083) + efc2_4yr*(279.6772) + efc3_4yr*(1810.6208) + efc4_4yr*(2265.9244) + efc5_4yr*(2447.0094) + efc6_4yr*(2372.4242) + efc7_4yr*(3141.1027) + efc8_4yr*(3074.3813) + efc9_4yr*(2111.8229) + finc1_4yr*(-123.4008) + finc2_4yr*(115.3869) + finc3_4yr*(418.1767) + finc4_4yr*(227.6036) + finc5_4yr*(631.8121) + finc6_4yr*(487.8596) + finc7_4yr*(916.5277) + finc8_4yr*(1454.7427) + finc9_4yr*(1776.1062) + binsatm1*(-135.1884) + binsatm2*(-84.6638) + binsatm3*(-551.3572) + binsatm4*(-427.1241) + binsatm5*(-423.7365) + binsatm6*(-666.2553) + binsatm7*(-262.0947) + binsatm8*(-681.6066) + binsatm9*(-1569.0931) + binsatv1*(175.8538) + binsatv2*(348.1326) + binsatv3*(35.9479) + binsatv4*(294.6957) + binsatv5*(-48.8518) + binsatv6*(16.1382) + binsatv7*(-288.6987) + binsatv8*(-477.0777) + binsatv9*(-897.8223) + 3004.9318
generat loan2impPos = 2929.9435 + efc1_2yr*(715.3761) + efc2_2yr*(173.0259) + efc3_2yr*(597.203) + efc4_2yr*(857.129) + efc5_2yr*(1249.8034) + efc6_2yr*(1024.8624) + efc7_2yr*(1249.758) + efc8_2yr*(1095.9268) + finc1_2yr*(-90.3268) + finc2_2yr*(-79.2131) + finc3_2yr*(-36.498) + finc4_2yr*(18.0709) + finc5_2yr*(-118.3996) + finc6_2yr*(-169.6658) + finc7_2yr*(-549.5066) + finc8_2yr*(-378.2811) + finc9_2yr*(-61.0912) + -4.3431

sum loan4impPos if in_4yr & ~anyFlag, d
sum loan2impPos if in_2yr & ~anyFlag, d

generat loan4imp = loan4impPos*loan4pr
generat loan2imp = loan2impPos*loan2pr

sum loan4imp if in_4yr & ~anyFlag, d
sum loan2imp if in_2yr & ~anyFlag, d

generat grant4idx = 0.7798 + efc1_4yr*(0.9321) + efc2_4yr*(0.6868) + efc3_4yr*(0.0292) + efc4_4yr*(-1.0251) + efc5_4yr*(-1.2971) + efc6_4yr*(-1.5743) + efc7_4yr*(-1.7771) + efc8_4yr*(-1.9483) + efc9_4yr*(-1.9558) + finc1_4yr*(-0.1975) + finc2_4yr*(-0.7559) + finc3_4yr*(-0.5065) + finc4_4yr*(-0.5827) + finc5_4yr*(-0.5214) + finc6_4yr*(-0.4863) + finc7_4yr*(-0.6878) + finc8_4yr*(-0.7863) + finc9_4yr*(-0.8146) + binsatm1*(0.0722) + binsatm2*(-0.026) + binsatm3*(0.0495) + binsatm4*(-0.0012) + binsatm5*(0.1179) + binsatm6*(0.1665) + binsatm7*(0.1797) + binsatm8*(0.1924) + binsatm9*(0.0723) + binsatv1*(-0.0644) + binsatv2*(0.0078) + binsatv3*(-0.0534) + binsatv4*(0.0828) + binsatv5*(0.1877) + binsatv6*(0.2402) + binsatv7*(0.2127) + binsatv8*(0.3817) + binsatv9*(0.3923) + 1.016
generat grant2idx = -0.2196 + efc1_2yr*(0.4438) + efc2_2yr*(-0.0491) + efc3_2yr*(-0.4656) + efc4_2yr*(-1.2203) + efc5_2yr*(-1.2743) + efc6_2yr*(-1.7325) + efc7_2yr*(-1.7391) + efc8_2yr*(-1.6104) + finc1_2yr*(-0.1786) + finc2_2yr*(-0.1578) + finc3_2yr*(-0.1935) + finc4_2yr*(-0.6507) + finc5_2yr*(-0.5761) + finc6_2yr*(-0.475) + finc7_2yr*(-0.5374) + finc8_2yr*(-0.5111) + finc9_2yr*(-0.7397) + 0.8013

generat grant4pr  = exp(grant4idx)/(1+exp(grant4idx))
generat grant2pr  = exp(grant2idx)/(1+exp(grant2idx))

sum grant4pr if in_4yr & ~anyFlag, d
sum grant2pr if in_2yr & ~anyFlag, d

generat grant4impPos = 4819.9277 + efc1_4yr*(-285.6587) + efc2_4yr*(-850.9437) + efc3_4yr*(-3206.715) + efc4_4yr*(-4319.5595) + efc5_4yr*(-4929.4486) + efc6_4yr*(-5681.987) + efc7_4yr*(-6241.8933) + efc8_4yr*(-6992.924) + efc9_4yr*(-7224.5194) + finc1_4yr*(302.0341) + finc2_4yr*(123.3267) + finc3_4yr*(274.0223) + finc4_4yr*(505.0647) + finc5_4yr*(757.4287) + finc6_4yr*(577.9029) + finc7_4yr*(678.0444) + finc8_4yr*(558.2155) + finc9_4yr*(663.8731) + binsatm1*(315.1831) + binsatm2*(592.9409) + binsatm3*(923.202) + binsatm4*(982.1282) + binsatm5*(997.5396) + binsatm6*(1280.5311) + binsatm7*(1191.6313) + binsatm8*(1736.448) + binsatm9*(1939.1151) + binsatv1*(94.4814) + binsatv2*(146.3205) + binsatv3*(608.1291) + binsatv4*(527.9978) + binsatv5*(526.2817) + binsatv6*(829.8153) + binsatv7*(830.2776) + binsatv8*(1577.6449) + binsatv9*(2208.0262) + 2282.7886
generat grant2impPos = 2134.5654 + efc1_2yr*(-292.1988) + efc2_2yr*(-1451.9079) + efc3_2yr*(-2076.2855) + efc4_2yr*(-2027.1858) + efc5_2yr*(-1859.2596) + efc6_2yr*(-1731.9758) + efc7_2yr*(-1784.4964) + efc8_2yr*(-1764.3874) + finc1_2yr*(248.3406) + finc2_2yr*(180.5374) + finc3_2yr*(-10.1507) + finc4_2yr*(40.8704) + finc5_2yr*(-217.682) + finc6_2yr*(-235.9044) + finc7_2yr*(-208.1524) + finc8_2yr*(-218.2376) + finc9_2yr*(-120.329) + 1043.9698

sum grant4impPos if in_4yr & ~anyFlag, d
sum grant2impPos if in_2yr & ~anyFlag, d

generat grant4imp = grant4impPos*grant4pr
generat grant2imp = grant2impPos*grant2pr

sum grant4imp if in_4yr & ~anyFlag, d
sum grant2imp if in_2yr & ~anyFlag, d

* Summary stats on E_ParTrans and net_cost_4yr, net_cost_2yr
sum E_ParTrans4 if in_4yr & ~anyFlag, d
sum E_ParTrans2 if in_2yr & ~anyFlag, d

sum efc if in_4yr & ~anyFlag, d
sum efc if in_2yr & ~anyFlag, d

gen loanPlusGrant4 = grant4imp + loan4imp
gen loanPlusGrant2 = grant2imp + loan2imp

sum loanPlusGrant4 if in_4yr & ~anyFlag, d
sum loanPlusGrant2 if in_2yr & ~anyFlag, d

gen oop4 = E_ParTrans4 - tui4imp + grant4imp + loan4imp
gen oop2 = E_ParTrans2 - tui2imp + grant2imp + loan2imp

reg lnParTrans    lnFamIncAsTeen if in_4yr & recParTrans & ~anyFlag
reg lnParTrans    lnFamIncAsTeen log_assets black hispanic if in_4yr & recParTrans & ~anyFlag
reg lnIncParTrans lnFamIncAsTeen if in_4yr & recParTrans & ~anyFlag
reg lnIncParTrans lnFamIncAsTeen log_assets black hispanic if in_4yr & recParTrans & ~anyFlag
reg efc           lnFamIncAsTeen log_assets black hispanic if in_4yr & ~anyFlag
reg oop4          lnFamIncAsTeen log_assets black hispanic if in_4yr & ~anyFlag

sum oop4 if in_4yr & ~anyFlag, d
sum oop2 if in_2yr & ~anyFlag, d

sum famIncAsTeen if in_4yr & oop4<0 & ~anyFlag, d
sum famIncAsTeen if in_2yr & oop2<0 & ~anyFlag, d

sum workPT if in_4yr & ~anyFlag
sum workFT if in_4yr & ~anyFlag

sum workPT if in_2yr & ~anyFlag
sum workPT if in_4yr & ~anyFlag

sum oop4 if in_4yr & workFT & ~anyFlag, d
sum oop4 if in_4yr & workPT & ~anyFlag, d
sum oop4 if in_4yr & !workFT & !workPT & ~anyFlag, d

sum oop2 if in_2yr & workFT & ~anyFlag, d
sum oop2 if in_2yr & workPT & ~anyFlag, d
sum oop2 if in_2yr & !workFT & !workPT & ~anyFlag, d



* AGE 18 DEBT REGRESSION
capture drop efc?_?yr finc?_?yr
*Now impute tuition paid, loans taken out, and grants taken out, using estimates from NPSAS
gen efc1_4yr = inrange(efc,    1,  312.99999999999999999999)
gen efc2_4yr = inrange(efc,  313, 2383.99999999999999999999)
gen efc3_4yr = inrange(efc, 2384, 5100.99999999999999999999)
gen efc4_4yr = inrange(efc, 5101, 8362.99999999999999999999)
gen efc5_4yr = inrange(efc, 8363,12206.99999999999999999999)
gen efc6_4yr = inrange(efc,12207,16890.99999999999999999999)
gen efc7_4yr = inrange(efc,16891,22899.99999999999999999999)
gen efc8_4yr = inrange(efc,22900,33023.99999999999999999999)
gen efc9_4yr = inrange(efc,33024,                         .)

gen efc1_2yr = inrange(efc,    1,  1328.9999999999999999999)
gen efc2_2yr = inrange(efc, 1329,  3001.9999999999999999999)
gen efc3_2yr = inrange(efc, 3002,  5334.9999999999999999999)
gen efc4_2yr = inrange(efc, 5335,  7913.9999999999999999999)
gen efc5_2yr = inrange(efc, 7914, 11480.9999999999999999999)
gen efc6_2yr = inrange(efc,11481, 15865.9999999999999999999)
gen efc7_2yr = inrange(efc,15866, 22904.9999999999999999999)
gen efc8_2yr = inrange(efc,22905,                         .)

gen finc1_4yr = inrange(famIncAsTeenEFC, 22363, 38061.999999999999999999999)
gen finc2_4yr = inrange(famIncAsTeenEFC, 38062, 52475.999999999999999999999)
gen finc3_4yr = inrange(famIncAsTeenEFC, 52476, 66438.999999999999999999999)
gen finc4_4yr = inrange(famIncAsTeenEFC, 66439, 79895.999999999999999999999)
gen finc5_4yr = inrange(famIncAsTeenEFC, 79896, 94098.999999999999999999999)
gen finc6_4yr = inrange(famIncAsTeenEFC, 94099,110000.999999999999999999999)
gen finc7_4yr = inrange(famIncAsTeenEFC,110001,130786.999999999999999999999)
gen finc8_4yr = inrange(famIncAsTeenEFC,130787,165785.999999999999999999999)
gen finc9_4yr = inrange(famIncAsTeenEFC,165786,                           .)

gen finc1_2yr = inrange(famIncAsTeenEFC, 17066, 27314.999999999999999999999)
gen finc2_2yr = inrange(famIncAsTeenEFC, 27315, 38114.999999999999999999999)
gen finc3_2yr = inrange(famIncAsTeenEFC, 38115, 47323.999999999999999999999)
gen finc4_2yr = inrange(famIncAsTeenEFC, 47324, 57202.999999999999999999999)
gen finc5_2yr = inrange(famIncAsTeenEFC, 57203, 68846.999999999999999999999)
gen finc6_2yr = inrange(famIncAsTeenEFC, 68847, 81644.999999999999999999999)
gen finc7_2yr = inrange(famIncAsTeenEFC, 81645, 98987.999999999999999999999)
gen finc8_2yr = inrange(famIncAsTeenEFC, 98988,121971.999999999999999999999)
gen finc9_2yr = inrange(famIncAsTeenEFC,121972,                           .)

generat loan18_4impPosRMSE = 7291.563690
generat loan18_2impPosRMSE = 2778.862690

generat loan18_4idx = -1.0004 + efc1_4yr*(0.6095) + efc2_4yr*(0.7745) + efc3_4yr*(0.628) + efc4_4yr*(0.8591) + efc5_4yr*(0.2808) + efc6_4yr*(-0.307) + efc7_4yr*(-0.586) + efc8_4yr*(-1.0725) + efc9_4yr*(-1.3246) + finc1_4yr*(-0.1968) + finc2_4yr*(-0.2036) + finc3_4yr*(-0.1725) + finc4_4yr*(0.0511) + finc5_4yr*(0.3845) + finc6_4yr*(0.0622) + finc7_4yr*(0.4301) + finc8_4yr*(0.3277) + finc9_4yr*(0.1961) + binsatm1*(-0.0516) + binsatm2*(-0.2625) + binsatm3*(-0.2363) + binsatm4*(-0.104) + binsatm5*(-0.183) + binsatm6*(-0.1864) + binsatm7*(-0.4072) + binsatm8*(-0.7692) + binsatm9*(-0.4968) + binsatv1*(0.0808) + binsatv2*(-0.1152) + binsatv3*(-0.2122) + binsatv4*(-0.3021) + binsatv5*(-0.1043) + binsatv6*(-0.2253) + binsatv7*(-0.2626) + binsatv8*(-0.6712) + binsatv9*(-0.4753) + 1.9293
generat loan18_2idx = -11.4222 + efc1_2yr*(0.0035) + efc2_2yr*(0.4992) + efc3_2yr*(0.781) + efc4_2yr*(0.3748) + efc5_2yr*(-0.1215) + efc6_2yr*(-0.1735) + efc7_2yr*(-0.7727) + efc8_2yr*(-1.4242) + finc1_2yr*(0.114) + finc2_2yr*(-0.1131) + finc3_2yr*(-0.2419) + finc4_2yr*(0.3067) + finc5_2yr*(0.2528) + finc6_2yr*(0.7436) + finc7_2yr*(0.5606) + finc8_2yr*(1.0144) + finc9_2yr*(0.8824) + 9.6392

generat loan18_4pr  = exp(loan18_4idx)/(1+exp(loan18_4idx))
generat loan18_2pr  = exp(loan18_2idx)/(1+exp(loan18_2idx))

sum loan18_4pr if in_4yr & ~anyFlag, d
sum loan18_2pr if in_2yr & ~anyFlag, d



generat loan18_4impPos = 3014.8787 + efc1_4yr*(478.3708) + efc2_4yr*(979.6938) + efc3_4yr*(2668.3326) + efc4_4yr*(2678.5941) + efc5_4yr*(3209.4493) + efc6_4yr*(3810.4078) + efc7_4yr*(3343.4367) + efc8_4yr*(3324.6752) + efc9_4yr*(1696.1917) + finc1_4yr*(-260.9732) + finc2_4yr*(-382.595) + finc3_4yr*(24.6798) + finc4_4yr*(-778.0996) + finc5_4yr*(158.8361) + finc6_4yr*(-189.8691) + finc7_4yr*(580.5521) + finc8_4yr*(2363.6766) + finc9_4yr*(1223.3394) + binsatm1*(-871.7511) + binsatm2*(-633.1251) + binsatm3*(-1646.5809) + binsatm4*(-615.5127) + binsatm5*(-655.5934) + binsatm6*(-31.417) + binsatm7*(-1459.2514) + binsatm8*(-842.1835) + binsatm9*(-1891.2) + binsatv1*(1176.398) + binsatv2*(701.6157) + binsatv3*(217.8979) + binsatv4*(595.525) + binsatv5*(534.8639) + binsatv6*(364.2473) + binsatv7*(-365.7138) + binsatv8*(-1093.6581) + binsatv9*(-1469.3204) + 2805.8850

* aggregate some 2yr bins since there were cell size issues
replace efc1_2yr = inrange(efc,    1,  1328.9999999999999999999)
replace efc2_2yr = inrange(efc, 1329,  3001.9999999999999999999)
replace efc3_2yr = inrange(efc, 3002,  5334.9999999999999999999)
replace efc4_2yr = inrange(efc, 5335,  7913.9999999999999999999)
replace efc5_2yr = inrange(efc, 7914, 11480.9999999999999999999)
replace efc6_2yr = inrange(efc,11481, 15865.9999999999999999999)
replace efc7_2yr = inrange(efc,15866,                         .)
replace finc1_2yr = inrange(famIncAsTeenEFC, 27315, 38114.999999999999999999999)
replace finc2_2yr = inrange(famIncAsTeenEFC, 38115, 57202.999999999999999999999)
replace finc3_2yr = inrange(famIncAsTeenEFC, 57203, 68846.999999999999999999999)
replace finc4_2yr = inrange(famIncAsTeenEFC, 68847, 81644.999999999999999999999)
replace finc5_2yr = inrange(famIncAsTeenEFC, 81645, 98987.999999999999999999999)
replace finc6_2yr = inrange(famIncAsTeenEFC, 98988,                           .)
generat loan18_2impPos = 1967.0377 + efc1_2yr*(-366.3647) + efc2_2yr*(-458.3262) + efc3_2yr*(335.7275) + efc4_2yr*(-298.8623) + efc5_2yr*(684.4434) + efc6_2yr*(207.3959) + efc7_2yr*(1029.1805) +  finc1_2yr*(586.6354) + finc2_2yr*(235.9855) + finc3_2yr*(47.1963) + finc4_2yr*(750.4633) + finc5_2yr*(279.0236) + finc6_2yr*(-698.8392) + 576.9154


sum loan18_4impPos if in_4yr & ~anyFlag, d
sum loan18_2impPos if in_2yr & ~anyFlag, d

generat loan18_4imp = loan18_4impPos*loan18_4pr
generat loan18_2imp = loan18_2impPos*loan18_2pr

sum loan18_4imp if in_4yr & ~anyFlag, d
sum loan18_2imp if in_2yr & ~anyFlag, d

*=================================================
* Generate accumulated debt
*=================================================
gen accum_debt_in2yr = 0
gen accum_debt_in4yr = 0
gen accum_debt_nosch = 0

bys ID (year): replace accum_debt_in2yr = cum_2yr*loan18_2imp+cum_4yr*loan18_4imp+in_2yr*loan18_2imp if ~anyFlag
bys ID (year): replace accum_debt_in4yr = cum_2yr*loan18_2imp+cum_4yr*loan18_4imp+in_4yr*loan18_4imp if ~anyFlag
bys ID (year): replace accum_debt_nosch = cum_2yr*loan18_2imp+cum_4yr*loan18_4imp                    if ~anyFlag

sum accum_d* if in_2yr & cum_2yr==0 & cum_4yr==0 & ~anyFlag
sum accum_d* if in_4yr & cum_4yr==0 & cum_2yr==0 & ~anyFlag
sum accum_d* if ~in_2yr & ~in_4yr & cum_2yr==0 & cum_4yr==0 & ~anyFlag

sum accum_d* if in_2yr & cum_2yr==1 & cum_4yr==0 & ~anyFlag
sum accum_d* if in_4yr & cum_4yr==1 & cum_2yr==0 & ~anyFlag
sum accum_d* if ~in_2yr & ~in_4yr & cum_2yr==0 & cum_4yr==1 & ~anyFlag

/*
gen accum_debt_in2yr = 0
gen accum_debt_in4yr = 0
gen accum_debt_nosch = 0

bys ID (year): replace accum_debt_in2yr = sum(L.in_2yr*loan18_2imp+L.in_4yr*loan18_4imp)+in_2yr*loan18_2imp if ~anyFlag
bys ID (year): replace accum_debt_in4yr = sum(L.in_2yr*loan18_2imp+L.in_4yr*loan18_4imp)+in_4yr*loan18_4imp if ~anyFlag
bys ID (year): replace accum_debt_nosch = sum(L.in_2yr*loan18_2imp+L.in_4yr*loan18_4imp)                    if ~anyFlag

sum accum_d* if in_2yr & cum_2yr==0 & cum_4yr==0 & ~anyFlag
sum accum_d* if in_4yr & cum_4yr==0 & cum_2yr==0 & ~anyFlag
sum accum_d* if ~in_2yr & ~in_4yr & cum_2yr==0 & cum_4yr==0 & ~anyFlag

sum accum_d* if in_2yr & cum_2yr==1 & cum_4yr==0 & ~anyFlag
sum accum_d* if in_4yr & cum_4yr==1 & cum_2yr==0 & ~anyFlag
sum accum_d* if ~in_2yr & ~in_4yr & cum_2yr==0 & cum_4yr==1 & ~anyFlag
*/

