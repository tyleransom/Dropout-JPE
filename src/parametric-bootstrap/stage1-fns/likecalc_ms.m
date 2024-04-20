function likes = likecalc_ms(md,mp,df,S)

    %--------------------------------------------------------------------------
    % Likelihood of schooling ability measurements
    %--------------------------------------------------------------------------
    % Arithmetic Reasoning
    likeAR   = normpdf(md.asvabARl-md.Xml*mp.bstartAR,0,mp.sigAR).^(md.flagARl);
    likeAR(isnan(likeAR)) = 1;
    likeAR   = reshape(likeAR,[],S);

    % Coding Speed
    likeCS   = normpdf(md.asvabCSl-md.Xml*mp.bstartCS,0,mp.sigCS).^(md.flagCSl);
    likeCS(isnan(likeCS)) = 1;
    likeCS   = reshape(likeCS,[],S);

    % Mathematical Knowledge
    likeMK   = normpdf(md.asvabMKl-md.Xml*mp.bstartMK,0,mp.sigMK).^(md.flagMKl);
    likeMK(isnan(likeMK)) = 1;
    likeMK   = reshape(likeMK,[],S);

    % Numerical Operations
    likeNO   = normpdf(md.asvabNOl-md.Xml*mp.bstartNO,0,mp.sigNO).^(md.flagNOl);
    likeNO(isnan(likeNO)) = 1;
    likeNO   = reshape(likeNO,[],S);

    % Paragraph Comprehension
    likePC   = normpdf(md.asvabPCl-md.Xml*mp.bstartPC,0,mp.sigPC).^(md.flagPCl);
    likePC(isnan(likePC)) = 1;
    likePC   = reshape(likePC,[],S);

    % Word Knowledge
    likeWK   = normpdf(md.asvabWKl-md.Xml*mp.bstartWK,0,mp.sigWK).^(md.flagWKl);
    likeWK(isnan(likeWK)) = 1;
    likeWK   = reshape(likeWK,[],S);

    % SAT math
    likeSATm = normpdf(md.SATml-md.Xml*mp.bstartSATm,0,mp.sigSATm).^(md.flagSATml);
    likeSATm(isnan(likeSATm)) = 1;
    likeSATm = reshape(likeSATm,[],S);

    % SAT verbal
    likeSATv = normpdf(md.SATvl-md.Xml*mp.bstartSATv,0,mp.sigSATv).^(md.flagSATvl);
    likeSATv(isnan(likeSATv)) = 1;
    likeSATv = reshape(likeSATv,[],S);


    %--------------------------------------------------------------------------
    % Likelihood of schooling preference measurements
    %--------------------------------------------------------------------------
    % Number of times late for school without excuse
    nc = 8;
    pLS      = pologit(mp.bstartLS,size(md.Xml(:,2:end),2),md.Xml(:,2:end),nc);
    likeLS   = ones(size(md.flagLSl));
    for j=1:nc
        likeLS = likeLS.*(pLS(:,j).^(md.yLSl==j));
    end
    likeLS = likeLS.^md.flagLSl;
    likeLS(isnan(likeLS)) = 1;
    likeLS   = reshape(likeLS,[],S);

    % Likert scale: I broke rules regularly
    nc = 7;
    pBR      = pologit(mp.bstartBR,size(md.Xml(:,2:end),2),md.Xml(:,2:end),nc);
    likeBR   = ones(size(md.flagBRl));
    for j=1:nc
        likeBR = likeBR.*(pBR(:,j).^(md.yBRl==j));
    end
    likeBR = likeBR.^md.flagBRl;
    likeBR(isnan(likeBR)) = 1;
    likeBR   = reshape(likeBR,[],S);

    % Extra classes (tobit)
    likeEC = ones(size(md.flagECl));
    likeEC = normpdf(md.HECl-md.Xml*mp.bstartEC,0,mp.sigEC) .^(md.yECl==1 & md.WECl==0).*...
                (1-normcdf(md.Xml*mp.bstartEC./mp.sigEC)).^(md.yECl==0).*...
                   normcdf(md.Xml*mp.bstartEC./mp.sigEC) .^(md.yECl==1 & md.WECl==1);
    likeEC = likeEC.^md.flagECl;
    likeEC(isnan(likeEC)) = 1;
    likeEC = reshape(likeEC,[],S);

    % Took classes during break
    nc = 2;
    pTB      = plogit(mp.bstartTB,size(md.Xml,2),md.Xml,nc);
    likeTB   = ones(size(md.flagTBl));
    for j=1:nc
        likeTB = likeTB.*(pTB(:,j).^(md.yTBl==j));
    end
    likeTB = likeTB.^md.flagTBl;
    likeTB(isnan(likeTB)) = 1;
    likeTB   = reshape(likeTB,[],S);

    % Reason took classes during break
    nc = 2;
    pRTB      = plogit(mp.bstartRTB,size(md.Xml,2),md.Xml,nc);
    likeRTB   = ones(size(md.flagRTBl));
    for j=1:nc
        likeRTB = likeRTB.*(pRTB(:,j).^(md.yRTBl==j));
    end
    likeRTB = likeRTB.^md.flagRTBl;
    likeRTB(isnan(likeRTB)) = 1;
    likeRTB   = reshape(likeRTB,[],S);


    %--------------------------------------------------------------------------
    % Likelihood of work ability & preference measurements
    %--------------------------------------------------------------------------
    % High standards at work
    nc = 7;
    pHS      = pologit(mp.bstartHS,size(md.Xml(:,2:end),2),md.Xml(:,2:end),nc);
    likeHS   = ones(size(md.flagHSl));
    for j=1:nc
        likeHS = likeHS.*(pHS(:,j).^(md.yHSl==j));
    end
    likeHS = likeHS.^md.flagHSl;
    likeHS(isnan(likeHS)) = 1;
    likeHS   = reshape(likeHS,[],S);

    % Do what is expected
    nc = 7;
    pDE      = pologit(mp.bstartDE,size(md.Xml(:,2:end),2),md.Xml(:,2:end),nc);
    likeDE   = ones(size(md.flagDEl));
    for j=1:nc
        likeDE = likeDE.*(pDE(:,j).^(md.yDEl==j));
    end
    likeDE = likeDE.^md.flagDEl;
    likeDE(isnan(likeDE)) = 1;
    likeDE   = reshape(likeDE,[],S);

    % Percent chance work 20+ hours per week at age 30 (youth's assessment)
    nc = 3;
    pPWY      = pologit(mp.bstartPWY,size(md.Xml(:,2:end),2),md.Xml(:,2:end),nc);
    likePWY   = ones(size(md.flagPWYl));
    for j=1:nc
        likePWY = likePWY.*(pPWY(:,j).^(md.yPWYl==j));
    end
    likePWY = likePWY.^md.flagPWYl;
    likePWY(isnan(likePWY)) = 1;
    likePWY   = reshape(likePWY,[],S);

    % percent chance work 20+ hours per week at age 30 (parent's assessment)
    nc = 3;
    pPWP      = pologit(mp.bstartPWP,size(md.Xml(:,2:end),2),md.Xml(:,2:end),nc);
    likePWP   = ones(size(md.flagPWPl));
    for j=1:nc
        likePWP = likePWP.*(pPWP(:,j).^(md.yPWPl==j));
    end
    likePWP = likePWP.^md.flagPWPl;
    likePWP(isnan(likePWP)) = 1;
    likePWP   = reshape(likePWP,[],S);


    %--------------------------------------------------------------------------
    % Likelihood contribution of measurement system model
    %--------------------------------------------------------------------------
    likes = prod3(likeAR, likeCS, likeMK, likeNO, likePC, likeWK, likeSATm, likeSATv, likeLS, likeBR, likeEC, likeTB, likeRTB, likeHS, likeDE, likePWY, likePWP);


    %--------------------------------------------------------------------------
    % Unit test likelihood values
    %--------------------------------------------------------------------------
    assert(size(likes,1)==df.N && size(likes,2)==S,'likecalc_ms: dimensions of likes are wrong')
    assert(all(all(likes>0)),'likecalc_ms: likelihood has zero values');
    assert(~(any(any(likes<0))),'likecalc_ms: likelihood has negative values');
end
 