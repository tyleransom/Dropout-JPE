function [] = printresults(learnparms,gradparms,guess,ipath,suffix)
    v2struct(learnparms)
    v2struct(gradparms)
    
    % learning model parameter estimates
    DeltaCorr = corrcov(tril(Delta,-1)+tril(Delta,-1)'+diag(diag(Delta))); % since our Delta matrix is not perfectly symmetric (it is to 1e-10 tolerance though)
    dlmwrite(strcat(ipath,'learning_results',suffix,'_',num2str(guess),'.csv'), [Delta NaN(length(Delta),1) DeltaCorr]);
    dlmwrite(strcat(ipath,'learning_results',suffix,'_',num2str(guess),'.csv'), NaN, '-append');
    dlmwrite(strcat(ipath,'learning_results',suffix,'_',num2str(guess),'.csv'), [[sig([1 3]) [lambdag1start^2*sig(2);lambdan1start^2*sig(4)]];[sig(5:6) sig(10:11)];[lambda4s1start^2*sig(7:9) lambda4h1start^2*sig(12:14)]; [sig(15:17) NaN*ones(3,1)]], '-append');
    dlmwrite(strcat(ipath,'learning_results',suffix,'_',num2str(guess),'.csv'), NaN, '-append');
    dlmwrite(strcat(ipath,'learning_results',suffix,'_',num2str(guess),'.csv'), [[bstartg];[sum(BigN(1:2))];NaN*ones(1,1);[bstartn];[sum(BigN(3:4))];NaN*ones(1,1);[bstart4s];[sum(BigN(5:9))];NaN*ones(1,1);[bstart4h];[sum(BigN(10:14))];NaN*ones(1,1);[bstart2];[sum(BigN(15:17))];NaN*ones(1,1);[lambdaydgstart];NaN*ones(1,1);[lambdag0start;lambdag1start];NaN*ones(2,1); [lambdan0start;lambdan1start];NaN*ones(2,1);[lambda4s0start;lambda4s1start];NaN*ones(2,1); [lambda4h0start;lambda4h1start];NaN*ones(2,1)], '-append');

    % graduation parameter estimates
    dlmwrite(strcat(ipath,'gradlogit_results',suffix,'_',num2str(guess),'.csv'), P_grad_betas4);

end 
