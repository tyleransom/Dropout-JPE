function [] = printresults(tblstr,ipath,suffix)
    % measurement system
    mywritetable(tblstr.mp.schab,[ipath,'msys-schabil',suffix,'.csv']);
    mywritetable(tblstr.mp.schpr,[ipath,'msys-schpref',suffix,'.csv']);
    mywritetable(tblstr.mp.wrkap,[ipath,'msys-wrkabilpref',suffix,'.csv']);

    % graduation logit
    mywritetable(tblstr.grl,[ipath,'gradlogit',suffix,'.csv']);
    
    % wages and grades
    mywritetable(tblstr.wwc,[ipath,'wageWC',suffix,'.csv']);
    mywritetable(tblstr.wbc,[ipath,'wageBC',suffix,'.csv']);
    mywritetable(tblstr.g4s,[ipath,'grades4s',suffix,'.csv']);
    mywritetable(tblstr.g4h,[ipath,'grades4h',suffix,'.csv']);
    mywritetable(tblstr.g2y,[ipath,'grades2y',suffix,'.csv']);

    % choice models
    mywritetable(tblstr.col,[ipath,'college-yes-no',suffix,'.csv']); 
    mywritetable(tblstr.c24,[ipath,'college-2yr-4yr-given-coll',suffix,'.csv']);
    mywritetable(tblstr.csc,[ipath,'college-sci-hum-given-4yr',suffix,'.csv']);
    mywritetable(tblstr.cls,[ipath,'work-yes-no',suffix,'.csv']);
    mywritetable(tblstr.cft,[ipath,'work-ft-pt-given-work',suffix,'.csv']);
    mywritetable(tblstr.cwc,[ipath,'work-wc-bc-given-work',suffix,'.csv']);
end
