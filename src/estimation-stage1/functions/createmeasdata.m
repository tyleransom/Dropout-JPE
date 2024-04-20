function [measData] = createmeasdata(fname)
    %% Load data and adjust things
    year = [];
    load(fname)
    [N,T] = size(anyFlag);
    inSample = any(anyFlag==0,2);
    inSample(ID==2863) = 0;
    assert(sum(inSample)==2300,'Problem with sample selection')

    %% Make time-invariant versions of background characteristics for use in measurement system
    birthYr  = 1979-age(:,1);
    famInc   = FamIncAsTeen./10;

    %% Make usable categories for discrete measurement outcomes
    numAPs1  = 1*(numAPs==0) + 2*(numAPs==1) + 3*(numAPs>=2);
    numAPs1(isnan(numAPs)) = NaN;
    numAPs   = numAPs1;

    lateNoExcuse1  = 1*(lateForSchoolNoExcuse==0) + 2*(lateForSchoolNoExcuse==1) + 3*(lateForSchoolNoExcuse==2) + 4*(lateForSchoolNoExcuse==3) + 5*(lateForSchoolNoExcuse==4) + 6*(lateForSchoolNoExcuse==5) + 7*(lateForSchoolNoExcuse>=6 & lateForSchoolNoExcuse<=10) + 8*(lateForSchoolNoExcuse>=11);
    lateNoExcuse1(isnan(lateForSchoolNoExcuse)) = NaN;
    lateForSchoolNoExcuse = lateNoExcuse1;

    miHrsExtraClass = isnan(HrsExtraClass);
    HrsExtraClass(HrsExtraClass==0) = 0.1;
    HrsExtraClass(R1ExtraClass==0) = -100;
    HrsExtraClass(R1ExtraClass==1 & isnan(HrsExtraClass)) = -10;
    lnHrsExtraClass = log(HrsExtraClass);

    reasonTookClassDuringBreak1 = 1*ismember(reasonTookClassDuringBreak,[1,3,4]) + 2*ismember(reasonTookClassDuringBreak,[2,5,6,7]);
    reasonTookClassDuringBreak1(isnan(reasonTookClassDuringBreak)) = NaN;
    reasonTookClassDuringBreak  = reasonTookClassDuringBreak1;

    pctWork1  = 1*(pctChanceWork20Hrs30<=75) + 2*(pctChanceWork20Hrs30>75 & pctChanceWork20Hrs30<=90) + 3*(pctChanceWork20Hrs30>90);
    pctWork1(isnan(pctChanceWork20Hrs30)) = NaN;
    pctChanceWork20Hrs30 = pctWork1;

    parPctWork1  = 1*(parPctChanceWork20Hrs30<=75) + 2*(parPctChanceWork20Hrs30>75 & parPctChanceWork20Hrs30<=90) + 3*(parPctChanceWork20Hrs30>90);
    parPctWork1(isnan(parPctChanceWork20Hrs30)) = NaN;
    parPctChanceWork20Hrs30 = parPctWork1;

    measData = v2struct(N, T, ID, black, hispanic, birthYr, Parent_college, famInc, asvabAR, asvabCS, asvabMK, asvabNO, asvabPC, asvabWK, SATmath, SATverb, numAPs, lateForSchoolNoExcuse, breakRulesRegularly, R1ExtraClass, R1WeekdaysExtraClass, miHrsExtraClass, HrsExtraClass, lnHrsExtraClass, tookClassDuringBreak, reasonTookClassDuringBreak, highStandardsWork, doMoreThanExpected, pctChanceWork20Hrs30, parPctChanceWork20Hrs30, inSample);
end
