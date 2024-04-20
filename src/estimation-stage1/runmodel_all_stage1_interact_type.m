%-------------------------------------------------------------------------------
% Initialize
%-------------------------------------------------------------------------------
clear; clc;

% initialize HPC environmental variables
if isempty(str2num(getenv('SLURM_ARRAY_TASK_ID'))) && isempty(str2num(getenv('SLURM_JOB_ID')))
    guess = 49;
    guess = 37753198;
elseif ~isempty(str2num(getenv('SLURM_ARRAY_TASK_ID')))
    guess=str2num(getenv('SLURM_ARRAY_TASK_ID'));
else
    guess=str2num(getenv('SLURM_JOB_ID'));
end

% File path for saving learning results
ipath = '../../output/all-stage-1/';

% Diary file
delete(strcat(ipath,'runmodel_all_stage1_interact_type_',num2str(guess),'.diary'));
diary(strcat(ipath,'runmodel_all_stage1_interact_type_',num2str(guess),'.diary'));
tic
OS = 'cluster';

% Add functions to path
addpath('functions');

% Set seed
rng(guess);

% initialize optimization options
o1=optimset('Disp','off','FunValCheck','on','MaxFunEvals',100000,'MaxIter',15000);
o2=optimset('Disp','off','FunValCheck','on','MaxFunEvals',2000000,'MaxIter',15000);
o3=optimset('Disp','iter','FunValCheck','on','MaxFunEvals',2000000,'MaxIter',15000,'GradObj','on','LargeScale','off');
o4=optimset('Disp','off','FunValCheck','on','MaxFunEvals',2000000,'MaxIter',15000,'GradObj','on','DerivativeCheck','on','LargeScale','off');
o5=optimset('Disp','off','FunValCheck','on','MaxFunEvals',2000000,'MaxIter',15000,'TolX',1e-4,'TolFun',1e-4');
o6=optimset('Disp','iter','FunValCheck','on','MaxFunEvals',2000000,'MaxIter',15000,'GradObj','on','DerivativeCheck','on','LargeScale','off');



%-------------------------------------------------------------------------------
% Initialize hyperparameters
%-------------------------------------------------------------------------------
% File path for data
fname = '../../data/nlsy97/cleaned/wide_data_male20220401_tscrGPA.mat';

% Number of unobserved types
S = 8;

% Number of missing GPA percentiles
num_GPA_pctiles = 4;

% set threshold of noise in starting values
alpha = 2;



%-------------------------------------------------------------------------------
% Process data
%-------------------------------------------------------------------------------
% load data on choices, outcomes, and covariates
df          = createchoicedata(fname,S,num_GPA_pctiles);
invIDImp    = df.invIDImp;
IDImp       = [df.ID(~df.everImpMaj & ~df.everImpGPA & ~df.everImpMajGPA);df.ID(df.everImpGPA);df.ID(df.everImpMaj);df.ID(df.everImpMajGPA)];
baseN       = df.baseN;
NimpMaj     = df.NimpMaj;
NimpGPA     = df.NimpGPA;
NimpMajGPA  = df.NimpMajGPA;

% load data for measurement system
md = createmeasdata(fname);

% compute signals
[prab] = prior_mean_outcome_DDC_standardized(df,S);



%-------------------------------------------------------------------------------
% construct covariate matrices
%-------------------------------------------------------------------------------
% for unobserved types
A = [1 1 1; 1 1 0; 1 0 1; 1 0 0; 0 1 1; 0 1 0; 0 0 1; 0 0 0];
cv.type_dummies = kron(A,ones(df.Ntilde*df.T,1,1));

% for other parts of the model
cv.demogs  = makegrid2_con([ones(df.N*df.T,1) df.black df.hispanic df.HS_grades df.Parent_college df.birthYr==1980 df.birthYr==1981 df.birthYr==1982 df.birthYr==1983 df.famInc],df.impMajlp,df.impGPAlp,df.impMajGPAlp,num_GPA_pctiles,S);
cv.yrdums  = makegrid2_con([df.year<=1999 df.year==2000 df.year==2001 df.year==2002 df.year==2003 df.year==2004 df.year==2005 df.year==2006 df.year==2007 df.year==2008 df.year==2009 df.year==2010 df.year==2011 df.year==2012 df.year==2013 df.year==2014],df.impMajlp,df.impGPAlp,df.impMajGPAlp,num_GPA_pctiles,S); 
cv.expers  = [df.agelImps (df.agelImps+5).^2 df.cum_2yrlImps df.cum_2yrlImps.^2 df.cum_4yrSlImps df.cum_4yrSlImps.^2 df.cum_4yrNSlImps df.cum_4yrNSlImps.^2 df.cum_2yrlImps.*(df.cum_4yrSlImps+df.cum_4yrNSlImps) df.experlImps df.experlImps.^2 df.exper_white_collarlImps df.exper_white_collarlImps.^2 df.experlImps.*df.exper_white_collarlImps]; 
cv.experw  = [                               df.cum_2yrlImps df.cum_2yrlImps.^2 df.cum_4yrSlImps df.cum_4yrSlImps.^2 df.cum_4yrNSlImps df.cum_4yrNSlImps.^2 df.cum_2yrlImps.*(df.cum_4yrSlImps+df.cum_4yrNSlImps) df.experlImps df.experlImps.^2 df.exper_white_collarlImps df.exper_white_collarlImps.^2 df.experlImps.*df.exper_white_collarlImps]; 
cv.prevs   = [df.prev_HSlImps df.prev_2yrlImps df.prev_4yrSlImps df.prev_4yrNSlImps df.prev_PTlImps df.prev_FTlImps df.prev_WClImps];
cv.currs   = [df.in_2yrlImps df.in_scilImps df.in_humlImps df.in_PTlImps df.in_FTlImps df.in_WClImps];
cv.currws  = [df.in_2yrlImps df.in_scilImps df.in_humlImps df.grad_4yrlImps==1 (df.grad_4yrlImps==1 & df.finalMajorScilImps==1)];
cv.currgs  = [          df.in_scilImps df.in_PTlImps df.in_FTlImps df.in_WClImps];
cv.currgg  = [                         df.in_PTlImps df.in_FTlImps df.in_WClImps];
cv.currwk  = [df.in_FTlImps df.grad_4yrlImps==1 (df.grad_4yrlImps==1 & df.finalMajorScilImps==1)];
cv.grad4yX = bsxfun(@times, df.grad_4yrlImps==1                            ,makegrid2_con([df.black df.hispanic df.HS_grades df.Parent_college df.birthYr==1980 df.birthYr==1981 df.birthYr==1982 df.birthYr==1983 df.famInc df.age (df.age+5).^2 df.cum_2yr df.cum_2yr.^2 df.cum_4yrS df.cum_4yrS.^2 df.cum_4yrNS df.cum_4yrNS.^2 df.cum_2yr.*(df.cum_4yrS+df.cum_4yrNS) df.exper df.exper.^2 df.exper_white_collar df.exper_white_collar.^2 df.exper.*df.exper_white_collar df.prev_4yrS df.prev_4yrNS df.prev_PT df.prev_FT df.prev_WC],df.impMajlp,df.impGPAlp,df.impMajGPAlp,num_GPA_pctiles,S)); 
cv.gr4yscX = bsxfun(@times,(df.grad_4yrlImps==1 & df.finalMajorScilImps==1),makegrid2_con([df.cum_4yrS df.cum_4yrNS df.exper df.exper_white_collar df.prev_PT df.prev_FT df.prev_WC],df.impMajlp,df.impGPAlp,df.impMajGPAlp,num_GPA_pctiles,S)); 
cv.signals = [prab.prior_mean_outcome_S_vec prab.prior_mean_outcome_U_vec prab.prior_mean_outcome_4S_vec prab.prior_mean_outcome_4NS_vec prab.prior_mean_outcome_2_vec];
cv.signalXwage = cat(2,bsxfun(@times,cv.signals(:,1:2),(df.cum_2yrlImps+df.cum_4yrlImps)),...
                       bsxfun(@times,cv.signals(:,1:2),df.experlImps),...
                       bsxfun(@times,cv.signals(:,1:2),df.exper_white_collarlImps),...
                       bsxfun(@times,cv.signals(:,1:2),(df.prev_2yrlImps + df.prev_4yrSlImps + df.prev_4yrNSlImps)),...
                       bsxfun(@times,cv.signals(:,1:2),(df.prev_PTlImps + df.prev_FTlImps)),...
                       bsxfun(@times,cv.signals(:,1:2),df.prev_WClImps));
cv.signalXgpa  = cat(2,bsxfun(@times,cv.signals(:,3:5),(df.cum_2yrlImps+df.cum_4yrlImps)),...
                       bsxfun(@times,cv.signals(:,3:5),df.experlImps),...
                       bsxfun(@times,cv.signals(:,3:5),df.exper_white_collarlImps),...
                       bsxfun(@times,cv.signals(:,3:5),(df.prev_2yrlImps + df.prev_4yrSlImps + df.prev_4yrNSlImps)),...
                       bsxfun(@times,cv.signals(:,3:5),(df.prev_PTlImps + df.prev_FTlImps)),...
                       bsxfun(@times,cv.signals(:,3:5),df.prev_WClImps));
cv.signalXall  = cat(2,bsxfun(@times,cv.signals,       (df.cum_2yrlImps+df.cum_4yrlImps)),...
                       bsxfun(@times,cv.signals,       df.experlImps),...
                       bsxfun(@times,cv.signals,       df.exper_white_collarlImps),...
                       bsxfun(@times,cv.signals,       (df.prev_2yrlImps + df.prev_4yrSlImps + df.prev_4yrNSlImps)),...
                       bsxfun(@times,cv.signals,       (df.prev_PTlImps + df.prev_FTlImps)),...
                       bsxfun(@times,cv.signals,       df.prev_WClImps));
cv.signalXgrad = cat(2,bsxfun(@times,cv.signals(:,3:4),(df.cum_2yrlImps+df.cum_4yrlImps)),...
                       bsxfun(@times,cv.signals(:,3:4),df.experlImps),...
                       bsxfun(@times,cv.signals(:,3:4),df.in_scilImps),...
                       bsxfun(@times,cv.signals(:,3:4),df.in_worklImps),...
                       bsxfun(@times,cv.signals(:,3:4),df.in_WClImps));
cv.signalWCtype = bsxfun(@times,cv.type_dummies,cv.signals(:,1));
cv.signalBCtype = bsxfun(@times,cv.type_dummies,cv.signals(:,2));
cv.signal4Stype = bsxfun(@times,cv.type_dummies,cv.signals(:,3));
cv.signal4Htype = bsxfun(@times,cv.type_dummies,cv.signals(:,4));
cv.signal2Ytype = bsxfun(@times,cv.type_dummies,cv.signals(:,5));



%-------------------------------------------------------------------------------
% construct cell arrays holding names (for ease of printing results later)
%-------------------------------------------------------------------------------
cv.type_dummies_names = {'sch abil H', 'sch pref H', 'work abil/pref H'};
cv.demogs_names  = {'Intercept','black','hispanic','HS_grades','Parent_college','birthYr1980','birthYr1981','birthYr1982','birthYr1983','famInc'};
cv.yrdums_names  = {'year<=99','year=00','year=01','year=02','year=03','year=04','year=05','year=06','year=07','year=08','year=09','year=10','year=11','year=12','year=13','year=14'};
cv.experw_names  = {                  'cum_2yr','cum_2yr^2','cum_4yrS','cum_4yrS^2','cum_4yrNS','cum_4yrNS^2','cum_2yr * cum_4yr','exper','exper^2','exper_white_collar','exper_white_collar^2','exper*exper_white_collar'};
cv.expers_names  = {'age','(age+5)^2','cum_2yr','cum_2yr^2','cum_4yrS','cum_4yrS^2','cum_4yrNS','cum_4yrNS^2','cum_2yr * cum_4yr','exper','exper^2','exper_white_collar','exper_white_collar^2','exper*exper_white_collar'};
cv.prevs_names   = {'prev_HS','prev_2yr','prev_4yrS','prev_4yrNS','prev_PT','prev_FT','prev_WC'};
cv.currs_names   = {'in_2yr','in_4yrS','in_4yrNS','in_PT','in_FT','in_WC'};
cv.currws_names  = {'in_2yr','in_4yrS','in_4yrNS','grad_4yr','grad_4yr*final_sci_maj'};
cv.grad4yX_names = {'grad_4yr*black','grad_4yr*hispanic','grad_4yr*HS_grades','grad_4yr*Parent_college','grad_4yr*birthYr1980','grad_4yr*birthYr1981','grad_4yr*birthYr1982','grad_4yr*birthYr1983','grad_4yr*famInc','grad_4yr*age','grad_4yr*(age+5)^2','grad_4yr*cum_2yr','grad_4yr*cum_2yr^2','grad_4yr*cum_4yrS','grad_4yr*cum_4yrS^2','grad_4yr*cum_4yrNS','grad_4yr*cum_4yrNS^2','grad_4yr*cum_2yr*cum_4yr','grad_4yr*exper','grad_4yr*exper^2','grad_4yr*exper_white_collar','grad_4yr*exper_white_collar^2','grad_4yr*exper*exper_white_collar','grad_4yr*prev_4yrS','grad_4yr*prev_4yrNS','grad_4yr*prev_PT','grad_4yr*prev_FT','grad_4yr*prev_WC'};
cv.gr4yscX_names = {'grad_4yr_sci*cum_4yrS','grad_4yr_sci*cum_4yrNS','grad_4yr_sci*exper','grad_4yr_sci*exper_white_collar','grad_4yr_sci*prev_PT','grad_4yr_sci*prev_FT','grad_4yr_sci*prev_WC'};
cv.currgs_names  = {'in_4yrS','in_PT','in_FT','in_WC'};
cv.currgg_names  = {'in_PT','in_FT','in_WC'};
cv.currwk_names  = {'in_FT','grad_4yr','grad_4yr*final_sci_maj'};
cv.signals_names = {'signal_WC','signal_BC','signal_4S','signal_4NS','signal_2'};
cv.signalw_names = {'signal_WC','signal_BC'};
cv.signalgpa_names = {'signal_4S','signal_4NS','signal_2'};
cv.signalgr_names = {'signal_4S','signal_4NS'};
cv.signalWCtype_names = {'sch abil H * signal_WC', 'sch pref H * signal_WC', 'work abil/pref H * signal_WC'};
cv.signalBCtype_names = {'sch abil H * signal_BC', 'sch pref H * signal_BC', 'work abil/pref H * signal_BC'};
cv.signal4Stype_names = {'sch abil H * signal_4S', 'sch pref H * signal_4S', 'work abil/pref H * signal_4S'};
cv.signal4Htype_names = {'sch abil H * signal_4H', 'sch pref H * signal_4H', 'work abil/pref H * signal_4H'};
cv.signal2Ytype_names = {'sch abil H * signal_2',  'sch pref H * signal_2',  'work abil/pref H * signal_2' };
% signal interaction names (all)
cv.signalXall_names = {};
for j = 1:6 % number of columns in cv.signalXall
    for i = 1:length(cv.signals_names)
        switch j
            case 1
                suffix = '*cum_sch';
            case 2
                suffix = '*exper';
            case 3
                suffix = '*exper_white_collar';
            case 4
                suffix = '*prev_sch';
            case 5
                suffix = '*prev_work';
            case 6
                suffix = '*prev_WC';
        end
        cv.signalXall_names{j,i} = strcat(cv.signals_names{i},suffix);
    end
end
cv.signalXall_names = reshape(cv.signalXall_names,1,[]); % make it a row vector
% signal interaction names (wages)
cv.signalXwage_names = {};
for j = 1:6 % number of columns in cv.signalXwage
    for i = 1:length(cv.signalw_names)
        switch j
            case 1
                suffix = '*cum_sch';
            case 2
                suffix = '*exper';
            case 3
                suffix = '*exper_white_collar';
            case 4
                suffix = '*prev_sch';
            case 5
                suffix = '*prev_work';
            case 6
                suffix = '*prev_WC';
        end
        cv.signalXwage_names{j,i} = strcat(cv.signalw_names{i},suffix);
    end
end
cv.signalXwage_names = reshape(cv.signalXwage_names,1,[]); % make it a row vector
% signal interaction names (GPAs)
cv.signalXgpa_names = {};
for j = 1:6 % number of columns in cv.signalXgpa
    for i = 1:length(cv.signalgpa_names)
        switch j
            case 1
                suffix = '*cum_sch';
            case 2
                suffix = '*exper';
            case 3
                suffix = '*exper_white_collar';
            case 4
                suffix = '*prev_sch';
            case 5
                suffix = '*prev_work';
            case 6
                suffix = '*prev_WC';
        end
        cv.signalXgpa_names{j,i} = strcat(cv.signalgpa_names{i},suffix);
    end
end
cv.signalXgpa_names = reshape(cv.signalXgpa_names,1,[]); % make it a row vector
% signal interaction names (graduation)
cv.signalXgrad_names = {};
for j = 1:5 % number of columns in cv.signalXgrad
    for i = 1:length(cv.signalgr_names)
        switch j
            case 1
                suffix = '*cum_sch';
            case 2
                suffix = '*exper';
            case 3
                suffix = '*in_sci';
            case 4
                suffix = '*in_work';
            case 5
                suffix = '*in_WC';
        end
        cv.signalXgrad_names{j,i} = strcat(cv.signalgr_names{i},suffix);
    end
end
cv.signalXgrad_names = reshape(cv.signalXgrad_names,1,[]); % make it a row vector

% ensure that "names" matrices and data matrices are conformable
assert(size(cv.demogs,2)     ==length(cv.demogs_names), 'demogs matrix and names do not match');
assert(size(cv.yrdums,2)     ==length(cv.yrdums_names), 'yrdums matrix and names do not match');
assert(size(cv.experw,2)     ==length(cv.experw_names), 'experw matrix and names do not match');
assert(size(cv.expers,2)     ==length(cv.expers_names), 'expers matrix and names do not match');
assert(size(cv.prevs,2)      ==length(cv.prevs_names),  'prevs matrix and names do not match');
assert(size(cv.currs,2)      ==length(cv.currs_names),  'currs matrix and names do not match');
assert(size(cv.currws,2)     ==length(cv.currws_names), 'currws matrix and names do not match');
assert(size(cv.currgs,2)     ==length(cv.currgs_names), 'currgs matrix and names do not match');
assert(size(cv.currgg,2)     ==length(cv.currgg_names), 'currgg matrix and names do not match');
assert(size(cv.grad4yX,2)    ==length(cv.grad4yX_names),'grad4yX matrix and names do not match');
assert(size(cv.gr4yscX,2)    ==length(cv.gr4yscX_names),'gr4yscX matrix and names do not match');
assert(size(cv.signals,2)    ==length(cv.signals_names),'signals matrix and names do not match');
assert(size(cv.signalXall,2) ==length(cv.signalXall_names),'signalXall matrix and names do not match');
assert(size(cv.signalXwage,2)==length(cv.signalXwage_names),'signalXwage matrix and names do not match');
assert(size(cv.signalXgpa,2) ==length(cv.signalXgpa_names),'signalXgpa matrix and names do not match');
assert(size(cv.signalXgrad,2)==length(cv.signalXgrad_names),'signalXgrad matrix and names do not match');
assert(size(cv.signalWCtype,2)==length(cv.signalWCtype_names),'signalWCtype matrix and names do not match');
assert(size(cv.signalBCtype,2)==length(cv.signalBCtype_names),'signalBCtype matrix and names do not match');
assert(size(cv.signal4Stype,2)==length(cv.signal4Stype_names),'signal4Stype matrix and names do not match');
assert(size(cv.signal4Htype,2)==length(cv.signal4Htype_names),'signal4Htype matrix and names do not match');
assert(size(cv.signal2Ytype,2)==length(cv.signal2Ytype_names),'signal2Ytype matrix and names do not match');


% for measurement system
[mnd] = create_estimatemeas_data(md,A,S);

% for graduation logit
cv.gradlogit = cat(2,cv.demogs,cv.expers,cv.currgs,cv.signals,cv.signalXgrad,cv.type_dummies,cv.signal4Stype,cv.signal4Htype);
cv.gradlogit_names = cat(2,cv.demogs_names,cv.expers_names,cv.currgs_names,cv.signals_names,cv.signalXgrad_names,cv.type_dummies_names,cv.signal4Stype_names,cv.signal4Htype_names,{'N'});
assert(size(cv.gradlogit,2)==size(cv.gradlogit_names,2)-1,'gradlogit matrix and names do not match');

% wages generally
cv.wages = cat(2,cv.demogs,cv.yrdums,cv.experw,cv.prevs,cv.currws,cv.signals,cv.signalXwage,cv.type_dummies);
cv.wages_names = cat(2,cv.demogs_names,cv.yrdums_names,cv.experw_names,cv.prevs_names,cv.currws_names,cv.signals_names,cv.signalXwage_names,cv.type_dummies_names);

% for white collar wages
cv.wagesWC = cat(2,cv.wages,cv.signalWCtype);
cv.wagesWC_names = cat(2,cv.wages_names,cv.signalWCtype_names,{'sigma'},{'N'});
assert(size(cv.wagesWC,2)==size(cv.wagesWC_names,2)-2,'wagesWC matrix and names do not match');

% for blue collar wages
cv.wagesBC = cat(2,cv.wages,cv.signalBCtype);
cv.wagesBC_names = cat(2,cv.wages_names,cv.signalBCtype_names,{'sigma'},{'N'});
assert(size(cv.wagesBC,2)==size(cv.wagesBC_names,2)-2,'wagesBC matrix and names do not match');

% for college GPAs generally
cv.grades = cat(2,cv.demogs,cv.expers,cv.prevs,cv.currgg,cv.signals,cv.signalXgpa,cv.type_dummies);
cv.grades_names = cat(2,cv.demogs_names,cv.expers_names,cv.prevs_names,cv.currgg_names,cv.signals_names,cv.signalXgpa_names,cv.type_dummies_names);

% for science grades
cv.grades4S = cat(2,cv.grades,cv.signal4Stype);
cv.grades4S_names = cat(2,cv.grades_names,cv.signal4Stype_names,{'sigma'},{'N'});
assert(size(cv.grades4S,2)==size(cv.grades4S_names,2)-2,'grades4S matrix and names do not match');

% for humanities grades
cv.grades4H = cat(2,cv.grades,cv.signal4Htype);
cv.grades4H_names = cat(2,cv.grades_names,cv.signal4Htype_names,{'sigma'},{'N'});
assert(size(cv.grades4H,2)==size(cv.grades4H_names,2)-2,'grades4H matrix and names do not match');

% for 2yr grades
cv.grades2Y = cat(2,cv.grades,cv.signal2Ytype);
cv.grades2Y_names = cat(2,cv.grades_names,cv.signal2Ytype_names,{'sigma'},{'N'});
assert(size(cv.grades2Y,2)==size(cv.grades2Y_names,2)-2,'grades2Y matrix and names do not match');

% for college logit
cv.colllogit = cat(2,cv.demogs,cv.expers,cv.prevs,cv.signals,cv.signalXgpa,cv.type_dummies,cv.signal4Stype,cv.signal4Htype,cv.signal2Ytype); 
cv.coll_names = cat(2,cv.demogs_names,cv.expers_names,cv.prevs_names,cv.signals_names,cv.signalXgpa_names,cv.type_dummies_names,cv.signal4Stype_names,cv.signal4Htype_names,cv.signal2Ytype_names,{'N'});
assert(size(cv.colllogit,2)==size(cv.coll_names,2)-1,'colllogit matrix and names do not match');

% for 2yr/4yr logit
cv.c24logit = cv.colllogit;
cv.c2y4y_names = cv.coll_names;

% for hum/sci logit
cv.csclogit = cat(2,cv.demogs,cv.expers,cv.prevs,cv.signals,cv.signalXgpa,cv.type_dummies,cv.signal4Stype,cv.signal4Htype);  
cv.cscihum_names = cat(2,cv.demogs_names,cv.expers_names,cv.prevs_names,cv.signals_names,cv.signalXgpa_names,cv.type_dummies_names,cv.signal4Stype_names,cv.signal4Htype_names,{'N'});
assert(size(cv.csclogit,2)==size(cv.cscihum_names,2)-1,'csclogit matrix and names do not match');

% for work logit
cv.lbsplogit = cat(2,cv.demogs,cv.expers,cv.prevs,cv.currws,cv.signals,cv.signalXwage,cv.type_dummies,cv.signalWCtype,cv.signalBCtype);
cv.clabsup_names = cat(2,cv.demogs_names,cv.expers_names,cv.prevs_names,cv.currws_names,cv.signals_names,cv.signalXwage_names,cv.type_dummies_names,cv.signalWCtype_names,cv.signalBCtype_names,{'N'});
assert(size(cv.lbsplogit,2)==size(cv.clabsup_names,2)-1,'lbsplogit matrix and names do not match');

% for workFT logit (given working)
cv.wftlogit = cv.lbsplogit;
cv.cworkFT_names = cv.clabsup_names;

% for workWC logit (given work FT)
cv.wwclogit = cat(2,cv.demogs,cv.expers,cv.prevs,cv.currwk,cv.signals,cv.signalXwage,cv.type_dummies,cv.signalWCtype); 
cv.cworkWC_names = cat(2,cv.demogs_names,cv.expers_names,cv.prevs_names,cv.currwk_names,cv.signals_names,cv.signalXwage_names,cv.type_dummies_names,cv.signalWCtype_names,{'N'});



%-------------------------------------------------------------------------------
% initialize results tables
%-------------------------------------------------------------------------------
Ts.grl = cell2table(cv.gradlogit_names','VariableNames',{'Variable'});
Ts.wwc = cell2table(cv.wagesWC_names',  'VariableNames',{'Variable'}); 
Ts.wbc = cell2table(cv.wagesBC_names',  'VariableNames',{'Variable'}); 
Ts.g4s = cell2table(cv.grades4S_names', 'VariableNames',{'Variable'}); 
Ts.g4h = cell2table(cv.grades4H_names', 'VariableNames',{'Variable'}); 
Ts.g2y = cell2table(cv.grades2Y_names', 'VariableNames',{'Variable'}); 
Ts.col = cell2table(cv.coll_names',     'VariableNames',{'Variable'});  
Ts.c24 = cell2table(cv.c2y4y_names',    'VariableNames',{'Variable'});  
Ts.csc = cell2table(cv.cscihum_names',  'VariableNames',{'Variable'});  
Ts.cls = cell2table(cv.clabsup_names',  'VariableNames',{'Variable'});  
Ts.cft = cell2table(cv.cworkFT_names',  'VariableNames',{'Variable'});   
Ts.cwc = cell2table(cv.cworkWC_names',  'VariableNames',{'Variable'});   



%-------------------------------------------------------------------------------
% construct estimation flags
%-------------------------------------------------------------------------------
flags.baseflag = df.anyFlaglImps==0;
flags.gradl    = df.anyFlaglImps==0 & ismember(df.ClImps,6:15) & ((df.cum_2yrlImps+df.cum_4yrlImps)>=2);
flags.c24l     = df.anyFlaglImps==0 & ismember(df.ClImps,1:15);
flags.cscl     = df.anyFlaglImps==0 & ismember(df.ClImps,6:15); % & (df.miss_majorlImps==0);  % I think it should include the missing majors
flags.cftl     = df.anyFlaglImps==0 & ismember(df.ClImps,[1:4 6:9 11:14 16:19]);
flags.cwcl     = df.anyFlaglImps==0 & ismember(df.ClImps,[1:4 6:9 11:14 16:19]);
flags.wage_wc  = df.anyFlaglImps==0 & ismember(df.ClImps,[2 4 7 9 12 14 17 19]);
flags.wage_bc  = df.anyFlaglImps==0 & ismember(df.ClImps,[1 3 6 8 11 13 16 18]);
flags.g4s      = df.anyFlaglImps==0 & ismember(df.ClImps, 6:10) & (df.miss_gradeslImps==0); 
flags.g4h      = df.anyFlaglImps==0 & ismember(df.ClImps,11:15) & (df.miss_gradeslImps==0); 
flags.g2y      = df.anyFlaglImps==0 & ismember(df.ClImps, 1:5 ) & (df.miss_gradeslImps==0); 
flags.mg4s     = df.anyFlaglImps==0 & ismember(df.ClImps, 6:10); 
flags.mg4h     = df.anyFlaglImps==0 & ismember(df.ClImps,11:15); 
flags.mg2y     = df.anyFlaglImps==0 & ismember(df.ClImps, 1:5 ); 



%-------------------------------------------------------------------------------
% Starting values
%-------------------------------------------------------------------------------
% Load in meas. sys. starting values
load(strcat(ipath,'startvals/everything45.mat'),'prior','measparms','PType');
PType_scrambled = PType(df.IDImp,:);
PType_ms        = PType_scrambled(df.invIDImp,:);
assert(isequal(PType,PType_ms),'PType is not the same after scrambling and unscrambling');

% type transformations
PmajgpaTypel = reshape(kron(PType_ms(df.IDImps,:),ones(df.T,1)),[],1);

% log wage regression starting values
parms.wwc.b = [cv.wagesBC(flags.wage_wc,:)\df.wageslImps(flags.wage_wc);0.5];
parms.wbc.b = [cv.wagesWC(flags.wage_bc,:)\df.wageslImps(flags.wage_bc);0.5];

% gpa regression starting values
parms.g4s.b = [cv.grades4S(flags.g4s,:)\df.gradeslImps(flags.g4s);0.5];
parms.g4h.b = [cv.grades4H(flags.g4h,:)\df.gradeslImps(flags.g4h);0.5];
parms.g2y.b = [cv.grades2Y(flags.g2y,:)\df.gradeslImps(flags.g2y);0.5];



%-------------------------------------------------------------------------------
% EM algorithm
%-------------------------------------------------------------------------------
tic_whole = tic;
EMcriter  = 1;
iteration = 1;
likevec = [];
while  EMcriter>1e-4 && iteration<1200
%while EMcriter>1e-4 && iteration<4
    tic_inner = tic;
    oPmajgpaTypel=PmajgpaTypel;

    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    % M-step: measurement system
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    [measparms,Ts.mp] = estimatemeas(mnd,measparms,PType_ms);
    like.msy = likecalc_ms(mnd,measparms,df,S);
    parms.msys = measparms;

    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    % M-step: graduation logit
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    [parms.grl.b,~,stats] = glmfit(cv.gradlogit(flags.gradl,:), df.grad_4yr_next_yrlImps(flags.gradl),'binomial','link','logit','constant','off','weights',PmajgpaTypel(flags.gradl));
    Ts.grl.est = [parms.grl.b;round(sum(PmajgpaTypel(flags.gradl)))];
    Ts.grl.se  = [stats.se;NaN];
    like.grl = likecalc_logit(cv.gradlogit,parms.grl.b,df.grad_4yr_next_yrlImps,flags.gradl,df.Ntilde,df.T,S);

    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    % M-step: log wage and GPA regressions
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    % white collar
    [parms.wwc.b,setemp] = normalMLEfit(parms.wwc.b, cv.wagesWC(flags.wage_wc,:), df.wageslImps(flags.wage_wc), PmajgpaTypel(flags.wage_wc));
    Ts.wwc.est = [parms.wwc.b; round(sum(PmajgpaTypel(flags.wage_wc)))]; 
    Ts.wwc.se  = [full(setemp);NaN];
    like.wwc = likecalc_normMLE(cv.wagesWC,parms.wwc.b,df.wageslImps,flags.wage_wc,df.Ntilde,df.T,S);

    % blue collar
    [parms.wbc.b,setemp] = normalMLEfit(parms.wbc.b, cv.wagesBC(flags.wage_bc,:), df.wageslImps(flags.wage_bc), PmajgpaTypel(flags.wage_bc));
    Ts.wbc.est = [parms.wbc.b; round(sum(PmajgpaTypel(flags.wage_bc)))];
    Ts.wbc.se  = [full(setemp);NaN];
    like.wbc = likecalc_normMLE(cv.wagesBC,parms.wbc.b,df.wageslImps,flags.wage_bc,df.Ntilde,df.T,S);

    % 4yr science
    [parms.g4s.b,setemp] = normalMLEfit(parms.g4s.b, cv.grades4S(flags.g4s,:), df.gradeslImps(flags.g4s), PmajgpaTypel(flags.g4s));
    Ts.g4s.est = [parms.g4s.b; round(sum(PmajgpaTypel(flags.g4s)))];
    Ts.g4s.se  = [full(setemp);NaN];
    like.g4s  = likecalc_normMLE(cv.grades4S,parms.g4s.b,df.gradeslImps,flags.g4s,df.Ntilde,df.T,S);
    like.mg4s = likecalc_miss_grades(cv.grades4S,parms.g4s.b,df.gradeslImps,flags.mg4s,df,df.Ntilde,df.T,num_GPA_pctiles,S,'4yr science');

    % 4yr humanities
    [parms.g4h.b,setemp] = normalMLEfit(parms.g4h.b, cv.grades4H(flags.g4h,:), df.gradeslImps(flags.g4h), PmajgpaTypel(flags.g4h));
    Ts.g4h.est = [parms.g4h.b; round(sum(PmajgpaTypel(flags.g4h)))];
    Ts.g4h.se  = [full(setemp);NaN];
    like.g4h  = likecalc_normMLE(cv.grades4H,parms.g4h.b,df.gradeslImps,flags.g4h,df.Ntilde,df.T,S);
    like.mg4h = likecalc_miss_grades(cv.grades4H,parms.g4h.b,df.gradeslImps,flags.mg4h,df,df.Ntilde,df.T,num_GPA_pctiles,S,'4yr humanities');

    % 2yr
    [parms.g2y.b,setemp] = normalMLEfit(parms.g2y.b, cv.grades2Y(flags.g2y,:), df.gradeslImps(flags.g2y), PmajgpaTypel(flags.g2y));
    Ts.g2y.est = [parms.g2y.b; round(sum(PmajgpaTypel(flags.g2y)))];
    Ts.g2y.se  = [full(setemp);NaN];
    like.g2y  = likecalc_normMLE(cv.grades2Y,parms.g2y.b,df.gradeslImps,flags.g2y,df.Ntilde,df.T,S);
    like.mg2y = likecalc_miss_grades(cv.grades2Y,parms.g2y.b,df.gradeslImps,flags.mg2y,df,df.Ntilde,df.T,num_GPA_pctiles,S,'2yr');
        
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    % M-step: choice logits
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    % college yes/no
    [parms.col.b,~,stats] = glmfit(cv.colllogit(flags.baseflag,:), df.in_collegelImps(flags.baseflag),'binomial','link','logit','constant','off','weights',PmajgpaTypel(flags.baseflag));
    Ts.col.est = [parms.col.b; round(sum(PmajgpaTypel(flags.baseflag)))];
    Ts.col.se  = [stats.se;NaN];
    like.cl = likecalc_logit(cv.colllogit,parms.col.b,df.in_collegelImps,flags.baseflag,df.Ntilde,df.T,S);

    % 4yr yes/no (given college)
    [parms.c24.b,~,stats] = glmfit(cv.c24logit(flags.c24l,:), df.in_4yrlImps(flags.c24l),'binomial','link','logit','constant','off','weights',PmajgpaTypel(flags.c24l));
    Ts.c24.est = [parms.c24.b; round(sum(PmajgpaTypel(flags.c24l)))];
    Ts.c24.se  = [stats.se;NaN];
    like.c24l = likecalc_logit(cv.c24logit,parms.c24.b,df.in_4yrlImps,flags.c24l,df.Ntilde,df.T,S);

    % sci yes/no (given 4yr)
    [parms.csc.b,~,stats] = glmfit(cv.csclogit(flags.cscl,:), df.in_scilImps(flags.cscl),'binomial','link','logit','constant','off','weights',PmajgpaTypel(flags.cscl));
    Ts.csc.est = [parms.csc.b; round(sum(PmajgpaTypel(flags.cscl)))];
    Ts.csc.se  = [stats.se;NaN];
    like.cscl = likecalc_logit(cv.csclogit,parms.csc.b,df.in_scilImps,flags.cscl,df.Ntilde,df.T,S);

    % work yes/no
    [parms.cls.b,~,stats] = glmfit(cv.lbsplogit(flags.baseflag,:), df.in_worklImps(flags.baseflag),'binomial','link','logit','constant','off','weights',PmajgpaTypel(flags.baseflag));
    Ts.cls.est = [parms.cls.b; round(sum(PmajgpaTypel(flags.baseflag)))];
    Ts.cls.se  = [stats.se;NaN];
    like.clsl = likecalc_logit(cv.lbsplogit,parms.cls.b,df.in_worklImps,flags.baseflag,df.Ntilde,df.T,S);

    % work FT or PT (given work)
    [parms.cft.b,~,stats] = glmfit(cv.wftlogit(flags.cftl,:), df.in_FTlImps(flags.cftl),'binomial','link','logit','constant','off','weights',PmajgpaTypel(flags.cftl));
    Ts.cft.est = [parms.cft.b; round(sum(PmajgpaTypel(flags.cftl)))];
    Ts.cft.se  = [stats.se;NaN];
    like.cftl = likecalc_logit(cv.wftlogit,parms.cft.b,df.in_FTlImps,flags.cftl,df.Ntilde,df.T,S);

    % work WC or BC (given work)
    [parms.cwc.b,~,stats] = glmfit(cv.wwclogit(flags.cwcl,:), df.in_WClImps(flags.cwcl),'binomial','link','logit','constant','off','weights',PmajgpaTypel(flags.cwcl));
    Ts.cwc.est = [parms.cwc.b; round(sum(PmajgpaTypel(flags.cwcl)))];
    Ts.cwc.se  = [stats.se;NaN];
    like.cwcl = likecalc_logit(cv.wwclogit,parms.cwc.b,df.in_WClImps,flags.cwcl,df.Ntilde,df.T,S);

    
    
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    % print parameter estimates
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    printresults(Ts,ipath,num2str(guess));



    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    % E-step: update the q's
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    % calculate overall likelihood
    %like.all = prod3(like.msy,like.grl,like.wwc,like.wbc,like.g4s,like.g4h,like.g2y,like.cl,like.c24l,like.cscl,like.clsl,like.cftl,like.cwcl);
    like.all = prod3(like.msy,like.grl,like.wwc,like.wbc,like.g4s,like.mg4s,like.g4h,like.mg4h,like.g2y,like.mg2y,like.cl,like.c24l,like.cscl,like.clsl,like.cftl,like.cwcl);

    assert(all(all(like.all>0)),'like.all likelihood has zero values');
    assert(~(any(any(like.all<0))),'like.all likelihood has negative values');
    
    % get likelihood components according to outcome missingness
    [like.nm,like.maj,like.gpa,like.majgpa] = likecalc(like.all,df,num_GPA_pctiles,S);

    % update the posterior probabilities
    [PType,PType_ms,PTypeTilde,PmajgpaTypel,pi_miss_major,pi_miss_gpa,jointlike,prior] = typeprob_complex(prior,like.nm,like.maj,like.gpa,like.majgpa,df,iteration,num_GPA_pctiles,S);


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
    disp(strcat('aggregate missing major probabilities are: [', sprintf('%5.4f ', pi_miss_major), ']'));
    disp(strcat('aggregate missing GPA probabilities are: [',   sprintf('%5.4f ', pi_miss_gpa  ), ']'));

    likevec = cat(1,likevec,jointlike);
    if length(likevec)>1
        softAssert(likevec(iteration)>=likevec(iteration-1),'Likelihood decreased!')
    end

    iteration = iteration + 1;
    EMcriter  = norm(PmajgpaTypel-oPmajgpaTypel,Inf);
    disp(' ');
    disp(' ');

end



%-------------------------------------------------------------------------------
% save results
%-------------------------------------------------------------------------------
save(strcat(ipath,'everything_all_stage1_interact_type_',num2str(guess)),'-v7.3','like','prior','P*T*','jointlike','likevec','parms','Ts','invIDImp','iteration'); 
disp(['Total time spent: ',num2str(toc(tic_whole)/3600),' hours']);



%-------------------------------------------------------------------------------
% Line plot of the likelihood vector
%-------------------------------------------------------------------------------
plot(1:length(likevec), likevec);

% Add labels and title
xlabel('Index');
ylabel('Value');
title('Line plot of likevec');

% Get the current figures
fig = gcf;

% Save the figure as a pdf file
print(fig, strcat(ipath,'likeplot',guess,'.pdf'), '-dpdf');



diary('off');
