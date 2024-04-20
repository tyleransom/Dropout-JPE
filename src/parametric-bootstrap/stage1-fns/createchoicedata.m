function [choiceData] = createchoicedata(allstates,currStates,S)
    year = [];
    v2struct(allstates);
    
    % combine log wages
    log_wage = wagen;
    log_wage(~isnan(wageg)) = wageg(~isnan(wageg));
    
    % combine college GPAs
    grades = grade4s;
    grades(~isnan(grade4h)) = grade4h(~isnan(grade4h));
    grades(~isnan(grade2 )) = grade2(~isnan(grade2 ));
    
    % future college graduation
    grad_4yr_next_yr = zeros(size(Ymat));
    for t=1:size(Ymat,2)-1
        grad_4yr_next_yr(:,t)  = (grad_4yr(:,t+1)==1);
    end

    
    %% Reshape variables into N*Tx1 form where first T observations are person 1, next T observations are person 2, etc.
    [N,T]          = size(Ymat);
    yrc            = cumsum(Ymat>0 & Ymat<16,2);
    ID             = [1:N]';
    IDlp           = kron(ID,ones(T,1));
    IDl            = kron(ones(S,1),IDlp);
    black          = kron(black                   ,ones(T,1));
    hispanic       = kron(hispanic                ,ones(T,1));
    Parent_college = kron(Parent_college          ,ones(T,1));
    born1980       = kron(birthYr==1980           ,ones(T,1));
    born1981       = kron(birthYr==1981           ,ones(T,1));
    born1982       = kron(birthYr==1982           ,ones(T,1));
    born1983       = kron(birthYr==1983           ,ones(T,1));
    born1984       = kron(birthYr==1984           ,ones(T,1));
    birthYr        = kron(birthYr                 ,ones(T,1));
    famInc         = kron(famInc                  ,ones(T,1));
    HS_grades      = kron(HS_grades               ,ones(T,1));
    finalMajorSci  = kron(finalMajorSci           ,ones(T,1));
    lnFamInc       = kron(currStates.lnFamInc     ,ones(T,1));
    efc            = kron(currStates.efc          ,ones(T,1));
    tui4imp        = kron(currStates.tui4imp      ,ones(T,1));
    grant4pr       = kron(currStates.grant4pr     ,ones(T,1));
    loan4pr        = kron(currStates.loan4pr      ,ones(T,1));
    grant4RMSE     = kron(currStates.grant4RMSE   ,ones(T,1));
    loan4RMSE      = kron(currStates.loan4RMSE    ,ones(T,1));
    grant4idx      = kron(currStates.grant4idx    ,ones(T,1));
    loan4idx       = kron(currStates.loan4idx     ,ones(T,1));
    tui2imp        = kron(currStates.tui2imp      ,ones(T,1));
    grant2pr       = kron(currStates.grant2pr     ,ones(T,1));
    loan2pr        = kron(currStates.loan2pr      ,ones(T,1));
    grant2RMSE     = kron(currStates.grant2RMSE   ,ones(T,1));
    loan2RMSE      = kron(currStates.loan2RMSE    ,ones(T,1));
    grant2idx      = kron(currStates.grant2idx    ,ones(T,1));
    loan2idx       = kron(currStates.loan2idx     ,ones(T,1));
    ParTrans2RMSE  = kron(currStates.ParTrans2RMSE,ones(T,1));
    ParTrans4RMSE  = kron(currStates.ParTrans4RMSE,ones(T,1));
    E_loan2_18     = kron(currStates.E_loan4_18   ,ones(T,1));
    E_loan4_18     = kron(currStates.E_loan2_18   ,ones(T,1));
    idxParTrans4   = kron(currStates.idxParTrans4 ,ones(T,1));
    idxParTrans2   = kron(currStates.idxParTrans2 ,ones(T,1));
    prParTrans4    = kron(currStates.prParTrans4  ,ones(T,1));
    prParTrans2    = kron(currStates.prParTrans2  ,ones(T,1));
    predSATmathZ   = kron(currStates.predSATmathZ ,ones(T,1));
    predSATverbZ   = kron(currStates.predSATverbZ ,ones(T,1));

    Y                   = reshape(Ymat'              ,numel(Ymat                      ),1);
    log_wage            = reshape(log_wage'          ,numel(log_wage                  ),1);
    grades              = reshape(grades'            ,numel(grades                    ),1);
    yrc                 = reshape(yrc'               ,numel(yrc                       ),1);
    exper               = reshape(exper'             ,numel(exper                     ),1);
    exper_white_collar  = reshape(exper_white_collar',numel(exper_white_collar        ),1);
    cum_2yr             = reshape(cum_2yr'           ,numel(cum_2yr                   ),1);
    cum_4yr             = reshape(cum_4yr'           ,numel(cum_4yr                   ),1);
    cum_4yrS            = reshape(cum_4yrS'          ,numel(cum_4yrS                  ),1);
    cum_4yrNS           = reshape(cum_4yrNS'         ,numel(cum_4yrNS                 ),1);
    prev_HS             = reshape(prev_HS'           ,numel(prev_HS                   ),1);
    prev_2yr            = reshape(prev_2yr'          ,numel(prev_2yr                  ),1);
    prev_4yrS           = reshape(prev_4yrS'         ,numel(prev_4yrS                 ),1);
    prev_4yrNS          = reshape(prev_4yrNS'        ,numel(prev_4yrNS                ),1);
    prev_PT             = reshape(prev_PT'           ,numel(prev_PT                   ),1);
    prev_FT             = reshape(prev_FT'           ,numel(prev_FT                   ),1);
    prev_WC             = reshape(prev_WC'           ,numel(prev_WC                   ),1);
    prev_BC             = (prev_PT | prev_FT) & ~prev_WC;
    age                 = reshape(age'               ,numel(age                       ),1);
    year                = reshape(year'              ,numel(year                      ),1);
    grad_4yr            = reshape(grad_4yr'          ,numel(grad_4yr                  ),1);
    grad_4yr_next_yr    = reshape(grad_4yr_next_yr'  ,numel(grad_4yr_next_yr          ),1);
    anyFlag             = zeros(N,T);
    period              = cumsum(anyFlag==0,2);
    period              = reshape(period',numel(period),1);
    timeperiod          = kron(ones(N,1),[1:T]');
    workFT              = ismember(Y,[1:2 6:7 11:12 18:19]);
    workPT              = ismember(Y,[3:4 8:9 13:14 16:17]);
    yrsSinceHS          = period;
    in_college          = ismember(Y, 1:15);
    in_2yr              = ismember(Y, 1:5);
    in_4yr              = ismember(Y, 6:15);
    in_sci              = ismember(Y, 6:10);
    in_hum              = ismember(Y,11:15);
    in_work             = ismember(Y,[1:4 6:9 11:14 16:19]);
    in_PT               = ismember(Y,[3:4 8:9 13:14 16:17]);
    in_FT               = ismember(Y,[1:2 6:7 11:12 18:19]);
    in_WC               = ismember(Y,[2 4 7 9 12 14 17 19]);
    in_BC               = ismember(Y,[1 3 6 8 11 13 16 18]);
    
    Yl                  = kron(ones(S,1),Y);
    yrcl                = kron(ones(S,1),yrc);
    periodl             = kron(ones(S,1),period);
    wagesl              = kron(ones(S,1),log_wage);
    gradesl             = kron(ones(S,1),grades);
    grad_4yrl           = kron(ones(S,1),grad_4yr);
    grad_4yr_next_yrl   = kron(ones(S,1),grad_4yr_next_yr);
    experl              = kron(ones(S,1),exper);
    exper_white_collarl = kron(ones(S,1),exper_white_collar);
    cum_2yrl            = kron(ones(S,1),cum_2yr);
    cum_4yrl            = kron(ones(S,1),cum_4yr);
    cum_4yrSl           = kron(ones(S,1),cum_4yrS);
    cum_4yrNSl          = kron(ones(S,1),cum_4yrNS);
    prev_HSl            = kron(ones(S,1),prev_HS);
    prev_2yrl           = kron(ones(S,1),prev_2yr);
    prev_4yrSl          = kron(ones(S,1),prev_4yrS);
    prev_4yrNSl         = kron(ones(S,1),prev_4yrNS);
    prev_PTl            = kron(ones(S,1),prev_PT);
    prev_FTl            = kron(ones(S,1),prev_FT);
    prev_WCl            = kron(ones(S,1),prev_WC);
    in_collegel         = ismember(Yl, 1:15);
    in_2yrl             = ismember(Yl, 1:5);
    in_4yrl             = ismember(Yl, 6:15);
    in_scil             = ismember(Yl, 6:10);
    in_huml             = ismember(Yl,11:15);
    in_workl            = ismember(Yl,[1:4 6:9 11:14 16:19]);
    in_PTl              = ismember(Yl,[3:4 8:9 13:14 16:17]);
    in_FTl              = ismember(Yl,[1:2 6:7 11:12 18:19]);
    in_WCl              = ismember(Yl,[2 4 7 9 12 14 17 19]);
    in_BCl              = ismember(Yl,[1 3 6 8 11 13 16 18]);

    choiceData = v2struct(N, T, ID, IDlp, IDl, black, hispanic, Parent_college, ...
                          birthYr, born1980, born1981, born1982, born1983, born1984, ...
                          famInc, lnFamInc, HS_grades, finalMajorSci, tui4imp, ...
                          grant4pr, loan4pr, grant4RMSE, loan4RMSE, grant4idx, ...
                          loan4idx, tui2imp, grant2pr, loan2pr, grant2RMSE, ...
                          loan2RMSE, grant2idx, loan2idx, ParTrans2RMSE, ...
                          ParTrans4RMSE, E_loan4_18, E_loan2_18, idxParTrans4, ...
                          idxParTrans2, prParTrans4, prParTrans2, predSATmathZ, ...
                          predSATverbZ, efc, Y, Yl, log_wage, grades, exper, experl, ...
                          exper_white_collar, exper_white_collarl, cum_2yr, cum_2yrl, ...
                          cum_4yr, cum_4yrl, cum_4yrS, cum_4yrSl, cum_4yrNS, cum_4yrNSl, yrsSinceHS, ...
                          prev_HS, prev_2yr, prev_4yrS, prev_4yrNS, prev_PT, prev_FT, ...
                          prev_WC, prev_BC, age, year, grad_4yr, grad_4yr_next_yr, ...
                          grad_4yrl, grad_4yr_next_yrl, period, timeperiod, ...
                          workFT, workPT, yrc, yrcl, periodl, prev_HSl, prev_2yrl, ...
                          prev_4yrSl, prev_4yrNSl, prev_PTl, prev_FTl, prev_WCl, ...
                          in_college, in_2yr, in_4yr, in_sci, in_hum, ...
                          in_work, in_PT, in_FT, in_WC, in_BC, ...
                          in_collegel, in_2yrl, in_4yrl, in_scil, in_huml, ...
                          in_workl, in_PTl, in_FTl, in_WCl, in_BCl, wagesl, gradesl);
end
