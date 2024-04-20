function P = plogit_restrictU(b,X,abil)

    % make sure X excludes a constant
    assert(~any(all(X == 1,1)), 'X should not include a constant')    
    % make sure b is correctly specified
    assert(length(b)==6*(size(X,2)+1)+21, 'b should have 6*(size(X,2)+1)+21 elements')    

    nb                   = size(X,2)+1;
    c2idx                = 0*nb+1:1*nb;
    c4sidx               = 1*nb+1:2*nb;
    c4hidx               = 2*nb+1:3*nb;
    wptidx               = 3*nb+1:4*nb;
    wftidx               = 4*nb+1:5*nb;
    wcidx                = 5*nb+1:6*nb;
    compidx              = 6*nb+1:length(b);
    b2                   = b(c2idx);
    b4s                  = b(c4sidx);
    b4h                  = b(c4hidx);
    bwpt                 = b(wptidx);
    bwft                 = b(wftidx);
    bwc                  = b(wcidx);
    bws                  = b(end-1:end);

    % utilities
    U2    = [X abil(:,5)]*b2;
    U4s   = [X abil(:,3)]*b4s;
    U4h   = [X abil(:,4)]*b4h;
    Uftbc = [X abil(:,2)]*bwft;
    Uptbc = [X abil(:,2)]*bwpt;
    Uftwc = [X abil(:,1)]*(bwft+bwc);
    Uptwc = [X abil(:,1)]*(bwpt+bwc);

    % combined flow utilities
    u2ftbc  = b(compidx(1 )) + U2+Uftbc+bws(2)*abil(:,2);
    u2ftwc  = b(compidx(2 )) + U2+Uftwc+bws(1)*abil(:,1);
    u2ptbc  = b(compidx(3 )) + U2+Uptbc+bws(2)*abil(:,2);
    u2ptwc  = b(compidx(4 )) + U2+Uptwc+bws(1)*abil(:,1);
    u2      = b(compidx(5 )) + U2;
    u4sftbc = b(compidx(6 )) + U4s+Uftbc+bws(2)*abil(:,2);
    u4sftwc = b(compidx(7 )) + U4s+Uftwc+bws(1)*abil(:,1);
    u4sptbc = b(compidx(8 )) + U4s+Uptbc+bws(2)*abil(:,2);
    u4sptwc = b(compidx(9 )) + U4s+Uptwc+bws(1)*abil(:,1);
    u4s     = b(compidx(10)) + U4s;
    u4hftbc = b(compidx(11)) + U4h+Uftbc+bws(2)*abil(:,2);
    u4hftwc = b(compidx(12)) + U4h+Uftwc+bws(1)*abil(:,1);
    u4hptbc = b(compidx(13)) + U4h+Uptbc+bws(2)*abil(:,2);
    u4hptwc = b(compidx(14)) + U4h+Uptwc+bws(1)*abil(:,1);
    u4h     = b(compidx(15)) + U4h;
    uptbc   = b(compidx(16)) + Uptbc;
    uptwc   = b(compidx(17)) + Uptwc;
    uftbc   = b(compidx(18)) + Uftbc;
    uftwc   = b(compidx(19)) + Uftwc;

    log_dem = log(1+exp(u2ftbc)  + exp(u2ftwc)  + exp(u2ptbc)  + exp(u2ptwc)  + exp(u2) +...
                    exp(u4sftbc) + exp(u4sftwc) + exp(u4sptbc) + exp(u4sptwc) + exp(u4s)+...
                    exp(u4hftbc) + exp(u4hftwc) + exp(u4hptbc) + exp(u4hptwc) + exp(u4h)+... 
                    exp(uptbc)   + exp(uptwc)   + exp(uftbc)   + exp(uftwc));

    % choice probabilities
    logP       = zeros(size(u2,1),20);
    logP(:,1 ) = u2ftbc  - log_dem;
    logP(:,2 ) = u2ftwc  - log_dem;
    logP(:,3 ) = u2ptbc  - log_dem;
    logP(:,4 ) = u2ptwc  - log_dem;
    logP(:,5 ) = u2      - log_dem;
    logP(:,6 ) = u4sftbc - log_dem;
    logP(:,7 ) = u4sftwc - log_dem;
    logP(:,8 ) = u4sptbc - log_dem;
    logP(:,9 ) = u4sptwc - log_dem;
    logP(:,10) = u4s     - log_dem;
    logP(:,11) = u4hftbc - log_dem;
    logP(:,12) = u4hftwc - log_dem;
    logP(:,13) = u4hptbc - log_dem;
    logP(:,14) = u4hptwc - log_dem;
    logP(:,15) = u4h     - log_dem;
    logP(:,16) = uptbc   - log_dem;
    logP(:,17) = uptwc   - log_dem;
    logP(:,18) = uftbc   - log_dem;
    logP(:,19) = uftwc   - log_dem;
    logP(:,20) =         - log_dem;

    P = exp(logP);
end