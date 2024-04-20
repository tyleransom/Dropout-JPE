function [postMean,postVar,PsiPrior] = posteriorVecPsi(priorMean,priorVar,idioVar,signal,choice,choiceMat,currStates,Delta)
    % This function returns a NTxJ matrix of posterior means and a NTxJxJ tensor of posterior variances given function inputs
    % Inputs to the function are: 
    % 1. the NTxJ matrix of prior means
    % 2. the NTxJxJ tensor of prior variances
    % 3. the Kx1 vector of idiosyncratic variances (K=J in no-heteroskedasticity case)
    % 4. the NTxJ matrix of signals (zeros where a signal is unobserved)
    % 5. the NTx1 vector of observed choices
    % 5. the NTxL matrix of state variables
    % 6. the population covariance matrix

    % Use bsxfun to vectorize this. Mathematical formulas are:
    % postMean = inv(inv(priorVar)+Omega)*(inv(priorVar)*priorMean+Omega*signal);
    % postVar = inv(inv(priorVar)+Omega);

    J   = size(Delta,1);
    N   = size(priorMean,1);
    yc  = currStates.cum_2yr+currStates.cum_4yr;
    T   = size(choiceMat,2);


    sector = zeros(N,5);
    sector(:,1) = ismember(choice,[2 4 7 9 12 14 17 19 22 24]);
    sector(:,2) = ismember(choice,[1 3 6 8 11 13 16 18 21 23]);
    sector(:,3) = ismember(choice,[6:10]);
    sector(:,4) = ismember(choice,[11:15]);
    sector(:,5) = ismember(choice,[1:5]);
    sector      = logical(sector);

    Omega = zeros(N,J,J);
    Omega(sector(:,1),1,1) = (ismember(choice(sector(:,1)),[17 19])).*(1/idioVar(1))+(ismember(choice(sector(:,1)),[2 4 7 9 12 14 22 24])).*(1/idioVar(2));
    Omega(sector(:,2),2,2) = (ismember(choice(sector(:,2)),[16 18])).*(1/idioVar(3))+(ismember(choice(sector(:,2)),[1 3 6 8 11 13 21 23])).*(1/idioVar(4));
    Omega(sector(:,3),3,3) = (yc(sector(:,3))==0).*(1/idioVar(5))+(yc(sector(:,3))==1).*(1/idioVar(6))+(yc(sector(:,3))==2).*(1/idioVar(7))+(yc(sector(:,3))==3).*(1/idioVar(8))+(yc(sector(:,3))>=4).*(1/idioVar(9));
    Omega(sector(:,4),4,4) = (yc(sector(:,4))==0).*(1/idioVar(10))+(yc(sector(:,4))==1).*(1/idioVar(11))+(yc(sector(:,4))==2).*(1/idioVar(12))+(yc(sector(:,4))==3).*(1/idioVar(13))+(yc(sector(:,4))>=4).*(1/idioVar(14));
    Omega(sector(:,5),5,5) = (yc(sector(:,5))==0).*(1/idioVar(15))+(yc(sector(:,5))==1).*(1/idioVar(16))+(yc(sector(:,5))>=2).*(1/idioVar(17));

    OmegaTilde = zeros(N,J);
    for j=1:J
        OmegaTilde(:,j) = Omega(:,j,j);
    end

    PsiPrior = zeros(N,J,J);
    for t=1:T-1
        sectorTemp = zeros(N,J);
        sectorTemp(:,1) = ismember(choiceMat(:,t),[2 4 7 9 12 14 17 19 22 24]);
        sectorTemp(:,2) = ismember(choiceMat(:,t),[1 3 6 8 11 13 16 18 21 23]);
        sectorTemp(:,3) = ismember(choiceMat(:,t),[6:10]);
        sectorTemp(:,4) = ismember(choiceMat(:,t),[11:15]);
        sectorTemp(:,5) = ismember(choiceMat(:,t),[1:5]);
        sectorTemp      = logical(sectorTemp);
        
        if t>1
            yctemp = sum(ismember(choiceMat(:,1:t-1),[1:15]),2);
        else
            yctemp = zeros(N,1);
        end
        
        temp = zeros(N,J,J);
        temp(sectorTemp(:,1),1,1) = (ismember(choiceMat(sectorTemp(:,1),t),[17 19])).*(1/idioVar(1))+(ismember(choiceMat(sectorTemp(:,1),t),[2 4 7 9 12 14 22 24])).*(1/idioVar(2));
        temp(sectorTemp(:,2),2,2) = (ismember(choiceMat(sectorTemp(:,2),t),[16 18])).*(1/idioVar(3))+(ismember(choiceMat(sectorTemp(:,2),t),[1 3 6 8 11 13 21 23])).*(1/idioVar(4));
        temp(sectorTemp(:,3),3,3) = (yctemp(sectorTemp(:,3))==0).*(1/idioVar(5))+(yctemp(sectorTemp(:,3))==1).*(1/idioVar(6))+(yctemp(sectorTemp(:,3))==2).*(1/idioVar(7))+(yctemp(sectorTemp(:,3))==3).*(1/idioVar(8))+(yctemp(sectorTemp(:,3))>=4).*(1/idioVar(9));
        temp(sectorTemp(:,4),4,4) = (yctemp(sectorTemp(:,4))==0).*(1/idioVar(10))+(yctemp(sectorTemp(:,4))==1).*(1/idioVar(11))+(yctemp(sectorTemp(:,4))==2).*(1/idioVar(12))+(yctemp(sectorTemp(:,4))==3).*(1/idioVar(13))+(yctemp(sectorTemp(:,4))>=4).*(1/idioVar(14));
        temp(sectorTemp(:,5),5,5) = (yctemp(sectorTemp(:,5))==0).*(1/idioVar(15))+(yctemp(sectorTemp(:,5))==1).*(1/idioVar(16))+(yctemp(sectorTemp(:,5))>=2).*(1/idioVar(17));
        
        PsiPrior = PsiPrior+temp;
    end

    %first part of postMean [inv(inv(priorVar)+Omega)]:
    V = priorVar;
    for j=1:J
        cof = OmegaTilde(:,j);
        V = V - bsxfun(@times,cof./(1+cof.*V(:,j,j)),bsxfun(@times,V(:,j,:),V(:,:,j)));
    end
    postVar = V;

    % %part 2a of postMean: inv(priorVar) == inv(inv(Delta)+PsiPrior)
    % V = repmat(reshape(Delta\eye(J),[1 J J]),[N 1 1]);
    % for j=1:J
        % cof = PsiPrior(:,j);
        % V = V - bsxfun(@times,cof./(1+cof.*V(:,j,j)),bsxfun(@times,V(:,j,:),V(:,:,j)));
    % end
    % invPriorVar = V;

    %part 2b of postMean: inv(priorVar)*priorMean ... equiv ... inv(idelta+Psiprior)*priorMean
    abvec = zeros(N,J);
    idelta = repmat(reshape(Delta\eye(J),[1 J J]),[N 1 1]);
    for j=1:J
        % abvec = abvec + bsxfun(@times,invPriorVar(:,:,j),priorMean(:,j));
        abvec = abvec + bsxfun(@times,idelta(:,:,j)+PsiPrior(:,:,j),priorMean(:,j));
    end

    %third part of postMean:
    abvec2 = zeros(N,J);
    for j=1:J
        abvec2 = abvec2 + bsxfun(@times,Omega(:,:,j),signal(:,j));
    end

    %combine all parts:
    postMean = zeros(N,J);
    for j=1:J
        postMean = postMean + bsxfun(@times,V(:,:,j),abvec(:,j)+abvec2(:,j));
    end

end
