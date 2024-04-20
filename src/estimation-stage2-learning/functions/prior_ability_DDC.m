function [priorabilstruct,residStruct] = prior_ability_DDC(learnparms,learndata,choicedata,S);
    % Returns a N*T*S by J (nb of outcomes) matrix of prior abilities.
    % The order within each column is: first t (time), then i (individual), then s (heterogeneity type).

    % read in parameters and data
    v2struct(learnparms);
    v2struct(learndata);
    v2struct(choicedata);

    % Create index vectors for later convenience
    ydg      = [18:33];
    ydn      = [18:33];
    yd4s     = [];
    yd4h     = [];
    yndg     = setdiff([1:size(xgS,2)],[18:33]);
    yndn     = setdiff([1:size(xnS,2)],[18:33]);
    ynd4s    = [];
    ynd4h    = [];
    wcNS_idx = [              17 19];
    wcS_idx  = [2 4 7 9 12 14      ];
    wc_idx   = [2 4 7 9 12 14 17 19];
    bcNS_idx = [              16 18];
    bcS_idx  = [1 3 6 8 11 13      ];
    bc_idx   = [1 3 6 8 11 13 16 18];

    % Create flags for later convenience
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

    J=size(Delta,1);
    idelta=Delta\eye(size(Delta));

    residgNS = wagegNS-(xgNS*bstartg);
    residnNS = wagenNS-(xnNS*bstartn);
    residgS  = (wagegS-lambdag0start-xgS(:,ydg)*bstartg(ydg))/lambdag1start-(xgS(:,yndg)*bstartg(yndg));
    residnS  = (wagenS-lambdan0start-xnS(:,ydn)*bstartn(ydn))/lambdan1start-(xnS(:,yndn)*bstartn(yndn));

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

    ClImpsbis        = reshape(ClImps',T,Ntilde*S)';
    Residgbis        = reshape(Residg',T,Ntilde*S)';
    Residnbis        = reshape(Residn',T,Ntilde*S)';
    Resid4sbis       = reshape(Resid4s',T,Ntilde*S)';
    Resid4hbis       = reshape(Resid4h',T,Ntilde*S)';
    Resid2bis        = reshape(Resid2',T,Ntilde*S)';
    yrclbis          = reshape(yrclImps',T,Ntilde*S)';

    abilmat       = zeros(Ntilde*S,J*T);
    abiltmat      = zeros(Ntilde*S,J);
    abilpriormat  = zeros(Ntilde*S,J*T);
    vabilmat      = permute(repmat(Delta,[1 1 T Ntilde*S]),[4 3 2 1]);
    vabiltmat     = permute(repmat(Delta,[1 1 Ntilde*S]),[3 2 1]);
    vabilpriormat = permute(repmat(Delta,[1 1 T Ntilde*S]),[4 3 2 1]);

    for t=1:T
        ClImpst        = ClImpsbis(:,1:t);
        yrclImpst      = yrclbis(:,1:t);

        % time-period-specific flags
        flagt_wcNS = ismember(ClImpst,wcNS_idx);
        flagt_wcS  = ismember(ClImpst,wcS_idx );
        flagt_wc   = ismember(ClImpst,wc_idx  );
        flagt_bcNS = ismember(ClImpst,bcNS_idx);
        flagt_bcS  = ismember(ClImpst,bcS_idx );
        flagt_bc   = ismember(ClImpst,bc_idx  );
        flagt4s12  = (ClImpst>5  & ClImpst<11 & yrclImpst<3);
        flagt4h12  = (ClImpst>10 & ClImpst<16 & yrclImpst<3);
        flagt212   = (ClImpst>0  & ClImpst<6  & yrclImpst<3);
        flagt4s3T  = (ClImpst>5  & ClImpst<11 & yrclImpst>2);
        flagt4h3T  = (ClImpst>10 & ClImpst<16 & yrclImpst>2);
        flagt23T   = (ClImpst>0  & ClImpst<6  & yrclImpst>2);
        flagt4s    = (ClImpst>5  & ClImpst<11);
        flagt4s1   = (ClImpst>5  & ClImpst<11 & yrclImpst==1);
        flagt4s2   = (ClImpst>5  & ClImpst<11 & yrclImpst==2);
        flagt4s3   = (ClImpst>5  & ClImpst<11 & yrclImpst==3);
        flagt4s4   = (ClImpst>5  & ClImpst<11 & yrclImpst==4);
        flagt4s5T  = (ClImpst>5  & ClImpst<11 & yrclImpst>=5);
        flagt4h    = (ClImpst>10 & ClImpst<16);
        flagt4h1   = (ClImpst>10 & ClImpst<16 & yrclImpst==1);
        flagt4h2   = (ClImpst>10 & ClImpst<16 & yrclImpst==2);
        flagt4h3   = (ClImpst>10 & ClImpst<16 & yrclImpst==3);
        flagt4h4   = (ClImpst>10 & ClImpst<16 & yrclImpst==4);
        flagt4h5T  = (ClImpst>10 & ClImpst<16 & yrclImpst>=5);
        flagt2     = (ClImpst>0  & ClImpst<6);
        flagt21    = (ClImpst>0  & ClImpst<6  & yrclImpst==1);
        flagt22    = (ClImpst>0  & ClImpst<6  & yrclImpst==2);

        isiggt  = ones(Ntilde*S,t);
        isignt  = ones(Ntilde*S,t);
        isig4st = ones(Ntilde*S,t);
        isig4ht = ones(Ntilde*S,t);
        isig2t  = ones(Ntilde*S,t);
        isiggt (flagt_wcNS) = 1/sig(1);
        isiggt (flagt_wcS)  = 1/sig(2);
        isignt (flagt_bcNS) = 1/sig(3);
        isignt (flagt_bcS)  = 1/sig(4);
        isig4st(flagt4s1)   = 1/sig(5);
        isig4st(flagt4s2)   = 1/sig(6);
        isig4st(flagt4s3)   = 1/sig(7);
        isig4st(flagt4s4)   = 1/sig(8);
        isig4st(flagt4s5T)  = 1/sig(9);
        isig4ht(flagt4h1)   = 1/sig(10);
        isig4ht(flagt4h2)   = 1/sig(11);
        isig4ht(flagt4h3)   = 1/sig(12);
        isig4ht(flagt4h4)   = 1/sig(13);
        isig4ht(flagt4h5T)  = 1/sig(14);
        isig2t (flagt21)    = 1/sig(15);
        isig2t (flagt22)    = 1/sig(16);
        isig2t (flagt23T)   = 1/sig(17);

        Residgt   = Residgbis(:,1:t);
        Residnt   = Residnbis(:,1:t);
        Resid4st  = Resid4sbis(:,1:t);
        Resid4ht  = Resid4hbis(:,1:t);
        Resid2t   = Resid2bis(:,1:t);

        % We weight by 1/sig(c) before summing the residuals
        tresidgt  = sum(Residgt .*isiggt ,2);
        tresidnt  = sum(Residnt .*isignt ,2);
        tresid4st = sum(Resid4st.*isig4st,2);
        tresid4ht = sum(Resid4ht.*isig4ht,2);
        tresid2t  = sum(Resid2t .*isig2t ,2);

        if t==1
            Csumw=[(flagt_wcNS) (flagt_wcS) (flagt_bcNS) (flagt_bcS) (flagt4s1) (flagt4s2) (flagt4s3) (flagt4s4) (flagt4s5T) (flagt4h1) (flagt4h2) (flagt4h3) (flagt4h4) (flagt4h5T) (flagt21) (flagt22) (flagt23T)];
        else
            Csumw=[sum(flagt_wcNS,2) sum(flagt_wcS,2) sum(flagt_bcNS,2) sum(flagt_bcS,2) sum(flagt4s1,2) sum(flagt4s2,2) sum(flagt4s3,2) sum(flagt4s4,2) sum(flagt4s5T,2) sum(flagt4h1,2) sum(flagt4h2,2) sum(flagt4h3,2) sum(flagt4h4,2) sum(flagt4h5T,2) sum(flagt21,2) sum(flagt22,2) sum(flagt23T,2)];
        end

        i=1;

        for i=1:S*Ntilde
            psit=Csumw(i,:);

            Psi=[psit(1:2)*(1./sig(1:2)) 0 0 0 0; 0 psit(3:4)*(1./sig(3:4)) 0 0 0;  0 0 psit(5:9)*(1./sig(5:9)) 0 0; 0 0 0 psit(10:14)*(1./sig(10:14)) 0; 0 0 0 0 psit(15:17)*(1./sig(15:17))];

            vtempt=(idelta+Psi)\eye(size(idelta));

            temp=(vtempt*([tresidgt(i);tresidnt(i);tresid4st(i);tresid4ht(i);tresid2t(i)]))';

            abiltmat(i,:)=temp;
            vabiltmat(i,:,:)=vtempt;
        end

        abilmat(:,(t-1)*J+1:t*J)=abiltmat;
        vabilmat(:,t,:,:)=vabiltmat;


        if t>1
            abilpriormat(:,(t-1)*J+1:t*J)=abilmat(:,(t-2)*J+1:(t-1)*J);
            vabilpriormat(:,t,:,:)=vabilmat(:,(t-1),:,:);
        end
    end

    abilmat       = reshape(abilmat',J,Ntilde*T*S)';
    abilpriormat  = reshape(abilpriormat',J,Ntilde*T*S)';
    vabilmat      = reshape(permute(vabilmat,[2 1 3 4]),[Ntilde*T*S J J]);
    vabilpriormat = reshape(permute(vabilpriormat,[2 1 3 4]),[Ntilde*T*S J J]);

    prior_ability_S       = abilpriormat(1:N*T,1);
    prior_ability_U       = abilpriormat(1:N*T,2);
    prior_ability_4S      = abilpriormat(1:N*T,3);
    prior_ability_4NS     = abilpriormat(1:N*T,4);
    prior_ability_2       = abilpriormat(1:N*T,5);
    prior_ability_S_vec   = abilpriormat(:,1);
    prior_ability_U_vec   = abilpriormat(:,2);
    prior_ability_4S_vec  = abilpriormat(:,3);
    prior_ability_4NS_vec = abilpriormat(:,4);
    prior_ability_2_vec   = abilpriormat(:,5);

    residStruct=v2struct(Residg,Residn,Resid4s,Resid4h,Resid2);

    priorabilstruct = v2struct(prior_ability_S, prior_ability_U, prior_ability_4S, prior_ability_4NS, prior_ability_2, prior_ability_S_vec, prior_ability_U_vec, prior_ability_4S_vec, prior_ability_4NS_vec, prior_ability_2_vec, vabilpriormat);
end
