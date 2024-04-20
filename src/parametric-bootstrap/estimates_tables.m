% Create all LaTeX tables having to do with estimation
clear; clc;

%==============================================================================
% preamble
%==============================================================================

% path to tables
pathtables = '../../exhibits/tables/';

% path to functions
addpath 'export-fns/'
addpath 'boot-fns/'

% path to estimation results
pathmeasys = '../../output/all-stage-1/everything_all_stage1_interact_type_36688212.mat'; 
pathstage1 = '../../output/all-stage-1/';
pathlearn  = '../../output/learning/';
pathstatic = '../../output/utility/';
pathpboot  = '../../output/bootstrap/';

%------------------------------------------------------------------------------
% load parameter estimates and standard errors
%------------------------------------------------------------------------------
% measurement system
load(pathmeasys,'prior','parms');
% read in meas sys estimates from CSVs since they didn't get saved in MAT format
schabil = readtable([pathstage1,'msys-schabil36688212.csv']);
parms.msys.bstartAR   = schabil.Var2(1:end-2);
parms.msys.sigAR      = schabil.Var2(end-1);
parms.msys.bstartCS   = schabil.Var3(1:end-2);
parms.msys.sigCS      = schabil.Var3(end-1);
parms.msys.bstartMK   = schabil.Var4(1:end-2);
parms.msys.sigMK      = schabil.Var4(end-1);
parms.msys.bstartNO   = schabil.Var5(1:end-2);
parms.msys.sigNO      = schabil.Var5(end-1);
parms.msys.bstartPC   = schabil.Var6(1:end-2);
parms.msys.sigPC      = schabil.Var6(end-1);
parms.msys.bstartWK   = schabil.Var7(1:end-2);
parms.msys.sigWK      = schabil.Var7(end-1);
parms.msys.bstartSATm = schabil.Var8(1:end-2);
parms.msys.sigSATm    = schabil.Var8(end-1);
parms.msys.bstartSATv = schabil.Var9(1:end-2);
parms.msys.sigSATv    = schabil.Var9(end-1);
schpref = readtable([pathstage1,'msys-schpref36688212.csv']);
parms.msys.bstartLS   = schpref.Var2(2:end-2);
parms.msys.bstartBR   = schpref.Var3(2:end-3);
parms.msys.bstartEC   = schpref.Var4(1:12);
parms.msys.sigEC      = schpref.Var4(end-1);
parms.msys.bstartTB   = schpref.Var5(1:12);
parms.msys.bstartRTB  = schpref.Var6(1:12);
wrkabilpref = readtable([pathstage1,'msys-wrkabilpref36688212.csv']);
parms.msys.bstartHS   = wrkabilpref.Var2(1:end-1);
parms.msys.bstartDE   = wrkabilpref.Var3(1:end-1);
parms.msys.bstartPWY  = wrkabilpref.Var4(1:end-5);
parms.msys.bstartPWP  = wrkabilpref.Var5(1:end-5);

% load measurement system parms into workspace
bstartAR   = parms.msys.bstartAR;
sigAR      = parms.msys.sigAR;
bstartCS   = parms.msys.bstartCS;
sigCS      = parms.msys.sigCS;
bstartMK   = parms.msys.bstartMK;
sigMK      = parms.msys.sigMK;
bstartNO   = parms.msys.bstartNO;
sigNO      = parms.msys.sigNO;
bstartPC   = parms.msys.bstartPC;
sigPC      = parms.msys.sigPC;
bstartWK   = parms.msys.bstartWK;
sigWK      = parms.msys.sigWK;
bstartSATm = parms.msys.bstartSATm;
sigSATm    = parms.msys.sigSATm;
bstartSATv = parms.msys.bstartSATv;
sigSATv    = parms.msys.sigSATv;
bstartLS   = parms.msys.bstartLS;
bstartBR   = parms.msys.bstartBR;
bstartEC   = parms.msys.bstartEC;
sigEC      = parms.msys.sigEC;
bstartTB   = parms.msys.bstartTB;
bstartRTB  = parms.msys.bstartRTB;
bstartHS   = parms.msys.bstartHS;
bstartDE   = parms.msys.bstartDE;
bstartPWY  = parms.msys.bstartPWY;
bstartPWP  = parms.msys.bstartPWP;

% Results that need to be manually updated:
% missing data probabilities
pr_missing_is_sci = 0.3531;
pr_missing_gpa    = [0.4776;0.2102;0.1870;0.1252];
% likelihood value
choice_like_val = -26105;
% Wage AR(1) observations
NTar = 16;
% Graduation logit observations
NTgl = 1115;
% total observations
NTobs = 22398;
% parameters governing the structure of the flow utility estimates
S         = 8;
sdemog    = 10;
number2   = 25;
number4s  = 25;
number4ns = 25;
numberpt  = 22;
numberft  = 21;
numberwc  = 21;
% parameters governing the structure of the flow utility estimates (static choice model)
stsdemog    = 16;
stnumber2   = 33;
stnumber4s  = 33;
stnumber4ns = 33;
stnumberpt  = 29;
stnumberft  = 28;
stnumberwc  = 26;
stnumbergpt = 10;
stnumbergft = 10;
stnumbergwc = 10;

% learning and static estimation (learning, job offer, AR1 model, graduation logit)
load(strcat(pathstatic,'everything_jointsearch_WCabsorb37595330'),'searchparms','AR1parms','gradparms','learnparms','learnStruct','PmajgpaTypel','Utilstruct');
load(strcat(pathstatic,'everything_consumpstructural_FVfast39374622.mat'),'strucparms');
v2struct(learnparms)
v2struct(gradparms)

% load standard errors
ses = load(strcat(pathpboot,'bootSEs.mat'));
v2struct(ses);
% load measurement system SEs into workspace
se_bstartAR   = ses.se_bstartAR;
se_sigAR      = ses.se_sigAR;
se_bstartCS   = ses.se_bstartCS;
se_sigCS      = ses.se_sigCS;
se_bstartMK   = ses.se_bstartMK;
se_sigMK      = ses.se_sigMK;
se_bstartNO   = ses.se_bstartNO;
se_sigNO      = ses.se_sigNO;
se_bstartPC   = ses.se_bstartPC;
se_sigPC      = ses.se_sigPC;
se_bstartWK   = ses.se_bstartWK;
se_sigWK      = ses.se_sigWK;
se_bstartSATm = ses.se_bstartSATm;
se_sigSATm    = ses.se_sigSATm;
se_bstartSATv = ses.se_bstartSATv;
se_sigSATv    = ses.se_sigSATv;
se_bstartLS   = ses.se_bstartLS;
se_bstartBR   = ses.se_bstartBR;
se_bstartEC   = ses.se_bstartEC;
se_sigEC      = ses.se_sigEC;
se_bstartTB   = ses.se_bstartTB;
se_bstartRTB  = ses.se_bstartRTB;
se_bstartHS   = ses.se_bstartHS;
se_bstartDE   = ses.se_bstartDE;
se_bstartPWY  = ses.se_bstartPWY;
se_bstartPWP  = ses.se_bstartPWP;

%==============================================================================
% learning results tables
%==============================================================================
% data to compute means and variances
flag_wc = ismember(Utilstruct.ClImps,[2 4 7 9 12 14 17 19]);
flag_bc = ismember(Utilstruct.ClImps,[1 3 6 8 11 13 16 18]);
flag4s  = (Utilstruct.ClImps>5  & Utilstruct.ClImps<11);
flag4h  = (Utilstruct.ClImps>10 & Utilstruct.ClImps<16);
flag2   = (Utilstruct.ClImps>0  & Utilstruct.ClImps<6);
qg      = PmajgpaTypel(flag_wc);
qn      = PmajgpaTypel(flag_bc);
q4s     = PmajgpaTypel(flag4s);
q4h     = PmajgpaTypel(flag4h);
q2      = PmajgpaTypel(flag2);
% grades equations
results = table;
results.names = ["%Constant";"Black";"Hispanic";"Parent graduated college";"HS Grades (z-score)";"%Born in 1980";"%Born in 1981";"%Born in 1982";"%Born in 1983";"%Age 18 or younger";"%Age 19";"%Age 20";"Work full-time";"Work part-time";"Year 2 or higher in college";"Schooling ability type H";"Schooling preference type H";"Work motivation type H";];
results.b4s = [bstart4s(1:14);0;bstart4s(15:end)];
results.se4s = [se_bstart4s(1:14);0;se_bstart4s(15:end)];
results.b4h = [bstart4h(1:14);0;bstart4h(15:end)];
results.se4h = [se_bstart4h(1:14);0;se_bstart4h(15:end)];
results.b2 = bstart2;
results.se2 = se_bstart2;
fid = fopen(strcat(pathtables,'gpa_eqn_estimates.tex'), 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Estimates of 2- and 4-year GPA Parameters}\n');
fprintf(fid, '\\label{tab:GPAEstimates}\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\begin{threeparttable}\n');
%fprintf(fid, '\\renewcommand{\\arraystretch}{0.8}\n');
fprintf(fid, '\\begin{tabular}{lcccccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, ' & \\multicolumn{2}{c}{4 year Science} & \\multicolumn{2}{c}{4 year Non-Science} & \\multicolumn{2}{c}{2 year}\\\\\n');
fprintf(fid, '\\cmidrule(r){2-3}\\cmidrule(lr){4-5}\\cmidrule(l){6-7}\n');
fprintf(fid, ' & Coeff.  & Std. Error  & Coeff.  & Std. Error  & Coeff.  & Std. Error\\\\\n');
fprintf(fid, '\\midrule\n');
for j = 1:15
    if j==15
        fprintf(fid, '%4s &  &  &  &  & %4.3f & (%4.3f) \\\\ \n', results.names(j), results.b2(j), results.se2(j)); 
    else
        fprintf(fid, '%4s & %4.3f & (%4.3f) & %4.3f & (%4.3f) & %4.3f & (%4.3f) \\\\ \n', results.names(j), results.b4s(j), results.se4s(j), results.b4h(j), results.se4h(j), results.b2(j), results.se2(j));
    end
end
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Unobserved type \\\\ \n');
for j = 16:18
    fprintf(fid, '%4s & %4.3f & (%4.3f) & %4.3f & (%4.3f) & %4.3f & (%4.3f) \\\\ \n', results.names(j), results.b4s(j), results.se4s(j), results.b4h(j), results.se4h(j), results.b2(j), results.se2(j));
end
fprintf(fid, '\\midrule\n');
fprintf(fid, '$\\lambda_{0}$ (ability index intercept) & %4.3f & (%4.3f) & %4.3f & (%4.3f) & %4.3f & (---) \\\\ \n', lambda4s0start, se_lambda4s0start, lambda4h0start, se_lambda4h0start, 0);
fprintf(fid, '$\\lambda_{1}$ (ability index loading) & %4.3f & (%4.3f) & %4.3f & (%4.3f) & %4.3f & (---) \\\\ \n', lambda4s1start, se_lambda4s1start, lambda4h1start, se_lambda4h1start, 1);
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Mean of dependent variable & \\multicolumn{2}{c}{ %4.3f } & \\multicolumn{2}{c}{ %4.3f } & \\multicolumn{2}{c}{ %4.3f } \\\\ \n', sum(learnStruct.grade4s.*q4s)./sum(q4s), sum(learnStruct.grade4h.*q4h)./sum(q4h), sum(learnStruct.grade2.*q2)./sum(q2));
fprintf(fid, 'Person-year obs.  & \\multicolumn{2}{c}{ %4s } & \\multicolumn{2}{c}{ %4s } & \\multicolumn{2}{c}{ %4s }\\\\\n', addComma(round(sum(BigN(5:9)),0)), addComma(round(sum(BigN(10:14)),0)), addComma(round(sum(BigN(15:17)),0)));
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Bootstrap standard errors in parentheses. Estimates for the constant, birth cohort dummies, and age group dummies (18 and under, 19, 20) are suppressed. Reference categories for multinomial variables are as follows: ``White'''' for race/ethnicity, ``Not working while in school'''' for work intensity, and ``L'''' for each unobserved type.\n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);




% wage equations
results = table;
results.names = ["%Constant";"Black";"Hispanic";"Parent graduated college";"HS Grades (z-score)";"%Born in 1980";"%Born in 1981";"%Born in 1982";"%Born in 1983";"%Age 18 or younger";"%Age 19";"%Age 20";"Work experience (any sector)";"Work experience (white collar sector)";"Years of college completed";"College graduate (any major)";"College graduate (science major)";"Year 1999 or earlier";"Year 2000";"Year 2001 ";"Year 2002 ";"Year 2003 ";"Year 2004 ";"Year 2005 ";"Year 2006 ";"Year 2007 ";"Year 2008 ";"Year 2009 ";"Year 2010";"Year 2011";"Year 2012";"Year 2013";"Year 2014";"Work part-time";"Schooling ability type H";"Schooling preference type H";"Work motivation type H";]; 
results.bg = bstartg;
results.seg = se_bstartg;
results.bn = bstartn;
results.sen = se_bstartn;
fid = fopen(strcat(pathtables,'wage_eqn_estimates.tex'), 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Estimates of White- and Blue-collar Wage Parameters}\n');
fprintf(fid, '\\label{tab:WageEstimates}\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\begin{threeparttable}\n');
%fprintf(fid, '\\renewcommand{\\arraystretch}{0.8}\n');
fprintf(fid, '\\begin{tabular}{lcccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, ' & \\multicolumn{2}{c}{White Collar} & \\multicolumn{2}{c}{Blue Collar} \\\\\n');
fprintf(fid, '\\cmidrule(r){2-3}\\cmidrule(l){4-5}\n');
fprintf(fid, ' & Coeff.  & Std. Error  & Coeff.  & Std. Error\\\\\n');
fprintf(fid, '\\midrule\n');
for j = [1:17 34]; % don't report year dummies
    fprintf(fid, '%4s & %4.3f & (%4.3f) & %4.3f & (%4.3f) \\\\ \n', results.names(j), results.bg(j), results.seg(j), results.bn(j), results.sen(j));
end
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Unobserved type \\\\ \n');
for j = 35:37; % types
    fprintf(fid, '%4s & %4.3f & (%4.3f) & %4.3f & (%4.3f) \\\\ \n', results.names(j), results.bg(j), results.seg(j), results.bn(j), results.sen(j));
end
fprintf(fid, '\\midrule\n');
fprintf(fid, '$\\lambda_{0}$ (in-school work index intercept) & %4.3f & (%4.3f) & %4.3f & (%4.3f) \\\\ \n', lambdag0start, se_lambdag0start, lambdan0start, se_lambdan0start);
fprintf(fid, '$\\lambda_{1}$ (in-school work index loading)   & %4.3f & (%4.3f) & %4.3f & (%4.3f) \\\\ \n', lambdag1start, se_lambdag1start, lambdan1start, se_lambdan1start);
fprintf(fid, '\\midrule\n');
fprintf(fid, '%%Year dummies & \\multicolumn{2}{c}{ $\\checkmark$ } & \\multicolumn{2}{c}{ $\\checkmark$ } \\\\\n');
fprintf(fid, 'Mean of dependent variable & \\multicolumn{2}{c}{ %4.3f } & \\multicolumn{2}{c}{ %4.3f } \\\\ \n', sum(learnStruct.wageg.*qg)./sum(qg), sum(learnStruct.wagen.*qn)./sum(qn));
fprintf(fid, 'Person-year obs.  & \\multicolumn{2}{c}{ %4s } & \\multicolumn{2}{c}{ %4s } \\\\\n', addComma(round(sum(BigN(1:2)),0)), addComma(round(sum(BigN(3:4)),0)));
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Bootstrap standard errors in parentheses. Estimates for the constant, birth cohort dummies, age group dummies (18 and under, 19, 20), and calendar year dummies are suppressed. Reference categories for multinomial variables are as follows: ``White'''' for race/ethnicity, ``Work full-time'''' for work intensity, and ``L'''' for each unobserved type.\n');
fprintf(fid, '\n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);






% wage AR(1) process
fid = fopen(strcat(pathtables,'wage_AR1_estimates.tex'), 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Labor market shock forecasting estimates}\n');
fprintf(fid, '\\label{tab:wageAR1s}\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lcc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Parameter & Estimate & Std. Error \\\\ \n');
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Autocorrelation & %4.3f & (%4.3f) \\\\ \n', AR1parms.rhoU, se_rhoU);
fprintf(fid, 'Std. Dev. of shock & %4.3f & (%4.3f) \\\\ \n', AR1parms.unsk_wage_sig, se_unsk_wage_sig);
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Observations & \\multicolumn{2}{c}{%2.0f} \\\\ \n', NTar);
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Bootstrap standard errors in parentheses. We estimate a single AR1 process for both labor market sectors.\n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);






% White collar offer arrival rate
results = table;
results.names = ["Constant";"Age";"College graduate";"Schooling ability type H";"Schooling preference type H";"Work motivation type H";]; 
results.b = searchparms.boffer;
results.se = se_boffer;
fid = fopen(strcat(pathtables,'offer_arrival_estimates.tex'), 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Estimates of White Collar Offer Arrival Parameters}\n');
fprintf(fid, '\\label{tab:OfferEstimates}\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lcc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Variable  & Coeff.  & Std. Error \\\\ \n');
fprintf(fid, '\\midrule\n');
for j = 1:size(results,1)
    fprintf(fid, '%4s & %4.3f & (%4.3f) \\\\ \n', results.names(j), results.b(j), results.se(j));
end
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Person-year observations & \\multicolumn{2}{c}{%4s} \\\\ \n',addComma(NTobs));
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Estimates of the $\\delta_\\lambda$ parameters in Equation \\eqref{eq:g4}. Bootstrap standard errors in parentheses. Age is normalized to be zero at 18 years old. Reference category is ``L'''' for each unobserved type. We restrict the offer arrival probability to equal 1 for those who worked in the white-collar sector in the previous period.\n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);






% Pr(graduation)
results = table;
results.names = ["Constant";"Black";"Hispanic";"HS Grades (z-score)";"Parent graduated college";"Born in 1980";"Born in 1981";"Born in 1982";"Born in 1983";"Family Income (\$10,000)";"College experience completion profiles:";"\qquad 0  years of 2yr";"\qquad 2+ years of 2yr";"\qquad 2  years of 4yr";"\qquad 3  years of 4yr";"\qquad 4  years of 4yr";"\qquad 5  years of 4yr";"\qquad 6+ years of 4yr";"\qquad 2  years of 4yr and 0 years of 2yr";"\qquad 4  years of 4yr and 0 years of 2yr";"\qquad 5  years of 4yr and 0 years of 2yr";"\qquad 6+ years of 4yr and 0 years of 2yr";"Science major";"Prior ability science $\times$ Science major";"Prior ability non-sci. $\times$ Non-Sci. major";"Work part-time";"Work full-time" ;"Schooling ability type H";"Schooling preference type H";"Work motivation type H";]; 
results.b = [P_grad_betas4(1:10);0;P_grad_betas4(11:end)];
results.se = [se_P_grad_betas4(1:10);0;se_P_grad_betas4(11:end)];
fid = fopen(strcat(pathtables,'grad_logit_estimates.tex'), 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Estimates of Probability of Graduation}\n');
fprintf(fid, '\\label{tab:GprobEstimates}\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\renewcommand{\\arraystretch}{0.7}\n');
fprintf(fid, '\\begin{tabular}{lcc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Variable  & Coeff.  & Std. Error \\\\ \n');
fprintf(fid, '\\midrule\n');
for j = 1:size(results,1)
    if j~=11
        fprintf(fid, '%4s & %4.3f & (%4.3f) \\\\ \n', results.names(j), results.b(j), results.se(j));
    else
        fprintf(fid, '%4s & & \\\\ \n', results.names(j));
    end
end
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Person-year observations & \\multicolumn{2}{c}{%4s} \\\\ \n',addComma(NTgl));
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Parameter estimates from a logit predicting probability of graduating in the following period. Estimated only on four-year college students in their junior year and above. Bootstrap standard errors in parentheses. Reference categories for multinomial variables are as follows: ``White'''' for race/ethnicity, ``Born in 1984'''' for birth year, ``1 year of 2yr college'''' and ``3 years of 4yr college and 0 years of 2yr college'''' for college experience, ``Not working'''' for work intensity, and ``L'''' for each unobserved type.\n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);





% Idiosyncratic variances
sigNormed = cat(1,sig(1),lambdag1start^2*sig(2),sig(3),lambdan1start^2*sig(4),sig(5:6),lambda4s1start^2*sig(7:9),sig(10:11),lambda4h1start^2*sig(12:14),sig(15:17));
fid = fopen(strcat(pathtables,'idiosyncratic_vars.tex'), 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Idiosyncratic Variances}\n');
fprintf(fid, '\\label{tab:trans}\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lccllccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, '\\multicolumn{3}{c}{Employment} & & \\multicolumn{4}{c}{Schooling} \\\\ \n');
fprintf(fid, '\\cmidrule(r){1-3}\\cmidrule(l){5-8}\n');
fprintf(fid, 'Work Type & White Collar & Blue Collar & & Schooling Period & Science & Non-Science & 2-year \\\\ \n');
fprintf(fid, '\\midrule\n');
fprintf(fid, 'In-school & %4.3f & %4.3f & & 1 & %4.3f & %4.3f & %4.3f \\\\ \n', sigNormed(2), sigNormed(4), sigNormed(5), sigNormed(10), sigNormed(15));
fprintf(fid, ' & (%4.3f) & (%4.3f) & & & (%4.3f) & (%4.3f) & (%4.3f) \\\\ \n', se_sigNormed(2), se_sigNormed(4), se_sigNormed(5), se_sigNormed(10), se_sigNormed(15));
fprintf(fid, 'Out-of-school & %4.3f & %4.3f & & 2 & %4.3f & %4.3f & %4.3f \\\\ \n', sigNormed(1), sigNormed(3), sigNormed(6), sigNormed(11), sigNormed(16)); 
fprintf(fid, ' & (%4.3f) & (%4.3f) & & & (%4.3f) & (%4.3f) & (%4.3f) \\\\ \n', se_sigNormed(1), se_sigNormed(3), se_sigNormed(6), se_sigNormed(11), se_sigNormed(16));
fprintf(fid, ' & & & & 3  & %4.3f & %4.3f & %4.3f \\\\ \n', sigNormed(7), sigNormed(12), sigNormed(17));  
fprintf(fid, ' & & & &    & (%4.3f) & (%4.3f) & (%4.3f) \\\\ \n', se_sigNormed(7), se_sigNormed(12), se_sigNormed(17));
fprintf(fid, ' & & & & 4  & %4.3f   & %4.3f   & \\\\ \n', sigNormed(8), sigNormed(13));   
fprintf(fid, ' & & & &    & (%4.3f) & (%4.3f) & \\\\ \n', se_sigNormed(8), se_sigNormed(13));
fprintf(fid, ' & & & & 5+ & %4.3f   & %4.3f   & \\\\ \n', sigNormed(9), sigNormed(14));    
fprintf(fid, ' & & & &    & (%4.3f) & (%4.3f) & \\\\ \n', se_sigNormed(9), se_sigNormed(14));
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Bootstrap standard errors in parentheses. The period-3 variance in 2-year college is the same for all periods after period 3. \n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);




% Correlation matrix
DeltaCorr = corrcov(.5*Delta + .5*Delta');
DeltaN = [509         454         232         288         184;
          454        1810         509         629         688;
          232         509         790         624         127;
          288         629         624         942         168;
          184         688         127         168         778];
fid = fopen(strcat(pathtables,'correlation_matrix.tex'), 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Ability Correlation Matrix and Variances of Unobserved Abilities and Raw Outcomes}\n');
fprintf(fid, '\\label{tab:cov}\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lccccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, ' & White Collar & Blue Collar & Science & Non-Science & 2-year \\\\ \n');
fprintf(fid, '\\midrule\n');
fprintf(fid, 'White Collar & %4.3f & & & & \\\\ \n', DeltaCorr(1,1));
fprintf(fid, ' & (---) & & & & \\\\ \n');
fprintf(fid, 'Blue Collar & %4.3f & %4.3f & & & \\\\ \n', DeltaCorr(2,1), DeltaCorr(2,2));
fprintf(fid, ' & (%4.3f) & (---) & & & \\\\ \n', se_DeltaCorr(2,1));
fprintf(fid, 'Science & %4.3f & %4.3f & %4.3f & & \\\\ \n', DeltaCorr(3,1), DeltaCorr(3,2), DeltaCorr(3,3));
fprintf(fid, ' & (%4.3f) & (%4.3f) & (---) & & \\\\ \n', se_DeltaCorr(3,1), se_DeltaCorr(3,2));
fprintf(fid, 'Non-Science & %4.3f & %4.3f & %4.3f & %4.3f & \\\\ \n', DeltaCorr(4,1), DeltaCorr(4,2), DeltaCorr(4,3), DeltaCorr(4,4));
fprintf(fid, ' & (%4.3f) & (%4.3f) & (%4.3f) & (---) & \\\\ \n', se_DeltaCorr(4,1), se_DeltaCorr(4,2), se_DeltaCorr(4,3));
fprintf(fid, '2-year & %4.3f & %4.3f & %4.3f & %4.3f & %4.3f \\\\ \n', DeltaCorr(5,1), DeltaCorr(5,2), DeltaCorr(5,3), DeltaCorr(5,4), DeltaCorr(5,5)); 
fprintf(fid, ' & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) & (---) \\\\ \n', se_DeltaCorr(5,1), se_DeltaCorr(5,2), se_DeltaCorr(5,3), se_DeltaCorr(5,4));
fprintf(fid, '\\midrule\n');
fprintf(fid, '\\textit{Variance of Unobserved Abilities}  & %4.3f & %4.3f & %4.3f & %4.3f & %4.3f \\\\ \n', Delta(1,1), Delta(2,2), Delta(3,3), Delta(4,4), Delta(5,5));
fprintf(fid, ' & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) \\\\ \n', se_Delta(1,1), se_Delta(2,2), se_Delta(3,3), se_Delta(4,4), se_Delta(5,5));
fprintf(fid, '\\midrule\n');
fprintf(fid, '\\textit{Variance of Raw Outcomes}  & %4.3f & %4.3f & %4.3f & %4.3f & %4.3f \\\\ \n', var(learnStruct.wageg,qg), var(learnStruct.wagen,qn), var(learnStruct.grade4s,q4s), var(learnStruct.grade4h,q4h), var(learnStruct.grade2,q2));
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Bootstrap standard errors in parentheses. ``Variance of Unobserved Abilities'''' refers to the diagonal elements of the covariance matrix corresponding to the correlation matrix presented here. ``Variance of Raw Outcomes'''' refers to the variance of the corresponding outcome variables (log wages, college GPA). Each cell of the correlation matrix contains at least %4s unique individuals and at most %4s unique individuals. Our estimation sample contains %4s unique individuals. \n', num2str(min(DeltaN(:))), addComma(round(max(DeltaN(:)),0)), addComma(2300) );
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);




% flow utility parameter estimates
% arrange parameter vector into nicer format, imposing various parameter restrictions
alpha = strucparms.bstrucstruc(1);
se_alpha = se_bstrucstruc(1);
gp = strucparms.bstrucstruc(2);
se_gp = se_bstrucstruc(2);
b2flg   = 2+[1:number2];
b4sflg  = 2+[1+number2:number2+number4s];
b4nsflg = 2+[1+number2+number4s:number2+number4s+number4ns];
bwptflg = 2+[1+number2+number4s+number4ns:number2+number4s+number4ns+numberpt];
bwftflg = 2+[1+number2+number4s+number4ns+numberpt:number2+number4s+number4ns+numberpt+numberft];
bwcflg  = 2+[1+number2+number4s+number4ns+numberpt+numberft:number2+number4s+number4ns+numberpt+numberft+numberwc];
b2        = strucparms.bstrucstruc(b2flg);
b2temp    = [b2(1:sdemog+1);alpha;b2(sdemog+2:end-7);999;999;b2(end-6:end)];
b4s       = strucparms.bstrucstruc(b4sflg);
b4stemp   = [b4s(1:sdemog+1);alpha;b4s(sdemog+2:end-7);999;999;b4s(end-6:end)];
b4ns      = strucparms.bstrucstruc(b4nsflg);
b4nstemp  = [b4ns(1:sdemog+1);alpha;b4ns(sdemog+2:end-7);999;999;b4ns(end-6:end)];
bwpt      = strucparms.bstrucstruc(bwptflg);
bwpttemp  = [bwpt(1:sdemog);999;alpha;bwpt(sdemog+1:end-3);999;999;999;999;bwpt(end-2:end)];
bwft      = strucparms.bstrucstruc(bwftflg);
bwfttemp  = [bwft(1:sdemog);999;alpha;bwft(sdemog+1:end-3);999;999;999;999;999;bwft(end-2:end)];
bwc       = strucparms.bstrucstruc(bwcflg);
bwctemp   = [bwc(1:sdemog);999;999;bwc(sdemog+1:end-3);999;999;999;999;999;bwc(end-2:end)];
se_b2        = se_bstrucstruc(b2flg);
se_b2temp    = [se_b2(1:sdemog+1);se_alpha;se_b2(sdemog+2:end-7);999;999;se_b2(end-6:end)];
se_b4s       = se_bstrucstruc(b4sflg);
se_b4stemp   = [se_b4s(1:sdemog+1);se_alpha;se_b4s(sdemog+2:end-7);999;999;se_b4s(end-6:end)];
se_b4ns      = se_bstrucstruc(b4nsflg);
se_b4nstemp  = [se_b4ns(1:sdemog+1);se_alpha;se_b4ns(sdemog+2:end-7);999;999;se_b4ns(end-6:end)];
se_bwpt      = se_bstrucstruc(bwptflg);
se_bwpttemp  = [se_bwpt(1:sdemog);999;se_alpha;se_bwpt(sdemog+1:end-3);999;999;999;999;se_bwpt(end-2:end)];
se_bwft      = se_bstrucstruc(bwftflg);
se_bwfttemp  = [se_bwft(1:sdemog);999;se_alpha;se_bwft(sdemog+1:end-3);999;999;999;999;999;se_bwft(end-2:end)];
se_bwc       = se_bstrucstruc(bwcflg);
se_bwctemp   = [se_bwc(1:sdemog);999;999;se_bwc(sdemog+1:end-3);999;999;999;999;999;se_bwc(end-2:end)];
% format as table for ease of printing to latex file
results = table;
results.names = ["%Constant";"Black";"Hispanic";"HS Grades (z-score)";"Parent graduated college";"%Born in 1980";"%Born in 1981";"%Born in 1982";"%Born in 1983";"Family Income (\$10,000)";"Prior academic ability";"%$\mathbb{E}[u(\text{consumption})] \div 1,000$";"Previous high school";"Previous 2-year college";"Previous 4-year science";"Previous 4-year non-science";"Previous work part-time";"Previous work full-time";"Previous work white-collar";"College graduate";"Currently work white-collar";"Currently work part-time";"Currently work full-time";"%Currently work part-time in white collar";"%Currently work full-time in white collar";"Schooling ability type H";"Schooling preference type H";"Work motivation type H";]; 
results.b2  = num2str(b2temp,'%.3f');
results.seb2  = num2str(se_b2temp,'%.3f');
results.b4s = num2str(b4stemp,'%.3f');
results.seb4s = num2str(se_b4stemp,'%.3f');
results.b4h = num2str(b4nstemp,'%.3f');
results.seb4h = num2str(se_b4nstemp,'%.3f');
results.bpt = num2str(bwpttemp,'%.3f');
results.sebpt = num2str(se_bwpttemp,'%.3f');
results.bft = num2str(bwfttemp,'%.3f');
results.sebft = num2str(se_bwfttemp,'%.3f');
results.bwc = num2str(bwctemp,'%.3f');
results.sebwc = num2str(se_bwctemp,'%.3f');
% replace 999's with blanks
resultscell = table2cell(results);
replaceIndex = cellfun(@(x) strcmp(x, '999.000'), resultscell);
resultscell(replaceIndex) = {' '};
results = cell2table(resultscell);
results.Properties.VariableNames = {'names', 'b2', 'seb2', 'b4s', 'seb4s', 'b4h', 'seb4h', 'bpt', 'sebpt', 'bft', 'sebft', 'bwc', 'sebwc'};
% now build the flow utility estimates table
fid = fopen(strcat(pathtables,'util_est_matrix.tex'), 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Flow Utility Parameter Estimates}\n');
fprintf(fid, '\\label{tab:Utility Estimates}\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\resizebox{1.0\\textwidth}{!}{\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '%%\\renewcommand{\\arraystretch}{0.8}\n');
fprintf(fid, '%%\\renewcommand{\\tabcolsep}{2pt}\n');
fprintf(fid, '\\begin{tabular}{lcccccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, '         & \\multicolumn{3}{c}{College} & \\multicolumn{3}{c}{Work} \\\\ \n');
fprintf(fid, '\\cmidrule(r){2-4}\\cmidrule(l){5-7}\n');
fprintf(fid, 'Variable & 2-year & Science & Non-Science & Part-time & Full-time & White Collar \\\\ \n');
fprintf(fid, '\\midrule\n');
for j=1:(size(results,1)-3)
    fprintf(fid, '%s & %s & %s & %s & %s & %s & %s \\\\ \n', results.names(j), results.b2{j}, results.b4s{j}, results.b4h{j}, results.bpt{j}, results.bft{j}, results.bwc{j});
    if ismember(j,[1 6:9 12 24 25])
        fprintf(fid, '%% & (%s) & (%s) & (%s) & (%s) & (%s) & (%s) \\\\ \n', results.seb2{j}, results.seb4s{j}, results.seb4h{j}, results.sebpt{j}, results.sebft{j}, results.sebwc{j});
    else
        fprintf(fid, ' & (%s) & (%s) & (%s) & (%s) & (%s) & (%s) \\\\ \n', results.seb2{j}, results.seb4s{j}, results.seb4h{j}, results.sebpt{j}, results.sebft{j}, results.sebwc{j});
    end
end
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Unobserved type \\\\ \n');
for j=(size(results,1)-2):size(results,1)
    fprintf(fid, '%s & %s & %s & %s & %s & %s & %s \\\\ \n', results.names(j), results.b2{j}, results.b4s{j}, results.b4h{j}, results.bpt{j}, results.bft{j}, results.bwc{j});
    fprintf(fid, ' & (%s) & (%s) & (%s) & (%s) & (%s) & (%s) \\\\ \n', results.seb2{j}, results.seb4s{j}, results.seb4h{j}, results.sebpt{j}, results.sebft{j}, results.sebwc{j});
end
fprintf(fid, '\\midrule\n');
fprintf(fid, '$\\mathbb{E}[u(\\text{consumption})] \\div 1,000$ & %4.3f & (%4.3f) & & & & \\\\ \n', alpha, se_alpha);
fprintf(fid, '$\\Pr(\\text{graduate\\,in\\,\\,} t+1)$               & %4.3f & (%4.3f) & & & & \\\\ \n', gp, se_gp);
fprintf(fid, 'Constant Relative Risk Aversion parameter ($\\theta$) & %4.1f & & & & & \\\\ \n',0.4);
fprintf(fid, 'Log likelihood & %s & & & & & \\\\ \n',addComma(choice_like_val));
fprintf(fid, 'Person-year obs. & %s & & & & & \\\\ \n',addComma(NTobs));
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Home production is the reference alternative. Bootstrap standard errors are listed below or to the side of each coefficient in parentheses. Beliefs on labor market productivity are included in the expected utility of consumption term. Consumption is evaluated in terms of yearly consumption flow in 1996 dollars.  Missing majors are estimated to be science with probability %3.2f. Missing GPAs are estimated to be $\\leq2.5$ w.p. %3.2f, 2.5--3.0 w.p. %3.2f, 3.0--3.6 w.p. %3.2f, and 3.6--4.0 w.p. %3.2f. \n', pr_missing_is_sci, pr_missing_gpa(1), pr_missing_gpa(2), pr_missing_gpa(3), pr_missing_gpa(4));
fprintf(fid, '\n');
fprintf(fid, '\\medskip\n');
fprintf(fid, '\n');
fprintf(fid, 'Reference categories for multinomial variables are as follows: ``White'''' for race/ethnicity, ``Previous home production'''' for previous decision, ``Not working'''' for in-college work intensity, and ``L'''' for each unobserved type. We omit the following coefficients: the constant (for each choice); birth year dummies (for each choice); and the interactions between currently working full- or part-time and currently working in the white-collar sector (for each of the schooling choices). \n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);
% delete standard errors that are blank
str = fileread([pathtables,'util_est_matrix.tex']);
str = strrep(str, '(  ','(');
str = strrep(str, '(  )','');
str = strrep(str, '( )','');
fid = fopen([pathtables,'util_est_matrix.tex'], 'w');
fprintf(fid, '%s', str);
fclose(fid);








% static choice model parameter estimates
% arrange parameter vector into nicer format, imposing various parameter restrictions
alpha = searchparms.bstrucsearch(1);
se_alpha = se_bstrucsearch(1);
galpha = searchparms.bstrucsearch(2);
se_galpha = se_bstrucsearch(2);
b2flg    = 2+[1:stnumber2];
b4sflg   = 2+[1+stnumber2:stnumber2+stnumber4s];
b4nsflg  = 2+[1+stnumber2+stnumber4s:stnumber2+stnumber4s+stnumber4ns];
bwptflg  = 2+[1+stnumber2+stnumber4s+stnumber4ns:stnumber2+stnumber4s+stnumber4ns+stnumberpt];
bgwptflg = 2+[1+stnumber2+stnumber4s+stnumber4ns+stnumberpt:stnumber2+stnumber4s+stnumber4ns+stnumberpt+stnumbergpt]; 
bwftflg  = 2+[1+stnumber2+stnumber4s+stnumber4ns+stnumberpt+stnumbergpt:stnumber2+stnumber4s+stnumber4ns+stnumberpt+stnumbergpt+stnumberft];
bgwftflg = 2+[1+stnumber2+stnumber4s+stnumber4ns+stnumberpt+stnumbergpt+stnumberft:stnumber2+stnumber4s+stnumber4ns+stnumberpt+stnumbergpt+stnumberft+stnumbergft];
bwcflg   = 2+[1+stnumber2+stnumber4s+stnumber4ns+stnumberpt+stnumbergpt+stnumberft+stnumbergft:stnumber2+stnumber4s+stnumber4ns+stnumberpt+stnumbergpt+stnumberft+stnumbergft+stnumberwc];
bgwcflg  = 2+[1+stnumber2+stnumber4s+stnumber4ns+stnumberpt+stnumbergpt+stnumberft+stnumbergft+stnumberwc:stnumber2+stnumber4s+stnumber4ns+stnumberpt+stnumbergpt+stnumberft+stnumbergft+stnumberwc+stnumbergwc];
b2         = searchparms.bstrucsearch(b2flg);
b2temp     = [b2(1:stsdemog+3);alpha;b2(stsdemog+4:end-7);999;b2(end-6:end)];
b4s        = searchparms.bstrucsearch(b4sflg);
b4stemp    = [b4s(1:stsdemog+3);alpha;b4s(stsdemog+4:end-7);999;b4s(end-6:end)];
b4ns       = searchparms.bstrucsearch(b4nsflg);
b4nstemp   = [b4ns(1:stsdemog+3);alpha;b4ns(stsdemog+4:end-7);999;b4ns(end-6:end)];
bwpt       = searchparms.bstrucsearch(bwptflg);
bwpttemp   = [bwpt(1:stsdemog);999;bwpt(stsdemog+1:stsdemog+2);alpha;bwpt(stsdemog+3:end-3);999;999;999;999;bwpt(end-2:end)];
bwft       = searchparms.bstrucsearch(bwftflg);
bwfttemp   = [bwft(1:stsdemog);999;bwft(stsdemog+1:stsdemog+2);alpha;bwft(stsdemog+3:end-3);999;999;999;999;999;bwft(end-2:end)];
bwc        = searchparms.bstrucsearch(bwcflg);
bwctemp    = [bwc(1:stsdemog);999;999;999;999;bwc(stsdemog+1:end-3);999;999;999;999;999;bwc(end-2:end)];
bgwpt      = searchparms.bstrucsearch(bgwptflg);
bgwpttemp  = [bgwpt(1:10);galpha];
bgwft      = searchparms.bstrucsearch(bgwftflg);
bgwfttemp  = [bgwft(1:10);galpha];
bgwc       = searchparms.bstrucsearch(bgwcflg);
bgwctemp   = [bgwc(1:10);999];
se_b2        = se_bstrucsearch(b2flg);
se_b2temp    = [se_b2(1:stsdemog+3);se_alpha;se_b2(stsdemog+4:end-7);999;se_b2(end-6:end)];
se_b4s       = se_bstrucsearch(b4sflg);
se_b4stemp   = [se_b4s(1:stsdemog+3);se_alpha;se_b4s(stsdemog+4:end-7);999;se_b4s(end-6:end)];
se_b4ns      = se_bstrucsearch(b4nsflg);
se_b4nstemp  = [se_b4ns(1:stsdemog+3);se_alpha;se_b4ns(stsdemog+4:end-7);999;se_b4ns(end-6:end)];
se_bwpt      = se_bstrucsearch(bwptflg);
se_bwpttemp  = [se_bwpt(1:stsdemog);999;se_bwpt(stsdemog+1:stsdemog+2);se_alpha;se_bwpt(stsdemog+3:end-3);999;999;999;999;se_bwpt(end-2:end)];
se_bwft      = se_bstrucsearch(bwftflg);
se_bwfttemp  = [se_bwft(1:stsdemog);999;se_bwft(stsdemog+1:stsdemog+2);se_alpha;se_bwft(stsdemog+3:end-3);999;999;999;999;999;se_bwft(end-2:end)];
se_bwc       = se_bstrucsearch(bwcflg);
se_bwctemp   = [se_bwc(1:stsdemog);999;999;999;999;se_bwc(stsdemog+1:end-3);999;999;999;999;999;se_bwc(end-2:end)];
se_bgwpt     = se_bstrucsearch(bgwptflg);
se_bgwpttemp = [se_bgwpt(1:10);se_galpha];
se_bgwft     = se_bstrucsearch(bgwftflg);
se_bgwfttemp = [se_bgwft(1:10);se_galpha];
se_bgwc      = se_bstrucsearch(bgwcflg);
se_bgwctemp  = [se_bgwc(1:10);999];
% format as table for ease of printing to latex file
results = table;
results.names = ["Constant";"Black";"Hispanic";"HS Grades (z-score)";"Parent graduated college";"Born in 1980";"Born in 1981";"Born in 1982";"Born in 1983";"Family Income (\$10,000)";"Age";"Age squared";"Experience";"Experience squared";"Years of college";"Years of college squared";"Prior academic ability";"Accumulated debt (\$1,000)";"Accumulated debt squared $\div 100$";"Non-grad $\times\mathbb{E}[u(\text{consumption})] \div 1,000$";"Previous high school";"Previous 2-year college";"Previous 4-year science";"Previous 4-year non-science";"Previous work part-time";"Previous work full-time";"Previous work white-collar";"Currently work white-collar";"Currently work part-time";"Currently work full-time";"Currently work part-time in white collar";"Currently work full-time in white collar";"Schooling ability type H";"Schooling preference type H";"Work motivation type H"; "College graduate";"Black $\times$ col. grad.";"Hispanic $\times$ col. grad.";"HS Grades (z-score) $\times$ col. grad";"Parent grad. col. $\times$ col. grad.";"Born in 1980 $\times$ col. grad.";"Born in 1981 $\times$ col. grad.";"Born in 1982 $\times$ col. grad.";"Born in 1983 $\times$ col. grad.";"Family Income (\$10,000) $\times$ col. grad.";"Col. grad $\times\mathbb{E}[u(\text{consumption})] \div 1,000$"];
results.b2    = [b2temp;999*ones(11,1)];
results.seb2  = [se_b2temp;999*ones(11,1)]; 
results.b4s   = [b4stemp;999*ones(11,1)]; 
results.seb4s = [se_b4stemp;999*ones(11,1)]; 
results.b4h   = [b4nstemp;999*ones(11,1)]; 
results.seb4h = [se_b4nstemp;999*ones(11,1)]; 
results.bpt   = [bwpttemp;bgwpttemp];
results.sebpt = [se_bwpttemp;se_bgwpttemp];
results.bft   = [bwfttemp;bgwfttemp];
results.sebft = [se_bwfttemp;se_bgwfttemp];
results.bwc   = [bwctemp;bgwctemp];
results.sebwc = [se_bwctemp;se_bgwctemp];
% now build the flow utility estimates table
fid = fopen(strcat(pathtables,'static_util_est_matrix.tex'), 'w');
fprintf(fid, '\\begin{landscape}\n');
fprintf(fid, '\\begin{ThreePartTable}\n');
fprintf(fid, '\\begin{TableNotes}\n');
fprintf(fid, '\\item[ ] Notes: Home production is the reference alternative. Bootstrap standard errors are listed below each coefficient in parentheses. Beliefs on labor market productivity are included in the expected utility of consumption term. Consumption is evaluated in terms of yearly consumption flow in 1996 dollars.  Missing majors are estimated to be science with probability %3.2f. Missing GPAs are estimated to be $\\leq2.5$ w.p. %3.2f, 2.5--3.0 w.p. %3.2f, 3.0--3.6 w.p. %3.2f, and 3.6--4.0 w.p. %3.2f. \n', pr_missing_is_sci, pr_missing_gpa(1), pr_missing_gpa(2), pr_missing_gpa(3), pr_missing_gpa(4));
fprintf(fid, '\n');
fprintf(fid, '\\medskip\n');
fprintf(fid, '\n');
fprintf(fid, 'Reference categories for multinomial variables are as follows: ``White'''' for race/ethnicity, ``Born in 1984'''' for birth year, ``Previous home production'''' for previous decision, ``Not working'''' for in-college work intensity, and ``L'''' for each unobserved type.\n');
fprintf(fid, '\\end{TableNotes}\n');
fprintf(fid, '\n');
fprintf(fid, '\\begin{longtable}{lcccccc}\n');
fprintf(fid, '\\caption{Parameter Estimates of Static Choice Model}\\\\\n');
fprintf(fid, '\\label{tab:Static Utility Estimates}\\\\\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Variable & 2-year & 4-year Sci & 4-year Non-Sci & Work PT & Work FT & White Collar \\\\ \n');
fprintf(fid, '\\midrule\n');
fprintf(fid, '\\endfirsthead\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Variable & 2-year & 4-year Sci & 4-year Non-Sci & Work PT & Work FT & White Collar \\\\ \n');
fprintf(fid, '\\midrule\n');
fprintf(fid, '\\endhead\n');
fprintf(fid, '\\cmidrule{5-7}\n');
fprintf(fid, '\\multicolumn{7}{r}{\\textit{continued}}\n');
fprintf(fid, '\\endfoot\n');
fprintf(fid, '\\insertTableNotes\n');
fprintf(fid, '\\endlastfoot\n');
for j=1:size(results,1)
    fprintf(fid, '%s & %4.3f & %4.3f & %4.3f & %4.3f & %4.3f & %4.3f \\\\ \n', results.names(j), results.b2(j), results.b4s(j), results.b4h(j), results.bpt(j), results.bft(j), results.bwc(j));
    fprintf(fid, ' & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) \\\\ \n', results.seb2(j), results.seb4s(j), results.seb4h(j), results.sebpt(j), results.sebft(j), results.sebwc(j));
end
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Constant Relative Risk Aversion parameter ($\\theta$) & \\multicolumn{6}{c}{%4.1f} \\\\ \n',0.4);
fprintf(fid, 'Log likelihood & \\multicolumn{6}{c}{%s} \\\\ \n',addComma(choice_like_val));
fprintf(fid, 'Person-year obs. & \\multicolumn{6}{c}{%s} \\\\ \n',addComma(NTobs));
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{longtable}\n');
fprintf(fid, '\\end{ThreePartTable}\n');
fprintf(fid, '\\end{landscape}\n');
fclose(fid);
% delete standard errors that are blank
% get rid of 998's and 999's
str = fileread([pathtables,'static_util_est_matrix.tex']);
str = strrep(str, '999.000', '');
str = strrep(str, '()', '');
fid = fopen([pathtables,'static_util_est_matrix.tex'], 'w');
fprintf(fid, '%s', str);
fclose(fid);




% Mass probabilities for types
results = table;
results.names = ["(H, H, H)";"(H, H, L)";"(H, L, H)";"(H, L, L)";"(L, H, H)";"(L, H, L)";"(L, L, H)";"(L, L, L)"];
results.b = prior(:);
results.se = se_prior(:);
fid = fopen(strcat(pathtables,'type_mass_probabilities.tex'), 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Estimates of Probability Mass for Each Unobserved Type}\n');
fprintf(fid, '\\label{tab:type_mass}\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lcc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Type Identity  & Mass Probability  & Std. Error \\\\ \n');
fprintf(fid, '\\midrule\n');
for j = 1:size(results,1)
    fprintf(fid, '%4s & %4.3f & (%4.3f) \\\\ \n', results.names(j), results.b(j), results.se(j));
end
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Bootstrap standard errors in parentheses. Type dummy labels are as follows: ``H'''' signifies ``high type''''; ``L'''' signifies ``low type''''. Labels are ordered as \\{ Schooling ability, Schooling preferences, Work motivation \\}. e.g. ``Unobserved type (H, L, H)'''' corresponds to a worker with high schooling ability, low schooling preferences, and high work motivation.  Labels are identified through the measurement system detailed in Appendix \\ref{App:meas-sys-appendix}. \n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);



% Unobserved types harmonious table
assert(size(strucparms.bstrucstruc,1)==141,'need to adjust indices for flow utility estimates in type coefficient signs table!');
assert(size(searchparms.bstrucsearch,1)==214,'need to adjust indices for static choice estimates!');
fid = fopen(strcat(pathtables,'types_all_eqns.tex'), 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Unobserved Type Coefficient Signs and Significance Across All Equations of the Model}\n');
fprintf(fid, '\\label{tab:type_harmony}\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\resizebox{\\textwidth}{!}{\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\renewcommand{\\arraystretch}{0.8}\n');
fprintf(fid, '\\begin{tabular}{lccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, '& \\multicolumn{3}{c}{Unobserved Type Identity} \\\\ \n');
fprintf(fid, '\\cmidrule{2-4}\n');
fprintf(fid, 'Model Equation & Sch. Abil. H & Sch. Pref. H & Work Motivation H \\\\ \n');
fprintf(fid, '\\midrule\n');
fprintf(fid, '\\multicolumn{4}{l}{\\textit{Panel A: Measurement System}} \\\\\n');
fprintf(fid, 'ASVAB Arithmetic Reasoning               & %s & %s & %s \\\\\n',detect_signif(bstartAR(end-2),se_bstartAR(end-2)),detect_signif(bstartAR(end-1),se_bstartAR(end-1)),detect_signif(bstartAR(end),se_bstartAR(end)));
fprintf(fid, 'ASVAB Coding Speed                       & %s & %s & %s \\\\\n',detect_signif(bstartCS(end-2),se_bstartCS(end-2)),detect_signif(bstartCS(end-1),se_bstartCS(end-1)),detect_signif(bstartCS(end),se_bstartCS(end)));
fprintf(fid, 'ASVAB Mathematical Knowledge             & %s & %s & %s \\\\\n',detect_signif(bstartMK(end-2),se_bstartMK(end-2)),detect_signif(bstartMK(end-1),se_bstartMK(end-1)),detect_signif(bstartMK(end),se_bstartMK(end)));
fprintf(fid, 'ASVAB Numerical Operations               & %s & %s & %s \\\\\n',detect_signif(bstartNO(end-2),se_bstartNO(end-2)),detect_signif(bstartNO(end-1),se_bstartNO(end-1)),detect_signif(bstartNO(end),se_bstartNO(end)));
fprintf(fid, 'ASVAB Paragraph Comprehension            & %s & %s & %s \\\\\n',detect_signif(bstartPC(end-2),se_bstartPC(end-2)),detect_signif(bstartPC(end-1),se_bstartPC(end-1)),detect_signif(bstartPC(end),se_bstartPC(end)));
fprintf(fid, 'ASVAB Word Knowledge                     & %s & %s & %s \\\\\n',detect_signif(bstartWK(end-2),se_bstartWK(end-2)),detect_signif(bstartWK(end-1),se_bstartWK(end-1)),detect_signif(bstartWK(end),se_bstartWK(end)));
fprintf(fid, 'SAT Math                                 & %s & %s & %s \\\\\n',detect_signif(bstartSATm(end-2),se_bstartSATm(end-2)),detect_signif(bstartSATm(end-1),se_bstartSATm(end-1)),detect_signif(bstartSATm(end),se_bstartSATm(end)));
fprintf(fid, 'SAT Verbal                               & %s & %s & %s \\\\\n',detect_signif(bstartSATv(end-2),se_bstartSATv(end-2)),detect_signif(bstartSATv(end-1),se_bstartSATv(end-1)),detect_signif(bstartSATv(end),se_bstartSATv(end)));
fprintf(fid, 'Late for Classes                         & %s & %s & %s \\\\\n',detect_signif(bstartLS(end-9),se_bstartLS(end-9)),detect_signif(bstartLS(end-8),se_bstartLS(end-8)),detect_signif(bstartLS(end-7),se_bstartLS(end-7)));
fprintf(fid, 'Regularly Break Rules                    & %s & %s & %s \\\\\n',detect_signif(bstartBR(end-8),se_bstartBR(end-8)),detect_signif(bstartBR(end-7),se_bstartBR(end-7)),detect_signif(bstartBR(end-6),se_bstartBR(end-6)));
fprintf(fid, 'Took Extra Classes/Lessons               & %s & %s & %s \\\\\n',detect_signif(bstartEC(end-2),se_bstartEC(end-2)),detect_signif(bstartEC(end-1),se_bstartEC(end-1)),detect_signif(bstartEC(end),se_bstartEC(end)));
fprintf(fid, 'Ever Took Classes During School Break    & %s & %s & %s \\\\\n',detect_signif(bstartTB(end-2),se_bstartTB(end-2)),detect_signif(bstartTB(end-1),se_bstartTB(end-1)),detect_signif(bstartTB(end),se_bstartTB(end)));
fprintf(fid, 'Reason Took Classes During Break         & %s & %s & %s \\\\\n',detect_signif(bstartRTB(end-2),se_bstartRTB(end-2)),detect_signif(bstartRTB(end-1),se_bstartRTB(end-1)),detect_signif(bstartRTB(end),se_bstartRTB(end)));
fprintf(fid, 'Have High Standards at Work              & %s & %s & %s \\\\\n',detect_signif(bstartHS(end-8),se_bstartHS(end-8)),detect_signif(bstartHS(end-7),se_bstartHS(end-7)),detect_signif(bstartHS(end-6),se_bstartHS(end-6)));
fprintf(fid, 'Make Every Effort to Do What is Expected & %s & %s & %s \\\\\n',detect_signif(bstartDE(end-8),se_bstartDE(end-8)),detect_signif(bstartDE(end-7),se_bstartDE(end-7)),detect_signif(bstartDE(end-6),se_bstartDE(end-6)));
fprintf(fid, 'Percent Chance Work at Age 30            & %s & %s & %s \\\\\n',detect_signif(bstartPWY(end-4),se_bstartPWY(end-4)),detect_signif(bstartPWY(end-3),se_bstartPWY(end-3)),detect_signif(bstartPWY(end-2),se_bstartPWY(end-2)));
fprintf(fid, 'Parental Assessment of Age-30 Work Pr.   & %s & %s & %s \\\\\n',detect_signif(bstartPWP(end-4),se_bstartPWP(end-4)),detect_signif(bstartPWP(end-3),se_bstartPWP(end-3)),detect_signif(bstartPWP(end-2),se_bstartPWP(end-2)));
fprintf(fid, ' & & & \\\\\n');
fprintf(fid, '\\multicolumn{4}{l}{\\textit{Panel B: Learning Outcomes}} \\\\\n');
fprintf(fid, 'White Collar Log Wages    & %s & %s & %s \\\\\n',detect_signif(bstartg(end-2),se_bstartg(end-2)),detect_signif(bstartg(end-1),se_bstartg(end-1)),detect_signif(bstartg(end),se_bstartg(end)));
fprintf(fid, 'Blue Collar Log Wages     & %s & %s & %s \\\\\n',detect_signif(bstartn(end-2),se_bstartn(end-2)),detect_signif(bstartn(end-1),se_bstartn(end-1)),detect_signif(bstartn(end),se_bstartn(end)));
fprintf(fid, '4-year Science Grades     & %s & %s & %s \\\\\n',detect_signif(bstart4s(end-2),se_bstart4s(end-2)),detect_signif(bstart4s(end-1),se_bstart4s(end-1)),detect_signif(bstart4s(end),se_bstart4s(end)));
fprintf(fid, '4-year Non-Science Grades & %s & %s & %s \\\\\n',detect_signif(bstart4h(end-2),se_bstart4h(end-2)),detect_signif(bstart4h(end-1),se_bstart4h(end-1)),detect_signif(bstart4h(end),se_bstart4h(end)));
fprintf(fid, '2-year Grades             & %s & %s & %s \\\\\n',detect_signif(bstart2(end-2),se_bstart2(end-2)),detect_signif(bstart2(end-1),se_bstart2(end-1)),detect_signif(bstart2(end),se_bstart2(end)));
fprintf(fid, ' & & & \\\\\n');
fprintf(fid, '\\multicolumn{4}{l}{\\textit{Panel C: White Collar Offer Arrival}} \\\\\n');
fprintf(fid, 'Receive White Collar Offer & %s & %s & %s \\\\\n',detect_signif(searchparms.boffer(end-2),se_boffer(end-2)),detect_signif(searchparms.boffer(end-1),se_boffer(end-1)),detect_signif(searchparms.boffer(end),se_boffer(end)));
fprintf(fid, ' & & & \\\\\n');
fprintf(fid, '\\multicolumn{4}{l}{\\textit{Panel D: Logit for Graduation in $t+1$}} \\\\\n');
fprintf(fid, 'Graduate in $t+1$ & %s & %s & %s \\\\\n',detect_signif(P_grad_betas4(end-2),se_P_grad_betas4(end-2)),detect_signif(P_grad_betas4(end-1),se_P_grad_betas4(end-1)),detect_signif(P_grad_betas4(end),se_P_grad_betas4(end)));
fprintf(fid, ' & & & \\\\\n');
fprintf(fid, '\\multicolumn{4}{l}{\\textit{Panel E: Flow Utilities}} \\\\\n');
fprintf(fid, '2-year College & %s & %s & %s \\\\\n',detect_signif(strucparms.bstrucstruc(25),se_bstrucstruc(25)),detect_signif(strucparms.bstrucstruc(26),se_bstrucstruc(26)),detect_signif(strucparms.bstrucstruc(27),se_bstrucstruc(27)));
fprintf(fid, '4-year Science & %s & %s & %s \\\\\n',detect_signif(strucparms.bstrucstruc(50),se_bstrucstruc(50)),detect_signif(strucparms.bstrucstruc(51),se_bstrucstruc(51)),detect_signif(strucparms.bstrucstruc(52),se_bstrucstruc(52)));
fprintf(fid, '4-year Non-Science & %s & %s & %s \\\\\n',detect_signif(strucparms.bstrucstruc(75),se_bstrucstruc(75)),detect_signif(strucparms.bstrucstruc(76),se_bstrucstruc(76)),detect_signif(strucparms.bstrucstruc(77),se_bstrucstruc(77)));
fprintf(fid, 'Work Part-Time & %s & %s & %s \\\\\n',detect_signif(strucparms.bstrucstruc(97),se_bstrucstruc(97)),detect_signif(strucparms.bstrucstruc(98),se_bstrucstruc(98)),detect_signif(strucparms.bstrucstruc(99),se_bstrucstruc(99)));
fprintf(fid, 'Work Full-Time & %s & %s & %s \\\\\n',detect_signif(strucparms.bstrucstruc(118),se_bstrucstruc(118)),detect_signif(strucparms.bstrucstruc(119),se_bstrucstruc(119)),detect_signif(strucparms.bstrucstruc(120),se_bstrucstruc(120)));
fprintf(fid, 'Work White Collar & %s & %s & %s \\\\\n',detect_signif(strucparms.bstrucstruc(139),se_bstrucstruc(139)),detect_signif(strucparms.bstrucstruc(140),se_bstrucstruc(140)),detect_signif(strucparms.bstrucstruc(141),se_bstrucstruc(141)));
fprintf(fid, 'Home Production & %s & %s & %s \\\\\n','(Ref.)','(Ref.)','(Ref.)');
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: $^\\ast$ indicates statistical significance at the 10\\%% level. $^{\\ast\\ast}$ indicates statistical significance at the 5\\%% level. ``(Ref.)'''' indicates that the coefficient is normalized as the reference category. See Tables \\ref{tab:msys-schabil}--\\ref{tab:msys-workabilpref} (measurement system), \\ref{tab:WageEstimates} (log wages), \\ref{tab:GPAEstimates} (grades), \\ref{tab:OfferEstimates} (offer arrival), \\ref{tab:GprobEstimates} (graduation), and \\ref{tab:Utility Estimates} (flow utilities) for exact parameter estimates. \n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);




% measurement system table: schooling ability measures
% format as table for ease of printing to latex file
results = table;
results.names = ["Constant";"Black";"Hispanic";"Born in 1980";"Born in 1981";"Born in 1982";"Born in 1983";"Parent graduated college";"Family Income (\$10,000)";"Schooling ability type H";"Schooling preference type H";"Work motivation type H";"Std. Dev. of noise"];
results.bAR     = [bstartAR;abs(sigAR)];
results.sebAR   = [se_bstartAR;se_sigAR];
results.bCS     = [bstartCS;abs(sigCS)];
results.sebCS   = [se_bstartCS;se_sigCS];
results.bMK     = [bstartMK;abs(sigMK)];
results.sebMK   = [se_bstartMK;se_sigMK];
results.bNO     = [bstartNO;abs(sigNO)];
results.sebNO   = [se_bstartNO;se_sigNO];
results.bPC     = [bstartPC;abs(sigPC)];
results.sebPC   = [se_bstartPC;se_sigPC];
results.bWK     = [bstartWK;abs(sigWK)];
results.sebWK   = [se_bstartWK;se_sigWK];
results.bSATm   = [bstartSATm;abs(sigSATm)];
results.sebSATm = [se_bstartSATm;se_sigSATm];
results.bSATv   = [bstartSATv;abs(sigSATv)];
results.sebSATv = [se_bstartSATv;se_sigSATv];
% flag type dummy reference categories
results.bAR    (results.bAR    ==0) = 998;
results.sebAR  (results.sebAR  ==0) = 998;
results.bCS    (results.bCS    ==0) = 998;
results.sebCS  (results.sebCS  ==0) = 998;
results.bMK    (results.bMK    ==0) = 998;
results.sebMK  (results.sebMK  ==0) = 998;
results.bNO    (results.bNO    ==0) = 998;
results.sebNO  (results.sebNO  ==0) = 998;
results.bPC    (results.bPC    ==0) = 998;
results.sebPC  (results.sebPC  ==0) = 998;
results.bWK    (results.bWK    ==0) = 998;
results.sebWK  (results.sebWK  ==0) = 998;
results.bSATm  (results.bSATm  ==0) = 998;
results.sebSATm(results.sebSATm==0) = 998;
results.bSATv  (results.bSATv  ==0) = 998;
results.sebSATv(results.sebSATv==0) = 998;
% now build the table
fid = fopen(strcat(pathtables,'schabil_meas_sys.tex'), 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Measurement System Estimates for Schooling Ability Measurements}\n');
fprintf(fid, '\\label{tab:msys-schabil}\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\resizebox{\\textwidth}{!}{\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\renewcommand{\\arraystretch}{0.8}\n');
fprintf(fid, '\\renewcommand{\\tabcolsep}{2pt}\n');
fprintf(fid, '\\begin{tabular}{lcccccccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, '         & \\multicolumn{6}{c}{ASVAB} & & \\\\ \n');
fprintf(fid, '\\cmidrule{2-7}\n');
fprintf(fid, '         & Arithmetic & Coding & Mathematical & Numerical & Paragraph & Word & \\multicolumn{2}{c}{SAT} \\\\ \n');
fprintf(fid, '\\cmidrule{8-9}\n');
fprintf(fid, 'Variable & Reasoning & Speed & Knowledge & Operations & Comprehension & Knowledge & Math & Verbal \\\\ \n');
fprintf(fid, '\\midrule\n');
for j=1:size(results,1)
    fprintf(fid, '%s & %4.3f & %4.3f & %4.3f & %4.3f & %4.3f & %4.3f & %4.3f & %4.3f \\\\ \n', results.names(j), results.bAR(j), results.bCS(j), results.bMK(j), results.bNO(j), results.bPC(j), results.bWK(j), results.bSATm(j), results.bSATv(j));
    fprintf(fid, ' & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) \\\\ \n', results.sebAR(j), results.sebCS(j), results.sebMK(j), results.sebNO(j), results.sebPC(j), results.sebWK(j), results.sebSATm(j), results.sebSATv(j));
end
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Observations & %s & %s & %s & %s & %s & %s & %s & %s \\\\ \n', addComma(2136), addComma(2122), addComma(2134), addComma(2122), addComma(2135), addComma(2136), addComma(1232), addComma(1223));
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Bootstrap standard errors are listed below each coefficient in parentheses. Each column represents estimates of a linear regression model with normally distributed errors, estimated by maximum likelihood.\n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);
% delete standard errors that are blank
str = fileread([pathtables,'schabil_meas_sys.tex']);
str = strrep(str, '(0.000)',   '(---)');
str = strrep(str, '(998.000)', '(---)');
str = strrep(str, '998.000',   'Ref.' );
fid = fopen([pathtables,'schabil_meas_sys.tex'], 'w');
fprintf(fid, '%s', str);
fclose(fid);






% measurement system table: schooling ability measures
% format as table for ease of printing to latex file
results = table;
results.names = ["Constant";"Black";"Hispanic";"Born in 1980";"Born in 1981";"Born in 1982";"Born in 1983";"Parent graduated college";"Family Income (\$10,000)";"Schooling ability type H";"Schooling preference type H";"Work motivation type H";"Cut point 1";"Cut point 2";"Cut point 3";"Cut point 4";"Cut point 5";"Cut point 6";"Cut point 7";"Std. Dev. of noise"];
results.bLS    = [999;bstartLS;999];
results.sebLS  = [999;se_bstartLS;999];
results.bBR    = [999;bstartBR;999;999];
results.sebBR  = [999;se_bstartBR;999;999];
results.bEC    = [bstartEC;999*ones(7,1);abs(sigEC)];
results.sebEC  = [se_bstartEC;999*ones(7,1);se_sigEC];
results.bTB    = [bstartTB;999*ones(8,1)];
results.sebTB  = [se_bstartTB;999*ones(8,1)];
results.bRTB   = [bstartRTB;999*ones(8,1)];
results.sebRTB = [se_bstartRTB;999*ones(8,1)];
% replace birth cohort dummy 0s with 999
indices = find((results.bLS==0)    & contains(string(results.names), 'Born'));
results.bLS   (indices) = 999;
indices = find((results.sebLS==0)  & contains(string(results.names), 'Born'));
results.sebLS (indices) = 999;
indices = find((results.bBR==0)    & contains(string(results.names), 'Born'));
results.bBR   (indices) = 999;
indices = find((results.sebBR==0)  & contains(string(results.names), 'Born'));
results.sebBR (indices) = 999;
indices = find((results.bEC==0)    & contains(string(results.names), 'Born'));
results.bEC   (indices) = 999;
indices = find((results.sebEC==0)  & contains(string(results.names), 'Born'));
results.sebEC (indices) = 999;
indices = find((results.bTB==0)    & contains(string(results.names), 'Born'));
results.bTB   (indices) = 999;
indices = find((results.sebTB==0)  & contains(string(results.names), 'Born'));
results.sebTB (indices) = 999;
indices = find((results.bRTB==0)   & contains(string(results.names), 'Born'));
results.bRTB  (indices) = 999;
indices = find((results.sebRTB==0) & contains(string(results.names), 'Born'));
results.sebRTB(indices) = 999;
% replace type dummy 0s with 998
indices = find((results.bLS==0)    & ~contains(string(results.names), 'Born'));
results.bLS   (indices) = 998;
indices = find((results.sebLS==0)  & ~contains(string(results.names), 'Born'));
results.sebLS (indices) = 998;
indices = find((results.bBR==0)    & ~contains(string(results.names), 'Born'));
results.bBR   (indices) = 998;
indices = find((results.sebBR==0)  & ~contains(string(results.names), 'Born'));
results.sebBR (indices) = 998;
indices = find((results.bEC==0)    & ~contains(string(results.names), 'Born'));
results.bEC   (indices) = 998;
indices = find((results.sebEC==0)  & ~contains(string(results.names), 'Born'));
results.sebEC (indices) = 998;
indices = find((results.bTB==0)    & ~contains(string(results.names), 'Born'));
results.bTB   (indices) = 998;
indices = find((results.sebTB==0)  & ~contains(string(results.names), 'Born'));
results.sebTB (indices) = 998;
indices = find((results.bRTB==0)   & ~contains(string(results.names), 'Born'));
results.bRTB  (indices) = 998;
indices = find((results.sebRTB==0) & ~contains(string(results.names), 'Born'));
results.sebRTB(indices) = 998;
% now build the table
fid = fopen(strcat(pathtables,'schabilpref_meas_sys.tex'), 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Measurement System Estimates for Schooling Ability \\& Preferences Measurements}\n');
fprintf(fid, '\\label{tab:msys-schabilpref}\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\resizebox{0.9\\textwidth}{!}{\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\renewcommand{\\arraystretch}{0.8}\n');
fprintf(fid, '\\renewcommand{\\tabcolsep}{2pt}\n');
fprintf(fid, '\\begin{tabular}{lccccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, '         & No. times late & Break rules & Hours per week & Ever took classes   & Reason took classes \\\\ \n');
fprintf(fid, 'Variable & for school     & regularly   & extra classes  & during school break & during school break \\\\ \n');
fprintf(fid, '\\midrule\n');
for j=1:size(results,1)
    fprintf(fid, '%s & %4.3f & %4.3f & %4.3f & %4.3f & %4.3f \\\\ \n', results.names(j), results.bLS(j), results.bBR(j), results.bEC(j), results.bTB(j), results.bRTB(j));
    fprintf(fid, ' & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) \\\\ \n', results.sebLS(j), results.sebBR(j), results.sebEC(j), results.sebTB(j), results.sebRTB(j));
end
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Observations & %s & %s & %s & %s & %s \\\\ \n', addComma(2303), addComma(2088), addComma(1386), addComma(1141), addComma(151));
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Bootstrap standard errors are listed below each coefficient in parentheses. The first two columns are estimates of ordered logit models, where ``Break rules regulary'''' is on a Likert scale with seven levels. ``Hours per week in extra classes'''' is a Type II Tobit model left-censored at zero hours. ``Ever took classes during school break'''' and ``Reason took classes during school break'''' are binary logit models with respective positive categories of ``Yes'''' and ``In order to accelerate, for fun, or for enrichment'''' and respective reference categories ``No'''' and ``To make up classes or for other reasons.'''' \n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);
% get rid of 998's and 999's
str = fileread([pathtables,'schabilpref_meas_sys.tex']);
str = strrep(str, '(998.000)', '(---)');
str = strrep(str, '998.000',   'Ref.' );
str = strrep(str, '999.000', '');
str = strrep(str, '()', '');
fid = fopen([pathtables,'schabilpref_meas_sys.tex'], 'w');
fprintf(fid, '%s', str);
fclose(fid);




% measurement system table: work ability and preference measures
% format as table for ease of printing to latex file
results = table;
results.names = ["Black";"Hispanic";"Born in 1980";"Born in 1981";"Born in 1982";"Born in 1983";"Parent graduated college";"Family Income (\$10,000)";"Schooling ability type H";"Schooling preference type H";"Work motivation type H";"Cut point 1";"Cut point 2";"Cut point 3";"Cut point 4";"Cut point 5";"Cut point 6"];
results.bHS    = bstartHS;
results.sebHS  = se_bstartHS;
results.bDE    = bstartDE;
results.sebDE  = se_bstartDE;
results.bPWY   = [bstartPWY;999*ones(4,1)];
results.sebPWY = [se_bstartPWY;999*ones(4,1)];
results.bPWP   = [bstartPWP;999*ones(4,1)];
results.sebPWP = [se_bstartPWP;999*ones(4,1)];
% replace type dummy 0s with 998
indices = find((results.bHS==0)    & ~contains(string(results.names), 'Born'));
results.bHS   (indices) = 998;
indices = find((results.sebHS==0)  & ~contains(string(results.names), 'Born'));
results.sebHS (indices) = 998;
indices = find((results.bDE==0)    & ~contains(string(results.names), 'Born'));
results.bDE   (indices) = 998;
indices = find((results.sebDE==0)  & ~contains(string(results.names), 'Born'));
results.sebDE (indices) = 998;
indices = find((results.bPWY==0)   & ~contains(string(results.names), 'Born'));
results.bPWY   (indices) = 998;
indices = find((results.sebPWY==0) & ~contains(string(results.names), 'Born'));
results.sebPWY (indices) = 998;
indices = find((results.bPWP==0)   & ~contains(string(results.names), 'Born'));
results.bPWP   (indices) = 998;
indices = find((results.sebPWP==0) & ~contains(string(results.names), 'Born'));
results.sebPWP (indices) = 998;
% replace birth cohort dummy 0s with 999
indices = find((results.bHS==0)    & contains(string(results.names), 'Born'));
results.bHS   (indices) = 999;
indices = find((results.sebHS==0)  & contains(string(results.names), 'Born'));
results.sebHS (indices) = 999;
indices = find((results.bDE==0)    & contains(string(results.names), 'Born'));
results.bDE   (indices) = 999;
indices = find((results.sebDE==0)  & contains(string(results.names), 'Born'));
results.sebDE (indices) = 999;
indices = find((results.bPWY==0)   & contains(string(results.names), 'Born'));
results.bPWY   (indices) = 999;
indices = find((results.sebPWY==0) & contains(string(results.names), 'Born'));
results.sebPWY (indices) = 999;
indices = find((results.bPWP==0)   & contains(string(results.names), 'Born'));
results.bPWP   (indices) = 999;
indices = find((results.sebPWP==0) & contains(string(results.names), 'Born'));
results.sebPWP (indices) = 999;
% now build the table
fid = fopen(strcat(pathtables,'workabilpref_meas_sys.tex'), 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Measurement System Estimates for Working Ability \\& Preferences Measurements}\n');
fprintf(fid, '\\label{tab:msys-workabilpref}\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\resizebox{0.85\\textwidth}{!}{\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\renewcommand{\\arraystretch}{0.8}\n');
fprintf(fid, '\\renewcommand{\\tabcolsep}{2pt}\n');
fprintf(fid, '\\begin{tabular}{lcccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, '         &                &                & Individual''s subjective & Parent''s subjective  \\\\ \n');
fprintf(fid, '         & High standards & Try to do what & likelihood of working    & likelihood of working \\\\ \n');
fprintf(fid, 'Variable & at work        & is expected    & at age 30                & at age 30             \\\\ \n');
fprintf(fid, '\\midrule\n');
for j=1:size(results,1)
    fprintf(fid, '%s & %4.3f & %4.3f & %4.3f & %4.3f \\\\ \n', results.names(j), results.bHS(j), results.bDE(j), results.bPWY(j), results.bPWP(j));
    fprintf(fid, ' & (%4.3f) & (%4.3f) & (%4.3f) & (%4.3f) \\\\ \n', results.sebHS(j), results.sebDE(j), results.sebPWY(j), results.sebPWP(j));
end
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Observations & %s & %s & %s & %s \\\\ \n', addComma(2085), addComma(2087), addComma(915), addComma(849));
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Bootstrap standard errors are listed below each coefficient in parentheses. Each column represents estimates of an ordered logit model. The first two columns are Likert scales with seven levels. The latter two columns are on a scale of 0\\%%--100\\%% that has been discretized into three bins: 0\\%%--75\\%%, 76\\%%--90\\%%, and 91\\%%+ \n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);
% get rid of 998's and 999's
str = fileread([pathtables,'workabilpref_meas_sys.tex']);
str = strrep(str, '(998.000)', '(---)');
str = strrep(str, '998.000',   'Ref.' );
str = strrep(str, '999.000', '');
str = strrep(str, '()', '');
fid = fopen([pathtables,'workabilpref_meas_sys.tex'], 'w');
fprintf(fid, '%s', str);
fclose(fid);
