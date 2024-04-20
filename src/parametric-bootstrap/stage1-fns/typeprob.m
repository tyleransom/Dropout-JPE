function [prior,PType,PTypel,jointlike]=typeprob(prior,base,T,S)

    % update baselihood (conditional on unobs type, unobs major, and unobs GPA)
    PType = nan(size(base));
    for s=1:S
        PType(:,s) = prior(s)*base(:,s)./(base*prior');
    end
    PTypelp = kron(PType,ones(T,1));
    PTypel  = PTypelp(:);

    prior     = mean(PType);
    jointlike = sum(log(sum((ones(length(base),1)*prior).*base,2)));
end
