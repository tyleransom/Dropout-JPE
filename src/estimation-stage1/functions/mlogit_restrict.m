function [like,grad]=mlogit_restrict(b,restrMat,Y,X,K,J,q)
%setting up the parameters that are the same across choices
N    = size(X,1);
num  = zeros(N,1);
dem  = zeros(N,1);

% apply restrictions as defined in restrMat
if ~isempty(restrMat)
    b = applyRestr(restrMat,b);
end
if  isempty(q)
    q = ones(N,1);
end

%sets the last alternative to be the one that is normalized to zero
for j=1:J-1
    temp=X*b((j-1)*K+1:j*K);
    num=(Y==j).*temp+num;
    dem=exp(temp)+dem;
end
dem=dem+1;

like=q'*(log(dem)-num);

for j=1:J-1
	P(:,j) = exp(X*b((j-1)*K+1:j*K))./dem;
end
P(:,J) = 1-sum(P(:,1:J-1),2);

grad = zeros(size(b));
for j=1:J-1
    grad((j-1)*K+1:j*K)=-X'*(q.*((Y==j)-exp(X*b((j-1)*K+1:j*K))./dem));
end
if ~isempty(restrMat)
    grad = applyRestrGrad(restrMat,grad);
end
