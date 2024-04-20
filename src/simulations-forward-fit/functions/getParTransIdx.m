function ptidx = getParTransIdx(data,a,cs,sector)
    if sector==4
        b = [8.357448; -.0955420; .1104414; .0027407; .0903884; .1878193]; % parameter estimates from Stata
    elseif sector==2
        b = [8.652486; -.0595774; .0334340; .0311122;-.0200760; .0910101]; % parameter estimates from Stata
    end
    X = [ones(size(data.black)) data.age+a data.lnFamInc data.cum_2yr+data.cum_4yr+cs data.black data.hispanic];
    ptidx = X*b;
end 
