function ptpr = getParTransPr(data,a,sector)
    if sector==4
        b = [1.701702; -.3316555; .1240221;  .2617838; .1667502]; % parameter estimates from Stata
    elseif sector==2
        b = [1.627587; -.3034261; .1539419; -.0397682; .1832065]; % parameter estimates from Stata
    end
    X = [ones(size(data.black)) data.age+a data.lnFamInc data.black data.hispanic];
    ptpr = exp(X*b)./(1+exp(X*b));
end 
