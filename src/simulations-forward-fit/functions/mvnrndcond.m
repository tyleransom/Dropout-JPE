function [X] = mvnrndcond(Mu,Sigma)

% Draw from a multivariate normal using conditional distribution,
% looping over J instead of N.  If all draws are from the same variance use
% matlabs built in mvnrnd, which will be faster

% check sizes

[N,J] = size(Mu);

if ~all([isequal(size(Mu),[N J]) isequal(size(Sigma),[J J N])])
    if size(Sigma,3)==1
        warning('Do not use this function with single covariance matrix. Use mvnrnd instead')
    else
        error('Dimensions of input do not comply')
    end    
end

% Compute probability through conditional pdf;
X = zeros(N,J);

for j = 1:J

    vj = max(reshape(Sigma(1,1,:),[N 1]),0);
    covj = Sigma(2:end,1,:);

    X(:,j) = Mu(:,1) + randn(N,1).*sqrt(vj);

    if j==J, break; end

    invcovj = bsxfun(@rdivide,covj,reshape(vj,[1 1 size(vj,1)]));
    invcovj(isnan(invcovj) | isinf(invcovj)) = 0;    
    update_Mu = bsxfun(@times,reshape(invcovj,[size(covj,1) N])',X(:,j)-Mu(:,1));
    Mu(:,1) = [];
    Mu = Mu + update_Mu;

    update_Sigma = bsxfun(@times,covj,reshape(invcovj,[1 size(covj,1) size(covj,3)]));
    Sigma(1,:,:) = [];
    Sigma(:,1,:) = [];
    Sigma = Sigma - update_Sigma;

end


