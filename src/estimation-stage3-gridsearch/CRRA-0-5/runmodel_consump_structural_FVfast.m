%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate structural flow utility parameters given estimates from all pvs steps:
%   - measurement system
%   - learning
%   - graduation logit
%   - job offer arrival logit
%   - CCP terms obtained from flexible static choice model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------------------------------------------
% Initialize
%------------------------------------------------------------------------------
clear all; clc;
if isempty(str2num(getenv('SLURM_ARRAY_TASK_ID'))) && isempty(str2num(getenv('SLURM_JOB_ID')))
    guess = 16;
elseif ~isempty(str2num(getenv('SLURM_ARRAY_TASK_ID')))
    guess=str2num(getenv('SLURM_ARRAY_TASK_ID'));
else
    guess=str2num(getenv('SLURM_JOB_ID'));
end

% File path for saving and loading results
ipath = '../../../output/utility-grid-search/CRRA-0-5/';

delete(strcat(ipath,'runmodel_consumpstructural_FVfast',num2str(guess),'.diary'));
diary( strcat(ipath,'runmodel_consumpstructural_FVfast',num2str(guess),'.diary'));
tic
OS = 'cluster';

% Set seed
rng(guess);

% Add path
addpath('../../estimation-stage3-5-structural/functions');

% Discount factor
Beta = 0.9; 

%------------------------------------------------------------------------------
% Read in data and parameters from all previous steps
%------------------------------------------------------------------------------
%[~,eeeeee] = system('echo ${PWD##*/}','-echo');
%eeeeee = strtrim(eeeeee(eeeeee~='Z'))
[status,cmdout] = system(['ls -t ',ipath,'everything_jointsearch_WCabsorb*.mat | head -1'],'-echo');
ffffff = strtrim(cmdout);
load(ffffff);
v2struct(searchparms);
% check conformability of learning parameter vectors and data
assert(size(learnparms.bstartg,1)==size(learnStruct.xgNS,2),'bstartg and xgNS are not conformable');
% check CRRA value
assert(norm(CRRA-0.5,Inf)<1e-6, ['CRRA wrongly read in; CRRA is supposed to be 0.5 but it is actually ',num2str(CRRA)])


%------------------------------------------------------------------------------
% Stack learning results data to conform to search-offer stacked data
%------------------------------------------------------------------------------
idelta = learnparms.Delta\eye(5,5);
dataStruct.ideltaMat = repmat(reshape(idelta,[1 5 5]),[size(dataStruct.yrclImps,1) 1 1]);
priorabilstructsearch = prior_ability_DDC_search(learnparms,learnStruct,dataStruct,S);


%------------------------------------------------------------------------------
% Import previously calculated FV terms
%------------------------------------------------------------------------------
q = ones(size(PmajgpaTypel));
AdjNG = [];
AdjG  = [];
for j=1:20
    emm=load([ipath,'adjIntMatsSearchStructuralFast10D',num2str(j)],'AdjNG','AdjG');
    AdjNG = cat(2,AdjNG,emm.AdjNG);
    AdjG  = cat(2,AdjG, emm.AdjG);
end
% summary stats of Adj terms
flagG = Utilstruct.ClImps>0 & Utilstruct.grad_4yrlImps==1;
flagNG = Utilstruct.ClImps>0 & Utilstruct.grad_4yrlImps==0;
sumoptG  = struct('Weights',q(flagG).*PmajgpaTypel(flagG));
sumoptNG = struct('Weights',q(flagNG).*PmajgpaTypel(flagNG));
summarize(AdjNG(flagNG,:),sumoptNG);
summarize(AdjG (flagG ,:),sumoptG);


%------------------------------------------------------------------------------
% Estimate structural flow utility parameters
%------------------------------------------------------------------------------
tic
% create current-period and future-period flow utilities at same time
Utilstruct = createfutureflowsconsumpstruct(dataStruct,priorabilstruct,consumpstructMCint,Beta,S,ngpct,PmajgpaTypel,AdjNG,AdjG,CRRA);
% create some fields in the utd struct
sdemog = Utilstruct.sdemog;
Utilstruct.number2   = size(Utilstruct.X2nw,2)-3;       % exclude consump, grad_4yr, whiteCollar dummy
Utilstruct.number4s  = size(Utilstruct.X4snw,2)-3;      % exclude consump, grad_4yr, whiteCollar dummy
Utilstruct.number4ns = size(Utilstruct.X4nsnw,2)-3;     % exclude consump, grad_4yr, whiteCollar dummy
Utilstruct.numberpt  = size(Utilstruct.Xngwptbc,2)-6;   % exclude abil, consump,                    workPT/FT dummies
Utilstruct.numberft  = size(Utilstruct.Xngwftbc,2)-7;   % exclude abil, consump, whiteCollar dummy, workPT/FT dummies
Utilstruct.numberwc  = size(Utilstruct.Xngwftwc,2)-7;   % exclude abil, consump, whiteCollar dummy, workPT/FT dummies
% create current-period flow utilities only
Utilstruct_static = createfutureflowsconsumpstruct(dataStruct,priorabilstruct,consumpstructMCint,0,S,ngpct,PmajgpaTypel,zeros(size(AdjNG)),zeros(size(AdjG)),CRRA);
Utilstruct_static.number2   = size(Utilstruct.X2nw,2)-3;       % exclude consump, grad_4yr, whiteCollar dummy
Utilstruct_static.number4s  = size(Utilstruct.X4snw,2)-3;      % exclude consump, grad_4yr, whiteCollar dummy
Utilstruct_static.number4ns = size(Utilstruct.X4nsnw,2)-3;     % exclude consump, grad_4yr, whiteCollar dummy
Utilstruct_static.numberpt  = size(Utilstruct.Xngwptbc,2)-6;   % exclude abil, consump,                    workPT/FT dummies
Utilstruct_static.numberft  = size(Utilstruct.Xngwftbc,2)-7;   % exclude abil, consump, whiteCollar dummy, workPT/FT dummies
Utilstruct_static.numberwc  = size(Utilstruct.Xngwftwc,2)-7;   % exclude abil, consump, whiteCollar dummy, workPT/FT dummies

% starting values
bstrucstruc0 = [3.117;-4.008;-0.085;0.044;-0.017;0.036;-0.187;-0.212;-0.180;-0.123;0.004;0.306;0.985;2.413;0.826;0.293;0.001;0.069;-0.035;0.682;-0.698;-0.416;-0.318;0.146;0.112;0.1026;-6.204;-0.124;-0.093;0.261;0.051;-0.319;-0.302;-0.083;-0.109;0.045;1.481;2.650;1.046;4.555;1.971;0.471;0.151;-0.362;-0.618;-1.408;0.227;0.957;0.309;0.293;0.3012;-4.934;-0.115;-0.041;0.221;0.063;-0.237;-0.149;-0.039;0.001;0.058;1.625;1.730;0.721;1.971;3.582;0.415;0.564;-0.112;-0.508;-1.837;0.181;0.365;0.107;0.134;0.1262;-3.279;0.044;-0.071;0.001;0.029;0.078;0.071;0.030;0.066;-0.014;1.185;0.043;0.665;0.628;2.222;0.986;-1.325;-0.232;-0.060;-0.104;-0.210;-0.2169;-3.289;0.037;-0.018;0.020;-0.029;0.150;0.084;0.031;0.032;-0.007;0.907;0.301;0.392;0.630;1.388;2.316;-1.491;-0.116;-0.082;-0.051;-0.021;-1.672;0.028;0.030;0.050;0.184;0.148;0.148;0.040;-0.038;-0.006;-0.599;0.110;-0.165;0.080;-0.981;-0.925;2.721;0.531;0.130;0.090;0.1263];
assert(length(bstrucstruc0)==140,'problem with starting values');

% optional code to compare analytical and numerical gradients
derivative_checker = false;
if derivative_checker==true
    o4Nu = optimset('Disp','Iter','LargeScale','off','MaxFunEvals',0,'MaxIter',0,'TolX',1e-6,'Tolfun',1e-6,'GradObj','off','DerivativeCheck','off','FinDiffType','central','FunValCheck','off');
    o4An = optimset('Disp','Iter','LargeScale','off','MaxFunEvals',0,'MaxIter',0,'TolX',1e-6,'Tolfun',1e-6,'GradObj','on' ,'DerivativeCheck','off','FinDiffType','central','FunValCheck','off');
    [bstrucstruc0,lstrucstruc,e,o,gNum]=fminunc('consumpsearchstrucmlogit',bstrucstruc0,o4Nu,Utilstruct.ClImps,lambda,Utilstruct,Utilstruct.grad_4yrlImps,AdjNG,AdjG,Utilstruct.sdemog,S,q.*PmajgpaTypel);
    [bstrucstruc0,lstrucstruc,e,o,gAna]=fminunc('consumpsearchstrucmlogit',bstrucstruc0,o4An,Utilstruct.ClImps,lambda,Utilstruct,Utilstruct.grad_4yrlImps,AdjNG,AdjG,Utilstruct.sdemog,S,q.*PmajgpaTypel);
    dlmwrite(strcat(ipath,'gradient_checker_structural.csv'),[gNum zeros(size(gNum,1),1) gAna]);
    return
end

% estimate choice model
o4=optimset('Disp','Iter','LargeScale','off','MaxFunEvals',2000000,'MaxIter',15000,'TolX',1e-6,'Tolfun',1e-6,'GradObj','on','DerivativeCheck','off','FinDiffType','central');
[bstrucstruc,lstrucstruc,e,o,gstrucstruc,hstrucstruc]=fminunc('consumpsearchstrucmlogit',bstrucstruc0,o4,Utilstruct.ClImps,lambda,Utilstruct,Utilstruct.grad_4yrlImps,AdjNG,AdjG,Utilstruct.sdemog,S,q.*PmajgpaTypel);
strucparms.bstrucstruc = bstrucstruc;
strucparms.lstrucstruc = lstrucstruc;
strucparms.hstrucstruc = hstrucstruc;
save(strcat(ipath,'everything_consumpstructural_FVfast',num2str(guess),'.mat'),'-v7.3','strucparms');

%------------------------------------------------------------------------------
% Summary stats on entire future value term (future flow util + CCP adj)
%------------------------------------------------------------------------------
% create conditional value functions (current flows + future flows + Adj's)
[vNG,vG]=consumpsearchstruc_condvalfns(bstrucstruc,Utilstruct.ClImps,lambda,Utilstruct,Utilstruct.grad_4yrlImps,AdjNG,AdjG,Utilstruct.sdemog,S,q.*PmajgpaTypel);
% create u + u_t+1 flow utils (current flows + future flows)
[fNG,fG]=consumpsearchstruc_condvalfns(bstrucstruc,Utilstruct.ClImps,lambda,Utilstruct,Utilstruct.grad_4yrlImps,zeros(size(AdjNG)),zeros(size(AdjG)),Utilstruct.sdemog,S,q.*PmajgpaTypel);
% create current flows
[uNG,uG]=consumpsearchstruc_condvalfns(bstrucstruc,Utilstruct_static.ClImps,lambda,Utilstruct_static,Utilstruct_static.grad_4yrlImps,zeros(size(AdjNG)),zeros(size(AdjG)),Utilstruct_static.sdemog,S,q.*PmajgpaTypel);
% take difference to get FV's
FVNG = vNG-uNG;
FVG  = vG -uG ;
% take difference to get FV's
FUNG = fNG-uNG;
FUG  = fG -uG ;
% get summary stats on future value terms (future flows plus Adj's)
summarize(FVNG(flagNG,:),sumoptNG);
summarize(FVG (flagG ,:),sumoptG);
% who are the people who have negative future value of blue-collar work after 4yr graduation?
previdx = [13:19];
disp('characteristics of 4yr grads with negative BC work FV (rel. to home)');
summarize(Utilstruct_static.Xgwptbc( (FVG(:,1)<=0 | FVG(:,3)<=0) & flagG,previdx));
disp('characteristics of undergrads with negative WC work FV (rel. to home)');
summarize(Utilstruct_static.X2ftbc( (FVNG(:,17)<=0 | FVNG(:,19)<=0) & flagNG,previdx));
disp('characteristics of undergrads with negative 2yr or 4yr S FV (rel. to home)');
summarize(Utilstruct_static.X2ftbc( (FVNG(:,5)<=0 | FVNG(:,10)<=0) & flagNG,previdx));
save([ipath,'u_jtplus1'],'-v7.3','FUNG','FUG');

%------------------------------------------------------------------------------
% Print output to spreadsheet
%------------------------------------------------------------------------------
printresults_strucconsumpstruc(bstrucstruc,hstrucstruc,lstrucstruc,Utilstruct,sdemog,Utilstruct.ClImps,q,PmajgpaTypel,S,ipath)
disp(['Time spent estimating DDC utility parameters: ',num2str(toc/60),' minutes']);

diary('off'); 
