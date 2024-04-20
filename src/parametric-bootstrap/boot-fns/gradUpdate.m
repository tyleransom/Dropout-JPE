function [gradt1,P] = gradUpdate(gradt,Y,currStates,priorabilstruct,beta);
    v2struct(currStates);

    N  = length(cum_2yr);
    yc = cum_2yr+cum_4yr;

    X = [ones(size(black)) black hispanic HS_grades Parent_college born1980 born1981 born1982 born1983 famInc cum_2yr==0 cum_2yr>=2 cum_4yr==2 cum_4yr==3 cum_4yr==4 cum_4yr==5 cum_4yr>=6 (cum_4yr==2).*(cum_2yr==0) (cum_4yr==4).*(cum_2yr==0) (cum_4yr==5).*(cum_2yr==0) (cum_4yr>=6).*(cum_2yr==0    ) ismember(Y,6:10) priorabilstruct.prior_ability_4S.*ismember(Y,6:10) priorabilstruct.prior_ability_4NS.*ismember(Y,11:15) ismember(Y,[8 9 13 14]) ismember(Y,[6 7 11 12]) ismember(utype,1:4) ismember(utype,[1:2 5:6]) ismember(utype,[1 3 5 7])];

    P                             = exp(X*beta)./(1+exp(X*beta));
    P(yc<2 | ~ismember(Y,[6:15])) = 0;

    gradt1           = rand(N,1)<P;
    gradt1(gradt==1) = 1;

end

