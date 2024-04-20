function gprobdiffs = creategprobdiffs_b(data,priorabilstruct,gradparms,S);

    v2struct(data);
    v2struct(priorabilstruct);

    % set up unobserved types
    A     = [1 1 1; 1 1 0; 1 0 1; 1 0 0; 0 1 1; 0 1 0; 0 0 1; 0 0 0];
    stype = kron(A,ones(N*T,1));
    
    scienceMajor = rand(N*T,1);

    % set up data matrix
    Xlogit = [ones(N*T,1) black hispanic HS_grades Parent_college birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 famInc cum_2yr==0 cum_2yr>=2 cum_4yr==2 cum_4yr==3 cum_4yr==4 cum_4yr==5 cum_4yr>=6 (cum_4yr==2).*(cum_2yr==0) (cum_4yr==4).*(cum_2yr==0) (cum_4yr==5).*(cum_2yr==0) (cum_4yr>=6).*(cum_2yr==0)];

    Xlogit = kron(ones(S,1),Xlogit);
    sc2    = kron(ones(S,1),cum_2yr);
    sc4    = kron(ones(S,1),cum_4yr);
    
    % create flag for estimation subset
    subset = logical((sc2+sc4)>=2);

    % create alternative-specific matrices
    Z = zeros(N*T*S,29,19);
    for j=6:15
        Z(:,:,j) = cat(2,Xlogit,ones(N*T*S,1)*(j>=6 & j<=10),prior_ability_4S_vec.*(j>=6 & j<=10),prior_ability_4NS_vec.*(j>=11 & j<=15),ones(N*T*S,1)*ismember(j,[8:9 13:14]),ones(N*T*S,1)*ismember(j,[6:7 11:12]),stype);
    end

    gprobdiffs = zeros(N*T*S,19);
    for j=6:15
        gprobdiffs(subset,j) = glmval(gradparms.P_grad_betas4,squeeze(Z(subset,:,j)),'logit','constant','off'); 
    end

end
