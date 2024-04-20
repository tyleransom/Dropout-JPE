function [AdjNG,AdjG] = formFVfricIntFast_b(beta,utd,BetaFric,BetaGrad,Xgrad,data,priorabilstruct,learnparms,AR1parms,A,S,Clb,CRRA,intrate,numDraws,b,Y,cmapStruct,cmapStruct_t1,cmapStruct_t2)

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

    Xfric = [ones(size(utd.X2nw,1),1) utd.sage utd.grad_4yrlImps utd.X2nw(:,end-2:end)]; % covariates: constant, age, grad_4yr dummy, unobserved type dummies
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
    
    AdjNG = zeros(length(utd.grad_4yrlImps),20);
    AdjG  = zeros(length(utd.grad_4yrlImps),20);
    
    % loop control:
    % FVstates.gflag governs whether the pr of graduation enters the FV term (and whether it is pgrad or 1-pgrad)
    % FVstates.gtemp governs whether the graduate or undergraduate choice set shoud be used to compute the choice probability
    % FVstates.otemp governs whether an offer was received
    % FVstates.special1 governs whether we are on the branch without offer probabilities
    % FVstates.special2 governs whether we are on the special1 branch with a negative offer probability

    FVstates.special1 = 0;
    FVstates.special2 = 0;

    for w = 1:20
        if w<=5 || (w>=16 && w<=20) % non-graduate, non-4yr
            FVstates.gflag = [];
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            % Home at t+1 | Choice at t
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            tic
            Ad1a  = overallFast_b(beta,M1,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            disp(['Time spent on overall function: ',num2str(toc/60),' minutes']);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad1aa = overallFast_b(beta,M1,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
        end
        % Home at t+1 | Choice at t, graduate
        if w>=16 % graduate
            FVstates.gflag = [];
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            Ad1b = overallFast_b(beta,M1,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad1bb= overallFast_b(beta,M1,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
        end
        if w>=6 && w<=15 % 4yr (induces branches for each possible graduation outcome)
            % Home at t+1 | Choice at t, p(grad=1)
            FVstates.gflag = 1;
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            Ad1c_g = overallFast_b(beta,M1,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad1cc_g= overallFast_b(beta,M1,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            % Home at t+1 | Choice at t, p(grad=0)
            FVstates.gflag = 0;
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            Ad1c_ng = overallFast_b(beta,M1,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad1cc_ng= overallFast_b(beta,M1,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);          
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Home at t+2 | Choice at t, Home at t+1
        if w<=5 || (w>=16 && w<=20) % non-graduate, non-4yr
            FVstates.gflag = [];
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            Ad4a = overallFast_b(beta,M4,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad4aa= overallFast_b(beta,M4,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
           
        end
        % Home at t+2 | Choice at t, Home at t+1, graduate
        if w>=16 % graduate
            FVstates.gflag = [];
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            Ad4b = overallFast_b(beta,M4,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad4bb= overallFast_b(beta,M4,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
        end
        if w>=6 && w<=15 % 4yr (induces branches for each possible graduation outcome)
            % Home at t+2 | Choice at t, Home at t+1, P(grad=1)
            FVstates.gflag = 1;
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            Ad4c_g = overallFast_b(beta,M4,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad4cc_g= overallFast_b(beta,M4,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            % Home at t+2 | Choice at t, Home at t+1, P(grad=0)
            FVstates.gflag = 0;
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            Ad4c_ng = overallFast_b(beta,M4,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad4cc_ng= overallFast_b(beta,M4,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
        end
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Choice at t+1 | Home at t
        if w<=5 || (w>=16 && w<=20) % non-graduate, non-4yr
            FVstates.gflag = [];
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            FVstates.special1 = 1;
            Ad2a = overallFast_b(beta,M5,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.special2 = 1;
            Ad5a = overallFast_b(beta,M5,w, w,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad2aa= overallFast_b(beta,M5,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.special1 = 0; % reset these to zero
            FVstates.special2 = 0; % reset these to zero
        end
        % Choice at t+1 | Home at t, graduate
        if w>=16
            FVstates.gflag = [];
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            FVstates.special1 = 1;
            Ad2b = overallFast_b(beta,M5,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.special2 = 1;
            Ad5b = overallFast_b(beta,M5,w, w,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad2bb= overallFast_b(beta,M5,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);     
            FVstates.special1 = 0; % reset these to zero
            FVstates.special2 = 0; % reset these to zero
        end
        if w>=6 && w<=15 % 4yr (note that this does NOT induce branches for each possible graduation outcome) No graduate
            FVstates.gflag = [];
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            FVstates.special1 = 1;
            Ad2c = overallFast_b(beta,M5,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.special2 = 1;
            Ad5c = overallFast_b(beta,M5,w, w,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad2cc= overallFast_b(beta,M5,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.special1 = 0; % reset these to zero
            FVstates.special2 = 0; % reset these to zero
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Home at t+2 | Home at t, Choice at t+1
        if w<=5 || (w>=16 && w<=20) % non-graduate, non-4yr
            FVstates.gflag = [];
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            Ad3a = overallFast_b(beta,M3,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad3aa= overallFast_b(beta,M3,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
     
        end
        % Home at t+2 | Home at t, Choice at t+1, graduate
        if w>=16 % graduate
            FVstates.gflag = [];
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            Ad3b = overallFast_b(beta,M3,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad3bb= overallFast_b(beta,M3,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
        end
        if w>=6 && w<=15 % 4yr (induces branches for each possible graduation outcome)
            % Home at t+2 | Home at t, Choice at t+1, p(grad==1)
            FVstates.gflag = 1;
            FVstates.gtemp = 1*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            Ad3c_g = overallFast_b(beta,M3,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad3cc_g= overallFast_b(beta,M3,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            % Home at t+2 | Home at t, Choice at t+1, p(grad==0)
            FVstates.gflag = 0;
            FVstates.gtemp = 0*ones(size(Xfric,1),1);
            FVstates.otemp = 1*ones(size(Xfric,1),1);
            Ad3c_ng = overallFast_b(beta,M3,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
            FVstates.otemp = 0*ones(size(Xfric,1),1);
            Ad3cc_ng= overallFast_b(beta,M3,w,20,b,Y,utd,FVstates,sdemog,A,S,data,priorabilstruct,learnparms,AR1parms,Clb,CRRA,intrate,numDraws,BetaFric,Xfric,BetaGrad,Xgrad,cmapStruct,cmapStruct_t1,cmapStruct_t2);
        end
        
        if w<=5 || (w>=16 && w<=20) % non-graduate, non-4yr
            Ad_finala=Ad1a-Ad2a-Ad3a+Ad4a-Ad5a+Ad1aa-Ad2aa-Ad3aa+Ad4aa; %adding terms for when receive and do not receive offer conditional on non-graduate (choices that do not lead to graduation)
            AdjNG(:,w)=Ad_finala;
        end
        if w>=16 % graduate
            Ad_finalb=Ad1b-Ad2b-Ad3b+Ad4b-Ad5b+Ad1bb-Ad2bb-Ad3bb+Ad4bb; %adding terms for when receive and do not receive offer condiitonal on graduate
            AdjG(:,w) = Ad_finalb;
        end
        if w>=6 && w<=15 % 4yr (add across branches stemming from each possible graduation outcome)
            Ad_finalc=Ad1c_g-Ad3c_g+Ad4c_g+Ad1cc_g-Ad3cc_g+Ad4cc_g+Ad1c_ng-Ad3c_ng+Ad4c_ng+Ad1cc_ng-Ad3cc_ng+Ad4cc_ng-Ad5c-Ad2c-Ad2cc;  %adding terms for when receive and do not receive offer but choices that could lead to graduation (i.e. including Pgrad)
            AdjNG(:,w)=Ad_finalc;
        end
    end
end  
