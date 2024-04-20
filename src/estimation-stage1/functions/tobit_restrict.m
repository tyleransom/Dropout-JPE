function [like,grad]=tobit_restrict(b,restrMat,Yext,Yint,W,X,q)
%setting up the parameters that are the same across choices
N    = size(X,1);

% apply restrictions as defined in restrMat
if ~isempty(restrMat)
    b = applyRestr(restrMat,b);
end
if  isempty(q)
    q = ones(N,1);
end
beta  = b(1:end-1);
sigma = b(end);

like = -q'*(Yext.*(1-W).*(-.5*(log(2*pi)+log(sigma^2)+((Yint-X*beta)./sigma).^2)) + (1-Yext).*log(1-normcdf((X*beta)./sigma)) + Yext.*W.*log(normcdf((X*beta)./sigma))) ;

% analytical gradient
grad = zeros(size(b));
grad(1:end-1) = -X'*( (q.*Yext.*(1-W).*(Yint-X*beta)./(sigma.^2)) - (q.*(1-Yext).*normpdf((X*beta)./sigma)./(sigma*(1-normcdf((X*beta)./sigma)))) + (q.*Yext.*W.*normpdf((X*beta)./sigma)./(sigma*(normcdf((X*beta)./sigma)))) );
grad(end) = sum(Yext.*(1-W).*q.*(1./sigma-((Yint-X*beta).^2)./(sigma.^3)) - (q.*(1-Yext).*normpdf((X*beta)./sigma).*(X*beta)./((1-normcdf((X*beta)./sigma)).*sigma^2)) + (q.*Yext.*W.*normpdf((X*beta)./sigma).*(X*beta)./((normcdf((X*beta)./sigma)).*sigma^2)));
if ~isempty(restrMat)
    grad = applyRestrGrad(restrMat,grad);
end
