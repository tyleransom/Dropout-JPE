function [parmvec,se] = normalMLEfit(theta,x,y,w)
    % Optimization options
    options=optimset('Disp','off','FunValCheck','off','MaxFunEvals',1e8,'MaxIter',1e8,'GradObj','on','LargeScale','on');

    % Estimate
    [parmvec,~,~,~,~,h] = fminunc('normalMLE',theta,options,[],y,x,w);
    
    % Standard Error
    se = sqrt(diag(inv(h)));
end
