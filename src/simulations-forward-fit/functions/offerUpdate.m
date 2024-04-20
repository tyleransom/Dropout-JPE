function [offer,P] = offerUpdate(currStates,beta);
    
    v2struct(currStates);
    % make age gradient flat after t=19 (last period in estimation)
    if age>=19
        age = 19;
    end
    N  = length(cum_2yr);
    
    X = [ones(N,1) age grad_4yr ismember(utype,1:4) ismember(utype,[1:2 5:6]) ismember(utype,[1 3 5 7])];
    
    P = exp(X*beta)./(1+exp(X*beta));
    
    offer  = rand(N,1)<P;
    offer(prev_WC==1) = 1;
    P(prev_WC==1) = 1;
end
