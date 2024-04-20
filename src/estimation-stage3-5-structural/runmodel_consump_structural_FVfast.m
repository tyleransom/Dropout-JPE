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
ipath = '../../output/utility/';

delete(strcat(ipath,'runmodel_consumpstructural_FVfast',num2str(guess),'.diary'));
diary( strcat(ipath,'runmodel_consumpstructural_FVfast',num2str(guess),'.diary'));
tic
OS = 'cluster';

% Set seed
rng(guess);

% Add path
addpath('functions');

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
% create graduation probabilities to put in flow utility estimation
gprobdiffs = creategprobdiffs(dataStruct,priorabilstruct,gradparms,ngpct,S);
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
bstrucstruc0 = [2.399;0.125;-4.303;-0.036;0.055;0.037;0.172;-0.145;-0.179;-0.140;-0.079;0.013;0.151;1.034;2.456;1.257;-0.065;0.031;0.105;-0.031;0.649;-0.719;-0.542;-0.427;-0.063;0.444;-0.013;-6.987;-0.058;-0.032;0.403;0.306;-0.200;-0.162;0.127;0.023;0.058;1.667;2.742;1.275;4.816;2.055;0.583;0.266;-0.497;-0.695;-1.389;0.401;0.819;0.345;0.339;-0.037;-5.365;-0.039;0.040;0.292;0.239;-0.184;-0.097;0.039;0.065;0.065;1.363;1.809;0.712;2.213;3.435;0.383;0.564;-0.097;-0.359;-1.785;0.072;0.416;0.098;0.487;0.057;-3.022;0.022;-0.070;0.006;0.061;0.074;0.047;0.034;0.054;-0.013;1.168;0.049;0.716;0.596;2.186;0.964;-1.285;-0.202;-0.137;-0.024;0.030;-0.270;-2.921;0.010;-0.030;0.018;-0.046;0.195;0.112;0.072;0.064;-0.004;0.852;0.280;0.379;0.558;1.357;2.271;-1.463;-0.007;-0.034;0.005;-0.067;-1.617;-0.001;0.029;0.053;0.202;0.151;0.150;0.040;-0.021;-0.002;-0.580;0.118;-0.158;0.044;-0.966;-0.923;2.693;0.503;0.060;0.050;0.033];
assert(length(bstrucstruc0)==141,'problem with starting values');

% optional code to compare analytical and numerical gradients
derivative_checker = false;
if derivative_checker==true
    o4Nu = optimset('Disp','Iter','LargeScale','off','MaxFunEvals',0,'MaxIter',0,'TolX',1e-6,'Tolfun',1e-6,'GradObj','off','DerivativeCheck','off','FinDiffType','central','FunValCheck','off');
    o4An = optimset('Disp','Iter','LargeScale','off','MaxFunEvals',0,'MaxIter',0,'TolX',1e-6,'Tolfun',1e-6,'GradObj','on' ,'DerivativeCheck','off','FinDiffType','central','FunValCheck','off');
    [bstrucstruc0,lstrucstruc,e,o,gNum]=fminunc('consumpsearchstrucmlogit',bstrucstruc0,o4Nu,Utilstruct.ClImps,lambda,Utilstruct,Utilstruct.grad_4yrlImps,gprobdiffs,AdjNG,AdjG,Utilstruct.sdemog,S,q.*PmajgpaTypel,Beta);
    [bstrucstruc0,lstrucstruc,e,o,gAna]=fminunc('consumpsearchstrucmlogit',bstrucstruc0,o4An,Utilstruct.ClImps,lambda,Utilstruct,Utilstruct.grad_4yrlImps,gprobdiffs,AdjNG,AdjG,Utilstruct.sdemog,S,q.*PmajgpaTypel,Beta);
    dlmwrite(strcat(ipath,'gradient_checker_structural.csv'),[gNum zeros(size(gNum,1),1) gAna]);
    return
end

% estimate choice model
o4=optimset('Disp','Iter','LargeScale','off','MaxFunEvals',2000000,'MaxIter',15000,'TolX',1e-6,'Tolfun',1e-6,'GradObj','on','DerivativeCheck','off','FinDiffType','central');
[bstrucstruc,lstrucstruc,e,o,gstrucstruc,hstrucstruc]=fminunc('consumpsearchstrucmlogit',bstrucstruc0,o4,Utilstruct.ClImps,lambda,Utilstruct,Utilstruct.grad_4yrlImps,gprobdiffs,AdjNG,AdjG,Utilstruct.sdemog,S,q.*PmajgpaTypel,Beta);
strucparms.bstrucstruc = bstrucstruc;
strucparms.lstrucstruc = lstrucstruc;
strucparms.hstrucstruc = hstrucstruc;
save(strcat(ipath,'everything_consumpstructural_FVfast',num2str(guess),'.mat'),'-v7.3','strucparms');

% %------------------------------------------------------------------------------
% % Summary stats on entire future value term (future flow util + CCP adj)
% %------------------------------------------------------------------------------
% % create conditional value functions (current flows + future flows + Adj's)
% [vNG,vG]=consumpsearchstruc_condvalfns(bstrucstruc,Utilstruct.ClImps,lambda,Utilstruct,Utilstruct.grad_4yrlImps,AdjNG,AdjG,Utilstruct.sdemog,S,q.*PmajgpaTypel);
% % create u + u_t+1 flow utils (current flows + future flows)
% [fNG,fG]=consumpsearchstruc_condvalfns(bstrucstruc,Utilstruct.ClImps,lambda,Utilstruct,Utilstruct.grad_4yrlImps,zeros(size(AdjNG)),zeros(size(AdjG)),Utilstruct.sdemog,S,q.*PmajgpaTypel);
% % create current flows
% [uNG,uG]=consumpsearchstruc_condvalfns(bstrucstruc,Utilstruct_static.ClImps,lambda,Utilstruct_static,Utilstruct_static.grad_4yrlImps,zeros(size(AdjNG)),zeros(size(AdjG)),Utilstruct_static.sdemog,S,q.*PmajgpaTypel);
% % take difference to get FV's
% FVNG = vNG-uNG;
% FVG  = vG -uG ;
% % take difference to get FV's
% FUNG = fNG-uNG;
% FUG  = fG -uG ;
% % get summary stats on future value terms (future flows plus Adj's)
% summarize(FVNG(flagNG,:),sumoptNG);
% summarize(FVG (flagG ,:),sumoptG);
% % who are the people who have negative future value of blue-collar work after 4yr graduation?
% previdx = [13:19];
% disp('characteristics of 4yr grads with negative BC work FV (rel. to home)');
% summarize(Utilstruct_static.Xgwptbc( (FVG(:,1)<=0 | FVG(:,3)<=0) & flagG,previdx));
% disp('characteristics of undergrads with negative WC work FV (rel. to home)');
% summarize(Utilstruct_static.X2ftbc( (FVNG(:,17)<=0 | FVNG(:,19)<=0) & flagNG,previdx));
% disp('characteristics of undergrads with negative 2yr or 4yr S FV (rel. to home)');
% summarize(Utilstruct_static.X2ftbc( (FVNG(:,5)<=0 | FVNG(:,10)<=0) & flagNG,previdx));
% save([ipath,'u_jtplus1'],'-v7.3','FUNG','FUG');

%------------------------------------------------------------------------------
% Print output to spreadsheet
%------------------------------------------------------------------------------
printresults_strucconsumpstruc(bstrucstruc,hstrucstruc,lstrucstruc,Utilstruct,sdemog,Utilstruct.ClImps,q,PmajgpaTypel,S,ipath)
disp(['Time spent estimating DDC utility parameters: ',num2str(toc/60),' minutes']);

diary('off'); 
