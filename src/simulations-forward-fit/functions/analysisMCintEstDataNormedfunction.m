function [output,output2] = analysisMCintEstDataNormedfunction(tau)

[status,cmdout] = system('ls -t ../../EstimationNoGradSchTheta0_4/everything_jointsearch_WCabsorb*.mat | head -1','-echo');
ffffff = strtrim(cmdout);
load(ffffff,'dataStruct','searchparms','AR1parms','S','learnparms','Clb','CRRA','PmajgpaType'); % has the following: 'searchparms','AR1parms','Searchstruct','Utilstruct','PmajgpaType','sPmajgpaType','S','dataStruct','priorabilstruct','consumpstructMCint','ngpct','learnStruct','learnparms','Clb','CRRA'
cmapParms   = load('../../EstimationNoGradSchTheta0_4/cmapoutput.mat'); 
cmapParmst1 = load('../../EstimationNoGradSchTheta0_4/cmapoutput_t1.mat'); 
cmapParmst2 = load('../../EstimationNoGradSchTheta0_4/cmapoutput_t2.mat'); 
load('../../EstimationNoGradSchTheta0_4/gradLogitEstimatesMostFlex','P_grad_betas4');
[status,cmdout] = system('ls -t ../../EstimationNoGradSchTheta0_4/everything_consumpstructural_FVfast*.mat | head -1','-echo');
gggggg = strtrim(cmdout);
load(gggggg);
sigNormed=cat(1,learnparms.sig(1),learnparms.lambdag1start^2*learnparms.sig(2),learnparms.sig(3),learnparms.lambdan1start^2*learnparms.sig(4),learnparms.sig(5:6),learnparms.lambda4s1start^2*learnparms.sig(7:9),learnparms.sig(10:11),learnparms.lambda4h1start^2*learnparms.sig(12:14),learnparms.sig(15:17));
learnparms.Delta = tril(learnparms.Delta,-1)+tril(learnparms.Delta,-1)'+diag(diag(learnparms.Delta));
load simDataMCintEstData10D_10rep
Delta = learnparms.Delta;
ClImps = dataStruct.ClImps;
grad_4yrlImps = dataStruct.grad_4yrlImps;

J   = size(Delta,2); % number of sectors in learning model

% Choice alternatives
% 1.  2yr FT BC
% 2.  2yr FT WC
% 3.  2yr PT BC
% 4.  2yr PT WC
% 5.  2yr only
% 6.  4yr S FT BC
% 7.  4yr S FT WC
% 8.  4yr S PT BC
% 9.  4yr S PT WC
% 10. 4yr S only
% 11. 4yr H FT BC
% 12. 4yr H FT WC
% 13. 4yr H PT BC
% 14. 4yr H PT WC
% 15. 4yr H only
% 16. work PT only BC
% 17. work PT only WC
% 18. work FT only BC
% 19. work FT only WC
% 20. home production

% load first simulation replicate
Ymat               = YmatD              (:,1:tau,1);     % choice variable in {1,...,15}
age                = ageD               (:,1:tau,1);     % age (in years since age 18)
cum_2yr            = cum_2yrD           (:,1:tau,1);     % 2yr college experience
cum_4yr            = cum_4yrD           (:,1:tau,1);     % 4yr college experience
exper              = experD             (:,1:tau,1);     % blue+white collar experience
exper_white_collar = exper_white_collarD(:,1:tau,1);     % white collar experience
grad_4yr           = grad_4yrD          (:,1:tau,1);     % graduation dummy
prev_2yr           = prev_2yrD          (:,1:tau,1);     % previously in 2yr
prev_4yrNS         = prev_4yrNSD        (:,1:tau,1);     % previously in 4yr humanities
prev_4yrS          = prev_4yrSD         (:,1:tau,1);     % previously in 4yr science
prev_WC            = prev_WCD           (:,1:tau,1);     % previously in work FT
prev_FT            = prev_FTD           (:,1:tau,1);     % previously in work FT
prev_HS            = prev_HSD           (:,1:tau,1);     % previously in high school
prev_PT            = prev_PTD           (:,1:tau,1);     % previously in work PT
year               = yearD              (:,1:tau,1);     % calendar year
offer              = offerD             (:,1:tau,1);     % calendar year
priorAbilMat       = priorAbilMatD      (:,:,1:tau,1);   % prior ability (NxJxT)
posteriorAbilMat   = posteriorAbilMatD  (:,:,1:tau,1);   % posterior ability (NxJxT)
priorVarMat        = priorVarMatD       (:,:,:,1:tau,1); % prior variance (NxJxJxT)
posteriorVarMat    = posteriorVarMatD   (:,:,:,1:tau,1); % posterior variance (NxJxJxT)
trueAbil           = trueAbilD          (:,:,1);         % true ability (Nx1)
% freq               = freqD              (:,1);           % choice frequencies (15x1)
finalMajorSci      = finalMajorSciD     (:,1);           % graduated in science (Nx1)
type               = typeD              (:,1);           % unobserved type (Nx1)
black              = blackD             (:,1);           % black (Nx1)
hispanic           = hispanicD          (:,1);           % hispanic (Nx1)
Parent_college     = Parent_collegeD    (:,1);           % Parent_college (Nx1)
HS_grades          = HS_gradesD         (:,1);           % HS_grades (Nx1)
born1980           = born1980D          (:,1);           % born1980 (Nx1)         
born1981           = born1981D          (:,1);           % born1981 (Nx1)
born1982           = born1982D          (:,1);           % born1982 (Nx1)
born1983           = born1983D          (:,1);           % born1983 (Nx1)
famInc             = famIncD            (:,1);           % famInc (Nx1)     

% load replicates 2 through D and stack them
for d=2:D
	Ymat               = cat(1,Ymat              ,YmatD              (:,1:tau,d));
	age                = cat(1,age               ,ageD               (:,1:tau,d));
	cum_2yr            = cat(1,cum_2yr           ,cum_2yrD           (:,1:tau,d));
	cum_4yr            = cat(1,cum_4yr           ,cum_4yrD           (:,1:tau,d));
	exper              = cat(1,exper             ,experD             (:,1:tau,d));
	exper_white_collar = cat(1,exper_white_collar,exper_white_collarD(:,1:tau,d));
	grad_4yr           = cat(1,grad_4yr          ,grad_4yrD          (:,1:tau,d));
	prev_2yr           = cat(1,prev_2yr          ,prev_2yrD          (:,1:tau,d));
	prev_4yrNS         = cat(1,prev_4yrNS        ,prev_4yrNSD        (:,1:tau,d));
	prev_4yrS          = cat(1,prev_4yrS         ,prev_4yrSD         (:,1:tau,d));
	prev_WC            = cat(1,prev_WC           ,prev_WCD           (:,1:tau,d));
	prev_FT            = cat(1,prev_FT           ,prev_FTD           (:,1:tau,d));
	prev_HS            = cat(1,prev_HS           ,prev_HSD           (:,1:tau,d));
	prev_PT            = cat(1,prev_PT           ,prev_PTD           (:,1:tau,d));
	year               = cat(1,year              ,yearD              (:,1:tau,d));
	offer              = cat(1,offer             ,offerD             (:,1:tau,d));
	priorAbilMat       = cat(1,priorAbilMat      ,priorAbilMatD      (:,:,1:tau,d));
	posteriorAbilMat   = cat(1,posteriorAbilMat  ,posteriorAbilMatD  (:,:,1:tau,d));
	priorVarMat        = cat(1,priorVarMat       ,priorVarMatD       (:,:,:,1:tau,d));
	posteriorVarMat    = cat(1,posteriorVarMat   ,posteriorVarMatD   (:,:,:,1:tau,d));
	trueAbil           = cat(1,trueAbil          ,trueAbilD          (:,:,d));
	% freq               = cat(1,freq              ,freqD              (:,d));
	finalMajorSci      = cat(1,finalMajorSci     ,finalMajorSciD     (:,d));
	type               = cat(1,type              ,typeD              (:,d));
	black              = cat(1,black             ,blackD             (:,d));
	hispanic           = cat(1,hispanic          ,hispanicD          (:,d));
	HS_grades          = cat(1,HS_grades         ,HS_gradesD         (:,d));
	Parent_college     = cat(1,Parent_college    ,Parent_collegeD    (:,d));
	born1980           = cat(1,born1980          ,born1980D          (:,d));
	born1981           = cat(1,born1981          ,born1981D          (:,d));
	born1982           = cat(1,born1982          ,born1982D          (:,d));
	born1983           = cat(1,born1983          ,born1983D          (:,d));
    famInc             = cat(1,famInc            ,famIncD            (:,d));
end


N           = length(type);
LY          = [20*ones(N,1) Ymat(:,1:end-1)];
YmatFut     = [Ymat(:,2:end) nan(N,1)];
grad_4yrLY  = [zeros(N,1) grad_4yr(:,1:end-1)];
grad_4yrFut = [grad_4yr(:,2:end) nan(N,1)];

% Normalize ability to be in terms of SD of that ability
trueAbil         = trueAbil        ./repmat(sqrt(diag(Delta))',[N 1]);
posteriorAbilMat = posteriorAbilMat./repmat(sqrt(diag(Delta))',[N 1 tau]);
priorAbilMat     = priorAbilMat    ./repmat(sqrt(diag(Delta))',[N 1 tau]);

% create NxJxT matrices of the diagonals of the prior and posterior variance matrices
priorVarDiagMat = nan(size(priorAbilMat));
for j=1:J
	priorVarDiagMat(:,j,:) = priorVarMat(:,j,j,:);
end
posteriorVarDiagMat = nan(size(posteriorAbilMat));
for j=1:J
	posteriorVarDiagMat(:,j,:) = posteriorVarMat(:,j,j,:);
end

%---------------------------------------
% Generate completion category variables
% 6 potential Categories:
% Continuous completion (CC)
% Stop out (SO) but graduated
% Stop out (SO) then drop out
% Drop out (DO)
% CC truncated
% SO truncated
%---------------------------------------
schOpts       = [1:15];
nonSchOpts    = [16:20];
workSchOpts   = [1 2 3 4 6 7 8 9 11 12 13 14];
workWCschOpts = [2 4 7 9 12 14];
workBCschOpts = [1 3 6 8 11 13];
workFTschOpts = [1 2 6 7 11 12];
workPTschOpts = [3 4 8 9 13 14];
c2Opts        = [1:5];
c4Opts        = [6:15];
c4sOpts       = [6:10];
c4hOpts       = [11:15];
workOpts      = [17:19];
workWCOpts    = [17 19];
workBCOpts    = [16 18];
workWCanyOpts = [2 4 7 9 12 14 17 19];
workBCanyOpts = [1 3 6 8 11 13 16 18];
workWCgOpts   = [17 19];
workBCgOpts   = [16 18];
workWCngOpts  = [2 4 7 9 12 14 17 19];
workBCngOpts  = [1 3 6 8 11 13 16 18];
truncated     = ismember(Ymat(:,end),schOpts);
taumat        = kron(ones(N,1),[1:tau]);
colmat        = ismember(Ymat,schOpts).*taumat; colmat(colmat==0) = NaN;
neverCollege  = max(ismember(Ymat,schOpts),[],2)==0;
delayCollege  = ismember(Ymat(:,1),nonSchOpts) & ~neverCollege;
firstColPer   = nanmin(colmat,[],2);
lastColPer    = nanmax(colmat,[],2); lastColPer(isnan(lastColPer))=tau;
start2yr      = zeros(N,1);
startSci      = zeros(N,1);
startHum      = zeros(N,1);
startWC       = zeros(N,1);
startBC       = zeros(N,1);
stillInSch    = zeros(N,1);
for i=1:N
	if ~isnan(firstColPer(i));
		start2yr(i) = ismember(Ymat(i,firstColPer(i)),c2Opts);
		startSci(i) = ismember(Ymat(i,firstColPer(i)),c4sOpts);
		startHum(i) = ismember(Ymat(i,firstColPer(i)),c4hOpts);
	end
    if neverCollege(i)==1
        tmp = Ymat(i,:);
    else
        tmp = Ymat(i,(lastColPer(i)+1):tau);
    end
    tl  = length(tmp);
    %if tl<=1
    %    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    %    disp('            Problem with tmp                        ')
    %    i
    %    neverCollege(i)
    %    lastColPer(i)
    %    Ymat(i,:)
    %    colmat(i,:)
    %end
    if tl==0
        stillInSch(i) = 1;
    elseif tl>=1 & ismember(tmp(1),[workWCanyOpts workBCanyOpts])
        startWC(i) = ismember(tmp(1),workWCanyOpts);
        startBC(i) = ismember(tmp(1),workBCanyOpts);
    elseif tl>=2 && ~ismember(tmp(1),[workWCanyOpts workBCanyOpts]) && ismember(tmp(2),[workWCanyOpts workBCanyOpts])
        startWC(i) = ismember(tmp(2),workWCanyOpts);
        startBC(i) = ismember(tmp(2),workBCanyOpts);
    elseif tl>=3 && ~ismember(tmp(1),[workWCanyOpts workBCanyOpts]) && ~ismember(tmp(2),[workWCanyOpts workBCanyOpts]) && ismember(tmp(3),[workWCanyOpts workBCanyOpts]) 
        startWC(i) = ismember(tmp(3),workWCanyOpts);
        startBC(i) = ismember(tmp(3),workBCanyOpts);
    elseif tl>=4 && ~ismember(tmp(1),[workWCanyOpts workBCanyOpts]) && ~ismember(tmp(2),[workWCanyOpts workBCanyOpts]) && ~ismember(tmp(3),[workWCanyOpts workBCanyOpts]) && ismember(tmp(4),[workWCanyOpts workBCanyOpts]) 
        startWC(i) = ismember(tmp(4),workWCanyOpts);
        startBC(i) = ismember(tmp(4),workBCanyOpts);
    elseif tl>=5 && ~ismember(tmp(1),[workWCanyOpts workBCanyOpts]) && ~ismember(tmp(2),[workWCanyOpts workBCanyOpts]) && ~ismember(tmp(3),[workWCanyOpts workBCanyOpts]) && ~ismember(tmp(4),[workWCanyOpts workBCanyOpts]) && ismember(tmp(5),[workWCanyOpts workBCanyOpts])   
        startWC(i) = ismember(tmp(5),workWCanyOpts);
        startBC(i) = ismember(tmp(5),workBCanyOpts);
    end
    if mod(i,2000)==0
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        i
        tmp
        if tl==0
            Ymat(i,:)
        end
        startWC(i)
        startBC(i)
    end
end
startNW       = 1-startWC-startBC-stillInSch;
start2yr      = logical(start2yr);
startSci      = logical(startSci);
startHum      = logical(startHum);
everGrad4yr   = max(grad_4yr,[],2)==1;
everEnrl2yr   = max(ismember(Ymat,c2Opts),[],2)==1;
everEnrl4yr   = max(ismember(Ymat,c4Opts),[],2)==1;
SO            = (cum_2yr+cum_4yr)>0 & prev_2yr==0 & prev_4yrS==0 & prev_4yrNS==0 & ismember(Ymat,schOpts);
SOmat         = SO.*taumat; SOmat(SOmat==0) = NaN;
everSO        = max(SO,[],2)==1;
DO            = ismember(Ymat,schOpts) & ismember(YmatFut,nonSchOpts) & grad_4yrFut==0;
DOmat         = DO.*taumat; DOmat(DOmat==0) = NaN;
everDO        = ~everSO & max(DO,[],2)==1;
everCC        = ~neverCollege & all(isnan(SOmat),2) & all(isnan(DOmat),2);
%grad2flag     = everGrad2yr & ~everEnrl4yr;
CCDOSO        = 1*(everCC & everGrad4yr) + 2*(everSO & everGrad4yr) + 3*(everSO & ~everGrad4yr & ~truncated) + 4*(everDO) + 5*(everCC & truncated) + 6*(everSO & ~everGrad4yr & truncated) + 7*neverCollege;
CCDOSOdetail  = 1*(everCC & everGrad4yr & finalMajorSci==1) + 2*(everCC & everGrad4yr & finalMajorSci==0) + 3*(everSO & everGrad4yr & finalMajorSci==1) + 4*(everSO & everGrad4yr & finalMajorSci==0) + 5*(everSO & ~everGrad4yr & ~truncated) + 6*(everDO) + 7*(everCC & truncated) + 8*(everSO & ~everGrad4yr & truncated) + 9*neverCollege;
%CCDOSOgrad2   = 1*(everCC & everGrad4yr) + 2*(everSO & everGrad4yr) + 3*(everSO & ~everGrad4yr & ~truncated) + 4*(everDO & ~grad2flag) + 5*(everDO & grad2flag) + 6*(everCC & truncated) + 7*(everSO & ~everGrad4yr & truncated) + 8*neverCollege;
% summarize([ (everCC & everGrad4yr) (everSO & everGrad4yr) (everSO & ~everGrad4yr & ~truncated) (everDO) (everCC & truncated) (everSO & ~everGrad4yr & truncated) neverCollege]);
everWorkSch   = max(ismember(Ymat,workSchOpts),[],2);
everWorkWCsch = max(ismember(Ymat,workWCschOpts),[],2);
everWorkBCsch = max(ismember(Ymat,workBCschOpts),[],2);
num2yr        = cumsum(ismember(Ymat,c2Opts),2);
numSci        = cumsum(ismember(Ymat,c4sOpts),2);
numHum        = cumsum(ismember(Ymat,c4hOpts),2);
numWorkFTSch  = cumsum(ismember(Ymat,workFTschOpts),2);
numWorkPTSch  = cumsum(ismember(Ymat,workPTschOpts),2);
numWorkWCSch  = cumsum(ismember(Ymat,workWCschOpts),2);
numWorkBCSch  = cumsum(ismember(Ymat,workBCschOpts),2);
numWCWork     = cumsum(ismember(Ymat,workWCOpts),2);
numBCWork     = cumsum(ismember(Ymat,workBCOpts),2);
num2yrMat     = num2yr;
numSciMat     = numSci;
numHumMat     = numHum;
num2yr        = num2yr(:,tau);
numSci        = numSci(:,tau);
numHum        = numHum(:,tau);
numSchoolMat  = num2yrMat+numSciMat+numHumMat;
numSchoolNow  = numSchoolMat.*(ismember(Ymat,schOpts));
numSchool     = num2yr+numSci+numHum;
numWorkFTSch  = numWorkFTSch(:,tau);
numWorkPTSch  = numWorkPTSch(:,tau);
numWCWork     = numWCWork(:,tau);
numBCWork     = numBCWork(:,tau);
numWorkSch    = numWorkFTSch+.5*numWorkPTSch;
ever2yr       = max(ismember(Ymat,c2Opts ),[],2);
ever4yr       = max(ismember(Ymat,c4Opts ),[],2);
ever4yrS      = max(ismember(Ymat,c4sOpts),[],2);
ever4yrNS     = max(ismember(Ymat,c4hOpts),[],2);
CCDOSO1       = 1*(everCC & everGrad4yr) + 2*(everSO & everGrad4yr) + 3*(everSO & ~everGrad4yr & ~truncated) + 4*(everDO) + 5*(everCC & truncated) + 6*(everSO & ~everGrad4yr & truncated) + 7*(neverCollege & ((numWCWork+numBCWork)>=5)) + 8*(neverCollege & ((numWCWork+numBCWork)<5));
CCDOSOdetail1  = 1*(everCC & everGrad4yr & finalMajorSci==1) + 2*(everCC & everGrad4yr & finalMajorSci==0) + 3*(everSO & everGrad4yr & finalMajorSci==1) + 4*(everSO & everGrad4yr & finalMajorSci==0) + 5*(everSO & ~everGrad4yr & ~truncated) + 6*(everDO) + 7*(everCC & truncated) + 8*(everSO & ~everGrad4yr & truncated) + 9*(neverCollege & ((numWCWork+numBCWork)>=5)) + 10*(neverCollege & ((numWCWork+numBCWork)<5)); 

% Create vectors that hold the period in which a person last attended school
yrGrad4yr     = lastColPer(everGrad4yr);
yrSO          = lastColPer(everSO);
yrDO          = lastColPer(everDO);

assert(sum(start2yr+startSci+startHum+neverCollege==1)==N,'Error in college starting dummies!');

if tau==10
%---------------------------------------------------
% Creating Table 1 with Baseline Simulation
%---------------------------------------------------
%black              = blackD             (:,1);           % black (Nx1)
%hispanic           = hispanicD          (:,1);           % hispanic (Nx1)
%Parent_college     = Parent_collegeD    (:,1);           % Parent_college (Nx1)
%HS_grades          = HS_gradesD         (:,1);           % HS_grades (Nx1)
%born1980           = born1980D          (:,1);           % born1980 (Nx1)         
%born1981           = born1981D          (:,1);           % born1981 (Nx1)
%born1982           = born1982D          (:,1);           % born1982 (Nx1)
%born1983           = born1983D          (:,1);           % born1983 (Nx1)
%famInc             = famIncD            (:,1);           % famInc (Nx1)     
demog              = [black hispanic HS_grades Parent_college born1980 born1981 born1982 born1983 famInc];
%size(demog)
%size(start2yr)
mean_two_year      = mean(demog(start2yr==1,:));
mean_four_year_sci = mean(demog(startSci==1,:));
mean_four_year_hum = mean(demog(startHum==1,:));
mean_no_college    = mean(demog(neverCollege==1,:));
mean_total         = mean(demog);
meanmat            = cat(1,mean_two_year,mean_four_year_sci,mean_four_year_hum,mean_no_college,mean_total)';
Nmat               = cat(1,sum(start2yr==1),sum(startSci==1),sum(startHum==1),sum(neverCollege==1),N);

sd_two_year        = std(demog(start2yr==1,:));
sd_four_year_sci   = std(demog(startSci==1,:));
sd_four_year_hum   = std(demog(startHum==1,:));
sd_no_college      = std(demog(neverCollege==1,:));
sd_total           = std(demog);
sdmat              =  cat(1,sd_two_year,sd_four_year_sci,sd_four_year_hum,sd_no_college,sd_total)';

% LaTeX export of demographics by starting point:
names = cell(9,1);
names{1 } = 'Black';
names{2 } = 'Hispanic';
names{3 } = 'HS GPA';
names{4 } = 'Parent graduated college';
names{5 } = 'born 1980';
names{6 } = 'born 1981';
names{7 } = 'born 1982';
names{8 } = 'born 1983';
names{9 } = 'Family Income (10,000)';
nobsstr = cell(1,5);nobsfmt = cell(1,5);
for k=1:5
	[nobsstr{k},nobsfmt{k}] = commastring(Nmat(k));
end
fid = fopen(['demogByStartingTypeT',num2str(tau),'.tex'], 'w');
fprintf(fid, '\\begin{landscape}\n');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Background characteristics by college enrollment status: Baseline model}\n');
fprintf(fid, '\\label{tab:backgroundBaseline} \n');
fprintf(fid, '\\centering{}\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lccccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, ' & \\multicolumn{3}{c}{Starting College Type}   &            \\\\\n');
fprintf(fid, ' & Two-year  & Four-year Sci & Four-year Non-Sci   & No college & Total \\\\\n');
fprintf(fid, '\\cmidrule(r{.5em}){1-1}\\cmidrule(lr{.5em}){2-4}\\cmidrule(lr{.5em}){5-5}\\cmidrule(l{.5em}){6-6}\n');
for j=1:9
	fprintf(fid, names{j});
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',meanmat(j,1));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',meanmat(j,2));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',meanmat(j,3));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',meanmat(j,4));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',meanmat(j,5));
	fprintf(fid, ' \\\\\n');
	fprintf(fid, ' & ');
	fprintf(fid, '(');
	fprintf(fid,'%4.3f',sdmat(j,1));
	fprintf(fid, ')');
	fprintf(fid, ' & ');
	fprintf(fid, '(');
	fprintf(fid,'%4.3f',sdmat(j,2));
	fprintf(fid, ')');
	fprintf(fid, ' & ');
	fprintf(fid, '(');
	fprintf(fid,'%4.3f',sdmat(j,3));
	fprintf(fid, ')');
	fprintf(fid, ' & ');
	fprintf(fid, '(');
	fprintf(fid,'%4.3f',sdmat(j,4));
	fprintf(fid, ')');
	fprintf(fid, ' & ');
	fprintf(fid, '(');
	fprintf(fid,'%4.3f',sdmat(j,5));
	fprintf(fid, ')');
	fprintf(fid, ' \\\\\n');
end
fprintf(fid, '\\cmidrule(r{.5em}){1-1}\\cmidrule(lr{.5em}){2-4}\\cmidrule(lr{.5em}){5-5}\\cmidrule(l{.5em}){6-6}\n');
fprintf(fid, 'Total N');
fprintf(fid, ' & ');
fprintf(fid,nobsfmt{1},nobsstr{1});
fprintf(fid, ' & ');
fprintf(fid,nobsfmt{2},nobsstr{2});
fprintf(fid, ' & ');
fprintf(fid,nobsfmt{3},nobsstr{3});
fprintf(fid, ' & ');
fprintf(fid,nobsfmt{4},nobsstr{4});
fprintf(fid, ' & ');
fprintf(fid,nobsfmt{5},nobsstr{5});
fprintf(fid, ' \\\\\n');
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: This table reports summary statistics for the baseline simulation of the model. Standard deviations are listed directly below the mean (in parentheses) for each entry. Compare with Table \\ref{Tab_descriptives1}, which reports these figures in the estimation sample.\n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '\\end{table}\n');
fprintf(fid, '\\end{landscape}\n');
fclose(fid);
end


if tau==11
%---------------------------------------------------
% Wage decompositions
%---------------------------------------------------
% Method 1 but assuming all work full-time and not in school
cum_sch = (1-grad_4yr(:,tau)).*min(cum_2yr(:,tau)+cum_4yr(:,tau),4) + 4.*grad_4yr(:,tau);

xn1  = [ones(N,1) black hispanic Parent_college HS_grades born1980 born1981 born1982 born1983 age(:,tau)<=0 age(:,tau)==1 age(:,tau)==2 exper(:,tau) exper_white_collar(:,tau)];
xn2  = [cum_sch grad_4yr(:,tau) finalMajorSci.*grad_4yr(:,tau)];
xn3  = [year(:,tau)<=1999 year(:,tau)==2000 year(:,tau)==2001 year(:,tau)==2002 year(:,tau)==2003 year(:,tau)==2004 year(:,tau)==2005 year(:,tau)==2006 year(:,tau)==2007 year(:,tau)==2008 year(:,tau)==2009 year(:,tau)==2010 year(:,tau)==2011 year(:,tau)==2012 year(:,tau)==2013 year(:,tau)==2014];
xn4  = Ymat(:,tau)*0;
xn5  = [type==1 type==2 type==3 type==4 type==5 type==6 type==7 trueAbil(:,2)];

xn_all = [xn1 xn2 xn3 xn4 xn5];

xg1  = [ones(N,1) black hispanic Parent_college HS_grades born1980 born1981 born1982 born1983 age(:,tau)<=0 age(:,tau)==1 age(:,tau)==2 exper(:,tau) exper_white_collar(:,tau)];
xg2  = [cum_sch grad_4yr(:,tau) finalMajorSci.*grad_4yr(:,tau)];
xg3  = [year(:,tau)<=1999 year(:,tau)==2000 year(:,tau)==2001 year(:,tau)==2002 year(:,tau)==2003 year(:,tau)==2004 year(:,tau)==2005 year(:,tau)==2006 year(:,tau)==2007 year(:,tau)==2008 year(:,tau)==2009 year(:,tau)==2010 year(:,tau)==2011 year(:,tau)==2012 year(:,tau)==2013 year(:,tau)==2014];
xg4  = Ymat(:,tau)*0;
xg5  = [type==1 type==2 type==3 type==4 type==5 type==6 type==7 trueAbil(:,1)];

xg_all = [xg1 xg2 xg3 xg4 xg5];

bstartn_all = [learnparms.bstartn; 1];
bstartg_all = [learnparms.bstartg; 1];

mean_exper_g_b = mean(exper(grad_4yr(:,tau)==1,tau));
mean_exper_white_collar_g_b = mean(exper_white_collar(grad_4yr(:,tau)==1,tau));
mean_exper_ng_b = mean(exper(grad_4yr(:,tau)==0,tau));
mean_exper_white_collar_ng_b = mean(exper_white_collar(grad_4yr(:,tau)==0,tau));
sum_stats_gradsM1=mean(xg_all(grad_4yr(:,tau)==1,:));
sum_stats_no_gradsM1=mean(xn_all(grad_4yr(:,tau)==0,:));


% Expected log wage in the WC sector conditional on college grad
E_wage_wc_g_b=mean(xg_all(grad_4yr(:,tau)==1,:)*bstartg_all);  
% Expected log wage in the BC sector conditional on high school grad
E_wage_bc_ng_b=mean(xn_all(grad_4yr(:,tau)==0,:)*bstartn_all);
% Expected log wage in the WC sector conditional on high school grad
E_wage_wc_ng_b=mean(xg_all(grad_4yr(:,tau)==0,:)*bstartg_all);
% Expected log wage in the BC sector conditional on college grad
E_wage_bc_g_b=mean(xn_all(grad_4yr(:,tau)==1,:)*bstartn_all);
% Expected log wage in the BC sector conditional on college grad
E_wage_all_b=mean(cat(1,xg_all(grad_4yr(:,tau)==1,:)*bstartg_all,xg_all(grad_4yr(:,tau)==0,:)*bstartg_all,xn_all(grad_4yr(:,tau)==1,:)*bstartn_all,xn_all(grad_4yr(:,tau)==0,:)*bstartn_all));

% Pr WC conditional on college grad
P_wc_g_b = sum(ismember(Ymat(grad_4yr==1),workWCanyOpts))./sum(ismember(Ymat(grad_4yr==1),[workWCanyOpts workBCanyOpts])); 
% Pr BC conditional on college grad
P_bc_g_b = sum(ismember(Ymat(grad_4yr==1),workBCanyOpts))./sum(ismember(Ymat(grad_4yr==1),[workWCanyOpts workBCanyOpts]));  
% Pr WC conditional on high school grad
P_wc_ng_b = sum(ismember(Ymat(grad_4yr==0),workWCanyOpts))./sum(ismember(Ymat(grad_4yr==0),[workWCanyOpts workBCanyOpts]));  
% Pr BC conditional on high school grad
P_bc_ng_b = sum(ismember(Ymat(grad_4yr==0),workBCanyOpts))./sum(ismember(Ymat(grad_4yr==0),[workWCanyOpts workBCanyOpts])); 

% overall gap
E_wage_overall_b = P_wc_g_b*E_wage_wc_g_b + P_bc_g_b*E_wage_bc_g_b - P_wc_ng_b*E_wage_wc_ng_b - P_bc_ng_b*E_wage_bc_ng_b;

dlmwrite('Ewage.csv',['Basic']);
dlmwrite('Ewage.csv',[E_wage_wc_g_b;E_wage_wc_ng_b;E_wage_bc_g_b;E_wage_bc_ng_b;P_wc_g_b;P_bc_g_b;P_wc_ng_b;P_bc_ng_b;E_wage_overall_b],'-append');
dlmwrite('Ewage.csv',['Alternative'],'-append');

%Calculation of variance
Prob_CG_b=mean(grad_4yr(:,tau));

%xn_all(:,end) = trueAbil(:,2);
%xg_all(:,end) = trueAbil(:,1);

E_W_b=Prob_CG_b*E_wage_wc_g_b+(1-Prob_CG_b)*E_wage_bc_ng_b;
E_W_b_2  = (E_W_b).^2;
E_W_g_b_2  = (E_wage_wc_g_b).^2;
E_W_ng_b_2  = (E_wage_bc_ng_b).^2;

Xn = cat(2,mean(xn1(grad_4yr(:,tau)==0,1:end-2)),mean(xg1(grad_4yr(:,tau)==1,end-1:end)),mean(xg2(grad_4yr(:,tau)==1,:)),zeros(1,tau-7),1,zeros(1,16-(tau-7)),mean(xn5(grad_4yr(:,tau)==0,:)));
size(bstartg_all)
size(Xn)
Bg = bstartg_all;
Xn
XnBg = Xn*Bg;

Xg = cat(2,mean(xg1(grad_4yr(:,tau)==1,1:end-2)),mean(xn1(grad_4yr(:,tau)==0,end)),mean(xn2(grad_4yr(:,tau)==0,:)),zeros(1,tau-2),1,zeros(1,17-(tau-2)),mean(xg5(grad_4yr(:,tau)==1,:)));
Bn = bstartn_all;
Xg
XgBn = Xg*Bn;

EPSILONg = sqrt(sigNormed(1))*randn(N,1);
EPSILONn = sqrt(sigNormed(3))*randn(N,1);
E_W2_g_b = mean((xg_all(grad_4yr(:,tau)==1,:)*bstartg_all+EPSILONg(grad_4yr(:,tau)==1,:)).^2);
E_W2_ng_b = mean((xn_all(grad_4yr(:,tau)==0,:)*bstartn_all+EPSILONn(grad_4yr(:,tau)==0,:)).^2);
E_W2_b = Prob_CG_b*E_W2_g_b+(1-Prob_CG_b)*E_W2_ng_b;

save(['wage_decomp_M1_t',num2str(tau),'_b'],'xn_all','xg_all','bstartn_all','bstartg_all','grad_4yr','tau','EPSILONg','EPSILONn','Ymat');

%% Method 2
%
%exper_CC=exper(:,tau);
%exper_CC=mean(exper_CC(everCC==1));
%
%exper_white_collar_CC=exper_white_collar(:,tau);
%exper_white_collar_CC=mean(exper_white_collar_CC(everCC==1));
%
%exper_NC=exper(:,tau); 
%exper_NC=mean(exper_NC(((cum_2yr(:,tau)+cum_4yr(:,tau))==0) & Ymat(:,tau)>9));
%
%finalMajorSci_CC=mean(finalMajorSci(everCC==1));
%
%
%xn1  = [ones(N,1) black hispanic SATmath SATverb Parent_college HS_grades age(:,tau) exper_NC*ones(N,1)];
%xn2  = [(cum_2yr(:,tau)+cum_4yr(:,tau))==100 (cum_2yr(:,tau)+cum_4yr(:,tau))==100 (cum_2yr(:,tau)+cum_4yr(:,tau))==100 (cum_2yr(:,tau)+cum_4yr(:,tau))>=100];
%xn3  = [year(:,tau)<1999 year(:,tau)==1999 year(:,tau)==2000 year(:,tau)==2001 year(:,tau)==2002 year(:,tau)==2003 year(:,tau)==2004 year(:,tau)==2005 year(:,tau)==2006 year(:,tau)==2007 year(:,tau)==2008 year(:,tau)==2009 year(:,tau)==2010];
%xn4  = [(Ymat(:,tau)==2)*0+(Ymat(:,tau)==5)*0+(Ymat(:,tau)==8)*0+(Ymat(:,tau)==10)*0 (Ymat(:,tau)==2)*0 (Ymat(:,tau)==5)*0+(Ymat(:,tau)==8)*0 (Ymat(:,tau)==1)*0 (Ymat(:,tau)==4)*0+(Ymat(:,tau)==7)*0];
%xn5  = [type==1 trueAbil(:,2)];
%
%xn_all = [xn1 xn2 xn3 xn4 xn5];
%
%xg1  = [ones(N,1) black hispanic SATmath SATverb Parent_college HS_grades age(:,tau) exper_CC*ones(N,1) exper_white_collar_CC*ones(N,1)]; 
%xg2  = [cum_grad_school_CC_1*ones(N,1) cum_grad_school_CC_2*ones(N,1) cum_grad_school_CC_3*ones(N,1) cum_grad_school_CC_4*ones(N,1) finalMajorSci_CC*ones(N,1)]; 
%xg3  = [year(:,tau)<2004 year(:,tau)==2004 year(:,tau)==2005 year(:,tau)==2006 year(:,tau)==2007 year(:,tau)==2008 year(:,tau)==2009 year(:,tau)==2010]; 
%xg4  = [(Ymat(:,tau)==10)*0+(Ymat(:,tau)==14)*0 (Ymat(:,tau)==14)*0 (Ymat(:,tau)==13)*0];
%xg5  = [type==1 trueAbil(:,1)];
%
%xg_all = [xg1 xg2 xg3 xg4 xg5];
%
%
%sum_stats_gradsM2=mean(xg_all(grad_4yr(:,tau)==1,:));
%sum_stats_no_gradsM2=mean(xn_all(grad_4yr(:,tau)==0,:));
%
%% Expected log wage in the skilled sector conditional on college grad
%Alt_E_wage_wc_g_b=mean(xg_all(grad_4yr(:,tau)==1,:)*bstartg_all);
%% Expected log wage in the unskilled sector conditional on high school grad
%Alt_E_wage_bc_ng_b=mean(xn_all(grad_4yr(:,tau)==0,:)*bstartn_all);
%% Expected log wage in the skilled sector conditional on high school grad
%Alt_E_wage_wc_ng_b=mean(xg_all(grad_4yr(:,tau)==0,:)*bstartg_all);
%% Expected log wage in the unskilled sector conditional on college grad
%Alt_E_wage_bc_g_b=mean(xn_all(grad_4yr(:,tau)==1,:)*bstartn_all);
%dlmwrite('Ewage.csv',[Alt_E_wage_wc_g_b;Alt_E_wage_bc_ng_b;Alt_E_wage_wc_ng_b;Alt_E_wage_bc_g_b],'-append');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Point C
%
%Prob_CG_b=mean(grad_4yr(:,tau));
%
%E_Alt_W_b=Prob_CG_b*Alt_E_wage_wc_g_b+(1-Prob_CG_b)*Alt_E_wage_bc_ng_b;
%
%%%%%%%%%%%% Calculating components of the variance
%
%%xn_all(:,end) = trueAbil(:,2);
%%xg_all(:,end) = trueAbil(:,1);
%
%E_Alt_W_b_2 =(E_Alt_W_b).^2;
%
%Alt_E_W2_g_b = mean((xg_all(grad_4yr(:,tau)==1,:)*bstartg_all+EPSILONg(grad_4yr(:,tau)==1,:)).^2);
%Alt_E_W2_ng_b = mean((xn_all(grad_4yr(:,tau)==0,:)*bstartn_all+EPSILONn(grad_4yr(:,tau)==0,:)).^2);
%Alt_E_W2_b = Prob_CG_b*Alt_E_W2_g_b+(1-Prob_CG_b)*Alt_E_W2_ng_b;
%
%save(['wage_decomp_M2_t',num2str(tau),'_b'],'xn_all','xg_all','bstartn_all','bstartg_all','grad_4yr','tau','EPSILONg','EPSILONn','Ymat');

Method_1=[E_wage_wc_g_b E_wage_bc_ng_b E_wage_wc_ng_b E_wage_bc_g_b Prob_CG_b E_W2_b E_W_b_2]';
%Method_2=[Alt_E_wage_wc_g_b Alt_E_wage_bc_ng_b Alt_E_wage_wc_ng_b Alt_E_wage_bc_g_b Prob_CG_b Alt_E_W2_b E_Alt_W_b_2]';

wageDecompTable = nan(14,1);
wageDecompTable( 1) = E_wage_wc_g_b;
wageDecompTable( 2) = E_wage_wc_ng_b;
wageDecompTable( 3) = E_wage_bc_g_b;
wageDecompTable( 4) = E_wage_bc_ng_b;
wageDecompTable( 5) = E_wage_wc_g_b-E_wage_wc_ng_b;
wageDecompTable( 6) = E_wage_bc_g_b-E_wage_bc_ng_b;
wageDecompTable( 7) = E_wage_all_b;
wageDecompTable( 8) = XnBg;
wageDecompTable( 9) = E_wage_wc_g_b-XnBg;
wageDecompTable(10) = XgBn;
wageDecompTable(11) = XgBn-E_wage_bc_ng_b;
wageDecompTable(12) = sqrt(E_W2_b-E_W_b_2);
wageDecompTable(13) = sqrt(E_W2_g_b-E_W_g_b_2);
wageDecompTable(14) = sqrt(E_W2_ng_b-E_W_ng_b_2);

wageDecompTable

save(['wageDecompsBaselineT',num2str(tau)],'wageDecompTable','tau','mean_exper*','*W2*','E_W_b_2','E_wage_wc_g_b','E_wage_bc_ng_b','E_wage_wc_ng_b','E_wage_bc_g_b'); %,'Alt_E_wage_wc_g_b','Alt_E_wage_bc_ng_b','Alt_E_wage_wc_ng_b','Alt_E_wage_bc_g_b');


tabulate(CCDOSO(CCDOSO<7));
output = tabulate(CCDOSO);
output = output(:,end);
tabulate(CCDOSOdetail);
output2 = tabulate(CCDOSOdetail);
output2 = output2(:,end);

end

if tau==10
% Table of sorting based on work experience profile in first 10 years
%---------------------------------------------------
% Work experience sorting table
%---------------------------------------------------
flagCoarse(:,1 ) = numWCWork>0 & numBCWork==0;
flagCoarse(:,2 ) = numBCWork>0 & numWCWork==0; 
flagCoarse(:,3 ) = numWCWork>0 & numBCWork>0 & numWCWork>=numBCWork; 
flagCoarse(:,4 ) = numWCWork>0 & numBCWork>0 & numWCWork<numBCWork; 
flagCoarse(:,5 ) = numWCWork==0 & numBCWork==0;  

% generate posterior abilities in last period
posterEnd     = nan(N,J);
postVeryEnd   = nan(N,J);
for i=1:length(flagCoarse)
	posterEnd(i,:)   = squeeze(posteriorAbilMat(i,:,tau));
	postVeryEnd(i,:) = squeeze(posteriorVarDiagMat(i,:,tau));
end

% summary stats
numgroups = size(flagCoarse,2)
posteriorStats = nan(5,5,numgroups);
cumSchoolStats = nan(3,5,numgroups);
for j=1:numgroups
    posteriorStats(:,:,j) = summarize(posterEnd(flagCoarse(:,j),:));
end
% rearrange SUMMARIZE output to match with what we want to report in the spreadsheet
posteriorAns = posteriorStats(:,[2 1],:); %switch order of mean and frequency
posteriorAns = reshape(posteriorAns,[10 numgroups])';
posteriorAns = posteriorAns(:,1:6);
cumSchoolAns = cumSchoolStats(:,2,:); %only grab mean
cumSchoolAns = reshape(cumSchoolAns,[3 numgroups])';
posteriorAns = cat(2,posteriorAns,cumSchoolAns);
%dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['posteriorabil']);
%dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[nan(1,size(posteriorAns,2));posteriorAns(1:2,:);nan(1,size(posteriorAns,2));posteriorAns(3:4,:);nan(1,size(posteriorAns,2));posteriorAns(5:9,:);nan(1,size(posteriorAns,2));posteriorAns(10:14,:);nan(1,size(posteriorAns,2));posteriorAns(15:end-1,:);nan(1,size(posteriorAns,2));posteriorAns(end,:);nan(1,size(posteriorAns,2))],'-append');
%dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['divider'],'-append');

%trueStats = nan(5,5,numgroups);
%for j=1:numgroups
	%trueStats(:,:,j) = summarize(squeeze(trueAbil(flagCoarse(:,j),:)));
%end
%trueAns = trueStats(:,[2 1],:);
%trueAns = reshape(trueAns,[10 numgroups])';
%trueAns = trueAns(:,1:6);
%trueAns = cat(2,trueAns,cumSchoolAns);
%dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['trueabil'],'-append');
%dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[nan(1,size(trueAns,2));trueAns(1:2,:);nan(1,size(trueAns,2));trueAns(3:4,:);nan(1,size(trueAns,2));trueAns(5:9,:);nan(1,size(trueAns,2));trueAns(10:14,:);nan(1,size(trueAns,2));trueAns(15:end-1,:);nan(1,size(trueAns,2));trueAns(end,:);nan(1,size(trueAns,2))],'-append');
%dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['divider'],'-append');

postVarStats = nan(5,5,numgroups);
for j=1:numgroups
    %if j<=21
        postVarStats(:,:,j) = summarize(postVeryEnd(flagCoarse(:,j),:));
    %else
    %    postVarStats(:,:,j) = summarize(postVeryEnd(flagCoarse(:,j),:));
    %end
end
postVarAns = postVarStats(:,[2 1],:);
postVarAns = reshape(postVarAns,[10 numgroups])';
postVarAns = postVarAns(:,1:6);
postVarAns = cat(2,postVarAns,cumSchoolAns);
%dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['posteriorvar'],'-append');
%dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[nan(1,size(postVarAns,2));postVarAns(1:2,:);nan(1,size(postVarAns,2));postVarAns(3:4,:);nan(1,size(postVarAns,2));postVarAns(5:9,:);nan(1,size(postVarAns,2));postVarAns(10:14,:);nan(1,size(postVarAns,2));postVarAns(15:end-1,:);nan(1,size(postVarAns,2));postVarAns(end,:);nan(1,size(postVarAns,2))],'-append');
%dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['divider'],'-append');


% LaTeX export of posterior abilities by choice path:
header = cell(5,1);
%header{1 } = '\\midrule\n\\multicolumn{7}{l}{\\emph{Continuous enrollment, graduate in science with $x$ years of in-school work experience}}\\\\\n';
%header{5 } = '\\midrule\n\\multicolumn{7}{l}{\\emph{Continuous enrollment, graduate in non-science with $x$ years of in-school work experience}}\\\\\n';
%header{9 } = '\\midrule\n\\multicolumn{7}{l}{\\emph{Stop out (SO)}}\\\\\n';
%header{14} = '\\midrule\n\\multicolumn{7}{l}{\\emph{Drop out (DO) after $x$ years of school}}\\\\\n';
%header{21} = '\\midrule\n\\multicolumn{7}{l}{\\emph{Never attended college}}\\\\\n';
%header{22} = '\\midrule\n\\multicolumn{7}{l}{\\emph{Initial employment sector after finishing school}}\\\\\n';
names = cell(5,1);
names{1 } = 'White collar only & ';
names{2 } = 'Blue collar only & ';
names{3 } = 'Mixture, white collar modal & ';
names{4 } = 'Mixture, blue collar modal & ';
names{5 } = 'Never worked     & ';
nobsstr = cell(5);nobsfmt = cell(5);
for k=1:5
	[nobsstr{k},nobsfmt{k}] = commastring(posteriorAns(k,6));
    share(k,1) = posteriorAns(k,6)./sum(posteriorAns(1:5,6));
end
fid = fopen(['posteriorAbilWorkPathNormedT',num2str(tau),'.tex'], 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Average end-of-panel posterior abilities for different work paths}\n');
fprintf(fid, '\\label{tab:PosterAbilityWorkPath} \n');
fprintf(fid, '\\centering{}\n');
fprintf(fid, '\\resizebox{.95\\textwidth}{!}{\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lcccccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Choice Path  & White Collar  & Blue Collar  & Science  & Non-Science  & 2-year  & Share(\\%%)\\\\\n');
fprintf(fid, '\\midrule\n');
for j=[1:5]
	%if ismember(j,[1 5 9 14 21 22])
		%fprintf(fid, header{j});
	%end
	fprintf(fid, names{j});
	fprintf(fid,'%4.3f',posteriorAns(j,1));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,2));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,3));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,4));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,5));
	fprintf(fid, ' & ');
	fprintf(fid,'%3.1f',100*share(j));
	fprintf(fid, ' \\\\\n');
end
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid,['\\footnotesize Notes: Abilities are reported in standard deviation units. This table is constructed using 100 simulations of the structural model for each individual included in the estimation.\n']);
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);


% Completion status variable
% 1.  continuous complete & sci major & ever worked in school
% 2.  continuous complete & hum major & ever worked in school
% 3.  continuous complete & sci major & never worked in school
% 4.  continuous complete & hum major & never worked in school
% 5.  stopout and graduate
% 6.  stopout and dropout
% 7.  dropout
% 8.  CC truncated [drop these]
% 9.  SO truncated [drop these]
% 10. never went to college

%CCDOSO        = 1*(everCC & everGrad4yr) + 2*(everSO & everGrad4yr) + 3*(everSO & ~everGrad4yr & ~truncated) + 4*(everDO) + 5*(everCC & truncated) + 6*(everSO & ~everGrad4yr & truncated) + 7*neverCollege;

% Add more subpaths to the choice path sorting --- 
% delayed entry; DO after 1 year, 2 years, etc.; 
% SO grad sci vs. SO grad hum;
% CC work (1 yr exp, 2yrs exp, etc.)

disp('tabulate CCDOSO');
tabulate(CCDOSO1)
disp('tabulate CCDOSOdetail1');
tabulate(CCDOSOdetail1)
%---------------------------------------------------
% Aggregated sorting tables
%---------------------------------------------------
flagCoarse(:,1 ) = CCDOSO==1 &  finalMajorSci & ~everWorkSch;
flagCoarse(:,2 ) = CCDOSO==1 &  finalMajorSci &  everWorkWCsch & ~everWorkBCsch;
flagCoarse(:,3 ) = CCDOSO==1 &  finalMajorSci &  everWorkBCsch & ~everWorkWCsch;
flagCoarse(:,4 ) = CCDOSO==1 &  finalMajorSci &  everWorkSch & ~(everWorkWCsch & ~everWorkBCsch) & ~(everWorkBCsch & ~everWorkWCsch);
flagCoarse(:,5 ) = CCDOSO==1 & ~finalMajorSci & ~everWorkSch;
flagCoarse(:,6 ) = CCDOSO==1 & ~finalMajorSci &  everWorkWCsch & ~everWorkBCsch;
flagCoarse(:,7 ) = CCDOSO==1 & ~finalMajorSci &  everWorkBCsch & ~everWorkWCsch;
flagCoarse(:,8 ) = CCDOSO==1 & ~finalMajorSci &  everWorkSch & ~(everWorkWCsch & ~everWorkBCsch) & ~(everWorkBCsch & ~everWorkWCsch); 
flagCoarse(:,9 ) = CCDOSO==2 &  finalMajorSci;
flagCoarse(:,10) = CCDOSO==2 & ~finalMajorSci;
flagCoarse(:,11) = CCDOSO==3 &  start2yr     ;
flagCoarse(:,12) = CCDOSO==3 &  startSci     ;
flagCoarse(:,13) = CCDOSO==3 &  startHum     ;
flagCoarse(:,14) = CCDOSO==4 &  numSchool==1;
flagCoarse(:,15) = CCDOSO==4 &  numSchool==2;
flagCoarse(:,16) = CCDOSO==4 &  numSchool==3;
flagCoarse(:,17) = CCDOSO==4 &  numSchool==4;
flagCoarse(:,18) = CCDOSO==4 &  numSchool>=5;
flagCoarse(:,19) = CCDOSO==5;
flagCoarse(:,20) = CCDOSO==6;
flagCoarse(:,21) = neverCollege;
flagCoarse(:,22) = CCDOSO<=2 & startBC;
flagCoarse(:,23) = CCDOSO<=2 & startWC;
flagCoarse(:,24) = CCDOSO<=2 & startNW;
flagCoarse(:,25) = CCDOSO>=3 & startBC;
flagCoarse(:,26) = CCDOSO>=3 & startWC;
flagCoarse(:,27) = CCDOSO>=3 & stillInSch; 
flagCoarse(:,28) = CCDOSO>=3 & startNW;       

% generate "last period" for each individual
lastPeriod = nan(N,1);
lastPeriod(~neverCollege) = lastColPer(~neverCollege);
lastPeriod(neverCollege) = tau;

% generate posterior abilities in last period
poster        = nan(N,J);
postVery      = nan(N,J);
posterEnd     = nan(N,J);
postVeryEnd   = nan(N,J);
num2yrI       = zeros(N,1);
numSciI       = zeros(N,1);
numHumI       = zeros(N,1);
numWorkFTSchI = zeros(N,1);
numWorkPTSchI = zeros(N,1);
numWCWorkI    = zeros(N,1);
numBCWorkI    = zeros(N,1);
for i=1:length(flagCoarse)
	poster(i,:)      = squeeze(posteriorAbilMat(i,:,lastPeriod(i)));
	postVery(i,:)    = squeeze(posteriorVarDiagMat(i,:,lastPeriod(i)));
	posterEnd(i,:)   = squeeze(posteriorAbilMat(i,:,tau));
	postVeryEnd(i,:) = squeeze(posteriorVarDiagMat(i,:,tau));
	% num2yrI       = sum(ismember(Ymat(i,1:lastPeriod(i)),[1 2 3 4 5]),2);
	% numSciI       = sum(ismember(Ymat(i,1:lastPeriod(i)),[6 7 8 9 10]),2);
	% numHumI       = sum(ismember(Ymat(i,1:lastPeriod(i)),[11 12 13 14 15]),2);
	% numWorkFTSchI = sum(ismember(Ymat(i,1:lastPeriod(i)),[1 4 7]),2);
	% numWorkPTSchI = sum(ismember(Ymat(i,1:lastPeriod(i)),[2 5 8]),2);
	% numWCWorkI    = sum(ismember(Ymat(i,1:lastPeriod(i)),workOpts) & grad_4yr==0,2);
	% numBCWorkI    = sum(ismember(Ymat(i,1:lastPeriod(i)),[10 11 13 14]) & grad_4yr==1,2);
end

% summary stats
numgroups = size(flagCoarse,2)
posteriorStats = nan(5,5,numgroups);
cumSchoolStats = nan(3,5,numgroups);
for j=1:numgroups
    %if j<=21
        posteriorStats(:,:,j) = summarize(poster(flagCoarse(:,j),:));
        cumSchoolStats(:,:,j) = summarize([num2yr(flagCoarse(:,j),1) numHum(flagCoarse(:,j),1) numSci(flagCoarse(:,j),1)]);
    %else
    %    posteriorStats(:,:,j) = summarize(posterEnd(flagCoarse(:,j),:));
    %    cumSchoolStats(:,:,j) = summarize([num2yr(flagCoarse(:,j),1) numHum(flagCoarse(:,j),1) numSci(flagCoarse(:,j),1)]);
    %end
end
% rearrange SUMMARIZE output to match with what we want to report in the spreadsheet
posteriorAns = posteriorStats(:,[2 1],:); %switch order of mean and frequency
posteriorAns = reshape(posteriorAns,[10 numgroups])';
posteriorAns = posteriorAns(:,1:6);
cumSchoolAns = cumSchoolStats(:,2,:); %only grab mean
cumSchoolAns = reshape(cumSchoolAns,[3 numgroups])';
posteriorAns = cat(2,posteriorAns,cumSchoolAns);
dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['posteriorabil']);
dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[nan(1,size(posteriorAns,2));posteriorAns(1:2,:);nan(1,size(posteriorAns,2));posteriorAns(3:4,:);nan(1,size(posteriorAns,2));posteriorAns(5:9,:);nan(1,size(posteriorAns,2));posteriorAns(10:14,:);nan(1,size(posteriorAns,2));posteriorAns(15:end-1,:);nan(1,size(posteriorAns,2));posteriorAns(end,:);nan(1,size(posteriorAns,2))],'-append');
dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['divider'],'-append');

trueStats = nan(5,5,numgroups);
for j=1:numgroups
	trueStats(:,:,j) = summarize(squeeze(trueAbil(flagCoarse(:,j),:)));
end
trueAns = trueStats(:,[2 1],:);
trueAns = reshape(trueAns,[10 numgroups])';
trueAns = trueAns(:,1:6);
trueAns = cat(2,trueAns,cumSchoolAns);
dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['trueabil'],'-append');
dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[nan(1,size(trueAns,2));trueAns(1:2,:);nan(1,size(trueAns,2));trueAns(3:4,:);nan(1,size(trueAns,2));trueAns(5:9,:);nan(1,size(trueAns,2));trueAns(10:14,:);nan(1,size(trueAns,2));trueAns(15:end-1,:);nan(1,size(trueAns,2));trueAns(end,:);nan(1,size(trueAns,2))],'-append');
dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['divider'],'-append');

postVarStats = nan(5,5,numgroups);
for j=1:numgroups
    %if j<=21
        postVarStats(:,:,j) = summarize(postVery(flagCoarse(:,j),:));
    %else
    %    postVarStats(:,:,j) = summarize(postVeryEnd(flagCoarse(:,j),:));
    %end
end
postVarAns = postVarStats(:,[2 1],:);
postVarAns = reshape(postVarAns,[10 numgroups])';
postVarAns = postVarAns(:,1:6);
postVarAns = cat(2,postVarAns,cumSchoolAns);
dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['posteriorvar'],'-append');
dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[nan(1,size(postVarAns,2));postVarAns(1:2,:);nan(1,size(postVarAns,2));postVarAns(3:4,:);nan(1,size(postVarAns,2));postVarAns(5:9,:);nan(1,size(postVarAns,2));postVarAns(10:14,:);nan(1,size(postVarAns,2));postVarAns(15:end-1,:);nan(1,size(postVarAns,2));postVarAns(end,:);nan(1,size(postVarAns,2))],'-append');
dlmwrite(['CoarseSimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['divider'],'-append');


% LaTeX export of posterior abilities by choice path:
header = cell(21,1);
header{1 } = '\\midrule\n\\multicolumn{7}{l}{\\emph{Continuous enrollment, graduate in science with $x$ years of in-school work experience}}\\\\\n';
header{5 } = '\\midrule\n\\multicolumn{7}{l}{\\emph{Continuous enrollment, graduate in non-science with $x$ years of in-school work experience}}\\\\\n';
header{9 } = '\\midrule\n\\multicolumn{7}{l}{\\emph{Stop out (SO)}}\\\\\n';
header{14} = '\\midrule\n\\multicolumn{7}{l}{\\emph{Drop out (DO) after $x$ years of school}}\\\\\n';
header{21} = '\\midrule\n\\multicolumn{7}{l}{\\emph{Never attended college}}\\\\\n';
header{22} = '\\midrule\n\\multicolumn{7}{l}{\\emph{Initial employment sector after finishing school}}\\\\\n';
names = cell(21,1);
names{1 } = '$x=0$     & ';
names{2 } = '$x>0$, white collar only & ';
names{3 } = '$x>0$, blue collar only & ';
names{4 } = '$x>0$, mixture & ';
names{5 } = '$x=0$     & ';
names{6 } = '$x>0$, white collar only & ';
names{7 } = '$x>0$, blue collar only & ';
names{8 } = '$x>0$, mixture & ';
names{9 } = 'SO, graduate in science          & ';
names{10} = 'SO, graduate in non-science       & ';
names{11} = 'SO then DO, start in 2yr         & ';
names{12} = 'SO then DO, start in science     & ';
names{13} = 'SO then DO, start in non-science  & ';
names{14} = '$x=1$     & ';
names{15} = '$x=2$     & ';
names{16} = '$x=3$     & ';
names{17} = '$x=4$     & ';
names{18} = '$x\\geq5$  & ';
names{21} = 'Never attend college  & ';
names{22} = 'Start in blue collar, college graduate & ';
names{23} = 'Start in white collar, college graduate & ';
names{24} = 'LF non-participant, college graduate & ';
names{25} = 'Start in blue collar, HS graduate & ';
names{26} = 'Start in white collar, HS graduate & ';
names{27} = 'Still in college, HS graduate & ';
names{28} = 'LF non-participant, HS graduate & ';
nobsstr = cell(28);nobsfmt = cell(28);
for k=1:28
	[nobsstr{k},nobsfmt{k}] = commastring(posteriorAns(k,6));
    if k<22
        share(k,1) = posteriorAns(k,6)./sum(posteriorAns(1:21,6));
    else
        share(k,1) = posteriorAns(k,6)./sum(posteriorAns(22:28,6));
    end
end
fid = fopen(['posteriorAbilNormedT',num2str(tau),'.tex'], 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Average posterior abilities after last year of college for different choice paths}\n');
fprintf(fid, '\\label{tab:Posterability} \n');
fprintf(fid, '\\centering{}\n');
fprintf(fid, '\\resizebox{.95\\textwidth}{!}{\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lcccccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Choice Path  & White Collar  & Blue Collar  & Science  & Non-Science  & 2-year  & Share(\\%%)\\\\\n');
for j=[1:18 21:28]
	if ismember(j,[1 5 9 14 21 22])
		fprintf(fid, header{j});
	end
	fprintf(fid, names{j});
	fprintf(fid,'%4.3f',posteriorAns(j,1));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,2));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,3));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,4));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,5));
	fprintf(fid, ' & ');
	fprintf(fid,'%3.1f',100*share(j));
	fprintf(fid, ' \\\\\n');
end
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid,['\\footnotesize Notes: Abilities are reported in standard deviation units. This table is constructed using 100 simulations of the structural model for each individual included in the estimation. For those who never attended college, we use the posterior in the ',num2str(tau),'th period.\n']);
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);


% LaTeX export of posterior variances by choice path:
header = cell(21,1);
header{1 } = '\\midrule\n\\multicolumn{7}{l}{\\emph{Continuous enrollment, graduate in science with $x$ years of in-school work experience}}\\\\\n';
header{5 } = '\\midrule\n\\multicolumn{7}{l}{\\emph{Continuous enrollment, graduate in non-science with $x$ years of in-school work experience}}\\\\\n';
header{9 } = '\\midrule\n\\multicolumn{7}{l}{\\emph{Stop out (SO)}}\\\\\n';
header{14} = '\\midrule\n\\multicolumn{7}{l}{\\emph{Drop out (DO) after $x$ years of school}}\\\\\n';
header{21} = '\\midrule\n\\multicolumn{7}{l}{\\emph{Never attended college}}\\\\\n';
header{22} = '\\midrule\n\\multicolumn{7}{l}{\\emph{Initial employment sector after finishing school}}\\\\\n';
nobsstr = cell(28);nobsfmt = cell(28);
for k=1:28
	[nobsstr{k},nobsfmt{k}] = commastring(postVarAns(k,6));
end
fid = fopen(['posteriorVarT',num2str(tau),'.tex'], 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Average posterior variance after last year of college for different choice paths}\n');
fprintf(fid, '\\label{tab:Postervar} \n');
fprintf(fid, '\\centering{}\n');
fprintf(fid, '\\resizebox{.95\\textwidth}{!}{\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lcccccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Choice Path  & White Collar  & Blue Collar  & Science  & Non-Science  & 2-year  & Share(\\%%)\\\\\n');
for j=[1:18 21:28]
	if ismember(j,[1 5 9 14 21 22])
		fprintf(fid, header{j});
	end
	fprintf(fid, names{j});
	fprintf(fid,'%4.3f',postVarAns(j,1));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',postVarAns(j,2));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',postVarAns(j,3));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',postVarAns(j,4));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',postVarAns(j,5));
	fprintf(fid, ' & ');
	fprintf(fid,'%3.1f',100*share(j));
	fprintf(fid, ' \\\\\n');
end
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Time 0 population variance');
fprintf(fid, ' & ');
fprintf(fid,'%4.3f',Delta(1,1));
fprintf(fid, ' & ');
fprintf(fid,'%4.3f',Delta(2,2));
fprintf(fid, ' & ');
fprintf(fid,'%4.3f',Delta(3,3));
fprintf(fid, ' & ');
fprintf(fid,'%4.3f',Delta(4,4));
fprintf(fid, ' & ');
fprintf(fid,'%4.3f',Delta(5,5));
fprintf(fid, ' \\\\\n');
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid,['\\footnotesize Notes: This table is constructed using 100 simulations of the structural model for each individual included in the estimation. For those who never attended college, we use the posterior in the ',num2str(tau),'th period.\n']);
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);

% LaTeX export of true abilities by choice path:
header = cell(21,1);
header{1 } = '\\midrule\n\\multicolumn{7}{l}{\\emph{Continuous enrollment, graduate in science with $x$ years of in-school work experience}}\\\\\n';
header{5 } = '\\midrule\n\\multicolumn{7}{l}{\\emph{Continuous enrollment, graduate in non-science with $x$ years of in-school work experience}}\\\\\n';
header{9 } = '\\midrule\n\\multicolumn{7}{l}{\\emph{Stop out (SO)}}\\\\\n';
header{14} = '\\midrule\n\\multicolumn{7}{l}{\\emph{Drop out (DO) after $x$ years of school}}\\\\\n';
header{21} = '\\midrule\n\\multicolumn{7}{l}{\\emph{Never attended college}}\\\\\n';
header{22} = '\\midrule\n\\multicolumn{7}{l}{\\emph{Initial employment sector after finishing school}}\\\\\n';
nobsstr = cell(28);nobsfmt = cell(28);
for k=1:28
	[nobsstr{k},nobsfmt{k}] = commastring(trueAns(k,6));
end
fid = fopen(['trueAbilNormedT',num2str(tau),'.tex'], 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Average true ability for different choice paths in baseline model}\n');
fprintf(fid, '\\label{tab:trueAbility} \n');
fprintf(fid, '\\centering{}\n');
fprintf(fid, '\\resizebox{.95\\textwidth}{!}{\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lcccccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Choice Path  & White Collar  & Blue Collar  & Science  & Non-Science  & 2-year  & Share(\\%%)\\\\\n');
for j=[1:18 21:28]
	if ismember(j,[1 5 9 14 21 22])
		fprintf(fid, header{j});
	end
	fprintf(fid, names{j});
	fprintf(fid,'%4.3f',trueAns(j,1));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',trueAns(j,2));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',trueAns(j,3));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',trueAns(j,4));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',trueAns(j,5));
	fprintf(fid, ' & ');
	fprintf(fid,'%3.1f',100*share(j));
	fprintf(fid, ' \\\\\n');
end
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Abilities are reported in standard deviation units. This table is constructed using 100 simulations of the structural model for each individual included in the estimation.\n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);







%---------------------------------------------------
% Labor market sorting tables
%---------------------------------------------------
samp1  = everSO & ismember(Ymat(:,1),schOpts) & ismember(Ymat(:,2),nonSchOpts) & ismember(Ymat(:,3),nonSchOpts);
samp2  = everSO & ismember(Ymat(:,1),schOpts) & ismember(Ymat(:,2),nonSchOpts) & ismember(Ymat(:,3),schOpts);
% samp1a = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & ismember(Ymat(:,2),schOpts) & ismember(Ymat(:,3),workOpts) & ismember(Ymat(:,4),workOpts);
% samp2a = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & ismember(Ymat(:,2),schOpts) & ismember(Ymat(:,3),workOpts) & ismember(Ymat(:,4),schOpts);
% samp1b = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & ismember(Ymat(:,3),schOpts) & ismember(Ymat(:,4),workOpts) & ismember(Ymat(:,5),workOpts);
% samp2b = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & ismember(Ymat(:,3),schOpts) & ismember(Ymat(:,4),workOpts) & ismember(Ymat(:,5),schOpts);
% samp1c = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & cum_2yr(:,4)==0 & cum_4yr(:,4)==0 & ismember(Ymat(:,4),schOpts) & ismember(Ymat(:,5),workOpts) & ismember(Ymat(:,6),workOpts);
% samp2c = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & cum_2yr(:,4)==0 & cum_4yr(:,4)==0 & ismember(Ymat(:,4),schOpts) & ismember(Ymat(:,5),workOpts) & ismember(Ymat(:,6),schOpts);
% samp1d = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & cum_2yr(:,4)==0 & cum_4yr(:,4)==0 & cum_2yr(:,5)==0 & cum_4yr(:,5)==0 & ismember(Ymat(:,5),schOpts) & ismember(Ymat(:,6),workOpts) & ismember(Ymat(:,7),workOpts);
% samp2d = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & cum_2yr(:,4)==0 & cum_4yr(:,4)==0 & cum_2yr(:,5)==0 & cum_4yr(:,5)==0 & ismember(Ymat(:,5),schOpts) & ismember(Ymat(:,6),workOpts) & ismember(Ymat(:,7),schOpts);
% samp1e = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & cum_2yr(:,4)==0 & cum_4yr(:,4)==0 & cum_2yr(:,5)==0 & cum_4yr(:,5)==0 & cum_2yr(:,6)==0 & cum_4yr(:,6)==0 & ismember(Ymat(:,6),schOpts) & ismember(Ymat(:,7),workOpts) & ismember(Ymat(:,8),workOpts);
% samp2e = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & cum_2yr(:,4)==0 & cum_4yr(:,4)==0 & cum_2yr(:,5)==0 & cum_4yr(:,5)==0 & cum_2yr(:,6)==0 & cum_4yr(:,6)==0 & ismember(Ymat(:,6),schOpts) & ismember(Ymat(:,7),workOpts) & ismember(Ymat(:,8),schOpts);
% flagSamp(:, 2) = samp1 | samp1a | samp1b | samp1c | samp1d | samp1e;
% flagSamp(:, 1) = samp2 | samp2a | samp2b | samp2c | samp2d | samp2e;
flagSamp(:, 3) = samp1 | samp2;
flagSamp(:, 2) = samp1;
flagSamp(:, 1) = samp2;

% summary stats
numgroups = size(flagSamp,2)
posteriorStats = nan(5,5,numgroups);
trueStats      = nan(5,5,numgroups);
cumSchoolStats = nan(3,5,numgroups);
for j=1:numgroups
	trueStats(:,:,j)      = summarize(squeeze(trueAbil(flagSamp(:,j),:)));
	posteriorStats(:,:,j) = summarize(squeeze(posteriorAbilMat(flagSamp(:,j),:,2)));
	cumSchoolStats(:,:,j) = summarize([num2yr(flagSamp(:,j),1) numHum(flagSamp(:,j),1) numSci(flagSamp(:,j),1)]);
end
% rearrange SUMMARIZE output to match with what we want to report in the spreadsheet
posteriorAns = posteriorStats(:,[2 1],:); %switch order of mean and frequency
posteriorAns = reshape(posteriorAns,[10 numgroups])';
posteriorAns = posteriorAns(:,1:6);
trueAns      = trueStats(:,[2 1],:); %switch order of mean and frequency
trueAns      = reshape(trueAns,[10 numgroups])';
trueAns      = trueAns(:,1:6);
cumSchoolAns = cumSchoolStats(:,2,:); %only grab mean
cumSchoolAns = reshape(cumSchoolAns,[3 numgroups])';
posteriorAns = cat(2,posteriorAns,cumSchoolAns);
trueAns      = cat(2,trueAns,cumSchoolAns);
dlmwrite(['LMsortingMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[nan(1,size(posteriorAns,2));posteriorAns(1:3,:);nan(1,size(posteriorAns,2))]);
dlmwrite(['LMsortingMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['divider'],'-append');
dlmwrite(['LMsortingMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[nan(1,size(trueAns,2));trueAns(1:3,:);nan(1,size(trueAns,2))],'-append');
dlmwrite(['LMsortingMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['divider'],'-append');

% LaTeX export of LM sorting table:
header = cell(3,1);
header{1 } = '\\midrule\n';
header{3 } = '\\midrule\n';
names = cell(3,1);
names{1 } = 'Return to school & ';
names{2 } = 'Stay in Work     & ';
names{3 } = 'Total            & ';
nobsstr = cell(3);nobsfmt = cell(3);
for k=1:3
	[nobsstr{k},nobsfmt{k}] = commastring(posteriorAns(k,6));
end
fid = fopen(['LMsortingPosteriorNormedT',num2str(tau),'.tex'], 'w');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lcccccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Path & White Collar  & Blue Collar  & Sci  & Non-Sci  & 2yr  & N\\\\\n');
for j=1:3
	if ismember(j,[1 3])
		fprintf(fid, header{j});
	end
	fprintf(fid, names{j});
	fprintf(fid,'%4.3f',posteriorAns(j,1));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,2));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,3));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,4));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,5));
	fprintf(fid, ' & ');
	fprintf(fid,nobsfmt{j},nobsstr{j});
	fprintf(fid, ' \\\\\n');
end
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\end{threeparttable}\n');
fclose(fid);

% LaTeX export of LM sorting table:
header = cell(3,1);
header{1 } = '\\midrule\n';
header{3 } = '\\midrule\n';
names = cell(3,1);
names{1 } = 'Return to school & ';
names{2 } = 'Stay in Work     & ';
names{3 } = 'Total            & ';
nobsstr = cell(3);nobsfmt = cell(3);
for k=1:3
	[nobsstr{k},nobsfmt{k}] = commastring(trueAns(k,6));
end
fid = fopen(['LMsortingTrueNormedT',num2str(tau),'.tex'], 'w');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lccccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Path  & White Collar & Blue Collar  & Sci  & Non-Sci  & 2yr  & N\\\\\n');
for j=1:3
	if ismember(j,[1 3])
		fprintf(fid, header{j});
	end
	fprintf(fid, names{j});
	fprintf(fid,'%4.3f',trueAns(j,1));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',trueAns(j,2));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',trueAns(j,3));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',trueAns(j,4));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',trueAns(j,5));
	fprintf(fid, ' & ');
	fprintf(fid,nobsfmt{j},nobsstr{j});
	fprintf(fid, ' \\\\\n');
end
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\end{threeparttable}\n');
fclose(fid);




%---------------------------------------------------
% Disaggregated sorting table
%---------------------------------------------------
compStat = nan(N,1);
% those who didn't delay college
flag(:, 1) = CCDOSO==1 & ~delayCollege &  finalMajorSci &  numWorkSch==0;
flag(:, 2) = CCDOSO==1 & ~delayCollege &  finalMajorSci &  numWorkSch>0 & numWorkSch<=1;
flag(:, 3) = CCDOSO==1 & ~delayCollege &  finalMajorSci &  numWorkSch>1 & numWorkSch<=2;
flag(:, 4) = CCDOSO==1 & ~delayCollege &  finalMajorSci &  numWorkSch>2 & numWorkSch<=3;
flag(:, 5) = CCDOSO==1 & ~delayCollege &  finalMajorSci &  numWorkSch>3 & numWorkSch<=4;
flag(:, 6) = CCDOSO==1 & ~delayCollege &  finalMajorSci &  numWorkSch>4;
flag(:, 7) = CCDOSO==1 & ~delayCollege & ~finalMajorSci &  numWorkSch==0;
flag(:, 8) = CCDOSO==1 & ~delayCollege & ~finalMajorSci &  numWorkSch>0 & numWorkSch<=1;
flag(:, 9) = CCDOSO==1 & ~delayCollege & ~finalMajorSci &  numWorkSch>1 & numWorkSch<=2;
flag(:,10) = CCDOSO==1 & ~delayCollege & ~finalMajorSci &  numWorkSch>2 & numWorkSch<=3;
flag(:,11) = CCDOSO==1 & ~delayCollege & ~finalMajorSci &  numWorkSch>3 & numWorkSch<=4;
flag(:,12) = CCDOSO==1 & ~delayCollege & ~finalMajorSci &  numWorkSch>4;
flag(:,13) = CCDOSO==2 & ~delayCollege &  finalMajorSci;
flag(:,14) = CCDOSO==2 & ~delayCollege & ~finalMajorSci;
flag(:,15) = CCDOSO==3 & ~delayCollege &  start2yr     ;
flag(:,16) = CCDOSO==3 & ~delayCollege &  startSci     ;
flag(:,17) = CCDOSO==3 & ~delayCollege &  startHum     ;
flag(:,18) = CCDOSO==4 & ~delayCollege &  numSchool==1;
flag(:,19) = CCDOSO==4 & ~delayCollege &  numSchool==2;
flag(:,20) = CCDOSO==4 & ~delayCollege &  numSchool==3;
flag(:,21) = CCDOSO==4 & ~delayCollege &  numSchool==4;
flag(:,22) = CCDOSO==4 & ~delayCollege &  numSchool>=5;
% flag(:,23) = CCDOSO==5 & ~delayCollege
% flag(:,24) = CCDOSO==6 & ~delayCollege
% those who delayed starting college
flag(:,23) = CCDOSO==1 &  delayCollege &  finalMajorSci;
flag(:,24) = CCDOSO==1 &  delayCollege & ~finalMajorSci;
flag(:,25) = CCDOSO==2 &  delayCollege &  finalMajorSci;
flag(:,26) = CCDOSO==2 &  delayCollege & ~finalMajorSci;
flag(:,27) = CCDOSO==3 &  delayCollege &  start2yr     ;
flag(:,28) = CCDOSO==3 &  delayCollege &  startSci     ;
flag(:,29) = CCDOSO==3 &  delayCollege &  startHum     ;
flag(:,30) = CCDOSO==4 &  delayCollege;
% flag(:,33) = CCDOSO==5 &  delayCollege;
% flag(:,34) = CCDOSO==6 &  delayCollege;
% those who are truncated
flag(:,31) = CCDOSO==5;
flag(:,32) = CCDOSO==6;
% those who never went to college
flag(:,33) = neverCollege;

% posterior ability statistics
% check that these are mutually exclusive
summarize(sum(flag,2));

% generate "last period" for each individual
lastPeriod = nan(N,1);
lastPeriod(~neverCollege) = lastColPer(~neverCollege);
lastPeriod(neverCollege) = tau;

% generate posterior abilities in last period
poster        = nan(N,J);
num2yrI       = zeros(N,1);
numSciI       = zeros(N,1);
numHumI       = zeros(N,1);
numWorkFTSchI = zeros(N,1);
numWorkPTSchI = zeros(N,1);
numWCWorkI    = zeros(N,1);
numBCWorkI    = zeros(N,1);
for i=1:length(flag)
	poster(i,:)      = squeeze(posteriorAbilMat(i,:,lastPeriod(i)));
	postVery(i,:)    = squeeze(posteriorVarDiagMat(i,:,lastPeriod(i)));
	posterEnd(i,:)   = squeeze(posteriorAbilMat(i,:,tau));
	postVeryEnd(i,:) = squeeze(posteriorVarDiagMat(i,:,tau));
	% num2yrI       = sum(ismember(Ymat(i,1:lastPeriod(i)),[1 2 3 4 5]),2);
	% numSciI       = sum(ismember(Ymat(i,1:lastPeriod(i)),[6 7 8 9 10]),2);
	% numHumI       = sum(ismember(Ymat(i,1:lastPeriod(i)),[11 12 13 14 15]),2);
	% numWorkFTSchI = sum(ismember(Ymat(i,1:lastPeriod(i)),[1 4 7]),2);
	% numWorkPTSchI = sum(ismember(Ymat(i,1:lastPeriod(i)),[2 5 8]),2);
	% numWCWorkI    = sum(ismember(Ymat(i,1:lastPeriod(i)),workOpts) & grad_4yr==0,2);
	% numBCWorkI    = sum(ismember(Ymat(i,1:lastPeriod(i)),[10 11 13 14]) & grad_4yr==1,2);
end

% summary stats
numgroups = size(flag,2)
posteriorStats = nan(5,5,numgroups);
cumSchoolStats = nan(3,5,numgroups);
for j=1:numgroups
	posteriorStats(:,:,j) = summarize(poster(flag(:,j),:));
	cumSchoolStats(:,:,j) = summarize([num2yr(flag(:,j),1) numHum(flag(:,j),1) numSci(flag(:,j),1)]);
end
% rearrange SUMMARIZE output to match with what we want to report in the spreadsheet
posteriorAns = posteriorStats(:,[2 1],:); %switch order of mean and frequency
posteriorAns = reshape(posteriorAns,[10 numgroups])';
posteriorAns = posteriorAns(:,1:6);
cumSchoolAns = cumSchoolStats(:,2,:); %only grab mean
cumSchoolAns = reshape(cumSchoolAns,[3 numgroups])';
posteriorAns = cat(2,posteriorAns,cumSchoolAns);
dlmwrite(['SimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[nan(1,size(posteriorAns,2));posteriorAns(1:6,:);nan(1,size(posteriorAns,2));posteriorAns(7:12,:);nan(1,size(posteriorAns,2));posteriorAns(13:17,:);nan(1,size(posteriorAns,2));posteriorAns(18:22,:);nan(1,size(posteriorAns,2));posteriorAns(23:end-3,:);nan(1,size(posteriorAns,2));posteriorAns(end-2:end-1,:);nan(1,size(posteriorAns,2));posteriorAns(end,:);nan(1,size(posteriorAns,2))]);
dlmwrite(['SimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['divider'],'-append');

trueStats = nan(5,5,numgroups);
for j=1:numgroups
	trueStats(:,:,j) = summarize(squeeze(trueAbil(flag(:,j),:,end)));
end
trueAns = trueStats(:,[2 1],:);
trueAns = reshape(trueAns,[10 numgroups])';
trueAns = trueAns(:,1:6);
trueAns = cat(2,trueAns,cumSchoolAns);
dlmwrite(['SimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[nan(1,size(trueAns,2));trueAns(1:6,:);nan(1,size(trueAns,2));trueAns(7:12,:);nan(1,size(trueAns,2));trueAns(13:17,:);nan(1,size(trueAns,2));trueAns(18:22,:);nan(1,size(trueAns,2));trueAns(23:end-3,:);nan(1,size(trueAns,2));trueAns(end-2:end-1,:);nan(1,size(trueAns,2));trueAns(end,:);nan(1,size(trueAns,2))],'-append');
dlmwrite(['SimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['divider'],'-append');

postVarStats = nan(5,5,numgroups);
for j=1:numgroups
	postVarStats(:,:,j) = summarize(postVery(flag(:,j),:));
end
postVarAns = postVarStats(:,[2 1],:);
postVarAns = reshape(postVarAns,[10 numgroups])';
postVarAns = postVarAns(:,1:6);
postVarAns = cat(2,postVarAns,cumSchoolAns);
dlmwrite(['SimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[nan(1,size(postVarAns,2));postVarAns(1:6,:);nan(1,size(postVarAns,2));postVarAns(7:12,:);nan(1,size(postVarAns,2));postVarAns(13:17,:);nan(1,size(postVarAns,2));postVarAns(18:22,:);nan(1,size(postVarAns,2));postVarAns(23:end-3,:);nan(1,size(postVarAns,2));postVarAns(end-2:end-1,:);nan(1,size(postVarAns,2));postVarAns(end,:);nan(1,size(postVarAns,2))],'-append');
dlmwrite(['SimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['divider'],'-append');

% Post results of what is the posterior variance after 1 signal, 2 signals, etc.
postVarExample = nan(J,tau+1);
postVarExample(:,1) = diag(Delta);
for j=1:J
	pV = Delta;
	for t=1:tau
		pV = postVarSimple(pV,sigNormed,j,t);
		postVarExample(j,t+1) = pV(j,j);
	end
end
dlmwrite(['SimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[postVarExample';nan(1,J)],'-append');

% Post results of what is the posterior variance after 1 signal, 2 signals, etc. (dual signals with unskilled wages)
postVarExample = nan(J,tau+1);
postVarExample(:,1) = diag(Delta);
for j=1:J
	pV = Delta;
	for t=1:tau
		pV = postVarJoint(pV,sigNormed,j,2,t);
		postVarExample(j,t+1) = pV(j,j);
	end
end
dlmwrite(['SimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[postVarExample';nan(1,J)],'-append');



%---------------------------------------------------
% Posterior Variance by Personal Background
%---------------------------------------------------
flagBackgr(:,1 ) = black==1;
flagBackgr(:,2 ) = hispanic==1;
flagBackgr(:,3 ) = black==0 & hispanic==0;
flagBackgr(:,4 ) = Parent_college==0;
flagBackgr(:,5 ) = Parent_college==1;
flagBackgr(:,6 ) =                                   HS_grades<=prctile(HS_grades,25);
flagBackgr(:,7 ) = HS_grades>prctile(HS_grades,25) & HS_grades<=prctile(HS_grades,51);
flagBackgr(:,8 ) = HS_grades>prctile(HS_grades,51) & HS_grades<=prctile(HS_grades,75);
flagBackgr(:,9 ) = HS_grades>prctile(HS_grades,75);
flagBackgr(:,10) =                             famInc<=prctile(famInc,25);
flagBackgr(:,11) = famInc>prctile(famInc,25) & famInc<=prctile(famInc,50);
flagBackgr(:,12) = famInc>prctile(famInc,50) & famInc<=prctile(famInc,75);
flagBackgr(:,13) = famInc>prctile(famInc,75);

% generate posterior variances in last period
for i=1:length(flagBackgr)
	postVery(i,:) = squeeze(posteriorVarDiagMat(i,:,lastPeriod(i)));
end

% summary stats
numgroups = size(flagBackgr,2)
posteriorStats = nan(5,5,numgroups);
cumSchoolStats = nan(3,5,numgroups);
for j=1:numgroups
	posteriorStats(:,:,j) = summarize(postVery(flagBackgr(:,j),:));
end
% rearrange SUMMARIZE output to match with what we want to report in the spreadsheet
posteriorAns = posteriorStats(:,[2 1],:); %switch order of mean and frequency
posteriorAns = reshape(posteriorAns,[10 numgroups])';
posteriorAns = posteriorAns(:,1:6);
dlmwrite(['PostVarBackgroundMCintEstDataNormedT',num2str(tau),'.csv'],[nan(1,size(posteriorAns,2));posteriorAns(1:3,:);nan(1,size(posteriorAns,2));posteriorAns(4:5,:);nan(1,size(posteriorAns,2));posteriorAns(6:9,:);nan(1,size(posteriorAns,2));posteriorAns(10:13,:);nan(1,size(posteriorAns,2));posteriorAns(14:end,:);nan(1,size(posteriorAns,2))]);
dlmwrite(['PostVarBackgroundMCintEstDataNormedT',num2str(tau),'.csv'],['divider'],'-append');


% LaTeX export of posterior variances by demographics:
header = cell(13,1);
header{1 } = '\\midrule\n\\multicolumn{6}{l}{\\emph{Race}}\\\\\n';
header{4 } = '\\midrule\n\\multicolumn{6}{l}{\\emph{Parental college status}}\\\\\n';
header{6 } = '\\midrule\n\\multicolumn{6}{l}{\\emph{HS GPA quartile}}\\\\\n';
header{10} = '\\midrule\n\\multicolumn{6}{l}{\\emph{Family income quartile}}\\\\\n';
names = cell(13,1);
names{1 } = 'Black                            & ';
names{2 } = 'Hispanic                         & ';
names{3 } = 'White                            & ';
names{4 } = 'Parent did not graduate college  & ';
names{5 } = 'Parent graduated college         & ';
names{6 } = '1st quartile                     & ';
names{7 } = '2nd quartile                     & ';
names{8 } = '3rd quartile                     & ';
names{9 } = '4th quartile                     & ';
names{10} = '1st quartile                     & ';
names{11} = '2nd quartile                     & ';
names{12} = '3rd quartile                     & ';
names{13} = '4th quartile                     & ';
nobsstr = cell(13);nobsfmt = cell(13);
share = zeros(13,1);
for k=1:13
	[nobsstr{k},nobsfmt{k}] = commastring(posteriorAns(k,6));
	if ismember(k,[1:3])
		share(k,1) = posteriorAns(k,6)./sum(posteriorAns(1:3,6));
	elseif ismember(k,[4:5])
		share(k,1) = posteriorAns(k,6)./sum(posteriorAns(4:5,6));
	elseif ismember(k,[6:9])
		share(k,1) = posteriorAns(k,6)./sum(posteriorAns(6:9,6));
	elseif ismember(k,[10:13])
		share(k,1) = posteriorAns(k,6)./sum(posteriorAns(10:13,6));
	end
end
fid = fopen(['PostVarBackgroundMCintEstDataNormedT',num2str(tau),'.tex'], 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Average posterior variances after last year of college by demographic characteristics}\n');
fprintf(fid, '\\label{tab:PostVarDemog} \n');
fprintf(fid, '\\centering{}\n');
fprintf(fid, '\\resizebox{.95\\textwidth}{!}{\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lccccc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Characteristic  & White Collar  & Blue Collar  & Science  & Non-Science  & 2-year\\\\\n');
for j=[1:13]
	if ismember(j,[1 4 6 10])
		fprintf(fid, header{j});
	end
	fprintf(fid, names{j});
	fprintf(fid,'%4.3f',posteriorAns(j,1));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,2));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,3));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,4));
	fprintf(fid, ' & ');
	fprintf(fid,'%4.3f',posteriorAns(j,5));
	% fprintf(fid, ' & ');
	% fprintf(fid,'%3.1f',100*share(j));
	fprintf(fid, ' \\\\\n');
end
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Time 0 population variance');
fprintf(fid, ' & ');
fprintf(fid,'%4.3f',Delta(1,1));
fprintf(fid, ' & ');
fprintf(fid,'%4.3f',Delta(2,2));
fprintf(fid, ' & ');
fprintf(fid,'%4.3f',Delta(3,3));
fprintf(fid, ' & ');
fprintf(fid,'%4.3f',Delta(4,4));
fprintf(fid, ' & ');
fprintf(fid,'%4.3f',Delta(5,5));
fprintf(fid, ' \\\\\n');
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid,['\\footnotesize Notes: This table is constructed using 100 simulations of the structural model for each individual included in the estimation. For those who never attended college, we use the posterior in the ',num2str(tau),'th period.\n']);
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);




% Post results of what is the posterior variance after certain GPA signal sequences
ttau = 3;
JJ   = 12;
jmat = nan(JJ,ttau);
jmat( 1,1:1) = [3    ];
jmat( 2,1:1) = [4    ];
jmat( 3,1:2) = [3 4  ];
jmat( 4,1:2) = [4 3  ];
jmat( 5,1:3) = [3 4 4];
jmat( 6,1:3) = [3 4 3];
jmat( 7,1:3) = [3 3 4];
jmat( 8,1:3) = [3 3 3];
jmat( 9,1:3) = [4 3 3];
jmat(10,1:3) = [4 3 4];
jmat(11,1:3) = [4 4 3];
jmat(12,1:3) = [4 4 4];
postVarExample = nan(J,JJ+1);
postVarExample(:,1) = diag(Delta);
for jj=1:JJ
	pV = Delta;
	for tt=1:ttau
		j = jmat(jj,tt);
		if ~isnan(j)
			pV = postVarSimple(pV,sigNormed,j,tt);
			postVarExample(:,jj+1) = diag(pV);
		end
	end
end
dlmwrite(['SimulationsMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[postVarExample';nan(1,J)],'-append');

% Signals affecting decisions (cf. table 10)
samp1  = everSO & ismember(Ymat(:,1),schOpts) & ismember(Ymat(:,2),workOpts) & ismember(Ymat(:,3),workOpts);
samp2  = everSO & ismember(Ymat(:,1),schOpts) & ismember(Ymat(:,2),workOpts) & ismember(Ymat(:,3),schOpts);
samp1a = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & ismember(Ymat(:,2),schOpts) & ismember(Ymat(:,3),workOpts) & ismember(Ymat(:,4),workOpts);
samp2a = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & ismember(Ymat(:,2),schOpts) & ismember(Ymat(:,3),workOpts) & ismember(Ymat(:,4),schOpts);
samp1b = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & ismember(Ymat(:,3),schOpts) & ismember(Ymat(:,4),workOpts) & ismember(Ymat(:,5),workOpts);
samp2b = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & ismember(Ymat(:,3),schOpts) & ismember(Ymat(:,4),workOpts) & ismember(Ymat(:,5),schOpts);
samp1c = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & cum_2yr(:,4)==0 & cum_4yr(:,4)==0 & ismember(Ymat(:,4),schOpts) & ismember(Ymat(:,5),workOpts) & ismember(Ymat(:,6),workOpts);
samp2c = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & cum_2yr(:,4)==0 & cum_4yr(:,4)==0 & ismember(Ymat(:,4),schOpts) & ismember(Ymat(:,5),workOpts) & ismember(Ymat(:,6),schOpts);
samp1d = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & cum_2yr(:,4)==0 & cum_4yr(:,4)==0 & cum_2yr(:,5)==0 & cum_4yr(:,5)==0 & ismember(Ymat(:,5),schOpts) & ismember(Ymat(:,6),workOpts) & ismember(Ymat(:,7),workOpts);
samp2d = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & cum_2yr(:,4)==0 & cum_4yr(:,4)==0 & cum_2yr(:,5)==0 & cum_4yr(:,5)==0 & ismember(Ymat(:,5),schOpts) & ismember(Ymat(:,6),workOpts) & ismember(Ymat(:,7),schOpts);
samp1e = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & cum_2yr(:,4)==0 & cum_4yr(:,4)==0 & cum_2yr(:,5)==0 & cum_4yr(:,5)==0 & cum_2yr(:,6)==0 & cum_4yr(:,6)==0 & ismember(Ymat(:,6),schOpts) & ismember(Ymat(:,7),workOpts) & ismember(Ymat(:,8),workOpts);
samp2e = everSO & cum_2yr(:,2)==0 & cum_4yr(:,2)==0 & cum_2yr(:,3)==0 & cum_4yr(:,3)==0 & cum_2yr(:,4)==0 & cum_4yr(:,4)==0 & cum_2yr(:,5)==0 & cum_4yr(:,5)==0 & cum_2yr(:,6)==0 & cum_4yr(:,6)==0 & ismember(Ymat(:,6),schOpts) & ismember(Ymat(:,7),workOpts) & ismember(Ymat(:,8),schOpts);
flagSamp(:, 2) = samp1 | samp1a | samp1b | samp1c | samp1d | samp1e;
flagSamp(:, 1) = samp2 | samp2a | samp2b | samp2c | samp2d | samp2e;

% summary stats
numgroups = size(flagSamp,2)
posteriorStats = nan(5,5,numgroups);
cumSchoolStats = nan(3,5,numgroups);
for j=1:numgroups
	posteriorStats(:,:,j) = summarize(squeeze(posteriorAbilMat(flagSamp(:,j),:,2)));
	cumSchoolStats(:,:,j) = summarize([num2yr(flagSamp(:,j),1) numHum(flagSamp(:,j),1) numSci(flagSamp(:,j),1)]);
end
% rearrange SUMMARIZE output to match with what we want to report in the spreadsheet
posteriorAns = posteriorStats(:,[2 1],:); %switch order of mean and frequency
posteriorAns = reshape(posteriorAns,[10 numgroups])';
posteriorAns = posteriorAns(:,1:6);
cumSchoolAns = cumSchoolStats(:,2,:); %only grab mean
cumSchoolAns = reshape(cumSchoolAns,[3 numgroups])';
posteriorAns = cat(2,posteriorAns,cumSchoolAns);
% dlmwrite(['LMsortingMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[nan(1,size(posteriorAns,2));posteriorAns(1:2,:);nan(1,size(posteriorAns,2))]);
% dlmwrite(['LMsortingMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['divider'],'-append');





% AbilSamp1   = nan(N,5);
% AbilSamp2   = nan(N,5);
% AbilSamp12  = nan(N,5);
% VabilSamp1  = nan(N,5);
% VabilSamp2  = nan(N,5);
% VabilSamp12 = nan(N,5);
% AbilSamp1(samp1,:)           = squeeze(posteriorAbilMat(samp1,:,2));
% AbilSamp2(samp2,:)           = squeeze(posteriorAbilMat(samp2,:,2));
% AbilSamp12(samp1 | samp2,:)  = squeeze(posteriorAbilMat(samp1 | samp2,:,2));
% VabilSamp1(samp1,:)          = squeeze(posteriorVarDiagMat(samp1,:,2));
% VabilSamp2(samp2,:)          = squeeze(posteriorVarDiagMat(samp2,:,2));
% VabilSamp12(samp1 | samp2,:) = squeeze(posteriorVarDiagMat(samp1 | samp2,:,2));
% dlmwrite(['LMsortingMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],[nan(1,size(posteriorAns,2));[[nanmean(AbilSamp1(samp1,:));nanmean(AbilSamp2(samp2,:))] [sum(samp1);sum(samp2)] [[num2yr(AbilSamp1(samp1,3)) numHum(AbilSamp1(samp1,3)) numSci(AbilSamp1(samp1,3))];[num2yr(AbilSamp2(samp2,3)) numHum(AbilSamp2(samp2,3)) numSci(AbilSamp2(samp2,3))]]]],'-append');
% dlmwrite(['LMsortingMCintEstDataGradYearOnlyNormedT',num2str(tau),'.csv'],['divider'],'-append');


% summarize(AbilSamp1);
% summarize(AbilSamp2);
% summarize(AbilSamp12);
% summarize(VabilSamp1);
% summarize(VabilSamp2);
% summarize(VabilSamp12);

% [rejectNull,pval]=ttest2(AbilSamp1(:,2),AbilSamp2(:,2))
% abs(tinv(1-pval/2,20000))

% [rejectNull,pval]=ttest2(AbilSamp1(:,3),AbilSamp2(:,3))
% abs(tinv(1-pval/2,20000))

% [rejectNull,pval]=ttest2(AbilSamp1(:,4),AbilSamp2(:,4))
% abs(tinv(1-pval/2,20000))

% Test
% 1. Sci then Hum
pV = Delta;
pV = postVarSimple(pV,sigNormed,3,1);
pV = postVarSimple(pV,sigNormed,4,2);
diag(pV)
% 2. Hum then Sci
pV = Delta;
pV = postVarSimple(pV,sigNormed,4,1);
pV = postVarSimple(pV,sigNormed,3,2);
diag(pV)




%---------------------------------------------------
% Model fit and completion status
%---------------------------------------------------
% Model Fit
weighttab(ClImps(ClImps>0),PmajgpaType(ClImps>0));
tabulate(Ymat(:));

weighttab(ClImps(ClImps>0 & grad_4yrlImps==0),PmajgpaType(ClImps>0 & grad_4yrlImps==0));
tabulate(Ymat(grad_4yr==0));

weighttab(ClImps(ClImps>0 & grad_4yrlImps==1),PmajgpaType(ClImps>0 & grad_4yrlImps==1));
tabulate(Ymat(grad_4yr==1));

% Some summary statistics
% summarize(~neverCollege);
% summarize(ever2yr);
% summarize(ever4yr);
% summarize(ever4yr & ever2yr);
% summarize(everSO(~neverCollege));
% summarize(everDO(~neverCollege));
% summarize(everCC(~neverCollege));
% summarize(everSO(ever2yr));
% summarize(everDO(ever2yr));
% summarize(everCC(ever2yr));
% summarize(everSO(ever4yr));
% summarize(everDO(ever4yr));
% summarize(everCC(ever4yr));
% summarize(finalMajorSci(everGrad4yr));
% summarize(everSO(everGrad4yr));

% tabulate the CC/DO/SO variable:
tabulate(CCDOSO(CCDOSO<7));
output = tabulate(CCDOSO);
output = output(:,end);
tabulate(CCDOSOdetail);
output2 = tabulate(CCDOSOdetail);
output2 = output2(:,end);


% major switching
switchMaj = (ismember(Ymat,c2Opts)  & ismember(LY,c4Opts)) | ...
            (ismember(Ymat,c4sOpts) & ismember(LY,[c2Opts c4hOpts])) | ...
            (ismember(Ymat,c4hOpts) & ismember(LY,[c2Opts c4sOpts]));
numMajSwitches = cumsum(switchMaj,2);
output3(1,1) = 100*mean(ismember(Ymat(numSchoolNow==2 & (startSci*ones(1,10)==1)),c4hOpts));
output3(2,1) = 100*mean(ismember(Ymat(numSchoolNow==2 & (startHum*ones(1,10)==1)),c4sOpts));
output3(3,1) = 100*mean(ismember(Ymat(numSchoolNow==4 & (startSci*ones(1,10)==1)),c4hOpts));
output3(4,1) = 100*mean(ismember(Ymat(numSchoolNow==4 & (startHum*ones(1,10)==1)),c4sOpts));
output3(5,1) =   1*mean(numMajSwitches(grad_4yr==1 & grad_4yrLY==0));
output3(6,1) = 100*mean(ever2yr(everGrad4yr==1)==1);
% dlmwrite('MCintEstDataNormedSwitchingTable.csv',[output3]);

% fraction graduating from 4-year college and ever attending 2-year
% output4(1,1) = 100*mean(everGrad4yr & ever2yr);
% dlmwrite('Normed2yrProb.csv',[output4]);

[nobsstr,nobsfmt] = commastring(N);

% LaTeX export:
fid = fopen('CompStatTableBase.tex', 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{College completion status frequencies: baseline and counterfactual}\n');
fprintf(fid, '\\label{tab:compStatBaseCfl} \n');
fprintf(fid, '\\centering{}\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, '                                                                  & Baseline (\\%%)\\\\\n');
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Continuous completion (CC), Science                               &  ');
fprintf(fid,'%4.2f',output2(1));
fprintf(fid, ' \\\\\n');
fprintf(fid, 'Continuous completion (CC), Non-Science                            &  ');
fprintf(fid,'%4.2f',output2(2));
fprintf(fid, ' \\\\\n');
fprintf(fid, 'Stop out (SO) but graduated Science                                   &  ');
fprintf(fid,'%4.2f',output2(3));
fprintf(fid, ' \\\\\n');
fprintf(fid, 'Stop out (SO) but graduated Non-Science                                   &  ');
fprintf(fid,'%4.2f',output2(4));
fprintf(fid, ' \\\\\n');
fprintf(fid, 'Graduate from four-year college                                   &  ');
fprintf(fid,'%4.2f',sum(output2(1:4)));
fprintf(fid, ' \\\\\n');
fprintf(fid, 'Graduate from four-year college \\& ever attended two-year college &  ');
fprintf(fid,'%4.2f',100*mean(everGrad4yr & ever2yr));
fprintf(fid, ' \\\\\n');
fprintf(fid, 'Stop out (SO) then drop out                                       &  ');
fprintf(fid,'%4.2f',output2(5));
fprintf(fid, ' \\\\\n');
fprintf(fid, 'Drop out (DO)                                                     &  ');
fprintf(fid,'%4.2f',output2(6));
fprintf(fid, ' \\\\\n');
fprintf(fid, 'Never went to college                                             &  ');
fprintf(fid,'%4.2f',output2(end));
fprintf(fid, ' \\\\\n');
fprintf(fid, '\\midrule\n');
fprintf(fid, '$N$                                                               &  ');
fprintf(fid,nobsfmt,nobsstr);
fprintf(fid, ' \\\\\n');
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Figures constructed using 100 simulations of the structural model for each individual included in the estimation.\n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);


% LaTeX export:
fid = fopen('majSwitchTableBase.tex', 'w');
fprintf(fid, '\\begin{table}[ht]\n');
fprintf(fid, '\\caption{Major switching probabilities: baseline and counterfactua}\n');
fprintf(fid, '\\label{tab:majSwitchBaseCfl} \n');
fprintf(fid, '\\centering{}\n');
fprintf(fid, '\\begin{threeparttable}\n');
fprintf(fid, '\\begin{tabular}{lc}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, '                                                & Baseline (\\%%)\\\\\n');
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Pr(switch | started science, enrolled 2 years)  &  ');
fprintf(fid,'%4.2f',output3(1));
fprintf(fid, ' \\\\\n');
fprintf(fid, 'Pr(switch | started non-science, enrolled 2 years)      &  ');
fprintf(fid,'%4.2f',output3(2));
fprintf(fid, ' \\\\\n');
fprintf(fid, 'Pr(switch | started science, enrolled 4 years)  &  ');
fprintf(fid,'%4.2f',output3(3));
fprintf(fid, ' \\\\\n');
fprintf(fid, 'Pr(switch | started non-science,  enrolled 4 years)     &  ');
fprintf(fid,'%4.2f',output3(4));
fprintf(fid, ' \\\\\n');
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Pr(start 2yr | grad 4yr)                        &  ');
fprintf(fid,'%4.2f',output3(6));
fprintf(fid, ' \\\\\n');
fprintf(fid, 'Number of major switches | graduate             &  ');
fprintf(fid,'%4.2f',output3(5));
fprintf(fid, ' \\\\\n');
fprintf(fid, '\\midrule\n');
fprintf(fid, '$N$                                             &  ');
fprintf(fid,nobsfmt,nobsstr);
fprintf(fid, ' \\\\\n');
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\footnotesize Notes: Figures constructed using 100 simulations of the structural model for each individual included in the estimation.\n');
fprintf(fid, '\\end{threeparttable}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);




% time to degree
cumSchool = cum_2yr+cum_4yr;
ttd = zeros(N,1);
kk=1;
for i=1:N
	if everGrad4yr(i)==1
		ttd(i)=cumSchool(i,yrGrad4yr(kk))+1;
		kk = kk+1;
	end
end
summarize(ttd(everGrad4yr));
end

end
