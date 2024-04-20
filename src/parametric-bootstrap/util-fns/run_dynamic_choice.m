function [strucparms] = run_dynamic_choice(AdjNG,AdjG,staticparms,learnparms,gradparms,learnStruct,dataStruct,consumpstructMCint,A,S,PmajgpaType,Beta,interestrate,Clb,CRRA,guess,ipath)

    %------------------------------------------------------------------------------
    % Recover posterior variances
    %------------------------------------------------------------------------------
    priorabilstruct = prior_ability_DDC(learnparms,learnStruct,dataStruct,S);

    %------------------------------------------------------------------------------
    % Estimate structural flow utility parameters
    %------------------------------------------------------------------------------
    tic
    % create graduation probabilities to put in flow utility estimation
    gprobdiffs = creategprobdiffs_b(dataStruct,priorabilstruct,gradparms,S);
    mgpd = mean(gprobdiffs,1);
    assert(sum(gprobdiffs(:))>0,'gprobdiffs is all zeros');
    assert(isequal(mgpd([1:5 16:19]),zeros(1,9)),'gprobdiffs is not zero for non-schooling alternatives');
    assert(all(mgpd([6:15])>zeros(1,10)),'gprobdiffs is zero for schooling alternatives');
    % create current-period and future-period flow utilities at same time
    Utilstruct = createfutureflowsconsumpstruct_b(dataStruct,priorabilstruct,consumpstructMCint,Beta,A,S,PmajgpaType,CRRA);
    % create some fields in the utd struct
    sdemog = Utilstruct.sdemog;
    Utilstruct.number2   = size(Utilstruct.X2nw,2)-3;       % exclude consump, grad_4yr, whiteCollar dummy
    Utilstruct.number4s  = size(Utilstruct.X4snw,2)-3;      % exclude consump, grad_4yr, whiteCollar dummy
    Utilstruct.number4ns = size(Utilstruct.X4nsnw,2)-3;     % exclude consump, grad_4yr, whiteCollar dummy
    Utilstruct.numberpt  = size(Utilstruct.Xngwptbc,2)-6;   % exclude abil, consump,                    workPT/FT dummies
    Utilstruct.numberft  = size(Utilstruct.Xngwftbc,2)-7;   % exclude abil, consump, whiteCollar dummy, workPT/FT dummies
    Utilstruct.numberwc  = size(Utilstruct.Xngwftwc,2)-7;   % exclude abil, consump, whiteCollar dummy, workPT/FT dummies
    % create current-period flow utilities only
    Utilstruct_static = createfutureflowsconsumpstruct_b(dataStruct,priorabilstruct,consumpstructMCint,0,A,S,PmajgpaType,CRRA);
    Utilstruct_static.number2   = size(Utilstruct.X2nw,2)-3;       % exclude consump, grad_4yr, whiteCollar dummy
    Utilstruct_static.number4s  = size(Utilstruct.X4snw,2)-3;      % exclude consump, grad_4yr, whiteCollar dummy
    Utilstruct_static.number4ns = size(Utilstruct.X4nsnw,2)-3;     % exclude consump, grad_4yr, whiteCollar dummy
    Utilstruct_static.numberpt  = size(Utilstruct.Xngwptbc,2)-6;   % exclude abil, consump,                    workPT/FT dummies
    Utilstruct_static.numberft  = size(Utilstruct.Xngwftbc,2)-7;   % exclude abil, consump, whiteCollar dummy, workPT/FT dummies
    Utilstruct_static.numberwc  = size(Utilstruct.Xngwftwc,2)-7;   % exclude abil, consump, whiteCollar dummy, workPT/FT dummies

    % starting values
    bstrucstruc0 = [3.117;2.112;-4.008;-0.085;0.044;-0.017;0.036;-0.187;-0.212;-0.180;-0.123;0.004;0.306;0.985;2.413;0.826;0.293;0.001;0.069;-0.035;0.682;-0.698;-0.416;-0.318;0.146;0.112;0.1026;-6.204;-0.124;-0.093;0.261;0.051;-0.319;-0.302;-0.083;-0.109;0.045;1.481;2.650;1.046;4.555;1.971;0.471;0.151;-0.362;-0.618;-1.408;0.227;0.957;0.309;0.293;0.3012;-4.934;-0.115;-0.041;0.221;0.063;-0.237;-0.149;-0.039;0.001;0.058;1.625;1.730;0.721;1.971;3.582;0.415;0.564;-0.112;-0.508;-1.837;0.181;0.365;0.107;0.134;0.1262;-3.279;0.044;-0.071;0.001;0.029;0.078;0.071;0.030;0.066;-0.014;1.185;0.043;0.665;0.628;2.222;0.986;-1.325;-0.232;-0.060;-0.104;-0.210;-0.2169;-3.289;0.037;-0.018;0.020;-0.029;0.150;0.084;0.031;0.032;-0.007;0.907;0.301;0.392;0.630;1.388;2.316;-1.491;-0.116;-0.082;-0.051;-0.021;-1.672;0.028;0.030;0.050;0.184;0.148;0.148;0.040;-0.038;-0.006;-0.599;0.110;-0.165;0.080;-0.981;-0.925;2.721;0.531;0.130;0.090;0.1263];
    assert(length(bstrucstruc0)==141,'problem with starting values');

    % estimate choice model
    o4=optimset('Disp','Iter','LargeScale','off','MaxFunEvals',2000000,'MaxIter',15000,'TolX',1e-6,'Tolfun',1e-6,'GradObj','on','DerivativeCheck','off','FinDiffType','central');
    [bstrucstruc,lstrucstruc,e,o,gstrucstruc,hstrucstruc]=fminunc('consumpsearchstrucmlogit',bstrucstruc0,o4,Utilstruct.Yl,staticparms.lambda,Utilstruct,Utilstruct.grad_4yrl,gprobdiffs,AdjNG,AdjG,Utilstruct.sdemog,S,PmajgpaType,Beta);
    strucparms.bstrucstruc = bstrucstruc;
    strucparms.lstrucstruc = lstrucstruc;
    strucparms.hstrucstruc = hstrucstruc;
end
