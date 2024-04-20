function [outputs,tables] = estimatemeas(measnewdata,measparms,q)

    v2struct(measnewdata);
    v2struct(measparms);
    q = q(:);

    % Optimization options
    options=optimset('Disp','off','FunValCheck','off','MaxFunEvals',1e8,'MaxIter',1e8,'GradObj','on','LargeScale','on');
    options1=optimset('Disp','off','FunValCheck','off','MaxFunEvals',1e8,'MaxIter',1e8,'GradObj','on','LargeScale','on');

    %--------------------------------------------------------------------------
    % Estimate schooling ability measures
    %--------------------------------------------------------------------------
    % create matrix of restrictions consistent with structure of types
    sx       = size(Xml,2);
    restrMat = [sx-1 0 0 0 0;
                sx   0 0 0 0];

    [bAR,~,~,~,~,hAR] = fminunc('normalMLE',[bstartAR;sigAR],options,restrMat,asvabARl(flagARl),Xml(flagARl,:),q(flagARl));
    [bAR,invHAR] = applyRestr(restrMat,bAR,hAR);
    seAR     = sqrt(diag(invHAR));
    bstartAR = bAR(1:end-1);
    sigAR    = abs(bAR(end));

    [bCS,~,~,~,~,hCS] = fminunc('normalMLE',[bstartCS;sigCS],options,restrMat,asvabCSl(flagCSl),Xml(flagCSl,:),q(flagCSl));
    [bCS,invHCS] = applyRestr(restrMat,bCS,hCS);
    seCS     = sqrt(diag(invHCS));
    bstartCS = bCS(1:end-1);
    sigCS    = abs(bCS(end));

    [bMK,~,~,~,~,hMK] = fminunc('normalMLE',[bstartMK;sigMK],options,restrMat,asvabMKl(flagMKl),Xml(flagMKl,:),q(flagMKl));
    [bMK,invHMK] = applyRestr(restrMat,bMK,hMK);
    seMK     = sqrt(diag(invHMK));
    bstartMK = bMK(1:end-1);
    sigMK    = abs(bMK(end));

    [bNO,~,~,~,~,hNO] = fminunc('normalMLE',[bstartNO;sigNO],options,restrMat,asvabNOl(flagNOl),Xml(flagNOl,:),q(flagNOl));
    [bNO,invHNO] = applyRestr(restrMat,bNO,hNO);
    seNO     = sqrt(diag(invHNO));
    bstartNO = bNO(1:end-1);
    sigNO    = abs(bNO(end));

    [bPC,~,~,~,~,hPC] = fminunc('normalMLE',[bstartPC;sigPC],options,restrMat,asvabPCl(flagPCl),Xml(flagPCl,:),q(flagPCl));
    [bPC,invHPC] = applyRestr(restrMat,bPC,hPC);
    sePC     = sqrt(diag(invHPC));
    bstartPC = bPC(1:end-1);
    sigPC    = abs(bPC(end));

    [bWK,~,~,~,~,hWK] = fminunc('normalMLE',[bstartWK;sigWK],options,restrMat,asvabWKl(flagWKl),Xml(flagWKl,:),q(flagWKl));
    [bWK,invHWK] = applyRestr(restrMat,bWK,hWK);
    seWK     = sqrt(diag(invHWK));
    bstartWK = bWK(1:end-1);
    sigWK    = abs(bWK(end));

    [bSATm,~,~,~,~,hSATm] = fminunc('normalMLE',[bstartSATm;sigSATm],options,restrMat,SATml(flagSATml),Xml(flagSATml,:),q(flagSATml));
    [bSATm,invHSATm] = applyRestr(restrMat,bSATm,hSATm);
    seSATm     = sqrt(diag(invHSATm));
    bstartSATm = bSATm(1:end-1);
    sigSATm    = abs(bSATm(end));

    [bSATv,~,~,~,~,hSATv] = fminunc('normalMLE',[bstartSATv;sigSATv],options,restrMat,SATvl(flagSATvl),Xml(flagSATvl,:),q(flagSATvl));
    [bSATv,invHSATv] = applyRestr(restrMat,bSATv,hSATv);
    seSATv     = sqrt(diag(invHSATv));
    bstartSATv = bSATv(1:end-1);
    sigSATv    = abs(bSATv(end));
    
    schab = cell2table({'constant', 'black', 'hispanic', 'born1980', 'born1981', 'born1982', 'born1983', 'Parent_college', 'famIncome', 'sch abil H', 'sch pref H', 'wrk abil pref H', 'SD of noise','N'}','VariableNames',{'Variable'});
    schab.AR   = [bAR;round(sum(q(flagARl)))];
    schab.CS   = [bCS;round(sum(q(flagCSl)))];
    schab.MK   = [bMK;round(sum(q(flagMKl)))];
    schab.NO   = [bNO;round(sum(q(flagNOl)))];
    schab.PC   = [bPC;round(sum(q(flagPCl)))];
    schab.WK   = [bWK;round(sum(q(flagWKl)))];
    schab.SATm = [bSATm;round(sum(q(flagSATml)))];
    schab.SATv = [bSATv;round(sum(q(flagSATvl)))];


    %--------------------------------------------------------------------------
    % Estimate schooling preference measures
    %--------------------------------------------------------------------------
    % number of times late for school without excuse
    nc = 8;
    % create matrix of restrictions consistent with structure of types
    sx       = size(Xml(:,2:end),2);
    restrMat = [sx-2 0 0 0 0;
                sx   0 0 0 0];
    % optimize
    [bLS,~,~,~,~,hLS] = fminunc('ologit_restrict',bstartLS,options1,restrMat,yLSl(flagLSl),Xml(flagLSl,2:end),size(Xml,2)-1,nc,q(flagLSl));
    [bstartLS,invHLS] = applyRestr(restrMat,bLS,hLS);
    seLS     = sqrt(diag(invHLS));


    % break rules regularly
    nc = 7;
    % use same restrMat as above
    % optimize
    [bBR,~,~,~,~,hBR] = fminunc('ologit_restrict',bstartBR,options1,restrMat,yBRl(flagBRl),Xml(flagBRl,2:end),size(Xml,2)-1,nc,q(flagBRl));
    [bstartBR,invHBR] = applyRestr(restrMat,bBR,hBR);
    seBR     = sqrt(diag(invHBR));


    % took extra classes (tobit)
    % create matrix of restrictions consistent with structure of types
    sx       = size(Xml,2);
    restrMat = [4 0 0 0 0;
                5 0 0 0 0;
                sx-2 0 0 0 0;
                sx   0 0 0 0];
    % optimize
    [bEC,~,~,~,~,hEC] = fminunc('tobit_restrict',[bstartEC;sigEC],options1,restrMat,yECl(flagECl),HECl(flagECl),WECl(flagECl),Xml(flagECl,:),q(flagECl));
    [bEC,invHrestr] = applyRestr(restrMat,bEC,hEC);
    seEC     = sqrt(diag(invHrestr));
    bstartEC = bEC(1:end-1);
    sigEC    = bEC(end);


    % took classes during break
    nc = 2;
    % create matrix of restrictions consistent with structure of types
    restrMat = [7 0 0 0 0;
                sx-2 0 0 0 0;
                sx   0 0 0 0];
    % optimize
    [bTB,~,~,~,~,hTB] = fminunc('mlogit_restrict',bstartTB,options1,restrMat,yTBl(flagTBl),Xml(flagTBl,:),size(Xml,2),nc,q(flagTBl));
    [bstartTB,invHrestr] = applyRestr(restrMat,bTB,hTB);
    seTB     = sqrt(diag(invHrestr));


    % reason took classes during break
    nc = 2;
    % create matrix of restrictions consistent with structure of types
    restrMat = [6 0 0 0 0;
                7 0 0 0 0;
                sx-2 0 0 0 0;
                sx   0 0 0 0];
    % optimize
    [bRTB,~,~,~,~,hRTB] = fminunc('mlogit_restrict',bstartRTB,options1,restrMat,yRTBl(flagRTBl),Xml(flagRTBl,:),size(Xml,2),nc,q(flagRTBl));
    [bstartRTB,invHrestr] = applyRestr(restrMat,bRTB,hRTB);
    seRTB     = sqrt(diag(invHrestr));
    
    schpr = cell2table({'constant', 'black', 'hispanic', 'born1980', 'born1981', 'born1982', 'born1983', 'Parent_college', 'famIncome', 'sch abil H', 'sch pref H', 'wrk abil pref H', 'cut 1', 'cut 2', 'cut 3', 'cut 4', 'cut 5', 'cut 6', 'cut 7', 'SD of noise','N'}','VariableNames',{'Variable'});
    schpr.LateSchool = [0;bLS;0;round(sum(q(flagLSl)))];
    schpr.BreakRules = [0;bBR;0;0;round(sum(q(flagBRl)))];
    schpr.ExtraClasses = [bstartEC;zeros(7,1);sigEC;round(sum(q(flagECl)))];
    schpr.ClassesOverBreak = [bTB;zeros(8,1);round(sum(q(flagTBl)))];
    schpr.ReasonClassesOverBreak = [bRTB;zeros(8,1);round(sum(q(flagRTBl)))];



    %--------------------------------------------------------------------------
    % Estimate work ability/preference measures
    %--------------------------------------------------------------------------
    % high standards at work
    nc = 7;
    % create matrix of restrictions consistent with structure of types
    sx       = size(Xml(:,2:end),2);
    restrMat = [sx-2 0 0 0 0;
                sx-1 0 0 0 0];
    % optimize
    [bHS,~,~,~,~,hHS] = fminunc('ologit_restrict',bstartHS,options1,restrMat,yHSl(flagHSl),Xml(flagHSl,2:end),size(Xml,2)-1,nc,q(flagHSl));
    [bstartHS,invHrestr] = applyRestr(restrMat,bHS,hHS);
    seHS     = sqrt(diag(invHrestr));


    % do what is expected
    nc = 7;
    % use same restrMat as above
    % optimize
    [bDE,~,~,~,~,hDE] = fminunc('ologit_restrict',bstartDE,options1,restrMat,yDEl(flagDEl),Xml(flagDEl,2:end),size(Xml,2)-1,nc,q(flagDEl));
    [bstartDE,invHrestr] = applyRestr(restrMat,bDE,hDE);
    seDE     = sqrt(diag(invHrestr));


    % percent chance work 20+ hours per week at age 30 (youth's assessment)
    nc = 3;
    % optimize
    restrMat = [4 0 0 0 0;
                5 0 0 0 0;
                6 0 0 0 0;
                sx-2 0 0 0 0;
                sx-1 0 0 0 0];
    [bPWY,~,~,~,~,hPWY] = fminunc('ologit_restrict',bstartPWY,options1,restrMat,yPWYl(flagPWYl),Xml(flagPWYl,2:end),size(Xml,2)-1,nc,q(flagPWYl));
    [bstartPWY,invHrestr] = applyRestr(restrMat,bPWY,hPWY);
    sePWY     = sqrt(diag(invHrestr));


    % percent chance work 20+ hours per week at age 30 (parent's assessment)
    nc = 3;
    % use same restrMat as above
    % optimize
    [bPWP,~,~,~,~,hPWP] = fminunc('ologit_restrict',bstartPWP,options1,restrMat,yPWPl(flagPWPl),Xml(flagPWPl,2:end),size(Xml,2)-1,nc,q(flagPWPl));
    [bstartPWP,invHrestr] = applyRestr(restrMat,bPWP,hPWP);
    sePWP     = sqrt(diag(invHrestr));
    
    wrkap = cell2table({'black', 'hispanic', 'born1980', 'born1981', 'born1982', 'born1983', 'Parent_college', 'famIncome', 'sch abil H', 'sch pref H', 'wrk abil pref H', 'cut 1', 'cut 2', 'cut 3', 'cut 4', 'cut 5', 'cut 6','N'}','VariableNames',{'Variable'});
    wrkap.HighStandards = [bHS;round(sum(q(flagHSl)))];
    wrkap.DoExpected    = [bDE;round(sum(q(flagDEl)))];
    wrkap.PctWorkY      = [bPWY;zeros(4,1);round(sum(q(flagPWYl)))];
    wrkap.PctWorkP      = [bPWP;zeros(4,1);round(sum(q(flagPWPl)))];


    
    outputs = v2struct(bstartAR,sigAR,bstartCS,sigCS,bstartMK,sigMK,bstartNO,sigNO,bstartPC,sigPC,bstartWK,sigWK,bstartSATm,sigSATm,bstartSATv,sigSATv,bstartLS,bstartBR,bstartEC,sigEC,bstartTB,bstartRTB,bstartHS,bstartDE,bstartPWY,bstartPWP,seAR,seCS,seMK,seNO,sePC,seWK,seSATm,seSATv,seLS,seBR,seEC,seTB,seRTB,seHS,seDE,sePWY,sePWP);
    tables = v2struct(schab,schpr,wrkap);
end
