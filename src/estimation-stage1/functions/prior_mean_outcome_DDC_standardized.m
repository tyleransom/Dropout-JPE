function [meanpriorstruct] = prior_mean_outcome_DDC_standardized(df,S)
    % Returns a N*T*S by J (nb of outcomes) matrix of average outcomes (up to time-t).
    % The order within each column is: first t (time), then i (individual), then s (heterogeneity type).

    J       = 5;
    T       = df.T;
    Ntilde  = df.Ntilde;

    % Create index vectors for later convenience
    wc_idx  = [2 4 7 9 12 14 17 19];
    bc_idx  = [1 3 6 8 11 13 16 18];

    % Create flags for later convenience
    flagWC  = ismember(df.ClImps,wc_idx);
    flagBC  = ismember(df.ClImps,bc_idx);
    flag4s  = ismember(df.ClImps,6:10  ); % don't drop missing grades from the signal calculation; use imputed values
    flag4h  = ismember(df.ClImps,11:15 );
    flag2   = ismember(df.ClImps,1:5   );

    wageg   = df.wageslImps (flagWC);
    wagen   = df.wageslImps (flagBC);
    grade4s = df.gradeslImps(flag4s);
    grade4h = df.gradeslImps(flag4h);
    grade2  = df.gradeslImps(flag2);

    outcg   = (wageg - mean(wageg(wageg~=0)))./std(wageg(wageg~=0));
    outcn   = (wagen - mean(wagen(wagen~=0)))./std(wagen(wagen~=0));

    outc4s  = (grade4s - mean(grade4s(grade4s~=0)))./std(grade4s(grade4s~=0));
    outc4h  = (grade4h - mean(grade4h(grade4h~=0)))./std(grade4h(grade4h~=0));
    outc2   = (grade2  - mean(grade2 (grade2 ~=0)))./std(grade2 (grade2 ~=0));

    Outcg          = zeros(Ntilde*T*S,1);
    Outcg(flagWC)  = outcg;
    Outcn          = zeros(Ntilde*T*S,1);
    Outcn(flagBC)  = outcn;
    Outc4s         = zeros(Ntilde*T*S,1);
    Outc4s(flag4s) = outc4s;
    Outc4h         = zeros(Ntilde*T*S,1);
    Outc4h(flag4h) = outc4h;
    Outc2          = zeros(Ntilde*T*S,1);
    Outc2 (flag2)  = outc2;

    ClImpsbis      = reshape(df.ClImps',T,Ntilde*S)';
    Outcgbis       = reshape(Outcg',T,Ntilde*S)';
    Outcnbis       = reshape(Outcn',T,Ntilde*S)';
    Outc4sbis      = reshape(Outc4s',T,Ntilde*S)';
    Outc4hbis      = reshape(Outc4h',T,Ntilde*S)';
    Outc2bis       = reshape(Outc2',T,Ntilde*S)';

    meanymat       = zeros(Ntilde*S,J*T);
    meanypriormat  = zeros(Ntilde*S,J*T);

    for t=1:T
        ClImpst  = ClImpsbis(:,1:t);

        % Create time-period-specific flags
        flagtWC  = ismember(ClImpst,wc_idx  );
        flagtBC  = ismember(ClImpst,bc_idx  );
        flagt4s  = (ClImpst>5  & ClImpst<11);
        flagt4h  = (ClImpst>10 & ClImpst<16);
        flagt2   = (ClImpst>0  & ClImpst<6);

        Outcgt   = Outcgbis(:,1:t);
        Outcnt   = Outcnbis(:,1:t);
        Outc4st  = Outc4sbis(:,1:t);
        Outc4ht  = Outc4hbis(:,1:t);
        Outc2t   = Outc2bis(:,1:t);

        % sum all of the outcome variables
        toutcgt  = sum(Outcgt,2);
        toutcnt  = sum(Outcnt,2);
        toutc4st = sum(Outc4st,2);
        toutc4ht = sum(Outc4ht,2);
        toutc2t  = sum(Outc2t ,2);

        if t==1
            Csumw = [(flagtWC) (flagtBC) (flagt4s) (flagt4h) (flagt2)];
        else
            Csumw = [sum(flagtWC,2) sum(flagtBC,2) sum(flagt4s,2) sum(flagt4h,2) sum(flagt2,2)];
        end

        meanytmat = [toutcgt toutcnt toutc4st toutc4ht toutc2t]./Csumw;

        meanymat(:,(t-1)*J+1:t*J)=meanytmat;

        if t>1
            meanypriormat(:,(t-1)*J+1:t*J)=meanymat(:,(t-2)*J+1:(t-1)*J);
        end

    end

    meanypriormat(isnan(meanypriormat)) = 0;
    meanypriormat                       = reshape(meanypriormat',J,Ntilde*T*S)';

    prior_mean_outcome_S_vec   = meanypriormat(:,1);
    prior_mean_outcome_U_vec   = meanypriormat(:,2);
    prior_mean_outcome_4S_vec  = meanypriormat(:,3);
    prior_mean_outcome_4NS_vec = meanypriormat(:,4);
    prior_mean_outcome_2_vec   = meanypriormat(:,5);

    meanpriorstruct = v2struct(prior_mean_outcome_S_vec, prior_mean_outcome_U_vec, prior_mean_outcome_4S_vec, prior_mean_outcome_4NS_vec, prior_mean_outcome_2_vec);
end
