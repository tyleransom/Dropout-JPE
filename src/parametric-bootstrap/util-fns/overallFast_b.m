function [Adj,PFricTilde,pgradTilde,Ptemp,utiltemp] = overallFast_b(beta,M,ww,jjj,b,Y,utd,FVstates,sdemog,A,S,data,prabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,D,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2)
    
    offer   = FVstates.otemp;    % whether to consider white-collar alternatives in choice set
    grad4yr = FVstates.gtemp;    % whether to consider graduate alternatives in choice set
    pgflag  = FVstates.gflag;    % whether to return p or 1-p from the graduation probability
    specl1  = FVstates.special1; % is this a "weird" FV term where we don't have any arrival rate entering?
    specl2  = FVstates.special2; % is this a "weird" FV term where we multiply by a negative number?

    % get cumulative schooling to pass to graduation function
    scum_2yr = kron(ones(S,1),data.cum_2yr);
    scum_4yr = kron(ones(S,1),data.cum_4yr);

    % compute offer probabilities conditional on finite dependence path node
    % tic;
    PFric = update_offerprob(BetaFric,Xfric,offer,grad4yr,M,ww);
    % disp(['Time spent updating offer probability: ',num2str(toc),' seconds']);
    
    % initialize choice and grad probabilities (conditional on signal draw)
    Adj   = zeros(size(Y,1),1);
    % tic;
    [sectors,omegatildet1,omegat1] = make_omega_sectors(ww,M(ww,2),jjj,5,data.yrcl,learnparms.sig);
    % disp(['Time spent makeomegasectors: ',num2str(toc),' seconds']);
    if isempty(sectors) % no need to do integration here
        pgrad     = gprob(BetaGrad,Xgrad,scum_2yr,scum_4yr,prabilstruct.prior_ability_4S_vec,prabilstruct.prior_ability_4NS_vec,grad4yr,M,ww);
        [P,utild] = searchconsumpplogit(b,offer,utd,prabilstruct,grad4yr,sdemog,A,S);
        Ptemp = P(:,jjj);
        utiltemp = utild.X2nw;
        if specl1==0
            PFricTilde = PFric;
            if isempty(pgflag)
                pgradTilde = 1;
                Adj = -(beta^M(ww,3)).*PFric.*log(P(:,jjj));
            elseif pgflag==1
                pgradTilde = pgrad;
                Adj = -(beta^M(ww,3)).*PFric.*pgrad.*log(P(:,jjj));
                %summarize(pgrad);
            elseif pgflag==0
                pgradTilde = 1-pgrad;
                Adj = -(beta^M(ww,3)).*PFric.*(1-pgrad).*log(P(:,jjj));
                %summarize(1-pgrad);
            end
        else
            pgradTilde = 0;
            if all(offer)==1 && specl2==0
                PFricTilde = PFric-1;
                Adj = -(beta^M(ww,3)).*(PFric-1).*log(P(:,jjj));
            elseif all(offer)==1 && specl2==1
                PFricTilde = 1;
                Adj = -(beta^M(ww,3)).*log(P(:,jjj));
            elseif all(offer)==0
                PFricTilde = PFric;
                Adj = -(beta^M(ww,3)).*PFric.*log(P(:,jjj));
            end
         end
    else
        draws = zeros(size(prabilstruct.abilpriormat,1),numel(sectors),D);
        Ptemp = zeros(size(utd.X2nw,1),1);
        utiltemp = zeros(size(utd.X2nw));
        for d=1:D
            %tic;
            if length(sectors)==2
                draws = mvnrndcond([prabilstruct.abilpriormat(:,sectors)],[permute(prabilstruct.vabilpriormat(:,sectors(1),sectors(1)),[2 3 1]) permute(prabilstruct.vabilpriormat(:,sectors(1),sectors(2)),[2 3 1]); permute(prabilstruct.vabilpriormat(:,sectors(1),sectors(2)),[2 3 1]) permute(prabilstruct.vabilpriormat(:,sectors(2),sectors(2)),[2 3 1])]);
            elseif length(sectors)==1
                draws = normrnd(prabilstruct.abilpriormat(:,sectors),squeeze(permute(prabilstruct.vabilpriormat(:,sectors(1),sectors(1)),[2 3 1])));
            end
            %disp(['Time spent making one draw from ability: ',num2str(toc),' seconds']);
            
            % tic;
            % compute posterior ability
            postabil = postabil_combined(prabilstruct.vabilpriormat,omegatildet1,data.ideltaMat,prabilstruct.Psipriormat,prabilstruct.abilpriormat,omegat1,draws,sectors);
            % disp(['Time spent updating ability signal for one draw: ',num2str(toc),' seconds']);
            
            % update prior ability with the new (future, realized) posterior ability
            newprabilstruct.prior_ability_S_vec   = postabil(:,1);
            newprabilstruct.prior_ability_U_vec   = postabil(:,2);
            newprabilstruct.prior_ability_4S_vec  = postabil(:,3);
            newprabilstruct.prior_ability_4NS_vec = postabil(:,4);
            newprabilstruct.prior_ability_2_vec   = postabil(:,5);
            % compute probabilities that are functions of ability
            % tic;
            pgrad=gprob(BetaGrad,Xgrad,scum_2yr,scum_4yr,newprabilstruct.prior_ability_4S_vec,newprabilstruct.prior_ability_4NS_vec,grad4yr,M,ww);
            % disp(['Time spent computing grad probability for one draw: ',num2str(toc),' seconds']);
            %tic;
            [P,utild] = searchconsumpplogit(b,offer,utd,newprabilstruct,grad4yr,sdemog,A,S);
            Ptemp = Ptemp + (1/D).*P(:,jjj);
            utiltemp = utiltemp + (1/D).*utild.X2nw;
            %disp(['Time spent computing choice probability for one draw: ',num2str(toc),' seconds']);
            if specl1==0
                PFricTilde = PFric;
                if isempty(pgflag)
                    pgradTilde = 1;
                    Adj = Adj-(beta^M(ww,3)).*PFric.*(1/D).*log(P(:,jjj));
                elseif pgflag==1
                    pgradTilde = pgrad;
                    Adj = Adj-(beta^M(ww,3)).*PFric.*(1/D).*pgrad.*log(P(:,jjj));
                    summarize(squeeze(pgrad(:,:,1)));
                elseif pgflag==0
                    pgradTilde = 1-pgrad;
                    Adj = Adj-(beta^M(ww,3)).*PFric.*(1/D).*(1-pgrad).*log(P(:,jjj));
                    summarize(squeeze(1-pgrad(:,:,1)));
                end
            else
                pgradTilde = 0;
                if all(offer)==1 && specl2==0
                    PFricTilde = PFric-1;
                    Adj = Adj-(beta^M(ww,3)).*(PFric-1).*(1/D).*log(P(:,jjj));
                elseif all(offer)==1 && specl2==1
                    PFricTilde = 1;
                    Adj = Adj-(beta^M(ww,3)).*(1/D).*log(P(:,jjj));
                elseif all(offer)==0
                    PFricTilde = PFric;
                    Adj = Adj-(beta^M(ww,3)).*PFric.*(1/D).*log(P(:,jjj));
                end
             end
        end
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CODE BELOW THIS LINE CONSISTS OF FUNCTIONS WHICH ARE DEPENDENT ON CALCULATIONS ABOVE THIS LINE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CODE TO UPDATE SIGNALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [sectors,omegatildet1,omegat1] = make_omega_sectors(zero_choice,prev_choice,current_choice,J,yrcl,sig)
        % set up \Omega_{it+1} matrix based on current/previous choice combination
        omegat1 = zeros(size(yrcl,1),5,5);
        for j=1:J 
            omegatildet1(:,j) = omegat1(:,j,j); 
        end

        switch current_choice
        case {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19} % we only hit this on the t+1 node of the H-j-H path, which means we don't need to integrate at all
            sectors = [];
        case 20 %home
            switch prev_choice % i.e. we are on t+1 node of j-H-H path or t+2 node of H-j-H path
            case {2,4} %white collar while in 2yr college
                omegat1(:,1,1) = 1/sig(2);
                omegat1(:,5,5) = (yrcl==0).*(1/sig(15))+(yrcl==1).*(1/sig(16))+(yrcl>=2).*(1/sig(17)); % stagger by one period because future decision is 2yrFT
                for j=1:J 
                    omegatildet1(:,j) = omegat1(:,j,j); 
                end
                sectors =[1 5];
            case {1,3} %blue collar while in 2yr college
                omegat1(:,2,2) = 1/sig(4);
                omegat1(:,5,5) = (yrcl==0).*(1/sig(15))+(yrcl==1).*(1/sig(16))+(yrcl>=2).*(1/sig(17)); % stagger by one period because future decision is 2yrFT
                for j=1:J 
                    omegatildet1(:,j) = omegat1(:,j,j); 
                end    
                sectors = [2 5];
            case 5 %2yr college only
                omegat1(:,5,5) = (yrcl==0).*(1/sig(16))+(yrcl==1).*(1/sig(16))+(yrcl>=2).*(1/sig(17)); % stagger by one period because future decision is 2yrFT
                for j=1:J 
                    omegatildet1(:,j) = omegat1(:,j,j); 
                end
                sectors = 5;
            case {7,9} %white collar while in 4yr science major
                omegat1(:,1,1) = 1/sig(2);
                omegat1(:,3,3) = (yrcl==0).*(1/sig(5))+(yrcl==1).*(1/sig(6))+(yrcl==2).*(1/sig(7))+(yrcl==3).*(1/sig(8))+(yrcl>=4).*(1/sig(9)); % stagger by one period because future decision is 4yrSFT
                for j=1:J 
                    omegatildet1(:,j) = omegat1(:,j,j); 
                end
                sectors = [1 3];
            case {6,8} %blue collar while in 4yr science major
                omegat1(:,2,2) = 1/sig(4);
                omegat1(:,3,3) = (yrcl==0).*(1/sig(5))+(yrcl==1).*(1/sig(6))+(yrcl==2).*(1/sig(7))+(yrcl==3).*(1/sig(8))+(yrcl>=4).*(1/sig(9)); % stagger by one period because future decision is 4yrSFT
                for j=1:J 
                    omegatildet1(:,j) = omegat1(:,j,j); 
                end
                sectors = [2 3];    
            case 10 %4yr science major only
                omegat1(:,3,3) = (yrcl==0).*(1/sig(5))+(yrcl==1).*(1/sig(6))+(yrcl==2).*(1/sig(7))+(yrcl==3).*(1/sig(8))+(yrcl>=4).*(1/sig(9)); % stagger by one period because future decision is 4yrSFT
                for j=1:J 
                    omegatildet1(:,j) = omegat1(:,j,j); 
                end
                sectors = 3;
            case {12,14} %white collar while in 4yr humanities major
                omegat1(:,1,1) = 1/sig(2);
                omegat1(:,4,4) = (yrcl==0).*(1/sig(10))+(yrcl==1).*(1/sig(11))+(yrcl==2).*(1/sig(12))+(yrcl==3).*(1/sig(13))+(yrcl>=4).*(1/sig(14)); % stagger by one period because future decision is 4yrNSFT
                for j=1:J 
                    omegatildet1(:,j) = omegat1(:,j,j); 
                end
                sectors = [1 4];
            case {11,13} %blue collar while in 4yr humanities major
                omegat1(:,2,2) = 1/sig(4);
                omegat1(:,4,4) = (yrcl==0).*(1/sig(10))+(yrcl==1).*(1/sig(11))+(yrcl==2).*(1/sig(12))+(yrcl==3).*(1/sig(13))+(yrcl>=4).*(1/sig(14)); % stagger by one period because future decision is 4yrNSFT
                for j=1:J 
                    omegatildet1(:,j) = omegat1(:,j,j); 
                end
                sectors = [2 4];    
            case 15 %4yr humanities major only
                omegat1(:,4,4) = (yrcl==0).*(1/sig(10))+(yrcl==1).*(1/sig(11))+(yrcl==2).*(1/sig(12))+(yrcl==3).*(1/sig(13))+(yrcl>=4).*(1/sig(14)); % stagger by one period because future decision is 4yrNSFT
                for j=1:J 
                    omegatildet1(:,j) = omegat1(:,j,j); 
                end
                sectors = 4;
            case {17,19} %white collar and not graduated
                omegat1(:,1,1) = (1/sig(1));
                for j=1:J 
                    omegatildet1(:,j) = omegat1(:,j,j); 
                end
                sectors = 1;
            case {16,18} %blue collar and not graduated
                omegat1(:,2,2) = (1/sig(3));
                for j=1:J 
                    omegatildet1(:,j) = omegat1(:,j,j); 
                end
                sectors = 1;    
            case 20 % here we are on t+2 node of j-H-H path
                switch zero_choice
                case {2,4} %white collar while in 2yr college
                    omegat1(:,1,1) = 1/sig(2);
                    omegat1(:,5,5) = (yrcl==0).*(1/sig(15))+(yrcl==1).*(1/sig(16))+(yrcl>=2).*(1/sig(17)); % stagger by one period because future decision is 2yrFT
                    for j=1:J 
                        omegatildet1(:,j) = omegat1(:,j,j); 
                    end
                    sectors =[1 5];
                case {1,3} %blue collar while in 2yr college
                    omegat1(:,2,2) = 1/sig(4);
                    omegat1(:,5,5) = (yrcl==0).*(1/sig(15))+(yrcl==1).*(1/sig(16))+(yrcl>=2).*(1/sig(17)); % stagger by one period because future decision is 2yrFT
                    for j=1:J 
                        omegatildet1(:,j) = omegat1(:,j,j); 
                    end    
                    sectors = [2 5];
                case 5 %2yr college only
                    omegat1(:,5,5) = (yrcl==0).*(1/sig(16))+(yrcl==1).*(1/sig(16))+(yrcl>=2).*(1/sig(17)); % stagger by one period because future decision is 2yrFT
                    for j=1:J 
                        omegatildet1(:,j) = omegat1(:,j,j); 
                    end
                    sectors = 5;
                case {7,9} %white collar while in 4yr science major
                    omegat1(:,1,1) = 1/sig(2);
                    omegat1(:,3,3) = (yrcl==0).*(1/sig(5))+(yrcl==1).*(1/sig(6))+(yrcl==2).*(1/sig(7))+(yrcl==3).*(1/sig(8))+(yrcl>=4).*(1/sig(9)); % stagger by one period because future decision is 4yrSFT
                    for j=1:J 
                        omegatildet1(:,j) = omegat1(:,j,j); 
                    end
                    sectors = [1 3];
                case {6,8} %blue collar while in 4yr science major
                    omegat1(:,2,2) = 1/sig(4);
                    omegat1(:,3,3) = (yrcl==0).*(1/sig(5))+(yrcl==1).*(1/sig(6))+(yrcl==2).*(1/sig(7))+(yrcl==3).*(1/sig(8))+(yrcl>=4).*(1/sig(9)); % stagger by one period because future decision is 4yrSFT
                    for j=1:J 
                        omegatildet1(:,j) = omegat1(:,j,j); 
                    end
                    sectors = [2 3];    
                case 10 %4yr science major only
                    omegat1(:,3,3) = (yrcl==0).*(1/sig(5))+(yrcl==1).*(1/sig(6))+(yrcl==2).*(1/sig(7))+(yrcl==3).*(1/sig(8))+(yrcl>=4).*(1/sig(9)); % stagger by one period because future decision is 4yrSFT
                    for j=1:J 
                        omegatildet1(:,j) = omegat1(:,j,j); 
                    end
                    sectors = 3;
                case {12,14} %white collar while in 4yr humanities major
                    omegat1(:,1,1) = 1/sig(2);
                    omegat1(:,4,4) = (yrcl==0).*(1/sig(10))+(yrcl==1).*(1/sig(11))+(yrcl==2).*(1/sig(12))+(yrcl==3).*(1/sig(13))+(yrcl>=4).*(1/sig(14)); % stagger by one period because future decision is 4yrNSFT
                    for j=1:J 
                        omegatildet1(:,j) = omegat1(:,j,j); 
                    end
                    sectors = [1 4];
                case {11,13} %blue collar while in 4yr humanities major
                    omegat1(:,2,2) = 1/sig(4);
                    omegat1(:,4,4) = (yrcl==0).*(1/sig(10))+(yrcl==1).*(1/sig(11))+(yrcl==2).*(1/sig(12))+(yrcl==3).*(1/sig(13))+(yrcl>=4).*(1/sig(14)); % stagger by one period because future decision is 4yrNSFT
                    for j=1:J 
                        omegatildet1(:,j) = omegat1(:,j,j); 
                    end
                    sectors = [2 4];    
                case 15 %4yr humanities major only
                    omegat1(:,4,4) = (yrcl==0).*(1/sig(10))+(yrcl==1).*(1/sig(11))+(yrcl==2).*(1/sig(12))+(yrcl==3).*(1/sig(13))+(yrcl>=4).*(1/sig(14)); % stagger by one period because future decision is 4yrNSFT
                    for j=1:J 
                        omegatildet1(:,j) = omegat1(:,j,j); 
                    end
                    sectors = 4;
                case {17,19} %white collar and not graduated
                    omegat1(:,1,1) = (1/sig(1));
                    for j=1:J 
                        omegatildet1(:,j) = omegat1(:,j,j); 
                    end
                    sectors = 1;
                case {16,18} %blue collar and not graduated
                    omegat1(:,2,2) = (1/sig(3));
                    for j=1:J 
                        omegatildet1(:,j) = omegat1(:,j,j); 
                    end
                    sectors = 1;    
                case 20 % here we are on t+2 node of j-H-H path
                    sectors = [];
                end
            end
        otherwise
            error('Error in assigning future choice!')
        end
    end




    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CODE TO UPDATE ABILITY WITH FUTURE SIGNALS (FOR INTEGRATION OF ABILITY) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [postabil] = postabil_combined(vabilpriormat,omegatildet1,ideltaMat,Psipriormat,abilpriormat,omegat1,ddd,sectors)
        %first part of postabil:
        V = postabil1(vabilpriormat,omegatildet1);
        
        %second part of postabil:
        abvec = postabil2(ideltaMat,Psipriormat,abilpriormat);
        
        %third part of postabil:
        abvec2 = postabil3(omegat1,ddd,sectors);
        
        %combine all parts:
        postabil = postabilall(V,abvec,abvec2);
                
        function [V]=postabil1(V,omeg)
            J = 5;
            for j=1:J
                cof = omeg(:,j);
                V = V - bsxfun(@times,cof./(1+cof.*V(:,j,j)),bsxfun(@times,V(:,j,:),V(:,:,j)));
            end
        end
        
        function [A]=postabil2(idelta,Psiprior,abilprior)
            J = 5;
            A = zeros(size(abilprior,1),J);
            for j=1:J
                A = A + bsxfun(@times,idelta(:,:,j)+Psiprior(:,:,j),abilprior(:,j));
            end
        end
        
        function [A2] = postabil3(ot1,draws,sectors) %sectors should indicate whatever sectors are signaling, e.g. [1 5] for 2yr + white collar, [1 3] for sci + white collar, etc.
            J = 5;
            A2 = zeros(size(ot1,1),J);
            signaldraws = zeros(size(ot1,1),J);
            signaldraws(:,sectors) = draws;
            for j=1:J
                A2 = A2 + bsxfun(@times,ot1(:,:,j),signaldraws(:,j));
            end
        end
        
        function [postabil] = postabilall(V,A,A2)
            J = 5;
            postabil = zeros(size(A2,1),J);
            for j=1:J
                postabil = postabil + bsxfun(@times,V(:,:,j),A(:,j)+A2(:,j));
            end
        end
    end
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WHITE COLLAR OFFER PROBABILITIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    function [lambda]=update_offerprob(bo,Xo,o,g,M,ww)
        a = M(ww,3);
        j = M(ww,2);
        Xo(:,2)= Xo(:,2)+a;
        Xo(:,3)=(g==1);
        if ismember(j,[2 4 7 9 12 14 17 19]); 
            p = 1;
        else
            p = exp(Xo*bo)./(1+exp(Xo*bo));
        end
        lambda = (o==1).*p + (o==0).*(1-p);
    end



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GRAD PROBABILITIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    function [pgrad]=gprob(b,X,dc2,dc4,a4s,a4h,g,M,ww)
        j       = ww;
        dc2     = dc2;
        dc4     = dc4;
        cs      = dc2+dc4;
        X(:,11) = dc2==0;
        X(:,12) = dc2>=2;
        X(:,13) = dc4==2;
        X(:,14) = dc4==3;
        X(:,15) = dc4==4;
        X(:,16) = dc4==5;
        X(:,17) = dc4>=6;
        X(:,18) = (dc2==0).*(dc4==2);
        X(:,19) = (dc2==0).*(dc4==4);
        X(:,20) = (dc2==0).*(dc4==5);
        X(:,21) = (dc2==0).*(dc4>=6);
        X(:,22) = ismember(j,[6:10] );
        X(:,23) = ismember(j,[6:10] ).*a4s;
        X(:,24) = ismember(j,[11:15]).*a4h;
        X(:,25) = ismember(j,[3 4 8 9 13 14]);
        X(:,26) = ismember(j,[1 2 6 7 11 12]); 
        if j<6
            pgrad=zeros(size(X,1),1);
        elseif j>5 && j<16
            pgrad = exp(X*b)./(1+exp(X*b));
            pgrad(cs<2) = 0;
        elseif (j>15 && j<21) && ~all(g)
            pgrad=zeros(size(X,1),1);
        else
            pgrad=ones(size(X,1),1);
        end
    end



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LOGIT CHOICE PROBABILITIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    function [P,utd]=searchconsumpplogit(b,offer,utd,prabilstr,grad_4yr,sdemog,A,S)
        utd = updateflows(data,prabilstr,0,A,S,intrate,M,ww);

        P = zeros(size(offer,1),20);
        alpha    = b(1);
        galpha   = b(2);
        b2flg    = 2+[1:utd.number2];
        b4sflg   = 2+[1+utd.number2:utd.number2+utd.number4s];
        b4nsflg  = 2+[1+utd.number2+utd.number4s:utd.number2+utd.number4s+utd.number4ns];
        bwptflg  = 2+[1+utd.number2+utd.number4s+utd.number4ns:utd.number2+utd.number4s+utd.number4ns+utd.numberpt];
        bgwptflg = 2+[1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt:utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt]; 
        bwftflg  = 2+[1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt:utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft];
        bgwftflg = 2+[1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft:utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft+utd.numbergft];
        bwcflg   = 2+[1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft+utd.numbergft:utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft+utd.numbergft+utd.numberwc];
        bgwcflg  = 2+[1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft+utd.numbergft+utd.numberwc:utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft+utd.numbergft+utd.numberwc+utd.numbergwc];

        b2        = b(b2flg);
        b2temp    = [b2(1:sdemog+3);0;b2(sdemog+4:end-7);0;b2(end-6:end)];% first 0: consumption; second 0: white_collar; third 0: work pref type
        b4s       = b(b4sflg);
        b4stemp   = [b4s(1:sdemog+3);0;b4s(sdemog+4:end-7);0;b4s(end-6:end)];
        b4ns      = b(b4nsflg);
        b4nstemp  = [b4ns(1:sdemog+3);0;b4ns(sdemog+4:end-7);0;b4ns(end-6:end)];
        bwpt      = b(bwptflg);
        bwpttemp  = [bwpt(1:sdemog);0;bwpt(sdemog+1:sdemog+2);0;bwpt(sdemog+3:end-3);0;0;0;0;bwpt(end-2:end)];% first two 0s: academic ability, consumption; second four 0s: workPT, workFT, workPT*white_collar, workFT*white_collar
        bwft      = b(bwftflg);
        bwfttemp  = [bwft(1:sdemog);0;bwft(sdemog+1:sdemog+2);0;bwft(sdemog+3:end-3);0;0;0;0;0;bwft(end-2:end)];% first two 0s: academic ability, consumption; second 5 0s: white_collar, workPT, workFT, wPT*WC, wFT*WC
        bwc       = b(bwcflg);
        bwctemp   = [bwc(1:sdemog);0;0;0;0;bwc(sdemog+1:end-3);0;0;0;0;0;bwc(end-2:end)];% first four 0s: academic ability, accum. debt (and squared), consumption; second 5 0s: white_collar, workPT, workFT, wPT*WC, wFT*WC 

        bgwpt     = b(bgwptflg);
        bgwpttemp = bgwpt(1:10);
        bgwpttflg = find(bgwpttemp~=0);
        bgwft     = b(bgwftflg);
        bgwfttemp = bgwft(1:10);
        bgwfttflg = find(bgwfttemp~=0);
        bgwc      = b(bgwcflg);
        bgwctemp  = bgwc(1:10);
        bgwctflg  = find(bgwctemp~=0);

        % indices to flag consumption and non-consumption covariates in matrices
        cidx  = sdemog+4;
        gcidx = 11;
        
        % "utility" for 2-year college:
        vng2ftbc = (utd.X2ftbc*(b2temp+bwfttemp        )+utd.X2ftbc(:,cidx)*alpha);
        vng2ftwc = (utd.X2ftwc*(b2temp+bwfttemp+bwctemp)+utd.X2ftwc(:,cidx)*alpha);
        vng2ptbc = (utd.X2ptbc*(b2temp+bwpttemp        )+utd.X2ptbc(:,cidx)*alpha);
        vng2ptwc = (utd.X2ptwc*(b2temp+bwpttemp+bwctemp)+utd.X2ptwc(:,cidx)*alpha);
        vng2     = (utd.X2nw*(  b2temp                 )+utd.X2nw(  :,cidx)*alpha);

        % "utility" for 4-year college: Science majors
        vng4sftbc = (utd.X4sftbc*(b4stemp+bwfttemp        )+utd.X4sftbc(:,cidx)*alpha);
        vng4sftwc = (utd.X4sftwc*(b4stemp+bwfttemp+bwctemp)+utd.X4sftwc(:,cidx)*alpha);
        vng4sptbc = (utd.X4sptbc*(b4stemp+bwpttemp        )+utd.X4sptbc(:,cidx)*alpha);
        vng4sptwc = (utd.X4sptwc*(b4stemp+bwpttemp+bwctemp)+utd.X4sptwc(:,cidx)*alpha);
        vng4s     = (utd.X4snw*(  b4stemp                 )+utd.X4snw(  :,cidx)*alpha);

        % Non-Science majors
        vng4nsftbc = (utd.X4nsftbc*(b4nstemp+bwfttemp        )+utd.X4nsftbc(:,cidx)*alpha);
        vng4nsftwc = (utd.X4nsftwc*(b4nstemp+bwfttemp+bwctemp)+utd.X4nsftwc(:,cidx)*alpha);
        vng4nsptbc = (utd.X4nsptbc*(b4nstemp+bwpttemp        )+utd.X4nsptbc(:,cidx)*alpha);
        vng4nsptwc = (utd.X4nsptwc*(b4nstemp+bwpttemp+bwctemp)+utd.X4nsptwc(:,cidx)*alpha);
        vng4ns     = (utd.X4nsnw*(  b4nstemp                 )+utd.X4nsnw(  :,cidx)*alpha);

        % "utility" for working
        vngwptbc = (utd.Xngwptbc*(bwpttemp        )+utd.Xngwptbc(:,cidx)*alpha);
        vngwptwc = (utd.Xngwptwc*(bwpttemp+bwctemp)+utd.Xngwptwc(:,cidx)*alpha);
        vngwftbc = (utd.Xngwftbc*(bwfttemp        )+utd.Xngwftbc(:,cidx)*alpha);
        vngwftwc = (utd.Xngwftwc*(bwfttemp+bwctemp)+utd.Xngwftwc(:,cidx)*alpha);

        % "utility" for grad school 
        vgwptbc = (utd.Xngwptbc*( bwpttemp        )+utd.Xgwptbc(:,bgwpttflg)*(bgwpttemp         )+utd.Xgwptbc( :,gcidx)*galpha);
        vgwptwc = (utd.Xngwptwc*( bwpttemp+bwctemp)+utd.Xgwptwc(:,bgwpttflg)*(bgwpttemp+bgwctemp)+utd.Xgwptwc( :,gcidx)*galpha);
        vgwftbc = (utd.Xngwftbc*( bwfttemp        )+utd.Xgwftbc(:,bgwfttflg)*(bgwfttemp         )+utd.Xgwftbc( :,gcidx)*galpha);
        vgwftwc = (utd.Xngwftwc*( bwfttemp+bwctemp)+utd.Xgwftwc(:,bgwfttflg)*(bgwfttemp+bgwctemp)+utd.Xgwftwc( :,gcidx)*galpha);

        %% Compute logit probabilities
        % Part 1a: non-grad but no white collar offer
        log_dem_ngno = log(1+exp(vng2ftbc)+exp(vng2ptbc)+exp(vng2)+exp(vng4sftbc)+exp(vng4sptbc)+exp(vng4s)+exp(vng4nsftbc)+exp(vng4nsptbc)+exp(vng4ns)+exp(vngwptbc)+exp(vngwftbc));
        log_p2ftbc_ngno   = vng2ftbc  -log_dem_ngno; %alt 1
        log_p2ptbc_ngno   = vng2ptbc  -log_dem_ngno; %alt 3
        log_p2_ngno       = vng2      -log_dem_ngno; %alt 5
        log_p4sftbc_ngno  = vng4sftbc -log_dem_ngno; %alt 6
        log_p4sptbc_ngno  = vng4sptbc -log_dem_ngno; %alt 8
        log_p4s_ngno      = vng4s     -log_dem_ngno; %alt 10
        log_p4nsftbc_ngno = vng4nsftbc-log_dem_ngno; %alt 11
        log_p4nsptbc_ngno = vng4nsptbc-log_dem_ngno; %alt 13
        log_p4ns_ngno     = vng4ns    -log_dem_ngno; %alt 15
        log_pwptbc_ngno   = vngwptbc  -log_dem_ngno; %alt 16
        log_pwftbc_ngno   = vngwftbc  -log_dem_ngno; %alt 18
        log_ph_ngno       =           -log_dem_ngno; %alt 20
        P(grad_4yr==0 & offer==0,[1 3 5 6 8 10 11 13 15 16 18 20]) = cat(2,exp(log_p2ftbc_ngno  (grad_4yr==0 & offer==0)),... %alt 1
                                                                           exp(log_p2ptbc_ngno  (grad_4yr==0 & offer==0)),... %alt 3
                                                                           exp(log_p2_ngno      (grad_4yr==0 & offer==0)),... %alt 5
                                                                           exp(log_p4sftbc_ngno (grad_4yr==0 & offer==0)),... %alt 6
                                                                           exp(log_p4sptbc_ngno (grad_4yr==0 & offer==0)),... %alt 8
                                                                           exp(log_p4s_ngno     (grad_4yr==0 & offer==0)),... %alt 10
                                                                           exp(log_p4nsftbc_ngno(grad_4yr==0 & offer==0)),... %alt 11
                                                                           exp(log_p4nsptbc_ngno(grad_4yr==0 & offer==0)),... %alt 13
                                                                           exp(log_p4ns_ngno    (grad_4yr==0 & offer==0)),... %alt 15
                                                                           exp(log_pwptbc_ngno  (grad_4yr==0 & offer==0)),... %alt 16
                                                                           exp(log_pwftbc_ngno  (grad_4yr==0 & offer==0)),... %alt 18
                                                                           exp(log_ph_ngno      (grad_4yr==0 & offer==0)));   %alt 20

        % Part 1b: non-grad but received white collar offer
        log_dem_ngof = log(1+exp(vng2ftbc)+exp(vng2ftwc)+exp(vng2ptbc)+exp(vng2ptwc)+exp(vng2)+exp(vng4sftbc)+exp(vng4sftwc)+exp(vng4sptbc)+exp(vng4sptwc)+exp(vng4s)+exp(vng4nsftbc)+exp(vng4nsftwc)+exp(vng4nsptbc)+exp(vng4nsptwc)+exp(vng4ns)+exp(vngwptbc)+exp(vngwptwc)+exp(vngwftbc)+exp(vngwftwc));
        log_p2ftbc_ngof   = vng2ftbc  -log_dem_ngof; %alt  1
        log_p2ftwc_ngof   = vng2ftwc  -log_dem_ngof; %alt  2
        log_p2ptbc_ngof   = vng2ptbc  -log_dem_ngof; %alt  3
        log_p2ptwc_ngof   = vng2ptwc  -log_dem_ngof; %alt  4
        log_p2_ngof       = vng2      -log_dem_ngof; %alt  5
        log_p4sftbc_ngof  = vng4sftbc -log_dem_ngof; %alt  6
        log_p4sftwc_ngof  = vng4sftwc -log_dem_ngof; %alt  7
        log_p4sptbc_ngof  = vng4sptbc -log_dem_ngof; %alt  8
        log_p4sptwc_ngof  = vng4sptwc -log_dem_ngof; %alt  9
        log_p4s_ngof      = vng4s     -log_dem_ngof; %alt 10
        log_p4nsftbc_ngof = vng4nsftbc-log_dem_ngof; %alt 11
        log_p4nsftwc_ngof = vng4nsftwc-log_dem_ngof; %alt 12
        log_p4nsptbc_ngof = vng4nsptbc-log_dem_ngof; %alt 13
        log_p4nsptwc_ngof = vng4nsptwc-log_dem_ngof; %alt 14
        log_p4ns_ngof     = vng4ns    -log_dem_ngof; %alt 15
        log_pwptbc_ngof   = vngwptbc  -log_dem_ngof; %alt 16
        log_pwptwc_ngof   = vngwptwc  -log_dem_ngof; %alt 17
        log_pwftbc_ngof   = vngwftbc  -log_dem_ngof; %alt 18
        log_pwftwc_ngof   = vngwftwc  -log_dem_ngof; %alt 19
        log_ph_ngof       =           -log_dem_ngof; %alt 20
        P(grad_4yr==0 & offer==1,1:20) = cat(2,exp(log_p2ftbc_ngof  (grad_4yr==0 & offer==1)),... %alt  1
                                               exp(log_p2ftwc_ngof  (grad_4yr==0 & offer==1)),... %alt  2
                                               exp(log_p2ptbc_ngof  (grad_4yr==0 & offer==1)),... %alt  3
                                               exp(log_p2ptwc_ngof  (grad_4yr==0 & offer==1)),... %alt  4
                                               exp(log_p2_ngof      (grad_4yr==0 & offer==1)),... %alt  5
                                               exp(log_p4sftbc_ngof (grad_4yr==0 & offer==1)),... %alt  6
                                               exp(log_p4sftwc_ngof (grad_4yr==0 & offer==1)),... %alt  7
                                               exp(log_p4sptbc_ngof (grad_4yr==0 & offer==1)),... %alt  8
                                               exp(log_p4sptwc_ngof (grad_4yr==0 & offer==1)),... %alt  9
                                               exp(log_p4s_ngof     (grad_4yr==0 & offer==1)),... %alt 10
                                               exp(log_p4nsftbc_ngof(grad_4yr==0 & offer==1)),... %alt 11
                                               exp(log_p4nsftwc_ngof(grad_4yr==0 & offer==1)),... %alt 12
                                               exp(log_p4nsptbc_ngof(grad_4yr==0 & offer==1)),... %alt 13
                                               exp(log_p4nsptwc_ngof(grad_4yr==0 & offer==1)),... %alt 14
                                               exp(log_p4ns_ngof    (grad_4yr==0 & offer==1)),... %alt 15
                                               exp(log_pwptbc_ngof  (grad_4yr==0 & offer==1)),... %alt 16
                                               exp(log_pwptwc_ngof  (grad_4yr==0 & offer==1)),... %alt 17
                                               exp(log_pwftbc_ngof  (grad_4yr==0 & offer==1)),... %alt 18
                                               exp(log_pwftwc_ngof  (grad_4yr==0 & offer==1)),... %alt 19
                                               exp(log_ph_ngof      (grad_4yr==0 & offer==1)));   %alt 20

        % Part 2a: graduated but no white collar offer
        log_dem_grno     = log(1+exp(vgwptbc)+exp(vgwftbc));
        log_pwptbc_grno  = vgwptbc-log_dem_grno; %alt 16
        log_pwftbc_grno  = vgwftbc-log_dem_grno; %alt 18
        log_ph_grno      =        -log_dem_grno; %alt 20
        P(grad_4yr==1 & offer==0,[16 18 20]) = cat(2,exp(log_pwptbc_grno (grad_4yr==1 & offer==0)),... %alt 16
                                                     exp(log_pwftbc_grno (grad_4yr==1 & offer==0)),... %alt 18
                                                     exp(log_ph_grno     (grad_4yr==1 & offer==0)));   %alt 20




        % Part 2b: graduated and received white collar offer
        log_dem_grof     = log(1+exp(vgwptbc)+exp(vgwptwc)+exp(vgwftbc)+exp(vgwftwc));
        log_pwptbc_grof  = vgwptbc-log_dem_grof; %alt 16
        log_pwptwc_grof  = vgwptwc-log_dem_grof; %alt 17
        log_pwftbc_grof  = vgwftbc-log_dem_grof; %alt 18
        log_pwftwc_grof  = vgwftwc-log_dem_grof; %alt 19
        log_ph_grof      =        -log_dem_grof; %alt 20
        P(grad_4yr==1 & offer==1,16:20) = cat(2,exp(log_pwptbc_grof (grad_4yr==1 & offer==1)),... %alt 16
                                                exp(log_pwptwc_grof (grad_4yr==1 & offer==1)),... %alt 17
                                                exp(log_pwftbc_grof (grad_4yr==1 & offer==1)),... %alt 18
                                                exp(log_pwftwc_grof (grad_4yr==1 & offer==1)),... %alt 19
                                                exp(log_ph_grof     (grad_4yr==1 & offer==1)));   %alt 20
        end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FLOW UTILITIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    function Utils = updateflows(data,prabstr,discfact,A,S,intrate,M,ww);
        a=M(ww,3);
        e=M(ww,6);
        wce=M(ww,7);
        c2=M(ww,4);
        c4=M(ww,5);
        %tic
        consumps = createconsump(data,prabstr,learnparms,Clb,CRRA,AR1parms,S);
        %disp(['Time spent on consumption function: ',num2str(toc),' seconds']);
        N = data.N;
        prior_ability_2_vec   = prabstr.prior_ability_2_vec;
        prior_ability_4S_vec  = prabstr.prior_ability_4S_vec;
        prior_ability_4NS_vec = prabstr.prior_ability_4NS_vec;
        consump   = consumps.consump;
        consump_g = consumps.consump_g;
        N = data.N;
        T = data.T;
        black = data.black;
        hispanic = data.hispanic;
        HS_grades = data.HS_grades;
        Parent_college = data.Parent_college;
        birthYr = data.birthYr;
        famInc = data.famInc;
        age = data.age+a;
        exper = data.exper+e;
        exper_white_collar = data.exper_white_collar+wce;
        cum_4yr = data.cum_4yr+c4;
        cum_2yr = data.cum_2yr+c2;

        if CRRA<=0.2
            multip = 1/10000;
        elseif CRRA>0.2 && CRRA<=0.4
            multip = 1/1000;
        elseif CRRA>0.4 && CRRA<=0.7
            multip = 1/100;
        elseif CRRA>0.7 && CRRA<1.0
            multip = 1/10;
        elseif CRRA>1.0 && CRRA<=1.2
            multip = 1;
        elseif CRRA>1.2 && CRRA<=1.4
            multip = 10;
        elseif CRRA>1.4 && CRRA<=1.5
            multip = 100;
        elseif CRRA>1.6 && CRRA<=1.8
            multip = 1000;
        elseif CRRA>1.8 && CRRA<=2.0
            multip = 10000;
        end

        %% Form current and future flow utilities for structural MLE
        % u_{j,t} (X components)
        demog=[ones(N*T,1) black hispanic HS_grades Parent_college birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 famInc age age.^2 exper exper.^2 (cum_2yr+cum_4yr) (cum_2yr+cum_4yr).^2];
        sdemog = size(demog,2);
        demogs                   = kron(ones(S,1),demog);
        sloan4                   = kron(ones(S,1),data.E_loan4_18.*(1+intrate).^(data.yrsSinceHS)./1000);
        sloan2                   = kron(ones(S,1),data.E_loan2_18.*(1+intrate).^(data.yrsSinceHS)./1000);
        sprev_HS                 = kron(ones(S,1),data.prev_HS);
        sprev_2yr                = kron(ones(S,1),data.prev_2yr);
        sprev_4yrS               = kron(ones(S,1),data.prev_4yrS);
        sprev_4yrNS              = kron(ones(S,1),data.prev_4yrNS);
        sprev_PT                 = kron(ones(S,1),data.prev_PT);
        sprev_FT                 = kron(ones(S,1),data.prev_FT);
        sprev_WC                 = kron(ones(S,1),data.prev_WC);
        sage                     = kron(ones(S,1),data.age);
        sgrad_4yr                = kron(ones(S,1),data.grad_4yr);
        stype                    = kron(A,ones(data.N*T,1));
        sYSHS                    = kron(ones(S,1),data.yrsSinceHS);
        scum_2yr                 = kron(ones(S,1),data.cum_2yr);
        scum_4yr                 = kron(ones(S,1),data.cum_4yr);
        sfinsci                  = kron(ones(S,1),data.finalMajorSci);
        scum_school              = scum_2yr+scum_4yr;
        obs_abil_vec             = zeros(size(prior_ability_4S_vec));
        obs_abil_vec(sfinsci==1) = prior_ability_4S_vec(sfinsci==1);
        obs_abil_vec(sfinsci==0) = prior_ability_4NS_vec(sfinsci==0);

        % observed debt (i.e. in period t)
        debt20                   = (scum_2yr.*sloan2 + scum_4yr.*sloan4).*(1+intrate).^(sYSHS) + sloan2.*(1+intrate).^(sYSHS);
        debt40                   = (scum_2yr.*sloan2 + scum_4yr.*sloan4).*(1+intrate).^(sYSHS) + sloan4.*(1+intrate).^(sYSHS);
        debtn0                   = (scum_2yr.*sloan2 + scum_4yr.*sloan4).*(1+intrate).^(sYSHS);

        % case 1: 2yr paths
        % t+1, H-2-H path (i.e. H in t, 2yr in t+1, H in t+2)
        if M(ww,3)==1 && M(ww,2)==20 && ismember(M(ww,1),[1:5])
            debt2 = debtn0.*(1+intrate)+sloan2.*(1+intrate).^(sYSHS+1);
            debt4 = debtn0.*(1+intrate)+sloan4.*(1+intrate).^(sYSHS+1);
            debtn = debtn0.*(1+intrate);
            % t+1, 2-H-H path
        elseif M(ww,3)==1 && ismember(M(ww,2),[1:5]) && M(ww,1)==20
            debt2 = debt20.*(1+intrate)+sloan2.*(1+intrate).^(sYSHS+1);
            debt4 = debt20.*(1+intrate)+sloan4.*(1+intrate).^(sYSHS+1);
            debtn = debt20.*(1+intrate);
            % t+2, either path
        elseif M(ww,3)==2 && (ismember(M(ww,2),[1:5]) || ismember(M(ww,1),[1:5]))
            debt2 = debt20.*(1+intrate).^2+sloan2.*(1+intrate).^(sYSHS+2);
            debt4 = debt20.*(1+intrate).^2+sloan4.*(1+intrate).^(sYSHS+2);
            debtn = debt20.*(1+intrate).^2;

            % case 2: 4yr paths
            % t+1, H-4-H path
        elseif M(ww,3)==1 && M(ww,2)==20 && ismember(M(ww,1),[6:15])
            debt2 = debtn0.*(1+intrate)+sloan2.*(1+intrate).^(sYSHS+1);
            debt4 = debtn0.*(1+intrate)+sloan4.*(1+intrate).^(sYSHS+1);
            debtn = debtn0.*(1+intrate);
            % t+1, 4-H-H path
        elseif M(ww,3)==1 && ismember(M(ww,2),[6:15]) && M(ww,1)==20
            debt2 = debt40.*(1+intrate)+sloan2.*(1+intrate).^(sYSHS+1);
            debt4 = debt40.*(1+intrate)+sloan4.*(1+intrate).^(sYSHS+1);
            debtn = debt40.*(1+intrate);
            % t+2, either path
        elseif M(ww,3)==2 && (ismember(M(ww,2),[6:15]) || ismember(M(ww,1),[6:15]))
            debt2 = debt40.*(1+intrate).^2+sloan2.*(1+intrate).^(sYSHS+2);
            debt4 = debt40.*(1+intrate).^2+sloan4.*(1+intrate).^(sYSHS+2);
            debtn = debt40.*(1+intrate).^2;

            % case 3: all other paths
            % t+1, H-W-H path
        elseif M(ww,3)==1 && M(ww,2)==20 && ismember(M(ww,1),[16:20])
            debt2 = debtn0.*(1+intrate)+sloan2.*(1+intrate).^(sYSHS+1);
            debt4 = debtn0.*(1+intrate)+sloan4.*(1+intrate).^(sYSHS+1);
            debtn = debtn0.*(1+intrate);
            % t+1, W-H-H path
        elseif M(ww,3)==1 && ismember(M(ww,2),[16:20]) && M(ww,1)==20
            debt2 = debtn0.*(1+intrate)+sloan2.*(1+intrate).^(sYSHS+1); 
            debt4 = debtn0.*(1+intrate)+sloan4.*(1+intrate).^(sYSHS+1); 
            debtn = debtn0.*(1+intrate);
            % t+2, either path
        elseif M(ww,3)==2 && (ismember(M(ww,2),[16:20]) || ismember(M(ww,1),[16:20]))
            debt2 = debtn0.*(1+intrate).^2+sloan2.*(1+intrate).^(sYSHS+2);
            debt4 = debtn0.*(1+intrate).^2+sloan4.*(1+intrate).^(sYSHS+2);
            debtn = debtn0.*(1+intrate).^2;
        end

        
        %ORDER - 1:sprev_HS 2:sprev_2yr 3:sprev_4yrS 4:sprev_4yrNS 5:sprev_PT 6:sprev_FT 7:sprev_WC
        
        sprevs = [sprev_HS sprev_2yr sprev_4yrS sprev_4yrNS sprev_PT sprev_FT sprev_WC];
        if M(ww,2)==20 % home
            sprevs = 0.*sprevs;
        elseif M(ww,2)==1  % 2yr & FT, blue collar
            sprevs = ones(size(sprevs,1),1)*[0 1 0 0 0 1 0];
        elseif M(ww,2)==2  % 2yr & FT, white collar
            sprevs = ones(size(sprevs,1),1)*[0 1 0 0 0 1 1];
        elseif M(ww,2)==3  % 2yr & PT, blue collar
            sprevs = ones(size(sprevs,1),1)*[0 1 0 0 1 0 0];
        elseif M(ww,2)==4  % 2yr & PT, white collar
            sprevs = ones(size(sprevs,1),1)*[0 1 0 0 1 0 1];
        elseif M(ww,2)==5  % 2yr & No Work
            sprevs = ones(size(sprevs,1),1)*[0 1 0 0 0 0 0];
        elseif M(ww,2)==6  % 4yr Science & FT, blue collar
            sprevs = ones(size(sprevs,1),1)*[0 0 1 0 0 1 0];
        elseif M(ww,2)==7  % 4yr Science & FT, white collar
            sprevs = ones(size(sprevs,1),1)*[0 0 1 0 0 1 1];
        elseif M(ww,2)==8  % 4yr Science & PT, blue collar
            sprevs = ones(size(sprevs,1),1)*[0 0 1 0 1 0 0];
        elseif M(ww,2)==9  % 4yr Science & PT, white collar
            sprevs = ones(size(sprevs,1),1)*[0 0 1 0 1 0 1];
        elseif M(ww,2)==10 % 4yr Science & No Work
            sprevs = ones(size(sprevs,1),1)*[0 0 1 0 0 0 0];
        elseif M(ww,2)==11 % 4yr Humanities & FT, blue collar
            sprevs = ones(size(sprevs,1),1)*[0 0 0 1 0 1 0];
        elseif M(ww,2)==12 % 4yr Humanities & FT, white collar
            sprevs = ones(size(sprevs,1),1)*[0 0 0 1 0 1 1];
        elseif M(ww,2)==13 % 4yr Humanities & PT, blue collar
            sprevs = ones(size(sprevs,1),1)*[0 0 0 1 1 0 0];
        elseif M(ww,2)==14 % 4yr Humanities & PT, white collar
            sprevs = ones(size(sprevs,1),1)*[0 0 0 1 1 0 1];
        elseif M(ww,2)==15 % 4yr Humanities & No Work
            sprevs = ones(size(sprevs,1),1)*[0 0 0 1 0 0 0];
        elseif M(ww,2)==16 % Work PT, blue collar
            sprevs = ones(size(sprevs,1),1)*[0 0 0 0 1 0 0];
        elseif M(ww,2)==17 % Work PT, white collar
            sprevs = ones(size(sprevs,1),1)*[0 0 0 0 1 0 1];
        elseif M(ww,2)==18 % Work FT, blue collar
            sprevs = ones(size(sprevs,1),1)*[0 0 0 0 0 1 0];
        elseif M(ww,2)==19 % Work FT, white collar
            sprevs = ones(size(sprevs,1),1)*[0 0 0 0 0 1 1];
        end
        
        %Non-grad flow utilities (last 6 before types are: grad_4yr, workWC, workPT, workFT, workPT*white_collar, workFT*white_collar)
        X2ftbc   = [(1-discfact).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multip.*(consump(:,1 )-consump(:,20)) sprevs (1-discfact).*[zeros(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) stype]];
        X2ftwc   = [(1-discfact).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multip.*(consump(:,2 )-consump(:,20)) sprevs (1-discfact).*[ ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) stype]];
        X2ptbc   = [(1-discfact).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multip.*(consump(:,3 )-consump(:,20)) sprevs (1-discfact).*[zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) stype]];
        X2ptwc   = [(1-discfact).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multip.*(consump(:,4 )-consump(:,20)) sprevs (1-discfact).*[ ones(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) stype]];
        X2nw     = [(1-discfact).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multip.*(consump(:,5 )-consump(:,20)) sprevs (1-discfact).*[zeros(N*T*S,5)                                                                                 stype]];
        X4sftbc  = [(1-discfact).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multip.*(consump(:,6 )-consump(:,20)) sprevs (1-discfact).*[zeros(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) stype]];
        X4sftwc  = [(1-discfact).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multip.*(consump(:,7 )-consump(:,20)) sprevs (1-discfact).*[ ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) stype]];
        X4sptbc  = [(1-discfact).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multip.*(consump(:,8 )-consump(:,20)) sprevs (1-discfact).*[zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) stype]];
        X4sptwc  = [(1-discfact).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multip.*(consump(:,9 )-consump(:,20)) sprevs (1-discfact).*[ ones(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) stype]];
        X4snw    = [(1-discfact).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multip.*(consump(:,10)-consump(:,20)) sprevs (1-discfact).*[zeros(N*T*S,5)                                                                                 stype]];
        X4nsftbc = [(1-discfact).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multip.*(consump(:,11)-consump(:,20)) sprevs (1-discfact).*[zeros(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) stype]];
        X4nsftwc = [(1-discfact).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multip.*(consump(:,12)-consump(:,20)) sprevs (1-discfact).*[ ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) stype]];
        X4nsptbc = [(1-discfact).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multip.*(consump(:,13)-consump(:,20)) sprevs (1-discfact).*[zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) stype]];
        X4nsptwc = [(1-discfact).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multip.*(consump(:,14)-consump(:,20)) sprevs (1-discfact).*[ ones(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) stype]];
        X4nsnw   = [(1-discfact).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multip.*(consump(:,15)-consump(:,20)) sprevs (1-discfact).*[zeros(N*T*S,5)                                                                                 stype]];
        Xngwptbc = [(1-discfact).*[demogs zeros(N*T*S,1)   debtn debtn.^2./100] multip.*(consump(:,16)-consump(:,20)) sprevs (1-discfact).*[zeros(N*T*S,1) zeros(N*T*S,4)                                                             stype]];
        Xngwptwc = [(1-discfact).*[demogs zeros(N*T*S,1)   debtn debtn.^2./100] multip.*(consump(:,17)-consump(:,20)) sprevs (1-discfact).*[ ones(N*T*S,1) zeros(N*T*S,4)                                                             stype]];
        Xngwftbc = [(1-discfact).*[demogs zeros(N*T*S,1)   debtn debtn.^2./100] multip.*(consump(:,18)-consump(:,20)) sprevs (1-discfact).*[zeros(N*T*S,1) zeros(N*T*S,4)                                                             stype]];
        Xngwftwc = [(1-discfact).*[demogs zeros(N*T*S,1)   debtn debtn.^2./100] multip.*(consump(:,19)-consump(:,20)) sprevs (1-discfact).*[ ones(N*T*S,1) zeros(N*T*S,4)                                                             stype]];
                                                                                   
        % Grad flow utilities                                                      
        Xgwptbc  = [(1-discfact).*[demogs(:,1:10)] multip.*(consump_g(:,16)-consump_g(:,20))];
        Xgwptwc  = [(1-discfact).*[demogs(:,1:10)] multip.*(consump_g(:,17)-consump_g(:,20))];
        Xgwftbc  = [(1-discfact).*[demogs(:,1:10)] multip.*(consump_g(:,18)-consump_g(:,20))];
        Xgwftwc  = [(1-discfact).*[demogs(:,1:10)] multip.*(consump_g(:,19)-consump_g(:,20))];

        Utils.sdemog = sdemog;
        Utils.X2ftbc  = X2ftbc  ;
        Utils.X2ftwc  = X2ftwc  ;
        Utils.X2ptbc  = X2ptbc  ;
        Utils.X2ptwc  = X2ptwc  ;
        Utils.X2nw    = X2nw    ;
        Utils.X4sftbc = X4sftbc ;
        Utils.X4sftwc = X4sftwc ;
        Utils.X4sptbc = X4sptbc ;
        Utils.X4sptwc = X4sptwc ;
        Utils.X4snw   = X4snw   ;
        Utils.X4nsftbc= X4nsftbc;
        Utils.X4nsftwc= X4nsftwc;
        Utils.X4nsptbc= X4nsptbc;
        Utils.X4nsptwc= X4nsptwc;
        Utils.X4nsnw  = X4nsnw  ;
        Utils.Xngwptbc= Xngwptbc;
        Utils.Xngwptwc= Xngwptwc;
        Utils.Xngwftbc= Xngwftbc;
        Utils.Xngwftwc= Xngwftwc;
        Utils.Xgwptbc = Xgwptbc ;
        Utils.Xgwptwc = Xgwptwc ;
        Utils.Xgwftbc = Xgwftbc ;
        Utils.Xgwftwc = Xgwftwc ;
        Utils.stype   = stype   ;
        Utils.sprevs  = sprevs  ;
        Utils.sage    = sage    ;
        Utils.number2   = size(X2nw,2)-2;       % exclude consump, whiteCollar dummy, work pref type
        Utils.number4s  = size(X4snw,2)-2;      % exclude consump, whiteCollar dummy, work pref type
        Utils.number4ns = size(X4nsnw,2)-2;     % exclude consump, whiteCollar dummy, work pref type
        Utils.numberpt  = size(Xngwptbc,2)-6;   % exclude abil, consump,                    workPT/FT dummies and interactions, sch pref type
        Utils.numberft  = size(Xngwftbc,2)-7;   % exclude abil, consump, whiteCollar dummy, workPT/FT dummies and interactions, sch pref type
        Utils.numberwc  = size(Xngwftwc,2)-9;   % exclude abil, consump, debt, debt^2, whiteCollar dummy, workPT/FT dummies and interactions, sch pref type
        Utils.numbergpt = 10;                   % only subset of demographics
        Utils.numbergft = 10;                   % only subset of demographics
        Utils.numbergwc = 10;                   % only subset of demographics
    end



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EXPECTED CONSUMPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    function econsumps = createconsump(data,prablstrct,learnparms,Clb,CRRA,AR1parms,S)

        a=M(ww,3);
        c2=M(ww,4);
        c4=M(ww,5);
        cs=c2+c4;
        wages = createWwages(data,prablstrct,learnparms,AR1parms,A,S,M,ww);
        unsk_wage_sig = AR1parms.unsk_wage_sig;
        lambdag1start = learnparms.lambdag1start;
        lambdan1start = learnparms.lambdan1start;
        sig = learnparms.sig;
        E_ln_wage = wages.E_ln_wage;
        E_ln_wage_g = wages.E_ln_wage_g;
        idxParTrans4 = data.idxParTrans4; 
        idxParTrans2 = data.idxParTrans2; 
        grant4RMSE = data.grant4RMSE; 
        grant4idx = data.grant4idx; 
        loan4RMSE = data.loan4RMSE; 
        loan4idx = data.loan4idx; 
        tui2imp = data.tui2imp; 
        grant2RMSE = data.grant2RMSE; 
        grant2idx = data.grant2idx; 
        loan2RMSE = data.loan2RMSE; 
        loan2idx = data.loan2idx; 
        tui4imp = data.tui4imp;
        ParTrans4RMSE = data.ParTrans4RMSE;
        ParTrans2RMSE = data.ParTrans2RMSE;
        prParTrans4 = data.prParTrans4;
        prParTrans2 = data.prParTrans2;
        grant4pr = data.grant4pr;
        grant2pr = data.grant2pr;
        loan4pr = data.loan4pr;
        loan2pr = data.loan2pr;
        ClImps = data.Yl;

        %summarize([idxParTrans4 idxParTrans2]);
        %summarize([prParTrans4  prParTrans2 ]);
        idxParTrans4 = idxParTrans4 - a*0.095542  + cs*.0027407;        % 4yr PT age coefficient = -0.095542 ; cum_school coefficient = .0027407 
        idxParTrans2 = idxParTrans2 - a*0.0595774 + cs*.0311122;        % 2yr PT age coefficient = -0.0592096; cum_school coefficient = .0311122 
        prPT4idx     = log(prParTrans4./(1-prParTrans4)) - a*0.3316555; % 4yr PT>0 logit age coefficient = -0.3316555  
        prPT2idx     = log(prParTrans2./(1-prParTrans2)) - a*0.3034261; % 2yr PT>0 logit age coefficient = -0.3034261  
        prParTrans4  = exp(prPT4idx)./(1+exp(prPT4idx));                % logit(log odds) = new probability
        prParTrans2  = exp(prPT2idx)./(1+exp(prPT2idx));                % logit(log odds) = new probability
        %summarize([idxParTrans4 idxParTrans2]);
        %summarize([prParTrans4  prParTrans2 ]);
        
        flg = ClImps>0;

        % wages in levels
        jhrs     = [repmat([40*52 40*52 20*52 20*52 0],1,3) 20*52 20*52 40*52 40*52 0];
        jhrs_g   = [zeros(1,15) 20*52 20*52 40*52 40*52 0];
        wrkr     = ones(size(E_ln_wage  ,1),1)*jhrs;
        wrkr_g   = ones(size(E_ln_wage_g,1),1)*jhrs_g;
        E_wage   = wrkr.*exp(E_ln_wage);
        E_wage_g = wrkr_g.*exp(E_ln_wage_g);

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
        lo4idx   = kron(ones(S,1),data.E_loan4_18.*(1+intrate).^(data.yrsSinceHS+a));
        lo2idx   = kron(ones(S,1),data.E_loan2_18.*(1+intrate).^(data.yrsSinceHS+a));
        prpt4    = kron(ones(S,1),prParTrans4);
        prpt2    = kron(ones(S,1),prParTrans2);
        prg4     = kron(ones(S,1),grant4pr);
        prg2     = kron(ones(S,1),grant2pr);
        tu4      = kron(ones(S,1),tui4imp);
        tu2      = kron(ones(S,1),tui2imp);

        pt2pridx   = log(prpt2./(1-prpt2));
        pt4pridx   = log(prpt4./(1-prpt4));
        gr2pridx   = log(prg2./(1-prg2));
        gr4pridx   = log(prg4./(1-prg4));

        consump    = nan(size(pt4idx,1),20);
        consump_g  = nan(size(pt4idx,1),20);

        consumpNaive      = nan(size(pt4idx,1),20);
        consumpNaive_g    = nan(size(pt4idx,1),20);

        % non-grads
        for j = 1:20; % loop over all current decisions
            % school only
            if j==5
                consumpNaive(flg,5) = max(exp(pt2idx(flg))+gr2idx(flg)+lo2idx(flg)-tu2(flg),Clb).^(1-CRRA)./(1-CRRA);
                consumpNaive(flg,[10 15]) = repmat(max(exp(pt4idx(flg))+gr4idx(flg)+lo4idx(flg)-tu4(flg),Clb).^(1-CRRA)./(1-CRRA),1,2);
            % 2yr and work (blue collar)
            elseif ismember(j,[1 3])
                consumpNaive(flg,j) = max(E_wage(flg,j)+exp(pt2idx(flg))+gr2idx(flg)+lo2idx(flg)-tu2(flg),Clb).^(1-CRRA)./(1-CRRA);
            % 2yr and work (white collar)
            elseif ismember(j,[2 4])
                consumpNaive(flg,j) = max(E_wage(flg,j)+exp(pt2idx(flg))+gr2idx(flg)+lo2idx(flg)-tu2(flg),Clb).^(1-CRRA)./(1-CRRA);
            % 4yr and work (blue collar)
            elseif ismember(j,[6 8 11 13])
                consumpNaive(flg,j) = max(E_wage(flg,j)+exp(pt4idx(flg))+gr4idx(flg)+lo4idx(flg)-tu4(flg),Clb).^(1-CRRA)./(1-CRRA);
            % 4yr and work (white collar)
            elseif ismember(j,[7 9 12 14])
                consumpNaive(flg,j) = max(E_wage(flg,j)+exp(pt4idx(flg))+gr4idx(flg)+lo4idx(flg)-tu4(flg),Clb).^(1-CRRA)./(1-CRRA);
            % work only
            elseif ismember(j,[16 18])
                consumpNaive(flg,j) = max(E_wage(flg,j),Clb).^(1-CRRA)./(1-CRRA);
            elseif ismember(j,[17 19])
                consumpNaive(flg,j) = max(E_wage(flg,j),Clb).^(1-CRRA)./(1-CRRA);
            elseif j==20
                consumpNaive(flg,j) = Clb.^(1-CRRA)./(1-CRRA);
            end
            if a==1
                consump(flg,j) = predconsump(j,0,cmapStruct_t1.cmap_nograd,cmapStruct_t1.cmap_nograd_work,cmapStruct_t1.cmap_grad_work,cmapStruct_t1.scaler_nograd,cmapStruct_t1.scaler_nograd_work,cmapStruct_t1.scaler_grad_work,consumpNaive(flg,j),gr2pridx(flg),gr4pridx(flg),gr2idx(flg),gr4idx(flg),pt2pridx(flg),pt4pridx(flg),pt2idx(flg),pt4idx(flg),lo2idx(flg),lo4idx(flg)); 
            elseif a==2
                consump(flg,j) = predconsump(j,0,cmapStruct_t2.cmap_nograd,cmapStruct_t2.cmap_nograd_work,cmapStruct_t2.cmap_grad_work,cmapStruct_t2.scaler_nograd,cmapStruct_t2.scaler_nograd_work,cmapStruct_t2.scaler_grad_work,consumpNaive(flg,j),gr2pridx(flg),gr4pridx(flg),gr2idx(flg),gr4idx(flg),pt2pridx(flg),pt4pridx(flg),pt2idx(flg),pt4idx(flg),lo2idx(flg),lo4idx(flg)); 
            else
                error('problem with finite dependence path!')
            end
        end

        % grads
        for j = 16:20 % loop over all current decisions
            if ismember(j,[16 18])
                consumpNaive_g(flg,j) = max(E_wage_g(flg,j),Clb).^(1-CRRA)./(1-CRRA);
            elseif ismember(j,[17 19])
                consumpNaive_g(flg,j) = max(E_wage_g(flg,j),Clb).^(1-CRRA)./(1-CRRA);
            elseif ismember(j,[20])
                consumpNaive_g(flg,j) = Clb.^(1-CRRA)./(1-CRRA);
            end
            if a==1
                consump_g(flg,j) = predconsump(j,1,cmapStruct_t1.cmap_nograd,cmapStruct_t1.cmap_nograd_work,cmapStruct_t1.cmap_grad_work,cmapStruct_t1.scaler_nograd,cmapStruct_t1.scaler_nograd_work,cmapStruct_t1.scaler_grad_work,consumpNaive_g(flg,j),gr2pridx(flg),gr4pridx(flg),gr2idx(flg),gr4idx(flg),pt2pridx(flg),pt4pridx(flg),pt2idx(flg),pt4idx(flg),lo2idx(flg),lo4idx(flg));  
            elseif a==2
                consump_g(flg,j) = predconsump(j,1,cmapStruct_t2.cmap_nograd,cmapStruct_t2.cmap_nograd_work,cmapStruct_t2.cmap_grad_work,cmapStruct_t2.scaler_nograd,cmapStruct_t2.scaler_nograd_work,cmapStruct_t2.scaler_grad_work,consumpNaive_g(flg,j),gr2pridx(flg),gr4pridx(flg),gr2idx(flg),gr4idx(flg),pt2pridx(flg),pt4pridx(flg),pt2idx(flg),pt4idx(flg),lo2idx(flg),lo4idx(flg));  
            else
                error('problem with finite dependence path!')
            end
        end

        econsumps.consump   = consump;
        econsumps.consump_g = consump_g;
    end









    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WAGES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function ewages = createWwages(data,prbilstruct,learnparms,AR1parms,A,S,M,ww)
    a=M(ww,3);
    e=M(ww,6);
    wce=M(ww,7);
    c2=M(ww,4);
    c4=M(ww,5);

        %year = [];
        %v2struct(data);
        %v2struct(prbilstruct);
        %v2struct(learnparms);
        %v2struct(AR1parms);
        % Can't use v2struct when the code is written in this way, so we instead need to manually unroll the elements from the struct that will be used
        birthYr = data.birthYr;
        N = data.N;
        T = data.T;
        black = data.black;
        hispanic = data.hispanic;
        Parent_college = data.Parent_college;
        HS_grades = data.HS_grades; 
        age = data.age; 
        exper = data.exper; 
        exper_white_collar = data.exper_white_collar ;
        cum_2yr = data.cum_2yr+c2;
        cum_4yr = data.cum_4yr+c4;
        grad_4yr = data.grad_4yr;
        finalMajorSci = data.finalMajorSci;
        year = data.year;
        %prior_ability_U = prbilstruct.prior_ability_U;
        prior_ability_U_vec = prbilstruct.prior_ability_U_vec;
        %prior_ability_S = prbilstruct.prior_ability_S;
        prior_ability_S_vec = prbilstruct.prior_ability_S_vec;


        ydg      = [18:33];
        ydn      = [18:33];
        yndg     = setdiff([1:length(learnparms.bstartg)],ydg);
        yndn     = setdiff([1:length(learnparms.bstartn)],ydn);

        ability_range_bc = length(AR1parms.unskilledWageBeta_a(1:end-3))+1;
        ability_range_wc = length(  AR1parms.skilledWageBeta_a(1:end-3))+1;

        wageparmbc = cat(1,AR1parms.unskilledWageBetaMat(1:ability_range_bc-1,:),ones(1,size(AR1parms.unskilledWageBetaMat,2)),AR1parms.unskilledWageBetaMat(ability_range_bc:end,:));
        wageparmwc = cat(1,  AR1parms.skilledWageBetaMat(1:ability_range_wc-1,:),ones(1,size(  AR1parms.skilledWageBetaMat,2)),  AR1parms.skilledWageBetaMat(ability_range_wc:end,:));

        % make sure that college graduates have the experience profiles of 4+ year college completers
        cum_sch = (1-grad_4yr).*min(cum_2yr+cum_4yr,4) + 4.*grad_4yr;

        %% Get expected log wages along different finite dependence paths
        cumSchlImps = kron(ones(S,1),cum_sch);
        finalMajorScilImps = kron(ones(S,1),finalMajorSci);

        % stack age
        agelImps = kron(ones(S,1),age);
        
        % unobs types
        stype = kron(A,ones(N*T,1));

        E_ln_wage = zeros(size(finalMajorScilImps,1),20);
        % non-grads
        for j = setdiff(1:20,[5 10 15 20]) % loop over all current decisions
            baseXbcWage = [ones(N*T,1) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age<=0 age==1 age==2 exper exper_white_collar cum_sch (grad_4yr==1) (finalMajorSci==1 & grad_4yr==1) year<=1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ones(N*T,1)*ismember(j,[3 8 13 16]) prior_ability_U_vec(1:N*T)];
            baseXbcWage = cat(2,kron(ones(S,1),baseXbcWage),stype);
            baseXbcWage(:,ability_range_bc) = prior_ability_U_vec;

            baseXwcWage = [ones(N*T,1) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age<=0 age==1 age==2 exper exper_white_collar cum_sch (grad_4yr==1) (finalMajorSci==1 & grad_4yr==1) year<=1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ones(N*T,1)*ismember(j,[4 9 14 17]) prior_ability_S_vec(1:N*T)];
            baseXwcWage = cat(2,kron(ones(S,1),baseXwcWage),stype);
            baseXwcWage(:,ability_range_wc) = prior_ability_S_vec;

            lamtildg0 = 0*ismember(j,[17 19]) + learnparms.lambdag0start*ismember(j,[2 4 7 9 12 14]);
            lamtildg1 = 1*ismember(j,[17 19]) + learnparms.lambdag1start*ismember(j,[2 4 7 9 12 14]);
            lamtildn0 = 0*ismember(j,[16 18]) + learnparms.lambdan0start*ismember(j,[1 3 6 8 11 13]);
            lamtildn1 = 1*ismember(j,[16 18]) + learnparms.lambdan1start*ismember(j,[1 3 6 8 11 13]);

            if ismember(j,[1 3 6 8 11 13 16 18]) % blue collar alternatives
                Xnew = Wupdater_bc_wage(baseXbcWage,agelImps,cumSchlImps,finalMajorScilImps,a,j,0,e,wce,c2,c4); % argument after j is graduate dummy
                E_ln_wage(:,j) = lamtildn0 + Xnew(:,ydn)*wageparmbc(ydn,a+1) + lamtildn1*(Xnew(:,setdiff([1:size(Xnew,2)],ydn))*wageparmbc(setdiff([1:size(Xnew,2)],ydn),a+1));
            elseif ismember(j,[2 4 7 9 12 14 17 19]) % white collar alternatives
                Xnew = Wupdater_wc_wage(baseXwcWage,agelImps,cumSchlImps,finalMajorScilImps,a,j,0,e,wce,c2,c4); % argument after j is graduate dummy;
                E_ln_wage(:,j) = lamtildg0 + learnparms.lambdaydgstart*(Xnew(:,ydg)*wageparmbc(ydn,a+1)) + lamtildg1*(Xnew(:,setdiff([1:size(Xnew,2)],ydg))*wageparmwc(setdiff([1:size(Xnew,2)],ydg),a+1));
            end
        end

        E_ln_wage_g = zeros(size(finalMajorScilImps,1),20);
        % grads
        for j = 16:20 % loop over all current decisions
            baseXbcWage = [ones(N*T,1) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age<=0 age==1 age==2 exper exper_white_collar cum_sch (grad_4yr==1) (finalMajorSci==1 & grad_4yr==1) year<=1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ones(N*T,1)*ismember(j,[3 8 13 16]) prior_ability_U_vec(1:N*T)];
            baseXbcWage = cat(2,kron(ones(S,1),baseXbcWage),stype);
            baseXbcWage(:,ability_range_bc) = prior_ability_U_vec;

            baseXwcWage = [ones(N*T,1) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age<=0 age==1 age==2 exper exper_white_collar cum_sch (grad_4yr==1) (finalMajorSci==1 & grad_4yr==1) year<=1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ones(N*T,1)*ismember(j,[4 9 14 17]) prior_ability_S_vec(1:N*T)];
            baseXwcWage = cat(2,kron(ones(S,1),baseXwcWage),stype);
            baseXwcWage(:,ability_range_wc) = prior_ability_S_vec;

            lamtildg0 = 0*ismember(j,[17 19]);
            lamtildg1 = 1*ismember(j,[17 19]);
            lamtildn0 = 0*ismember(j,[16 18]);
            lamtildn1 = 1*ismember(j,[16 18]);

            if ismember(j,[16 18]) % blue collar alternatives
                Xnew = Wupdater_bc_wage(baseXbcWage,agelImps,cumSchlImps,finalMajorScilImps,a,j,1,e,wce,c2,c4); % argument after j is graduate dummy;
                E_ln_wage_g(:,j) = lamtildn0 + Xnew(:,ydn)*wageparmbc(ydn,a+1) + lamtildn1*(Xnew(:,setdiff([1:size(Xnew,2)],ydn))*wageparmbc(setdiff([1:size(Xnew,2)],ydn),a+1));
            elseif ismember(j,[17 19]) % white collar alternatives
                Xnew = Wupdater_wc_wage(baseXwcWage,agelImps,cumSchlImps,finalMajorScilImps,a,j,1,e,wce,c2,c4); % argument after j is graduate dummy
                E_ln_wage_g(:,j) = lamtildg0 + learnparms.lambdaydgstart*(Xnew(:,ydg)*wageparmbc(ydn,a+1)) + lamtildg1*(Xnew(:,setdiff([1:size(Xnew,2)],ydg))*wageparmwc(setdiff([1:size(Xnew,2)],ydg),a+1));
            end
        end

        ewages.E_ln_wage   = E_ln_wage;
        ewages.E_ln_wage_g = E_ln_wage_g;
    end

end 
