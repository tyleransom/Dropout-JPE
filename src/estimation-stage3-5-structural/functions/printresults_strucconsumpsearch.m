function printresults_strucconsumpsearch(b,h,l,utd,sdemog,Y,q,PmajgpaType,S,ipath)

    alpha  = b(1);
    galpha = b(2);
    b2flg    = 2+[1:utd.number2];
    b4sflg   = 2+[1+utd.number2:utd.number2+utd.number4s];
    b4nsflg  = 2+[1+utd.number2+utd.number4s:utd.number2+utd.number4s+utd.number4ns];
    bwptflg  = 2+[1+utd.number2+utd.number4s+utd.number4ns:utd.number2+utd.number4s+utd.number4ns+utd.numberpt];
    bgwptflg = 2+[1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt:utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt]; 
    bwftflg  = 2+[1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt:utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft];
    bgwftflg = 2+[1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft:utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft+utd.numbergft];
    bwcflg   = 2+[1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft+utd.numbergft:utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft+utd.numbergft+utd.numberwc];
    bgwcflg  = 2+[1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft+utd.numbergft+utd.numberwc:utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numbergpt+utd.numberft+utd.numbergft+utd.numberwc+utd.numbergwc];

    %% reorganize structural parameter estimates
    b2        = b(b2flg);
    b2temp    = [b2(1:sdemog+3);alpha;b2(sdemog+4:end-7);0;b2(end-6:end)];% first 0: consumption; second 0: white_collar
    b4s       = b(b4sflg);
    b4stemp   = [b4s(1:sdemog+3);alpha;b4s(sdemog+4:end-7);0;b4s(end-6:end)];
    b4ns      = b(b4nsflg);
    b4nstemp  = [b4ns(1:sdemog+3);alpha;b4ns(sdemog+4:end-7);0;b4ns(end-6:end)];
    bwpt      = b(bwptflg);
    bwpttemp  = [bwpt(1:sdemog);0;bwpt(sdemog+1:sdemog+2);alpha;bwpt(sdemog+3:end-3);0;0;0;0;bwpt(end-2:end)];% first two 0s: academic ability, consumption; second four 0s: workPT, workFT, workPT*white_collar, workFT*white_collar
    bwft      = b(bwftflg);
    bwfttemp  = [bwft(1:sdemog);0;bwft(sdemog+1:sdemog+2);alpha;bwft(sdemog+3:end-3);0;0;0;0;0;bwft(end-2:end)];% first two 0s: academic ability, consumption; second 5 0s: white_collar, workPT, workFT, wPT*WC, wFT*WC
    bwc       = b(bwcflg);
    bwctemp   = [bwc(1:sdemog);0;0;0;0;bwc(sdemog+1:end-3);0;0;0;0;0;bwc(end-2:end)];% first four 0s: academic ability, accum. debt (and squared), consumption; second 5 0s: white_collar, workPT, workFT, wPT*WC, wFT*WC 
    bgwpt     = b(bgwptflg);
    bgwpttemp = [bgwpt(1:10);galpha];
    bgwft     = b(bgwftflg);
    bgwfttemp = [bgwft(1:10);galpha];
    bgwc      = b(bgwcflg);
    bgwctemp  = [bgwc(1:10);0];

    %% get standard errors for structural parameter estimates
    stderr = sqrt(diag(inv(full(h))));
    se_a   = stderr(1);
    se_ga  = stderr(2);

    %% reorganize standard errors
    stderr2        = stderr(b2flg);
    stderr2temp    = [stderr2(1:sdemog+3);se_a;stderr2(sdemog+4:end-7);0;stderr2(end-6:end)];% first 0: consumption; second 0: white_collar
    stderr4s       = stderr(b4sflg);
    stderr4stemp   = [stderr4s(1:sdemog+3);se_a;stderr4s(sdemog+4:end-7);0;stderr4s(end-6:end)];
    stderr4ns      = stderr(b4nsflg);
    stderr4nstemp  = [stderr4ns(1:sdemog+3);se_a;stderr4ns(sdemog+4:end-7);0;stderr4ns(end-6:end)];
    stderrwpt      = stderr(bwptflg);
    stderrwpttemp  = [stderrwpt(1:sdemog);0;stderrwpt(sdemog+1:sdemog+2);se_a;stderrwpt(sdemog+3:end-3);0;0;0;0;stderrwpt(end-2:end)];% first two 0s: academic astderrility, consumption; second four 0s: workPT, workFT, workPT*white_collar, workFT*white_collar
    stderrwft      = stderr(bwftflg);
    stderrwfttemp  = [stderrwft(1:sdemog);0;stderrwft(sdemog+1:sdemog+2);se_a;stderrwft(sdemog+3:end-3);0;0;0;0;0;stderrwft(end-2:end)];% first two 0s: academic astderrility, consumption; second 5 0s: white_collar, workPT, workFT, wPT*WC, wFT*WC
    stderrwc       = stderr(bwcflg);
    stderrwctemp   = [stderrwc(1:sdemog);0;0;0;0;stderrwc(sdemog+1:end-3);0;0;0;0;0;stderrwc(end-2:end)];% first four 0s: academic astderrility, accum. destderrt (and squared), consumption; second 5 0s: white_collar, workPT, workFT, wPT*WC, wFT*WC 
    stderrgwpt     = stderr(bgwptflg);
    stderrgwpttemp = [stderrgwpt(1:10);se_ga];
    stderrgwft     = stderr(bgwftflg);
    stderrgwfttemp = [stderrgwft(1:10);se_ga];
    stderrgwc      = stderr(bgwcflg);
    stderrgwctemp  = [stderrgwc(1:10);0];

    %% stack vectors
    b2ltemp   = cat(1,b2temp,zeros(size(bgwpttemp)));
    b4sltemp  = cat(1,b4stemp,zeros(size(bgwpttemp)));
    b4nsltemp = cat(1,b4nstemp,zeros(size(bgwpttemp)));
    bwptltemp = cat(1,bwpttemp,bgwpttemp);
    bwftltemp = cat(1,bwfttemp,bgwfttemp);
    bwcltemp  = cat(1,bwctemp,bgwctemp);

    stderrb2ltemp   = cat(1,stderr2temp,zeros(size(stderrgwpttemp)));
    stderrb4sltemp  = cat(1,stderr4stemp,zeros(size(stderrgwpttemp)));
    stderrb4nsltemp = cat(1,stderr4nstemp,zeros(size(stderrgwpttemp)));
    stderrbwPTltemp = cat(1,stderrwpttemp,stderrgwpttemp);
    stderrbwFTltemp = cat(1,stderrwfttemp,stderrgwfttemp);
    stderrbWCltemp  = cat(1,stderrwctemp,stderrgwctemp);

    %% concatenate results into a matrix for ease of copying into Excel
    result = cat(2,b2ltemp,...
                   b4sltemp,...
                   b4nsltemp,...
                   bwptltemp,...
                   bwftltemp,...
                   bwcltemp);
    result = [result; [-l nan(1,size(result,2)-1)]; [sum(q(Y>0,:).*PmajgpaType(Y>0,:)) nan(1,size(result,2)-1)]];
    result_stderr = cat(2,stderrb2ltemp,...
                          stderrb4sltemp,...
                          stderrb4nsltemp,...
                          stderrbwPTltemp,...
                          stderrbwFTltemp,...
                          stderrbWCltemp);
    result_stderr = [result_stderr; nan(1,size(result_stderr,2)); nan(1,size(result_stderr,2))];
    result(result==0)=NaN;
    result_stderr(result_stderr==0)=NaN;
    dlmwrite(strcat(ipath,'Searchconsump_utility_results_het_no_int_beta0.csv'),[result zeros(size(result,1),1) result_stderr]);

end

