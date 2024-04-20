function output = create_estimatemeas_data(measdata,A,S)

    v2struct(measdata);

    % Data for each equation of the measurement system
    Xm = [ones(length(black),1) black hispanic birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 Parent_college famInc];
    Xml = cat(2,kron(ones(S,1),Xm),kron(A,ones(size(Xm,1),1)));


    %--------------------------------------------------------------------------
    % Estimate schooling ability measures
    %--------------------------------------------------------------------------
    flagAR = ~isnan(asvabAR) & inSample;
    flagARl= logical(kron(ones(S,1),flagAR));
    asvabARl = kron(ones(S,1),asvabAR);

    flagCS = ~isnan(asvabCS) & inSample;
    flagCSl= logical(kron(ones(S,1),flagCS));
    asvabCSl = kron(ones(S,1),asvabCS);

    flagMK = ~isnan(asvabMK) & inSample;
    flagMKl= logical(kron(ones(S,1),flagMK));
    asvabMKl = kron(ones(S,1),asvabMK);

    flagNO = ~isnan(asvabNO) & inSample;
    flagNOl= logical(kron(ones(S,1),flagNO));
    asvabNOl = kron(ones(S,1),asvabNO);

    flagPC = ~isnan(asvabPC) & inSample;
    flagPCl= logical(kron(ones(S,1),flagPC));
    asvabPCl = kron(ones(S,1),asvabPC);

    flagWK = ~isnan(asvabWK) & inSample;
    flagWKl= logical(kron(ones(S,1),flagWK));
    asvabWKl = kron(ones(S,1),asvabWK);

    flagSATm = ~isnan(SATmath) & inSample;
    flagSATml= logical(kron(ones(S,1),flagSATm));
    SATml    = kron(ones(S,1),SATmath);

    flagSATv = ~isnan(SATverb) & inSample;
    flagSATvl= logical(kron(ones(S,1),flagSATv));
    SATvl    = kron(ones(S,1),SATverb);


    %--------------------------------------------------------------------------
    % Estimate schooling ability/preference measures
    %--------------------------------------------------------------------------
    % number of AP tests
    flagAP = ~isnan(numAPs) & inSample;
    flagAPl= logical(kron(ones(S,1),flagAP));
    yAPl   = kron(ones(S,1),numAPs);

    % number of times late for school without excuse
    flagLS = ~isnan(lateForSchoolNoExcuse) & inSample;
    flagLSl= logical(kron(ones(S,1),flagLS));
    yLSl   = kron(ones(S,1),lateForSchoolNoExcuse);

    % break rules regularly
    flagBR = ~isnan(breakRulesRegularly) & inSample;
    flagBRl= logical(kron(ones(S,1),flagBR));
    yBRl   = kron(ones(S,1),breakRulesRegularly);

    % took extra classes (tobit)
    flagEC = ~isnan(R1ExtraClass) & inSample;
    WEC    = miHrsExtraClass; 
    flagECl= logical(kron(ones(S,1),flagEC));
    yECl   = kron(ones(S,1),R1ExtraClass);
    HECl   = kron(ones(S,1),HrsExtraClass);
    WECl   = kron(ones(S,1),WEC);

    % took classes during break
    flagTB = ~isnan(tookClassDuringBreak) & inSample;
    flagTBl= logical(kron(ones(S,1),flagTB));
    yTBl   = kron(ones(S,1),2-tookClassDuringBreak);

    % reason took classes during break
    flagRTB = ~isnan(reasonTookClassDuringBreak) & inSample;
    flagRTBl= logical(kron(ones(S,1),flagRTB));
    yRTBl   = kron(ones(S,1),reasonTookClassDuringBreak);


    %--------------------------------------------------------------------------
    % Estimate work ability/preference measures
    %--------------------------------------------------------------------------
    % high standards at work
    flagHS = ~isnan(highStandardsWork) & inSample;
    flagHSl= logical(kron(ones(S,1),flagHS));
    yHSl   = kron(ones(S,1),highStandardsWork);

    % do what is expected
    flagDE = ~isnan(doMoreThanExpected) & inSample;
    flagDEl= logical(kron(ones(S,1),flagDE));
    yDEl   = kron(ones(S,1),doMoreThanExpected);

    % percent chance work 20+ hours per week at age 30 (youth's assessment)
    flagPWY = ~isnan(pctChanceWork20Hrs30) & inSample;
    flagPWYl= logical(kron(ones(S,1),flagPWY));
    yPWYl   = kron(ones(S,1),pctChanceWork20Hrs30);

    % percent chance work 20+ hours per week at age 30 (parent's assessment)
    flagPWP = ~isnan(parPctChanceWork20Hrs30) & inSample;
    flagPWPl= logical(kron(ones(S,1),flagPWP));
    yPWPl   = kron(ones(S,1),parPctChanceWork20Hrs30);

    output = v2struct(N,Xml,flagARl,asvabARl,flagCSl,asvabCSl,flagMKl,asvabMKl,flagPCl,asvabPCl,flagNOl,asvabNOl,flagWKl,asvabWKl,flagSATml,SATml,flagSATvl,SATvl,yAPl,flagAPl,yLSl,flagLSl,yBRl,flagBRl,yECl,flagECl,HECl,WECl,yTBl,flagTBl,yRTBl,flagRTBl,yHSl,flagHSl,yDEl,flagDEl,yPWYl,flagPWYl,yPWPl,flagPWPl);
end
