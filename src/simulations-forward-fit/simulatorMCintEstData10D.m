% Steps to perform simulation

% 1. Load data and parameters
clear; clc;
addpath 'functions/'
% File path for saving and loading results
ipath = '../../output/';
D = 10;
diary([ipath,'model-fit/simulatorMCintEstData10D_',num2str(D),'rep.diary']);
seed = 1234;
rng(seed,'twister');

[status,cmdout] = system(['ls -t ',ipath,'all-stage-1/everything_all_stage1_interact_type_*.mat | head -1'],'-echo');
ffffff = strtrim(cmdout);
load(ffffff,'prior');
[status,cmdout] = system(['ls -t ',ipath,'utility/everything_jointsearch_WCabsorb*.mat | head -1'],'-echo');
ffffff = strtrim(cmdout);
load(ffffff,'dataStruct','searchparms','gradparms','AR1parms','S','learnparms','Clb','CRRA','PmajgpaType'); % has the following: 'searchparms','AR1parms','Searchstruct','Utilstruct','PmajgpaType','sPmajgpaType','S','dataStruct','priorabilstruct','consumpstructMCint','ngpct','learnStruct','learnparms','Clb','CRRA'
cmapParms   = load([ipath,'utility/cmapoutput.mat']); 
cmapParmst1 = load([ipath,'utility/cmapoutput_t1.mat']); 
cmapParmst2 = load([ipath,'utility/cmapoutput_t2.mat']); 
P_grad_betas4 = gradparms.P_grad_betas4;
[status,cmdout] = system(['ls -t ',ipath,'utility/everything_consumpstructural_FVfast*.mat | head -1'],'-echo');
gggggg = strtrim(cmdout);
load(gggggg);
sigNormed=cat(1,learnparms.sig(1),learnparms.lambdag1start^2*learnparms.sig(2),learnparms.sig(3),learnparms.lambdan1start^2*learnparms.sig(4),learnparms.sig(5:6),learnparms.lambda4s1start^2*learnparms.sig(7:9),learnparms.sig(10:11),learnparms.lambda4h1start^2*learnparms.sig(12:14),learnparms.sig(15:17));
learnparms.Delta = tril(learnparms.Delta,-1)+tril(learnparms.Delta,-1)'+diag(diag(learnparms.Delta));

% 2. Initialize state variables (no experience)
% Read in demographic variables ((N*T)x1 vectors)
dataStruct.HS_gradesw = reshape(dataStruct.HS_grades,dataStruct.T,dataStruct.N)';
dataStruct.HS_gradesw = dataStruct.HS_gradesw(:,1);
dataStruct.anyFlagw = reshape(dataStruct.anyFlag,dataStruct.T,dataStruct.N)';
demog  = [dataStruct.blackw dataStruct.hispanicw dataStruct.HS_gradesw dataStruct.Parent_collegew dataStruct.birthYrw==1980 dataStruct.birthYrw==1981 dataStruct.birthYrw==1982 dataStruct.birthYrw==1983 dataStruct.famIncw];
flagly = any(dataStruct.anyFlagw==0,2);
num_per = sum(dataStruct.anyFlagw==0,2);
ider = dataStruct.NLS_ID(flagly);
num_per = num_per(flagly);
temp = [[1:sum(flagly)]' ider dataStruct.blackw(flagly) dataStruct.hispanicw(flagly) dataStruct.HS_gradesw(flagly) dataStruct.Parent_collegew(flagly) dataStruct.birthYrw(flagly) dataStruct.famIncw(flagly)];
%writematrix(temp,'demogs_with_NLS_ID.csv');
dlmwrite([ipath,'model-fit/demogs_with_NLS_ID.csv'],temp,',');
system(['sed  -i ''1i rownum,NLS_ID,black,hispanic,HS_grades,Parent_college,birthYr,famInc'' ',ipath,'model-fit/demogs_with_NLS_ID.csv']);

% Reshape the consumption input data
currStates.tui4imp       = reshape(dataStruct.tui4imp      ,dataStruct.T,dataStruct.N)';
currStates.grant4pr      = reshape(dataStruct.grant4pr     ,dataStruct.T,dataStruct.N)';
currStates.loan4pr       = reshape(dataStruct.loan4pr      ,dataStruct.T,dataStruct.N)';
currStates.grant4RMSE    = reshape(dataStruct.grant4RMSE   ,dataStruct.T,dataStruct.N)';
currStates.loan4RMSE     = reshape(dataStruct.loan4RMSE    ,dataStruct.T,dataStruct.N)';
currStates.grant4idx     = reshape(dataStruct.grant4idx    ,dataStruct.T,dataStruct.N)';
currStates.loan4idx      = reshape(dataStruct.loan4idx     ,dataStruct.T,dataStruct.N)';
currStates.tui2imp       = reshape(dataStruct.tui2imp      ,dataStruct.T,dataStruct.N)';
currStates.grant2pr      = reshape(dataStruct.grant2pr     ,dataStruct.T,dataStruct.N)';
currStates.loan2pr       = reshape(dataStruct.loan2pr      ,dataStruct.T,dataStruct.N)';
currStates.grant2RMSE    = reshape(dataStruct.grant2RMSE   ,dataStruct.T,dataStruct.N)';
currStates.loan2RMSE     = reshape(dataStruct.loan2RMSE    ,dataStruct.T,dataStruct.N)';
currStates.grant2idx     = reshape(dataStruct.grant2idx    ,dataStruct.T,dataStruct.N)';
currStates.loan2idx      = reshape(dataStruct.loan2idx     ,dataStruct.T,dataStruct.N)';
currStates.ParTrans2RMSE = reshape(dataStruct.ParTrans2RMSE,dataStruct.T,dataStruct.N)';
currStates.ParTrans4RMSE = reshape(dataStruct.ParTrans4RMSE,dataStruct.T,dataStruct.N)';
currStates.E_loan4_18    = reshape(dataStruct.E_loan4_18   ,dataStruct.T,dataStruct.N)';
currStates.E_loan2_18    = reshape(dataStruct.E_loan2_18   ,dataStruct.T,dataStruct.N)';
currStates.lnFamInc      = reshape(dataStruct.lnFamInc     ,dataStruct.T,dataStruct.N)';
currStates.sage          = reshape(dataStruct.age          ,dataStruct.T,dataStruct.N)';
currStates.startyr       = reshape(dataStruct.year         ,dataStruct.T,dataStruct.N)';
Clper                    = reshape(dataStruct.Clp          ,dataStruct.T,dataStruct.N)'; 
ageidx                   = isnan(Clper) | Clper>0;
ageidxer                 = cumsum(ageidx,2).*ageidx;
currStates.tui4imp       = currStates.tui4imp(flagly,1);
currStates.grant4pr      = currStates.grant4pr(flagly,1);
currStates.loan4pr       = currStates.loan4pr(flagly,1);
currStates.grant4RMSE    = currStates.grant4RMSE(flagly,1);
currStates.loan4RMSE     = currStates.loan4RMSE(flagly,1);
currStates.grant4idx     = currStates.grant4idx(flagly,1);
currStates.loan4idx      = currStates.loan4idx(flagly,1);
currStates.tui2imp       = currStates.tui2imp(flagly,1);
currStates.grant2pr      = currStates.grant2pr(flagly,1);
currStates.loan2pr       = currStates.loan2pr(flagly,1);
currStates.grant2RMSE    = currStates.grant2RMSE(flagly,1);
currStates.loan2RMSE     = currStates.loan2RMSE(flagly,1);
currStates.grant2idx     = currStates.grant2idx(flagly,1);
currStates.loan2idx      = currStates.loan2idx(flagly,1);
currStates.ParTrans2RMSE = currStates.ParTrans2RMSE(flagly,1);
currStates.ParTrans4RMSE = currStates.ParTrans4RMSE(flagly,1);
currStates.E_loan4_18    = currStates.E_loan4_18(flagly,1);
currStates.E_loan2_18    = currStates.E_loan2_18(flagly,1);
currStates.lnFamInc      = currStates.lnFamInc(flagly,1);
currStates.startyr       = currStates.startyr(ageidxer==1);
currStates.sage          = currStates.sage(ageidxer==1);

T = 19;
S = 8;
J = size(learnparms.Delta,1);
numMCdraws = 2000;
numDraws = 10;
Beta = .9;
intrate = .05;
N = sum(flagly==1);
wcidx = [2 4 7 9 12 14 17 19];
bcidx = [1 3 6 8 11 13 16 18];
ngbcidx = setdiff(1:20,wcidx);
gbcidx = setdiff(16:20,wcidx);
% time-invariant state variables:
obsvbls = demog(flagly==1,:); % collapse duplicates
summarize(obsvbls);
tabulate(obsvbls(:,3));

idelta = learnparms.Delta\eye(J,J);
currStates.ideltaMat = repmat(reshape(idelta,[1 J J]),[N 1 1]);
currStates.T = T;

% initialize final state matrices
YmatD               = nan(N,T,D);
offerD              = nan(N,T,D);
grad_4yrD           = nan(N,T,D);
ageD                = nan(N,T,D);
experD              = nan(N,T,D);
exper_white_collarD = nan(N,T,D);
cum_2yrD            = nan(N,T,D);
cum_4yrD            = nan(N,T,D);
prev_HSD            = nan(N,T,D);
prev_2yrD           = nan(N,T,D);
prev_4yrSD          = nan(N,T,D);
prev_4yrNSD         = nan(N,T,D);
prev_PTD            = nan(N,T,D);
prev_FTD            = nan(N,T,D);
prev_WCD            = nan(N,T,D);
yearD               = nan(N,T,D);
trueAbilD           = nan(N,J,D);
finalMajorSciD      = nan(N,D);
typeD               = nan(N,D);
idioMatD            = nan(N,J,T,D);
priorAbilMatD       = nan(N,J,T,D);
priorVarMatD        = nan(N,J,J,T,D);
posteriorAbilMatD   = nan(N,J,T,D);
posteriorVarMatD    = nan(N,J,J,T,D);
blackD              = nan(N,D);
hispanicD           = nan(N,D);
HS_gradesD          = nan(N,D);
Parent_collegeD     = nan(N,D);
born1980D           = nan(N,D);
born1981D           = nan(N,D);
born1982D           = nan(N,D);
born1983D           = nan(N,D);
famIncD             = nan(N,D);

meanAdjNoGrad = zeros(20,T,D);
meanAdjGrad   = zeros(20,T,D);
for d=1:D
    disp('');
    disp('***********************************************');
    disp(['* DRAW NUMBER: ',num2str(d)]);
    disp('***********************************************');
    disp('');
    %3. Draw unobserved type and unobserved ability
    draw = rand(N,1);
    utype = zeros(N,1);
    for s=1:S
        temp = (draw<sum(prior(:,s:end),2));
        utype=temp+utype;
    end
    trueAbil = mvnrnd(zeros(N,5),learnparms.Delta);
    
    %4. Initialize endogenous state variables
    finalMajorSci      = 0*ones(N,1);
    prior_ability_2    = 0*ones(N,T);
    prior_ability_4NS  = 0*ones(N,T);
    prior_ability_4S   = 0*ones(N,T);
    prior_ability_U    = 0*ones(N,T);
    prior_ability_S    = 0*ones(N,T);
    age                = 0*ones(N,T); % everyone starts out as an 18-year-old
    age(:,1)           = currStates.sage;
    exper              = 0*ones(N,T);
    exper_white_collar = 0*ones(N,T);
    offer              = 0*ones(N,T);
    grad_4yr           = 0*ones(N,T);
    cum_2yr            = 0*ones(N,T);
    cum_4yr            = 0*ones(N,T);
    prev_HS            = 1*ones(N,T);
    prev_2yr           = 0*ones(N,T);
    prev_4yrS          = 0*ones(N,T);
    prev_4yrNS         = 0*ones(N,T);
    prev_PT            = 0*ones(N,T);
    prev_FT            = 0*ones(N,T);
    prev_WC            = 0*ones(N,T);
    year               = ones(N,1)*[1997:1997+(T-1)];
    year(:,1)          = currStates.startyr;
    Ymat               = zeros(N,T);

    % Put these in a structure to easily pass on to other functions
    currStates.utype                    = utype;
    currStates.black                    = obsvbls(:,1);
    currStates.hispanic                 = obsvbls(:,2);
    currStates.HS_grades                = obsvbls(:,3);
    currStates.Parent_college           = obsvbls(:,4);
    currStates.born1980                 = obsvbls(:,5);
    currStates.born1981                 = obsvbls(:,6);
    currStates.born1982                 = obsvbls(:,7);
    currStates.born1983                 = obsvbls(:,8);
    currStates.famInc                   = obsvbls(:,9);
    priorabilstruct.prior_ability_2     = 0*ones(N,1);
    priorabilstruct.prior_ability_4NS   = 0*ones(N,1);
    priorabilstruct.prior_ability_4S    = 0*ones(N,1);
    priorabilstruct.prior_ability_U     = 0*ones(N,1);
    priorabilstruct.prior_ability_S     = 0*ones(N,1);
    currStates.age                      = age(:,1); %0*ones(N,1); % everyone starts out as an 18-year-old
    currStates.exper                    = 0*ones(N,1);
    currStates.exper_white_collar       = 0*ones(N,1);
    currStates.finalMajorSci            = 0*ones(N,1);
    currStates.grad_4yr                 = 0*ones(N,1);
    currStates.cum_2yr                  = 0*ones(N,1);
    currStates.cum_4yr                  = 0*ones(N,1);
    currStates.yct                      = 1*ones(N,1);
    currStates.prev_HS                  = 1*ones(N,1);
    currStates.prev_2yr                 = 0*ones(N,1);
    currStates.prev_4yrS                = 0*ones(N,1);
    currStates.prev_4yrNS               = 0*ones(N,1);
    currStates.prev_PT                  = 0*ones(N,1);
    currStates.prev_FT                  = 0*ones(N,1);
    currStates.prev_WC                  = 0*ones(N,1);
    currStates.year                     = year(:,1);
    currStates.N                        = N;
    
    priorAbilMat            = zeros(N,J,T);
    priorVarMat             = zeros(N,J,J,T);
    psiPriorMat             = zeros(N,J,J,T);
    posteriorAbilMat        = zeros(N,J,T);
    posteriorVarMat         = zeros(N,J,J,T);
    psiPosteriorMat         = zeros(N,J,J,T);
    priorAbilMat(:,:,1)     = zeros(N,J);
    priorVarMat(:,:,:,1)    = repmat(reshape(learnparms.Delta,[1 J J]),N,1);
    psiPriorMat(:,:,:,1)    = zeros(N,J,J);
    
    for t=1:T
        disp(['t = ',num2str(t)]);
        % generate offers
        offer(:,t) = offerUpdate(currStates,searchparms.boffer);
        disp(['average offer probability: ',num2str(mean(offer(:,t)))]);
        
        yct = cum_4yr(:,t)+cum_2yr(:,t)+1;
        priorabilstruct.Psipriormat   = squeeze(psiPriorMat(:,:,:,t));
        priorabilstruct.vabilpriormat = squeeze(priorVarMat(:,:,:,t));
        priorabilstruct.abilpriormat  = squeeze(priorAbilMat(:,:,t));
        
        % create expected wages (for use in CCP FV terms)
        ewagestruct = createwages(currStates,priorabilstruct,learnparms,AR1parms,S);
        
        % create expected consumption (for use in CCP FV terms)
        consumpstructMCint = createconsumpMCint(currStates,ewagestruct,priorabilstruct,learnparms,intrate,Clb,CRRA,numMCdraws,AR1parms,S,t);
        
        % create expected consumption (for use in flow utility terms)
        consumpstructMCintUtil = createconsumpMCint(currStates,ewagestruct,priorabilstruct,learnparms,intrate,Clb,CRRA,numMCdraws,AR1parms,S,t);
        
        % create matrices of covariates that enter CCPs
        Utilstruct = createfutureflowsconsump(currStates,priorabilstruct,consumpstructMCint,0,S,intrate,t,CRRA); % initialize Beta argument as 0
        
        % compute FV terms
        [AdjNoGrad,AdjGrad] = formFVfricIntFast(Beta,Utilstruct,searchparms.boffer,P_grad_betas4,currStates,priorabilstruct,learnparms,AR1parms,S,Clb,CRRA,intrate,numDraws,searchparms.bstrucsearch,cmapParms,cmapParmst1,cmapParmst2,t,d);
        meanAdjNoGrad(:,t,d) = mean(AdjNoGrad,1);
        meanAdjGrad(:,t,d)   = mean(AdjGrad,1);
        
        % create current- and future flow utility matrices, then plug into structural probability function
        gradprobdiff = creategprobdiffs(currStates,priorabilstruct,P_grad_betas4);
        Utilstruct = createfutureflowsconsumpstruct(currStates,priorabilstruct,consumpstructMCintUtil,Beta,S,CRRA);
        P = consumpsearchstrucplogit(strucparms.bstrucstruc,offer(:,t),Utilstruct,currStates.grad_4yr,gradprobdiff,AdjNoGrad,AdjGrad,Utilstruct.sdemog,S,Beta);

        %5. Draw choices
        draw  = rand(N,1);
        Yngno = zeros(N,1);
        Ygno  = zeros(N,1);
        Yngo  = zeros(N,1);
        Ygo   = zeros(N,1);
        for j=ngbcidx
            Ytemp = (draw<sum(P(:,j:end),2));
            Yngno=Ytemp+Yngno;
        end
        for j=1:20
            Ytemp = (draw<sum(P(:,j:end),2));
            Yngo=Ytemp+Yngo;
        end
        for j=gbcidx
            Ytemp = (draw<sum(P(:,j:end),2));
            Ygno=Ytemp+Ygno;
        end
        for j=16:20
            Ytemp = (draw<sum(P(:,j:end),2));
            Ygo=Ytemp+Ygo;
        end
        ngnoflag = offer(:,t)==0 & grad_4yr(:,t)==0;
        gnoflag  = offer(:,t)==0 & grad_4yr(:,t)==1;
        ngoflag  = offer(:,t)==1 & grad_4yr(:,t)==0;
        goflag   = offer(:,t)==1 & grad_4yr(:,t)==1;
        Yngno(ngnoflag) = ngbcidx(Yngno(ngnoflag));
        Ygno(gnoflag)   = gbcidx(Ygno(gnoflag));
        Ygo = Ygo+15;
        Y = Yngno.*ngnoflag+Ygno.*gnoflag+Yngo.*ngoflag+Ygo.*goflag;
        Ymat(:,t) = Y;
        
        
        %6. Draw idiosyncratic outcome shocks based on whatever choice was made
        var = sigNormed(1).*(ismember(Ymat(:,t),[17 19]))+sigNormed(2).*(ismember(Ymat(:,t),[2 4 7 9 12 14]));
        idio(:,1,t) = normrnd(0,sqrt(var),N,1).*(ismember(Ymat(:,t),wcidx));
        var = sigNormed(3).*(ismember(Ymat(:,t),[16 18]))+sigNormed(4).*(ismember(Ymat(:,t),[1 3 6 8 11 13]));
        idio(:,2,t) = normrnd(0,sqrt(var),N,1).*(ismember(Ymat(:,t),bcidx));
        var = sigNormed(5).*(yct==1)+sigNormed(6).*(yct==2)+sigNormed(7).*(yct==3)+sigNormed(8).*(yct==4)+sigNormed(9).*(yct>=5);
        idio(:,3,t) = normrnd(0,sqrt(var),N,1).*(grad_4yr(:,t)==0).*(ismember(Ymat(:,t),[6:10]));
        var = sigNormed(10).*(yct==1)+sigNormed(11).*(yct==2)+sigNormed(12).*(yct==3)+sigNormed(13).*(yct==4)+sigNormed(14).*(yct>=5);
        idio(:,4,t) = normrnd(0,sqrt(var),N,1).*(grad_4yr(:,t)==0).*(ismember(Ymat(:,t),[11:15]));
        var = sigNormed(15).*(yct==1)+sigNormed(16).*(yct==2)+sigNormed(17).*(yct>=3);
        idio(:,5,t) = normrnd(0,sqrt(var),N,1).*(grad_4yr(:,t)==0).*(ismember(Ymat(:,t),[1:5]));
        
        signal(:,:,t) = idio(:,:,t)+trueAbil;
        % set the signal to be zero if the choice is unobserved
        obsMat(:,1) = ismember(Ymat(:,t),wcidx);
        obsMat(:,2) = ismember(Ymat(:,t),bcidx);
        obsMat(:,3) = ismember(Ymat(:,t),[6:10]);
        obsMat(:,4) = ismember(Ymat(:,t),[11:15]);
        obsMat(:,5) = ismember(Ymat(:,t),[1:5]);
        signal(:,:,t) = signal(:,:,t).*obsMat;
        

        %7. Update state variables
        % update prior abilities
        [posteriorAbilMat(:,:,t),posteriorVarMat(:,:,:,t),psiPosteriorMat(:,:,:,t)] = posteriorVecPsi(priorAbilMat(:,:,t),priorVarMat(:,:,:,t),sigNormed,signal(:,:,t),Ymat(:,t),Ymat(:,1:t),currStates,learnparms.Delta);
        priorAbilMat   (:,:,t+1) = posteriorAbilMat(:,:,t);
        priorVarMat  (:,:,:,t+1) = posteriorVarMat(:,:,:,t);
        psiPriorMat  (:,:,:,t+1) = psiPosteriorMat(:,:,:,t);
        prior_ability_2  (:,t+1) = posteriorAbilMat(:,5,t);
        prior_ability_4NS(:,t+1) = posteriorAbilMat(:,4,t);
        prior_ability_4S (:,t+1) = posteriorAbilMat(:,3,t);
        prior_ability_U  (:,t+1) = posteriorAbilMat(:,2,t);
        prior_ability_S  (:,t+1) = posteriorAbilMat(:,1,t);
        
        % update graduation status
        grad_4yr(:,t+1) = gradUpdate(grad_4yr(:,t),Ymat(:,t),currStates,priorabilstruct,P_grad_betas4);
        
        % update other endogenous state variables
        age               (:,t+1) = age(:,t)+1;
        exper             (:,t+1) = exper(:,t)             +(ismember(Ymat(:,t),[1:2 6:7 11:12 18:19]))+.5*(ismember(Ymat(:,t),[3:4 8:9 13:14 16:17]));
        exper_white_collar(:,t+1) = exper_white_collar(:,t)+(ismember(Ymat(:,t),[2 7 12 19]))+.5*(ismember(Ymat(:,t),[4 9 14 17]));
        cum_2yr           (:,t+1) = cum_2yr(:,t)+(ismember(Ymat(:,t),[1:5]));
        cum_4yr           (:,t+1) = cum_4yr(:,t)+(ismember(Ymat(:,t),[6:15]));
        prev_HS           (:,t+1) = zeros(N,1);
        prev_2yr          (:,t+1) = (ismember(Ymat(:,t),[1:5]));
        prev_4yrS         (:,t+1) = (ismember(Ymat(:,t),[6:10]));
        prev_4yrNS        (:,t+1) = (ismember(Ymat(:,t),[11:15]));
        prev_PT           (:,t+1) = (ismember(Ymat(:,t),[3:4 8:9 13:14 16:17]));
        prev_FT           (:,t+1) = (ismember(Ymat(:,t),[1:2 6:7 11:12 18:19]));
        prev_WC           (:,t+1) = (ismember(Ymat(:,t),[2 4 7 9 12 14 17 19]));
        year              (:,t+1) = year(:,t)+1;
        finalMajorSci(grad_4yr(:,t+1)==1 & grad_4yr(:,t)==0 & ismember(Ymat(:,t),[6:10]))=1;
        
        % update structure
        priorabilstruct.prior_ability_2   = prior_ability_2  (:,t+1);
        priorabilstruct.prior_ability_4NS = prior_ability_4NS(:,t+1);
        priorabilstruct.prior_ability_4S  = prior_ability_4S (:,t+1);
        priorabilstruct.prior_ability_U   = prior_ability_U  (:,t+1);
        priorabilstruct.prior_ability_S   = prior_ability_S  (:,t+1);
        currStates.age                    = age              (:,t+1);
        currStates.exper                  = exper            (:,t+1);
        currStates.exper_white_collar     = exper_white_collar(:,t+1);
        currStates.grad_4yr               = grad_4yr         (:,t+1);
        currStates.cum_2yr                = cum_2yr          (:,t+1);
        currStates.cum_4yr                = cum_4yr          (:,t+1);
        currStates.yct                    = currStates.cum_2yr + currStates.cum_4yr + 1;
        currStates.prev_HS                = prev_HS          (:,t+1);
        currStates.prev_2yr               = prev_2yr         (:,t+1);
        currStates.prev_4yrS              = prev_4yrS        (:,t+1);
        currStates.prev_4yrNS             = prev_4yrNS       (:,t+1);
        currStates.prev_PT                = prev_PT          (:,t+1);
        currStates.prev_FT                = prev_FT          (:,t+1);
        currStates.prev_WC                = prev_WC          (:,t+1);
        currStates.year                   = year             (:,t+1);
    end
    YmatD               (:,:,d) = Ymat(:,1:T);
    offerD              (:,:,d) = offer(:,1:T);
    grad_4yrD           (:,:,d) = grad_4yr(:,1:T);
    ageD                (:,:,d) = age(:,1:T);
    experD              (:,:,d) = exper(:,1:T);
    exper_white_collarD (:,:,d) = exper_white_collar(:,1:T);
    cum_2yrD            (:,:,d) = cum_2yr(:,1:T);
    cum_4yrD            (:,:,d) = cum_4yr(:,1:T);
    prev_HSD            (:,:,d) = prev_HS(:,1:T);
    prev_2yrD           (:,:,d) = prev_2yr(:,1:T);
    prev_4yrSD          (:,:,d) = prev_4yrS(:,1:T);
    prev_4yrNSD         (:,:,d) = prev_4yrNS(:,1:T);
    prev_PTD            (:,:,d) = prev_PT(:,1:T);
    prev_FTD            (:,:,d) = prev_FT(:,1:T);
    prev_WCD            (:,:,d) = prev_WC(:,1:T);
    yearD               (:,:,d) = year(:,1:T);
    trueAbilD           (:,:,d) = trueAbil;
    finalMajorSciD      (  :,d) = finalMajorSci;
    typeD               (  :,d) = utype;
    idioMatD          (:,:,:,d) = idio(:,:,1:T);
    priorAbilMatD     (:,:,:,d) = priorAbilMat(:,:,1:T);
    priorVarMatD    (:,:,:,:,d) = priorVarMat(:,:,:,1:T);
    posteriorAbilMatD (:,:,:,d) = posteriorAbilMat(:,:,1:T);
    posteriorVarMatD(:,:,:,:,d) = posteriorVarMat(:,:,:,1:T);
    blackD                (:,d) = currStates.black;
    hispanicD             (:,d) = currStates.hispanic;
    HS_gradesD            (:,d) = currStates.HS_grades;
    Parent_collegeD       (:,d) = currStates.Parent_college;
    born1980D             (:,d) = currStates.born1980;
    born1981D             (:,d) = currStates.born1981;
    born1982D             (:,d) = currStates.born1982;
    born1983D             (:,d) = currStates.born1983;
    famIncD               (:,d) = currStates.famInc  ;
end

for d=1:D
    temp             = YmatD(:,:,d);
    tabs             = tabulate(temp(:));
    tabsnograd       = tabulate(temp(grad_4yrD(:,:,d)==0));
    tabsgrad         = tabulate(temp(grad_4yrD(:,:,d)==1));
    freqD(:,d)       = tabs(:,3)./100;
    freqnogradD(:,d) = tabsnograd(:,3)./100;
    freqgradD(:,d)   = tabsgrad(:,3)./100;
end

save('-v7.3',[ipath,'model-fit/simDataMCintEstData10D_',num2str(D),'rep.mat'],'*D*','meanAdj*');

% summary stats of average FV terms
summarize(squeeze(meanAdjNoGrad(:,1,:))');
summarize(squeeze(meanAdjGrad(:,1,:))');

% reshape and export to csv
iderDl = repmat(repmat(ider,1,T),1,1,D);
numperDl = repmat(repmat(num_per,1,T),1,1,D);
periodDl = repmat(repmat([1:T],N,1),1,1,D);
drawDl = repmat(reshape(repmat([1:D],N,1),[N 1 D]),[1 T 1]);
typeDl = repmat(reshape(typeD,[N 1 D]),[1 T 1]);
famIncDl = repmat(reshape(famIncD,[N 1 D]),[1 T 1]);
blackDl = repmat(reshape(blackD,[N 1 D]),[1 T 1]); 
hispanicDl = repmat(reshape(hispanicD,[N 1 D]),[1 T 1]);  
HS_gradesDl = repmat(reshape(HS_gradesD,[N 1 D]),[1 T 1]);   
Parent_collegeDl = repmat(reshape(Parent_collegeD,[N 1 D]),[1 T 1]);    
ttppD = 1980*(born1980D) + 1981*(born1981D) + 1982*(born1982D) + 1983*(born1983D) + 1984*(1-born1980D-born1981D-born1982D-born1983D);
disp('birth year distro');
tabulate(ttppD(:,1));
birthYrDl =  repmat(reshape(ttppD,[N 1 D]),[1 T 1]);     
trueAbil1Dl = repmat(reshape(trueAbilD(:,1,:),[N 1 D]),[1 T 1]);
trueAbil2Dl = repmat(reshape(trueAbilD(:,2,:),[N 1 D]),[1 T 1]);
trueAbil3Dl = repmat(reshape(trueAbilD(:,3,:),[N 1 D]),[1 T 1]);
trueAbil4Dl = repmat(reshape(trueAbilD(:,4,:),[N 1 D]),[1 T 1]);
trueAbil5Dl = repmat(reshape(trueAbilD(:,5,:),[N 1 D]),[1 T 1]);
posteriorAbil1Dl = squeeze(posteriorAbilMatD(:,1,:,:));
posteriorAbil2Dl = squeeze(posteriorAbilMatD(:,2,:,:)); 
posteriorAbil3Dl = squeeze(posteriorAbilMatD(:,3,:,:)); 
posteriorAbil4Dl = squeeze(posteriorAbilMatD(:,4,:,:)); 
posteriorAbil5Dl = squeeze(posteriorAbilMatD(:,5,:,:)); 
posteriorVar1Dl  = squeeze(posteriorVarMatD(:,1,1,:,:));
posteriorVar2Dl  = squeeze(posteriorVarMatD(:,2,2,:,:)); 
posteriorVar3Dl  = squeeze(posteriorVarMatD(:,3,3,:,:)); 
posteriorVar4Dl  = squeeze(posteriorVarMatD(:,4,4,:,:)); 
posteriorVar5Dl  = squeeze(posteriorVarMatD(:,5,5,:,:)); 
posteriorVarMatD    = nan(N,J,J,T,D);

temp = [iderDl(:) periodDl(:) drawDl(:) yearD(:) numperDl(:) typeDl(:) offerD(:) YmatD(:) grad_4yrD(:) trueAbil1Dl(:) trueAbil2Dl(:) trueAbil3Dl(:) trueAbil4Dl(:) trueAbil5Dl(:) posteriorAbil1Dl(:) posteriorAbil2Dl(:) posteriorAbil3Dl(:) posteriorAbil4Dl(:) posteriorAbil5Dl(:) posteriorVar1Dl(:) posteriorVar2Dl(:) posteriorVar3Dl(:) posteriorVar4Dl(:) posteriorVar5Dl(:) blackDl(:) hispanicDl(:) HS_gradesDl(:) Parent_collegeDl(:) birthYrDl(:) famIncDl(:)];
%writematrix(temp,'fwdsimdata.csv');
dlmwrite([ipath,'model-fit/fwdsimdata.csv'],temp,',');

