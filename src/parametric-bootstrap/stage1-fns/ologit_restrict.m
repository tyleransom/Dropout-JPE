function [like,grad]=ologit_restrict(b,restrMat,Y,X,K,J,q)
%setting up the parameters that are the same across choices
N   = size(X,1);
Y0  = zeros(N,J);
P   = zeros(N,J);
dP  = zeros(N,J);
dc  = zeros(N,J);
dc1 = zeros(N,J);

% apply restrictions as defined in restrMat
if ~isempty(restrMat)
    b = applyRestr(restrMat,b);
end
if  isempty(q)
    q=ones(N,1);
end

assert(length(b)==(K+(J-1)),'size of parameter vector doesn''t conform to ordered logit model')
beta = b(1:K);
cut = [-50; b(end-(J-2):end); 50];

for j=J:-1:1
    % matrices for use in likelihood and gradient
    Y0(:,j) = Y==j;
    P(:,j)  = 1./(1+exp(-cut(j+1)+X*beta)) - 1./(1+exp(-cut(j)+X*beta));
    % matrices for use in gradient only
    dP(:,j) = (exp(-cut(j)+X*beta)./(1+exp(-cut(j)+X*beta)).^2 - exp(-cut(j+1)+X*beta)./(1+exp(-cut(j+1)+X*beta)).^2)./P(:,j);
    dc (:,j) = -exp(-cut(j+1)+X*beta)./((1+exp(-cut(j+1)+X*beta)).^2)./P(:,j);
    if j<J
        dc1(:,j) = -exp(-cut(j+1)+X*beta)./((1+exp(-cut(j+1)+X*beta)).^2)./P(:,j+1);
    end
end

like=-q'*(sum(Y0.*log(P),2));

grad = zeros(size(b));
% gradient of linear index parameters
grad(1:K)=-X'*(q.*sum(Y0.*dP,2));
% gradient of cut points
for j=1:J-1
    grad(K+j) = -q'*(Y0(:,j+1).*dc1(:,j)-Y0(:,j).*dc(:,j));
end
% apply restrictions (if necessary)
if ~isempty(restrMat)
    grad = applyRestrGrad(restrMat,grad);
end
