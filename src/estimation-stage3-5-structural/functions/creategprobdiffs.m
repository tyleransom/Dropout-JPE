function gprobdiffs = creategprobdiffs(data,priorabilstruct,gradparms,num_GPA_pctiles,S);

    v2struct(data);
    v2struct(priorabilstruct);

    % set up unobserved types
    A     = [1 1 1; 1 1 0; 1 0 1; 1 0 0; 0 1 1; 0 1 0; 0 0 1; 0 0 0];
    stype = kron(A,ones(Ntilde*T,1));
    
    scienceMajor = rand(N*T,1);
    asifhum.scienceMajor = rand(N*T,1);
    asifsci.scienceMajor = rand(N*T,1);

    % set up data matrix
    Xlogit = [ones(N*T,1) black hispanic HS_grades Parent_college birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 famInc cum_2yr==0 cum_2yr>=2 cum_4yr==2 cum_4yr==3 cum_4yr==4 cum_4yr==5 cum_4yr>=6 (cum_4yr==2).*(cum_2yr==0) (cum_4yr==4).*(cum_2yr==0) (cum_4yr==5).*(cum_2yr==0) (cum_4yr>=6).*(cum_2yr==0) scienceMajor prior_ability_4S prior_ability_4NS workPTschool workFTschool];
    asifhum.Xlogit = [ones(N*T,1) black hispanic HS_grades Parent_college birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 famInc cum_2yr==0 cum_2yr>=2 cum_4yr==2 cum_4yr==3 cum_4yr==4 cum_4yr==5 cum_4yr>=6 (cum_4yr==2).*(cum_2yr==0) (cum_4yr==4).*(cum_2yr==0) (cum_4yr==5).*(cum_2yr==0) (cum_4yr>=6).*(cum_2yr==0) asifhum.scienceMajor prior_ability_4S prior_ability_4NS workPTschool workFTschool];
    asifsci.Xlogit = [ones(N*T,1) black hispanic HS_grades Parent_college birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 famInc cum_2yr==0 cum_2yr>=2 cum_4yr==2 cum_4yr==3 cum_4yr==4 cum_4yr==5 cum_4yr>=6 (cum_4yr==2).*(cum_2yr==0) (cum_4yr==4).*(cum_2yr==0) (cum_4yr==5).*(cum_2yr==0) (cum_4yr>=6).*(cum_2yr==0) asifsci.scienceMajor prior_ability_4S prior_ability_4NS workPTschool workFTschool];

    [~,Xlogit] = makegridchoice_con(Xlogit,asifsci.Xlogit,asifhum.Xlogit,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sc2]    = makegrid_con(cum_2yr,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sc4]    = makegrid_con(cum_4yr,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    
    % create flag for estimation subset
    subset = logical((sc2+sc4)>=2);

    % create alternative-specific matrices
    Z = zeros(Ntilde*T*S,29,19);
    for j=6:15
        Z(:,:,j) = cat(2,Xlogit(:,1:21),ones(Ntilde*T*S,1)*(j>=6 & j<=10),prior_ability_4S_vec.*(j>=6 & j<=10),prior_ability_4NS_vec.*(j>=11 & j<=15),ones(Ntilde*T*S,1)*ismember(j,[8:9 13:14]),ones(Ntilde*T*S,1)*ismember(j,[6:7 11:12]),stype);
    end

    gprobdiffs = zeros(Ntilde*T*S,19);
    gprobdiffs(subset,6 ) = glmval(gradparms.P_grad_betas4,squeeze(Z(subset,:,6 )),'logit','constant','off'); 
    gprobdiffs(subset,7 ) = glmval(gradparms.P_grad_betas4,squeeze(Z(subset,:,7 )),'logit','constant','off');  
    gprobdiffs(subset,8 ) = glmval(gradparms.P_grad_betas4,squeeze(Z(subset,:,8 )),'logit','constant','off');  
    gprobdiffs(subset,9 ) = glmval(gradparms.P_grad_betas4,squeeze(Z(subset,:,9 )),'logit','constant','off');  
    gprobdiffs(subset,10) = glmval(gradparms.P_grad_betas4,squeeze(Z(subset,:,10)),'logit','constant','off');  
    gprobdiffs(subset,11) = glmval(gradparms.P_grad_betas4,squeeze(Z(subset,:,11)),'logit','constant','off');  
    gprobdiffs(subset,12) = glmval(gradparms.P_grad_betas4,squeeze(Z(subset,:,12)),'logit','constant','off');  
    gprobdiffs(subset,13) = glmval(gradparms.P_grad_betas4,squeeze(Z(subset,:,13)),'logit','constant','off');  
    gprobdiffs(subset,14) = glmval(gradparms.P_grad_betas4,squeeze(Z(subset,:,14)),'logit','constant','off');  
    gprobdiffs(subset,15) = glmval(gradparms.P_grad_betas4,squeeze(Z(subset,:,15)),'logit','constant','off');  

end
