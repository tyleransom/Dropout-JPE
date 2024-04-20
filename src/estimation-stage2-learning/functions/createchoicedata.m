function [choiceData] = createchoicedata(fname,S,num_GPA_pctiles)
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
    asifhum.choice25 = choice25;
    asifhum.choice25(isnan(choice25) & choice9==4 & whiteCollar==0) = 11;
    asifhum.choice25(isnan(choice25) & choice9==4 & whiteCollar==1) = 12;
    asifhum.choice25(isnan(choice25) & choice9==5 & whiteCollar==0) = 13;
    asifhum.choice25(isnan(choice25) & choice9==5 & whiteCollar==1) = 14;
    asifhum.choice25(isnan(choice25) & choice9==6                 ) = 15;
    asifsci.choice25 = choice25;
    asifsci.choice25(isnan(choice25) & choice9==4 & whiteCollar==0) = 6;
    asifsci.choice25(isnan(choice25) & choice9==4 & whiteCollar==1) = 7;
    asifsci.choice25(isnan(choice25) & choice9==5 & whiteCollar==0) = 8;
    asifsci.choice25(isnan(choice25) & choice9==5 & whiteCollar==1) = 9;
    asifsci.choice25(isnan(choice25) & choice9==6                 ) = 10;
    jka6 = sum(sum(isnan(asifhum.choice25)))
    jka6 = sum(sum(isnan(asifsci.choice25)))
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
    %choice20((choice~=1)&(choice~=2)&(choice~=3)&(in_grad_school==1)&(grad_4yr==1)&(workFT==1)&(whiteCollar==0)) = 21; % grad school FT, blue collar
    %choice20((choice~=1)&(choice~=2)&(choice~=3)&(in_grad_school==1)&(grad_4yr==1)&(workFT==1)&(whiteCollar==1)) = 22; % grad school FT, white collar
    %choice20((choice~=1)&(choice~=2)&(choice~=3)&(in_grad_school==1)&(grad_4yr==1)&(workPT==1)&(whiteCollar==0)) = 23; % grad school PT, blue collar
    %choice20((choice~=1)&(choice~=2)&(choice~=3)&(in_grad_school==1)&(grad_4yr==1)&(workPT==1)&(whiteCollar==1)) = 24; % grad school PT, white collar
    %choice20((choice~=1)&(choice~=2)&(choice~=3)&(in_grad_school==1)&(grad_4yr==1)&(workFT==0)&(workPT==0))      = 25; % grad school no work
    asifhum.choice20 = choice20;
    asifhum.choice20(isnan(choice20) & choice9==4 & whiteCollar==0) = 11;
    asifhum.choice20(isnan(choice20) & choice9==4 & whiteCollar==1) = 12;
    asifhum.choice20(isnan(choice20) & choice9==5 & whiteCollar==0) = 13;
    asifhum.choice20(isnan(choice20) & choice9==5 & whiteCollar==1) = 14;
    asifhum.choice20(isnan(choice20) & choice9==6                 ) = 15;
    asifsci.choice20 = choice20;
    asifsci.choice20(isnan(choice20) & choice9==4 & whiteCollar==0) = 6;
    asifsci.choice20(isnan(choice20) & choice9==4 & whiteCollar==1) = 7;
    asifsci.choice20(isnan(choice20) & choice9==5 & whiteCollar==0) = 8;
    asifsci.choice20(isnan(choice20) & choice9==5 & whiteCollar==1) = 9;
    asifsci.choice20(isnan(choice20) & choice9==6                 ) = 10;
    jka6 = sum(sum(isnan(asifhum.choice20)))
    jka6 = sum(sum(isnan(asifsci.choice20)))
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
    %% Create counterfactual grades deciles
    num_GPA_grid_points = 3;
    if num_GPA_pctiles==10
        pctilemat = [1;2.25;2.6;2.8;2.95;3.1;3.3;3.5;3.7;3.9];
        cutmat    = [0;2;2.5;2.7;2.9;3;3.2;3.4;3.6;3.8;4];
    elseif num_GPA_pctiles==2
        pctilemat = [1.5;3.5];
        cutmat    = [0;3;4];
    elseif num_GPA_pctiles==4
        pctilemat = [1.25;2.75;3.3;3.8;];
        cutmat    = [0;2.5;3;3.6;4];
    end
    gradestensor = repmat(grades,[1 1 num_GPA_pctiles]);
    for pct = 1:num_GPA_pctiles
        for i=1:size(choice,1)
            for t=1:size(choice,2)
                if miss_grades(i,t) & ~bad_grades(i,t)
                    gradestensor(i,t,pct) = pctilemat(pct);
                end
            end
        end
    end
    gradesnumbers = nan(size(choice,1),size(choice,2));
    for i=1:size(choice,1)
        for t=1:size(choice,2)
            gradesnumbers(i,t) = t+100*i;
        end
    end
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
    asifhum.prev_4yrS  = zeros(size(choice));
    asifhum.prev_4yrNS = zeros(size(choice));
    asifsci.prev_4yrS  = zeros(size(choice));
    asifsci.prev_4yrNS = zeros(size(choice));
    prev_PT            = zeros(size(choice));
    prev_FT            = zeros(size(choice));
    prev_home          = zeros(size(choice));
    prev_WC            = zeros(size(choice));
    prev_BC            = zeros(size(choice));
    collegesum         = zeros(size(choice));
    for t=2:size(choice,2)
        prev_HS(:,t)            = (choice9(:,t-1)==-1);
        prev_2yr(:,t)           = (choice9(:,t-1)>0 & choice9(:,t-1)<4);
        prev_4yr(:,t)           = ((choice9(:,t-1)>3)&(choice9(:,t-1)<7));
        prev_4yrS(:,t)          = ((choice20(:,t-1)>5)&(choice20(:,t-1)<11));
        prev_4yrNS(:,t)         = ((choice20(:,t-1)>10)&(choice20(:,t-1)<16));
        asifhum.prev_4yrS(:,t)  = ((asifhum.choice20(:,t-1)>5)&(asifhum.choice20(:,t-1)<11));
        asifhum.prev_4yrNS(:,t) = ((asifhum.choice20(:,t-1)>10)&(asifhum.choice20(:,t-1)<16));
        asifsci.prev_4yrS(:,t)  = ((asifsci.choice20(:,t-1)>5)&(asifsci.choice20(:,t-1)<11));
        asifsci.prev_4yrNS(:,t) = ((asifsci.choice20(:,t-1)>10)&(asifsci.choice20(:,t-1)<16));
        prev_PT(:,t)            = ((choice9(:,t-1)==2)|(choice9(:,t-1)==5)|(choice9(:,t-1)==7));
        prev_FT(:,t)            = ((choice9(:,t-1)==1)|(choice9(:,t-1)==4)|(choice9(:,t-1)==8));
        prev_home(:,t)          = (choice9(:,t-1)==9);
        prev_WC(:,t)            = (whiteCollar(:,t-1)==1 & (ismember(choice9(:,t-1),[1 2 4 5 7 8])));
        prev_BC(:,t)            = (whiteCollar(:,t-1)==0 & (ismember(choice9(:,t-1),[1 2 4 5 7 8])));
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
    exper_inschool = cumsum((1*prev_FT.*(prev_2yr|prev_4yr)+.5*prev_PT.*(prev_2yr|prev_4yr)).*(grad_4yr==0),2);
    tabulate(choice12((grad_4yr==0)&(anyFlag==0)))
    tabulate(choice12((grad_4yr==1)&(anyFlag==0)))
    tabulate(choice20((grad_4yr==0)&(anyFlag==0)))
    tabulate(choice20((grad_4yr==1)&(anyFlag==0)))
    cum_2yr   = cumsum(prev_2yr,2);
    cum_4yr   = cumsum(prev_4yr,2);
    cum_4yrS  = cumsum(prev_4yrS ,2);
    cum_4yrNS = cumsum(prev_4yrNS,2);
    asifhum.cum_4yrS  = cumsum(asifhum.prev_4yrS ,2);
    asifhum.cum_4yrNS = cumsum(asifhum.prev_4yrNS,2);
    asifsci.cum_4yrS  = cumsum(asifsci.prev_4yrS ,2);
    asifsci.cum_4yrNS = cumsum(asifsci.prev_4yrNS,2);
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
    baseN          = N-NimpMaj-NimpGPA-NimpMajGPA;
    Ntilde         = baseN+2*NimpMaj+num_GPA_pctiles*NimpGPA+2*num_GPA_pctiles*NimpMajGPA;
    Ntilde1        = baseN + num_GPA_pctiles*NimpGPA;      % range of IDs for whom major is observed but GPA is not
    Ntilde2        = Ntilde1 + NimpMaj;                    % range of IDs for whom GPA is observed but major is not (as if science major)
    Ntilde3        = Ntilde2 + num_GPA_pctiles*NimpMajGPA; % range of IDs for whom neither major nor GPA is observed (as if science major)
    Ntilde4        = Ntilde3 + NimpMaj;                    % range of IDs for whom GPA is observed but major is not (as if humanities major)
    Ntilde5        = Ntilde4 + num_GPA_pctiles*NimpMajGPA; % range of IDs for whom neither major nor GPA is observed (as if humanities major)
    NtildeGrid     = baseN+2*NimpMaj+num_GPA_pctiles*num_GPA_grid_points*NimpGPA+2*num_GPA_pctiles*num_GPA_grid_points*NimpMajGPA;
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

    choice20            = reshape(choice20'                  ,numel(choice20                  ),1);
    asifhum.choice20    = reshape(asifhum.choice20'          ,numel(asifhum.choice20          ),1);
    asifsci.choice20    = reshape(asifsci.choice20'          ,numel(asifsci.choice20          ),1);
    choice12            = reshape(choice12'                  ,numel(choice12                  ),1);
    choice9             = reshape(choice9'                   ,numel(choice9                   ),1);
    choice              = reshape(choice'                    ,numel(choice                    ),1);
    log_wage            = reshape(log_wage'                  ,numel(log_wage                  ),1);
    grades              = reshape(grades'                    ,numel(grades                    ),1);
    gradesnumbers       = reshape(gradesnumbers'             ,numel(gradesnumbers             ),1);
    gradestensor        = reshape(permute(gradestensor,[2 1 3]),[N*T num_GPA_pctiles]);
    in_grad_school      = reshape(in_grad_school'            ,numel(in_grad_school            ),1);
    workPTschool        = reshape(workPTschool'              ,numel(workPTschool              ),1);
    workFTschool        = reshape(workFTschool'              ,numel(workFTschool              ),1);
    exper               = reshape(exper'                     ,numel(exper                     ),1);
    exper_postgrad      = reshape(exper_postgrad'            ,numel(exper_postgrad            ),1);
    exper_white_collar  = reshape(exper_white_collar'        ,numel(exper_white_collar        ),1);
    cum_2yr             = reshape(cum_2yr'                   ,numel(cum_2yr                   ),1);
    cum_4yr             = reshape(cum_4yr'                   ,numel(cum_4yr                   ),1);
    yrs_since_school    = reshape(yrs_since_school'          ,numel(yrs_since_school          ),1);
    asifhum.cum_4yrS    = reshape(asifhum.cum_4yrS'          ,numel(asifhum.cum_4yrS          ),1);
    asifhum.cum_4yrNS   = reshape(asifhum.cum_4yrNS'         ,numel(asifhum.cum_4yrNS         ),1);
    asifsci.cum_4yrS    = reshape(asifsci.cum_4yrS'          ,numel(asifsci.cum_4yrS          ),1);
    asifsci.cum_4yrNS   = reshape(asifsci.cum_4yrNS'         ,numel(asifsci.cum_4yrNS         ),1);
    cum_4yrS            = reshape(cum_4yrS'                  ,numel(cum_4yrS                  ),1);
    cum_4yrNS           = reshape(cum_4yrNS'                 ,numel(cum_4yrNS                 ),1);
    prev2_HS            = reshape(prev2_HS'                  ,numel(prev2_HS                  ),1);
    prev_HS             = reshape(prev_HS'                   ,numel(prev_HS                   ),1);
    prev_2yr            = reshape(prev_2yr'                  ,numel(prev_2yr                  ),1);
    asifhum.prev_4yrS   = reshape(asifhum.prev_4yrS'         ,numel(asifhum.prev_4yrS         ),1);
    asifhum.prev_4yrNS  = reshape(asifhum.prev_4yrNS'        ,numel(asifhum.prev_4yrNS        ),1);
    asifsci.prev_4yrS   = reshape(asifsci.prev_4yrS'         ,numel(asifsci.prev_4yrS         ),1);
    asifsci.prev_4yrNS  = reshape(asifsci.prev_4yrNS'        ,numel(asifsci.prev_4yrNS        ),1);
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
    firstGrades         = reshape(firstGrades'               ,numel(firstGrades               ),1);
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

    workFT = (choice9==1 | choice9==4 | choice9==8 ); 
    workPT = (choice9==2 | choice9==5 | choice9==7 );

    scienceMajor(isnan(scienceMajor)) = 0;
    origSciMajor(isnan(origSciMajor)) = 0;
    origHumMajor(isnan(origHumMajor)) = 0;
    choice                            = choice20;
    asifhum.choice                    = asifhum.choice20;
    asifsci.choice                    = asifsci.choice20;
    choice(anyFlag)                   = 0;
    asifhum.choice(anyFlag)           = 0;
    asifsci.choice(anyFlag)           = 0;
    NT                                = length(choice);
    %% Stack the data: first those with no missing GPAs or majors, then those with missing GPAs but no missing majors; then those with missing major but no GPA (as if science); then those with both missing major and GPA (as if science); then those with missing major but no GPA (as if humanities); then those with both missing major and GPA (as if humanities);
    yrclp                             = reshape(yrc',N*T,1);
    yrclpImps                         = [yrclp(~impGPAlp & ~impMajlp & ~impMajGPAlp);kron(ones(num_GPA_pctiles,1),yrclp(impGPAlp));yrclp(impMajlp);kron(ones(num_GPA_pctiles,1),yrclp(impMajGPAlp));yrclp(impMajlp);kron(ones(num_GPA_pctiles,1),yrclp(impMajGPAlp))];
    yrcl                              = kron(ones(S,1),yrclp);
    yrclImps                          = kron(ones(S,1),yrclpImps);
    % stack GPAs in the following sequence:
    % first for people not missing any critical data
    gradeslpImps                      = [grades(~impGPAlp & ~impMajlp & ~impMajGPAlp)];
    % next for those not missing major but missing GPA
    for pct = 1:num_GPA_pctiles
        gradeslpImps = cat(1,gradeslpImps,gradestensor(impGPAlp,pct));
    end
    % now for those who are missing a major, but not GPA
    gradeslpImps = cat(1,gradeslpImps,grades(impMajlp));
    % next for those missing both major and GPA
    for pct = 1:num_GPA_pctiles
        gradeslpImps = cat(1,gradeslpImps,gradestensor(impMajGPAlp,pct));
    end
    % now for those who are missing a major, but not GPA
    gradeslpImps = cat(1,gradeslpImps,grades(impMajlp));
    % next for those missing both major and GPA
    for pct = 1:num_GPA_pctiles
        gradeslpImps = cat(1,gradeslpImps,gradestensor(impMajGPAlp,pct));
    end
    % now stack by unobserved type
    gradeslImps = kron(ones(S,1),gradeslpImps);
    % now stack other variables as yrclp was done above
    Clp                                          = choice;
    asifhum.Clp                                  = asifhum.choice;
    asifsci.Clp                                  = asifsci.choice;
    [ClpImps,ClImps]                             = makegridchoice_con(Clp,asifsci.Clp,asifhum.Clp,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [IDImps,~]                                   = makegrid_con(ID,everImpMaj,everImpGPA,everImpMajGPA,num_GPA_pctiles,S);
    [IDlpImps,IDlImps]                           = makegrid_con(IDlp,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    periodl                                      = kron(ones(S,1),period);
    grad_4yrl                                    = kron(ones(S,1),grad_4yr);
    grad_4yr_next_yrl                            = kron(ones(S,1),grad_4yr_next_yr);
    [grad_4yrImps,grad_4yrlImps]                 = makegrid_con(grad_4yr,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [grad_2yrImps,grad_2yrlImps]                 = makegrid_con(grad_2yr,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [grad_4yr_next_yrImps,grad_4yr_next_yrlImps] = makegrid_con(grad_4yr_next_yr,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [grad_2yr_next_yrImps,grad_2yr_next_yrlImps] = makegrid_con(grad_2yr_next_yr,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,yearlImps]                                = makegrid_con(year,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    [~,anyFlaglImps]                             = makegrid_con(anyFlag,impMajlp,impGPAlp,impMajGPAlp,num_GPA_pctiles,S);
    grad_2yrl                                    = kron(ones(S,1),grad_2yr);
    grad_2yr_next_yrl                            = kron(ones(S,1),grad_2yr_next_yr);
    
    if length(ClpImps)~=Ntilde*T
        error('Imputation flags are not mutually exclusive!')
    end
    choiceData = v2struct(N, T, baseN, Ntilde, Ntilde1, Ntilde2, Ntilde3, Ntilde4, Ntilde5, NtildeGrid, NimpMaj, NimpGPA, NimpMajGPA, NLS_ID, ID, IDlp, IDl, male, black, hispanic, Peduc, m_Peduc, Parent_college, m_famInc, famInc, lnFamInc, HS_grades, ASVABmath, ASVABverb, SATmath, SATverb, predSATmathZ, predSATverbZ, AFQT, finalMajorSci, efc, tui4imp, grant4pr, loan4pr, grant4RMSE, loan4RMSE, grant4idx, loan4idx, tui2imp, grant2pr, loan2pr, grant2RMSE, loan2RMSE, grant2idx, loan2idx, ParTrans2RMSE, ParTrans4RMSE, E_loan4_18, E_loan2_18, gradestensor, choice20, asifhum, asifsci, choice12, choice9, choice, log_wage, grades, gradesnumbers, in_grad_school, workPTschool, workFTschool, exper, exper_postgrad, exper_white_collar, cum_2yr, cum_4yr, cum_4yrS, cum_4yrNS, yrs_since_school, yrsSinceHS, prev2_HS, prev_HS, prev_2yr, prev_4yr, prev_4yrS, prev_4yrNS, prev_PT, prev_FT, prev_WC, prev_BC, scienceMajor, origSciMajor, origHumMajor, origMissMajor, age, idxParTrans4, idxParTrans2, prParTrans4, prParTrans2,E_ParTrans4, E_ParTrans2, year, grad_4yr, grad_4yr_next_yr, grad_2yr, grad_2yr_next_yr, firstCol2yr, firstCol4yr, firstGrades, miss_grades, good_grades, black_2yr, black_4yr, black_exp, hispanic_2yr, hispanic_4yr, hispanic_exp, male_2yr, male_4yr, male_exp, ASVABmath2, ASVABverb2, SATmath2, SATverb2, AFQT2, cum_2yr2, cum_4yr2, exper2, age2, exper_postgrad2, exper_white_collar2, period, period, anyFlag, timeperiod, workFT, workPT, scienceMajor, origSciMajor, origHumMajor, choice, NT, yrclp, yrclpImps, yrcl, yrclImps, gradeslpImps, gradeslImps, Clp, ClpImps, ClImps, IDImps, IDlpImps, IDlImps, periodl, grad_4yrl, grad_4yr_next_yrl, grad_4yrImps, grad_4yr_next_yrImps, grad_4yrlImps, grad_4yr_next_yrlImps, grad_2yrl, grad_2yr_next_yrl, grad_2yrImps, grad_2yr_next_yrImps, grad_2yrlImps, grad_2yr_next_yrlImps, yearlImps, anyFlaglImps, impGPAlp, impMajlp, impMajGPAlp, num_GPA_pctiles, num_GPA_grid_points, everImpGPA, everImpMaj, everImpMajGPA, asvabAR, asvabCS, asvabMK, asvabNO, asvabPC, asvabWK, SATmathw, SATverbw, numAPs, lateForSchoolNoExcuse, breakRulesRegularly, R1ExtraClass, R1WeekdaysExtraClass, HrsExtraClass, lnHrsExtraClass, tookClassDuringBreak, reasonTookClassDuringBreak, highStandardsWork, doMoreThanExpected, pctChanceWork20Hrs30, parPctChanceWork20Hrs30, birthYrw, birthYr, hispanicw, blackw, Parent_collegew, famIncw, efcw, predSATmathZw, predSATverbZw, inSample);
end

