% Steps to perform parametric bootstrap

%-------------------------------------------------------------------------------
% 0. initialization
%-------------------------------------------------------------------------------
clear; clc;
% map task IDs to bootstrap replication numbers
if isempty(str2num(getenv('SLURM_ARRAY_TASK_ID'))) && isempty(str2num(getenv('SLURM_JOB_ID')))
    guess = 16;
elseif ~isempty(str2num(getenv('SLURM_ARRAY_TASK_ID')))
    guess=str2num(getenv('SLURM_ARRAY_TASK_ID'));
else
    guess=str2num(getenv('SLURM_JOB_ID'));
end
OS = 'cluster';

% random number seed
rng(guess,'twister');

% path to functions
addpath boot-fns/
addpath stage1-fns/
addpath learn-fns/
addpath util-fns/

% path to estimation results
pathmeasys = '../../output/all-stage-1/';
pathlearn  = '../../output/learning/';
pathstatic = '../../output/utility/';
pathpboot  = '../../output/bootstrap/';

% log files
delete(strcat(pathpboot,'parboot',num2str(guess),'.diary'));
diary(strcat(pathpboot,'parboot',num2str(guess),'.diary'));

%-------------------------------------------------------------------------------
% 1. Load (initial conditions) data and parameter estimates from all stages of model
%-------------------------------------------------------------------------------
load('../../output/all-stage-1/everything_all_stage1_interact_type_36688212.mat','prior','parms','PType'); 
load('../../output/all-stage-1/everything_all_stage1_interact_type_37753198.mat','invIDImp'); 
% read in meas sys estimates from CSVs since they didn't get saved in MAT format
schabil = readtable('../../output/all-stage-1/msys-schabil36688212.csv');
parms.msys.bstartAR   = schabil.Var2(1:end-2);
parms.msys.sigAR      = schabil.Var2(end-1);
parms.msys.bstartCS   = schabil.Var3(1:end-2);
parms.msys.sigCS      = schabil.Var3(end-1);
parms.msys.bstartMK   = schabil.Var4(1:end-2);
parms.msys.sigMK      = schabil.Var4(end-1);
parms.msys.bstartNO   = schabil.Var5(1:end-2);
parms.msys.sigNO      = schabil.Var5(end-1);
parms.msys.bstartPC   = schabil.Var6(1:end-2);
parms.msys.sigPC      = schabil.Var6(end-1);
parms.msys.bstartWK   = schabil.Var7(1:end-2);
parms.msys.sigWK      = schabil.Var7(end-1);
parms.msys.bstartSATm = schabil.Var8(1:end-2);
parms.msys.sigSATm    = schabil.Var8(end-1);
parms.msys.bstartSATv = schabil.Var9(1:end-2);
parms.msys.sigSATv    = schabil.Var9(end-1);
schpref = readtable('../../output/all-stage-1/msys-schpref36688212.csv');
parms.msys.bstartLS   = schpref.Var2(2:end-2);
parms.msys.bstartBR   = schpref.Var3(2:end-3);
parms.msys.bstartEC   = schpref.Var4(1:12);
parms.msys.sigEC      = schpref.Var4(end-1);
parms.msys.bstartTB   = schpref.Var5(1:12);
parms.msys.bstartRTB  = schpref.Var6(1:12);
wrkabilpref = readtable('../../output/all-stage-1/msys-wrkabilpref36688212.csv');
parms.msys.bstartHS   = wrkabilpref.Var2(1:end-1);
parms.msys.bstartDE   = wrkabilpref.Var3(1:end-1);
parms.msys.bstartPWY  = wrkabilpref.Var4(1:end-5);
parms.msys.bstartPWP  = wrkabilpref.Var5(1:end-5);
PType = PType(invIDImp,:); % unscramble q's
load('../../output/utility/everything_jointsearch_WCabsorb37595330.mat','dataStruct','searchparms','AR1parms','S','learnparms','gradparms','Clb','CRRA');
cmapParms   = load([pathstatic,'cmapoutput.mat']); 
cmapParmst1 = load([pathstatic,'cmapoutput_t1.mat']); 
cmapParmst2 = load([pathstatic,'cmapoutput_t2.mat']); 
load('../../output/utility/everything_consumpstructural_FVfast39374622.mat');
sigNormed=cat(1,learnparms.sig(1),learnparms.lambdag1start^2*learnparms.sig(2),learnparms.sig(3),learnparms.lambdan1start^2*learnparms.sig(4),learnparms.sig(5:6),learnparms.lambda4s1start^2*learnparms.sig(7:9),learnparms.sig(10:11),learnparms.lambda4h1start^2*learnparms.sig(12:14),learnparms.sig(15:17));
learnparms.Delta = tril(learnparms.Delta,-1)+tril(learnparms.Delta,-1)'+diag(diag(learnparms.Delta));

% check meas sys parameters read in correctly
assert(length(parms.msys.bstartAR)==12);
assert(length(parms.msys.bstartCS)==12);
assert(length(parms.msys.bstartMK)==12);
assert(length(parms.msys.bstartNO)==12);
assert(length(parms.msys.bstartPC)==12);
assert(length(parms.msys.bstartWK)==12);
assert(length(parms.msys.bstartSATm)==12);
assert(length(parms.msys.bstartSATv)==12);
assert(length(parms.msys.sigAR)==1);
assert(length(parms.msys.sigCS)==1);
assert(length(parms.msys.sigMK)==1);
assert(length(parms.msys.sigNO)==1);
assert(length(parms.msys.sigPC)==1);
assert(length(parms.msys.sigWK)==1);
assert(length(parms.msys.sigSATm)==1);
assert(length(parms.msys.sigSATv)==1);
assert(parms.msys.sigAR>0   & parms.msys.sigAR<1  );
assert(parms.msys.sigCS>0   & parms.msys.sigCS<1  );
assert(parms.msys.sigMK>0   & parms.msys.sigMK<1  );
assert(parms.msys.sigNO>0   & parms.msys.sigNO<1  );
assert(parms.msys.sigPC>0   & parms.msys.sigPC<1  );
assert(parms.msys.sigWK>0   & parms.msys.sigWK<1  );
assert(parms.msys.sigSATm>0 & parms.msys.sigSATm<1);
assert(parms.msys.sigSATv>0 & parms.msys.sigSATv<1);
assert(length(parms.msys.bstartLS)==18);
assert(length(parms.msys.bstartBR)==17);
assert(length(parms.msys.bstartEC)==12);
assert(length(parms.msys.bstartTB)==12);
assert(length(parms.msys.bstartRTB)==12);
assert(length(parms.msys.bstartHS)==17);
assert(length(parms.msys.bstartDE)==17);
assert(length(parms.msys.bstartPWY)==13);
assert(length(parms.msys.bstartPWP)==13);
assert(length(parms.msys.sigEC)==1);
assert(parms.msys.sigEC>0 & parms.msys.sigEC<10);


%-------------------------------------------------------------------------------
% 2. Draw initial conditions with replacement
%-------------------------------------------------------------------------------
% Read in demographic variables ((N*T)x1 vectors)
dataStruct.HS_gradesw = reshape(dataStruct.HS_grades,dataStruct.T,dataStruct.N)';
dataStruct.HS_gradesw = dataStruct.HS_gradesw(:,1);
dataStruct.anyFlagw = reshape(dataStruct.anyFlag,dataStruct.T,dataStruct.N)';
demog  = [dataStruct.blackw dataStruct.hispanicw dataStruct.HS_gradesw dataStruct.Parent_collegew dataStruct.birthYrw==1980 dataStruct.birthYrw==1981 dataStruct.birthYrw==1982 dataStruct.birthYrw==1983 dataStruct.famIncw];
inclus   = any(dataStruct.anyFlagw==0,2);
id       = [1:size(inclus,1)]';
ider     = id(inclus);
nls_ider = dataStruct.NLS_ID;
num_per  = sum(dataStruct.anyFlagw==0,2);

% Sample individuals with replacement
flagly  = randsample(ider,length(ider),true);
nls_id  = nls_ider(flagly);
num_per = num_per(flagly);

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
currStates.idxParTrans4  = reshape(dataStruct.idxParTrans4 ,dataStruct.T,dataStruct.N)';
currStates.idxParTrans2  = reshape(dataStruct.idxParTrans2 ,dataStruct.T,dataStruct.N)';
currStates.prParTrans4   = reshape(dataStruct.prParTrans4  ,dataStruct.T,dataStruct.N)';
currStates.prParTrans2   = reshape(dataStruct.prParTrans2  ,dataStruct.T,dataStruct.N)';
currStates.predSATmathZ  = reshape(dataStruct.predSATmathZ ,dataStruct.T,dataStruct.N)';
currStates.predSATverbZ  = reshape(dataStruct.predSATverbZ ,dataStruct.T,dataStruct.N)';
currStates.efc           = reshape(dataStruct.efc          ,dataStruct.T,dataStruct.N)';
currStates.lnFamInc      = reshape(dataStruct.lnFamInc     ,dataStruct.T,dataStruct.N)';
currStates.sage          = reshape(dataStruct.age          ,dataStruct.T,dataStruct.N)';
currStates.startyr       = reshape(dataStruct.year         ,dataStruct.T,dataStruct.N)';
Clper                    = reshape(dataStruct.Clp          ,dataStruct.T,dataStruct.N)'; 
Clper                    = Clper(flagly,:);
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
currStates.idxParTrans4  = currStates.idxParTrans4(flagly,1);
currStates.idxParTrans2  = currStates.idxParTrans2(flagly,1);
currStates.prParTrans4   = currStates.prParTrans4(flagly,1);
currStates.prParTrans2   = currStates.prParTrans2(flagly,1);
currStates.predSATmathZ  = currStates.predSATmathZ(flagly,1);
currStates.predSATverbZ  = currStates.predSATverbZ(flagly,1);
currStates.lnFamInc      = currStates.lnFamInc(flagly,1);
currStates.efc           = currStates.efc(flagly,1);
currStates.startyr       = currStates.startyr(ageidxer==1);
currStates.sage          = currStates.sage(ageidxer==1);

T = 19;
S = 8;
J = size(learnparms.Delta,1);
numMCdraws = 2000; % number of draws for computing consumption integrals
numDraws = 10;     % number of draws for computing CCP FV integrals
Beta = .9;
intrate = .05;
N = size(flagly,1);
wcidx = [2 4 7 9 12 14 17 19];
bcidx = [1 3 6 8 11 13 16 18];
ngbcidx = setdiff(1:20,wcidx);
gbcidx = setdiff(16:20,wcidx);
% time-invariant state variables:
obsvbls = demog(flagly,:); % collapse duplicates
summarize(obsvbls);
tabulate(obsvbls(:,3));

idelta = learnparms.Delta\eye(J,J);
currStates.ideltaMat = repmat(reshape(idelta,[1 J J]),[N 1 1]);
currStates.T = T;

%-------------------------------------------------------------------------------
% 3. Draw unobservables (type and abilities) with replacement
%-------------------------------------------------------------------------------
% abilities
trueAbil = mvnrnd(zeros(N,5),learnparms.Delta);

% types
draw = rand(N,1);
utype = zeros(N,1);
for s=1:S
    temp = (draw<sum(prior(:,s:end),2));
    utype=temp+utype;
end


%-------------------------------------------------------------------------------
% 4. draw choices and update state variables
%-------------------------------------------------------------------------------
% initialize state variable arrays
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
cum_4yrS           = 0*ones(N,T);
cum_4yrNS          = 0*ones(N,T);
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
idio               = zeros(N,5,T);
signal             = zeros(N,5,T);
obsMat             = zeros(N,5,T);
wageg              = nan(N,T);
wagen              = nan(N,T);
grade2             = nan(N,T);
grade4s            = nan(N,T);
grade4h            = nan(N,T);

consump            = zeros(N,20,S,T);
consump_t1         = zeros(N,20,S,T);
consump_g          = zeros(N,5,S,T);
consump_g_t1       = zeros(N,5,S,T);



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
currStates.cum_4yrS                 = 0*ones(N,1);
currStates.cum_4yrNS                = 0*ones(N,1);
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

% loop forward in time, updating all state variables
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
    consumpstructMCintUtil = consumpstructMCint;
    
    % create matrices of covariates that enter CCPs
    Utilstruct = createfutureflowsconsump(currStates,priorabilstruct,consumpstructMCint,0,S,intrate,t,CRRA); % initializes Beta argument as 0
    
    % compute FV terms
    [AdjNoGrad,AdjGrad] = formFVfricIntFast(Beta,Utilstruct,searchparms.boffer,gradparms.P_grad_betas4,currStates,priorabilstruct,learnparms,AR1parms,S,Clb,CRRA,intrate,numDraws,searchparms.bstrucsearch,cmapParms,cmapParmst1,cmapParmst2,t);
    
    % create current- and future flow utility matrices, then plug into structural probability function
    Utilstruct = createfutureflowsconsumpstruct(currStates,priorabilstruct,consumpstructMCintUtil,Beta,S,CRRA);
    gprobdiffs = creategprobdiffs(currStates,priorabilstruct,gradparms.P_grad_betas4);
    P = consumpsearchstrucplogit(strucparms.bstrucstruc,offer(:,t),Utilstruct,currStates.grad_4yr,gprobdiffs,AdjNoGrad,AdjGrad,Utilstruct.sdemog,S,Beta);
    
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    % Draw choices
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
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
    
    
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    % Draw log wage and college GPA outcomes based on whatever choice was made
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
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
    obsMat(:,1,t) = ismember(Ymat(:,t),wcidx);
    obsMat(:,2,t) = ismember(Ymat(:,t),bcidx);
    obsMat(:,3,t) = ismember(Ymat(:,t),[6:10]);
    obsMat(:,4,t) = ismember(Ymat(:,t),[11:15]);
    obsMat(:,5,t) = ismember(Ymat(:,t),[1:5]);
    signal(:,:,t) = signal(:,:,t).*obsMat(:,:,t);
    
    outcomes     = genwagegpa(currStates,Ymat(:,t),trueAbil,idio(:,:,t),learnparms);
    wageg(:,t)   = outcomes.wageg;
    wagen(:,t)   = outcomes.wagen;
    grade4s(:,t) = outcomes.grade4s;
    grade4h(:,t) = outcomes.grade4h;
    grade2(:,t)  = outcomes.grade2;
    
    
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    % Update state variables
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
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
    grad_4yr(:,t+1) = gradUpdate(grad_4yr(:,t),Ymat(:,t),currStates,priorabilstruct,gradparms.P_grad_betas4);
    
    % update other endogenous state variables
    age               (:,t+1) = age(:,t)+1;
    exper             (:,t+1) = exper(:,t)             +(ismember(Ymat(:,t),[1:2 6:7 11:12 18:19]))+.5*(ismember(Ymat(:,t),[3:4 8:9 13:14 16:17]));
    exper_white_collar(:,t+1) = exper_white_collar(:,t)+(ismember(Ymat(:,t),[2 7 12 19]))+.5*(ismember(Ymat(:,t),[4 9 14 17]));
    cum_2yr           (:,t+1) = cum_2yr(:,t)  +(ismember(Ymat(:,t),[1:5]));
    cum_4yr           (:,t+1) = cum_4yr(:,t)  +(ismember(Ymat(:,t),[6:15]));
    cum_4yrS          (:,t+1) = cum_4yrS(:,t) +(ismember(Ymat(:,t),[6:10]));
    cum_4yrNS         (:,t+1) = cum_4yrNS(:,t)+(ismember(Ymat(:,t),[11:15]));
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
    priorabilstruct.prior_ability_2   = prior_ability_2   (:,t+1);
    priorabilstruct.prior_ability_4NS = prior_ability_4NS (:,t+1);
    priorabilstruct.prior_ability_4S  = prior_ability_4S  (:,t+1);
    priorabilstruct.prior_ability_U   = prior_ability_U   (:,t+1);
    priorabilstruct.prior_ability_S   = prior_ability_S   (:,t+1);
    currStates.age                    = age               (:,t+1);
    currStates.exper                  = exper             (:,t+1);
    currStates.exper_white_collar     = exper_white_collar(:,t+1);
    currStates.grad_4yr               = grad_4yr          (:,t+1);
    currStates.cum_2yr                = cum_2yr           (:,t+1);
    currStates.cum_4yr                = cum_4yr           (:,t+1);
    currStates.cum_4yrS               = cum_4yrS          (:,t+1);
    currStates.cum_4yrNS              = cum_4yrNS         (:,t+1);
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
% combine all state variables into one structure for later use
allstates = struct('age'               ,age               (:,1:T), ...
                   'exper'             ,exper             (:,1:T), ...
                   'exper_white_collar',exper_white_collar(:,1:T), ...
                   'grad_4yr'          ,grad_4yr          (:,1:T), ...
                   'cum_2yr'           ,cum_2yr           (:,1:T), ...
                   'cum_4yr'           ,cum_4yr           (:,1:T), ...
                   'cum_4yrS'          ,cum_4yrS          (:,1:T), ...
                   'cum_4yrNS'         ,cum_4yrNS         (:,1:T), ...
                   'prev_HS'           ,prev_HS           (:,1:T), ...
                   'prev_2yr'          ,prev_2yr          (:,1:T), ...
                   'prev_4yrS'         ,prev_4yrS         (:,1:T), ...
                   'prev_4yrNS'        ,prev_4yrNS        (:,1:T), ...
                   'prev_PT'           ,prev_PT           (:,1:T), ...
                   'prev_FT'           ,prev_FT           (:,1:T), ...
                   'prev_WC'           ,prev_WC           (:,1:T), ...
                   'year'              ,year              (:,1:T), ...
                   'black'             ,currStates.black         , ...
                   'hispanic'          ,currStates.hispanic      , ...
                   'HS_grades'         ,currStates.HS_grades     , ...
                   'Parent_college'    ,currStates.Parent_college, ...
                   'birthYr'           ,1980*currStates.born1980 + 1981*currStates.born1981 + 1982*currStates.born1982 + 1983*currStates.born1983 + 1984*(1 - currStates.born1980 - currStates.born1981 - currStates.born1982 - currStates.born1983)     , ...
                   'famInc'            ,currStates.famInc        , ...
                   'wageg'             ,wageg                    , ...
                   'wagen'             ,wagen                    , ...
                   'grade4s'           ,grade4s                  , ...
                   'grade4h'           ,grade4h                  , ...
                   'grade2'            ,grade2                   , ...
                   'Ymat'              ,Ymat                     , ...
                   'finalMajorSci'     ,finalMajorSci            );
                   

%-------------------------------------------------------------------------------
% 5. generate measurement system outcomes based on unobservables and state vars
%-------------------------------------------------------------------------------
A = [1 1 1; 1 1 0; 1 0 1; 1 0 0; 0 1 1; 0 1 0; 0 0 1; 0 0 0];
initconds = struct('utype'         , utype       , ...
                   'black'         , obsvbls(:,1), ...
                   'hispanic'      , obsvbls(:,2), ...
                   'HS_grades'     , obsvbls(:,3), ...
                   'Parent_college', obsvbls(:,4), ...
                   'born1980'      , obsvbls(:,5), ...
                   'born1981'      , obsvbls(:,6), ...
                   'born1982'      , obsvbls(:,7), ...
                   'born1983'      , obsvbls(:,8), ...
                   'famInc'        , obsvbls(:,9));
measdata = createmeasdata(initconds,parms.msys,A,S);
                       

%-------------------------------------------------------------------------------
% 6. estimate model
%-------------------------------------------------------------------------------

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% stage 1: semiparametric model with measurement system
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%save([pathpboot,'allbefrunstage1_',num2str(guess),'.mat'],'-v7.3');
load([pathpboot,'allbefrunstage1_',num2str(guess),'.mat']);
stage1parms = run_stage1(measdata,allstates,currStates,parms,prior,S,guess,pathpboot);
save([pathpboot,'allbefrunlearning',num2str(guess),'.mat'],'-v7.3');


%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% stages 2-3: learning model
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
load([pathpboot,'allbefrunlearning',num2str(guess),'.mat']);
[learnparameters,gradparameters,dataStruct,learnStruct] = run_learning(stage1parms.PType,stage1parms.PTypel,learnparms,allstates,currStates,A,S);
save([pathpboot,'allbefrunchoice',num2str(guess),'.mat'],'-v7.3');


%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% stage 4: static choice model
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
load([pathpboot,'allbefrunchoice',num2str(guess),'.mat']);
staticparameters = run_static_choice(learnparameters,learnStruct,dataStruct,A,S,stage1parms.PTypel,intrate,Clb,CRRA,guess,pathpboot);
save([pathpboot,'allbefrunFVCCP', num2str(guess),'.mat'],'-v7.3');

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% stage 5: future value terms (computed from CCPs)
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
load([pathpboot,'allbefrunFVCCP', num2str(guess),'.mat']);
[Adj,AdjG] = run_FV_CCP(staticparameters,learnparameters,gradparameters,learnStruct,dataStruct,staticparameters.consumpstructMCint,A,S,stage1parms.PTypel,Beta,intrate,Clb,CRRA,guess,pathpboot);
save([pathpboot,'allbefrunstructural', num2str(guess),'.mat'],'-v7.3');

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% stage 6: structural flow utility parameters
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
load([pathpboot,'allbefrunstructural', num2str(guess),'.mat']);
structuralparameters = run_dynamic_choice(Adj,AdjG,staticparameters,learnparameters,gradparameters,learnStruct,dataStruct,staticparameters.consumpstructMCint,A,S,stage1parms.PTypel,Beta,intrate,Clb,CRRA,guess,pathpboot);

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% save results
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% remove unneeded fields  to keep file sizes to a minimum
staticparameters = rmfield(staticparameters,{'lambda','Utilstruct','consumpstructMCint'});

% create one giant struct and save it
allparms = struct('stage1parms',stage1parms,'learnparameters',learnparameters,'gradparameters',gradparameters,'staticparameters',staticparameters,'structuralparameters',structuralparameters);
save(strcat(pathpboot,'allparameters',num2str(guess),'.mat'),'-v7.3','allparms');

diary('off');
