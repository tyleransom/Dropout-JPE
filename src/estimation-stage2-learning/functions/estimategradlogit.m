function parms = estimategradlogit(ecdata,priorabilstruct,PmajgpaType,num_GPA_pctiles,S,ipath);

    v2struct(ecdata);
    v2struct(priorabilstruct);

    %------------------------------------------
    % Logit for college graduates
    %------------------------------------------

    %% Create some useful variables
    workPTschool = ismember(Clp,[8 9 13 14]); 
    workFTschool = ismember(Clp,[6 7 11 12]);

    asifhum.scienceMajor = asifhum.choice20>=6 & asifhum.choice20<=10;
    asifsci.scienceMajor = asifsci.choice20>=6 & asifsci.choice20<=10;


    %% Set up data matrix
    Xlogit = [ones(N*T,1) black hispanic HS_grades Parent_college birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 famInc cum_2yr==0 cum_2yr>=2 cum_4yr==2 cum_4yr==3 cum_4yr==4 cum_4yr==5 cum_4yr>=6 (cum_4yr==2).*(cum_2yr==0) (cum_4yr==4).*(cum_2yr==0) (cum_4yr==5).*(cum_2yr==0) (cum_4yr>=6).*(cum_2yr==0) scienceMajor prior_ability_4S prior_ability_4NS workPTschool workFTschool];
    asifhum.Xlogit = [ones(N*T,1) black hispanic HS_grades Parent_college birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 famInc cum_2yr==0 cum_2yr>=2 cum_4yr==2 cum_4yr==3 cum_4yr==4 cum_4yr==5 cum_4yr>=6 (cum_4yr==2).*(cum_2yr==0) (cum_4yr==4).*(cum_2yr==0) (cum_4yr==5).*(cum_2yr==0) (cum_4yr>=6).*(cum_2yr==0) asifhum.scienceMajor prior_ability_4S prior_ability_4NS workPTschool workFTschool];
    asifsci.Xlogit = [ones(N*T,1) black hispanic HS_grades Parent_college birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 famInc cum_2yr==0 cum_2yr>=2 cum_4yr==2 cum_4yr==3 cum_4yr==4 cum_4yr==5 cum_4yr>=6 (cum_4yr==2).*(cum_2yr==0) (cum_4yr==4).*(cum_2yr==0) (cum_4yr==5).*(cum_2yr==0) (cum_4yr>=6).*(cum_2yr==0) asifsci.scienceMajor prior_ability_4S prior_ability_4NS workPTschool workFTschool];

    [~,Xlogit] = makegridchoice_con(Xlogit,asifsci.Xlogit,asifhum.Xlogit,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sc2]    = makegrid_con(cum_2yr,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sc4]    = makegrid_con(cum_4yr,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);

    % add prior abilities to set of covariates
    ability_range_gradlogit = 23:24;
    Xlogit(:,ability_range_gradlogit) = [prior_ability_4S_vec.*(ClImps>=6 & ClImps<=10) prior_ability_4NS_vec.*(ClImps>=11 & ClImps<=15)];
    
    % create flag for estimation subset
    subset = (ClImps>=6) & (ClImps<=15) & logical((sc2+sc4)>=2);

    % Estimate
    [P_grad_betas4,~,stats] = glmfit(Xlogit(subset,:), grad_4yr_next_yrlImps(subset),'binomial','constant','off','weights',PmajgpaType(subset));

    % Export parameter estimates, subset flag, and covariates for use in likelihood calculation
    parms  = v2struct(P_grad_betas4,Xlogit,subset);
end  
