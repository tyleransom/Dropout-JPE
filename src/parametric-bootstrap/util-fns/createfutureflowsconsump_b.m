function Utils = createfutureflowsconsump_b(data,priorabilstruct,consumps,Beta,A,S,intrate,CRRA);

    v2struct(data);
    v2struct(priorabilstruct);
    v2struct(consumps);
    
    if CRRA<=0.2
        multiplier = 1/10000;
    elseif CRRA>0.2 & CRRA<=0.4
        multiplier = 1/1000;
    elseif CRRA>0.4 & CRRA<=0.7
        multiplier = 1/100;
    elseif CRRA>0.7 & CRRA<1.0
        multiplier = 1/10;
    elseif CRRA>1.0 & CRRA<=1.2
        multiplier = 1;
    elseif CRRA>1.2 & CRRA<=1.4
        multiplier = 10;
    elseif CRRA>1.4 & CRRA<=1.5
        multiplier = 100;
    elseif CRRA>1.6 & CRRA<=1.8
        multiplier = 1000;
    elseif CRRA>1.8 & CRRA<=2.0
        multiplier = 10000;
    end

    %% Form current and future flow utilities for structural MLE
    % u_{j,t} (X components)
    demog=[ones(N*T,1) black hispanic HS_grades Parent_college birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 famInc age age.^2 exper exper.^2 (cum_2yr+cum_4yr) (cum_2yr+cum_4yr).^2];
    sdemog = size(demog,2);
    demogs                   = kron(ones(S,1),demog);
    sloan4                   = kron(ones(S,1),E_loan4_18.*(1+intrate).^(yrsSinceHS)./1000);
    sloan2                   = kron(ones(S,1),E_loan2_18.*(1+intrate).^(yrsSinceHS)./1000);
    sprev_HS                 = kron(ones(S,1),prev_HS);
    sprev_2yr                = kron(ones(S,1),prev_2yr);
    sprev_4yrS               = kron(ones(S,1),prev_4yrS);
    sprev_4yrNS              = kron(ones(S,1),prev_4yrNS);
    sprev_PT                 = kron(ones(S,1),prev_PT);
    sprev_FT                 = kron(ones(S,1),prev_FT);
    sprev_WC                 = kron(ones(S,1),prev_WC);
    sage                     = kron(ones(S,1),age);
   %smale                    = kron(ones(S,1),male);
    sgrad_4yr                = kron(ones(S,1),grad_4yr);
    stype                    = kron(A,ones(N*T,1));
    sYSHS                    = kron(ones(S,1),yrsSinceHS);
    scum_2yr                 = kron(ones(S,1),cum_2yr);
    scum_4yr                 = kron(ones(S,1),cum_4yr);
    sfinsci                  = kron(ones(S,1),finalMajorSci);
    scum_school              = scum_2yr+scum_4yr;
    obs_abil_vec             = zeros(size(prior_ability_4S_vec));
    obs_abil_vec(sfinsci==1) = prior_ability_4S_vec(sfinsci==1);
    obs_abil_vec(sfinsci==0) = prior_ability_4NS_vec(sfinsci==0);
    sprevs                   = [sprev_HS sprev_2yr sprev_4yrS sprev_4yrNS sprev_PT sprev_FT sprev_WC];
    debt2                    = (scum_2yr.*sloan2 + scum_4yr.*sloan4).*(1+intrate).^(sYSHS) + sloan2.*(1+intrate).^(sYSHS);
    debt4                    = (scum_2yr.*sloan2 + scum_4yr.*sloan4).*(1+intrate).^(sYSHS) + sloan4.*(1+intrate).^(sYSHS);
    debtn                    = (scum_2yr.*sloan2 + scum_4yr.*sloan4).*(1+intrate).^(sYSHS);

    %Non-grad flow utilities (last 6 before types are: grad_4yr, workWC, workPT, workFT, workPT*white_collar, workFT*white_collar)
    X2ftbc   = [(1-Beta).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multiplier.*([consump(:,1 )-Beta.*consump_t1(:,1 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) stype]];
    X2ftwc   = [(1-Beta).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multiplier.*([consump(:,2 )-Beta.*consump_t1(:,2 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) stype]];
    X2ptbc   = [(1-Beta).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multiplier.*([consump(:,3 )-Beta.*consump_t1(:,3 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) stype]];
    X2ptwc   = [(1-Beta).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multiplier.*([consump(:,4 )-Beta.*consump_t1(:,4 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) stype]];
    X2nw     = [(1-Beta).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multiplier.*([consump(:,5 )-Beta.*consump_t1(:,5 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N*T*S,5)                     stype]];
    X4sftbc  = [(1-Beta).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multiplier.*([consump(:,6 )-Beta.*consump_t1(:,6 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) stype]];
    X4sftwc  = [(1-Beta).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multiplier.*([consump(:,7 )-Beta.*consump_t1(:,7 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) stype]];
    X4sptbc  = [(1-Beta).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multiplier.*([consump(:,8 )-Beta.*consump_t1(:,8 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) stype]];
    X4sptwc  = [(1-Beta).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multiplier.*([consump(:,9 )-Beta.*consump_t1(:,9 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) stype]];
    X4snw    = [(1-Beta).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multiplier.*([consump(:,10)-Beta.*consump_t1(:,10)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N*T*S,5)                     stype]];
    X4nsftbc = [(1-Beta).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multiplier.*([consump(:,11)-Beta.*consump_t1(:,11)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) stype]];
    X4nsftwc = [(1-Beta).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multiplier.*([consump(:,12)-Beta.*consump_t1(:,12)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) stype]];
    X4nsptbc = [(1-Beta).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multiplier.*([consump(:,13)-Beta.*consump_t1(:,13)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) zeros(N*T*S,1) stype]];
    X4nsptwc = [(1-Beta).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multiplier.*([consump(:,14)-Beta.*consump_t1(:,14)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1)  ones(N*T*S,1) zeros(N*T*S,1) stype]];
    X4nsnw   = [(1-Beta).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multiplier.*([consump(:,15)-Beta.*consump_t1(:,15)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N*T*S,5)                     stype]];
    Xngwptbc = [(1-Beta).*[demogs zeros(N*T*S,1)   debtn debtn.^2./100] multiplier.*([consump(:,16)-Beta.*consump_t1(:,16)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N*T*S,1) zeros(N*T*S,4) stype]];
    Xngwptwc = [(1-Beta).*[demogs zeros(N*T*S,1)   debtn debtn.^2./100] multiplier.*([consump(:,17)-Beta.*consump_t1(:,17)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(N*T*S,1) zeros(N*T*S,4) stype]];
    Xngwftbc = [(1-Beta).*[demogs zeros(N*T*S,1)   debtn debtn.^2./100] multiplier.*([consump(:,18)-Beta.*consump_t1(:,18)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N*T*S,1) zeros(N*T*S,4) stype]];
    Xngwftwc = [(1-Beta).*[demogs zeros(N*T*S,1)   debtn debtn.^2./100] multiplier.*([consump(:,19)-Beta.*consump_t1(:,19)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(N*T*S,1) zeros(N*T*S,4) stype]];

    % Grad flow utilities -- these are interacted with the graduation dummy equaling one
    Xgwptbc  = [(1-Beta).*[demogs(:,1:10)] multiplier.*([consump_g(:,16)-Beta.*consump_g_t1(:,16)]-[consump_g(:,20)-Beta.*consump_g_t1(:,20)])];
    Xgwptwc  = [(1-Beta).*[demogs(:,1:10)] multiplier.*([consump_g(:,17)-Beta.*consump_g_t1(:,17)]-[consump_g(:,20)-Beta.*consump_g_t1(:,20)])];
    Xgwftbc  = [(1-Beta).*[demogs(:,1:10)] multiplier.*([consump_g(:,18)-Beta.*consump_g_t1(:,18)]-[consump_g(:,20)-Beta.*consump_g_t1(:,20)])];
    Xgwftwc  = [(1-Beta).*[demogs(:,1:10)] multiplier.*([consump_g(:,19)-Beta.*consump_g_t1(:,19)]-[consump_g(:,20)-Beta.*consump_g_t1(:,20)])];

    Utils = v2struct(sdemog,X2ftbc,X2ftwc,X2ptbc,X2ptwc,X2nw,X4sftbc,X4sftwc,X4sptbc,X4sptwc,X4snw,X4nsftbc,X4nsftwc,X4nsptbc,X4nsptwc,X4nsnw,Xngwptbc,Xngwptwc,Xngwftbc,Xngwftwc,Xgwptbc,Xgwptwc,Xgwftbc,Xgwftwc,stype,sprevs,sage);
end
