% Bring together all of the bootstrap estimates to compute standard errors
clear; clc;
S = 8;
pathpboot  = '../../output/bootstrap/';
% Get a list of all .mat files in the folder
files = dir(fullfile(pathpboot, 'allparameters*.mat'));
% only keep first 150 if more than 150
files = files(1:min(150,length(files)));
B = length(files);
assert(B==150,'B is not 150')

% Initialize point estimate matrices
prior_boot          = [];
bstartAR_boot       = [];
sigAR_boot          = [];
bstartCS_boot       = [];
sigCS_boot          = [];
bstartMK_boot       = [];
sigMK_boot          = [];
bstartNO_boot       = [];
sigNO_boot          = [];
bstartPC_boot       = [];
sigPC_boot          = [];
bstartWK_boot       = [];
sigWK_boot          = [];
bstartSATm_boot     = [];
sigSATm_boot        = [];
bstartSATv_boot     = [];
sigSATv_boot        = [];
bstartLS_boot       = [];
bstartBR_boot       = [];
bstartEC_boot       = [];
sigEC_boot          = [];
bstartTB_boot       = [];
bstartRTB_boot      = [];
bstartHS_boot       = [];
bstartDE_boot       = [];
bstartPWY_boot      = [];
bstartPWP_boot      = [];
bstartg_boot        = [];
bstartn_boot        = [];
bstart4s_boot       = [];
bstart4h_boot       = [];
bstart2_boot        = [];
lambdaydgstart_boot = [];
lambdag0start_boot  = [];
lambdag1start_boot  = [];
lambdan0start_boot  = [];
lambdan1start_boot  = [];
lambda4s0start_boot = [];
lambda4s1start_boot = [];
lambda4h0start_boot = [];
lambda4h1start_boot = [];
lambda20start_boot  = [];
lambda21start_boot  = [];
sig_boot            = [];
sigNormed_boot      = [];
Delta_boot          = [];
DeltaCorr_boot      = [];
bstrucsearch_boot   = [];
boffer_boot         = [];
rhoU_boot           = [];
unsk_wage_sig_boot  = [];
P_grad_betas4_boot  = [];
bstrucstruc_boot    = [];

% loop and concatenate
for b = 1:length(files) 
    % unpack parameters
    temp           = load(fullfile(pathpboot, files(b).name));
    prior          = temp.allparms.stage1parms.prior';
    bstartAR       = temp.allparms.stage1parms.msys.bstartAR;
    sigAR          = temp.allparms.stage1parms.msys.sigAR;
    bstartCS       = temp.allparms.stage1parms.msys.bstartCS;
    sigCS          = temp.allparms.stage1parms.msys.sigCS;
    bstartMK       = temp.allparms.stage1parms.msys.bstartMK;
    sigMK          = temp.allparms.stage1parms.msys.sigMK;
    bstartNO       = temp.allparms.stage1parms.msys.bstartNO;
    sigNO          = temp.allparms.stage1parms.msys.sigNO;
    bstartPC       = temp.allparms.stage1parms.msys.bstartPC;
    sigPC          = temp.allparms.stage1parms.msys.sigPC;
    bstartWK       = temp.allparms.stage1parms.msys.bstartWK;
    sigWK          = temp.allparms.stage1parms.msys.sigWK;
    bstartSATm     = temp.allparms.stage1parms.msys.bstartSATm;
    sigSATm        = temp.allparms.stage1parms.msys.sigSATm;
    bstartSATv     = temp.allparms.stage1parms.msys.bstartSATv;
    sigSATv        = temp.allparms.stage1parms.msys.sigSATv;
    bstartLS       = temp.allparms.stage1parms.msys.bstartLS;
    bstartBR       = temp.allparms.stage1parms.msys.bstartBR;
    bstartEC       = temp.allparms.stage1parms.msys.bstartEC;
    sigEC          = temp.allparms.stage1parms.msys.sigEC;
    bstartTB       = temp.allparms.stage1parms.msys.bstartTB;
    bstartRTB      = temp.allparms.stage1parms.msys.bstartRTB;
    bstartHS       = temp.allparms.stage1parms.msys.bstartHS;
    bstartDE       = temp.allparms.stage1parms.msys.bstartDE;
    bstartPWY      = temp.allparms.stage1parms.msys.bstartPWY;
    bstartPWP      = temp.allparms.stage1parms.msys.bstartPWP;
    bstartg        = temp.allparms.learnparameters.bstartg;
    bstartn        = temp.allparms.learnparameters.bstartn;
    bstart4s       = temp.allparms.learnparameters.bstart4s;
    bstart4h       = temp.allparms.learnparameters.bstart4h;
    bstart2        = temp.allparms.learnparameters.bstart2;
    lambdaydgstart = temp.allparms.learnparameters.lambdaydgstart;
    lambdag0start  = temp.allparms.learnparameters.lambdag0start;
    lambdag1start  = temp.allparms.learnparameters.lambdag1start;
    lambdan0start  = temp.allparms.learnparameters.lambdan0start;
    lambdan1start  = temp.allparms.learnparameters.lambdan1start;
    lambda4s0start = temp.allparms.learnparameters.lambda4s0start;
    lambda4s1start = temp.allparms.learnparameters.lambda4s1start;
    lambda4h0start = temp.allparms.learnparameters.lambda4h0start;
    lambda4h1start = temp.allparms.learnparameters.lambda4h1start;
    lambda20start  = temp.allparms.learnparameters.lambda20start;
    lambda21start  = temp.allparms.learnparameters.lambda21start;
    sig            = temp.allparms.learnparameters.sig;
    sigNormed      = cat(1,sig(1),lambdag1start^2*sig(2),sig(3),lambdan1start^2*sig(4),sig(5:6),lambda4s1start^2*sig(7:9),sig(10:11),lambda4h1start^2*sig(12:14),sig(15:17));
    Delta          = temp.allparms.learnparameters.Delta;
    DeltaCorr      = corrcov(.5*Delta + .5*Delta');
    Delta          = Delta(:);
    DeltaCorr      = DeltaCorr(:);
    bstrucsearch   = temp.allparms.staticparameters.searchparms.bstrucsearch;
    boffer         = temp.allparms.staticparameters.searchparms.boffer;
    rhoU           = temp.allparms.staticparameters.AR1parms.rhoU;
    unsk_wage_sig  = temp.allparms.staticparameters.AR1parms.unsk_wage_sig;
    P_grad_betas4  = temp.allparms.gradparameters.P_grad_betas4;
    bstrucstruc    = temp.allparms.structuralparameters.bstrucstruc;

    % concatenate horizontally
    prior_boot          = cat(2,prior_boot          ,prior         );
    bstartAR_boot       = cat(2,bstartAR_boot       ,bstartAR      );
    sigAR_boot          = cat(2,sigAR_boot          ,sigAR         );
    bstartCS_boot       = cat(2,bstartCS_boot       ,bstartCS      );
    sigCS_boot          = cat(2,sigCS_boot          ,sigCS         );
    bstartMK_boot       = cat(2,bstartMK_boot       ,bstartMK      );
    sigMK_boot          = cat(2,sigMK_boot          ,sigMK         );
    bstartNO_boot       = cat(2,bstartNO_boot       ,bstartNO      );
    sigNO_boot          = cat(2,sigNO_boot          ,sigNO         );
    bstartPC_boot       = cat(2,bstartPC_boot       ,bstartPC      );
    sigPC_boot          = cat(2,sigPC_boot          ,sigPC         );
    bstartWK_boot       = cat(2,bstartWK_boot       ,bstartWK      );
    sigWK_boot          = cat(2,sigWK_boot          ,sigWK         );
    bstartSATm_boot     = cat(2,bstartSATm_boot     ,bstartSATm    );
    sigSATm_boot        = cat(2,sigSATm_boot        ,sigSATm       );
    bstartSATv_boot     = cat(2,bstartSATv_boot     ,bstartSATv    );
    sigSATv_boot        = cat(2,sigSATv_boot        ,sigSATv       );
    bstartLS_boot       = cat(2,bstartLS_boot       ,bstartLS      );
    bstartBR_boot       = cat(2,bstartBR_boot       ,bstartBR      );
    bstartEC_boot       = cat(2,bstartEC_boot       ,bstartEC      );
    sigEC_boot          = cat(2,sigEC_boot          ,sigEC         );
    bstartTB_boot       = cat(2,bstartTB_boot       ,bstartTB      );
    bstartRTB_boot      = cat(2,bstartRTB_boot      ,bstartRTB     );
    bstartHS_boot       = cat(2,bstartHS_boot       ,bstartHS      );
    bstartDE_boot       = cat(2,bstartDE_boot       ,bstartDE      );
    bstartPWY_boot      = cat(2,bstartPWY_boot      ,bstartPWY     );
    bstartPWP_boot      = cat(2,bstartPWP_boot      ,bstartPWP     );
    bstartg_boot        = cat(2,bstartg_boot        ,bstartg       );
    bstartn_boot        = cat(2,bstartn_boot        ,bstartn       );
    bstart4s_boot       = cat(2,bstart4s_boot       ,bstart4s      );
    bstart4h_boot       = cat(2,bstart4h_boot       ,bstart4h      );
    bstart2_boot        = cat(2,bstart2_boot        ,bstart2       );
    lambdaydgstart_boot = cat(2,lambdaydgstart_boot ,lambdaydgstart);
    lambdag0start_boot  = cat(2,lambdag0start_boot  ,lambdag0start );
    lambdag1start_boot  = cat(2,lambdag1start_boot  ,lambdag1start );
    lambdan0start_boot  = cat(2,lambdan0start_boot  ,lambdan0start );
    lambdan1start_boot  = cat(2,lambdan1start_boot  ,lambdan1start );
    lambda4s0start_boot = cat(2,lambda4s0start_boot ,lambda4s0start);
    lambda4s1start_boot = cat(2,lambda4s1start_boot ,lambda4s1start);
    lambda4h0start_boot = cat(2,lambda4h0start_boot ,lambda4h0start);
    lambda4h1start_boot = cat(2,lambda4h1start_boot ,lambda4h1start);
    lambda20start_boot  = cat(2,lambda20start_boot  ,lambda20start );
    lambda21start_boot  = cat(2,lambda21start_boot  ,lambda21start );
    sig_boot            = cat(2,sig_boot            ,sig           );
    sigNormed_boot      = cat(2,sigNormed_boot      ,sigNormed     );
    Delta_boot          = cat(2,Delta_boot          ,Delta         );
    DeltaCorr_boot      = cat(2,DeltaCorr_boot      ,DeltaCorr     );
    bstrucsearch_boot   = cat(2,bstrucsearch_boot   ,bstrucsearch  );
    boffer_boot         = cat(2,boffer_boot         ,boffer        );
    rhoU_boot           = cat(2,rhoU_boot           ,rhoU          );
    unsk_wage_sig_boot  = cat(2,unsk_wage_sig_boot  ,unsk_wage_sig );
    P_grad_betas4_boot  = cat(2,P_grad_betas4_boot  ,P_grad_betas4 );
    bstrucstruc_boot    = cat(2,bstrucstruc_boot    ,bstrucstruc   );
end

% compute standard errors and print them to the console
boot_compute = @(x) sqrt(diag((1/(B-1))*(x-repmat(mean(x,2),1,B))*(x-repmat(mean(x,2),1,B))'));

se_prior          = boot_compute(prior_boot         )
se_bstartAR       = boot_compute(bstartAR_boot      )
se_sigAR          = boot_compute(sigAR_boot         )
se_bstartCS       = boot_compute(bstartCS_boot      )
se_sigCS          = boot_compute(sigCS_boot         )
se_bstartMK       = boot_compute(bstartMK_boot      )
se_sigMK          = boot_compute(sigMK_boot         )
se_bstartNO       = boot_compute(bstartNO_boot      )
se_sigNO          = boot_compute(sigNO_boot         )
se_bstartPC       = boot_compute(bstartPC_boot      )
se_sigPC          = boot_compute(sigPC_boot         )
se_bstartWK       = boot_compute(bstartWK_boot      )
se_sigWK          = boot_compute(sigWK_boot         )
se_bstartSATm     = boot_compute(bstartSATm_boot    )
se_sigSATm        = boot_compute(sigSATm_boot       )
se_bstartSATv     = boot_compute(bstartSATv_boot    )
se_sigSATv        = boot_compute(sigSATv_boot       )
se_bstartLS       = boot_compute(bstartLS_boot      )
se_bstartBR       = boot_compute(bstartBR_boot      )
se_bstartEC       = boot_compute(bstartEC_boot      )
se_sigEC          = boot_compute(sigEC_boot         )
se_bstartTB       = boot_compute(bstartTB_boot      )
se_bstartRTB      = boot_compute(bstartRTB_boot     )
se_bstartHS       = boot_compute(bstartHS_boot      )
se_bstartDE       = boot_compute(bstartDE_boot      )
se_bstartPWY      = boot_compute(bstartPWY_boot     )
se_bstartPWP      = boot_compute(bstartPWP_boot     )
se_bstartg        = boot_compute(bstartg_boot       )
se_bstartn        = boot_compute(bstartn_boot       )
se_bstart4s       = boot_compute(bstart4s_boot      )
se_bstart4h       = boot_compute(bstart4h_boot      )
se_bstart2        = boot_compute(bstart2_boot       )
se_lambdaydgstart = boot_compute(lambdaydgstart_boot)
se_lambdag0start  = boot_compute(lambdag0start_boot )
se_lambdag1start  = boot_compute(lambdag1start_boot )
se_lambdan0start  = boot_compute(lambdan0start_boot )
se_lambdan1start  = boot_compute(lambdan1start_boot )
se_lambda4s0start = boot_compute(lambda4s0start_boot)
se_lambda4s1start = boot_compute(lambda4s1start_boot)
se_lambda4h0start = boot_compute(lambda4h0start_boot)
se_lambda4h1start = boot_compute(lambda4h1start_boot)
se_lambda20start  = boot_compute(lambda20start_boot )
se_lambda21start  = boot_compute(lambda21start_boot )
se_sig            = boot_compute(sig_boot           )
se_sigNormed      = boot_compute(sigNormed_boot     )
se_Delta          = boot_compute(Delta_boot         );
se_DeltaCorr      = boot_compute(DeltaCorr_boot     );
se_bstrucsearch   = boot_compute(bstrucsearch_boot  );
se_boffer         = boot_compute(boffer_boot        )
se_rhoU           = boot_compute(rhoU_boot          )
se_unsk_wage_sig  = boot_compute(unsk_wage_sig_boot )
se_P_grad_betas4  = boot_compute(P_grad_betas4_boot )
se_bstrucstruc    = boot_compute(bstrucstruc_boot   );

se_Delta     = reshape(se_Delta,5,5)
se_DeltaCorr = reshape(se_DeltaCorr,5,5)

mean_prior_boot          = mean(prior_boot          , 2);
mean_bstartAR_boot       = mean(bstartAR_boot       , 2);
mean_sigAR_boot          = mean(sigAR_boot          , 2);
mean_bstartCS_boot       = mean(bstartCS_boot       , 2);
mean_sigCS_boot          = mean(sigCS_boot          , 2);
mean_bstartMK_boot       = mean(bstartMK_boot       , 2);
mean_sigMK_boot          = mean(sigMK_boot          , 2);
mean_bstartNO_boot       = mean(bstartNO_boot       , 2);
mean_sigNO_boot          = mean(sigNO_boot          , 2);
mean_bstartPC_boot       = mean(bstartPC_boot       , 2);
mean_sigPC_boot          = mean(sigPC_boot          , 2);
mean_bstartWK_boot       = mean(bstartWK_boot       , 2);
mean_sigWK_boot          = mean(sigWK_boot          , 2);
mean_bstartSATm_boot     = mean(bstartSATm_boot     , 2);
mean_sigSATm_boot        = mean(sigSATm_boot        , 2);
mean_bstartSATv_boot     = mean(bstartSATv_boot     , 2);
mean_sigSATv_boot        = mean(sigSATv_boot        , 2);
mean_bstartLS_boot       = mean(bstartLS_boot       , 2);
mean_bstartBR_boot       = mean(bstartBR_boot       , 2);
mean_bstartEC_boot       = mean(bstartEC_boot       , 2);
mean_sigEC_boot          = mean(sigEC_boot          , 2);
mean_bstartTB_boot       = mean(bstartTB_boot       , 2);
mean_bstartRTB_boot      = mean(bstartRTB_boot      , 2);
mean_bstartHS_boot       = mean(bstartHS_boot       , 2);
mean_bstartDE_boot       = mean(bstartDE_boot       , 2);
mean_bstartPWY_boot      = mean(bstartPWY_boot      , 2);
mean_bstartPWP_boot      = mean(bstartPWP_boot      , 2);
mean_bstartg_boot        = mean(bstartg_boot        , 2);
mean_bstartn_boot        = mean(bstartn_boot        , 2);
mean_bstart4s_boot       = mean(bstart4s_boot       , 2);
mean_bstart4h_boot       = mean(bstart4h_boot       , 2);
mean_bstart2_boot        = mean(bstart2_boot        , 2);
mean_lambdaydgstart_boot = mean(lambdaydgstart_boot , 2);
mean_lambdag0start_boot  = mean(lambdag0start_boot  , 2);
mean_lambdag1start_boot  = mean(lambdag1start_boot  , 2);
mean_lambdan0start_boot  = mean(lambdan0start_boot  , 2);
mean_lambdan1start_boot  = mean(lambdan1start_boot  , 2);
mean_lambda4s0start_boot = mean(lambda4s0start_boot , 2);
mean_lambda4s1start_boot = mean(lambda4s1start_boot , 2);
mean_lambda4h0start_boot = mean(lambda4h0start_boot , 2);
mean_lambda4h1start_boot = mean(lambda4h1start_boot , 2);
mean_lambda20start_boot  = mean(lambda20start_boot  , 2);
mean_lambda21start_boot  = mean(lambda21start_boot  , 2);
mean_sig_boot            = mean(sig_boot            , 2);
mean_sigNormed_boot      = mean(sigNormed_boot      , 2);
mean_Delta_boot          = mean(Delta_boot          , 2);
mean_DeltaCorr_boot      = mean(DeltaCorr_boot      , 2);
mean_bstrucsearch_boot   = mean(bstrucsearch_boot   , 2);
mean_boffer_boot         = mean(boffer_boot         , 2);
mean_rhoU_boot           = mean(rhoU_boot           , 2);
mean_unsk_wage_sig_boot  = mean(unsk_wage_sig_boot  , 2);
mean_P_grad_betas4_boot  = mean(P_grad_betas4_boot  , 2);
mean_bstrucstruc_boot    = mean(bstrucstruc_boot    , 2);
%p0_P_grad_betas4   = min(P_grad_betas4_boot, [], 2);
%p1_P_grad_betas4   = prctile(P_grad_betas4_boot, 1, 2);
%p5_P_grad_betas4   = prctile(P_grad_betas4_boot, 5, 2);
%p25_P_grad_betas4  = prctile(P_grad_betas4_boot,25, 2);
%p50_P_grad_betas4  = prctile(P_grad_betas4_boot,50, 2);
%p75_P_grad_betas4  = prctile(P_grad_betas4_boot,75, 2);
%p95_P_grad_betas4  = prctile(P_grad_betas4_boot,95, 2);
%p99_P_grad_betas4  = prctile(P_grad_betas4_boot,99, 2);
%p100_P_grad_betas4 = max(P_grad_betas4_boot, [], 2);
%
%p0_P_grad_betas4([16 20])
%p1_P_grad_betas4([16 20])
%p5_P_grad_betas4([16 20])
%p25_P_grad_betas4([16 20])
%p50_P_grad_betas4([16 20])
%p75_P_grad_betas4([16 20])
%p95_P_grad_betas4([16 20])
%p99_P_grad_betas4([16 20])
%p100_P_grad_betas4([16 20])
%
%find(abs(P_grad_betas4_boot(16,:))>100)
%find(abs(P_grad_betas4_boot(20,:))>100)
%
%bstrucsearch = [1.642;0.648;-2.664;-0.090;0.101;0.199;0.432;0.082;-0.070;-0.069;-0.029;0.017;-0.187;0.006;0.022;-0.006;-0.031;0.018;1.439;-0.005;-0.009;0.970;2.422;0.890;0.319;0.005;0.090;-0.011;0.877;-0.463;-0.320;-0.098;0.269;0.271;0.224;0.202;0.023;0.006;-0.032;-4.704;0.100;-0.037;0.953;0.850;0.177;-0.052;0.287;0.081;0.053;-0.266;0.007;-0.050;0.010;0.668;-0.024;2.201;-0.017;0.001;2.692;1.032;4.504;1.940;0.471;0.163;-0.435;-0.187;-1.794;0.315;0.912;0.262;0.304;0.074;0.107;-0.039;-0.105;-0.100;-3.526;0.240;-0.064;0.656;0.789;0.196;0.080;-0.045;0.059;0.063;-0.282;0.005;-0.005;-0.001;0.488;-0.011;2.029;0.002;-0.004;1.772;0.722;1.912;3.524;0.416;0.570;-0.168;-0.113;-1.926;0.086;0.184;0.298;0.397;0.292;0.323;0.213;0.054;0.126;-2.158;-0.049;-0.087;-0.034;-0.003;0.177;0.172;0.163;0.112;-0.028;-0.134;0.001;0.302;-0.019;0.275;-0.019;-0.005;0.004;1.165;0.033;0.643;0.604;2.210;0.978;-1.346;-0.137;-0.131;0.000;-0.228;-0.002;-0.125;-0.008;-0.192;0.204;0.291;-0.029;-0.151;0.386;0.197;-0.064;-0.772;-0.665;-0.024;-1.442;-0.090;0.014;-0.053;-0.273;0.210;0.146;0.077;0.005;-0.014;-0.146;-0.004;0.388;-0.012;0.160;0.003;0.007;-0.006;0.912;0.318;0.407;0.634;1.377;2.293;-1.513;-0.089;-0.058;-0.069;-0.052;-0.064;0.029;-0.091;0.585;-0.065;-0.115;-0.283;0.404;0.504;0.229;-0.117;-0.159;-0.033;-2.106;0.042;0.116;0.131;0.508;0.409;0.334;0.329;0.168;0.007;0.174;-0.004;-0.043;0.004;0.359;-0.036;-0.530;0.088;-0.188;0.073;-0.987;-0.953;2.730;-0.174;-0.257;-0.114;-0.265;-0.143;-0.096;-0.348;0.585;0.637;-0.097;0.318;-0.596;-1.111;-0.728;-0.807;-0.517;0.034];
%bstrucstruc = [3.117;-4.008;-0.085;0.044;-0.017;0.036;-0.187;-0.212;-0.180;-0.123;0.004;0.306;0.985;2.413;0.826;0.293;0.001;0.069;-0.035;0.682;-0.698;-0.416;-0.318;0.146;0.112;0.196;0.107;0.078;0.065;0.069;-6.204;-0.124;-0.093;0.261;0.051;-0.319;-0.302;-0.083;-0.109;0.045;1.481;2.650;1.046;4.555;1.971;0.471;0.151;-0.362;-0.618;-1.408;0.227;0.957;0.309;0.293;0.383;0.310;0.235;0.334;0.214;-4.934;-0.115;-0.041;0.221;0.063;-0.237;-0.149;-0.039;0.000;0.058;1.625;1.730;0.721;1.971;3.582;0.415;0.564;-0.112;-0.508;-1.837;0.181;0.365;0.107;0.134;0.131;0.154;0.086;0.030;0.058;-3.279;0.044;-0.071;0.000;0.029;0.078;0.071;0.030;0.066;-0.014;1.185;0.043;0.665;0.628;2.222;0.986;-1.325;-0.232;-0.060;-0.104;-0.016;-0.210;-0.050;-0.114;-0.057;-0.154;-3.289;0.037;-0.018;0.020;-0.029;0.150;0.084;0.031;0.032;-0.007;0.907;0.301;0.392;0.630;1.388;2.316;-1.491;-0.116;-0.082;-0.016;-0.051;-0.070;-0.058;0.008;-0.051;-1.672;0.028;0.030;0.050;0.184;0.148;0.148;0.040;-0.038;-0.006;-0.599;0.110;-0.165;0.080;-0.981;-0.925;2.721;0.531;0.130;0.034;0.090;0.084;0.110;0.155;0.006];
%
%[bstrucsearch se_bstrucsearch]
%[bstrucstruc se_bstrucstruc]

save(strcat(pathpboot,'bootSEs.mat'),'se_*','B');

