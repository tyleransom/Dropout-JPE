function Utils = createfutureflowsconsump(data,priorabilstruct,consumps,Beta,S,num_GPA_pctiles,intrate,CRRA);

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
    [~,demogs]               = makegrid(demog,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    demogs                   = demogs(:,1:end-(S-1));
    [~,sloan4]               = makegrid(E_loan4_18.*(1+intrate).^(yrsSinceHS)./1000,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sloan2]               = makegrid(E_loan2_18.*(1+intrate).^(yrsSinceHS)./1000,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sprev_HS]             = makegrid(prev_HS,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sprev_2yr]            = makegrid(prev_2yr,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sprev_4yrS]           = makegridchoice(prev_4yrS,asifsci.prev_4yrS,asifhum.prev_4yrS,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sprev_4yrNS]          = makegridchoice(prev_4yrNS,asifsci.prev_4yrNS,asifhum.prev_4yrNS,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sprev_PT]             = makegrid(prev_PT,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sprev_FT]             = makegrid(prev_FT,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sprev_WC]             = makegrid(prev_WC,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sage]                 = makegrid(age,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,smale]                = makegrid(male,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sgrad_4yr]            = makegrid(grad_4yr,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
           A                 = [1 1 1; 1 1 0; 1 0 1; 1 0 0; 0 1 1; 0 1 0; 0 0 1; 0 0 0];
       stype                 = kron(A,ones(Ntilde*T,1));
    [~,sYSHS]                = makegrid(yrsSinceHS,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,scum_2yr]             = makegrid(cum_2yr,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,scum_4yr]             = makegrid(cum_4yr,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,sfinsci]              = makegrid(finalMajorSci,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
       scum_school           = scum_2yr+scum_4yr;
    obs_abil_vec             = zeros(size(prior_ability_4S_vec));
    obs_abil_vec(sfinsci==1) = prior_ability_4S_vec(sfinsci==1);
    obs_abil_vec(sfinsci==0) = prior_ability_4NS_vec(sfinsci==0);
    sprevs                   = [sprev_HS sprev_2yr sprev_4yrS sprev_4yrNS sprev_PT sprev_FT sprev_WC];
    debt2                    = (scum_2yr.*sloan2 + scum_4yr.*sloan4).*(1+intrate).^(sYSHS) + sloan2.*(1+intrate).^(sYSHS);
    debt4                    = (scum_2yr.*sloan2 + scum_4yr.*sloan4).*(1+intrate).^(sYSHS) + sloan4.*(1+intrate).^(sYSHS);
    debtn                    = (scum_2yr.*sloan2 + scum_4yr.*sloan4).*(1+intrate).^(sYSHS);

    %Non-grad flow utilities (last 6 before types are: grad_4yr, workWC, workPT, workFT, workPT*white_collar, workFT*white_collar)
    X2ftbc   = [(1-Beta).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multiplier.*([consump(:,1 )-Beta.*consump_t1(:,1 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,1) stype]];
    X2ftwc   = [(1-Beta).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multiplier.*([consump(:,2 )-Beta.*consump_t1(:,2 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) stype]];
    X2ptbc   = [(1-Beta).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multiplier.*([consump(:,3 )-Beta.*consump_t1(:,3 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,1) stype]];
    X2ptwc   = [(1-Beta).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multiplier.*([consump(:,4 )-Beta.*consump_t1(:,4 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1) stype]];
    X2nw     = [(1-Beta).*[demogs prior_ability_2_vec   debt2 debt2.^2./100] multiplier.*([consump(:,5 )-Beta.*consump_t1(:,5 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(Ntilde*T*S,5)                     stype]];
    X4sftbc  = [(1-Beta).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multiplier.*([consump(:,6 )-Beta.*consump_t1(:,6 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,1) stype]];
    X4sftwc  = [(1-Beta).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multiplier.*([consump(:,7 )-Beta.*consump_t1(:,7 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) stype]];
    X4sptbc  = [(1-Beta).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multiplier.*([consump(:,8 )-Beta.*consump_t1(:,8 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,1) stype]];
    X4sptwc  = [(1-Beta).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multiplier.*([consump(:,9 )-Beta.*consump_t1(:,9 )]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1) stype]];
    X4snw    = [(1-Beta).*[demogs prior_ability_4S_vec  debt4 debt4.^2./100] multiplier.*([consump(:,10)-Beta.*consump_t1(:,10)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(Ntilde*T*S,5)                     stype]];
    X4nsftbc = [(1-Beta).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multiplier.*([consump(:,11)-Beta.*consump_t1(:,11)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,1) stype]];
    X4nsftwc = [(1-Beta).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multiplier.*([consump(:,12)-Beta.*consump_t1(:,12)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) stype]];
    X4nsptbc = [(1-Beta).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multiplier.*([consump(:,13)-Beta.*consump_t1(:,13)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,1) stype]];
    X4nsptwc = [(1-Beta).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multiplier.*([consump(:,14)-Beta.*consump_t1(:,14)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1)  ones(Ntilde*T*S,1) zeros(Ntilde*T*S,1) stype]];
    X4nsnw   = [(1-Beta).*[demogs prior_ability_4NS_vec debt4 debt4.^2./100] multiplier.*([consump(:,15)-Beta.*consump_t1(:,15)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(Ntilde*T*S,5)                     stype]];
    Xngwptbc = [(1-Beta).*[demogs zeros(Ntilde*T*S,1)   debtn debtn.^2./100] multiplier.*([consump(:,16)-Beta.*consump_t1(:,16)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,4) stype]];
    Xngwptwc = [(1-Beta).*[demogs zeros(Ntilde*T*S,1)   debtn debtn.^2./100] multiplier.*([consump(:,17)-Beta.*consump_t1(:,17)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(Ntilde*T*S,1) zeros(Ntilde*T*S,4) stype]];
    Xngwftbc = [(1-Beta).*[demogs zeros(Ntilde*T*S,1)   debtn debtn.^2./100] multiplier.*([consump(:,18)-Beta.*consump_t1(:,18)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[zeros(Ntilde*T*S,1) zeros(Ntilde*T*S,4) stype]];
    Xngwftwc = [(1-Beta).*[demogs zeros(Ntilde*T*S,1)   debtn debtn.^2./100] multiplier.*([consump(:,19)-Beta.*consump_t1(:,19)]-[consump(:,20)-Beta.*consump_t1(:,20)]) sprevs (1-Beta).*[ ones(Ntilde*T*S,1) zeros(Ntilde*T*S,4) stype]];

    % Grad flow utilities -- these are interacted with the graduation dummy equaling one
    Xgwptbc  = [(1-Beta).*[demogs(:,1:10)] multiplier.*([consump_g(:,16)-Beta.*consump_g_t1(:,16)]-[consump_g(:,20)-Beta.*consump_g_t1(:,20)])];
    Xgwptwc  = [(1-Beta).*[demogs(:,1:10)] multiplier.*([consump_g(:,17)-Beta.*consump_g_t1(:,17)]-[consump_g(:,20)-Beta.*consump_g_t1(:,20)])];
    Xgwftbc  = [(1-Beta).*[demogs(:,1:10)] multiplier.*([consump_g(:,18)-Beta.*consump_g_t1(:,18)]-[consump_g(:,20)-Beta.*consump_g_t1(:,20)])];
    Xgwftwc  = [(1-Beta).*[demogs(:,1:10)] multiplier.*([consump_g(:,19)-Beta.*consump_g_t1(:,19)]-[consump_g(:,20)-Beta.*consump_g_t1(:,20)])];
    
    % unit tests
    assert(size(demog,2)==16,'demog is wrong number of columns');
    assert(size(demogs,2)==16,['demogs is wrong number of columns ... it should be 16 but instead it''s ',num2str(size(demogs,2))]);
    assert(size(prior_ability_2_vec,2)==1,'prior_ability_2_vec is wrong number of columns');
    assert(size(debt2,2)==1,'debt2 is wrong number of columns');
    assert(size(multiplier.*([consump(:,5 )-Beta.*consump_t1(:,5 )]-[consump(:,20)-Beta.*consump_t1(:,20)]),2)==1,'consumption is wrong number of columns');
    assert(size(sprevs,2)==7,'sprevs is wrong number of columns');
    assert(size(stype,2)==3,'stype is wrong number of columns');
    assert(size(X2nw,2)==35,'X2nw is wrong number of columns');

    Utils = v2struct(sdemog,X2ftbc,X2ftwc,X2ptbc,X2ptwc,X2nw,X4sftbc,X4sftwc,X4sptbc,X4sptwc,X4snw,X4nsftbc,X4nsftwc,X4nsptbc,X4nsptwc,X4nsnw,Xngwptbc,Xngwptwc,Xngwftbc,Xngwftwc,Xgwptbc,Xgwptwc,Xgwftbc,Xgwftwc,stype,sprevs,sage);
end
