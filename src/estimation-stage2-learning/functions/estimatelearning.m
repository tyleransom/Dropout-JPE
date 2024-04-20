function [parmsUpdated] = estimatelearning(choicedata,learndata,parms,PmajgpaTypes,PmajgpaType,S)
    % Read in data
    v2struct(choicedata)
    v2struct(learndata)
    v2struct(parms)

    % Create flags for later convenience
    ydg      = [18:33];
    ydn      = [18:33];
    yd4s     = [];
    yd4h     = [];
    yndg     = setdiff([1:size(xgS,2)],ydg);
    yndn     = setdiff([1:size(xnS,2)],ydn);
    ynd4s    = [];
    ynd4h    = [];
    wcNS_idx = [              17 19];
    wcS_idx  = [2 4 7 9 12 14      ];
    wc_idx   = [2 4 7 9 12 14 17 19];
    bcNS_idx = [              16 18];
    bcS_idx  = [1 3 6 8 11 13      ];
    bc_idx   = [1 3 6 8 11 13 16 18];
    assert(length(ydg)==length(ydn), 'ydg and ydn must be of the same length')

    flag_wcNS = ismember(ClImps,wcNS_idx);
    flag_wcS  = ismember(ClImps,wcS_idx );
    flag_wc   = ismember(ClImps,wc_idx  );
    flag_bcNS = ismember(ClImps,bcNS_idx);
    flag_bcS  = ismember(ClImps,bcS_idx );
    flag_bc   = ismember(ClImps,bc_idx  );
    flag4s12  = (ClImps>5  & ClImps<11 & yrclImps<3);
    flag4h12  = (ClImps>10 & ClImps<16 & yrclImps<3);
    flag212   = (ClImps>0  & ClImps<6  & yrclImps<3);
    flag4s3T  = (ClImps>5  & ClImps<11 & yrclImps>2);
    flag4h3T  = (ClImps>10 & ClImps<16 & yrclImps>2);
    flag23T   = (ClImps>0  & ClImps<6  & yrclImps>2);
    flag4s    = (ClImps>5  & ClImps<11);
    flag4s1   = (ClImps>5  & ClImps<11 & yrclImps==1);
    flag4s2   = (ClImps>5  & ClImps<11 & yrclImps==2);
    flag4s3   = (ClImps>5  & ClImps<11 & yrclImps==3);
    flag4s4   = (ClImps>5  & ClImps<11 & yrclImps==4);
    flag4s5T  = (ClImps>5  & ClImps<11 & yrclImps>=5);
    flag4h    = (ClImps>10 & ClImps<16);
    flag4h1   = (ClImps>10 & ClImps<16 & yrclImps==1);
    flag4h2   = (ClImps>10 & ClImps<16 & yrclImps==2);
    flag4h3   = (ClImps>10 & ClImps<16 & yrclImps==3);
    flag4h4   = (ClImps>10 & ClImps<16 & yrclImps==4);
    flag4h5T  = (ClImps>10 & ClImps<16 & yrclImps>=5);
    flag2     = (ClImps>0  & ClImps<6);
    flag21    = (ClImps>0  & ClImps<6  & yrclImps==1);
    flag22    = (ClImps>0  & ClImps<6  & yrclImps==2);

    gflg = ismember(ClImps(flag_wc),wcS_idx);
    nflg = ismember(ClImps(flag_bc),bcS_idx);
    sflg = yrclImps(flag4s)>2;
    hflg = yrclImps(flag4h)>2;

    % Create various versions of the type weights (q's)
    PmajgpaTypesl   = PmajgpaTypes(:);

    PmajgpaTypegNS  = PmajgpaType(flag_wcNS);
    PmajgpaTypegS   = PmajgpaType(flag_wcS);
    PmajgpaTypeg    = PmajgpaType(flag_wc);
    PmajgpaTypenNS  = PmajgpaType(flag_bcNS);
    PmajgpaTypenS   = PmajgpaType(flag_bcS);
    PmajgpaTypen    = PmajgpaType(flag_bc);
    PmajgpaType4s12 = PmajgpaType(flag4s12);
    PmajgpaType4h12 = PmajgpaType(flag4h12);
    PmajgpaType212  = PmajgpaType(flag212);
    PmajgpaType4s3T = PmajgpaType(flag4s3T);
    PmajgpaType4h3T = PmajgpaType(flag4h3T);
    PmajgpaType23T  = PmajgpaType(flag23T);
    PmajgpaType4s   = PmajgpaType(flag4s);
    PmajgpaType4s1  = PmajgpaType(flag4s1);
    PmajgpaType4s2  = PmajgpaType(flag4s2);
    PmajgpaType4s3  = PmajgpaType(flag4s3);
    PmajgpaType4s4  = PmajgpaType(flag4s4);
    PmajgpaType4s5T = PmajgpaType(flag4s5T);
    PmajgpaType4h   = PmajgpaType(flag4h);
    PmajgpaType4h1  = PmajgpaType(flag4h1);
    PmajgpaType4h2  = PmajgpaType(flag4h2);
    PmajgpaType4h3  = PmajgpaType(flag4h3);
    PmajgpaType4h4  = PmajgpaType(flag4h4);
    PmajgpaType4h5T = PmajgpaType(flag4h5T);
    PmajgpaType2    = PmajgpaType(flag2);
    PmajgpaType21   = PmajgpaType(flag21);
    PmajgpaType22   = PmajgpaType(flag22);

    NgNS  = sum(PmajgpaTypegNS );
    NgS   = sum(PmajgpaTypegS );
    NnNS  = sum(PmajgpaTypenNS );
    NnS   = sum(PmajgpaTypenS );
    N4s1  = sum(PmajgpaType4s1 );
    N4s2  = sum(PmajgpaType4s2 );
    N4s3  = sum(PmajgpaType4s3 );
    N4s4  = sum(PmajgpaType4s4 );
    N4s5T = sum(PmajgpaType4s5T);
    N4h1  = sum(PmajgpaType4h1 );
    N4h2  = sum(PmajgpaType4h2 );
    N4h3  = sum(PmajgpaType4h3 );
    N4h4  = sum(PmajgpaType4h4 );
    N4h5T = sum(PmajgpaType4h5T);
    N21   = sum(PmajgpaType21  );
    N22   = sum(PmajgpaType22  );
    N23T  = sum(PmajgpaType23T );
    BigN  = [NgNS;NgS;NnNS;NnS;N4s1;N4s2;N4s3;N4s4;N4s5T;N4h1;N4h2;N4h3;N4h4;N4h5T;N21;N22;N23T];

    % initialize results to be estimated
    lambdaydgstart = 1;
    lambda0start   = [lambdag0start;lambdan0start;lambda4s0start;lambda4h0start];
    selambda0start = zeros(size(lambda0start));
    lambda1start   = [lambdag1start;lambdan1start;lambda4s1start;lambda4h1start];
    selambda1start = zeros(size(lambda1start));
    seb2           = zeros(size(bstart2));
    sebg           = zeros(size(bstartg));
    sebn           = zeros(size(bstartn));
    seb4s          = zeros(size(bstart4s));
    seb4h          = zeros(size(bstart4h));

    residgNS = wagegNS-(xgNS(:,yndg)*bstartg(yndg) + lambdaydgstart*(xgNS(:,ydg)*bstartn(ydn)));
    residnNS = wagenNS-(xnNS*bstartn);
    residgS  = (wagegS-lambdag0start-lambdaydgstart*(xgS(:,ydg)*bstartn(ydn)))/lambdag1start-(xgS(:,yndg)*bstartg(yndg));
    residnS  = (wagenS-lambdan0start-                xnS(:,ydn)*bstartn(ydn) )/lambdan1start-(xnS(:,yndn)*bstartn(yndn));

    resid4s12 = grade4s12-(x4s12*bstart4s);
    resid4h12 = grade4h12-(x4h12*bstart4h);
    resid212  = grade212 -(x212 *bstart2 );
    resid4s3T = (grade4s3T-lambda4s0start)/lambda4s1start-(x4s3T*bstart4s);
    resid4h3T = (grade4h3T-lambda4h0start)/lambda4h1start-(x4h3T*bstart4h);
    resid23T  = (grade23T-lambda20start )/lambda21start -(x23T *bstart2 );

    Residg              = zeros(Ntilde*T*S,1);
    ResidgNS            = zeros(Ntilde*T*S,1);
    ResidgS             = zeros(Ntilde*T*S,1);
    Residg(flag_wcNS)   = residgNS;
    Residg(flag_wcS)    = residgS;
    ResidgNS(flag_wcNS) = residgNS;
    ResidgS(flag_wcS)   = residgS;

    Residn              = zeros(Ntilde*T*S,1);
    ResidnNS            = zeros(Ntilde*T*S,1);
    ResidnS             = zeros(Ntilde*T*S,1);
    Residn(flag_bcNS)   = residnNS;
    Residn(flag_bcS)    = residnS;
    ResidnNS(flag_bcNS) = residnNS;
    ResidnS(flag_bcS)   = residnS;

    Resid4s             = zeros(Ntilde*T*S,1);
    Resid4s12           = zeros(Ntilde*T*S,1);
    Resid4s3T           = zeros(Ntilde*T*S,1);
    Resid4s  (flag4s12) = resid4s12;
    Resid4s  (flag4s3T) = resid4s3T;
    Resid4s12(flag4s12) = resid4s12;
    Resid4s3T(flag4s3T) = resid4s3T;
    resid4s             = Resid4s(flag4s);
    resid4s1            = Resid4s(flag4s1);
    resid4s2            = Resid4s(flag4s2);
    resid4s3            = Resid4s(flag4s3);
    resid4s4            = Resid4s(flag4s4);
    resid4s5T           = Resid4s(flag4s5T);

    Resid4h             = zeros(Ntilde*T*S,1);
    Resid4h12           = zeros(Ntilde*T*S,1);
    Resid4h3T           = zeros(Ntilde*T*S,1);
    Resid4h  (flag4h12) = resid4h12;
    Resid4h  (flag4h3T) = resid4h3T;
    Resid4h12(flag4h12) = resid4h12;
    Resid4h3T(flag4h3T) = resid4h3T;
    resid4h             = Resid4h(flag4h);
    resid4h1            = Resid4h(flag4h1);
    resid4h2            = Resid4h(flag4h2);
    resid4h3            = Resid4h(flag4h3);
    resid4h4            = Resid4h(flag4h4);
    resid4h5T           = Resid4h(flag4h5T);

    Resid2              = zeros(Ntilde*T*S,1);
    Resid212            = zeros(Ntilde*T*S,1);
    Resid23T            = zeros(Ntilde*T*S,1);
    Resid2  (flag212)   = resid212;
    Resid2  (flag23T)   = resid23T;
    Resid212(flag212)   = resid212;
    Resid23T(flag23T)   = resid23T;
    resid2              = Resid2(flag2);
    resid21             = Resid2(flag21);
    resid22             = Resid2(flag22);
    resid23T            = Resid2(flag23T);

    Csum   = [(sum(reshape(flag_wc,T,Ntilde*S)))'  (sum(reshape(flag_bc,T,Ntilde*S)))'  (sum(reshape(flag4s,T,Ntilde*S)))'   (sum(reshape(flag4h,T,Ntilde*S)))'   (sum(reshape(flag2,T,Ntilde*S)))'];
    tresid = [(sum(reshape(Residg,T,Ntilde*S)))' (sum(reshape(Residn,T,Ntilde*S)))' (sum(reshape(Resid4s,T,Ntilde*S)))' (sum(reshape(Resid4h,T,Ntilde*S)))' (sum(reshape(Resid2,T,Ntilde*S)))'];

    Csumw=[(sum(reshape(flag_wcNS,T,Ntilde*S)))' (sum(reshape(flag_wcS,T,Ntilde*S)))' (sum(reshape(flag_bcNS,T,Ntilde*S)))' (sum(reshape(flag_bcS,T,Ntilde*S)))' (sum(reshape(flag4s1,T,Ntilde*S)))' (sum(reshape(flag4s2,T,Ntilde*S)))' (sum(reshape(flag4s3,T,Ntilde*S)))' (sum(reshape(flag4s4,T,Ntilde*S)))' (sum(reshape(flag4s5T,T,Ntilde*S)))' (sum(reshape(flag4h1,T,Ntilde*S)))' (sum(reshape(flag4h2,T,Ntilde*S)))' (sum(reshape(flag4h3,T,Ntilde*S)))' (sum(reshape(flag4h4,T,Ntilde*S)))' (sum(reshape(flag4h5T,T,Ntilde*S)))' (sum(reshape(flag21,T,Ntilde*S)))' (sum(reshape(flag22,T,Ntilde*S)))' (sum(reshape(flag23T,T,Ntilde*S)))'];
    Psi1=Csumw;

    sig2=zeros(1500,17);
    cov2=zeros(1500,15);

    sigtemp = zeros(17,1);
    covtemp = zeros(5);
    isigg   = ones(Ntilde*T*S,1);
    isign   = ones(Ntilde*T*S,1);
    isig4s  = ones(Ntilde*T*S,1);
    isig4h  = ones(Ntilde*T*S,1);
    isig2   = ones(Ntilde*T*S,1);

    isigg (flag_wcNS) = 1/sig(1);
    isigg (flag_wcS)  = 1/sig(2);
    isign (flag_bcNS) = 1/sig(3);
    isign (flag_bcS)  = 1/sig(4);
    isig4s(flag4s1)   = 1/sig(5);
    isig4s(flag4s2)   = 1/sig(6);
    isig4s(flag4s3)   = 1/sig(7);
    isig4s(flag4s4)   = 1/sig(8);
    isig4s(flag4s5T)  = 1/sig(9);
    isig4h(flag4h1)   = 1/sig(10);
    isig4h(flag4h2)   = 1/sig(11);
    isig4h(flag4h3)   = 1/sig(12);
    isig4h(flag4h4)   = 1/sig(13);
    isig4h(flag4h5T)  = 1/sig(14);
    isig2 (flag21)    = 1/sig(15);
    isig2 (flag22)    = 1/sig(16);
    isig2 (flag23T)   = 1/sig(17);

    j=1;

    while max(max(abs(covtemp - Delta))) > 1e-5
        sigtemp=sig;
        covtemp=Delta;

        Psi=zeros(5);
        abil=zeros(Ntilde*S,5);

        idelta=Delta\eye(size(Delta));
        vtemp2=zeros(5);
        vabil=zeros(S*Ntilde,5);
        vabilw=zeros(S*Ntilde,17);

        % We weight by 1/sig(c) before summing for each type of residuals
        tresidg  = sum(reshape(Residg .*isigg ,T,S*Ntilde))';
        tresidn  = sum(reshape(Residn .*isign ,T,S*Ntilde))';
        tresid4s = sum(reshape(Resid4s.*isig4s,T,S*Ntilde))';
        tresid4h = sum(reshape(Resid4h.*isig4h,T,S*Ntilde))';
        tresid2  = sum(reshape(Resid2 .*isig2 ,T,S*Ntilde))';

        Ntemp = 0;
        for i=1:S*Ntilde
            if sum(Csum(i,:),2)>0
                psit=Psi1(i,:);
                Psi=[psit(1:2)*(1./sig(1:2)) 0 0 0 0; 0 psit(3:4)*(1./sig(3:4)) 0 0 0;  0 0 psit(5:9)*(1./sig(5:9)) 0 0; 0 0 0 psit(10:14)*(1./sig(10:14)) 0; 0 0 0 0 psit(15:17)*(1./sig(15:17))];

                if rcond(idelta+Psi)<1e-10
                    i
                    idelta
                    Psi
                    disp(['Ability covariance estimation error in learning iteration ',num2str(j)]);
                    error('Individual covariance matrix singular!!!');
                end

                vtemp=(idelta+Psi)\eye(size(idelta));

                temp=(vtemp*([tresidg(i);tresidn(i);tresid4s(i);tresid4h(i);tresid2(i)]))';
                abil(i,:)=temp;

                vabil(i,1)=vtemp(1,1);
                vabil(i,2)=vtemp(2,2);
                vabil(i,3)=vtemp(3,3);
                vabil(i,4)=vtemp(4,4);
                vabil(i,5)=vtemp(5,5);

                vtemp2=vtemp2+PmajgpaTypesl(i)*(vtemp+temp'*temp);
                Ntemp = Ntemp+PmajgpaTypesl(i);
            end
        end

        if norm(Ntemp-sum(PmajgpaTypesl.*(sum(Csum,2)>0)),2)>1e-4
            Ntemp
            sum(PmajgpaTypesl.*(sum(Csum,2)>0))
            abs(Ntemp - sum(PmajgpaTypesl.*(sum(Csum,2)>0)))
            error('Ntemp is wrong!');
        end

        Delta=vtemp2./Ntemp;

        vabilw    = [vabil(:,1) vabil(:,1) vabil(:,2) vabil(:,2) vabil(:,3) vabil(:,3) vabil(:,3) vabil(:,3) vabil(:,3) vabil(:,4) vabil(:,4) vabil(:,4) vabil(:,4) vabil(:,4) vabil(:,5) vabil(:,5) vabil(:,5)];
        Abil      = kron(abil,ones(T,1));
        Vabil     = kron(vabil,ones(T,1));

        %It think we need these two lines but please check it
        abilg     = Abil (flag_wc,1);
        abiln     = Abil (flag_bc,2);

        abilgNS   = Abil (flag_wcNS,1);
        abilgS    = Abil (flag_wcS ,1);
        abilnNS   = Abil (flag_bcNS,2);
        abilnS    = Abil (flag_bcS ,2);
        abil4s12  = Abil (flag4s12 ,3);
        abil4h12  = Abil (flag4h12 ,4);
        abil212   = Abil (flag212  ,5);
        abil4s3T  = Abil (flag4s3T ,3);
        abil4h3T  = Abil (flag4h3T ,4);
        abil23T   = Abil (flag23T  ,5);
        vabilg    = Vabil(flag_wc  ,1);
        vabiln    = Vabil(flag_bc  ,2);
        vabil4s   = Vabil(flag4s   ,3);
        vabil4h   = Vabil(flag4h   ,4);
        vabil2    = Vabil(flag2    ,5);
        % vabilgS   = Vabil(flag4s3T,1);
        % vabilnS   = Vabil(flag4h3T,2);
        % vabil23T  = Vabil(flag23T,5);
        % vabil4s3T = Vabil(flag4s3T,3);
        % vabil4h3T = Vabil(flag4h3T,4);
        % vabil23T  = Vabil(flag23T,5);
        abil4s    = Abil (flag4s  ,3);
        abil4s1   = Abil (flag4s1 ,3);
        abil4s2   = Abil (flag4s2 ,3);
        abil4s3   = Abil (flag4s3 ,3);
        abil4s4   = Abil (flag4s4 ,3);
        abil4s5T  = Abil (flag4s5T,3);
        abil4h    = Abil (flag4h  ,4);
        abil4h1   = Abil (flag4h1 ,4);
        abil4h2   = Abil (flag4h2 ,4);
        abil4h3   = Abil (flag4h3 ,4);
        abil4h4   = Abil (flag4h4 ,4);
        abil4h5T  = Abil (flag4h5T,4);
        abil2     = Abil (flag2   ,5);
        abil21    = Abil (flag21  ,5);
        abil22    = Abil (flag22  ,5);
        abil23T   = Abil (flag23T ,5);

        % update value of sig
        sig=((sum(repmat(PmajgpaTypesl,[1 size(Csumw,2)]).*Csumw.*vabilw))'+[sum(PmajgpaTypegNS.*(residgNS-abilgNS).^2); sum(PmajgpaTypegS.*(residgS-abilgS).^2); sum(PmajgpaTypenNS.*(residnNS-abilnNS).^2); sum(PmajgpaTypenS.*(residnS-abilnS).^2); sum(PmajgpaType4s1.*(resid4s1 -abil4s1 ).^2); sum(PmajgpaType4s2.*(resid4s2 -abil4s2 ).^2); sum(PmajgpaType4s3.*(resid4s3 -abil4s3 ).^2); sum(PmajgpaType4s4.*(resid4s4 -abil4s4 ).^2); sum(PmajgpaType4s5T.*(resid4s5T-abil4s5T).^2); sum(PmajgpaType4h1.*(resid4h1 -abil4h1 ).^2); sum(PmajgpaType4h2.*(resid4h2 -abil4h2 ).^2); sum(PmajgpaType4h3.*(resid4h3 -abil4h3 ).^2); sum(PmajgpaType4h4.*(resid4h4 -abil4h4 ).^2); sum(PmajgpaType4h5T.*(resid4h5T-abil4h5T).^2); sum(PmajgpaType21.*(resid21  -abil21  ).^2); sum(PmajgpaType22.*(resid22  -abil22  ).^2); sum(PmajgpaType23T.*(resid23T -abil23T ).^2);])./BigN;
        
        % 1  sum(PmajgpaTypegNS.*(residgNS-abilgNS).^2)
        % 2  sum(PmajgpaTypegS.*(residgS-abilgS).^2)
        % 3  sum(PmajgpaTypenNS.*(residnNS-abilnNS).^2)
        % 4  sum(PmajgpaTypenS.*(residnS-abilnS).^2)
        % 5  sum(PmajgpaType4s1.*(resid4s1 -abil4s1 ).^2)
        % 6  sum(PmajgpaType4s2.*(resid4s2 -abil4s2 ).^2)
        % 7  sum(PmajgpaType4s3.*(resid4s3 -abil4s3 ).^2)
        % 8  sum(PmajgpaType4s4.*(resid4s4 -abil4s4 ).^2)
        % 9  sum(PmajgpaType4s5T.*(resid4s5T-abil4s5T).^2)
        % 10 sum(PmajgpaType4h1.*(resid4h1 -abil4h1 ).^2)
        % 11 sum(PmajgpaType4h2.*(resid4h2 -abil4h2 ).^2)
        % 12 sum(PmajgpaType4h3.*(resid4h3 -abil4h3 ).^2)
        % 13 sum(PmajgpaType4h4.*(resid4h4 -abil4h4 ).^2)
        % 14 sum(PmajgpaType4h5T.*(resid4h5T-abil4h5T).^2)
        % 15 sum(PmajgpaType21.*(resid21  -abil21  ).^2)
        % 16 sum(PmajgpaType22.*(resid22  -abil22  ).^2)
        % 17 sum(PmajgpaType23T.*(resid23T -abil23T ).^2)

        % make big sig vector
        sigv = zeros(Ntilde*T*S,1);
        sigv(flag_wcNS,1) = sig(1);
        sigv(flag_wcS ,1) = sig(2);
        sigv(flag_bcNS,1) = sig(3);
        sigv(flag_bcS ,1) = sig(4);
        sigv(flag4s1  ,1) = sig(5);
        sigv(flag4s2  ,1) = sig(6);
        sigv(flag4s3  ,1) = sig(7);
        sigv(flag4s4  ,1) = sig(8);
        sigv(flag4s5T ,1) = sig(9);
        sigv(flag4h1  ,1) = sig(10);
        sigv(flag4h2  ,1) = sig(11);
        sigv(flag4h3  ,1) = sig(12);
        sigv(flag4h4  ,1) = sig(13);
        sigv(flag4h5T ,1) = sig(14);
        sigv(flag21   ,1) = sig(15);
        sigv(flag22   ,1) = sig(16);
        sigv(flag23T  ,1) = sig(17);
        
        % now sig vectors that are conformable with gpa and wage vectors
        sigvg   = sigv(flag_wc);
        sigvn   = sigv(flag_bc);
        sigv4s  = sigv(flag4s);
        sigv4h  = sigv(flag4h);
        sigv2yr = sigv(flag2);
        
        % test no zeros in sigv's
        assert(sum(sigvg==0)==0,'sigvg has zeros');
        assert(sum(sigvn==0)==0,'sigvn has zeros');
        assert(sum(sigv4s==0)==0,'sigv4s has zeros');
        assert(sum(sigv4h==0)==0,'sigv4h has zeros');
        assert(sum(sigv2yr==0)==0,'sigv2yr has zeros');

        optionsA=optimset('Disp','off','TolX',5e-4,'LargeScale','off');
        optionsA0=optimset('Disp','off','TolX',5e-4,'LargeScale','off','MaxIter',0,'MaxFunEvals',0);
        [bbtemp]=fminunc('wolslambda_joint',[bstartn;lambdan0start;lambdan1start;bstartg(yndg);lambdag0start;lambdag1start],optionsA,wagen,xn,ydn,abiln,vabiln,nflg,PmajgpaTypen,wageg,xg,ydn,abilg,vabilg,gflg,PmajgpaTypeg,sigvg,sigvn);
        bntemp = bbtemp(1:size(xn,2)+2);
        bgtemp = bbtemp(size(xn,2)+3:end);
        [b4stemp]=fminunc('wolslambda',[bstart4s;lambda4s0start;lambda4s1start],optionsA,grade4s,x4s,yd4s,abil4s,vabil4s,sflg,PmajgpaType4s,sigv4s);
        [b4htemp]=fminunc('wolslambda',[bstart4h;lambda4h0start;lambda4h1start],optionsA,grade4h,x4h,yd4h,abil4h,vabil4h,hflg,PmajgpaType4h,sigv4h);
        [bstart2]=fminunc('wolslambda_2yr',bstart2,optionsA,grade2,x2,abil2,vabil2,PmajgpaType2,sigv2yr);
        lambdaydgstart = 1;
        lambdag0start  = bgtemp(end-1);
        lambdag1start  = bgtemp(end);
        lambdan0start  = bntemp(end-1);
        lambdan1start  = bntemp(end);
        lambda4s0start = b4stemp(end-1);
        lambda4s1start = b4stemp(end);
        lambda4h0start = b4htemp(end-1);
        lambda4h1start = b4htemp(end);
        bstartn        = bntemp(1:end-2);
        bstartg(ydg)   = bstartn(ydn);
        bstartg(yndg)  = bgtemp(1:end-2);
        bstart4s       = b4stemp(1:end-2);
        bstart4h       = b4htemp(1:end-2);

        lambda0start   = [lambdag0start;lambdan0start;lambda4s0start;lambda4h0start];
        lambda1start   = [lambdag1start;lambdan1start;lambda4s1start;lambda4h1start];

        residgNS          = wagegNS-(xgNS(:,yndg)*bstartg(yndg) + lambdaydgstart*(xgNS(:,ydg)*bstartn(ydn))); 
        residgS           = (wagegS-lambdag0start-lambdaydgstart*(xgS(:,ydg)*bstartn(ydn)))/lambdag1start-(xgS(:,yndg)*bstartg(yndg));
        Residg(flag_wcNS) = residgNS;
        Residg(flag_wcS)  = residgS;
        residg            = Residg(flag_wc);
        residgNS          = Residg(flag_wcNS);
        residgS           = Residg(flag_wcS);

        residnNS          = wagenNS-(xnNS*bstartn);
        residnS           = (wagenS-lambdan0start-xnS(:,ydn)*bstartn(ydn))/lambdan1start-(xnS(:,yndn)*bstartn(yndn));
        Residn(flag_bcNS) = residnNS;
        Residn(flag_bcS)  = residnS;
        residn            = Residn(flag_bc);
        residnNS          = Residn(flag_bcNS);
        residnS           = Residn(flag_bcS);

        resid2            = grade2-(x2*bstart2);
        Resid2(flag2)     = resid2;
        resid21           = Resid2(flag21);
        resid22           = Resid2(flag22);
        resid23T          = Resid2(flag23T);

        resid4s12         = grade4s12-(x4s12*bstart4s);
        resid4s3T         = (grade4s3T-lambda4s0start)/lambda4s1start-(x4s3T*bstart4s);
        Resid4s(flag4s12) = resid4s12;
        Resid4s(flag4s3T) = resid4s3T;
        resid4s           = Resid4s(flag4s);
        resid4s1          = Resid4s(flag4s1);
        resid4s2          = Resid4s(flag4s2);
        resid4s3          = Resid4s(flag4s3);
        resid4s4          = Resid4s(flag4s4);
        resid4s5T         = Resid4s(flag4s5T);

        resid4h12         = grade4h12-(x4h12*bstart4h);
        resid4h3T         = (grade4h3T-lambda4h0start)/lambda4h1start-(x4h3T*bstart4h);
        Resid4h(flag4h12) = resid4h12;
        Resid4h(flag4h3T) = resid4h3T;
        resid4h           = Resid4h(flag4h);
        resid4h1          = Resid4h(flag4h1);
        resid4h2          = Resid4h(flag4h2);
        resid4h3          = Resid4h(flag4h3);
        resid4h4          = Resid4h(flag4h4);
        resid4h5T         = Resid4h(flag4h5T);

        isigg (flag_wcNS) = 1/sig(1);
        isigg (flag_wcS)  = 1/sig(2);
        isign (flag_bcNS) = 1/sig(3);
        isign (flag_bcS)  = 1/sig(4);
        isig4s(flag4s1)   = 1/sig(5);
        isig4s(flag4s2)   = 1/sig(6);
        isig4s(flag4s3)   = 1/sig(7);
        isig4s(flag4s4)   = 1/sig(8);
        isig4s(flag4s5T)  = 1/sig(9);
        isig4h(flag4h1)   = 1/sig(10);
        isig4h(flag4h2)   = 1/sig(11);
        isig4h(flag4h3)   = 1/sig(12);
        isig4h(flag4h4)   = 1/sig(13);
        isig4h(flag4h5T)  = 1/sig(14);
        isig2 (flag21)    = 1/sig(15);
        isig2 (flag22)    = 1/sig(16);
        isig2 (flag23T)   = 1/sig(17);

        sig2(j,:)=sig';
        cov2(j,:)=[Delta(1,1) Delta(2,2) Delta(3,3) Delta(4,4) Delta(5,5) Delta(1,2) Delta(1,3) Delta(1,4) Delta(1,5) Delta(2,3) Delta(2,4) Delta(2,5) Delta(3,4) Delta(3,5) Delta(4,5)];

        % disp(['Iteration ',num2str(j),', criterion = ',num2str(max(max(abs(covtemp-Delta))))]);
        j=j+1;
    end

    % recover SEs for lambda functions
    [~,~,~,~,~,hbtemp]  = fminunc('wolslambda_joint',[bstartn;lambdan0start;lambdan1start;bstartg(yndg);lambdag0start;lambdag1start],optionsA,wagen,xn,ydn,abiln,vabiln,nflg,PmajgpaTypen,wageg,xg,ydn,abilg,vabilg,gflg,PmajgpaTypeg,sigvg,sigvn);
    [~,~,~,~,~,h4stemp] = fminunc('wolslambda',[bstart4s;lambda4s0start;lambda4s1start],optionsA,grade4s,x4s,yd4s,abil4s,vabil4s,sflg,PmajgpaType4s,sigv4s);
    [~,~,~,~,~,h4htemp] = fminunc('wolslambda',[bstart4h;lambda4h0start;lambda4h1start],optionsA,grade4h,x4h,yd4h,abil4h,vabil4h,hflg,PmajgpaType4h,sigv4h);
    [~,~,~,~,~,h2temp]  = fminunc('wolslambda_2yr',bstart2,optionsA,grade2,x2,abil2,vabil2,PmajgpaType2,sigv2yr);
    sebbtemp       = sqrt(diag(inv(hbtemp)));
    sebntemp       = sebbtemp(1:size(xn,2)+2);
    sebgtemp       = sebbtemp(size(xn,2)+3:end);
    seb4stemp      = sqrt(diag(inv(h4stemp)));
    seb4htemp      = sqrt(diag(inv(h4htemp)));
    seb2temp       = sqrt(diag(inv(h2temp)));
    sebn           = sebntemp(1:end-2);
    sebg(ydg)      = sebn(ydn);
    sebg(yndg)     = sebgtemp(1:end-2);
    seb4s          = seb4stemp(1:end-2);
    seb4h          = seb4htemp(1:end-2);
    selambdaydgstart = 0;
    selambda0start = [sebgtemp(end-1);sebntemp(end-1);seb4stemp(end-1);seb4htemp(end-1)];
    selambda1start = [sebgtemp(end);sebntemp(end);seb4stemp(end);seb4htemp(end)];

    disp(['Learning estimation took ',num2str(j),' iterations']);
    disp(['criterion at convergence was ',num2str(max(max(abs(covtemp-Delta))))]);
    
    parmsUpdated = v2struct(bstartg, bstartn, lambda0start, lambda1start, lambdaydgstart, lambdag0start, lambdag1start, lambdan0start, lambdan1start, bstart4s, bstart4h, bstart2, lambda4s0start, lambda4s1start, lambda4h0start, lambda4h1start, lambda20start, lambda21start, sig, Delta, BigN, sebg, sebn, seb4s, seb4h, seb2, selambda1start, selambda0start, selambdaydgstart);
end