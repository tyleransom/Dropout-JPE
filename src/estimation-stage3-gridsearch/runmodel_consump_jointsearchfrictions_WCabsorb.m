%===============================================================================
% Estimate parameters associated with search frictions with CRRA consumption
% Estimate graduation logit
% Estimate AR(1) model on wage year dummies
% Grid search over CRRA parameter value (via directory name)
%===============================================================================

%------------------------------------------------------------------------------
% Initialize
%------------------------------------------------------------------------------
clear all; clc;
if isempty(str2num(getenv('SLURM_ARRAY_TASK_ID'))) & isempty(str2num(getenv('SLURM_JOB_ID')))
    guess = 16;
elseif ~isempty(str2num(getenv('SLURM_ARRAY_TASK_ID')))
    guess=str2num(getenv('SLURM_ARRAY_TASK_ID'));
else
    guess=str2num(getenv('SLURM_JOB_ID'));
end

% Set up CRRA grid
crragrid = [[0:0.05:0.95] [1.05:0.05:2]]';
crratemp = crragrid(guess);
crrastrg = replace(num2str(crratemp), '.', '-');

% File path for saving results
ipath = ['../../output/utility-grid-search/CRRA-',crrastrg,'/'];


delete(strcat(ipath,'runmodel_consump_jointsearchfrictions_WCabsorb.diary'));
diary(strcat(ipath,'runmodel_consump_jointsearchfrictions_WCabsorb.diary'));
tic
OS = 'cluster';

% Add functions to path
addpath('../estimation-stage3-5-structural/functions');

% Set seed
rng(guess);

%------------------------------------------------------------------------------
% Initialization
%------------------------------------------------------------------------------
% File path for data
fname = '../../data/nlsy97/cleaned/wide_data_male20220401_tscrGPA.mat';

% File path for stage 1 semiparametric results
st1fname = '../../output/all-stage-1/everything_all_stage1_interact_type_36688212.mat';

% File path for stage 2 learning results
st2fname = '../../output/learning/everything37131357.mat';


%------------------------------------------------------------------------------
% Read in parameters from prior stages
%------------------------------------------------------------------------------
% load in q's from stage 1
load(st1fname,'P*T*','prior')
% load in learning parameters from stage 2
load(st2fname,'learnStruct','priorabilstruct','learnparms','gradparms','S','ngpct');



%------------------------------------------------------------------------------
% Read in updated choice data with expected loans at age 18
%------------------------------------------------------------------------------
dataStruct = createchoicedata(fname,S,ngpct);


%------------------------------------------------------------------------------
% Estimate the year dummy AR(1) model
%------------------------------------------------------------------------------
AR1parms = estimateAR1(learnparms);
v2struct(AR1parms);


%------------------------------------------------------------------------------
% Compute expected wages for use in E(U(C)) calculation
%------------------------------------------------------------------------------
% Create current and future expected wages (to read into search friction model)
tic
ewagestruct = createwages(dataStruct,priorabilstruct,learnparms,AR1parms,S,ngpct);
disp(['Time spent constructing expected wages: ',num2str(toc/60),' minutes']);

%% expected wages comparison
%disp('summary stats on expected wages');
%flg = (dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==0);
%sumopt = struct('Weights',PmajgpaTypel(flg));
%wage_sums = summarize(ewagestruct.E_ln_wage(flg,:),sumopt);
%flg = (dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==1);
%sumopt = struct('Weights',PmajgpaTypel(flg));
%wage_sums = summarize(ewagestruct.E_ln_wage_g(flg,:),sumopt);
%
%% raw data wages comparison
%[~,lwagelImps] = makegrid_con(dataStruct.log_wage,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S);
%datamean = zeros(25,1);
%disp('raw wage data by alternative and grad status')
%for j=1:20
%    disp(num2str(j));
%    flg = (dataStruct.ClImps==j & dataStruct.grad_4yrlImps==0);
%    sumopt = struct('Weights',PmajgpaTypel(flg));
%    if ismember(j,[5 10 15 20])
%        wage_sums = summarize(0*lwagelImps(flg,:),sumopt);
%    else
%        wage_sums = summarize(lwagelImps(flg,:),sumopt);
%    end
%    datamean(j) = wage_sums(1,2);
%end
%for j=16:20
%    disp(num2str(j));
%    flg = (dataStruct.ClImps==j & dataStruct.grad_4yrlImps==1);
%    sumopt = struct('Weights',PmajgpaTypel(flg));
%    if ismember(j,[20])
%        wage_sums = summarize(0*lwagelImps(flg,:),sumopt);
%    else
%        wage_sums = summarize(lwagelImps(flg,:),sumopt);
%    end
%    datamean(20+j-15) = wage_sums(1,2);
%end
%
%disp('model-predicted wage data by alternative and grad status')
%modelmean = zeros(25,1);
%for j=1:20
%    disp(num2str(j));
%    flg = (dataStruct.ClImps==j & dataStruct.grad_4yrlImps==0);
%    sumopt = struct('Weights',PmajgpaTypel(flg));
%    wage_sums = summarize(ewagestruct.E_ln_wage(flg,j),sumopt);
%    modelmean(j) = wage_sums(1,2);
%end
%for j=16:20
%    disp(num2str(j));
%    flg = (dataStruct.ClImps==j & dataStruct.grad_4yrlImps==1);
%    sumopt = struct('Weights',PmajgpaTypel(flg));
%    wage_sums = summarize(ewagestruct.E_ln_wage_g(flg,j),sumopt);
%    modelmean(20+j-15) = wage_sums(1,2);
%end
%
%disp('compare data and model average log wages');
%[datamean modelmean]
%assert(norm(datamean-modelmean,2)<0.3,'expected wages are messed up somehow');

interestrate = 0.05; % interest rate on loans (calibrated)
Clb = 2800;          % lower bound for consumption (calibrated)
CRRA = crratemp      % CRRA utility parameter 
numGpoints = 9;      % number of grid points for trapezoidal integration
numDraws   = 2000;   % number of draws for monte carlo integration
save(strcat(ipath,'consumptionInputs.mat'),'-v7.3','dataStruct','ewagestruct','priorabilstruct','learnparms','Clb','CRRA','numGpoints','AR1parms','S','ngpct','PmajgpaTypel');
MCintegrate = true;
skipper = true;
if skipper==false && MCintegrate==false
    % % Create current and future expected consumption (to read into search friction model)
    % tic
    % consumpstruct = createconsump(dataStruct,ewagestruct,priorabilstruct,learnparms,Clb,CRRA,numGpoints,AR1parms,S,ngpct);
    % disp(['Time spent constructing expected consumption: ',num2str(toc/60),' minutes']);
    % save('consumptionStruct','-v7.3','consumpstruct');
elseif skipper==true && MCintegrate==true
    % Create current and future expected consumption (to read into search friction model)
    tic
    consumpstructMCint = createconsumpMCint(dataStruct,ewagestruct,priorabilstruct,learnparms,interestrate,Clb,CRRA,numDraws,AR1parms,S,ngpct);
    disp(['Time spent constructing expected consumption by MC integration: ',num2str(toc/60),' minutes']);
    save(strcat(ipath,'consumptionStructMCint.mat'),'-v7.3','consumpstructMCint');
    [~,efc]      = makegrid_con(dataStruct.efc,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,SATmath]  = makegrid_con(dataStruct.predSATmathZ,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,SATverb]  = makegrid_con(dataStruct.predSATverbZ,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,famInc]   = makegrid_con(dataStruct.famInc,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,black]    = makegrid_con(dataStruct.black,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,hispanic] = makegrid_con(dataStruct.hispanic,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,Eloan2]   = makegrid_con(dataStruct.E_loan2_18.*(1+interestrate).^(dataStruct.yrsSinceHS),dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,Eloan4]   = makegrid_con(dataStruct.E_loan4_18.*(1+interestrate).^(dataStruct.yrsSinceHS),dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,gr2pridx] = makegrid_con(dataStruct.grant2pr,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,gr4pridx] = makegrid_con(dataStruct.grant4pr,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,gr2idx]   = makegrid_con(dataStruct.grant2idx,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,gr4idx]   = makegrid_con(dataStruct.grant4idx,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,pt2pridx] = makegrid_con(dataStruct.prParTrans2,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,pt4pridx] = makegrid_con(dataStruct.prParTrans4,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,pt2idx]   = makegrid_con(dataStruct.idxParTrans2,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,pt4idx]   = makegrid_con(dataStruct.idxParTrans4,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
     gr2pridx    = log(gr2pridx./(1-gr2pridx));
     gr4pridx    = log(gr4pridx./(1-gr4pridx));
     pt2pridx    = log(pt2pridx./(1-pt2pridx));
     pt4pridx    = log(pt4pridx./(1-pt4pridx));
    [~,age] = makegrid_con(dataStruct.age,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    tostata = array2table([PmajgpaTypel dataStruct.grad_4yrlImps consumpstructMCint.consump consumpstructMCint.consumpNaive consumpstructMCint.consump_g(:,16:20) consumpstructMCint.consumpNaive_g(:,16:20) consumpstructMCint.consump_t1 consumpstructMCint.consumpNaive_t1 consumpstructMCint.consump_g_t1(:,16:20) consumpstructMCint.consumpNaive_g_t1(:,16:20) consumpstructMCint.consump_t2 consumpstructMCint.consumpNaive_t2 consumpstructMCint.consump_g_t2(:,16:20) consumpstructMCint.consumpNaive_g_t2(:,16:20) consumpstructMCint.consumpPI consumpstructMCint.consump_gPI(:,16:20) efc SATmath SATverb famInc black hispanic age gr2pridx gr4pridx gr2idx gr4idx pt2pridx pt4pridx pt2idx pt4idx Eloan2 Eloan4], 'VariableNames',{'q', 'grad_4yr', 'actualNG_1', 'actualNG_2', 'actualNG_3', 'actualNG_4', 'actualNG_5', 'actualNG_6', 'actualNG_7', 'actualNG_8', 'actualNG_9', 'actualNG_10', 'actualNG_11', 'actualNG_12', 'actualNG_13', 'actualNG_14', 'actualNG_15', 'actualNG_16', 'actualNG_17', 'actualNG_18', 'actualNG_19', 'actualNG_20', 'naiveNG_1', 'naiveNG_2', 'naiveNG_3', 'naiveNG_4', 'naiveNG_5', 'naiveNG_6', 'naiveNG_7', 'naiveNG_8', 'naiveNG_9', 'naiveNG_10', 'naiveNG_11', 'naiveNG_12', 'naiveNG_13', 'naiveNG_14', 'naiveNG_15', 'naiveNG_16', 'naiveNG_17', 'naiveNG_18', 'naiveNG_19', 'naiveNG_20', 'actualG_16', 'actualG_17', 'actualG_18', 'actualG_19', 'actualG_20', 'naiveG_16', 'naiveG_17', 'naiveG_18', 'naiveG_19', 'naiveG_20', 'actualt1NG_1', 'actualt1NG_2', 'actualt1NG_3', 'actualt1NG_4', 'actualt1NG_5', 'actualt1NG_6', 'actualt1NG_7', 'actualt1NG_8', 'actualt1NG_9', 'actualt1NG_10', 'actualt1NG_11', 'actualt1NG_12', 'actualt1NG_13', 'actualt1NG_14', 'actualt1NG_15', 'actualt1NG_16', 'actualt1NG_17', 'actualt1NG_18', 'actualt1NG_19', 'actualt1NG_20', 'naivet1NG_1', 'naivet1NG_2', 'naivet1NG_3', 'naivet1NG_4', 'naivet1NG_5', 'naivet1NG_6', 'naivet1NG_7', 'naivet1NG_8', 'naivet1NG_9', 'naivet1NG_10', 'naivet1NG_11', 'naivet1NG_12', 'naivet1NG_13', 'naivet1NG_14', 'naivet1NG_15', 'naivet1NG_16', 'naivet1NG_17', 'naivet1NG_18', 'naivet1NG_19', 'naivet1NG_20', 'actualt1G_16', 'actualt1G_17', 'actualt1G_18', 'actualt1G_19', 'actualt1G_20', 'naivet1G_16', 'naivet1G_17', 'naivet1G_18', 'naivet1G_19', 'naivet1G_20', 'actualt2NG_1', 'actualt2NG_2', 'actualt2NG_3', 'actualt2NG_4', 'actualt2NG_5', 'actualt2NG_6', 'actualt2NG_7', 'actualt2NG_8', 'actualt2NG_9', 'actualt2NG_10', 'actualt2NG_11', 'actualt2NG_12', 'actualt2NG_13', 'actualt2NG_14', 'actualt2NG_15', 'actualt2NG_16', 'actualt2NG_17', 'actualt2NG_18', 'actualt2NG_19', 'actualt2NG_20', 'naivet2NG_1', 'naivet2NG_2', 'naivet2NG_3', 'naivet2NG_4', 'naivet2NG_5', 'naivet2NG_6', 'naivet2NG_7', 'naivet2NG_8', 'naivet2NG_9', 'naivet2NG_10', 'naivet2NG_11', 'naivet2NG_12', 'naivet2NG_13', 'naivet2NG_14', 'naivet2NG_15', 'naivet2NG_16', 'naivet2NG_17', 'naivet2NG_18', 'naivet2NG_19', 'naivet2NG_20', 'actualt2G_16', 'actualt2G_17', 'actualt2G_18', 'actualt2G_19', 'actualt2G_20', 'naivet2G_16', 'naivet2G_17', 'naivet2G_18', 'naivet2G_19', 'naivet2G_20', 'actualPING_1', 'actualPING_2', 'actualPING_3', 'actualPING_4', 'actualPING_5', 'actualPING_6', 'actualPING_7', 'actualPING_8', 'actualPING_9', 'actualPING_10', 'actualPING_11', 'actualPING_12', 'actualPING_13', 'actualPING_14', 'actualPING_15', 'actualPING_16', 'actualPING_17', 'actualPING_18', 'actualPING_19', 'actualPING_20', 'actualPIG_16', 'actualPIG_17', 'actualPIG_18', 'actualPIG_19', 'actualPIG_20', 'EFC','SATmath','SATverb','famInc','black','hispanic','age','gr2yrPrIdx','gr4yrPrIdx','gr2yrIdx','gr4yrIdx','pt2yrPrIdx','pt4yrPrIdx','pt2yrIdx','pt4yrIdx','Eloan2','Eloan4'}); 
    tostata=tostata(~any(ismissing(tostata),2),:);
    %writetable(tostata,'consumpspline4.csv');
elseif skipper==true && MCintegrate==false
    load(strcat(ipath,'consumptionStructMCint.mat'));
end

MCintegrate = true;
if skipper==true && MCintegrate==true
    % summary stats on consumption
    sumopt = struct('Weights',PmajgpaTypel(dataStruct.ClImps>0));
    MCint_sums      = summarize(consumpstructMCint.consump(dataStruct.ClImps>0,:),sumopt);
    MCint_sumsNaive = summarize(consumpstructMCint.consumpNaive(dataStruct.ClImps>0,:),sumopt);
    MCint_sumsG     = summarize(consumpstructMCint.consump_g(dataStruct.ClImps>0,:),sumopt);
    MCint_sumsGNaiv = summarize(consumpstructMCint.consumpNaive_g(dataStruct.ClImps>0,:),sumopt);

    % data required for consumption mapping
    [~,efc]      = makegrid_con(dataStruct.efc,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,SATmath]  = makegrid_con(dataStruct.predSATmathZ,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,SATverb]  = makegrid_con(dataStruct.predSATverbZ,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,famInc]   = makegrid_con(dataStruct.famInc,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,black]    = makegrid_con(dataStruct.black,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,hispanic] = makegrid_con(dataStruct.hispanic,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,Eloan2]   = makegrid_con(dataStruct.E_loan2_18.*(1+interestrate).^(dataStruct.yrsSinceHS),dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,Eloan4]   = makegrid_con(dataStruct.E_loan4_18.*(1+interestrate).^(dataStruct.yrsSinceHS),dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,gr2pridx] = makegrid_con(dataStruct.grant2pr,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,gr4pridx] = makegrid_con(dataStruct.grant4pr,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,gr2idx]   = makegrid_con(dataStruct.grant2idx,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,gr4idx]   = makegrid_con(dataStruct.grant4idx,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,pt2pridx] = makegrid_con(dataStruct.prParTrans2,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,pt4pridx] = makegrid_con(dataStruct.prParTrans4,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,pt2idx]   = makegrid_con(dataStruct.idxParTrans2,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
    [~,pt4idx]   = makegrid_con(dataStruct.idxParTrans4,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 
     gr2pridx    = log(gr2pridx./(1-gr2pridx));
     gr4pridx    = log(gr4pridx./(1-gr4pridx));
     pt2pridx    = log(pt2pridx./(1-pt2pridx));
     pt4pridx    = log(pt4pridx./(1-pt4pridx));
    [~,age] = makegrid_con(dataStruct.age,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S); 

    pt4idxt1   = pt4idx - 0.095542;                   % 4yr PT age coefficient = -0.095542
    pt2idxt1   = pt2idx - 0.0595774;                  % 2yr PT age coefficient = -0.0595774 
    pt4pridxt1 = pt4pridx - 0.3316555;                % 4yr PT>0 logit age coefficient = -0.3316555
    pt2pridxt1 = pt2pridx - 0.3034261;                % 2yr PT>0 logit age coefficient = -0.3034261 

    pt4idxt2   = pt4idx - 2*0.095542;                 % 4yr PT age coefficient = -0.095542   
    pt2idxt2   = pt2idx - 2*0.0595774;                % 2yr PT age coefficient = -0.0595774  
    pt4pridxt2 = pt4pridx - 2*0.3316555;              % 4yr PT>0 logit age coefficient = -0.3316555 
    pt2pridxt2 = pt2pridx - 2*0.3034261;              % 2yr PT>0 logit age coefficient = -0.3034261  

    % create mapping between naive consumption and integrated consumption
    [cmap_nograd,cmap_nograd_work,cmap_grad_work,r2_nograd,r2_nograd_work,r2_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work] = mapconsump(consumpstructMCint,dataStruct.grad_4yrlImps,PmajgpaTypel,gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridx,pt4pridx,pt2idx,pt4idx,Eloan2,Eloan4);
    cmapStruct = struct('gr2pridx',gr2pridx,'gr4pridx',gr4pridx,'gr2idx',gr2idx,'gr4idx',gr4idx,'pt2pridx',pt2pridx,'pt4pridx',pt4pridx,'pt2idx',pt2idx,'pt4idx',pt4idx,'Eloan2',Eloan2,'Eloan4',Eloan4);
    save(strcat(ipath,'cmapoutput.mat'),'cmap_nograd','cmap_nograd_work','cmap_grad_work','r2_nograd','r2_nograd_work','r2_grad_work','scaler_nograd','scaler_nograd_work','scaler_grad_work'); 

    % create mapping between naive consumption and integrated consumption in t+1 (E_t[C_{t+1}])
    [cmap_nograd,cmap_nograd_work,cmap_grad_work,r2_nograd,r2_nograd_work,r2_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work] = mapconsump_t1(consumpstructMCint,dataStruct.grad_4yrlImps,PmajgpaTypel,gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridxt1,pt4pridxt1,pt2idxt1,pt4idxt1,Eloan2,Eloan4);
    cmapStruct = struct('gr2pridx',gr2pridx,'gr4pridx',gr4pridx,'gr2idx',gr2idx,'gr4idx',gr4idx,'pt2pridx',pt2pridxt1,'pt4pridx',pt4pridxt1,'pt2idx',pt2idxt1,'pt4idx',pt4idxt1,'Eloan2',Eloan2,'Eloan4',Eloan4);
    save(strcat(ipath,'cmapoutput_t1.mat'),'cmap_nograd','cmap_nograd_work','cmap_grad_work','r2_nograd','r2_nograd_work','r2_grad_work','scaler_nograd','scaler_nograd_work','scaler_grad_work'); 

    % create mapping between naive consumption and integrated consumption in t+1 (E_t[C_{t+2}])
    [cmap_nograd,cmap_nograd_work,cmap_grad_work,r2_nograd,r2_nograd_work,r2_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work] = mapconsump_t2(consumpstructMCint,dataStruct.grad_4yrlImps,PmajgpaTypel,gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridxt2,pt4pridxt2,pt2idxt2,pt4idxt2,Eloan2,Eloan4);
    cmapStruct = struct('gr2pridx',gr2pridx,'gr4pridx',gr4pridx,'gr2idx',gr2idx,'gr4idx',gr4idx,'pt2pridx',pt2pridxt2,'pt4pridx',pt4pridxt2,'pt2idx',pt2idxt2,'pt4idx',pt4idxt2,'Eloan2',Eloan2,'Eloan4',Eloan4);
    save(strcat(ipath,'cmapoutput_t2.mat'),'cmap_nograd','cmap_nograd_work','cmap_grad_work','r2_nograd','r2_nograd_work','r2_grad_work','scaler_nograd','scaler_nograd_work','scaler_grad_work'); 

    % create mapping between naive consumption and integrated consumption in t+1 (E_t[C_{t+1}])
    [cmap_nograd,cmap_nograd_work,cmap_grad_work,r2_nograd,r2_nograd_work,r2_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work] = mapconsump_perf_info(consumpstructMCint,dataStruct.grad_4yrlImps,PmajgpaTypel,gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridx,pt4pridx,pt2idx,pt4idx,Eloan2,Eloan4);
    cmapStruct = struct('gr2pridx',gr2pridx,'gr4pridx',gr4pridx,'gr2idx',gr2idx,'gr4idx',gr4idx,'pt2pridx',pt2pridxt1,'pt4pridx',pt4pridxt1,'pt2idx',pt2idxt1,'pt4idx',pt4idxt1,'Eloan2',Eloan2,'Eloan4',Eloan4);
    save(strcat(ipath,'cmapoutput_perf_info.mat'),'cmap_nograd','cmap_nograd_work','cmap_grad_work','r2_nograd','r2_nograd_work','r2_grad_work','scaler_nograd','scaler_nograd_work','scaler_grad_work'); 

    % check predictions of integrated consumption mapping
    disp('check predictions for consumption mapping in t')
    load(strcat(ipath,'cmapoutput.mat'));
    multy = scaler_nograd_work(1)
    for j=1:20
        if j<21
            consumpTestNG(:,j) = predconsump(j,0,cmap_nograd,cmap_nograd_work,cmap_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work,consumpstructMCint.consumpNaive(:,j),gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridx,pt4pridx,pt2idx,pt4idx,Eloan2,Eloan4);
        end
        if j>15
            consumpTestG(:,j)  = predconsump(j,1,cmap_nograd,cmap_nograd_work,cmap_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work,consumpstructMCint.consumpNaive_g(:,j),gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridx,pt4pridx,pt2idx,pt4idx,Eloan2,Eloan4);
        end
    end
    summarize(multy*consumpTestNG(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==0,:));
    summarize(multy*consumpstructMCint.consump(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==0,:));
    summarize(multy*consumpTestG(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==1,:));
    summarize(multy*consumpstructMCint.consump_g(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==1,:));

    % check predictions of integrated consumption mapping (t+1)
    disp('check predictions for consumption mapping in t+1')
    load(strcat(ipath,'cmapoutput_t1.mat'));
    for j=1:20
        if j<21
            consumpTestNG(:,j) = predconsump(j,0,cmap_nograd,cmap_nograd_work,cmap_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work,consumpstructMCint.consumpNaive_t1(:,j),gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridxt1,pt4pridxt1,pt2idxt1,pt4idxt1,Eloan2,Eloan4);
        end
        if j>15
            consumpTestG(:,j)  = predconsump(j,1,cmap_nograd,cmap_nograd_work,cmap_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work,consumpstructMCint.consumpNaive_g_t1(:,j),gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridxt1,pt4pridxt1,pt2idxt1,pt4idxt1,Eloan2,Eloan4);
        end
    end
    summarize(multy*consumpTestNG(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==0,:));
    summarize(multy*consumpstructMCint.consump_t1(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==0,:));
    summarize(multy*consumpTestG(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==1,:));
    summarize(multy*consumpstructMCint.consump_g_t1(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==1,:));

    % check predictions of integrated consumption mapping (t+2)
    disp('check predictions for consumption mapping in t+2')
    load(strcat(ipath,'cmapoutput_t2.mat'));
    for j=1:20
        if j<21
            consumpTestNG(:,j) = predconsump(j,0,cmap_nograd,cmap_nograd_work,cmap_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work,consumpstructMCint.consumpNaive_t2(:,j),gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridxt2,pt4pridxt2,pt2idxt2,pt4idxt2,Eloan2,Eloan4);
        end
        if j>15
            consumpTestG(:,j)  = predconsump(j,1,cmap_nograd,cmap_nograd_work,cmap_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work,consumpstructMCint.consumpNaive_g_t2(:,j),gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridxt2,pt4pridxt2,pt2idxt2,pt4idxt2,Eloan2,Eloan4);
        end
    end
    summarize(multy*consumpTestNG(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==0,:));
    summarize(multy*consumpstructMCint.consump_t2(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==0,:));
    summarize(multy*consumpTestG(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==1,:));
    summarize(multy*consumpstructMCint.consump_g_t2(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==1,:));

    % check predictions of integrated consumption mapping (t+1 perfect info)
    disp('check predictions for consumption mapping in t (no ability uncertainty)')
    load(strcat(ipath,'cmapoutput_perf_info.mat'));
    for j=1:20
        if j<21
            consumpTestNG(:,j) = predconsump(j,0,cmap_nograd,cmap_nograd_work,cmap_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work,consumpstructMCint.consumpNaive(:,j),gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridx,pt4pridx,pt2idx,pt4idx,Eloan2,Eloan4);
        end
        if j>15
            consumpTestG(:,j)  = predconsump(j,1,cmap_nograd,cmap_nograd_work,cmap_grad_work,scaler_nograd,scaler_nograd_work,scaler_grad_work,consumpstructMCint.consumpNaive_g(:,j),gr2pridx,gr4pridx,gr2idx,gr4idx,pt2pridx,pt4pridx,pt2idx,pt4idx,Eloan2,Eloan4);
        end
    end
    summarize(multy*consumpTestNG(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==0,:));
    summarize(multy*consumpstructMCint.consumpPI(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==0,:));
    summarize(multy*consumpTestG(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==1,:));
    summarize(multy*consumpstructMCint.consump_gPI(dataStruct.ClImps>0 & dataStruct.grad_4yrlImps==1,:));
    load(strcat(ipath,'cmapoutput.mat'));
else
    load(strcat(ipath,'cmapoutput.mat'));
end

% Create future flow utility terms (to read into search friction model)
tic
Utilstruct = createfutureflowsconsump(dataStruct,priorabilstruct,consumpstructMCint,0,S,ngpct,interestrate,CRRA); % initialize Beta argument as 0
Utilstruct.ClImps        = dataStruct.ClImps;
Utilstruct.grad_4yrlImps = dataStruct.grad_4yrlImps;
disp(['Time spent constructing future flow utility terms: ',num2str(toc/60),' minutes']);

disp('summary of X2nw in t=1 in static model estimation')
Y      = Utilstruct.ClImps;
q      = PmajgpaTypel;
Ymat   = reshape(Y,[dataStruct.T dataStruct.Ntilde*S])';
permat = (Ymat>0).*cumsum(Ymat>0,2);
per    = reshape(permute(permat,[2 1]),[],1);

test = [Utilstruct.X2nw];
sumopt = struct('Weights',q(Y>0 & per==1));
summarize(test(Y>0 & per==1,:),sumopt);

disp('summary of X2nw in static model estimation')
test = [Utilstruct.X2nw];
sumopt = struct('Weights',q(Y>0));
summarize(test(Y>0,:),sumopt);

% Estimate the search friction choice model (EM algorithm)
tic
test = false;
restart = false; % indicator for if previous starting values should be re-used
searchparms = estimatejointsearchconsumpWCabsorb(Utilstruct,PmajgpaTypel,guess,S,restart,ipath);
v2struct(searchparms);
disp(['Time spent running search estimation: ',num2str(toc/3600),' hours']);

save(strcat(ipath,'everything_jointsearch_WCabsorb',num2str(guess),'.mat'),'-v7.3','searchparms','AR1parms','Utilstruct','P*T*','S','dataStruct','priorabilstruct','consumpstructMCint','ngpct','learnStruct','learnparms','gradparms','Clb','CRRA','cmap_nograd','cmap_nograd_work','cmap_grad_work');
save(strcat(ipath,'static_small.mat'),'dataStruct','AR1parms','S','searchparms','learnparms','gradparms','Clb','CRRA');

diary('off');  
