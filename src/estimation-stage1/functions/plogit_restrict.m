function P = plogit_restrict(b,X,abil)

    % make sure X excludes a constant
    assert(~any(all(X == 1,1)), 'X should not include a constant')    
    % make sure b is correctly specified
    assert(length(b)==3*(size(X,2)+1)+4, 'b should have 3*(size(X,2)+1)+4 elements')    
    
    bigY = zeros(size(X,1),20);

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

    P = exp(logP(:,16:20));
end