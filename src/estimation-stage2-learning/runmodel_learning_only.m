%------------------------------------------------------------------------------
% Initialize
%------------------------------------------------------------------------------
clear; clc;
if isempty(str2num(getenv('SLURM_ARRAY_TASK_ID'))) && isempty(str2num(getenv('SLURM_JOB_ID')))
    guess = 52;
elseif ~isempty(str2num(getenv('SLURM_ARRAY_TASK_ID')))
    guess=str2num(getenv('SLURM_ARRAY_TASK_ID'));
else
    guess=str2num(getenv('SLURM_JOB_ID'));
end

% File path for saving learning results
ipath = '../../output/learning/';

% Diary file
delete(strcat(ipath,'runmodel_learning',num2str(guess),'.diary'));
diary(strcat(ipath,'runmodel_learning',num2str(guess),'.diary'));
tic
OS = 'cluster';

% Add functions to path
addpath('functions');

label_switched = true; % flag for if the labels switched in the measurement system

% Set seed
rng(guess);

% initialize optimization options
o1=optimset('Disp','off','FunValCheck','on','MaxFunEvals',100000,'MaxIter',15000);
o2=optimset('Disp','off','FunValCheck','on','MaxFunEvals',2000000,'MaxIter',15000);
o3=optimset('Disp','iter','FunValCheck','on','MaxFunEvals',2000000,'MaxIter',15000,'GradObj','on','LargeScale','off');
o4=optimset('Disp','off','FunValCheck','on','MaxFunEvals',2000000,'MaxIter',15000,'GradObj','on','DerivativeCheck','on','LargeScale','off');
o5=optimset('Disp','off','FunValCheck','on','MaxFunEvals',2000000,'MaxIter',15000,'TolX',1e-4,'TolFun',1e-4');
o6=optimset('Disp','iter','FunValCheck','on','MaxFunEvals',2000000,'MaxIter',15000,'GradObj','on','DerivativeCheck','on','LargeScale','off');

%------------------------------------------------------------------------------
% Initialize hyperparameters
%------------------------------------------------------------------------------
% File path for data
fname = '../../data/nlsy97/cleaned/wide_data_male20220401_tscrGPA.mat';

% File path for stage 1 semiparametric results
st1fname = '../../output/all-stage-1/everything_all_stage1_interact_type_36688212.mat';

% Number of types
S = 8;

% Number of GPA *tiles (for GPA imputation)
ngpct = 4;

% set threshold of noise in starting values
alpha = 2;


%------------------------------------------------------------------------------
% Process data
%------------------------------------------------------------------------------
% load the main database and manipulate it
dataStruct  = createchoicedata(fname,S,ngpct);

% load the learning data
learnStruct = createlearningdata(dataStruct,S,guess,ipath);



%------------------------------------------------------------------------------
% Starting values for learning model
%------------------------------------------------------------------------------
% load in q's from stage 1
load(st1fname,'P*T*','prior')

% load in learning starting values
load(strcat(ipath,'startvals/learningstartvals.mat'));

% test conformability
assert(isequal(size(learnStruct.xnS,2),size(learnparms.bstartn,1)),'xnS and bstartn not same size');
assert(isequal(size(learnStruct.xgS,2),size(learnparms.bstartg,1)),'xnS and bstartn not same size');
assert(isequal(size(learnStruct.xnNS,2),size(learnparms.bstartn,1)),'xnS and bstartn not same size');
assert(isequal(size(learnStruct.xgNS,2),size(learnparms.bstartg,1)),'xnS and bstartn not same size');
assert(isequal(size(learnStruct.x2,2),size(learnparms.bstart2,1)),'x2 and bstart2 not same size');
assert(isequal(size(learnStruct.x4s,2),size(learnparms.bstart4s,1)),'x4s and bstart4s not same size');
assert(isequal(size(learnStruct.x4h,2),size(learnparms.bstart4h,1)),'x4h and bstart4h not same size');


%------------------------------------------------------------------------------
% learning estimation
%------------------------------------------------------------------------------
tic
learnparms = estimatelearning(dataStruct,learnStruct,learnparms,PTypeTilde,PmajgpaTypel,S);
disp(['Time spent estimating structural learning model: ',num2str(toc/60),' minutes']);

% update prior abilities
priorabilstruct   = prior_ability_DDC(learnparms,learnStruct,dataStruct,S);
   

%------------------------------------------------------------------------------
% graduation estimation
%------------------------------------------------------------------------------
tic
test = false;        
gradparms = estimategradlogit(dataStruct,priorabilstruct,PmajgpaTypel,dataStruct.num_GPA_pctiles,S,ipath);
v2struct(gradparms);
disp(['Time spent running graduation logit estimation: ',num2str(toc),' seconds']);

% print end-of-panel posterior variances by sector
[throwout] = recoverposteriorvar2015(dataStruct,priorabilstruct,PmajgpaTypel,S); 

% print results
printresults(learnparms,gradparms,guess,ipath,'');


save(strcat(ipath,'everything',num2str(guess)),'-v7.3','dataStruct','learnStruct','priorabilstruct','learnparms*','gradparms','S','ngpct'); 
save(strcat(ipath,'parmresults',num2str(guess)),'learnparms','gradparms','P*T*');

diary('off');
