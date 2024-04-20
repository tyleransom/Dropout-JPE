function pgpa = pwolslambda(b,x,idx,sector)
    lambda0 = b(end-1);
    lambda1 = b(end);
    beta    = b(1:end-2);
    if ~isempty(idx)
        nidx    = setdiff(1:size(x,2),idx);
    end
    
    % sector=1 corresponds to subset of observations that get hit by lambda
    % sector=0 corresponds to all other observations
    
    % if ~isequal(size(y),size(sector))
    % 	error('sector variable is wrong')
    % end
    
    if ~isempty(idx)
        pgpa = x(:,idx)*beta(idx)+(sector==1)*lambda0+((sector==0)*1+(sector==1)*lambda1).*(x(:,nidx)*beta(nidx));
    else
        pgpa =(sector==1)*lambda0+((sector==0)*1+(sector==1)*lambda1).*(x*beta);
    end
end
    