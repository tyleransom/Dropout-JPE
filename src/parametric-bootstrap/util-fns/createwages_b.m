function ewages = createwages_b(data,priorabilstruct,learnparms,AR1parms,A,S);

    year = [];
    v2struct(data);
    v2struct(priorabilstruct);
    v2struct(learnparms);
    v2struct(AR1parms);

    yndg     = setdiff([1:length(bstartg)],[18:33]);
    yndn     = setdiff([1:length(bstartn)],[18:33]);

    ability_range_bc = length(unskilledWageBeta_a(1:end-3))+1
    ability_range_wc = length(  skilledWageBeta_a(1:end-3))+1

    wageparmbc = cat(1,unskilledWageBetaMat(1:ability_range_bc-1,:),ones(1,size(unskilledWageBetaMat,2)),unskilledWageBetaMat(ability_range_bc:end,:));
    wageparmwc = cat(1,  skilledWageBetaMat(1:ability_range_wc-1,:),ones(1,size(  skilledWageBetaMat,2)),  skilledWageBetaMat(ability_range_wc:end,:));

    wageparmbc(:,1)
    wageparmwc(:,1)

    wageparmbc(:,2)
    wageparmwc(:,2)

    wageparmbc(:,3)
    wageparmwc(:,3)

    % stack age
    ClImps   = Yl;
    agelImps = kron(ones(S,1),age);

    %% Get expected log wages along different finite dependence paths
    finalMajorScilImps = kron(ones(S,1),finalMajorSci);

    % make sure that college graduates have the experience profiles of 4+ year college completers
    cum_sch = (1-grad_4yr).*min(cum_2yr+cum_4yr,4) + 4.*grad_4yr;

    E_ln_wage   = zeros(size(finalMajorScilImps,1),20);
    E_ln_waget1 = zeros(size(finalMajorScilImps,1),20);
    E_ln_waget2 = zeros(size(finalMajorScilImps,1),20);
    % non-grads
    for j = setdiff(1:20,[5 10 15 20]) % loop over all current decisions
        baseXbcWage = [ones(N*T,1) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age<=0 age==1 age==2 exper exper_white_collar cum_sch (grad_4yr==1) (finalMajorSci==1 & grad_4yr==1) year<=1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ones(N*T,1)*ismember(j,[3 8 13 16 23]) prior_ability_U];
        baseXbcWage = cat(2,kron(ones(S,1),baseXbcWage),kron(A,ones(N*T,1)));
        baseXbcWage(:,ability_range_bc) = prior_ability_U_vec;

        baseXwcWage = [ones(N*T,1) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age<=0 age==1 age==2 exper exper_white_collar cum_sch (grad_4yr==1) (finalMajorSci==1 & grad_4yr==1) year<=1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ones(N*T,1)*ismember(j,[4 9 14 17 24]) prior_ability_S];
        baseXwcWage = cat(2,kron(ones(S,1),baseXwcWage),kron(A,ones(N*T,1)));
        baseXwcWage(:,ability_range_wc) = prior_ability_S_vec;

        lamtildg0 = 0*ismember(j,[17 19]) + lambdag0start*ismember(j,[2 4 7 9 12 14]);
        lamtildg1 = 1*ismember(j,[17 19]) + lambdag1start*ismember(j,[2 4 7 9 12 14]);
        lamtildn0 = 0*ismember(j,[16 18]) + lambdan0start*ismember(j,[1 3 6 8 11 13]);
        lamtildn1 = 1*ismember(j,[16 18]) + lambdan1start*ismember(j,[1 3 6 8 11 13]);
        for a=0:2; % loop over all possible ages
            if ismember(j,[1 3 6 8 11 13 16 18]) % blue collar alternatives
                Xnew = updater_bc_wage(baseXbcWage,agelImps,finalMajorScilImps,a,j,0); % last argument is graduate dummy
                if a==0 % current wage
                    E_ln_wage(:,j)   = lamtildn0 + Xnew(:,ydn)*wageparmbc(ydn,a+1) + lamtildn1*(Xnew(:,setdiff([1:size(Xnew,2)],ydn))*wageparmbc(setdiff([1:size(Xnew,2)],ydn),a+1));
                elseif a==1 % t+1 wage
                    E_ln_waget1(:,j) = lamtildn0 + Xnew(:,ydn)*wageparmbc(ydn,a+1) + lamtildn1*(Xnew(:,setdiff([1:size(Xnew,2)],ydn))*wageparmbc(setdiff([1:size(Xnew,2)],ydn),a+1));
                elseif a==2 % t+1 wage
                    E_ln_waget2(:,j) = lamtildn0 + Xnew(:,ydn)*wageparmbc(ydn,a+1) + lamtildn1*(Xnew(:,setdiff([1:size(Xnew,2)],ydn))*wageparmbc(setdiff([1:size(Xnew,2)],ydn),a+1));
                end
            elseif ismember(j,[2 4 7 9 12 14 17 19]) % white collar alternatives
                Xnew = updater_wc_wage(baseXwcWage,agelImps,finalMajorScilImps,a,j,0); % last argument is graduate dummy
                if a==0 % current wage
                    E_ln_wage(:,j)   = lamtildg0 + lambdaydgstart*(Xnew(:,ydg)*wageparmbc(ydn,a+1)) + lamtildg1*(Xnew(:,setdiff([1:size(Xnew,2)],ydg))*wageparmwc(setdiff([1:size(Xnew,2)],ydg),a+1));
                elseif a==1 % t+1 wage
                    E_ln_waget1(:,j) = lamtildg0 + lambdaydgstart*(Xnew(:,ydg)*wageparmbc(ydn,a+1)) + lamtildg1*(Xnew(:,setdiff([1:size(Xnew,2)],ydg))*wageparmwc(setdiff([1:size(Xnew,2)],ydg),a+1));
                elseif a==2 % t+2 wage
                    E_ln_waget2(:,j) = lamtildg0 + lambdaydgstart*(Xnew(:,ydg)*wageparmbc(ydn,a+1)) + lamtildg1*(Xnew(:,setdiff([1:size(Xnew,2)],ydg))*wageparmwc(setdiff([1:size(Xnew,2)],ydg),a+1));
                end
            end
        end
    end

    E_ln_wage_g    = zeros(size(finalMajorScilImps,1),20);
    E_ln_wage_g_t1 = zeros(size(finalMajorScilImps,1),20);
    E_ln_wage_g_t2 = zeros(size(finalMajorScilImps,1),20);
    % grads
    for j = 16:20 % loop over all current decisions
        baseXbcWage = [ones(N*T,1) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age<=0 age==1 age==2 exper exper_white_collar cum_sch (grad_4yr==1) (finalMajorSci==1 & grad_4yr==1) year<=1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ones(N*T,1)*ismember(j,[3 8 13 16]) prior_ability_U];
        baseXbcWage = cat(2,kron(ones(S,1),baseXbcWage),kron(A,ones(N*T,1)));
        baseXbcWage(:,ability_range_bc) = prior_ability_U_vec;

        baseXwcWage = [ones(N*T,1) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age<=0 age==1 age==2 exper exper_white_collar cum_sch (grad_4yr==1) (finalMajorSci==1 & grad_4yr==1) year<=1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ones(N*T,1)*ismember(j,[4 9 14 17]) prior_ability_S];
        baseXwcWage = cat(2,kron(ones(S,1),baseXwcWage),kron(A,ones(N*T,1)));
        baseXwcWage(:,ability_range_wc) = prior_ability_S_vec;
        
        lamtildg0 = 0*ismember(j,[17 19]);
        lamtildg1 = 1*ismember(j,[17 19]);
        lamtildn0 = 0*ismember(j,[16 18]);
        lamtildn1 = 1*ismember(j,[16 18]);
        for a=0:2; % loop over all possible ages
            if ismember(j,[16 18]) % blue collar alternatives
                Xnew = updater_bc_wage(baseXbcWage,agelImps,finalMajorScilImps,a,j,1); % last argument is graduate dummy
                if a==0 % current wage
                    E_ln_wage_g(:,j)    = lamtildn0 + Xnew(:,ydn)*wageparmbc(ydn,a+1) + lamtildn1*(Xnew(:,setdiff([1:size(Xnew,2)],ydn))*wageparmbc(setdiff([1:size(Xnew,2)],ydn),a+1));
                elseif a==1 % t+1 wage
                    E_ln_wage_g_t1(:,j) = lamtildn0 + Xnew(:,ydn)*wageparmbc(ydn,a+1) + lamtildn1*(Xnew(:,setdiff([1:size(Xnew,2)],ydn))*wageparmbc(setdiff([1:size(Xnew,2)],ydn),a+1));
                elseif a==2 % t+2 wage
                    E_ln_wage_g_t2(:,j) = lamtildn0 + Xnew(:,ydn)*wageparmbc(ydn,a+1) + lamtildn1*(Xnew(:,setdiff([1:size(Xnew,2)],ydn))*wageparmbc(setdiff([1:size(Xnew,2)],ydn),a+1));
                end
            elseif ismember(j,[17 19]) % white collar alternatives
                Xnew = updater_wc_wage(baseXwcWage,agelImps,finalMajorScilImps,a,j,1); % last argument is graduate dummy
                if a==0 % current wage
                    E_ln_wage_g(:,j)    = lamtildg0 + lambdaydgstart*(Xnew(:,ydg)*wageparmbc(ydn,a+1)) + lamtildg1*(Xnew(:,setdiff([1:size(Xnew,2)],ydg))*wageparmwc(setdiff([1:size(Xnew,2)],ydg),a+1));
                elseif a==1 % t+1 wage
                    E_ln_wage_g_t1(:,j) = lamtildg0 + lambdaydgstart*(Xnew(:,ydg)*wageparmbc(ydn,a+1)) + lamtildg1*(Xnew(:,setdiff([1:size(Xnew,2)],ydg))*wageparmwc(setdiff([1:size(Xnew,2)],ydg),a+1));
                elseif a==2 % t+2 wage
                    E_ln_wage_g_t2(:,j) = lamtildg0 + lambdaydgstart*(Xnew(:,ydg)*wageparmbc(ydn,a+1)) + lamtildg1*(Xnew(:,setdiff([1:size(Xnew,2)],ydg))*wageparmwc(setdiff([1:size(Xnew,2)],ydg),a+1));
                end
            end
        end
    end
    size(baseXbcWage)

    ewages = v2struct(E_ln_wage,E_ln_waget1,E_ln_waget2,E_ln_wage_g,E_ln_wage_g_t1,E_ln_wage_g_t2);
end
