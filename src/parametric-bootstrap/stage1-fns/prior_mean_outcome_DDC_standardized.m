function [meanpriorstruct] = prior_mean_outcome_DDC_standardized(df,S)
    % Returns a N*T*S by J (nb of outcomes) matrix of average outcomes (up to time-t).
    % The order within each column is: first t (time), then i (individual), then s (heterogeneity type).

    J = 5;
    T = df.T;
    N = df.N;

    % Create index vectors for later convenience
    wc_idx  = [2 4 7 9 12 14 17 19];
    bc_idx  = [1 3 6 8 11 13 16 18];

    % Create flags for later convenience
    flagWC  = ismember(df.Yl,wc_idx);
    flagBC  = ismember(df.Yl,bc_idx);
    flag4s  = ismember(df.Yl,6:10  ); % don't drop missing grades from the signal calculation; use imputed values
    flag4h  = ismember(df.Yl,11:15 );
    flag2   = ismember(df.Yl,1:5   );

    wageg   = df.wagesl (flagWC);
    wagen   = df.wagesl (flagBC);
    grade4s = df.gradesl(flag4s);
    grade4h = df.gradesl(flag4h);
    grade2  = df.gradesl(flag2);

    outcg   = (wageg - mean(wageg(wageg~=0)))./std(wageg(wageg~=0));
    outcn   = (wagen - mean(wagen(wagen~=0)))./std(wagen(wagen~=0));

    outc4s  = (grade4s - mean(grade4s(grade4s~=0)))./std(grade4s(grade4s~=0));
    outc4h  = (grade4h - mean(grade4h(grade4h~=0)))./std(grade4h(grade4h~=0));
    outc2   = (grade2  - mean(grade2 (grade2 ~=0)))./std(grade2 (grade2 ~=0));

    Outcg          = zeros(N*T*S,1);
    Outcg(flagWC)  = outcg;
    Outcn          = zeros(N*T*S,1);
    Outcn(flagBC)  = outcn;
    Outc4s         = zeros(N*T*S,1);
    Outc4s(flag4s) = outc4s;
    Outc4h         = zeros(N*T*S,1);
    Outc4h(flag4h) = outc4h;
    Outc2          = zeros(N*T*S,1);
    Outc2 (flag2)  = outc2;

    Ylbis      = reshape(df.Yl',T,N*S)';
    Outcgbis       = reshape(Outcg',T,N*S)';
    Outcnbis       = reshape(Outcn',T,N*S)';
    Outc4sbis      = reshape(Outc4s',T,N*S)';
    Outc4hbis      = reshape(Outc4h',T,N*S)';
    Outc2bis       = reshape(Outc2',T,N*S)';

    meanymat       = zeros(N*S,J*T);
    meanypriormat  = zeros(N*S,J*T);

    for t=1:T
        Ylt  = Ylbis(:,1:t);

        % Create time-period-specific flags
        flagtWC  = ismember(Ylt,wc_idx  );
        flagtBC  = ismember(Ylt,bc_idx  );
        flagt4s  = (Ylt>5  & Ylt<11);
        flagt4h  = (Ylt>10 & Ylt<16);
        flagt2   = (Ylt>0  & Ylt<6);

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
    meanypriormat                       = reshape(meanypriormat',J,N*T*S)';

    prior_mean_outcome_S_vec   = meanypriormat(:,1);
    prior_mean_outcome_U_vec   = meanypriormat(:,2);
    prior_mean_outcome_4S_vec  = meanypriormat(:,3);
    prior_mean_outcome_4NS_vec = meanypriormat(:,4);
    prior_mean_outcome_2_vec   = meanypriormat(:,5);

    meanpriorstruct = v2struct(prior_mean_outcome_S_vec, prior_mean_outcome_U_vec, prior_mean_outcome_4S_vec, prior_mean_outcome_4NS_vec, prior_mean_outcome_2_vec);
end
