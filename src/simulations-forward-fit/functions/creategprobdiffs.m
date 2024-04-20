function gprobdiffs = creategprobdiffs(currStates,priorabilstruct,beta);

    v2struct(currStates);
    v2struct(priorabilstruct);

    N  = length(cum_2yr);
    yc = cum_2yr+cum_4yr;

    % set up unobserved types
    stype = [ismember(utype,1:4) ismember(utype,[1:2 5:6]) ismember(utype,[1 3 5 7])];

    % covariates that are not alternative-specific
    X = [ones(size(black)) black hispanic HS_grades Parent_college born1980 born1981 born1982 born1983 famInc cum_2yr==0 cum_2yr>=2 cum_4yr==2 cum_4yr==3 cum_4yr==4 cum_4yr==5 cum_4yr>=6 (cum_4yr==2).*(cum_2yr==0) (cum_4yr==4).*(cum_2yr==0) (cum_4yr==5).*(cum_2yr==0) (cum_4yr>=6).*(cum_2yr==0    )];
    
    % create flag for estimation subset
    subset = logical(yc>=2);

    % create alternative-specific matrices
    Z = zeros(N,29,19);
    for j=6:15
        Z(:,:,j) = cat(2,X,ones(N,1)*(j>=6 & j<=10),priorabilstruct.prior_ability_4S.*(j>=6 & j<=10),priorabilstruct.prior_ability_4NS.*(j>=11 & j<=15),ones(N,1)*ismember(j,[8:9 13:14]),ones(N,1)*ismember(j,[6:7 11:12]),stype);
    end

    % get predicted probabilities for each alternative
    gprobdiffs = zeros(N,19);
    for j=6:15
        gprobdiffs(subset,j) = glmval(beta,squeeze(Z(subset,:,j)),'logit','constant','off');  
    end 

end
