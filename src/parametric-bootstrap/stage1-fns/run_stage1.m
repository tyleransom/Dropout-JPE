function [parms] = run_stage1(mnd,allst,currst,estparms,prior,S,seedno,ipath)

    %-------------------------------------------------------------------------------
    % Process data
    %-------------------------------------------------------------------------------
    % load data on choices, outcomes, and covariates
    df = createchoicedata(allst,currst,S);

    % compute signals
    [prab] = prior_mean_outcome_DDC_standardized(df,S);



    %-------------------------------------------------------------------------------
    % construct covariate matrices
    %-------------------------------------------------------------------------------
    % for unobserved types
    A = [1 1 1; 1 1 0; 1 0 1; 1 0 0; 0 1 1; 0 1 0; 0 0 1; 0 0 0];
    cv.type_dummies = kron(A,ones(df.N*df.T,1,1));

    % for other parts of the model
    cv.demogs  = kron(ones(S,1),[ones(df.N*df.T,1) df.black df.hispanic df.HS_grades df.Parent_college df.birthYr==1980 df.birthYr==1981 df.birthYr==1982 df.birthYr==1983 df.famInc]);
    cv.yrdums  = kron(ones(S,1),[df.year<=1999 df.year==2000 df.year==2001 df.year==2002 df.year==2003 df.year==2004 df.year==2005 df.year==2006 df.year==2007 df.year==2008 df.year==2009 df.year==2010 df.year==2011 df.year==2012 df.year==2013 df.year==2014]); 
    cv.expers  = kron(ones(S,1),[df.age (df.age+5).^2 df.cum_2yr df.cum_2yr.^2 df.cum_4yrS df.cum_4yrS.^2 df.cum_4yrNS df.cum_4yrNS.^2 df.cum_2yr.*(df.cum_4yrS+df.cum_4yrNS) df.exper df.exper.^2 df.exper_white_collar df.exper_white_collar.^2 df.exper.*df.exper_white_collar]); 
    cv.experw  = kron(ones(S,1),[                     df.cum_2yr df.cum_2yr.^2 df.cum_4yrS df.cum_4yrS.^2 df.cum_4yrNS df.cum_4yrNS.^2 df.cum_2yr.*(df.cum_4yrS+df.cum_4yrNS) df.exper df.exper.^2 df.exper_white_collar df.exper_white_collar.^2 df.exper.*df.exper_white_collar]); 
    cv.prevs   = kron(ones(S,1),[df.prev_HS df.prev_2yr df.prev_4yrS df.prev_4yrNS df.prev_PT df.prev_FT df.prev_WC]);
    cv.currs   = kron(ones(S,1),[df.in_2yr df.in_sci df.in_hum df.in_PT df.in_FT df.in_WC]);
    cv.currws  = kron(ones(S,1),[df.in_2yr df.in_sci df.in_hum df.grad_4yr==1 (df.grad_4yr==1 & df.finalMajorSci==1)]);
    cv.currgs  = kron(ones(S,1),[          df.in_sci df.in_PT df.in_FT df.in_WC]);
    cv.currgg  = kron(ones(S,1),[                    df.in_PT df.in_FT df.in_WC]);
    cv.currwk  = kron(ones(S,1),[df.in_FT df.grad_4yr==1 (df.grad_4yr==1 & df.finalMajorSci==1)]);
    cv.grad4yX = bsxfun(@times,kron(ones(S,1),df.grad_4yr==1                      ),kron(ones(S,1),[df.black df.hispanic df.HS_grades df.Parent_college df.birthYr==1980 df.birthYr==1981 df.birthYr==1982 df.birthYr==1983 df.famInc df.age (df.age+5).^2 df.cum_2yr df.cum_2yr.^2 df.cum_4yrS df.cum_4yrS.^2 df.cum_4yrNS df.cum_4yrNS.^2 df.cum_2yr.*(df.cum_4yrS+df.cum_4yrNS) df.exper df.exper.^2 df.exper_white_collar df.exper_white_collar.^2 df.exper.*df.exper_white_collar df.prev_4yrS df.prev_4yrNS df.prev_PT df.prev_FT df.prev_WC])); 
    cv.gr4yscX = bsxfun(@times,kron(ones(S,1),df.grad_4yr==1 & df.finalMajorSci==1),kron(ones(S,1),[df.cum_4yrS df.cum_4yrNS df.exper df.exper_white_collar df.prev_PT df.prev_FT df.prev_WC])); 
    cv.signals = [prab.prior_mean_outcome_S_vec prab.prior_mean_outcome_U_vec prab.prior_mean_outcome_4S_vec prab.prior_mean_outcome_4NS_vec prab.prior_mean_outcome_2_vec];
    cv.signalXwage = cat(2,bsxfun(@times,cv.signals(:,1:2),(df.cum_2yrl+df.cum_4yrl)),...
                           bsxfun(@times,cv.signals(:,1:2),df.experl),...
                           bsxfun(@times,cv.signals(:,1:2),df.exper_white_collarl),...
                           bsxfun(@times,cv.signals(:,1:2),(df.prev_2yrl + df.prev_4yrSl + df.prev_4yrNSl)),...
                           bsxfun(@times,cv.signals(:,1:2),(df.prev_PTl + df.prev_FTl)),...
                           bsxfun(@times,cv.signals(:,1:2),df.prev_WCl));
    cv.signalXgpa  = cat(2,bsxfun(@times,cv.signals(:,3:5),(df.cum_2yrl+df.cum_4yrl)),...
                           bsxfun(@times,cv.signals(:,3:5),df.experl),...
                           bsxfun(@times,cv.signals(:,3:5),df.exper_white_collarl),...
                           bsxfun(@times,cv.signals(:,3:5),(df.prev_2yrl + df.prev_4yrSl + df.prev_4yrNSl)),...
                           bsxfun(@times,cv.signals(:,3:5),(df.prev_PTl + df.prev_FTl)),...
                           bsxfun(@times,cv.signals(:,3:5),df.prev_WCl));
    cv.signalXall  = cat(2,bsxfun(@times,cv.signals,       (df.cum_2yrl+df.cum_4yrl)),...
                           bsxfun(@times,cv.signals,       df.experl),...
                           bsxfun(@times,cv.signals,       df.exper_white_collarl),...
                           bsxfun(@times,cv.signals,       (df.prev_2yrl + df.prev_4yrSl + df.prev_4yrNSl)),...
                           bsxfun(@times,cv.signals,       (df.prev_PTl + df.prev_FTl)),...
                           bsxfun(@times,cv.signals,       df.prev_WCl));
    cv.signalXgrad = cat(2,bsxfun(@times,cv.signals(:,3:4),(df.cum_2yrl+df.cum_4yrl)),...
                           bsxfun(@times,cv.signals(:,3:4),df.experl),...
                           bsxfun(@times,cv.signals(:,3:4),df.in_scil),...
                           bsxfun(@times,cv.signals(:,3:4),df.in_workl),...
                           bsxfun(@times,cv.signals(:,3:4),df.in_WCl));
    cv.signalWCtype = bsxfun(@times,cv.type_dummies,cv.signals(:,1));
    cv.signalBCtype = bsxfun(@times,cv.type_dummies,cv.signals(:,2));
    cv.signal4Stype = bsxfun(@times,cv.type_dummies,cv.signals(:,3));
    cv.signal4Htype = bsxfun(@times,cv.type_dummies,cv.signals(:,4));
    cv.signal2Ytype = bsxfun(@times,cv.type_dummies,cv.signals(:,5));





    % for graduation logit
    cv.gradlogit = cat(2,cv.demogs,cv.expers,cv.currgs,cv.signals,cv.signalXgrad,cv.type_dummies,cv.signal4Stype,cv.signal4Htype);

    % wages generally
    cv.wages = cat(2,cv.demogs,cv.yrdums,cv.experw,cv.prevs,cv.currws,cv.signals,cv.signalXwage,cv.type_dummies);

    % for white collar wages
    cv.wagesWC = cat(2,cv.wages,cv.signalWCtype);

    % for blue collar wages
    cv.wagesBC = cat(2,cv.wages,cv.signalBCtype);

    % for college GPAs generally
    cv.grades = cat(2,cv.demogs,cv.expers,cv.prevs,cv.currgg,cv.signals,cv.signalXgpa,cv.type_dummies);

    % for science grades
    cv.grades4S = cat(2,cv.grades,cv.signal4Stype);

    % for humanities grades
    cv.grades4H = cat(2,cv.grades,cv.signal4Htype);

    % for 2yr grades
    cv.grades2Y = cat(2,cv.grades,cv.signal2Ytype);

    % for college logit
    cv.colllogit = cat(2,cv.demogs,cv.expers,cv.prevs,cv.signals,cv.signalXgpa,cv.type_dummies,cv.signal4Stype,cv.signal4Htype,cv.signal2Ytype); 

    % for 2yr/4yr logit
    cv.c24logit = cv.colllogit;

    % for hum/sci logit
    cv.csclogit = cat(2,cv.demogs,cv.expers,cv.prevs,cv.signals,cv.signalXgpa,cv.type_dummies,cv.signal4Stype,cv.signal4Htype);  

    % for work logit
    cv.lbsplogit = cat(2,cv.demogs,cv.expers,cv.prevs,cv.currws,cv.signals,cv.signalXwage,cv.type_dummies,cv.signalWCtype,cv.signalBCtype);

    % for workFT logit (given working)
    cv.wftlogit = cv.lbsplogit;

    % for workWC logit (given work FT)
    cv.wwclogit = cat(2,cv.demogs,cv.expers,cv.prevs,cv.currwk,cv.signals,cv.signalXwage,cv.type_dummies,cv.signalWCtype); 



    %-------------------------------------------------------------------------------
    % construct estimation flags
    %-------------------------------------------------------------------------------
    flags.baseflag = true(df.N*df.T*S,1);
    flags.gradl    = ismember(df.Yl,6:15) & ((df.cum_2yrl+df.cum_4yrl)>=2);
    flags.c24l     = ismember(df.Yl,1:15);
    flags.cscl     = ismember(df.Yl,6:15);
    flags.cftl     = ismember(df.Yl,[1:4 6:9 11:14 16:19]);
    flags.cwcl     = ismember(df.Yl,[1:4 6:9 11:14 16:19]);
    flags.wage_wc  = ismember(df.Yl,[2 4 7 9 12 14 17 19]);
    flags.wage_bc  = ismember(df.Yl,[1 3 6 8 11 13 16 18]);
    flags.g4s      = ismember(df.Yl, 6:10); 
    flags.g4h      = ismember(df.Yl,11:15); 
    flags.g2y      = ismember(df.Yl, 1:5 ); 

    %-------------------------------------------------------------------------------
    % Check parameter initialization for meas sys type dummies
    %-------------------------------------------------------------------------------
    softAssert(sign(estparms.msys.bstartAR(10))==1,['ASVAB AR type dummy not positive; coef is: ',num2str(estparms.msys.bstartAR(10))]);
    softAssert(sign(estparms.msys.bstartCS(10))==1,['ASVAB CS type dummy not positive; coef is: ',num2str(estparms.msys.bstartCS(10))]);
    softAssert(sign(estparms.msys.bstartMK(10))==1,['ASVAB MK type dummy not positive; coef is: ',num2str(estparms.msys.bstartMK(10))]);
    softAssert(sign(estparms.msys.bstartNO(10))==1,['ASVAB NO type dummy not positive; coef is: ',num2str(estparms.msys.bstartNO(10))]);
    softAssert(sign(estparms.msys.bstartPC(10))==1,['ASVAB PC type dummy not positive; coef is: ',num2str(estparms.msys.bstartPC(10))]);
    softAssert(sign(estparms.msys.bstartWK(10))==1,['ASVAB WK type dummy not positive; coef is: ',num2str(estparms.msys.bstartWK(10))]);
    softAssert(sign(estparms.msys.bstartSATm(10))==1,['SAT math type dummy not positive; coef is: ',num2str(estparms.msys.bstartSATm(10))]);
    softAssert(sign(estparms.msys.bstartSATv(10))==1,['SAT verbal type dummy not positive; coef is: ',num2str(estparms.msys.bstartSATv(10))]);
    softAssert(sign(estparms.msys.bstartLS(10))==-1,['Late for School type dummy not negative; coef is: ',num2str(estparms.msys.bstartLS(10))]);
    softAssert(sign(estparms.msys.bstartBR(10))==-1,['Break Rules type dummy not negative; coef is: ',num2str(estparms.msys.bstartBR(10))]);
    softAssert(sign(estparms.msys.bstartEC(11))== 1,['Extra classes type dummy not positive; coef is: ',num2str(estparms.msys.bstartEC(11))]);
    softAssert(sign(estparms.msys.bstartTB(11))==-1,['Took classes during break type dummy not negative; coef is: ',num2str(estparms.msys.bstartTB(11))]);
    softAssert(sign(estparms.msys.bstartRTB(11))==1,['Reason Took Classes during Break type dummy not positive; coef is: ',num2str(estparms.msys.bstartRTB(11))]);
    softAssert(sign(estparms.msys.bstartHS(11))==1,['High Standards type dummy not positive; coef is: ',num2str(estparms.msys.bstartHS(11))]);
    softAssert(sign(estparms.msys.bstartDE(11))==1,['Do what is expected type dummy not positive; coef is: ',num2str(estparms.msys.bstartDE(11))]);
    softAssert(sign(estparms.msys.bstartPWY(11))==1,['Pct Work Youth type dummy not positive; coef is: ',num2str(estparms.msys.bstartPWY(11))]);
    softAssert(sign(estparms.msys.bstartPWP(11))==1,['Pct Work Parent type dummy not positive; coef is: ',num2str(estparms.msys.bstartPWP(11))]);



    %-------------------------------------------------------------------------------
    % EM algorithm
    %-------------------------------------------------------------------------------
    tic_whole = tic;
    EMcriter  = 1;
    iteration = 1;
    likevec = [];
    while  EMcriter>1e-4 && iteration<1200
        tic_inner = tic;
        
        if iteration==1
            oPTypel=zeros(df.N*df.T*S,1);

            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            % M-step: measurement system
            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            measparms = estparms.msys;
            like.msy = likecalc_ms(mnd,measparms,df,S);
            parms.msys = measparms;

            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            % M-step: graduation logit
            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            parms.grl.b = estparms.grl.b;
            like.grl = likecalc_logit(cv.gradlogit,parms.grl.b,df.grad_4yr_next_yrl,flags.gradl,df.N,df.T,S);

            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            % M-step: log wage and GPA regressions
            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            % white collar
            parms.wwc.b = estparms.wwc.b;
            like.wwc = likecalc_normMLE(cv.wagesWC,parms.wwc.b,df.wagesl,flags.wage_wc,df.N,df.T,S);

            % blue collar
            parms.wbc.b = estparms.wbc.b;
            like.wbc = likecalc_normMLE(cv.wagesBC,parms.wbc.b,df.wagesl,flags.wage_bc,df.N,df.T,S);

            % 4yr science
            parms.g4s.b = estparms.g4s.b;
            like.g4s  = likecalc_normMLE(cv.grades4S,parms.g4s.b,df.gradesl,flags.g4s,df.N,df.T,S);

            % 4yr humanities
            parms.g4h.b = estparms.g4h.b;
            like.g4h  = likecalc_normMLE(cv.grades4H,parms.g4h.b,df.gradesl,flags.g4h,df.N,df.T,S);

            % 2yr
            parms.g2y.b = estparms.g2y.b;
            like.g2y  = likecalc_normMLE(cv.grades2Y,parms.g2y.b,df.gradesl,flags.g2y,df.N,df.T,S);
                
            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            % M-step: choice logits
            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            % college yes/no
            parms.col.b = estparms.col.b;
            like.cl = likecalc_logit(cv.colllogit,parms.col.b,df.in_collegel,flags.baseflag,df.N,df.T,S);

            % 4yr yes/no (given college)
            parms.c24.b = estparms.c24.b;
            like.c24l = likecalc_logit(cv.c24logit,parms.c24.b,df.in_4yrl,flags.c24l,df.N,df.T,S);

            % sci yes/no (given 4yr)
            parms.csc.b = estparms.csc.b;
            like.cscl = likecalc_logit(cv.csclogit,parms.csc.b,df.in_scil,flags.cscl,df.N,df.T,S);

            % work yes/no
            parms.cls.b = estparms.cls.b;
            like.clsl = likecalc_logit(cv.lbsplogit,parms.cls.b,df.in_workl,flags.baseflag,df.N,df.T,S);

            % work FT or PT (given work)
            parms.cft.b = estparms.cft.b;
            like.cftl = likecalc_logit(cv.wftlogit,parms.cft.b,df.in_FTl,flags.cftl,df.N,df.T,S);

            % work WC or BC (given work)
            parms.cwc.b = estparms.cwc.b;
            like.cwcl = likecalc_logit(cv.wwclogit,parms.cwc.b,df.in_WCl,flags.cwcl,df.N,df.T,S);
        else
            oPTypel=PTypel;
            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            % M-step: measurement system
            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            [measparms] = estimatemeas(mnd,measparms,PType);
            like.msy = likecalc_ms(mnd,measparms,df,S);
            parms.msys = measparms;

            % Check meas sys type dummy signs
            softAssert(sign(parms.msys.bstartAR(10))==1,['ASVAB AR type dummy not positive; coef is: ',num2str(parms.msys.bstartAR(10))]);
            softAssert(sign(parms.msys.bstartCS(10))==1,['ASVAB CS type dummy not positive; coef is: ',num2str(parms.msys.bstartCS(10))]);
            softAssert(sign(parms.msys.bstartMK(10))==1,['ASVAB MK type dummy not positive; coef is: ',num2str(parms.msys.bstartMK(10))]);
            softAssert(sign(parms.msys.bstartNO(10))==1,['ASVAB NO type dummy not positive; coef is: ',num2str(parms.msys.bstartNO(10))]);
            softAssert(sign(parms.msys.bstartPC(10))==1,['ASVAB PC type dummy not positive; coef is: ',num2str(parms.msys.bstartPC(10))]);
            softAssert(sign(parms.msys.bstartWK(10))==1,['ASVAB WK type dummy not positive; coef is: ',num2str(parms.msys.bstartWK(10))]);
            softAssert(sign(parms.msys.bstartSATm(10))==1,['SAT math type dummy not positive; coef is: ',num2str(parms.msys.bstartSATm(10))]);
            softAssert(sign(parms.msys.bstartSATv(10))==1,['SAT verbal type dummy not positive; coef is: ',num2str(parms.msys.bstartSATv(10))]);
            softAssert(sign(parms.msys.bstartLS(10))==-1,['Late for School type dummy not negative; coef is: ',num2str(parms.msys.bstartLS(10))]);
            softAssert(sign(parms.msys.bstartBR(10))==-1,['Break Rules type dummy not negative; coef is: ',num2str(parms.msys.bstartBR(10))]);
            softAssert(sign(parms.msys.bstartEC(11))== 1,['Extra classes type dummy not positive; coef is: ',num2str(parms.msys.bstartEC(11))]);
            softAssert(sign(parms.msys.bstartTB(11))==-1,['Took classes during break type dummy not negative; coef is: ',num2str(parms.msys.bstartTB(11))]);
            softAssert(sign(parms.msys.bstartRTB(11))==1,['Reason Took Classes during Break type dummy not positive; coef is: ',num2str(parms.msys.bstartRTB(11))]);
            softAssert(sign(parms.msys.bstartHS(11))==1,['High Standards type dummy not positive; coef is: ',num2str(parms.msys.bstartHS(11))]);
            softAssert(sign(parms.msys.bstartDE(11))==1,['Do what is expected type dummy not positive; coef is: ',num2str(parms.msys.bstartDE(11))]);
            softAssert(sign(parms.msys.bstartPWY(11))==1,['Pct Work Youth type dummy not positive; coef is: ',num2str(parms.msys.bstartPWY(11))]);
            softAssert(sign(parms.msys.bstartPWP(11))==1,['Pct Work Parent type dummy not positive; coef is: ',num2str(parms.msys.bstartPWP(11))]);

            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            % M-step: graduation logit
            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            [parms.grl.b] = glmfit(cv.gradlogit(flags.gradl,:), df.grad_4yr_next_yrl(flags.gradl),'binomial','link','logit','constant','off','weights',PTypel(flags.gradl));
            like.grl = likecalc_logit(cv.gradlogit,parms.grl.b,df.grad_4yr_next_yrl,flags.gradl,df.N,df.T,S);

            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            % M-step: log wage and GPA regressions
            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            % white collar
            [parms.wwc.b] = normalMLEfit(parms.wwc.b, cv.wagesWC(flags.wage_wc,:), df.wagesl(flags.wage_wc), PTypel(flags.wage_wc));
            like.wwc = likecalc_normMLE(cv.wagesWC,parms.wwc.b,df.wagesl,flags.wage_wc,df.N,df.T,S);

            % blue collar
            [parms.wbc.b] = normalMLEfit(parms.wbc.b, cv.wagesBC(flags.wage_bc,:), df.wagesl(flags.wage_bc), PTypel(flags.wage_bc));
            like.wbc = likecalc_normMLE(cv.wagesBC,parms.wbc.b,df.wagesl,flags.wage_bc,df.N,df.T,S);

            % 4yr science
            [parms.g4s.b] = normalMLEfit(parms.g4s.b, cv.grades4S(flags.g4s,:), df.gradesl(flags.g4s), PTypel(flags.g4s));
            like.g4s  = likecalc_normMLE(cv.grades4S,parms.g4s.b,df.gradesl,flags.g4s,df.N,df.T,S);

            % 4yr humanities
            [parms.g4h.b] = normalMLEfit(parms.g4h.b, cv.grades4H(flags.g4h,:), df.gradesl(flags.g4h), PTypel(flags.g4h));
            like.g4h  = likecalc_normMLE(cv.grades4H,parms.g4h.b,df.gradesl,flags.g4h,df.N,df.T,S);

            % 2yr
            [parms.g2y.b] = normalMLEfit(parms.g2y.b, cv.grades2Y(flags.g2y,:), df.gradesl(flags.g2y), PTypel(flags.g2y));
            like.g2y  = likecalc_normMLE(cv.grades2Y,parms.g2y.b,df.gradesl,flags.g2y,df.N,df.T,S);
                
            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            % M-step: choice logits
            %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            % college yes/no
            [parms.col.b] = glmfit(cv.colllogit(flags.baseflag,:), df.in_collegel(flags.baseflag),'binomial','link','logit','constant','off','weights',PTypel(flags.baseflag));
            like.cl = likecalc_logit(cv.colllogit,parms.col.b,df.in_collegel,flags.baseflag,df.N,df.T,S);

            % 4yr yes/no (given college)
            [parms.c24.b] = glmfit(cv.c24logit(flags.c24l,:), df.in_4yrl(flags.c24l),'binomial','link','logit','constant','off','weights',PTypel(flags.c24l));
            like.c24l = likecalc_logit(cv.c24logit,parms.c24.b,df.in_4yrl,flags.c24l,df.N,df.T,S);

            % sci yes/no (given 4yr)
            [parms.csc.b] = glmfit(cv.csclogit(flags.cscl,:), df.in_scil(flags.cscl),'binomial','link','logit','constant','off','weights',PTypel(flags.cscl));
            like.cscl = likecalc_logit(cv.csclogit,parms.csc.b,df.in_scil,flags.cscl,df.N,df.T,S);

            % work yes/no
            [parms.cls.b] = glmfit(cv.lbsplogit(flags.baseflag,:), df.in_workl(flags.baseflag),'binomial','link','logit','constant','off','weights',PTypel(flags.baseflag));
            like.clsl = likecalc_logit(cv.lbsplogit,parms.cls.b,df.in_workl,flags.baseflag,df.N,df.T,S);

            % work FT or PT (given work)
            [parms.cft.b] = glmfit(cv.wftlogit(flags.cftl,:), df.in_FTl(flags.cftl),'binomial','link','logit','constant','off','weights',PTypel(flags.cftl));
            like.cftl = likecalc_logit(cv.wftlogit,parms.cft.b,df.in_FTl,flags.cftl,df.N,df.T,S);

            % work WC or BC (given work)
            [parms.cwc.b] = glmfit(cv.wwclogit(flags.cwcl,:), df.in_WCl(flags.cwcl),'binomial','link','logit','constant','off','weights',PTypel(flags.cwcl));
            like.cwcl = likecalc_logit(cv.wwclogit,parms.cwc.b,df.in_WCl,flags.cwcl,df.N,df.T,S);
        end
        
        %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        % E-step: update the q's
        %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        % calculate overall likelihood
        like.all = prod3(like.msy,like.grl,like.wwc,like.wbc,like.g4s,like.g4h,like.g2y,like.cl,like.c24l,like.cscl,like.clsl,like.cftl,like.cwcl);
        fflgg = any(like.all<=0,2);
        
        if any(fflgg)
            like.all(like.all<=0) = eps;
            disp(['like.all: replaced ',num2str(sum(fflgg)),' zero-likelihood values with eps'])
        end

        assert(all(all(like.all>0)),'like.all likelihood has zero values');
        assert(~(any(any(like.all<0))),'like.all likelihood has negative values');
        
        % update the posterior probabilities
        [prior,PType,PTypel,jointlike] = typeprob(prior,like.all,df.T,S);

        %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        % update algorithm values
        %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        disp(['Completed iteration ',num2str(iteration)]);
        disp(['Time spent: ',num2str(toc(tic_inner)),' seconds']);
        disp(['EM criterion was ',num2str(EMcriter)]);
        disp(['Full likelihood after updating q''s is ',num2str(jointlike)])
        for s=1:S
            disp(['Pr(type==',num2str(s), ') is ',num2str(prior(s))])
        end

        likevec = cat(1,likevec,jointlike);
        if length(likevec)>1
            softAssert(likevec(iteration)>=likevec(iteration-1),'Likelihood decreased!')
        end

        iteration = iteration + 1;
        EMcriter  = norm(PTypel-oPTypel,Inf);
        disp(' ');
        disp(' ');

    end
    parms.prior  = prior;
    parms.PType  = PType;
    parms.PTypel = PTypel;

end