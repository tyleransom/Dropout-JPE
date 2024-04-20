function [choiceData] = createchoicedata(fname,S)
    %% Load DDC data and adjust things
    year = [];
    load(fname)
    %% Use hourly compensation instead of hourly wage
    log_wage = log_compJobMain;
    options = struct('Detail','on');
    summarize(log_wage(anyFlag==0),options);
    %% Decide on cutoff for hours/week for home production and part-time work
    home_cut = 10;
    pt_cut   = 35;
    %% generate "work PT while in school" and "work FT while in school" vectors
    workFTschool = (((choice==2)|(choice==3))&(weeks_worked_Oct>=4)&(hours_per_week_Oct>=pt_cut));
    workPTschool = (((choice==2)|(choice==3))&(weeks_worked_Oct>=4)&(hours_per_week_Oct>=home_cut & hours_per_week_Oct<pt_cut));
    workFT       = ( (choice~=2)&(choice~=3) &(weeks_worked_Oct>=4)&(hours_per_week_Oct>=pt_cut));
    workPT       = ( (choice~=2)&(choice~=3) &(weeks_worked_Oct>=4)&(hours_per_week_Oct>=home_cut & hours_per_week_Oct<pt_cut));
    workFTall    = ((weeks_worked_Oct>=4)&(hours_per_week_Oct>=pt_cut));
    workPTall    = ((weeks_worked_Oct>=4)&(hours_per_week_Oct>=home_cut & hours_per_week_Oct<pt_cut));
    %% Redefine Science and Non-science majors
    % Science Majors: categories 1,6,9,13,21,25,36
    % Non-scienc: everything else (i.e. 2-5,7-8,10-12,14-20,22-24,26-35, 37-99
    scienceMajor = (major==1 | major==6 | major==9 | major==13 | major==21 | major==25 | major==36);
    otherMajor   = ((major>=2 & major<=5) | (major>=7 & major<=8) | (major>=10 & major<=12) | (major>=14 & major<=20) | (major>=22 & major<=24) | (major>=26 & major<=35) | (major>=37 & major<=999));
    %% Generate "year in school" variable
    yrc = cumsum(choice==2 | choice==3,2).*(choice==2 | choice==3);
    perd = kron(ones(size(choice,1),1),[1:size(choice,2)]);
    grades(grades==0) = eps;
    neverCol    = max(choice'>=2 & choice'<=3)'==0;
    firstCol2yr = max(choice'==2 & yrc'==1)';
    firstCol4yr = max(choice'==3 & yrc'==1)';
    firstGrades = zeros(size(choice,1),1);
    firstGrades(neverCol) = NaN;
    firstGrades(~neverCol) = grades(yrc==1);
    firstCol2yr = firstCol2yr*ones(1,size(choice,2));
    firstCol4yr = firstCol4yr*ones(1,size(choice,2));
    firstGrades = firstGrades*ones(1,size(choice,2));
    origSciMajor  = (choice==2 | choice==3).*scienceMajor;
    origHumMajor  = (choice==2 | choice==3).*otherMajor;
    origMissMajor = (choice==2 | choice==3).*(1-otherMajor-scienceMajor);
    %% Drop bad majors (at second missing occurrence)
    miss_major = scienceMajor==0 & otherMajor==0 & choice==3;
    ever_miss_major = max(miss_major')';
    ever_4yr = max(choice'==3)';
    ever_2yr = max(choice'==2)';
    num_miss_major = sum(miss_major,2);
    bad_major = cumsum(miss_major,2)>=2;
    %% Generate grad school dummy
    in_grad_school = in_grad_school.*grad_4yr;
    %% Initiate the choice9 vector
    choice9 = nan(size(choice));
    choice9(choice==1)                                                   = -1; % HS
    choice9((choice==2)&(workFTschool==1))                               = 1; % 2yr FT
    choice9((choice==2)&(workPTschool==1))                               = 2; % 2yr PT
    choice9((choice==2)&(workFTschool==0)&(workPTschool==0))             = 3; % 2yr no work
    choice9((choice==3)&(workFTschool==1))                               = 4; % 4yr FT
    choice9((choice==3)&(workPTschool==1))                               = 5; % 4yr PT
    choice9((choice==3)&(workFTschool==0)&(workPTschool==0))             = 6; % 4yr no work
    choice9((choice~=1)&(choice~=2)&(choice~=3)&(workPT==1))             = 7; % work PT
    choice9((choice~=1)&(choice~=2)&(choice~=3)&(workFT==1))             = 8; % work FT
    choice9((choice~=1)&(choice~=2)&(choice~=3)&(workPT==0)&(workFT==0)) = 9; % home
    %% Initiate the choice12 vector
    choice12 = nan(size(choice));
    choice12(choice==1)                                                         = -1; % HS
    choice12((choice==2)&(workFTschool==1))                                     = 1;  % 2yr FT
    choice12((choice==2)&(workPTschool==1))                                     = 2;  % 2yr PT
    choice12((choice==2)&(workFTschool==0)&(workPTschool==0))                   = 3;  % 2yr no work
    choice12((choice==3)&(scienceMajor==1)&(workFTschool==1))                   = 4;  % 4yr science FT
    choice12((choice==3)&(scienceMajor==1)&(workPTschool==1))                   = 5;  % 4yr science PT
    choice12((choice==3)&(scienceMajor==1)&(workFTschool==0)&(workPTschool==0)) = 6;  % 4yr science no work
    choice12((choice==3)&(otherMajor  ==1)&(workFTschool==1))                   = 7;  % 4yr non-science FT
    choice12((choice==3)&(otherMajor  ==1)&(workPTschool==1))                   = 8;  % 4yr non-science PT
    choice12((choice==3)&(otherMajor  ==1)&(workFTschool==0)&(workPTschool==0)) = 9;  % 4yr non-science no work
    choice12((choice~=1)&(choice~=2)&(choice~=3)&(workPT==1))                   = 10; % work PT
    choice12((choice~=1)&(choice~=2)&(choice~=3)&(workFT==1))                   = 11; % work FT
    choice12((choice~=1)&(choice~=2)&(choice~=3)&(workPT==0)&(workFT==0))       = 12; % home
    %% Initiate the choice25 vector
    choice25 = nan(size(choice));
    choice25(choice==1)                                                                                          = -1; % HS
    choice25((choice==2)&(workFTschool==1)&(whiteCollar==0))                                                     = 1;  % 2yr FT, blue collar
    choice25((choice==2)&(workFTschool==1)&(whiteCollar==1))                                                     = 2;  % 2yr FT, white collar
    choice25((choice==2)&(workPTschool==1)&(whiteCollar==0))                                                     = 3;  % 2yr PT, blue collar
    choice25((choice==2)&(workPTschool==1)&(whiteCollar==1))                                                     = 4;  % 2yr PT, white collar
    choice25((choice==2)&(workFTschool==0)&(workPTschool==0))                                                    = 5;  % 2yr no work
    choice25((choice==3)&(scienceMajor==1)&(workFTschool==1)&(whiteCollar==0))                                   = 6;  % 4yr science FT, blue collar
    choice25((choice==3)&(scienceMajor==1)&(workFTschool==1)&(whiteCollar==1))                                   = 7;  % 4yr science FT, white collar
    choice25((choice==3)&(scienceMajor==1)&(workPTschool==1)&(whiteCollar==0))                                   = 8;  % 4yr science PT, blue collar
    choice25((choice==3)&(scienceMajor==1)&(workPTschool==1)&(whiteCollar==1))                                   = 9;  % 4yr science PT, white collar
    choice25((choice==3)&(scienceMajor==1)&(workFTschool==0)&(workPTschool==0))                                  = 10; % 4yr science no work
    choice25((choice==3)&(otherMajor  ==1)&(workFTschool==1)&(whiteCollar==0))                                   = 11; % 4yr non-science FT, blue collar
    choice25((choice==3)&(otherMajor  ==1)&(workFTschool==1)&(whiteCollar==1))                                   = 12; % 4yr non-science FT, white collar
    choice25((choice==3)&(otherMajor  ==1)&(workPTschool==1)&(whiteCollar==0))                                   = 13; % 4yr non-science PT, blue collar
    choice25((choice==3)&(otherMajor  ==1)&(workPTschool==1)&(whiteCollar==1))                                   = 14; % 4yr non-science PT, white collar
    choice25((choice==3)&(otherMajor  ==1)&(workFTschool==0)&(workPTschool==0))                                  = 15; % 4yr non-science no work
    choice25((choice~=1)&(choice~=2)&(choice~=3)&(workPT==1)&(whiteCollar==0))                                   = 16; % work PT, blue collar
    choice25((choice~=1)&(choice~=2)&(choice~=3)&(workPT==1)&(whiteCollar==1))                                   = 17; % work PT, white collar
    choice25((choice~=1)&(choice~=2)&(choice~=3)&(workFT==1)&(whiteCollar==0))                                   = 18; % work FT, blue collar
    choice25((choice~=1)&(choice~=2)&(choice~=3)&(workFT==1)&(whiteCollar==1))                                   = 19; % work FT, white collar
    choice25((choice~=1)&(choice~=2)&(choice~=3)&(workPT==0)&(workFT==0))                                        = 20; % home
    choice25((choice~=1)&(choice~=2)&(choice~=3)&(in_grad_school==1)&(grad_4yr==1)&(workFT==1)&(whiteCollar==0)) = 21; % grad school FT, blue collar
    choice25((choice~=1)&(choice~=2)&(choice~=3)&(in_grad_school==1)&(grad_4yr==1)&(workFT==1)&(whiteCollar==1)) = 22; % grad school FT, white collar
    choice25((choice~=1)&(choice~=2)&(choice~=3)&(in_grad_school==1)&(grad_4yr==1)&(workPT==1)&(whiteCollar==0)) = 23; % grad school PT, blue collar
    choice25((choice~=1)&(choice~=2)&(choice~=3)&(in_grad_school==1)&(grad_4yr==1)&(workPT==1)&(whiteCollar==1)) = 24; % grad school PT, white collar
    choice25((choice~=1)&(choice~=2)&(choice~=3)&(in_grad_school==1)&(grad_4yr==1)&(workFT==0)&(workPT==0))      = 25; % grad school no work
    %% Initiate the choice25 vector
    choice20 = nan(size(choice));
    choice20(choice==1)                                                                                          = -1; % HS
    choice20((choice==2)&(workFTschool==1)&(whiteCollar==0))                                                     = 1;  % 2yr FT, blue collar
    choice20((choice==2)&(workFTschool==1)&(whiteCollar==1))                                                     = 2;  % 2yr FT, white collar
    choice20((choice==2)&(workPTschool==1)&(whiteCollar==0))                                                     = 3;  % 2yr PT, blue collar
    choice20((choice==2)&(workPTschool==1)&(whiteCollar==1))                                                     = 4;  % 2yr PT, white collar
    choice20((choice==2)&(workFTschool==0)&(workPTschool==0))                                                    = 5;  % 2yr no work
    choice20((choice==3)&(scienceMajor==1)&(workFTschool==1)&(whiteCollar==0))                                   = 6;  % 4yr science FT, blue collar
    choice20((choice==3)&(scienceMajor==1)&(workFTschool==1)&(whiteCollar==1))                                   = 7;  % 4yr science FT, white collar
    choice20((choice==3)&(scienceMajor==1)&(workPTschool==1)&(whiteCollar==0))                                   = 8;  % 4yr science PT, blue collar
    choice20((choice==3)&(scienceMajor==1)&(workPTschool==1)&(whiteCollar==1))                                   = 9;  % 4yr science PT, white collar
    choice20((choice==3)&(scienceMajor==1)&(workFTschool==0)&(workPTschool==0))                                  = 10; % 4yr science no work
    choice20((choice==3)&(otherMajor  ==1)&(workFTschool==1)&(whiteCollar==0))                                   = 11; % 4yr non-science FT, blue collar
    choice20((choice==3)&(otherMajor  ==1)&(workFTschool==1)&(whiteCollar==1))                                   = 12; % 4yr non-science FT, white collar
    choice20((choice==3)&(otherMajor  ==1)&(workPTschool==1)&(whiteCollar==0))                                   = 13; % 4yr non-science PT, blue collar
    choice20((choice==3)&(otherMajor  ==1)&(workPTschool==1)&(whiteCollar==1))                                   = 14; % 4yr non-science PT, white collar
    choice20((choice==3)&(otherMajor  ==1)&(workFTschool==0)&(workPTschool==0))                                  = 15; % 4yr non-science no work
    choice20((choice~=1)&(choice~=2)&(choice~=3)&(workPT==1)&(whiteCollar==0))                                   = 16; % work PT, blue collar
    choice20((choice~=1)&(choice~=2)&(choice~=3)&(workPT==1)&(whiteCollar==1))                                   = 17; % work PT, white collar
    choice20((choice~=1)&(choice~=2)&(choice~=3)&(workFT==1)&(whiteCollar==0))                                   = 18; % work FT, blue collar
    choice20((choice~=1)&(choice~=2)&(choice~=3)&(workFT==1)&(whiteCollar==1))                                   = 19; % work FT, white collar
    choice20((choice~=1)&(choice~=2)&(choice~=3)&(workPT==0)&(workFT==0))                                        = 20; % home
    crosstab(choice25(:),choice20(:))
    %% Generate dummy for unobserved wages (contingent on choice)
    bad_wages = isnan(log_wage) & (choice9==1 | choice9==2 | choice9==4 | choice9==5 | choice9==7 | choice9==8);
    IDtemp = 1:length(ID);
    for i=1:max(IDtemp);
        for t=2:size(choice,2)-1
            if bad_wages(i,t-1)==1
                bad_wages(i,t)   = bad_wages(i,t-1);
            end
        end
    end
    bad_wages(:,end) = bad_wages(:,end-1) | bad_wages(:,end);
    %% Drop missing GPA after first missing occurrence
    miss_grades = isnan(grades) & (choice==2 | choice==3);
    num_miss_grades = sum(miss_grades,2);
    bad_grades = cumsum(miss_grades,2)>=2;
    %% Check a few IDs
    disp('ID 1030');
    [miss_grades(ID==1030,:); bad_grades(ID==1030,:); miss_major(ID==1030,:); bad_major(ID==1030,:); anyFlag(ID==1030,:); choice20(ID==1030,:); choice20(ID==1030,:); grades(ID==1030,:)]
    disp('ID 1654');
    [miss_grades(ID==1654,:); bad_grades(ID==1654,:); miss_major(ID==1654,:); bad_major(ID==1654,:); anyFlag(ID==1654,:); choice20(ID==1654,:); choice20(ID==1654,:); grades(ID==1654,:)]
    disp('ID 4636');
    [miss_grades(ID==4636,:); bad_grades(ID==4636,:); miss_major(ID==4636,:); bad_major(ID==4636,:); anyFlag(ID==4636,:); choice20(ID==4636,:); choice20(ID==4636,:); grades(ID==4636,:)]
    disp('ID 2508');
    [miss_grades(ID==2508,:); bad_grades(ID==2508,:); miss_major(ID==2508,:); bad_major(ID==2508,:); anyFlag(ID==2508,:); choice20(ID==2508,:); choice20(ID==2508,:); grades(ID==2508,:)]
    disp('ID 31');
    [miss_grades(ID==  31,:); bad_grades(ID==  31,:); miss_major(ID==  31,:); bad_major(ID==  31,:); anyFlag(ID==  31,:); choice20(ID==  31,:); choice20(ID==  31,:); grades(ID==  31,:)]
    disp('ID 113');
    [miss_grades(ID== 113,:); bad_grades(ID== 113,:); miss_major(ID== 113,:); bad_major(ID== 113,:); anyFlag(ID== 113,:); choice20(ID== 113,:); choice20(ID== 113,:); grades(ID== 113,:)]
    disp('ID 5084');
    [miss_grades(ID==5084,:); bad_grades(ID==5084,:); miss_major(ID==5084,:); bad_major(ID==5084,:); anyFlag(ID==5084,:); choice20(ID==5084,:); choice20(ID==5084,:); grades(ID==5084,:)]
    disp('ID 7839');
    [miss_grades(ID==7839,:); bad_grades(ID==7839,:); miss_major(ID==7839,:); bad_major(ID==7839,:); anyFlag(ID==7839,:); choice20(ID==7839,:); choice20(ID==7839,:); grades(ID==7839,:)]
    %% To identify problems with grad_4yr variable:
    BA_yearw  = BA_year*ones(1,size(choice,2));
    BA_monthw = BA_month*ones(1,size(choice,2));
    BA_yearlp = kron(BA_year,ones(size(choice,2),1));
    BA_yearl  = kron(ones(S,1),BA_yearlp);
    %% flag obs where people went to 4-year college after graduating 4-year college
    ret_aft_grad0 = (year>BA_yearw) & ~in_grad_school & (choice20<16); % & (BA_monthw<10)
    ret_aft_grad  = ret_aft_grad0;
    for i=1:size(choice,1)
        for t=2:size(choice,2)-1
            if ret_aft_grad(i,t-1)==1
                ret_aft_grad(i,t)   = ret_aft_grad(i,t-1);
            end
        end
    end
    ret_aft_grad(:,end) = ret_aft_grad(:,end-1) | ret_aft_grad(:,end);
    %% Assess sample selection of missing majors, missing wages, missing grades, etc.
    IDtest = ID*ones(1,size(choice,2));
    % starting sample
    disp('starting sample');
    sum(sum(anyFlag==0))
    numel(unique(IDtest(anyFlag==0)))
    inSample = any(anyFlag==0,2);
    sum(inSample)
    % drop missing majors
    disp('drop missing majors');
    sum(sum(anyFlag==0 & bad_major==0))
    numel(unique(IDtest(anyFlag==0 & bad_major==0)))
    inSample = any(anyFlag==0 & bad_major==0,2);
    sum(inSample)
    % drop missing wages
    disp('drop missing wages');
    sum(sum(anyFlag==0 & bad_major==0 & bad_wages==0))
    numel(unique(IDtest(anyFlag==0 & bad_major==0 & bad_wages==0)))
    inSample = any(anyFlag==0 & bad_major==0 & bad_wages==0,2);
    sum(inSample)
    % drop missing grades
    disp('drop missing grades');
    sum(sum(anyFlag==0 & bad_major==0 & bad_wages==0 & bad_grades==0))
    numel(unique(IDtest(anyFlag==0 & bad_major==0 & bad_wages==0 & bad_grades==0)))
    inSample = any(anyFlag==0 & bad_major==0 & bad_wages==0 & bad_grades==0,2);
    sum(inSample)
    % drop those returning after graduation
    disp('drop post-college returners');
    sum(sum(anyFlag==0 & bad_major==0 & bad_wages==0 & bad_grades==0 & ret_aft_grad==0))
    numel(unique(IDtest(anyFlag==0 & bad_major==0 & bad_wages==0 & bad_grades==0 & ret_aft_grad==0)))
    inSample = any(anyFlag==0 & bad_major==0 & bad_wages==0 & bad_grades==0 & ret_aft_grad==0,2);
    sum(inSample)
    %% drop bad majors, bad wages, missing grades after year 2, and post-graduation returners
    anyFlag = anyFlag | bad_major | bad_wages | bad_grades | ret_aft_grad;
    %% create dummy for "has imputed major" or "has imputed GPA" or "has imputed both"
    everImpMaj    = any(isnan(choice20) & ~miss_grades & ~anyFlag,2);
    everImpGPA    = any(miss_grades & ~isnan(choice20) & ~anyFlag,2);
    everImpMajGPA = any(isnan(choice20) & miss_grades & ~anyFlag,2) | (everImpMaj & everImpGPA);
    everImpMaj    = any(isnan(choice20) & ~miss_grades & ~anyFlag,2) & ~everImpMajGPA;
    everImpGPA    = any(miss_grades & ~isnan(choice20) & ~anyFlag,2) & ~everImpMajGPA;
    impMaj        = logical(everImpMaj*ones(1,size(choice20,2)));
    impGPA        = logical(everImpGPA*ones(1,size(choice20,2)));
    impMajGPA     = logical(everImpMajGPA*ones(1,size(choice20,2)));
    impMajlp      = reshape(impMaj',numel(impMaj),1);
    impGPAlp      = reshape(impGPA',numel(impGPA),1);
    impMajGPAlp   = reshape(impMajGPA',numel(impMajGPA),1);
    NimpMaj       = sum(everImpMaj);
    NimpGPA       = sum(everImpGPA);
    NimpMajGPA    = sum(everImpMajGPA);
    %% Double check that these flags are indeed mutually exclusive (the result should be an empty matrix if things are correctly set up)
    disp('Double checking that imp flags are mutually exclusive (result should be an empty matrix):');
    discount_double_check = ID(everImpMaj & everImpGPA)
    %% Create a flag for "ever in sample" to correctly z-score HS grades (later on in code)
    everInSample  = any(anyFlag==0,2) | everImpMaj | everImpGPA | everImpMajGPA;
    sum(everInSample)
    %% Generate lagged choice dummies 
    prev2_HS           = zeros(size(choice));
    prev_HS            = zeros(size(choice));
    prev_2yr           = zeros(size(choice));
    prev_4yr           = zeros(size(choice));
    prev_4yrS          = zeros(size(choice));
    prev_4yrNS         = zeros(size(choice));
    prev_PT            = zeros(size(choice));
    prev_FT            = zeros(size(choice));
    prev_home          = zeros(size(choice));
    prev_WC            = zeros(size(choice));
    prev_BC            = zeros(size(choice));
    prev_miss_grades   = zeros(size(choice));
    prev_miss_major    = zeros(size(choice));
    collegesum         = zeros(size(choice));
    for t=2:size(choice,2)
        prev_HS(:,t)            = (choice9(:,t-1)==-1);
        prev_2yr(:,t)           = (choice9(:,t-1)>0 & choice9(:,t-1)<4);
        prev_4yr(:,t)           = ((choice9(:,t-1)>3)&(choice9(:,t-1)<7));
        prev_4yrS(:,t)          = ((choice20(:,t-1)>5)&(choice20(:,t-1)<11));
        prev_4yrNS(:,t)         = ((choice20(:,t-1)>10)&(choice20(:,t-1)<16));
        prev_PT(:,t)            = ((choice9(:,t-1)==2)|(choice9(:,t-1)==5)|(choice9(:,t-1)==7));
        prev_FT(:,t)            = ((choice9(:,t-1)==1)|(choice9(:,t-1)==4)|(choice9(:,t-1)==8));
        prev_home(:,t)          = (choice9(:,t-1)==9);
        prev_WC(:,t)            = (whiteCollar(:,t-1)==1 & (ismember(choice9(:,t-1),[1 2 4 5 7 8])));
        prev_BC(:,t)            = (whiteCollar(:,t-1)==0 & (ismember(choice9(:,t-1),[1 2 4 5 7 8])));
        prev_miss_grades(:,t)   = (miss_grades(:,t-1)==1);
        prev_miss_major(:,t)    = (miss_major(:,t-1)==1);
    end
    for t=3:size(choice,2)
        prev2_HS(:,t) = (choice9(:,t-2)==-1);
    end
    if any(any((prev_HS+prev_PT)>1))
        error('problem with choice variable specification!')
    end
    %% Generate dummy for graduation from 4yr college next period
    grad_4yr_next_yr = zeros(size(choice));
    grad_2yr_next_yr = zeros(size(choice));
    for t=1:size(choice,2)-1
        grad_4yr_next_yr(:,t)   = (grad_4yr(:,t+1)==1);
        grad_2yr_next_yr(:,t)   = (grad_2yr(:,t+1)==1);
    end
    ever_grad_sch   = max(in_grad_school')';
    %% Generate experience variables
    exper              = cumsum((1*prev_FT+.5*prev_PT)                  ,2);
    exper_pregrad      = cumsum((1*prev_FT+.5*prev_PT).*(grad_4yr==0)   ,2);
    exper_postgrad     = cumsum((1*prev_FT+.5*prev_PT).*(grad_4yr==1)   ,2);
    exper_blue_collar  = cumsum((1*prev_FT.*prev_BC+.5*prev_PT.*prev_BC),2);
    exper_white_collar = cumsum((1*prev_FT.*prev_WC+.5*prev_PT.*prev_WC),2);
    exper_inschool     = cumsum((1*prev_FT.*(prev_2yr|prev_4yr)+.5*prev_PT.*(prev_2yr|prev_4yr)).*(grad_4yr==0),2);
    cum_miss_grades    = cumsum(miss_grades,2);
    cum_miss_major     = cumsum(miss_major ,2);
    tabulate(choice12((grad_4yr==0)&(anyFlag==0)))
    tabulate(choice12((grad_4yr==1)&(anyFlag==0)))
    tabulate(choice20((grad_4yr==0)&(anyFlag==0)))
    tabulate(choice20((grad_4yr==1)&(anyFlag==0)))
    cum_2yr   = cumsum(prev_2yr,2);
    cum_4yr   = cumsum(prev_4yr,2);
    cum_4yrS  = cumsum(prev_4yrS ,2);
    cum_4yrNS = cumsum(prev_4yrNS,2);
    %% Generate years since started college
    in_college = choice9>0 & choice9<7;
    cum_yrs_col_pre = cumsum(in_college,2); 
    cum_yrs_col_pre = (cum_yrs_col_pre==1);
    timepd = ones(size(choice9,1),1)*[1:size(choice9,2)];
    cum1 = in_college.*timepd.*cum_yrs_col_pre;
    yrs_since_school = cumsum(cumsum(timepd==cum1,2),2);
    in_college(1:5,:)
    yrs_since_school(1:5,:)
    %% Generate years since finished HS
    temp_per = cumsum(anyFlag==0,2);
    yrsSinceHS = cumsum(temp_per>0,2);
    yrsSinceHS(yrsSinceHS>0) = yrsSinceHS(yrsSinceHS>0)-1; % so that first period will be 0
    disp('Printing out 40 rows each of choice9, temp_per and yrsSinceHS');
    choice9(1:40,1:13)
    temp_per(1:40,1:13)
    yrsSinceHS(1:40,1:13)
    %% replace NaNs in the covariates with zeros (they will still be flagged so that they are not included)
    AFQT(isnan(AFQT))                     = 0;
    ASVABmath(isnan(ASVABmath))           = 0;
    ASVABverb(isnan(ASVABverb))           = 0;
    %SATmath(isnan(SATmath))           = 0;
    %SATverb(isnan(SATverb))           = 0;
    Grades_HS_best = (Grades_HS_best-nanmean(Grades_HS_best(everInSample)))./nanstd(Grades_HS_best(everInSample));
    Grades_HS_best(isnan(Grades_HS_best)) = 0;
    % grades(grades==0)                     = eps; % to differentiate a GPA of zero from the case of no school attendance (a mechanical 0) 
    %% Generate completion category variables (truncated folks are included as if they aren't truncated)
    never_college = max(choice12'>0 & choice12'<10)'==0;
    SO            = (((cum_2yr'+cum_4yr')>0) & prev_2yr'==0 & prev_4yr'==0 & choice9'>0 & choice9'<7)';
    ever_SO       = max(SO')';
    DO            = (repmat(~ever_SO' & ~never_college',size(choice,2),1) & (prev_2yr' | prev_4yr') & choice12'>9 & grad_4yr'==0)';
    ever_DO       = max(repmat(~ever_SO' & ~never_college',size(choice,2),1) & (prev_2yr' | prev_4yr') & choice12'>9 & grad_4yr'==0)';
    ever_grad_4yr = max(grad_4yr')';
    ever_work_sch = max(choice12'==1 | choice12'==2 | choice12'==4 | choice12'==5 | choice12'==7 | choice12'==8)';
    ever_CC       = ~never_college & ~ever_SO & ~ever_DO;
    ever_2yr      = max(choice12'>0 & choice12'<4)';
    choicePath    = zeros(size(ever_SO));
    choicePathnew = zeros(size(ever_SO));
    choicePathnew(ever_CC & ~ever_work_sch)                                           = 1;
    choicePathnew(ever_CC &  ever_work_sch)                                           = 2;
    choicePathnew(ever_SO &  (ever_grad_4yr | (choice9(:,end)>0 & choice9(:,end)<7))) = 3; %impute truncated folks according to last-period decision
    choicePathnew(ever_SO & ~(ever_grad_4yr | (choice9(:,end)>0 & choice9(:,end)<7))) = 4; %impute truncated folks according to last-period decision
    choicePathnew(ever_DO)                                                            = 5;
    choicePathnew(never_college)                                                      = 6;
    choicePathnew(anyFlag(:,end))                                                     = 7;
    choicePath(CC_DO_SO==1 & ~ever_work_sch &  finalMajorSci==1)                      = 1; % CC no work 4yr sci
    choicePath(CC_DO_SO==1 &  ever_work_sch &  finalMajorSci==1)                      = 2; % CC work 4yr sci
    % choicePath(CC_DO_SO==1 &  finalMajorSci==1)                                     = 3; % CC 4yr sci
    choicePath(CC_DO_SO==1 & ~ever_work_sch &  finalMajorSci==0)                      = 4; % CC no work 4yr hum
    choicePath(CC_DO_SO==1 &  ever_work_sch &  finalMajorSci==0)                      = 5; % CC work 4yr hum
    % choicePath(CC_DO_SO==1 &  finalMajorSci==0)                                     = 6; % CC 4yr hum
    choicePath(CC_DO_SO==1 & ~ever_work_sch & isnan(BA_year))                         = 7; % CC no work 2yr
    choicePath(CC_DO_SO==1 &  ever_work_sch & isnan(BA_year))                         = 8; % CC work 2yr
    % choicePath(CC_DO_SO==1 &  isnan(BA_year))                                       = 9; % CC 2yr (i.e. never went to 4yr)
    choicePath(CC_DO_SO==2 &  finalMajorSci)                                          = 10; % SO grad sci
    choicePath(CC_DO_SO==2 & ~finalMajorSci)                                          = 11; % SO grad hum
    choicePath(CC_DO_SO==3 )                                                          = 12;
    choicePath(CC_DO_SO==4 )                                                          = 13;
    choicePath(never_college)                                                         = 14;
    choicePath(anyFlag(:,end) | choicePath==0)                                        = 15;
    choicePathImpGPA = [choicePath(~everImpGPA,:);choicePath(everImpGPA,:);choicePath(everImpGPA,:)];

    %% Make time-invariant versions of background characteristics for use in measurement system
    birthYrw        = 1979-age(:,1);
    hispanicw       = hispanic;
    blackw          = black;
    Parent_collegew = Parent_college;
    famIncw         = FamIncAsTeen./10; % now in $10k (instead of $1k)
    efc             = efc./10000; % now in $10k (instead of $)
    efcw            = efc;
    SATmathw        = SATmath;
    SATverbw        = SATverb;
    predSATmathZw   = predSATmathZ;
    predSATverbZw   = predSATverbZ;

    %% Make usable categories for discrete measurement outcomes
    numAPs1  = 1*(numAPs==0) + 2*(numAPs==1) + 3*(numAPs>=2);
    numAPs1(isnan(numAPs)) = NaN;
    numAPs   = numAPs1;

    lateNoExcuse1  = 1*(lateForSchoolNoExcuse==0) + 2*(lateForSchoolNoExcuse==1) + 3*(lateForSchoolNoExcuse==2) + 4*(lateForSchoolNoExcuse==3) + 5*(lateForSchoolNoExcuse==4) + 6*(lateForSchoolNoExcuse==5) + 7*(lateForSchoolNoExcuse>=6 & lateForSchoolNoExcuse<=10) + 8*(lateForSchoolNoExcuse>=11);
    lateNoExcuse1(isnan(lateForSchoolNoExcuse)) = NaN;
    lateForSchoolNoExcuse = lateNoExcuse1;

    HrsExtraClass(HrsExtraClass==0) = 0.1;
    lnHrsExtraClass = log(HrsExtraClass);

    reasonTookClassDuringBreak1 = 1*ismember(reasonTookClassDuringBreak,[1,3,4]) + 2*ismember(reasonTookClassDuringBreak,[2,5,6,7]);
    reasonTookClassDuringBreak1(isnan(reasonTookClassDuringBreak)) = NaN;
    reasonTookClassDuringBreak  = reasonTookClassDuringBreak1;

    pctWork1  = 1*(pctChanceWork20Hrs30<=75) + 2*(pctChanceWork20Hrs30>75 & pctChanceWork20Hrs30<=90) + 3*(pctChanceWork20Hrs30>90);
    pctWork1(isnan(pctChanceWork20Hrs30)) = NaN;
    pctChanceWork20Hrs30 = pctWork1;

    parPctWork1  = 1*(parPctChanceWork20Hrs30<=75) + 2*(parPctChanceWork20Hrs30>75 & parPctChanceWork20Hrs30<=90) + 3*(parPctChanceWork20Hrs30>90);
    parPctWork1(isnan(parPctChanceWork20Hrs30)) = NaN;
    parPctChanceWork20Hrs30 = parPctWork1;

    %% Reshape variables into N*Tx1 form where first T observations are person 1, next T observations are person 2, etc.
    [N,T]          = size(choice);
    NLS_ID         = ID;
    ID             = [1:N]';
    IDlp           = kron(ID,ones(T,1));
    IDl            = kron(ones(S,1),IDlp);
    birthYr        = kron(birthYrw,ones(T,1));
    male           = kron(male             ,ones(T,1));
    black          = kron(black            ,ones(T,1));
    hispanic       = kron(hispanic         ,ones(T,1));
    Peduc          = kron(Peduc            ,ones(T,1));
    m_Peduc        = kron(m_Peduc          ,ones(T,1));
    Parent_college = kron(Parent_college   ,ones(T,1));
    m_famInc       = kron(m_FamIncAsTeen   ,ones(T,1));
    famInc         = kron(FamIncAsTeen     ,ones(T,1))./10;
    lnFamInc       = log(kron(FamIncAsTeen ,ones(T,1)));
    HS_grades      = kron(Grades_HS_best   ,ones(T,1));
    ASVABmath      = kron(ASVABmath        ,ones(T,1));
    ASVABverb      = kron(ASVABverb        ,ones(T,1));
    efc            = kron(efc              ,ones(T,1));
    SATmath        = kron(SATmath          ,ones(T,1));
    SATverb        = kron(SATverb          ,ones(T,1));
    predSATmathZ   = kron(predSATmathZ     ,ones(T,1));
    predSATverbZ   = kron(predSATverbZ     ,ones(T,1));
    tui4imp        = kron(tui4imp          ,ones(T,1));
    grant4pr       = kron(grant4pr         ,ones(T,1));
    loan4pr        = kron(loan4pr          ,ones(T,1));
    grant4RMSE     = kron(grant4RMSE       ,ones(T,1));
    loan4RMSE      = kron(loan4RMSE        ,ones(T,1));
    grant4idx      = kron(grant4idx        ,ones(T,1));
    loan4idx       = kron(loan4idx         ,ones(T,1));
    tui2imp        = kron(tui2imp          ,ones(T,1));
    grant2pr       = kron(grant2pr         ,ones(T,1));
    loan2pr        = kron(loan2pr          ,ones(T,1));
    grant2RMSE     = kron(grant2RMSE       ,ones(T,1));
    loan2RMSE      = kron(loan2RMSE        ,ones(T,1));
    grant2idx      = kron(grant2idx        ,ones(T,1));
    loan2idx       = kron(loan2idx         ,ones(T,1));
    ParTrans2RMSE  = kron(ParTrans2RMSE    ,ones(T,1));
    ParTrans4RMSE  = kron(ParTrans4RMSE    ,ones(T,1));
    E_loan2_18     = kron(E_loan2_18       ,ones(T,1));
    E_loan4_18     = kron(E_loan4_18       ,ones(T,1));
    AFQT           = kron(AFQT             ,ones(T,1));
    finalMajorSci  = kron(finalMajorSci    ,ones(T,1));

    grades              = reshape(grades'                    ,numel(grades                    ),1);
    choice20            = reshape(choice20'                  ,numel(choice20                  ),1);
    choice12            = reshape(choice12'                  ,numel(choice12                  ),1);
    choice9             = reshape(choice9'                   ,numel(choice9                   ),1);
    choice              = reshape(choice'                    ,numel(choice                    ),1);
    log_wage            = reshape(log_wage'                  ,numel(log_wage                  ),1);
    grades              = reshape(grades'                    ,numel(grades                    ),1);
    in_grad_school      = reshape(in_grad_school'            ,numel(in_grad_school            ),1);
    workPTschool        = reshape(workPTschool'              ,numel(workPTschool              ),1);
    workFTschool        = reshape(workFTschool'              ,numel(workFTschool              ),1);
    exper               = reshape(exper'                     ,numel(exper                     ),1);
    exper_postgrad      = reshape(exper_postgrad'            ,numel(exper_postgrad            ),1);
    exper_white_collar  = reshape(exper_white_collar'        ,numel(exper_white_collar        ),1);
    cum_2yr             = reshape(cum_2yr'                   ,numel(cum_2yr                   ),1);
    cum_4yr             = reshape(cum_4yr'                   ,numel(cum_4yr                   ),1);
    yrs_since_school    = reshape(yrs_since_school'          ,numel(yrs_since_school          ),1);
    cum_4yrS            = reshape(cum_4yrS'                  ,numel(cum_4yrS                  ),1);
    cum_4yrNS           = reshape(cum_4yrNS'                 ,numel(cum_4yrNS                 ),1);
    prev2_HS            = reshape(prev2_HS'                  ,numel(prev2_HS                  ),1);
    prev_HS             = reshape(prev_HS'                   ,numel(prev_HS                   ),1);
    prev_2yr            = reshape(prev_2yr'                  ,numel(prev_2yr                  ),1);
    prev_4yr            = reshape(prev_4yr'                  ,numel(prev_4yr                  ),1);
    prev_4yrS           = reshape(prev_4yrS'                 ,numel(prev_4yrS                 ),1);
    prev_4yrNS          = reshape(prev_4yrNS'                ,numel(prev_4yrNS                ),1);
    prev_PT             = reshape(prev_PT'                   ,numel(prev_PT                   ),1);
    prev_FT             = reshape(prev_FT'                   ,numel(prev_FT                   ),1);
    prev_WC             = reshape(prev_WC'                   ,numel(prev_WC                   ),1);
    prev_BC             = reshape(prev_BC'                   ,numel(prev_BC                   ),1);
    scienceMajor        = reshape(scienceMajor'              ,numel(scienceMajor              ),1);
    origSciMajor        = reshape(origSciMajor'              ,numel(origSciMajor              ),1);
    origHumMajor        = reshape(origHumMajor'              ,numel(origHumMajor              ),1);
    origMissMajor       = reshape(origMissMajor'             ,numel(origMissMajor             ),1);
    idxParTrans4        = reshape(idxParTrans4'              ,numel(idxParTrans4              ),1);
    idxParTrans2        = reshape(idxParTrans2'              ,numel(idxParTrans2              ),1);
    prParTrans4         = reshape(prParTrans4'               ,numel(prParTrans4               ),1);
    prParTrans2         = reshape(prParTrans2'               ,numel(prParTrans2               ),1);
    E_ParTrans4         = reshape(E_ParTrans4'               ,numel(E_ParTrans4               ),1);
    E_ParTrans2         = reshape(E_ParTrans2'               ,numel(E_ParTrans2               ),1);
    E_ParTrans4         = E_ParTrans4./10000;
    E_ParTrans2         = E_ParTrans2./10000;
    age                 = reshape(age'                       ,numel(age                       ),1);
    yrsSinceHS          = reshape(yrsSinceHS'                ,numel(yrsSinceHS                ),1);
    year                = reshape(year'                      ,numel(year                      ),1);
    grad_4yr            = reshape(grad_4yr'                  ,numel(grad_4yr                  ),1);
    grad_4yr_next_yr    = reshape(grad_4yr_next_yr'          ,numel(grad_4yr_next_yr          ),1);
    grad_2yr            = reshape(grad_2yr'                  ,numel(grad_2yr                  ),1);
    grad_2yr_next_yr    = reshape(grad_2yr_next_yr'          ,numel(grad_2yr_next_yr          ),1);
    firstCol2yr         = reshape(firstCol2yr'               ,numel(firstCol2yr               ),1);
    firstCol4yr         = reshape(firstCol4yr'               ,numel(firstCol4yr               ),1);
    miss_major          = reshape(miss_major'                ,numel(miss_major                ),1);
    cum_miss_major      = reshape(cum_miss_major'            ,numel(cum_miss_major            ),1);
    firstGrades         = reshape(firstGrades'               ,numel(firstGrades               ),1);
    cum_miss_grades     = reshape(cum_miss_grades'           ,numel(cum_miss_grades           ),1);
    miss_grades         = reshape(miss_grades'               ,numel(miss_grades               ),1);
    good_grades         = reshape(~bad_grades'               ,numel( bad_grades               ),1);
    black_2yr           = black             .*cum_2yr;
    black_4yr           = black             .*cum_4yr;
    black_exp           = black             .*exper;
    hispanic_2yr        = hispanic          .*cum_2yr;
    hispanic_4yr        = hispanic          .*cum_4yr;
    hispanic_exp        = hispanic          .*exper;
    male_2yr            = male              .*cum_2yr;
    male_4yr            = male              .*cum_4yr;
    male_exp            = male              .*exper;
    ASVABmath2          = ASVABmath         .^2;
    ASVABverb2          = ASVABverb         .^2;
    SATmath2            = SATmath           .^2;
    SATverb2            = SATverb           .^2;
    AFQT2               = AFQT              .^2;
    cum_2yr2            = cum_2yr           .^2;
    cum_4yr2            = cum_4yr           .^2;
    exper2              = exper             .^2;
    age2                = age               .^2;
    exper_postgrad2     = exper_postgrad    .^2;
    exper_white_collar2 = exper_white_collar.^2;
    period              = cumsum(anyFlag==0,2);
    period              = reshape(period',numel(period),1);
    anyFlag             = reshape(anyFlag',numel(anyFlag),1);
    timeperiod          = kron(ones(N,1),[1:T]');

    % make sure that college graduates have the experience profiles of 4+ year college completers
    cum_sch = (1-grad_4yr).*min(cum_2yr+cum_4yr,4) + 4.*grad_4yr;
    
    % full- and part-time work
    workFT = (choice9==1 | choice9==4 | choice9==8 ); 
    workPT = (choice9==2 | choice9==5 | choice9==7 );

    scienceMajor(isnan(scienceMajor)) = 0;
    origSciMajor(isnan(origSciMajor)) = 0;
    origHumMajor(isnan(origHumMajor)) = 0;
    choice                            = choice20;
    choice(miss_major)                = -1;
    choice(anyFlag)                   = 0;
    NT                                = length(choice);
    %% Stack the data: first those with no missing GPAs or majors, then those with missing GPAs but no missing majors; then those with missing major but no GPA (as if science); then those with both missing major and GPA (as if science); then those with missing major but no GPA (as if humanities); then those with both missing major and GPA (as if humanities);
    yrclp             = reshape(yrc',N*T,1);
    yrcl              = kron(ones(S,1),yrclp);
    yearl             = kron(ones(S,1),year);
    gradeslp          = grades;
    gradesl           = kron(ones(S,1),gradeslp);
    wagesl            = kron(ones(S,1),log_wage);
    Clp               = choice;
    Cl                = kron(ones(S,1),Clp);
    in_collegel       = ismember(Cl,[-1 1:15]);
    in_2yrl           = ismember(Cl, 1:5);
    in_4yrl           = ismember(Cl,[-1 6:15]);
    in_scil           = ismember(Cl, 6:10);
    in_huml           = ismember(Cl,11:15);
    in_workl          = ismember(Cl,[1:4 6:9 11:14 16:19]);
    in_PTl            = ismember(Cl,[3:4 8:9 13:14 16:17]);
    in_FTl            = ismember(Cl,[1:2 6:7 11:12 18:19]);
    in_WCl            = ismember(Cl,[2 4 7 9 12 14 17 19]);
    in_BCl            = ismember(Cl,[1 3 6 8 11 13 16 18]);
    in_college        = ismember(Clp,[-1 1:15]);
    in_2yr            = ismember(Clp, 1:5);
    in_4yr            = ismember(Clp,[-1 6:15]);
    in_sci            = ismember(Clp, 6:10);
    in_hum            = ismember(Clp,11:15);
    in_work           = ismember(Clp,[1:4 6:9 11:14 16:19]);
    in_PT             = ismember(Clp,[3:4 8:9 13:14 16:17]);
    in_FT             = ismember(Clp,[1:2 6:7 11:12 18:19]);
    in_WC             = ismember(Clp,[2 4 7 9 12 14 17 19]);
    in_BC             = ismember(Clp,[1 3 6 8 11 13 16 18]);
    IDl               = kron(ones(S,1),IDlp);
    periodl           = kron(ones(S,1),period);
    cum_2yrl          = kron(ones(S,1),cum_2yr);
    cum_4yrl          = kron(ones(S,1),cum_4yr);
    cum_schl          = kron(ones(S,1),cum_4yr);
    grad_4yrl         = kron(ones(S,1),grad_4yr);
    grad_4yr_next_yrl = kron(ones(S,1),grad_4yr_next_yr);
    grad_2yrl         = kron(ones(S,1),grad_2yr);
    grad_2yr_next_yrl = kron(ones(S,1),grad_2yr_next_yr);
    anyFlagl          = kron(ones(S,1),anyFlag);
    
    choiceData = v2struct(N, T, NLS_ID, ID, IDlp, IDl, male, black, hispanic, ...
                          Parent_college, m_famInc, famInc, lnFamInc, birthYr, ...
                          HS_grades, finalMajorSci, efc, tui4imp, grant4pr, ...
                          loan4pr, grant4RMSE, loan4RMSE, grant4idx, loan4idx, ...
                          tui2imp, grant2pr, loan2pr, grant2RMSE, loan2RMSE, ...
                          grant2idx, loan2idx, ParTrans2RMSE, ParTrans4RMSE, ...
                          E_loan4_18, E_loan2_18, log_wage, grades, wagesl, ...
                          gradesl, workPTschool, workFTschool, exper, ...
                          exper_postgrad, exper_white_collar, cum_2yr, cum_4yr, ...
                          cum_sch, cum_4yrS, cum_4yrNS, yrs_since_school, ...
                          yrsSinceHS, prev2_HS, prev_HS, prev_2yr, prev_4yr, ...
                          prev_4yrS, prev_4yrNS, prev_PT, prev_FT, prev_WC, ...
                          prev_BC, scienceMajor, origSciMajor, origHumMajor, ...
                          origMissMajor, age, idxParTrans4, idxParTrans2, ...
                          prParTrans4, prParTrans2,E_ParTrans4, E_ParTrans2, ...
                          year, grad_4yr, grad_4yr_next_yr, grad_2yr, ...
                          grad_2yr_next_yr, firstCol2yr, firstCol4yr, ...
                          miss_major, miss_grades, cum_miss_grades, good_grades, ...
                          cum_miss_major, period, anyFlag, timeperiod, ...
                          workFT, workPT, scienceMajor, origSciMajor, ...
                          origHumMajor, choice, NT, yrclp, yrclp, yrcl, yrcl, ...
                          gradeslp, gradesl, Clp, Cl, ID, IDlp, IDl, periodl, ...
                          grad_4yr, grad_4yr_next_yr, grad_4yrl, grad_4yr_next_yrl, ...
                          grad_2yrl, grad_2yr_next_yrl, grad_2yr, grad_2yr_next_yr, ...
                          yearl, anyFlagl, cum_2yrl, cum_4yrl, cum_schl, ...
                          in_college, in_2yr, in_4yr, in_sci, in_hum, ...
                          in_work, in_FT, in_PT, in_WC, in_BC, ...
                          in_collegel, in_2yrl, in_4yrl, in_scil, in_huml, ...
                          in_workl, in_FTl, in_PTl, in_WCl, in_BCl);
end
