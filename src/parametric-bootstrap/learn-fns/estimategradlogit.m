function parms = estimategradlogit(ecdata,priorabilstruct,q,A,S);

    v2struct(ecdata);
    v2struct(priorabilstruct);

    %------------------------------------------
    % Logit for college graduates
    %------------------------------------------

    %% Create some useful variables
    workPTschool = ismember(Y,[8 9 13 14]); 
    workFTschool = ismember(Y,[6 7 11 12]);
    scienceMajor = ismember(Y,6:10);


    %% Set up data matrix
    Xlogit = [ones(N*T,1) black hispanic HS_grades Parent_college birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 famInc cum_2yr==0 cum_2yr>=2 cum_4yr==2 cum_4yr==3 cum_4yr==4 cum_4yr==5 cum_4yr>=6 (cum_4yr==2).*(cum_2yr==0) (cum_4yr==4).*(cum_2yr==0) (cum_4yr==5).*(cum_2yr==0) (cum_4yr>=6).*(cum_2yr==0) scienceMajor prior_ability_4S prior_ability_4NS workPTschool workFTschool];
    Xlogit = cat(2,kron(ones(S,1),Xlogit),kron(A,ones(N*T,1)));
    sc2    = cum_2yrl;
    sc4    = cum_4yrl;

    % add prior abilities to set of covariates
    ability_range_gradlogit = 23:24;
    Xlogit(:,ability_range_gradlogit) = [prior_ability_4S_vec.*(Yl>=6 & Yl<=10) prior_ability_4NS_vec.*(Yl>=11 & Yl<=15)];
    
    % create flag for estimation subset
    subset = (Yl>=6) & (Yl<=15) & logical((sc2+sc4)>=2);

    % Estimate
    [P_grad_betas4,~,stats] = glmfit(Xlogit(subset,:), grad_4yr_next_yrl(subset),'binomial','constant','off','weights',q(subset));

    % Export parameter estimates, subset flag, and covariates for use in likelihood calculation
    parms  = v2struct(P_grad_betas4,Xlogit,subset);
end  
