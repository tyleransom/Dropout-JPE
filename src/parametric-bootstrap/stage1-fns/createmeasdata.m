function [measData] = createmeasdata(data,parms,A,S)
    %---------------------------------------------------------------------------
    % initial conditions
    %---------------------------------------------------------------------------
    black          = data.black;
    hispanic       = data.hispanic;
    birthYr        = 1980*data.born1980 + 1981*data.born1981+ 1982*data.born1982 + 1983*data.born1983 + 1984*(1-data.born1980-data.born1981-data.born1982-data.born1983);
    Parent_college = data.Parent_college;
    famInc         = data.famInc;
    X = [ones(length(black),1) black hispanic birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 Parent_college famInc ismember(data.utype,1:4) ismember(data.utype,[1:2 5:6]) ismember(data.utype,[1 3 5 7])]; 
    N = size(X,1);
    K = size(X,2);
    inSample = ones(N,1);
    Xm = [ones(length(black),1) black hispanic birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 Parent_college famInc];
    Xml = cat(2,kron(ones(S,1),Xm),kron(A,ones(size(Xm,1),1)));

    %---------------------------------------------------------------------------
    % continuous outcomes
    %---------------------------------------------------------------------------
    asvabAR = X*parms.bstartAR + parms.sigAR*randn(N,1);
    asvabCS = X*parms.bstartCS + parms.sigCS*randn(N,1);
    asvabMK = X*parms.bstartMK + parms.sigMK*randn(N,1);
    asvabNO = X*parms.bstartNO + parms.sigNO*randn(N,1);
    asvabPC = X*parms.bstartPC + parms.sigPC*randn(N,1);
    asvabWK = X*parms.bstartWK + parms.sigWK*randn(N,1);
    SATmath = X*parms.bstartSATm + parms.sigSATm*randn(N,1);
    SATverb = X*parms.bstartSATv + parms.sigSATv*randn(N,1);
    
    %---------------------------------------------------------------------------
    % ordered logit outcomes
    %---------------------------------------------------------------------------
    % late for school without excuse
    pppp = pologit(parms.bstartLS,K-1,X(:,2:end),8);
    draw = rand(N,1);
    lateForSchoolNoExcuse = zeros(N,1);
    for j=1:8
        temp = (draw<sum(pppp(:,j:end),2));
        lateForSchoolNoExcuse=temp+lateForSchoolNoExcuse;
    end
    
    % break rules regularly
    pppp = pologit(parms.bstartBR,K-1,X(:,2:end),7);
    draw = rand(N,1);
    breakRulesRegularly = zeros(N,1);
    for j=1:7
        temp = (draw<sum(pppp(:,j:end),2));
        breakRulesRegularly=temp+breakRulesRegularly;
    end
    
    % highStandardsWork
    pppp = pologit(parms.bstartHS,K-1,X(:,2:end),7);
    draw = rand(N,1);
    highStandardsWork = zeros(N,1);
    for j=1:7
        temp = (draw<sum(pppp(:,j:end),2));
        highStandardsWork=temp+highStandardsWork;
    end
    
    % doMoreThanExpected
    pppp = pologit(parms.bstartDE,K-1,X(:,2:end),7);
    draw = rand(N,1);
    doMoreThanExpected = zeros(N,1);
    for j=1:7
        temp = (draw<sum(pppp(:,j:end),2));
        doMoreThanExpected=temp+doMoreThanExpected;
    end
    
    % pctChanceWork20Hrs30
    pppp = pologit(parms.bstartPWY,K-1,X(:,2:end),3);
    draw = rand(N,1);
    pctChanceWork20Hrs30 = zeros(N,1);
    for j=1:3
        temp = (draw<sum(pppp(:,j:end),2));
        pctChanceWork20Hrs30=temp+pctChanceWork20Hrs30;
    end
    
    % parPctChanceWork20Hrs30
    pppp = pologit(parms.bstartPWP,K-1,X(:,2:end),3);
    draw = rand(N,1);
    parPctChanceWork20Hrs30 = zeros(N,1);
    for j=1:3
        temp = (draw<sum(pppp(:,j:end),2));
        parPctChanceWork20Hrs30=temp+parPctChanceWork20Hrs30;
    end
    
    %---------------------------------------------------------------------------
    % multinomial logit outcomes
    %---------------------------------------------------------------------------
    % tookClassDuringBreak
    pppp = plogit(parms.bstartTB,K,X,2);
    draw = rand(N,1);
    tookClassDuringBreak = zeros(N,1);
    for j=1:2
        temp = (draw<sum(pppp(:,j:end),2));
        tookClassDuringBreak=temp+tookClassDuringBreak;
    end
    
    % reasonTookClassDuringBreak
    pppp = plogit(parms.bstartRTB,K,X,2);
    draw = rand(N,1);
    reasonTookClassDuringBreak = zeros(N,1);
    for j=1:2
        temp = (draw<sum(pppp(:,j:end),2));
        reasonTookClassDuringBreak=temp+reasonTookClassDuringBreak;
    end

    %---------------------------------------------------------------------------
    % tobit outcome
    %---------------------------------------------------------------------------
    % Hours of extra classes (censored below at 0; missing for others)
    HrsExtraClass = X*parms.bstartEC + parms.sigEC*randn(N,1);
    miHrsExtraClass = 0 .* HrsExtraClass; % no missings in parametric boostrap
    R1ExtraClass = HrsExtraClass>0;
    HrsExtraClass(HrsExtraClass==0) = 0.1;
    HrsExtraClass(R1ExtraClass==0) = -100;
    HrsExtraClass(R1ExtraClass==1 & miHrsExtraClass) = -10;


    %---------------------------------------------------------------------------
    % flags to be used in estimation
    %---------------------------------------------------------------------------
    flagAR = ~isnan(asvabAR) & inSample;
    flagARl= logical(kron(ones(S,1),flagAR));
    flagCS = ~isnan(asvabCS) & inSample;
    flagCSl= logical(kron(ones(S,1),flagCS));
    flagMK = ~isnan(asvabMK) & inSample;
    flagMKl= logical(kron(ones(S,1),flagMK));
    flagNO = ~isnan(asvabNO) & inSample;
    flagNOl= logical(kron(ones(S,1),flagNO));
    flagPC = ~isnan(asvabPC) & inSample;
    flagPCl= logical(kron(ones(S,1),flagPC));
    flagWK = ~isnan(asvabWK) & inSample;
    flagWKl= logical(kron(ones(S,1),flagWK));
    flagSATm = ~isnan(SATmath) & inSample;
    flagSATml= logical(kron(ones(S,1),flagSATm));
    flagSATv = ~isnan(SATverb) & inSample;
    flagSATvl= logical(kron(ones(S,1),flagSATv));
    flagLS = ~isnan(lateForSchoolNoExcuse) & inSample;
    flagLSl= logical(kron(ones(S,1),flagLS));
    flagBR = ~isnan(breakRulesRegularly) & inSample;
    flagBRl= logical(kron(ones(S,1),flagBR));
    flagEC = ~isnan(R1ExtraClass) & inSample;
    flagECl= logical(kron(ones(S,1),flagEC));
    flagTB = ~isnan(tookClassDuringBreak) & inSample;
    flagTBl= logical(kron(ones(S,1),flagTB));
    flagRTB = ~isnan(reasonTookClassDuringBreak) & inSample;
    flagRTBl= logical(kron(ones(S,1),flagRTB));
    flagHS = ~isnan(highStandardsWork) & inSample;
    flagHSl= logical(kron(ones(S,1),flagHS));
    flagDE = ~isnan(doMoreThanExpected) & inSample;
    flagDEl= logical(kron(ones(S,1),flagDE));
    flagPWY = ~isnan(pctChanceWork20Hrs30) & inSample;
    flagPWYl= logical(kron(ones(S,1),flagPWY));
    flagPWP = ~isnan(parPctChanceWork20Hrs30) & inSample;
    flagPWPl= logical(kron(ones(S,1),flagPWP));
    
    %---------------------------------------------------------------------------
    % kroneckered outcomes to be used in estimation
    %---------------------------------------------------------------------------
    asvabARl = kron(ones(S,1),asvabAR);
    asvabCSl = kron(ones(S,1),asvabCS);
    asvabMKl = kron(ones(S,1),asvabMK);
    asvabNOl = kron(ones(S,1),asvabNO);
    asvabPCl = kron(ones(S,1),asvabPC);
    asvabWKl = kron(ones(S,1),asvabWK);
    SATml    = kron(ones(S,1),SATmath);
    SATvl    = kron(ones(S,1),SATverb);
    yLSl     = kron(ones(S,1),lateForSchoolNoExcuse);
    yBRl     = kron(ones(S,1),breakRulesRegularly);
    WEC      = miHrsExtraClass; 
    yECl     = kron(ones(S,1),R1ExtraClass);
    HECl     = kron(ones(S,1),HrsExtraClass);
    WECl     = kron(ones(S,1),WEC);
    yTBl     = kron(ones(S,1),2-tookClassDuringBreak);
    yRTBl    = kron(ones(S,1),reasonTookClassDuringBreak);
    yHSl     = kron(ones(S,1),highStandardsWork);
    yDEl     = kron(ones(S,1),doMoreThanExpected);
    yPWYl    = kron(ones(S,1),pctChanceWork20Hrs30);
    yPWPl    = kron(ones(S,1),parPctChanceWork20Hrs30);
    
    measData = v2struct(Xml,flagARl,asvabARl,flagCSl,asvabCSl,flagMKl,asvabMKl,flagPCl,asvabPCl,flagNOl,asvabNOl,flagWKl,asvabWKl,flagSATml,SATml,flagSATvl,SATvl,yLSl,flagLSl,yBRl,flagBRl,yECl,flagECl,HECl,WECl,yTBl,flagTBl,yRTBl,flagRTBl,yHSl,flagHSl,yDEl,flagDEl,yPWYl,flagPWYl,yPWPl,flagPWPl,N);
end
