function econsumps = createconsumpMCint_b(data,wages,priorabilstruct,learnparms,r,Clb,CRRA,D,AR1parms,S)

    year = [];
    v2struct(data);
    v2struct(wages);
    v2struct(learnparms);
    v2struct(priorabilstruct);
    v2struct(AR1parms);
    flg = Yl>0;

    % lambdas
    lmd1 = ones(1,20);
    lmd1([2 4 7 9 12 14]) = lambdag1start;
    lmd1([1 3 6 8 11 13]) = lambdan1start;
    % wages in levels
    jhrs   = [repmat([40*52 40*52 20*52 20*52 0],1,3) 20*52 20*52 40*52 40*52 0];
    jhrs_g = [zeros(1,15) 20*52 20*52 40*52 40*52 0];
    wrkr   = ones(size(E_ln_wage  ,1),1)*jhrs;
    wrkr_g = ones(size(E_ln_wage_g,1),1)*jhrs_g;
    E_wage      = wrkr.*exp(E_ln_wage);
    E_wage_t1   = wrkr.*exp(E_ln_waget1);
    E_wage_t2   = wrkr.*exp(E_ln_waget2);
    E_wage_g    = wrkr_g.*exp(E_ln_wage_g);
    E_wage_g_t1 = wrkr_g.*exp(E_ln_wage_g_t1);
    E_wage_g_t2 = wrkr_g.*exp(E_ln_wage_g_t2);

    %% Get consumption components in conformable size (i.e. replicate to account for missing majors and unobs types)
    % PT (2- and 4-year), Grants (2- and 4-year), Loans (2- and 4-year), Tuition (2- and 4-year)
    schlCsts = [idxParTrans4 idxParTrans2 grant4idx loan4idx tui2imp grant2idx loan2idx tui4imp];
    sig4pt   = kron(ones(S,1),ParTrans4RMSE);
    sig2pt   = kron(ones(S,1),ParTrans2RMSE);
    sigg4    = kron(ones(S,1),grant4RMSE);
    sigg2    = kron(ones(S,1),grant2RMSE);
    pt4idx   = kron(ones(S,1),idxParTrans4);
    pt2idx   = kron(ones(S,1),idxParTrans2);
    gr4idx   = kron(ones(S,1),grant4idx);
    gr2idx   = kron(ones(S,1),grant2idx);
    lo4idx   = kron(ones(S,1),E_loan4_18.*(1+r).^(yrsSinceHS));
    lo2idx   = kron(ones(S,1),E_loan2_18.*(1+r).^(yrsSinceHS));
    prpt4    = kron(ones(S,1),prParTrans4);
    prpt2    = kron(ones(S,1),prParTrans2);
    prg4     = kron(ones(S,1),grant4pr);
    prg2     = kron(ones(S,1),grant2pr);
    tu4      = kron(ones(S,1),tui4imp);
    tu2      = kron(ones(S,1),tui2imp);

    % update states for t+1 (on Home - j - Home finite dependence path)
    pt4idxt1   = pt4idx - 0.095542;                   % 4yr PT age coefficient = -0.095542  (don't need to adjust cum_school because it only enters the probability, not the level)
    pt2idxt1   = pt2idx - 0.0592096;                  % 2yr PT age coefficient = -0.0592096 
    prpt4t1idx = log(prpt4./(1-prpt4)) - 0.330024;    % 4yr PT>0 logit age coefficient = -0.330024  
    prpt2t1idx = log(prpt2./(1-prpt2)) - 0.3041113;   % 2yr PT>0 logit age coefficient = -0.3041113  
    prpt4t1    = exp(prpt4t1idx)./(1+exp(prpt4t1idx));% logit(log odds) = new probability
    prpt2t1    = exp(prpt2t1idx)./(1+exp(prpt2t1idx));% logit(log odds) = new probability
    lo4idxt1   = lo4idx.*(1+r);
    lo2idxt1   = lo2idx.*(1+r);

    % update states for t+2 (on Home - j - Home finite dependence path)
    pt4idxt2   = pt4idx - 2*0.095542;                 % 4yr PT age coefficient = -0.095542;  multiply by 2 since it's two periods ahead
    pt2idxt2   = pt2idx - 2*0.0592096;                % 2yr PT age coefficient = -0.0592096; multiply by 2 since it's two periods ahead
    prpt4t2idx = log(prpt4./(1-prpt4)) - 2*0.330024;  % 4yr PT>0 logit age coefficient = -0.330024 ; multiply by 2 since it's two periods ahead 
    prpt2t2idx = log(prpt2./(1-prpt2)) - 2*0.3041113; % 2yr PT>0 logit age coefficient = -0.3041113; multiply by 2 since it's two periods ahead 
    prpt4t2    = exp(prpt4t2idx)./(1+exp(prpt4t2idx));% logit(log odds) = new probability
    prpt2t2    = exp(prpt2t2idx)./(1+exp(prpt2t2idx));% logit(log odds) = new probability
    lo4idxt2   = lo4idx.*(1+r).^2;
    lo2idxt2   = lo2idx.*(1+r).^2;

    consump      = nan(size(pt4idx,1),20);
    consump_g    = nan(size(pt4idx,1),20);
    consumpPI    = nan(size(pt4idx,1),20);
    consump_gPI  = nan(size(pt4idx,1),20);
    consump_t1   = nan(size(pt4idx,1),20);
    consump_g_t1 = nan(size(pt4idx,1),20);
    consump_t2   = nan(size(pt4idx,1),20);
    consump_g_t2 = nan(size(pt4idx,1),20);

    consumpNaive      = nan(size(pt4idx,1),20);
    consumpNaive_g    = nan(size(pt4idx,1),20);
    consumpNaive_t1   = nan(size(pt4idx,1),20);
    consumpNaive_g_t1 = nan(size(pt4idx,1),20);
    consumpNaive_t2   = nan(size(pt4idx,1),20);
    consumpNaive_g_t2 = nan(size(pt4idx,1),20);

    % non-grads
    for j = 1:20; % loop over all current decisions
        %for a=0:1; % loop over all possible ages
            % school only
            if j==5
                consump(flg,5)         = e_sch_c(Clb,CRRA,pt2idx(flg),gr2idx(flg),lo2idx(flg),tu2(flg),sig2pt(flg),sigg2(flg),prpt2(flg),prg2(flg),D);
                consumpPI(flg,5)       = consump(flg,5);
                consumpNaive(flg,5)    = max(exp(pt2idx(flg))+gr2idx(flg)+lo2idx(flg)-tu2(flg),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t1(flg,5) = max(exp(pt2idxt1(flg))+gr2idx(flg)+lo2idxt1(flg)-tu2(flg),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t2(flg,5) = max(exp(pt2idxt2(flg))+gr2idx(flg)+lo2idxt2(flg)-tu2(flg),Clb).^(1-CRRA)./(1-CRRA);
                consump(flg,[10 15])   = repmat(e_sch_c(Clb,CRRA,pt4idx(flg),gr4idx(flg),lo4idx(flg),tu4(flg),sig4pt(flg),sigg4(flg),prpt4(flg),prg4(flg),D),1,2); % consumption doesn't depend on major
                consumpPI(flg,[10 15])       = consump(flg,[10 15]); % consumption doesn't depend on major
                consumpNaive(flg,[10 15])    = repmat(max(exp(pt4idx(flg))+gr4idx(flg)+lo4idx(flg)-tu4(flg),Clb).^(1-CRRA)./(1-CRRA),1,2);
                consumpNaive_t1(flg,[10 15]) = repmat(max(exp(pt4idxt1(flg))+gr4idx(flg)+lo4idxt1(flg)-tu4(flg),Clb).^(1-CRRA)./(1-CRRA),1,2);
                consumpNaive_t2(flg,[10 15]) = repmat(max(exp(pt4idxt2(flg))+gr4idx(flg)+lo4idxt2(flg)-tu4(flg),Clb).^(1-CRRA)./(1-CRRA),1,2);
                consump_t1(flg,5)            = e_sch_c(Clb,CRRA,pt2idxt1(flg),gr2idx(flg),lo2idxt1(flg),tu2(flg),sig2pt(flg),sigg2(flg),prpt2t1(flg),prg2(flg),D);
                consump_t1(flg,[10 15])      = repmat(e_sch_c(Clb,CRRA,pt4idxt1(flg),gr4idx(flg),lo4idxt1(flg),tu4(flg),sig4pt(flg),sigg4(flg),prpt4t1(flg),prg4(flg),D),1,2); % consumption doesn't depend on major
                consump_t2(flg,5)            = e_sch_c(Clb,CRRA,pt2idxt2(flg),gr2idx(flg),lo2idxt2(flg),tu2(flg),sig2pt(flg),sigg2(flg),prpt2t2(flg),prg2(flg),D);
                consump_t2(flg,[10 15])      = repmat(e_sch_c(Clb,CRRA,pt4idxt2(flg),gr4idx(flg),lo4idxt2(flg),tu4(flg),sig4pt(flg),sigg4(flg),prpt4t2(flg),prg4(flg),D),1,2); % consumption doesn't depend on major
            % 2yr and work (blue collar)
            elseif ismember(j,[1 3])
                consump(flg,j)         = e_w_sch_c(Clb,CRRA,E_ln_wage(flg,j),jhrs(j),pt2idx(flg),gr2idx(flg),lo2idx(flg),tu2(flg),sqrt(lmd1(j)^2.*vabilpriormat(flg,2,2)+sig(4)),sig2pt(flg),sigg2(flg),prpt2(flg),prg2(flg),D);
                consumpPI(flg,j)       = e_w_sch_c(Clb,CRRA,E_ln_wage(flg,j),jhrs(j),pt2idx(flg),gr2idx(flg),lo2idx(flg),tu2(flg),sqrt(sig(4)),sig2pt(flg),sigg2(flg),prpt2(flg),prg2(flg),D);
                consumpNaive(flg,j)    = max(E_wage(flg,j)+exp(pt2idx(flg))+gr2idx(flg)+lo2idx(flg)-tu2(flg),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t1(flg,j) = max(E_wage_t1(flg,j)+exp(pt2idxt1(flg))+gr2idx(flg)+lo2idxt1(flg)-tu2(flg),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t2(flg,j) = max(E_wage_t2(flg,j)+exp(pt2idxt2(flg))+gr2idx(flg)+lo2idxt2(flg)-tu2(flg),Clb).^(1-CRRA)./(1-CRRA);
                consump_t1(flg,j)      = e_w_sch_c(Clb,CRRA,E_ln_waget1(flg,j),jhrs(j),pt2idxt1(flg),gr2idx(flg),lo2idxt1(flg),tu2(flg),sqrt(lmd1(j)^2.*vabilpriormat(flg,2,2)+sig(4)+unsk_wage_sig^2),sig2pt(flg),sigg2(flg),prpt2t1(flg),prg2(flg),D);
                consump_t2(flg,j)      = e_w_sch_c(Clb,CRRA,E_ln_waget2(flg,j),jhrs(j),pt2idxt2(flg),gr2idx(flg),lo2idxt2(flg),tu2(flg),sqrt(lmd1(j)^2.*vabilpriormat(flg,2,2)+sig(4)+(1+rhoU^2)*unsk_wage_sig^2),sig2pt(flg),sigg2(flg),prpt2t2(flg),prg2(flg),D);
            % 2yr and work (white collar)
            elseif ismember(j,[2 4])
                consump(flg,j)         = e_w_sch_c(Clb,CRRA,E_ln_wage(flg,j),jhrs(j),pt2idx(flg),gr2idx(flg),lo2idx(flg),tu2(flg),sqrt(lmd1(j)^2.*vabilpriormat(flg,1,1)+sig(2)),sig2pt(flg),sigg2(flg),prpt2(flg),prg2(flg),D);
                consumpPI(flg,j)       = e_w_sch_c(Clb,CRRA,E_ln_wage(flg,j),jhrs(j),pt2idx(flg),gr2idx(flg),lo2idx(flg),tu2(flg),sqrt(sig(2)),sig2pt(flg),sigg2(flg),prpt2(flg),prg2(flg),D);
                consumpNaive(flg,j)    = max(E_wage(flg,j)+exp(pt2idx(flg))+gr2idx(flg)+lo2idx(flg)-tu2(flg),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t1(flg,j) = max(E_wage_t1(flg,j)+exp(pt2idxt1(flg))+gr2idx(flg)+lo2idxt1(flg)-tu2(flg),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t2(flg,j) = max(E_wage_t2(flg,j)+exp(pt2idxt2(flg))+gr2idx(flg)+lo2idxt2(flg)-tu2(flg),Clb).^(1-CRRA)./(1-CRRA);
                consump_t1(flg,j)      = e_w_sch_c(Clb,CRRA,E_ln_waget1(flg,j),jhrs(j),pt2idxt1(flg),gr2idx(flg),lo2idxt1(flg),tu2(flg),sqrt(lmd1(j)^2.*vabilpriormat(flg,1,1)+sig(2)+lambdaydgstart^2*unsk_wage_sig^2),sig2pt(flg),sigg2(flg),prpt2t1(flg),prg2(flg),D);
                consump_t2(flg,j)      = e_w_sch_c(Clb,CRRA,E_ln_waget2(flg,j),jhrs(j),pt2idxt2(flg),gr2idx(flg),lo2idxt2(flg),tu2(flg),sqrt(lmd1(j)^2.*vabilpriormat(flg,1,1)+sig(2)+(1+rhoU^2)*lambdaydgstart^2*unsk_wage_sig^2),sig2pt(flg),sigg2(flg),prpt2t2(flg),prg2(flg),D);
            % 4yr and work (blue collar)
            elseif ismember(j,[6 8 11 13])
                consump(flg,j)         = e_w_sch_c(Clb,CRRA,E_ln_wage(flg,j),jhrs(j),pt4idx(flg),gr4idx(flg),lo4idx(flg),tu4(flg),sqrt(lmd1(j)^2.*vabilpriormat(flg,2,2)+sig(4)),sig4pt(flg),sigg4(flg),prpt4(flg),prg4(flg),D);
                consumpPI(flg,j)       = e_w_sch_c(Clb,CRRA,E_ln_wage(flg,j),jhrs(j),pt4idx(flg),gr4idx(flg),lo4idx(flg),tu4(flg),sqrt(sig(4)),sig4pt(flg),sigg4(flg),prpt4(flg),prg4(flg),D);
                consumpNaive(flg,j)    = max(E_wage(flg,j)+exp(pt4idx(flg))+gr4idx(flg)+lo4idx(flg)-tu4(flg),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t1(flg,j) = max(E_wage_t1(flg,j)+exp(pt4idxt1(flg))+gr4idx(flg)+lo4idxt1(flg)-tu4(flg),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t2(flg,j) = max(E_wage_t2(flg,j)+exp(pt4idxt2(flg))+gr4idx(flg)+lo4idxt2(flg)-tu4(flg),Clb).^(1-CRRA)./(1-CRRA);
                consump_t1(flg,j)      = e_w_sch_c(Clb,CRRA,E_ln_waget1(flg,j),jhrs(j),pt4idxt1(flg),gr4idx(flg),lo4idxt1(flg),tu4(flg),sqrt(lmd1(j)^2.*vabilpriormat(flg,2,2)+sig(4)+unsk_wage_sig^2),sig4pt(flg),sigg4(flg),prpt4t1(flg),prg4(flg),D);
                consump_t2(flg,j)      = e_w_sch_c(Clb,CRRA,E_ln_waget2(flg,j),jhrs(j),pt4idxt2(flg),gr4idx(flg),lo4idxt2(flg),tu4(flg),sqrt(lmd1(j)^2.*vabilpriormat(flg,2,2)+sig(4)+(1+rhoU^2)*unsk_wage_sig^2),sig4pt(flg),sigg4(flg),prpt4t2(flg),prg4(flg),D);
            % 4yr and work (white collar)
            elseif ismember(j,[7 9 12 14])
                consump(flg,j)         = e_w_sch_c(Clb,CRRA,E_ln_wage(flg,j),jhrs(j),pt4idx(flg),gr4idx(flg),lo4idx(flg),tu4(flg),sqrt(lmd1(j)^2.*vabilpriormat(flg,1,1)+sig(2)),sig4pt(flg),sigg4(flg),prpt4(flg),prg4(flg),D);
                consumpPI(flg,j)       = e_w_sch_c(Clb,CRRA,E_ln_wage(flg,j),jhrs(j),pt4idx(flg),gr4idx(flg),lo4idx(flg),tu4(flg),sqrt(sig(2)),sig4pt(flg),sigg4(flg),prpt4(flg),prg4(flg),D);
                consumpNaive(flg,j)    = max(E_wage(flg,j)+exp(pt4idx(flg))+gr4idx(flg)+lo4idx(flg)-tu4(flg),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t1(flg,j) = max(E_wage_t1(flg,j)+exp(pt4idxt1(flg))+gr4idx(flg)+lo4idxt1(flg)-tu4(flg),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t2(flg,j) = max(E_wage_t2(flg,j)+exp(pt4idxt2(flg))+gr4idx(flg)+lo4idxt2(flg)-tu4(flg),Clb).^(1-CRRA)./(1-CRRA);
                consump_t1(flg,j)      = e_w_sch_c(Clb,CRRA,E_ln_waget1(flg,j),jhrs(j),pt4idxt1(flg),gr4idx(flg),lo4idxt1(flg),tu4(flg),sqrt(lmd1(j)^2.*vabilpriormat(flg,1,1)+sig(2)+lambdaydgstart^2*unsk_wage_sig^2),sig4pt(flg),sigg4(flg),prpt4t1(flg),prg4(flg),D);
                consump_t2(flg,j)      = e_w_sch_c(Clb,CRRA,E_ln_waget2(flg,j),jhrs(j),pt4idxt2(flg),gr4idx(flg),lo4idxt2(flg),tu4(flg),sqrt(lmd1(j)^2.*vabilpriormat(flg,1,1)+sig(2)+(1+rhoU^2)*lambdaydgstart^2*unsk_wage_sig^2),sig4pt(flg),sigg4(flg),prpt4t2(flg),prg4(flg),D);
            % work only
            elseif ismember(j,[16 18])
                consump(flg,j)         = e_work_c(E_ln_wage(flg,j),jhrs(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(flg,2,2),sig(3));
                consumpPI(flg,j)       = e_work_c(E_ln_wage(flg,j),jhrs(j),Clb,CRRA,0,sig(3));
                consumpNaive(flg,j)    = max(E_wage(flg,j),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t1(flg,j) = max(E_wage_t1(flg,j),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t2(flg,j) = max(E_wage_t2(flg,j),Clb).^(1-CRRA)./(1-CRRA);
                consump_t1(flg,j)      = e_work_c(E_ln_waget1(flg,j),jhrs(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(flg,2,2),sig(3)+unsk_wage_sig^2);
                consump_t2(flg,j)      = e_work_c(E_ln_waget2(flg,j),jhrs(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(flg,2,2),sig(3)+(1+rhoU^2)*unsk_wage_sig^2);
            elseif ismember(j,[17 19])
                consump(flg,j)         = e_work_c(E_ln_wage(flg,j),jhrs(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(flg,1,1),sig(1));
                consumpPI(flg,j)       = e_work_c(E_ln_wage(flg,j),jhrs(j),Clb,CRRA,0,sig(1));
                consumpNaive(flg,j)    = max(E_wage(flg,j),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t1(flg,j) = max(E_wage_t1(flg,j),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive_t2(flg,j) = max(E_wage_t2(flg,j),Clb).^(1-CRRA)./(1-CRRA);
                consump_t1(flg,j)      = e_work_c(E_ln_waget1(flg,j),jhrs(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(flg,1,1),sig(1)+lambdaydgstart^2*unsk_wage_sig^2);
                consump_t2(flg,j)      = e_work_c(E_ln_waget2(flg,j),jhrs(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(flg,1,1),sig(1)+(1+rhoU^2)*lambdaydgstart^2*unsk_wage_sig^2);
            elseif j==20
            consump(flg,j)         = Clb.^(1-CRRA)./(1-CRRA);
            consumpPI(flg,j)       = Clb.^(1-CRRA)./(1-CRRA);
            consumpNaive(flg,j)    = Clb.^(1-CRRA)./(1-CRRA);
            consumpNaive_t1(flg,j) = Clb.^(1-CRRA)./(1-CRRA);
            consumpNaive_t2(flg,j) = Clb.^(1-CRRA)./(1-CRRA);
            consump_t1(flg,j)      = Clb.^(1-CRRA)./(1-CRRA);
            consump_t2(flg,j)      = Clb.^(1-CRRA)./(1-CRRA);
            end
        %end
    end

    % grads
    for j = 16:20 % loop over all current decisions
        if ismember(j,[16 18])
            consump_g(flg,j)         = e_work_c(E_ln_wage_g(flg,j),jhrs_g(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(flg,2,2),sig(3));
            consump_gPI(flg,j)       = e_work_c(E_ln_wage_g(flg,j),jhrs_g(j),Clb,CRRA,0,sig(3));
            consumpNaive_g(flg,j)    = max(E_wage_g(flg,j),Clb).^(1-CRRA)./(1-CRRA);
            consumpNaive_g_t1(flg,j) = max(E_wage_g_t1(flg,j),Clb).^(1-CRRA)./(1-CRRA);
            consumpNaive_g_t2(flg,j) = max(E_wage_g_t2(flg,j),Clb).^(1-CRRA)./(1-CRRA);
            consump_g_t1(flg,j)      = e_work_c(E_ln_wage_g_t1(flg,j),jhrs_g(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(flg,2,2),sig(3)+unsk_wage_sig^2);
            consump_g_t2(flg,j)      = e_work_c(E_ln_wage_g_t2(flg,j),jhrs_g(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(flg,2,2),sig(3)+(1+rhoU^2)*unsk_wage_sig^2);
        elseif ismember(j,[17 19])
            consump_g(flg,j)         = e_work_c(E_ln_wage_g(flg,j),jhrs_g(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(flg,1,1),sig(1));
            consump_gPI(flg,j)       = e_work_c(E_ln_wage_g(flg,j),jhrs_g(j),Clb,CRRA,0,sig(1));
            consumpNaive_g(flg,j)    = max(E_wage_g(flg,j),Clb).^(1-CRRA)./(1-CRRA);
            consumpNaive_g_t1(flg,j) = max(E_wage_g_t1(flg,j),Clb).^(1-CRRA)./(1-CRRA);
            consumpNaive_g_t2(flg,j) = max(E_wage_g_t2(flg,j),Clb).^(1-CRRA)./(1-CRRA);
            consump_g_t1(flg,j)      = e_work_c(E_ln_wage_g_t1(flg,j),jhrs_g(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(flg,1,1),sig(1)+lambdaydgstart^2*unsk_wage_sig^2);
            consump_g_t2(flg,j)      = e_work_c(E_ln_wage_g_t2(flg,j),jhrs_g(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(flg,1,1),sig(1)+(1+rhoU^2)*lambdaydgstart^2*unsk_wage_sig^2);
        elseif j==20
            consump_g(flg,j)         = Clb.^(1-CRRA)./(1-CRRA);
            consump_gPI(flg,j)       = Clb.^(1-CRRA)./(1-CRRA);
            consumpNaive_g(flg,j)    = Clb.^(1-CRRA)./(1-CRRA);
            consumpNaive_g_t1(flg,j) = Clb.^(1-CRRA)./(1-CRRA);
            consumpNaive_g_t2(flg,j) = Clb.^(1-CRRA)./(1-CRRA);
            consump_g_t1(flg,j)      = Clb.^(1-CRRA)./(1-CRRA);
            consump_g_t2(flg,j)      = Clb.^(1-CRRA)./(1-CRRA);
        end
    end

    econsumps = v2struct(consump,consumpPI,consump_t1,consump_t2,consump_g,consump_gPI,consump_g_t1,consump_g_t2,consumpNaive,consumpNaive_g,consumpNaive_t1,consumpNaive_g_t1,consumpNaive_t2,consumpNaive_g_t2);
end

function ec = e_work_c(lnw,hrs,Clb,theta,vabil,vnoise)
    a = Clb.^(1-theta);
    mw = lnw+log(hrs);
    sig2w = vnoise+vabil;
    mz = (1-theta)*mw;
    sig2z = (1-theta).^2.*(vnoise + vabil);
    if theta>1
        ez = exp(mz+sig2z/2).*(     normcdf( (log(a)-mz-sig2z )./sqrt(sig2z)   )./    normcdf( (log(a)-mz)./sqrt(sig2z) )   );
    elseif theta<1
        ez = exp(mz+sig2z/2).*( ( 1-normcdf( (log(a)-mz-sig2z )./sqrt(sig2z) ) )./( 1-normcdf( (log(a)-mz)./sqrt(sig2z) ) ) );
    else
        error('not defined for theta=1!');
    end
    Fw = normcdf(log(Clb),mw,sqrt(sig2w));
    ec = (1/(1-theta)).*(Fw.*(Clb.^(1-theta)) + (1-Fw).*ez);
end

function ec = e_w_sch_c(Clb,theta,xbw,hrs,xbpt,xbg,xbl,tui,sigw,sigpt,sigg,prpt,prg,D)
    c1 = (1-prpt).*(1-prg).*intgrt(1,false,Clb,theta,tui,xbl,log(hrs),xbw,[],[],sigw,[],[],D);
    c2 =    prpt .*(1-prg).*intgrt(2,true,Clb,theta,tui,xbl,log(hrs),xbw,xbpt,[],sigw,sigpt,[],D);
    c3 = (1-prpt).*   prg .*intgrt(2,false,Clb,theta,tui,xbl,log(hrs),xbw,xbg,[],sigw,sigg,[],D);
    c4 =    prpt .*   prg .*intgrt(3,true,Clb,theta,tui,xbl,log(hrs),xbw,xbpt,xbg,sigw,sigpt,sigg,D);
    ec = c1+c2+c3+c4;

    function est = intgrt(ndim,ispt,Clb,theta,tui,loan,loghrs,m1,m2,m3,s1,s2,s3,D)
        % this function computes integrals by Monte Carlo simulation
        est = zeros(size(m1));
        if ndim==1
            for d=1:D
                x1  = normrnd(m1,s1);
                est = est+(1/D)*max(exp(loghrs+x1)+loan-tui,Clb).^(1-theta)./(1-theta);
            end
        elseif ndim==2
            if ispt
                for d=1:D
                    x1  = normrnd(m1,s1);
                    x2  = normrnd(m2,s2);
                    est = est+(1/D)*max(exp(loghrs+x1)+exp(x2)+loan-tui,Clb).^(1-theta)./(1-theta);
                end
            else
                for d=1:D
                    x1  = normrnd(m1,s1);
                    x2  = normrnd(m2,s2);
                    est = est+(1/D)*max(exp(loghrs+x1)+    x2 +loan-tui,Clb).^(1-theta)./(1-theta);
                end
            end
        elseif ndim==3
            if ispt
                for d=1:D
                    x1  = normrnd(m1,s1);
                    x2  = normrnd(m2,s2);
                    x3  = normrnd(m3,s3);
                    est = est+(1/D)*max(exp(loghrs+x1)+exp(x2)+x3+loan-tui,Clb).^(1-theta)./(1-theta);
                end
            else
                for d=1:D
                    x1  = normrnd(m1,s1);
                    x2  = normrnd(m2,s2);
                    x3  = normrnd(m3,s3);
                    est = est+(1/D)*max(exp(loghrs+x1)+    x2 +x3+loan-tui,Clb).^(1-theta)./(1-theta);
                end
            end
        end
    end
end


function ec = e_sch_c(Clb,theta,xbpt,xbg,xbl,tui,sigpt,sigg,prpt,prg,D)
    c1 = (1-prpt).*(1-prg).*max(xbl-tui,Clb).^(1-theta)./(1-theta);
    c2 =    prpt .*(1-prg).*intgrt(1,true,Clb,theta,tui,xbl,xbpt,[],sigpt,[],D);
    c3 = (1-prpt).*   prg .*intgrt(1,false,Clb,theta,tui,xbl,xbg,[],sigg,[],D);
    c4 =    prpt .*   prg .*intgrt(2,true,Clb,theta,tui,xbl,xbpt,xbg,sigpt,sigg,D);
    ec = c1+c2+c3+c4;

    function est = intgrt(ndim,ispt,Clb,theta,tui,loan,m1,m2,s1,s2,D)
        % this function computes integrals by Monte Carlo simulation
        est = zeros(size(m1));
        if ndim==1
            if ispt
                for d=1:D
                    x1  = normrnd(m1,s1);
                    est = est+(1/D)*max(exp(x1)+loan-tui,Clb).^(1-theta)./(1-theta);
                end
            else
                for d=1:D
                    x1  = normrnd(m1,s1);
                    est = est+(1/D)*max(    x1 +loan-tui,Clb).^(1-theta)./(1-theta);
                end
            end
        elseif ndim==2
            if ispt
                for d=1:D
                    x1  = normrnd(m1,s1);
                    x2  = normrnd(m2,s2);
                    est = est+(1/D)*max(exp(x1)+x2+loan-tui,Clb).^(1-theta)./(1-theta);
                end
            else
                for d=1:D
                    x1  = normrnd(m1,s1);
                    x2  = normrnd(m2,s2);
                    est = est+(1/D)*max(    x1 +x2+loan-tui,Clb).^(1-theta)./(1-theta);
                end
            end
        end
    end
end
