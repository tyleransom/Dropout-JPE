function Utils = createfutureflowsconsumpstruct(data,priorabilstruct,consumps,Beta,S,CRRA);

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
    N = size(black,1);
    sage = age;
    demogs=[ones(N,1) black hispanic HS_grades Parent_college born1980 born1981 born1982 born1983 famInc]; 
    sdemog = size(demogs,2);
    stype                          = [ismember(utype,1:4) ismember(utype,[1:2 5:6]) ismember(utype,[1 3 5 7])];
    obs_abil_vec                   = zeros(size(prior_ability_4S));
    obs_abil_vec(finalMajorSci==1) = prior_ability_4S(finalMajorSci==1);
    obs_abil_vec(finalMajorSci==0) = prior_ability_4NS(finalMajorSci==0);
    sprevs                         = [prev_HS prev_2yr prev_4yrS prev_4yrNS prev_PT prev_FT prev_WC];

    %Non-grad flow utilities (last 4 before types are: grad_4yr, workWC, workPT, workFT)
    X2ftbc   = [(1-Beta).*[demogs prior_ability_2  ] multiplier.*([consump(:,1 )-Beta.*consump_t1(:,1 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1) zeros(N,1) zeros(N,1)  ones(N,1) zeros(N,1) zeros(N,1) stype]];
    X2ftwc   = [(1-Beta).*[demogs prior_ability_2  ] multiplier.*([consump(:,2 )-Beta.*consump_t1(:,2 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1)  ones(N,1) zeros(N,1)  ones(N,1) zeros(N,1)  ones(N,1) stype]];
    X2ptbc   = [(1-Beta).*[demogs prior_ability_2  ] multiplier.*([consump(:,3 )-Beta.*consump_t1(:,3 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1) zeros(N,1)  ones(N,1) zeros(N,1) zeros(N,1) zeros(N,1) stype]];
    X2ptwc   = [(1-Beta).*[demogs prior_ability_2  ] multiplier.*([consump(:,4 )-Beta.*consump_t1(:,4 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1)  ones(N,1)  ones(N,1) zeros(N,1)  ones(N,1) zeros(N,1) stype]];
    X2nw     = [(1-Beta).*[demogs prior_ability_2  ] multiplier.*([consump(:,5 )-Beta.*consump_t1(:,5 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[                    zeros(N,6)              stype]];
    X4sftbc  = [(1-Beta).*[demogs prior_ability_4S ] multiplier.*([consump(:,6 )-Beta.*consump_t1(:,6 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1) zeros(N,1) zeros(N,1)  ones(N,1) zeros(N,1) zeros(N,1) stype]];
    X4sftwc  = [(1-Beta).*[demogs prior_ability_4S ] multiplier.*([consump(:,7 )-Beta.*consump_t1(:,7 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1)  ones(N,1) zeros(N,1)  ones(N,1) zeros(N,1)  ones(N,1) stype]];
    X4sptbc  = [(1-Beta).*[demogs prior_ability_4S ] multiplier.*([consump(:,8 )-Beta.*consump_t1(:,8 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1) zeros(N,1)  ones(N,1) zeros(N,1) zeros(N,1) zeros(N,1) stype]];
    X4sptwc  = [(1-Beta).*[demogs prior_ability_4S ] multiplier.*([consump(:,9 )-Beta.*consump_t1(:,9 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1)  ones(N,1)  ones(N,1) zeros(N,1)  ones(N,1) zeros(N,1) stype]];
    X4snw    = [(1-Beta).*[demogs prior_ability_4S ] multiplier.*([consump(:,10)-Beta.*consump_t1(:,10)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[                    zeros(N,6)              stype]];
    X4nsftbc = [(1-Beta).*[demogs prior_ability_4NS] multiplier.*([consump(:,11)-Beta.*consump_t1(:,11)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1) zeros(N,1) zeros(N,1)  ones(N,1) zeros(N,1) zeros(N,1) stype]];
    X4nsftwc = [(1-Beta).*[demogs prior_ability_4NS] multiplier.*([consump(:,12)-Beta.*consump_t1(:,12)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1)  ones(N,1) zeros(N,1)  ones(N,1) zeros(N,1)  ones(N,1) stype]];
    X4nsptbc = [(1-Beta).*[demogs prior_ability_4NS] multiplier.*([consump(:,13)-Beta.*consump_t1(:,13)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1) zeros(N,1)  ones(N,1) zeros(N,1) zeros(N,1) zeros(N,1) stype]];
    X4nsptwc = [(1-Beta).*[demogs prior_ability_4NS] multiplier.*([consump(:,14)-Beta.*consump_t1(:,14)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1)  ones(N,1)  ones(N,1) zeros(N,1)  ones(N,1) zeros(N,1) stype]];
    X4nsnw   = [(1-Beta).*[demogs prior_ability_4NS] multiplier.*([consump(:,15)-Beta.*consump_t1(:,15)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[                    zeros(N,6)              stype]];
    Xngwptbc = [(1-Beta).*[demogs zeros(N,1)       ] multiplier.*([consump(:,16)-Beta.*consump_t1(:,16)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1) zeros(N,1) zeros(N,4)            stype]];
    Xngwptwc = [(1-Beta).*[demogs zeros(N,1)       ] multiplier.*([consump(:,17)-Beta.*consump_t1(:,17)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1)  ones(N,1) zeros(N,4)            stype]];
    Xngwftbc = [(1-Beta).*[demogs zeros(N,1)       ] multiplier.*([consump(:,18)-Beta.*consump_t1(:,18)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1) zeros(N,1) zeros(N,4)            stype]];
    Xngwftwc = [(1-Beta).*[demogs zeros(N,1)       ] multiplier.*([consump(:,19)-Beta.*consump_t1(:,19)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(N,1)  ones(N,1) zeros(N,4)            stype]];

    % Grad flow utilities
    Xgwptbc  = [(1-Beta).*[demogs zeros(N,1)       ] multiplier.*([consump_g(:,16)-Beta.*consump_g_t1(:,16)]-[consump_g(:,20)-Beta.*consump_g_t1(:,20)]) sprevs (1-Beta).*[ ones(N,1) zeros(N,1) zeros(N,4)            stype]];
    Xgwptwc  = [(1-Beta).*[demogs zeros(N,1)       ] multiplier.*([consump_g(:,17)-Beta.*consump_g_t1(:,17)]-[consump_g(:,20)-Beta.*consump_g_t1(:,20)]) sprevs (1-Beta).*[ ones(N,1)  ones(N,1) zeros(N,4)            stype]];
    Xgwftbc  = [(1-Beta).*[demogs zeros(N,1)       ] multiplier.*([consump_g(:,18)-Beta.*consump_g_t1(:,18)]-[consump_g(:,20)-Beta.*consump_g_t1(:,20)]) sprevs (1-Beta).*[ ones(N,1) zeros(N,1) zeros(N,4)            stype]];
    Xgwftwc  = [(1-Beta).*[demogs zeros(N,1)       ] multiplier.*([consump_g(:,19)-Beta.*consump_g_t1(:,19)]-[consump_g(:,20)-Beta.*consump_g_t1(:,20)]) sprevs (1-Beta).*[ ones(N,1)  ones(N,1) zeros(N,4)            stype]];

    number2   = size(X2nw,2)-3;       % exclude consump, grad_4yr, whiteCollar dummy
    number4s  = size(X4snw,2)-3;      % exclude consump, grad_4yr, whiteCollar dummy
    number4ns = size(X4nsnw,2)-3;     % exclude consump, grad_4yr, whiteCollar dummy
    numberpt  = size(Xngwptbc,2)-6;   % exclude abil, consump,                    workPT/FT dummies
    numberft  = size(Xngwftbc,2)-7;   % exclude abil, consump, whiteCollar dummy, workPT/FT dummies
    numberwc  = size(Xngwftwc,2)-7;   % exclude abil, consump, whiteCollar dummy, workPT/FT dummies

    Utils = v2struct(sdemog,X2ftbc,X2ftwc,X2ptbc,X2ptwc,X2nw,X4sftbc,X4sftwc,X4sptbc,X4sptwc,X4snw,X4nsftbc,X4nsftwc,X4nsptbc,X4nsptwc,X4nsnw,Xngwptbc,Xngwptwc,Xngwftbc,Xngwftwc,Xgwptbc,Xgwptwc,Xgwftbc,Xgwftwc,stype,sprevs,sage,grad_4yr,number2,number4s,number4ns,numberpt,numberft,numberwc);
end 