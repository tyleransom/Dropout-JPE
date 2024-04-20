function AR1obj = estimateAR1(learnparms);

    v2struct(learnparms);

    %% Estimate AR(1) Model on Wage Dummies
    ydn = [18:33];
    ydg = [18:33];
    YU=[bstartn(ydn(2:end));0];
    XU=bstartn(ydn);
    [rhoU,sterr_rhoU]=lscov(XU,YU)
    AR_1_residU = YU - XU*rhoU
    rho     = rhoU(1);
    unsk_wage_sig = std(AR_1_residU) %std([bstartn(14:26);0]);

    options=optimset('Disp','iter','FunValCheck','off','MaxFunEvals',1e8,'MaxIter',1e8,'GradObj','on','LargeScale','off');
    [bARestU,~,~,~,gARestU,hARestU] = fminunc('normalMLE',[rhoU;std(AR_1_residU)],options,[],YU,XU,[],[1*ones(size(XU));]); % homoskedasticity
    seARestU = sqrt(diag(inv(hARestU)));
    disp('no drift, unskilled')
    [[rhoU;unsk_wage_sig;] bARestU seARestU]

    unsk_wage_sig = bARestU(2);
    rhoU          = bARestU(1);

    % Generate wage coefficient vectors that incorporate the AR(1) structure of the year dummies
    skilledWageBeta_0            = bstartn(ydn);
    skilledWageBeta_1            = rhoU  *skilledWageBeta_0;
    skilledWageBeta_2            = rhoU^2*skilledWageBeta_0;
    skilledWageBeta_3            = rhoU^3*skilledWageBeta_0;
    skilledWageBeta_4            = rhoU^4*skilledWageBeta_0;
    skilledWageBeta_a            = bstartg;
    skilledWageBeta_b            = [bstartg(1:ydg(1)-1);rhoU  *bstartn(ydn);bstartg(ydg(end)+1:end)];
    skilledWageBeta_c            = [bstartg(1:ydg(1)-1);rhoU^2*bstartn(ydn);bstartg(ydg(end)+1:end)];
    skilledWageBeta_d            = [bstartg(1:ydg(1)-1);rhoU^3*bstartn(ydn);bstartg(ydg(end)+1:end)];
    skilledWageBeta_e            = [bstartg(1:ydg(1)-1);rhoU^4*bstartn(ydn);bstartg(ydg(end)+1:end)];
    unskilledWageBeta_0          = bstartn(ydn);
    unskilledWageBeta_1          = rhoU  *unskilledWageBeta_0;
    unskilledWageBeta_2          = rhoU^2*unskilledWageBeta_0;
    unskilledWageBeta_3          = rhoU^3*unskilledWageBeta_0;
    unskilledWageBeta_4          = rhoU^4*unskilledWageBeta_0;
    unskilledWageBeta_a          = bstartn;
    unskilledWageBeta_b          = [bstartn(1:ydn(1)-1);rhoU  *bstartn(ydn);bstartn(ydn(end)+1:end)];
    unskilledWageBeta_c          = [bstartn(1:ydn(1)-1);rhoU^2*bstartn(ydn);bstartn(ydn(end)+1:end)];
    unskilledWageBeta_d          = [bstartn(1:ydn(1)-1);rhoU^3*bstartn(ydn);bstartn(ydn(end)+1:end)];
    unskilledWageBeta_e          = [bstartn(1:ydn(1)-1);rhoU^4*bstartn(ydn);bstartn(ydn(end)+1:end)];
    skilledWageBetaYrDMat(:,1)   = skilledWageBeta_0;
    skilledWageBetaYrDMat(:,2)   = skilledWageBeta_1;
    skilledWageBetaYrDMat(:,3)   = skilledWageBeta_2;
    skilledWageBetaYrDMat(:,4)   = skilledWageBeta_3;
    skilledWageBetaYrDMat(:,5)   = skilledWageBeta_4;
    skilledWageBetaMat(:,1)      = skilledWageBeta_a;
    skilledWageBetaMat(:,2)      = skilledWageBeta_b;
    skilledWageBetaMat(:,3)      = skilledWageBeta_c;
    skilledWageBetaMat(:,4)      = skilledWageBeta_d;
    skilledWageBetaMat(:,5)      = skilledWageBeta_e;
    unskilledWageBetaYrDMat(:,1) = unskilledWageBeta_0;
    unskilledWageBetaYrDMat(:,2) = unskilledWageBeta_1;
    unskilledWageBetaYrDMat(:,3) = unskilledWageBeta_2;
    unskilledWageBetaYrDMat(:,4) = unskilledWageBeta_3;
    unskilledWageBetaYrDMat(:,5) = unskilledWageBeta_4;
    unskilledWageBetaMat(:,1)    = unskilledWageBeta_a;
    unskilledWageBetaMat(:,2)    = unskilledWageBeta_b;
    unskilledWageBetaMat(:,3)    = unskilledWageBeta_c;
    unskilledWageBetaMat(:,4)    = unskilledWageBeta_d;
    unskilledWageBetaMat(:,5)    = unskilledWageBeta_e;

    AR1obj = v2struct(rhoU,unsk_wage_sig,skilledWageBeta_0, skilledWageBeta_1, skilledWageBeta_2, skilledWageBeta_3, skilledWageBeta_4, skilledWageBeta_a, skilledWageBeta_b, skilledWageBeta_c, skilledWageBeta_d, skilledWageBeta_e, unskilledWageBeta_0, unskilledWageBeta_1, unskilledWageBeta_2, unskilledWageBeta_3, unskilledWageBeta_4, unskilledWageBeta_a, unskilledWageBeta_b, unskilledWageBeta_c, unskilledWageBeta_d, unskilledWageBeta_e, skilledWageBetaYrDMat, skilledWageBetaMat, unskilledWageBetaYrDMat, unskilledWageBetaMat, ydg, ydn);

end
