function [learnData] = createlearningdata(maindata,A,S)

    year = [];
    v2struct(maindata);

    % create helpful flags for later use
    flagA_wcNS = ismember(Yl,[              17 19]);
    flagA_wcS  = ismember(Yl,[2 4 7 9 12 14      ]);
    flagA_wc   = ismember(Yl,[2 4 7 9 12 14 17 19]);
    flagA_bcNS = ismember(Yl,[              16 18]);
    flagA_bcS  = ismember(Yl,[1 3 6 8 11 13      ]);
    flagA_bc   = ismember(Yl,[1 3 6 8 11 13 16 18]);
    flagA4s    = (Yl>5  & Yl<11);
    flagA4h    = (Yl>10 & Yl<16);
    flagA2     = (Yl>0  & Yl<6 );

    % make sure that college graduates have the experience profiles of 4+ year college completers
    cum_sch = (1-grad_4yr).*min(cum_2yr+cum_4yr,4) + 4.*grad_4yr;
    
    % create learning data
    x2  = [ones(N*T,1) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age<=0 age==1 age==2 workFT workPT yrc>=2];
    x4h = [ones(N*T,1) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age<=0 age==1 age==2 workFT workPT];
    x4s = [ones(N*T,1) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age<=0 age==1 age==2 workFT workPT];
    xn  = [ones(N*T,1) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age<=0 age==1 age==2 exper exper_white_collar cum_sch (grad_4yr==1) (finalMajorSci==1 & grad_4yr==1) year<=1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ismember(Y,[3 8 13 16])];
    xg  = [ones(N*T,1) black hispanic Parent_college HS_grades birthYr==1980 birthYr==1981 birthYr==1982 birthYr==1983 age<=0 age==1 age==2 exper exper_white_collar cum_sch (grad_4yr==1) (finalMajorSci==1 & grad_4yr==1) year<=1999 year==2000 year==2001 year==2002 year==2003 year==2004 year==2005 year==2006 year==2007 year==2008 year==2009 year==2010 year==2011 year==2012 year==2013 year==2014 ismember(Y,[4 9 14 17])];

    % Stack the data: first those with no missing majors, then those assuming science major, then those assuming humanities major
    gradesl = kron(ones(S,1),grades);
    wagesl  = kron(ones(S,1),log_wage);
    xg      = cat(2,kron(ones(S,1),xg    ),kron(A,ones(N*T,1)));
    xn      = cat(2,kron(ones(S,1),xn    ),kron(A,ones(N*T,1)));
    x4s     = cat(2,kron(ones(S,1),x4s   ),kron(A,ones(N*T,1)));
    x4h     = cat(2,kron(ones(S,1),x4h   ),kron(A,ones(N*T,1)));
    x2      = cat(2,kron(ones(S,1),x2    ),kron(A,ones(N*T,1)));

    if ~isequal(size(Yl),size(gradesl)) || ~isequal(length(Yl),length(xg))
        error('Data stacking error!')
    end

    % Create data consistent with the actual data 
    xgNS  = xg (flagA_wcNS,:);
    xgS   = xg (flagA_wcS,:);
    xg    = xg (flagA_wc,:);
    xnNS  = xn (flagA_bcNS,:);
    xnS   = xn (flagA_bcS,:);
    xn    = xn (flagA_bc,:);
    x4s12 = x4s(flagA4s & yrcl<3,:);
    x4h12 = x4h(flagA4h & yrcl<3,:);
    x212  = x2 (flagA2  & yrcl<3,:);
    x4s3T = x4s(flagA4s & yrcl>2,:); 
    x4h3T = x4h(flagA4h & yrcl>2,:); 
    x23T  = x2 (flagA2  & yrcl>2,:); 
    x4s1  = x4s(flagA4s & yrcl==1,:);
    x4s2  = x4s(flagA4s & yrcl==2,:);
    x4s3  = x4s(flagA4s & yrcl==3,:);
    x4s4  = x4s(flagA4s & yrcl==4,:);
    x4s5T = x4s(flagA4s & yrcl>=5,:);
    x4s   = x4s(flagA4s,:);
    x4h1  = x4h(flagA4h & yrcl==1,:);
    x4h2  = x4h(flagA4h & yrcl==2,:);
    x4h3  = x4h(flagA4h & yrcl==3,:);
    x4h4  = x4h(flagA4h & yrcl==4,:);
    x4h5T = x4h(flagA4h & yrcl>=5,:);
    x4h   = x4h(flagA4h,:);
    x21   = x2 (flagA2 & yrcl==1,:);
    x22   = x2 (flagA2 & yrcl==2,:);
    x2    = x2 (flagA2,:);

    wageg     = wagesl (flagA_wc);
    wagegNS   = wagesl (flagA_wcNS);
    wagegS    = wagesl (flagA_wcS);
    wagen     = wagesl (flagA_bc);
    wagenNS   = wagesl (flagA_bcNS);
    wagenS    = wagesl (flagA_bcS);
    grade2    = gradesl(flagA2);
    grade4s   = gradesl(flagA4s);
    grade4h   = gradesl(flagA4h);
    grade4s1  = gradesl(flagA4s & yrcl==1);
    grade4h1  = gradesl(flagA4h & yrcl==1);
    grade21   = gradesl(flagA2  & yrcl==1);
    grade4s2  = gradesl(flagA4s & yrcl==2);
    grade4h2  = gradesl(flagA4h & yrcl==2);
    grade22   = gradesl(flagA2  & yrcl==2);
    grade4s3  = gradesl(flagA4s & yrcl==3);
    grade4h3  = gradesl(flagA4h & yrcl==3);
    grade23T  = gradesl(flagA2  & yrcl>=3);
    grade4s4  = gradesl(flagA4s & yrcl==4);
    grade4h4  = gradesl(flagA4h & yrcl==4);
    grade4s5T = gradesl(flagA4s & yrcl>=5);
    grade4h5T = gradesl(flagA4h & yrcl>=5);
    grade4s12 = gradesl(flagA4s & yrcl< 3);
    grade4h12 = gradesl(flagA4h & yrcl< 3);
    grade212  = gradesl(flagA2  & yrcl< 3);
    grade4s3T = gradesl(flagA4s & yrcl> 2);
    grade4h3T = gradesl(flagA4h & yrcl> 2);

    learnData = v2struct(x2, grade2, x4s, grade4s, x4h, grade4h, xg, wageg, xn, wagen, wagegNS, xgNS, wagegS, xgS, wagenNS, xnNS, wagenS, xnS, grade4s1, x4s12, grade4s12, x4s3T, grade4s3T, x4s1, grade4s2, x4s2, grade4s3, x4s3, grade4s4, x4s4, grade4s5T, x4s5T, x4h12, grade4h12, x4h3T, grade4h3T, grade4h1, x4h1, grade4h2, x4h2, grade4h3, x4h3, grade4h4, x4h4, grade4h5T, x4h5T, grade212, x212, grade21, x21, grade22, x22, grade23T, x23T);
end
