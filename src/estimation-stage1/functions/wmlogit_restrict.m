function [like,grad] = wmlogit_restrict(b,restrMat,Y,X,q,abil)

    % apply restrictions as defined in restrMat
    if ~isempty(restrMat)
        b = applyRestr(restrMat,b);
    end

    % make sure X excludes a constant
    assert(~any(all(X == 1,1)), 'X should not include a constant')    
    % make sure b is correctly specified
    assert(length(b)==3*(size(X,2)+1)+4, 'b should have 3*size(X,2)+4 elements')    
    
    bigY = bsxfun(@eq, Y, 1:max(Y));

    % parameters
    nb         = size(X,2)+1;
    wptidx     = 0*nb+1:1*nb;
    wftidx     = 1*nb+1:2*nb;
    wcidx      = 2*nb+1:3*nb;
    compidx    = 3*nb+1:length(b);
    bwpt       = b(wptidx);
    bwft       = b(wftidx);
    bwc        = b(wcidx);

    % flow utilities
    uptbc      = [X abil(:,2)]*(bwpt    )+b(compidx(1));
    uptwc      = [X abil(:,1)]*(bwpt+bwc)+b(compidx(2));
    uftbc      = [X abil(:,2)]*(bwft    )+b(compidx(3));
    uftwc      = [X abil(:,1)]*(bwft+bwc)+b(compidx(4));

    % choice probabilities
    log_dem    = log(1+exp(uptwc)+exp(uptbc)+exp(uftwc)+exp(uftbc));
    logP       = zeros(size(bigY));
    logP(:,16) = uptbc   - log_dem;
    logP(:,17) = uptwc   - log_dem;
    logP(:,18) = uftbc   - log_dem;
    logP(:,19) = uftwc   - log_dem;
    logP(:,20) =         - log_dem;

    % log-likelihood
    like       = -q'*(sum(bigY.*logP,2));

    %PTs:   %FTs:   %WCs:
    % 16    % 18    % 17 
    % 17    % 19    % 19 

    % gradient
    grad = zeros(size(b));
    grad(wptidx)     = [-X'*(q.*sum(bigY(:,[16 17])-exp(logP(:,[16 17])),2));-abil(:,1)'*(q.*(bigY(:,17)-exp(logP(:,17))))-abil(:,2)'*(q.*(bigY(:,16)-exp(logP(:,16))))]; % part-time
    grad(wftidx)     = [-X'*(q.*sum(bigY(:,[18 19])-exp(logP(:,[18 19])),2));-abil(:,1)'*(q.*(bigY(:,19)-exp(logP(:,19))))-abil(:,2)'*(q.*(bigY(:,18)-exp(logP(:,18))))]; % full-time
    grad(wcidx)      = -[X abil(:,1)]'*(q.*sum(bigY(:,[17 19])-exp(logP(:,[17 19])),2)); % white-collar
    grad(compidx(1)) = -q'*(bigY(:,16)-exp(logP(:,16))); % PT-BC intercept
    grad(compidx(2)) = -q'*(bigY(:,17)-exp(logP(:,17))); % PT-WC intercept
    grad(compidx(3)) = -q'*(bigY(:,18)-exp(logP(:,18))); % FT-BC intercept
    grad(compidx(4)) = -q'*(bigY(:,19)-exp(logP(:,19))); % FT-WC intercept
    grad = applyRestrGrad(restrMat,grad);
end