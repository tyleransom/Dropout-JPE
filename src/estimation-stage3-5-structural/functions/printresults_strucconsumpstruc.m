function printresults_strucconsumpstruc(b,h,l,utd,sdemog,Y,q,PmajgpaType,S,ipath)

    alpha = b(1);
    rho   = b(2);
    b2flg   = 2+[1:utd.number2];
    b4sflg  = 2+[1+utd.number2:utd.number2+utd.number4s];
    b4nsflg = 2+[1+utd.number2+utd.number4s:utd.number2+utd.number4s+utd.number4ns];
    bwptflg = 2+[1+utd.number2+utd.number4s+utd.number4ns:utd.number2+utd.number4s+utd.number4ns+utd.numberpt];
    bwftflg = 2+[1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt:utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numberft];
    bwcflg  = 2+[1+utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numberft:utd.number2+utd.number4s+utd.number4ns+utd.numberpt+utd.numberft+utd.numberwc];

    %% reorganize structural parameter estimates
    b2        = b(b2flg);
    b2temp    = [b2(1:sdemog+1);alpha;b2(sdemog+2:end-7);0;0;b2(end-6:end)];% three 0s: prev_GS, grad_4yr, white_collar
    b4s       = b(b4sflg);
    b4stemp   = [b4s(1:sdemog+1);alpha;b4s(sdemog+2:end-7);0;0;b4s(end-6:end)];
    b4ns      = b(b4nsflg);
    b4nstemp  = [b4ns(1:sdemog+1);alpha;b4ns(sdemog+2:end-7);0;0;b4ns(end-6:end)];
    bwpt      = b(bwptflg);
    bwpttemp  = [bwpt(1:sdemog);0;alpha;bwpt(sdemog+1:end-3);0;0;0;0;bwpt(end-2:end)];% only two 0s here bc need to estimate white_collar parameter
    bwft      = b(bwftflg);
    bwfttemp  = [bwft(1:sdemog);0;alpha;bwft(sdemog+1:end-3);0;0;0;0;0;bwft(end-2:end)];
    bwc       = b(bwcflg);
    bwctemp   = [bwc(1:sdemog);0;0;bwc(sdemog+1:end-3);0;0;0;0;0;bwc(end-2:end)];

    %% get standard errors for structural parameter estimates
    stderr = sqrt(diag(inv(full(h))));
    se_a   = stderr(1);
    se_r   = stderr(2);

    %% reorganize standard errors
    stderrb2       = stderr(b2flg);
    stderrb2temp   = [stderrb2(1:sdemog+1);se_a;stderrb2(sdemog+2:end-7);0;0;stderrb2(end-6:end)]; 
    stderrb4s      = stderr(b4sflg);
    stderrb4stemp  = [stderrb4s(1:sdemog+1);se_a;stderrb4s(sdemog+2:end-7);0;0;stderrb4s(end-6:end)];
    stderrb4ns     = stderr(b4nsflg);
    stderrb4nstemp = [stderrb4ns(1:sdemog+1);se_a;stderrb4ns(sdemog+2:end-7);0;0;stderrb4ns(end-6:end)];
    stderrbwPT     = stderr(bwptflg);
    stderrbwPTtemp = [stderrbwPT(1:sdemog);0;se_a;stderrbwPT(sdemog+1:end-3);0;0;0;0;stderrbwPT(end-2:end)];
    stderrbwFT     = stderr(bwftflg);
    stderrbwFTtemp = [stderrbwFT(1:sdemog);0;se_a;stderrbwFT(sdemog+1:end-3);0;0;0;0;0;stderrbwFT(end-2:end)];
    stderrbWC      = stderr(bwcflg);
    stderrbWCtemp  = [stderrbWC(1:sdemog);0;0;stderrbWC(sdemog+1:end-3);0;0;0;0;0;stderrbWC(end-2:end)];

    %% concatenate results into a matrix for ease of copying into Excel
    result = cat(2,b2temp,...
                   b4stemp,...
                   b4nstemp,...
                   bwpttemp,...
                   bwfttemp,...
                   bwctemp);
    result = [result; [rho nan(1,size(result,2)-1)]; [-l nan(1,size(result,2)-1)]; [sum(q(Y>0,:).*PmajgpaType(Y>0,:)) nan(1,size(result,2)-1)]];
    result_stderr = cat(2,stderrb2temp,...
                          stderrb4stemp,...
                          stderrb4nstemp,...
                          stderrbwPTtemp,...
                          stderrbwFTtemp,...
                          stderrbWCtemp);
    result_stderr = [result_stderr; [se_r nan(1,size(result_stderr,2)-1)]; nan(1,size(result_stderr,2)); nan(1,size(result_stderr,2))];
    result(result==0)=NaN;
    result_stderr(result_stderr==0)=NaN;
    dlmwrite(strcat(ipath,'Searchconsump_struct_utility_results_no_int.csv'),[result zeros(size(result,1),1) result_stderr]);

end
