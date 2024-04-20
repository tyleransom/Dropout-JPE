function [staticparms] = run_static_choice(learnparms,learnStruct,dataStruct,A,S,PmajgpaType,interestrate,Clb,CRRA,guess,ipath)
    %------------------------------------------------------------------------------
    % Recover posterior variances
    %------------------------------------------------------------------------------
    priorabilstruct = prior_ability_DDC(learnparms,learnStruct,dataStruct,S);


    %------------------------------------------------------------------------------
    % Estimate the year dummy AR(1) model
    %------------------------------------------------------------------------------
    AR1parms = estimateAR1(learnparms);
    v2struct(AR1parms);


    %------------------------------------------------------------------------------
    % compute expected utility of consumption
    %------------------------------------------------------------------------------
    % Create current and future expected wages (to read into consumption calculation)
    tic
    ewagestruct = createwages_b(dataStruct,priorabilstruct,learnparms,AR1parms,A,S);
    disp(['Time spent constructing expected wages: ',num2str(toc/60),' minutes']);
    % Consumption calculation
    numGpoints = 9;      % number of grid points for trapezoidal integration
    numDraws   = 2000;   % number of draws for monte carlo integration
    tic
    consumpstructMCint = createconsumpMCint_b(dataStruct,ewagestruct,priorabilstruct,learnparms,interestrate,Clb,CRRA,numDraws,AR1parms,S);
    disp(['Time spent constructing expected utility of consumption: ',num2str(toc/60),' minutes']);

    % Consumption mapping to be used in FV compuation
    % data required for consumption mapping
    efc      = kron(ones(S,1),dataStruct.efc); 
    SATmath  = kron(ones(S,1),dataStruct.predSATmathZ); 
    SATverb  = kron(ones(S,1),dataStruct.predSATverbZ); 
    famInc   = kron(ones(S,1),dataStruct.famInc); 
    black    = kron(ones(S,1),dataStruct.black); 
    hispanic = kron(ones(S,1),dataStruct.hispanic); 
    Eloan2   = kron(ones(S,1),dataStruct.E_loan2_18.*(1+interestrate).^(dataStruct.yrsSinceHS)); 
    Eloan4   = kron(ones(S,1),dataStruct.E_loan4_18.*(1+interestrate).^(dataStruct.yrsSinceHS)); 
    gr2pridx = kron(ones(S,1),dataStruct.grant2pr); 
    gr4pridx = kron(ones(S,1),dataStruct.grant4pr); 
    gr2idx   = kron(ones(S,1),dataStruct.grant2idx); 
    gr4idx   = kron(ones(S,1),dataStruct.grant4idx); 
    pt2pridx = kron(ones(S,1),dataStruct.prParTrans2); 
    pt4pridx = kron(ones(S,1),dataStruct.prParTrans4); 
    pt2idx   = kron(ones(S,1),dataStruct.idxParTrans2); 
    pt4idx   = kron(ones(S,1),dataStruct.idxParTrans4); 
    gr2pridx = log(gr2pridx./(1-gr2pridx));
    gr4pridx = log(gr4pridx./(1-gr4pridx));
    pt2pridx = log(pt2pridx./(1-pt2pridx));
    pt4pridx = log(pt4pridx./(1-pt4pridx));
    age      = kron(ones(S,1),dataStruct.age); 

    pt4idxt1   = pt4idx - 0.095542;                   % 4yr PT age coefficient = -0.095542
    pt2idxt1   = pt2idx - 0.0595774;                  % 2yr PT age coefficient = -0.0595774 
    pt4pridxt1 = pt4pridx - 0.3316555;                % 4yr PT>0 logit age coefficient = -0.3316555
    pt2pridxt1 = pt2pridx - 0.3034261;                % 2yr PT>0 logit age coefficient = -0.3034261 

    pt4idxt2   = pt4idx - 2*0.095542;                 % 4yr PT age coefficient = -0.095542   
    pt2idxt2   = pt2idx - 2*0.0595774;                % 2yr PT age coefficient = -0.0595774  
    pt4pridxt2 = pt4pridx - 2*0.3316555;              % 4yr PT>0 logit age coefficient = -0.3316555 
    pt2pridxt2 = pt2pridx - 2*0.3034261;              % 2yr PT>0 logit age coefficient = -0.3034261  

    % create mapping between naive consumption and integrated consumption
    [cmap_nograd,cmap_nograd_work,cmap_grad_work,r2_nograd,r2_nograd_work,r2_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work] = mapconsump(consumpstructMCint,dataStruct.grad_4yrl,PmajgpaType,gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridx,pt4pridx,pt2idx,pt4idx,Eloan2,Eloan4);
    cmapStruct = struct('gr2pridx',gr2pridx,'gr4pridx',gr4pridx,'gr2idx',gr2idx,'gr4idx',gr4idx,'pt2pridx',pt2pridx,'pt4pridx',pt4pridx,'pt2idx',pt2idx,'pt4idx',pt4idx,'Eloan2',Eloan2,'Eloan4',Eloan4);
    save(strcat(ipath,'cmapoutput_',num2str(guess),'.mat'),'cmap_nograd','cmap_nograd_work','cmap_grad_work','r2_nograd','r2_nograd_work','r2_grad_work','scaler_nograd','scaler_nograd_work','scaler_grad_work'); 

    % create mapping between naive consumption and integrated consumption in t+1 (E_t[C_{t+1}])
    [cmap_nograd,cmap_nograd_work,cmap_grad_work,r2_nograd,r2_nograd_work,r2_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work] = mapconsump_t1(consumpstructMCint,dataStruct.grad_4yrl,PmajgpaType,gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridxt1,pt4pridxt1,pt2idxt1,pt4idxt1,Eloan2,Eloan4);
    cmapStruct = struct('gr2pridx',gr2pridx,'gr4pridx',gr4pridx,'gr2idx',gr2idx,'gr4idx',gr4idx,'pt2pridx',pt2pridxt1,'pt4pridx',pt4pridxt1,'pt2idx',pt2idxt1,'pt4idx',pt4idxt1,'Eloan2',Eloan2,'Eloan4',Eloan4);
    save(strcat(ipath,'cmapoutput_t1_',num2str(guess),'.mat'),'cmap_nograd','cmap_nograd_work','cmap_grad_work','r2_nograd','r2_nograd_work','r2_grad_work','scaler_nograd','scaler_nograd_work','scaler_grad_work'); 

    % create mapping between naive consumption and integrated consumption in t+1 (E_t[C_{t+2}])
    [cmap_nograd,cmap_nograd_work,cmap_grad_work,r2_nograd,r2_nograd_work,r2_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work] = mapconsump_t2(consumpstructMCint,dataStruct.grad_4yrl,PmajgpaType,gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridxt2,pt4pridxt2,pt2idxt2,pt4idxt2,Eloan2,Eloan4);
    cmapStruct = struct('gr2pridx',gr2pridx,'gr4pridx',gr4pridx,'gr2idx',gr2idx,'gr4idx',gr4idx,'pt2pridx',pt2pridxt2,'pt4pridx',pt4pridxt2,'pt2idx',pt2idxt2,'pt4idx',pt4idxt2,'Eloan2',Eloan2,'Eloan4',Eloan4);
    save(strcat(ipath,'cmapoutput_t2_',num2str(guess),'.mat'),'cmap_nograd','cmap_nograd_work','cmap_grad_work','r2_nograd','r2_nograd_work','r2_grad_work','scaler_nograd','scaler_nograd_work','scaler_grad_work'); 


    %------------------------------------------------------------------------------
    % Create future flow utility terms (to read into search friction model)
    %------------------------------------------------------------------------------
    %save(strcat(ipath,'allbefcreatestaticXmat',num2str(guess),'.mat'),'-v7.3');
    tic
    Utilstruct = createfutureflowsconsump_b(dataStruct,priorabilstruct,consumpstructMCint,0,A,S,interestrate,CRRA); % initialize Beta argument as 0
    Utilstruct.ClImps        = dataStruct.Yl;
    Utilstruct.grad_4yrlImps = dataStruct.grad_4yrl;
    disp(['Time spent constructing future flow utility terms: ',num2str(toc/60),' minutes']);


    %------------------------------------------------------------------------------
    % Estimate the search friction choice model (via EM algorithm)
    %------------------------------------------------------------------------------
    tic
    test = false;
    restart = false; % indicator for if previous starting values should be re-used
    searchparms = estimatejointsearchconsumpWCabsorb(Utilstruct,PmajgpaType,guess,S,restart,ipath);
    v2struct(searchparms);
    disp(['Time spent running search estimation: ',num2str(toc/3600),' hours']);

    staticparms = struct('searchparms',searchparms,'AR1parms',AR1parms,'Utilstruct',Utilstruct,'consumpstructMCint',consumpstructMCint,'lambda',lambda);
    %save(strcat(ipath,'static_small_',num2str(guess),'.mat'),'dataStruct','AR1parms','S','searchparms','learnparms','Clb','CRRA');
end
