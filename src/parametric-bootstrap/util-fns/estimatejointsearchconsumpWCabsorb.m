function parms = estimatejointsearchconsumpWCabsorb(utd,PmajgpaType,guess,S,restart,ipath);

    %------------------------------------------
    % Preliminaries for joint likelihood
    %------------------------------------------
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

    o4   = optimset('Disp','Iter','LargeScale','off','MaxFunEvals',2000000,'MaxIter',15000,'TolX',1e-6,'Tolfun',1e-6,'GradObj','on', 'DerivativeCheck','off','FinDiffType','central');
    o5Nu = optimset('Disp','Iter','LargeScale','off','MaxFunEvals',2,      'MaxIter',2,    'TolX',1e-5,'Tolfun',1e-5,'GradObj','off','DerivativeCheck','off','FinDiffType','central');
    o5   = optimset('Disp','Iter','LargeScale','off','MaxFunEvals',2000000,'MaxIter',15000,'TolX',1e-5,'Tolfun',1e-5,'GradObj','on', 'DerivativeCheck','off','FinDiffType','central');
    o5sh = optimset('Disp','Iter','LargeScale','off','MaxFunEvals',2      ,'MaxIter',2    ,'TolX',1e-5,'Tolfun',1e-5,'GradObj','on', 'DerivativeCheck','off','FinDiffType','central');
    o4Nu = optimset('Disp','Iter','LargeScale','off','MaxFunEvals',0,'MaxIter',0,'TolX',1e-6,'Tolfun',1e-6,'GradObj','off','DerivativeCheck','off','FinDiffType','central','FunValCheck','off');
    o4An = optimset('Disp','Iter','LargeScale','off','MaxFunEvals',0,'MaxIter',0,'TolX',1e-6,'Tolfun',1e-6,'GradObj','on' ,'DerivativeCheck','off','FinDiffType','central','FunValCheck','off');

    %------------------------------------------
    % Data matrix for offer parameters
    %------------------------------------------
    Xoffer = [ones(size(utd.X2nw,1),1) utd.sage utd.grad_4yrlImps utd.X2nw(:,end-2:end)]; % covariates: constant, age, grad_4yr dummy, unobserved type dummies
    
    %------------------------------------------
    % Starting values for parameters
    %------------------------------------------
    if restart==false
        boffer = [-0.6752;-0.1637;1.7725;0.5956;0.5617;0.4481];
        bstrucsearch = [1.6417;0.6477;-2.6639;-0.0899;0.1011;0.1988;0.4317;0.0816;-0.0700;-0.0694;-0.0294;0.0171;-0.1865;0.0060;0.0219;-0.0065;-0.0314;0.0177;1.4391;-0.0052;-0.0087;0.9696;2.4216;0.8901;0.3191;0.0055;0.0896;-0.0113;0.8768;-0.4628;-0.3203;-0.0981;0.2689;0.2712;0.2917;-4.7037;0.0996;-0.0374;0.9532;0.8500;0.1772;-0.0523;0.2873;0.0809;0.0526;-0.2661;0.0071;-0.0500;0.0101;0.6677;-0.0239;2.2013;-0.0172;0.0010;2.6924;1.0319;4.5040;1.9400;0.4706;0.1634;-0.4355;-0.1865;-1.7937;0.3147;0.9116;0.2619;0.3035;0.2719;-3.5263;0.2396;-0.0637;0.6560;0.7888;0.1958;0.0799;-0.0453;0.0587;0.0631;-0.2819;0.0048;-0.0047;-0.0008;0.4885;-0.0115;2.0286;0.0024;-0.0039;1.7718;0.7225;1.9116;3.5239;0.4157;0.5698;-0.1676;-0.1129;-1.9263;0.0861;0.1841;0.2984;0.3968;0.1623;-2.1582;-0.0487;-0.0875;-0.0345;-0.0034;0.1768;0.1724;0.1627;0.1124;-0.0278;-0.1342;0.0005;0.3017;-0.0190;0.2754;-0.0194;-0.0052;0.0041;1.1645;0.0330;0.6432;0.6043;2.2102;0.9777;-1.3460;-0.1367;-0.1313;-0.0001;-0.2278;0.2039;0.2908;-0.0293;-0.1509;0.3855;0.1968;-0.0638;-0.7717;-0.0239;-0.2267;-1.4415;-0.0905;0.0140;-0.0528;-0.2729;0.2096;0.1463;0.0766;0.0050;-0.0138;-0.1462;-0.0041;0.3878;-0.0118;0.1604;0.0033;0.0071;-0.0059;0.9121;0.3182;0.4073;0.6343;1.3767;2.2932;-1.5131;-0.0886;-0.0578;-0.0685;0.5853;-0.0646;-0.1148;-0.2834;0.4040;0.5041;0.2287;-0.1168;-0.0327;-0.0821;-0.0921;-2.1060;0.0425;0.1158;0.1308;0.5079;0.4092;0.3336;0.3286;0.1685;0.0075;0.1736;-0.0042;-0.0432;0.0037;0.3589;-0.0363;-0.5298;0.0882;-0.1879;0.0729;-0.9872;-0.9533;2.7304;-0.1741;-0.2569;-0.1140;0.5846;0.6369;-0.0972;0.3184;-0.5962;-1.1105;-0.7281;-0.8074;0.0345];
        assert(length(bstrucsearch)==214,'starting values wrong length');
    else
        load(strcat(ipath,'searchconsumpstrucbWCabsorb.mat'),'bstrucsearch','boffer');
    end

    %------------------------------------------
    % Estimate joint mlogit/lambda parameters
    %------------------------------------------
    totlen = length(bstrucsearch)+length(boffer);
    idx1   = [1:totlen-size(Xoffer,2)];
    idx2   = [totlen-(size(Xoffer,2)-1):totlen];
    assert(isempty(setdiff(1:totlen,[idx1 idx2])),'partitioning is off!');
    derivative_checker = false;
    if derivative_checker==true
        [bstrucjointsearch0,lstruc,e,o,gNum]=fminunc('consumpjointsearchmlogitWCabsorb',[bstrucsearch;boffer],o4Nu,utd.ClImps,utd,Xoffer,utd.grad_4yrlImps,idx1,idx2,sdemog,S,PmajgpaType);
        [bstrucjointsearch0,lstruc,e,o,gAna]=fminunc('consumpjointsearchmlogitWCabsorb',[bstrucsearch;boffer],o4An,utd.ClImps,utd,Xoffer,utd.grad_4yrlImps,idx1,idx2,sdemog,S,PmajgpaType);
        dlmwrite('gradient_checker_jointsearch_WCabsorb.csv',[gNum zeros(size(gNum,1),1) gAna]);
        return
    end

    test = false;
    if test==true
        [bstrucjointsearch,lstrucjointsearch,e,o,gstrucjointsearch]=fminunc('consumpjointsearchmlogitWCabsorb',.01*[bstrucsearch;boffer],o5sh,utd.ClImps,utd,Xoffer,utd.grad_4yrlImps,idx1,idx2,sdemog,S,PmajgpaType);
        [bstrucjointsearch,lstrucjointsearch,e,o,gstrucjointsearch]=fminunc('consumpjointsearchmlogitWCabsorb',[bstrucsearch;boffer],o5sh,utd.ClImps,utd,Xoffer,utd.grad_4yrlImps,idx1,idx2,sdemog,S,PmajgpaType);
        %hstrucjointsearch = eye(length(bstrucjointsearch),length(bstrucjointsearch));
    else
        [bstrucjointsearch,lstrucjointsearch,e,o,gstrucjointsearch,hstrucjointsearch]=fminunc('consumpjointsearchmlogitWCabsorb',[bstrucsearch;boffer],o5,utd.ClImps,utd,Xoffer,utd.grad_4yrlImps,idx1,idx2,sdemog,S,PmajgpaType);
    end
    bstrucsearch = bstrucjointsearch(idx1);
    boffer       = bstrucjointsearch(idx2); 
    hstrucsearch = hstrucjointsearch(idx1,idx1);
    hoffer       = hstrucjointsearch(idx2,idx2); 
    lambda       = exp(Xoffer*boffer)./(1+exp(Xoffer*boffer));
    lambda(utd.sprevs(:,end)==1) = 1;

    disp('lambda parameters');
    [boffer sqrt(diag(inv(hoffer)))]
    disp('summary stats on lambda | prev_WC==0');
    sumopt = struct('Weights',PmajgpaType(utd.ClImps>0 & utd.sprevs(:,end)==0 ));
    summarize([lambda(utd.ClImps>0 & utd.sprevs(:,end)==0)],sumopt); 
    disp('summary stats on lambda');
    sumopt = struct('Weights',PmajgpaType(utd.ClImps>0));
    summarize([lambda(utd.ClImps>0)],sumopt); 
    disp('summary stats on linear index');
    summarize([Xoffer(utd.ClImps>0,:)*boffer],sumopt); 
    disp('summary stats on Xoffer');
    summarize(Xoffer(utd.ClImps>0,:),sumopt); 

    q = ones(size(PmajgpaType));

    save(strcat(ipath,'searchconsumpstrucbWCabsorb',num2str(guess),'.mat'),'bstrucsearch','hstrucsearch','boffer','hoffer');

    save(strcat(ipath,'jointsearchconsumpparmresults',num2str(guess),'.mat'),'boffer','hoffer','lambda','bstrucsearch','hstrucsearch');

    parms  = v2struct(bstrucsearch,boffer,hstrucsearch,hoffer,lambda);
end
