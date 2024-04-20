function P=pologit(b,K,X,J)

assert(length(b)==(K+(J-1)),'size of parameter vector doesn''t conform to ordered logit model')
P = zeros(size(X,1),J);

beta = b(1:K);
cut = [-50; b(end-(J-2):end); 50];

for j=J:-1:1
    % matrices for use in likelihood and gradient
    P(:,j)  = 1./(1+exp(-cut(j+1)+X*beta)) - 1./(1+exp(-cut(j)+X*beta));
end

end
