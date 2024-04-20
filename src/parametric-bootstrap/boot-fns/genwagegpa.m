function outcomes = genwagegpa(data,choice,trueabils,idiomat,learnparameters)

    year = [];
    v2struct(data);
    v2struct(learnparameters);

    yidx           = 18:33;
    flag_wc_sch    = ismember(choice,[2 4 7 9 12 14]);
    flag_wc_no_sch = ismember(choice,[17 19]); 
    flag_bc_sch    = ismember(choice,[1 3 6 8 11 13]);
    flag_bc_no_sch = ismember(choice,[16 18]); 
    flag_4su       = ismember(choice,[6:10])  & (yct>=3);
    flag_4hu       = ismember(choice,[11:15]) & (yct>=3);
    flag_4sl       = ismember(choice,[6:10])  & (yct< 3);
    flag_4hl       = ismember(choice,[11:15]) & (yct< 3);
    flag_2yr       = ismember(choice,[1:5]);
    workPT         = ismember(choice,[3 4 8 9 13 14 16 17]);
    workFT         = ismember(choice,[1 2 6 7 11 12 18 19]);

    % make sure that college graduates get the wages of 4+ year college completers
    cum_sch = (1-grad_4yr).*min(cum_2yr+cum_4yr,4) + 4.*grad_4yr;
    
    % initialize matrices
    wageg   = nan(N,1);
    wagen   = nan(N,1);
    grade4s = nan(N,1);
    grade4h = nan(N,1);
    grade2  = nan(N,1);
    
    %---------------------------------------------------------------------------
    % log wages
    %---------------------------------------------------------------------------
    x = [ones(N,1) black hispanic Parent_college HS_grades born1980 born1981 born1982 born1983 age<=0 age==1 age==2 exper exper_white_collar cum_sch (grad_4yr==1) (finalMajorSci==1 & grad_4yr==1) year<=1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 workPT ismember(utype,1:4) ismember(utype,[1:2 5:6]) ismember(utype,[1 3 5 7])];

    yndg = setdiff([1:length(bstartg)],yidx);
    yndn = setdiff([1:length(bstartn)],yidx);
    
    % white collar
    wageg(flag_wc_sch   ) = lambdag0start + x(flag_wc_sch   ,yidx)*bstartn(yidx) + lambdag1start*( x(flag_wc_sch   ,yndg)*bstartg(yndg) + trueabils(flag_wc_sch   ,1) ) + idiomat(flag_wc_sch   ,1);
    wageg(flag_wc_no_sch) = 0             + x(flag_wc_no_sch,yidx)*bstartn(yidx) +                 x(flag_wc_no_sch,yndg)*bstartg(yndg) + trueabils(flag_wc_no_sch,1)   + idiomat(flag_wc_no_sch,1);
    
    % blue collar
    wagen(flag_bc_sch   ) = lambdan0start + x(flag_bc_sch   ,yidx)*bstartn(yidx) + lambdan1start*( x(flag_bc_sch   ,yndn)*bstartg(yndn) + trueabils(flag_bc_sch   ,2) ) + idiomat(flag_bc_sch   ,2);
    wagen(flag_bc_no_sch) = 0             + x(flag_bc_no_sch,yidx)*bstartn(yidx) +                 x(flag_bc_no_sch,yndn)*bstartg(yndn) + trueabils(flag_bc_no_sch,2)   + idiomat(flag_bc_no_sch,2);
    
    %---------------------------------------------------------------------------
    % GPAs
    %---------------------------------------------------------------------------
    x2 = [ones(N,1) black hispanic Parent_college HS_grades born1980 born1981 born1982 born1983 age<=0 age==1 age==2 workFT workPT yct>=2 ismember(utype,1:4) ismember(utype,[1:2 5:6]) ismember(utype,[1 3 5 7])];
    x4 = [ones(N,1) black hispanic Parent_college HS_grades born1980 born1981 born1982 born1983 age<=0 age==1 age==2 workFT workPT        ismember(utype,1:4) ismember(utype,[1:2 5:6]) ismember(utype,[1 3 5 7])];
    
    grade2(flag_2yr)  = 0              +                  x2(flag_2yr,:)*bstart2  + trueabils(flag_2yr,5)   + idiomat(flag_2yr,5);
    grade4h(flag_4hl) = 0              +                  x4(flag_4hl,:)*bstart4h + trueabils(flag_4hl,4)   + idiomat(flag_4hl,4);
    grade4s(flag_4sl) = 0              +                  x4(flag_4sl,:)*bstart4s + trueabils(flag_4sl,3)   + idiomat(flag_4sl,3);
    grade4h(flag_4hu) = lambda4h0start + lambda4h1start*( x4(flag_4hu,:)*bstart4h + trueabils(flag_4hu,4) ) + idiomat(flag_4hu,4);
    grade4s(flag_4su) = lambda4s0start + lambda4s1start*( x4(flag_4su,:)*bstart4s + trueabils(flag_4su,3) ) + idiomat(flag_4su,3);
    
    outcomes = v2struct(wageg,wagen,grade4s,grade4h,grade2);
end