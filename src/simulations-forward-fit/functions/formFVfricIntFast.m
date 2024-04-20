function [AdjNG,AdjG] = formFVfricIntFast(beta,utd,BetaFric,BetaGrad,data,priorabilstruct,learnparms,AR1parms,S,Clb,CRRA,intrate,numDraws,b,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper,dddd)

    % create some fields in the utd struct
    sdemog = utd.sdemog;
    utd.number2   = size(utd.X2nw,2)-2;       % exclude consump, whiteCollar dummy
    utd.number4s  = size(utd.X4snw,2)-2;      % exclude consump, whiteCollar dummy
    utd.number4ns = size(utd.X4nsnw,2)-2;     % exclude consump, whiteCollar dummy
    utd.numberpt  = size(utd.Xngwptbc,2)-6;   % exclude abil, consump,                    workPT/FT dummies and interactions
    utd.numberft  = size(utd.Xngwftbc,2)-7;   % exclude abil, consump, whiteCollar dummy, workPT/FT dummies and interactions
    utd.numberwc  = size(utd.Xngwftwc,2)-9;   % exclude abil, consump, debt, debt^2, whiteCollar dummy, workPT/FT dummies and interactions
    utd.numbergpt = 10;                       % only subset of demographics
    utd.numbergft = 10;                       % only subset of demographics
    utd.numbergwc = 10;                       % only subset of demographics

    Xfric = [ones(size(utd.X2nw,1),1) data.age data.grad_4yr utd.X2nw(:,end-2:end)]; % covariates: constant, age, grad_4yr dummy, unobserved type dummies

    % Creating matrix to change state variables depending the path
    %Order of the variables
    %Column (1): Current Choice, Column (2): Lagged Choice, Column (3): age,
    %Column (4): 2 yr college years, Column (5): 4 yr college years,
    %Column (6): blue collar experience, Column (7): white collar experience
    %Column (8): graduate school years
    
    
    %Matrix of States [ (j=Home) t+1 | (k=choice) t ]
    M_h_j=zeros(20,8);
    % Choice Home at t+1
    M_h_j(:,1) = 20;
    % Choice k at t
    M_h_j(:,2) = 1:20;
    % Age at t+1
    M_h_j(:,3) = 1;
    % College 2yr
    M_h_j(1:5,4) = 1;
    % College 4yr
    M_h_j(6:15,5) = 1;
    % Exper. 
    M_h_j([1:2 6:7 11:12 18:19],6) = 1;
    M_h_j([3:4 8:9 13:14 16:17],6) = 0.5; 
    % Exper. White Collar
    M_h_j([2:5:12 19],7) = 1;
    M_h_j([4:5:14 17],7) = 0.5;
    
    
    %Matrix of States [ (j=choice) t+1 | (k=Home) t ]
    M_j_h=zeros(20,8);
    % Choice j at t+1
    M_j_h(:,1) = 1:20;
    % Choice Home t
    M_j_h(:,2) = 20;
    % Age at t+1
    M_j_h(:,3) = 1;
    
    
    %Matrix of States [ (j=home t+2) | (k=home) t , (k=choice) t+1 ]
    M_h_h_j=zeros(20,8);
    % Choice Home at t+2
    M_h_h_j(:,1) = 20;
    % Choice k at t+1
    M_h_h_j(:,2) = 1:20;
    % Age at t+2
    M_h_h_j(:,3) = 2;
    % College 2yr
    M_h_h_j(1:5,4) = 1;
    % College 4yr
    M_h_h_j(6:15,5) = 1;
    % Exper. 
    M_h_h_j([1:2 6:7 11:12 18:19],6) = 1;
    M_h_h_j([3:4 8:9 13:14 16:17],6) = 0.5; 
    % Exper. White Collar
    M_h_h_j([2:5:12 19],7) = 1;
    M_h_h_j([4:5:14 17],7) = 0.5;
    
    
    %Matrix of States [ (j=home t+2) | (k=choice) t , (k=home) t+1 ]
    M_h_j_h=zeros(20,8);
    % Choice Home at t+2
    M_h_j_h(:,1) = 20;
    % Choice home at t+1
    M_h_j_h(:,2) = 20;
    % Age at t+2
    M_h_j_h(:,3) = 2;
    % College 2yr
    M_h_j_h(1:5,4) = 1;
    % College 4yr
    M_h_j_h(6:15,5) = 1;
    % Exper. 
    M_h_j_h([1:2 6:7 11:12 18:19],6) = 1;
    M_h_j_h([3:4 8:9 13:14 16:17],6) = 0.5; 
    % Exper. White Collar
    M_h_j_h([2:5:12 19],7) = 1;
    M_h_j_h([4:5:14 17],7) = 0.5;
    
    
    %Ordering and including everything in one big matrix
    %1  "2yr & FT, blue collar"
    %2  "2yr & FT, white collar"
    %3  "2yr & PT, blue collar"
    %4  "2yr & PT, white collar"
    %5  "2yr & No Work"
    %6  "4yr Science & FT, blue collar"
    %7  "4yr Science & FT, white collar"
    %8  "4yr Science & PT, blue collar"
    %9  "4yr Science & PT, white collar"
    %10 "4yr Science & No Work"
    %11 "4yr Humanities & FT, blue collar"
    %12 "4yr Humanities & FT, white collar"
    %13 "4yr Humanities & PT, blue collar"
    %14 "4yr Humanities & PT, white collar"
    %15 "4yr Humanities & No Work"
    %16 "Work PT, blue collar"
    %17 "Work PT, white collar"
    %18 "Work FT, blue collar"
    %19 "Work FT, white collar"
    %20 "Home"
    
    %CCPs states [Each row of each matrix corresponds to a separate choice alternative of the model]
    % FD path 1: choice t, home t+1, home t+2
    %          = M1, M4
    % FD path 1: home t, choice t+1, home t+2
    %          = M5, M3
    
    % Home at t+1 | Choice at t
    M1=M_h_j;
    % Home at t+2 | Choice at t, Home at t+1
    M4=M_h_j_h;
    % Choice at t+1 | Home at t
    M5=M_j_h;
    % Home at t+2 | Home at t, Choice at t+1 
    M3=M_h_h_j;
    
    %Meaning of each column of M1-M5
    %Column (1): Current Choice, 
    %Column (2): Lagged Choice, 
    %Column (3): age,
    %Column (4): 2 yr college years, 
    %Column (5): 4 yr college years, 
    %Column (6): blue collar experience, 
    %Column (7): white collar experience
    %Column (8): graduate school years
    
    clear M_h_j M_h_h_j M_h_j_h M_j_h
    
    Ad1a=[];
    Ad2a=[];
    Ad3a=[];
    Ad4a=[];
    Ad5a=[];
    
    Ad1aa=[];
    Ad2aa=[];
    Ad3aa=[];
    Ad4aa=[];
    
    Ad1b=[];
    Ad2b=[];
    Ad3b=[];
    Ad4b=[];
    Ad5b=[];
    
    Ad1bb=[];
    Ad2bb=[];
    Ad3bb=[];
    Ad4bb=[];
    
    Ad_finala=[];
    Ad_finalb=[];
    
    AdjNG = zeros(length(data.grad_4yr),1);
    AdjG  = zeros(length(data.grad_4yr),1);
    
    % loop control:
    % FVstates.gflag governs whether the pr of graduation enters the FV term (and whether it is pgrad or 1-pgrad)
    % FVstates.gtemp governs whether the graduate or undergraduate choice set shoud be used to compute the choice probability
    % FVstates.otemp governs whether an offer was received
    % FVstates.special1 governs whether we are on the branch without offer probabilities
    % FVstates.special2 governs whether we are on the special1 branch with a negative offer probability

    FVstates.special1 = 0;
    FVstates.special2 = 0;

    for w = 1:20
        Xgrad = createXgrad(data,priorabilstruct,w);
        %disp(['w = ',num2str(w)]);
        if w<=5 || (w>=16 && w<=20) % non-graduate, non-4yr
            FVstates.gflag = [];
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            % Home at t+1 | Choice at t
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            %tic
            [Ad1a,lam1a,gp1a,P1a,utild1a]  = overallFast(beta,M1,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            %disp(['Time spent on overall function: ',num2str(toc/60),' minutes']);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad1aa,lam1aa,gp1aa,P1aa,utild1aa] = overallFast(beta,M1,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
        end
        % Home at t+1 | Choice at t, graduate
        if w>=16 % graduate
            FVstates.gflag = [];
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            [Ad1b,lam1b,gp1b,P1b,utild1b] = overallFast(beta,M1,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad1bb,lam1bb,gp1bb,P1bb,utild1bb] = overallFast(beta,M1,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
        end
        if w>=6 && w<=15 % 4yr (induces branches for each possible graduation outcome)
            % Home at t+1 | Choice at t, p(grad=1)
            FVstates.gflag = 1;
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            [Ad1c_g,lam1c_g,gp1c_g,P1c_g,utild1c_g] = overallFast(beta,M1,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad1cc_g,lam1cc_g,gp1cc_g,P1cc_g,utild1cc_g] = overallFast(beta,M1,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            % Home at t+1 | Choice at t, p(grad=0)
            FVstates.gflag = 0;
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            [Ad1c_ng,lam1c_ng,gp1c_ng,P1c_ng,utild1c_ng] = overallFast(beta,M1,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad1cc_ng,lam1cc_ng,gp1cc_ng,P1cc_ng,utild1cc_ng] = overallFast(beta,M1,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);          
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Home at t+2 | Choice at t, Home at t+1
        if w<=5 || (w>=16 && w<=20) % non-graduate, non-4yr
            FVstates.gflag = [];
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            [Ad4a,lam4a,gp4a,P4a,utild4a] = overallFast(beta,M4,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad4aa,lam4aa,gp4aa,P4aa,utild4aa] = overallFast(beta,M4,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
        end
        % Home at t+2 | Choice at t, Home at t+1, graduate
        if w>=16 % graduate
            FVstates.gflag = [];
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            [Ad4b,lam4b,gp4b,P4b,utild4b] = overallFast(beta,M4,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad4bb,lam4bb,gp4bb,P4bb,utild4b] = overallFast(beta,M4,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
        end
        if w>=6 && w<=15 % 4yr (induces branches for each possible graduation outcome)
            % Home at t+2 | Choice at t, Home at t+1, P(grad=1)
            FVstates.gflag = 1;
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            [Ad4c_g,lam4c_g,gp4c_g,P4c_g,utild4c_g] = overallFast(beta,M4,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad4cc_g,lam4cc_g,gp4cc_g,P4cc_g,utild4cc_g] = overallFast(beta,M4,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            % Home at t+2 | Choice at t, Home at t+1, P(grad=0)
            FVstates.gflag = 0;
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            [Ad4c_ng,lam4c_ng,gp4c_ng,P4c_ng,utild4c_ng] = overallFast(beta,M4,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad4cc_ng,lam4cc_ng,gp4cc_ng,P4cc_ng,utild4cc_ng] = overallFast(beta,M4,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
        end
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Choice at t+1 | Home at t
        if w<=5 || (w>=16 && w<=20) % non-graduate, non-4yr
            FVstates.gflag = [];
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            FVstates.special1 = 1;
            [Ad2a,lam2a,gp2a,P2a,utild2a] = overallFast(beta,M5,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.special2 = 1;
            [Ad5a,lam5a,gp5a,P5a,utild5a] = overallFast(beta,M5,w, w,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad2aa,lam2aa,gp2aa,P2aa,utild2aa] = overallFast(beta,M5,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.special1 = 0; % reset these to zero
            FVstates.special2 = 0; % reset these to zero
        end
        % Choice at t+1 | Home at t, graduate
        if w>=16
            FVstates.gflag = [];
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            FVstates.special1 = 1;
            [Ad2b,lam2b,gp2b,P2b,utild2b] = overallFast(beta,M5,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.special2 = 1;
            [Ad5b,lam5b,gp5b,P5b,utild5b] = overallFast(beta,M5,w, w,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad2bb,lam2bb,gp2bb,P2bb,utild2bb] = overallFast(beta,M5,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);     
            FVstates.special1 = 0; % reset these to zero
            FVstates.special2 = 0; % reset these to zero
        end
        if w>=6 && w<=15 % 4yr (note that this does NOT induce branches for each possible graduation outcome) No graduate
            FVstates.gflag = [];
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            FVstates.special1 = 1;
            [Ad2c,lam2c,gp2c,P2c,utild2c] = overallFast(beta,M5,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.special2 = 1;
            [Ad5c,lam5c,gp5c,P5c,utild5c] = overallFast(beta,M5,w, w,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad2cc,lam2cc,gp2cc,P2cc,utild2cc] = overallFast(beta,M5,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.special1 = 0; % reset these to zero
            FVstates.special2 = 0; % reset these to zero
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Home at t+2 | Home at t, Choice at t+1
        if w<=5 || (w>=16 && w<=20) % non-graduate, non-4yr
            FVstates.gflag = [];
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            [Ad3a,lam3a,gp3a,P3a,utild3a] = overallFast(beta,M3,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad3aa,lam3aa,gp3aa,P3aa,utild3aa] = overallFast(beta,M3,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
        end
        % Home at t+2 | Home at t, Choice at t+1, graduate
        if w>=16 % graduate
            FVstates.gflag = [];
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            [Ad3b,lam3b,gp3b,P3b,utild3b] = overallFast(beta,M3,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad3bb,lam3bb,gp3bb,P3bb,utild3bb] = overallFast(beta,M3,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
        end
        if w>=6 && w<=15 % 4yr (induces branches for each possible graduation outcome)
            % Home at t+2 | Home at t, Choice at t+1, p(grad==1)
            FVstates.gflag = 1;
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            [Ad3c_g,lam3c_g,gp3c_g,P3c_g,utild3c_g] = overallFast(beta,M3,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad3cc_g,lam3cc_g,gp3cc_g,P3cc_g,utild3cc_g] = overallFast(beta,M3,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            % Home at t+2 | Home at t, Choice at t+1, p(grad==0)
            FVstates.gflag = 0;
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            [Ad3c_ng,lam3c_ng,gp3c_ng,P3c_ng,utild3c_ng] = overallFast(beta,M3,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            [Ad3cc_ng,lam3cc_ng,gp3cc_ng,P3cc_ng,utild3cc_ng] = overallFast(beta,M3,w,20,b,utd,FVstates,sdemog,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2,timeper);
        end
        
        if w<=5 || (w>=16 && w<=20) % non-graduate, non-4yr
            Ad_finala=Ad1a-Ad2a-Ad3a+Ad4a-Ad5a+Ad1aa-Ad2aa-Ad3aa+Ad4aa; %adding terms for when receive and do not receive offer conditional on non-graduate (choices that do not lead to graduation)
            AdjNG(:,w) = Ad_finala;
        end
        if w>=16 % graduate
            Ad_finalb=Ad1b-Ad2b-Ad3b+Ad4b-Ad5b+Ad1bb-Ad2bb-Ad3bb+Ad4bb; %adding terms for when receive and do not receive offer condiitonal on graduate
            AdjG(:,w)  = Ad_finalb;
        end
        if w>=6 && w<=15 % 4yr (add across branches stemming from each possible graduation outcome)
            Ad_finalc=Ad1c_g-Ad3c_g+Ad4c_g+Ad1cc_g-Ad3cc_g+Ad4cc_g+Ad1c_ng-Ad3c_ng+Ad4c_ng+Ad1cc_ng-Ad3cc_ng+Ad4cc_ng-Ad5c-Ad2c-Ad2cc;  %adding terms for when receive and do not receive offer but choices that could lead to graduation (i.e. including Pgrad)
            AdjNG(:,w) = Ad_finalc;
        end
    end
end   
