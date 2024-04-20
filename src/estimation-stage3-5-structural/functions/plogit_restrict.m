function P = plogit_restrict(b,X)
    nb               = length(b)/3;
    wptidx           = [0*nb+1:1*nb];
    wftidx           = [1*nb+1:2*nb];
    wcidx            = [2*nb+1:3*nb];
    bwpt             = b(wptidx);
    bwft             = b(wftidx);
    bwc              = b(wcidx);

    % "utility" for part-time work:
    uptwc     = X*(bwpt+bwc);
    uptbc     = X*(bwpt    );
    uftwc     = X*(bwft+bwc);
    uftbc     = X*(bwft    );

    log_dem   = log(1+exp(uptwc)+exp(uptbc)+exp(uftwc)+exp(uftbc));
    log_pptwc = uptwc-log_dem;
    log_pptbc = uptbc-log_dem;
    log_pftwc = uftwc-log_dem;
    log_pftbc = uftbc-log_dem;
    log_ph    =      -log_dem;

    P = zeros(size(X,1),5);
    P(:,1 ) = exp(log_pptbc);   % 16; % work PT, blue collar
    P(:,2 ) = exp(log_pptwc);   % 17; % work PT, white collar
    P(:,3 ) = exp(log_pftbc);   % 18; % work FT, blue collar
    P(:,4 ) = exp(log_pftwc);   % 19; % work FT, white collar
    P(:,5 ) = exp(log_ph);      % 20; % home
end
