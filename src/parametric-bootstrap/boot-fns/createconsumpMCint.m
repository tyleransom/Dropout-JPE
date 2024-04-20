function econsumps = createconsumpMCint(data,wages,priorabilstruct,learnparms,r,Clb,CRRA,D,AR1parms,S,tt)

    year = [];
    v2struct(data);
    v2struct(wages);
    v2struct(learnparms);
    v2struct(priorabilstruct);
    v2struct(AR1parms);

    % lambdas
    lmd1 = ones(1,20);
    lmd1([2 4 7 9 12 14]) = lambdag1start;
    lmd1([1 3 6 8 11 13]) = lambdan1start;
    % wages in levels
    jhrs   = [repmat([40*52 40*52 20*52 20*52 0],1,3) 20*52 20*52 40*52 40*52 0];
    jhrs_g = [zeros(1,15) 20*52 20*52 40*52 40*52 0];
    wrkr   = ones(size(E_ln_wage  ,1),1)*jhrs;
    wrkr_g = ones(size(E_ln_wage_g,1),1)*jhrs_g;

    %% Get consumption components in conformable size (i.e. replicate to account for missing majors and unobs types)
    % PT (2- and 4-year), Grants (2- and 4-year), Loans (2- and 4-year), Tuition (2- and 4-year)
    sig4pt   = ParTrans4RMSE;
    sig2pt   = ParTrans2RMSE;
    sigg4    = grant4RMSE;
    sigg2    = grant2RMSE;
    pt4idx   = getParTransIdx(data,0,0,4);
    pt2idx   = getParTransIdx(data,0,0,2);
    pt4idxt1 = getParTransIdx(data,1,0,4);
    pt2idxt1 = getParTransIdx(data,1,0,2);
    gr4idx   = grant4idx;
    gr2idx   = grant2idx;
    lo4idx   = E_loan4_18.*(1+r).^(tt-1);
    lo2idx   = E_loan2_18.*(1+r).^(tt-1);
    lo4idxt1 = lo4idx.*(1+r);
    lo2idxt1 = lo2idx.*(1+r);
    prpt4    = getParTransPr(data,0,4);
    prpt2    = getParTransPr(data,0,2);
    prpt4t1  = getParTransPr(data,1,4);
    prpt2t1  = getParTransPr(data,1,2);
    prg4     = grant4pr;
    prg2     = grant2pr;
    tu4      = tui4imp;
    tu2      = tui2imp;

    consump      = nan(size(pt4idx,1),20);
    consump_g    = nan(size(pt4idx,1),20);
    consump_t1   = nan(size(pt4idx,1),20);
    consump_g_t1 = nan(size(pt4idx,1),20);

    % non-grads
    for j = 1:20; % loop over all current decisions
        %for a=0:1; % loop over all possible ages
            % school only
            if j==5
                consump(:,5)         = e_sch_c(Clb,CRRA,pt2idx,gr2idx,lo2idx,tu2,sig2pt,sigg2,prpt2,prg2,D);
                consump(:,[10 15])   = repmat(e_sch_c(Clb,CRRA,pt4idx,gr4idx,lo4idx,tu4,sig4pt,sigg4,prpt4,prg4,D),1,2); % consumption doesn't depend on major
                consump_t1(:,5)      = e_sch_c(Clb,CRRA,pt2idxt1,gr2idx,lo2idxt1,tu2,sig2pt,sigg2,prpt2t1,prg2,D);
                consump_t1(:,[10 15])= repmat(e_sch_c(Clb,CRRA,pt4idxt1,gr4idx,lo4idxt1,tu4,sig4pt,sigg4,prpt4t1,prg4,D),1,2); % consumption doesn't depend on major
            % 2yr and work (blue collar)
            elseif ismember(j,[1 3])
                %size(Clb)
                %size(CRRA)
                %size(E_ln_wage)
                %size(E_ln_wage(:,j))
                %size(jhrs(j))
                %size(pt2idx)
                %size(gr2idx)
                %size(lo2idx)
                %size(tu2)
                %size(sig2pt)
                %size(sigg2)
                %size(prpt2)
                %size(prg2)
                %size(consump(:,j))
                %size(consump)
                %size(vabilpriormat)
                %size(vabilpriormat(:,2,2))
                %size(sqrt(lmd1(j)^2.*vabilpriormat(:,2,2)+sig(4)))
                consump(:,j)         = e_w_sch_c(Clb,CRRA,E_ln_wage(:,j),jhrs(j),pt2idx,gr2idx,lo2idx,tu2,sqrt(lmd1(j)^2.*vabilpriormat(:,2,2)+sig(4)),sig2pt,sigg2,prpt2,prg2,D);
                consump_t1(:,j)      = e_w_sch_c(Clb,CRRA,E_ln_waget1(:,j),jhrs(j),pt2idxt1,gr2idx,lo2idxt1,tu2,sqrt(lmd1(j)^2.*vabilpriormat(:,2,2)+sig(4)+unsk_wage_sig^2),sig2pt,sigg2,prpt2t1,prg2,D);
            % 2yr and work (white collar)
            elseif ismember(j,[2 4])
                consump(:,j)         = e_w_sch_c(Clb,CRRA,E_ln_wage(:,j),jhrs(j),pt2idx,gr2idx,lo2idx,tu2,sqrt(lmd1(j)^2.*vabilpriormat(:,1,1)+sig(2)),sig2pt,sigg2,prpt2,prg2,D);
                consump_t1(:,j)      = e_w_sch_c(Clb,CRRA,E_ln_waget1(:,j),jhrs(j),pt2idxt1,gr2idx,lo2idxt1,tu2,sqrt(lmd1(j)^2.*vabilpriormat(:,1,1)+sig(2)+lambdaydgstart^2*unsk_wage_sig^2),sig2pt,sigg2,prpt2t1,prg2,D);
            % 4yr and work (blue collar)
            elseif ismember(j,[6 8 11 13])
                consump(:,j)         = e_w_sch_c(Clb,CRRA,E_ln_wage(:,j),jhrs(j),pt4idx,gr4idx,lo4idx,tu4,sqrt(lmd1(j)^2.*vabilpriormat(:,2,2)+sig(4)),sig4pt,sigg4,prpt4,prg4,D);
                consump_t1(:,j)      = e_w_sch_c(Clb,CRRA,E_ln_waget1(:,j),jhrs(j),pt4idxt1,gr4idx,lo4idxt1,tu4,sqrt(lmd1(j)^2.*vabilpriormat(:,2,2)+sig(4)+unsk_wage_sig^2),sig4pt,sigg4,prpt4t1,prg4,D);
            % 4yr and work (white collar)
            elseif ismember(j,[7 9 12 14])
                consump(:,j)         = e_w_sch_c(Clb,CRRA,E_ln_wage(:,j),jhrs(j),pt4idx,gr4idx,lo4idx,tu4,sqrt(lmd1(j)^2.*vabilpriormat(:,1,1)+sig(2)),sig4pt,sigg4,prpt4,prg4,D);
                consump_t1(:,j)      = e_w_sch_c(Clb,CRRA,E_ln_waget1(:,j),jhrs(j),pt4idxt1,gr4idx,lo4idxt1,tu4,sqrt(lmd1(j)^2.*vabilpriormat(:,1,1)+sig(2)+lambdaydgstart^2*unsk_wage_sig^2),sig4pt,sigg4,prpt4t1,prg4,D);
            % work only
            elseif ismember(j,[16 18])
                consump(:,j)         = e_work_c(E_ln_wage(:,j),jhrs(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(:,2,2),sig(3));
                consump_t1(:,j)      = e_work_c(E_ln_waget1(:,j),jhrs(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(:,2,2),sig(3)+unsk_wage_sig^2);
            elseif ismember(j,[17 19])
                consump(:,j)         = e_work_c(E_ln_wage(:,j),jhrs(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(:,1,1),sig(1));
                consump_t1(:,j)      = e_work_c(E_ln_waget1(:,j),jhrs(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(:,1,1),sig(1)+lambdaydgstart^2*unsk_wage_sig^2);
            elseif j==20
            consump(:,j)         = Clb.^(1-CRRA)./(1-CRRA);
            consump_t1(:,j)      = Clb.^(1-CRRA)./(1-CRRA);
            end
        %end
    end

    % grads
    for j = 16:20 % loop over all current decisions
        if ismember(j,[16 18])
            consump_g(:,j)         = e_work_c(E_ln_wage_g(:,j),jhrs_g(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(:,2,2),sig(3));
            consump_g_t1(:,j)      = e_work_c(E_ln_wage_g_t1(:,j),jhrs_g(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(:,2,2),sig(3)+unsk_wage_sig^2);
        elseif ismember(j,[17 19])
            consump_g(:,j)         = e_work_c(E_ln_wage_g(:,j),jhrs_g(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(:,1,1),sig(1));
            consump_g_t1(:,j)      = e_work_c(E_ln_wage_g_t1(:,j),jhrs_g(j),Clb,CRRA,lmd1(j)^2.*vabilpriormat(:,1,1),sig(1)+lambdaydgstart^2*unsk_wage_sig^2);
        elseif j==20
            consump_g(:,j)         = Clb.^(1-CRRA)./(1-CRRA);
            consump_g_t1(:,j)      = Clb.^(1-CRRA)./(1-CRRA);
        end
    end

    econsumps = v2struct(consump,consump_t1,consump_g,consump_g_t1);
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
