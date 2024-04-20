function SSE = wolslambda(b,y,x,idx,abil,vabil,sector,weight,sig2v)
lambda0 = b(end-1);
lambda1 = b(end);
beta    = b(1:end-2);
if ~isempty(idx)
    nidx = setdiff(1:size(x,2),idx);
end

% sector=1 corresponds to subset of observations that get hit by lambda
% sector=0 corresponds to all other observations

lambda0v            = zeros(size(y));
lambda0v(sector==1) = lambda0;
lambda1v            = ones(size(y));
lambda1v(sector==1) = lambda1;

if ~isequal(size(y),size(sector))
	error('sector variable is wrong')
end

if ~isempty(idx)
    SSE = sum(weight.*(log(sig2v) + (1./sig2v).*(vabil.*(lambda1v).^2 + (y - x(:,idx)*beta(idx) - lambda0v - lambda1v.*(x(:,nidx)*beta(nidx)+abil)).^2)));
else
    SSE = sum(weight.*(log(sig2v) + (1./sig2v).*(vabil.*(lambda1v).^2 + (y - lambda0v - lambda1v.*(x*beta+abil)).^2)));
end
