%===============================================================================
% Compute FV adjustment terms given static choice estimates
%===============================================================================

%------------------------------------------------------------------------------
% Initialize
%------------------------------------------------------------------------------
clear all; clc;
if isempty(str2num(getenv('SLURM_ARRAY_TASK_ID'))) & isempty(str2num(getenv('SLURM_JOB_ID')))
    guess = 16;
elseif ~isempty(str2num(getenv('SLURM_ARRAY_TASK_ID')))
    guess=str2num(getenv('SLURM_ARRAY_TASK_ID'))
else
    guess=str2num(getenv('SLURM_JOB_ID'));
end

% File path for saving and loading results
ipath = '../../../output/utility-grid-search/CRRA-0-7/';

delete(strcat(ipath,'computeFVfastParallel_',num2str(guess),'.diary'));
diary( strcat(ipath,'computeFVfastParallel_',num2str(guess),'.diary'));
tic
OS = 'cluster';

% Add functions to path
addpath('../../estimation-stage3-5-structural/functions');

% Set seed
rng(guess);

% Discount factor
Beta = 0.9; 

%------------------------------------------------------------------------------
% Read in data and parameters from all previous steps
%------------------------------------------------------------------------------
[status,cmdout] = system(['ls -t ',ipath,'everything_jointsearch_WCabsorb*.mat | head -1'],'-echo');
ffffff = strtrim(cmdout);
load(ffffff);
% flexible choice model parameters
v2struct(searchparms);
% consumption polynomial parameters
load(strcat(ipath,'cmapoutput.mat'));
cmapParms = struct('cmap_nograd',cmap_nograd,'cmap_nograd_work',cmap_nograd_work,'cmap_grad_work',cmap_grad_work,'scaler_nograd',scaler_nograd,'scaler_nograd_work',scaler_nograd_work,'scaler_grad_work',scaler_grad_work);
load(strcat(ipath,'cmapoutput_t1.mat'));
cmapParms_t1 = struct('cmap_nograd',cmap_nograd,'cmap_nograd_work',cmap_nograd_work,'cmap_grad_work',cmap_grad_work,'scaler_nograd',scaler_nograd,'scaler_nograd_work',scaler_nograd_work,'scaler_grad_work',scaler_grad_work); 
load(strcat(ipath,'cmapoutput_t2.mat'));
cmapParms_t2 = struct('cmap_nograd',cmap_nograd,'cmap_nograd_work',cmap_nograd_work,'cmap_grad_work',cmap_grad_work,'scaler_nograd',scaler_nograd,'scaler_nograd_work',scaler_nograd_work,'scaler_grad_work',scaler_grad_work); 
intrate = 0.05;
% graduation parameters
Xgrad = gradparms.Xlogit;
% check conformability of learning parameter vectors and data
assert(size(learnparms.bstartg,1)==size(learnStruct.xgNS,2),'bstartg and xgNS are not conformable');
assert(size(gradparms.P_grad_betas4,1)==size(Xgrad,2),'P_grad_betas4 and Xgrad are not conformable');
% check CRRA value
assert(norm(CRRA-0.7,Inf)<1e-6, ['CRRA wrongly read in; CRRA is supposed to be 0.7 but it is actually ',num2str(CRRA)])


%------------------------------------------------------------------------------
% Stack learning results data to conform to search-offer stacked data
%------------------------------------------------------------------------------
idelta = learnparms.Delta\eye(5,5);
dataStruct.ideltaMat = repmat(reshape(idelta,[1 5 5]),[size(dataStruct.yrclImps,1) 1 1]);
priorabilstructsearch = prior_ability_DDC_search(learnparms,learnStruct,dataStruct,S);
% check that priorabilstructsearch is the same as priorabilstruct
fields = fieldnames(priorabilstruct);
for i = 1:numel(fields)
    if ~isequal(priorabilstruct.(fields{i}), priorabilstructsearch.(fields{i}))
        j1    = priorabilstruct.(fields{i});
        j2    = priorabilstructsearch.(fields{i});
        ttttt = norm(j1(:) - j2(:), Inf);
        disp(['Field ', fields{i}, ' is not equal. Inf norm is ', num2str(ttttt)]);
    end
end


%------------------------------------------------------------------------------
% Create future value terms from CCPs
%------------------------------------------------------------------------------
tic
D = 10;
CRRA
boffer
[AdjNG,AdjG] = formFVfricIntFastParallel(Beta,Utilstruct,boffer,gradparms.P_grad_betas4,Xgrad,dataStruct,priorabilstructsearch,learnparms,AR1parms,S,ngpct,Clb,CRRA,intrate,D,bstrucsearch,dataStruct.ClImps,cmapParms,cmapParms_t1,cmapParms_t2,guess);
save([ipath,'adjIntMatsSearchStructuralFast10D',num2str(guess)],'-v7.3','AdjNG','AdjG');
disp(['Time spent creating FV terms: ',num2str(toc/60),' minutes']);

diary('off');

