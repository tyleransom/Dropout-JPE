function like = likecalc_logit(x,parm,y,f,N,T,S)
    % computes likelihood of binary logit model

    % get predicted probabilities
    p = glmval(parm,x,'logit','constant','off');
    
    % reshape objects
    p = permute(reshape(p,[T N S]),[2 1 3]);
    y = permute(reshape(y,[T N S]),[2 1 3]); 
    f = permute(reshape(f,[T N S]),[2 1 3]); 
    
    like = squeeze(prod(p.^(y.*f) .* (1-p).^((1-y).*f),2));
    assert(size(like,1)==N && size(like,2)==S,'likecalc_logit: dimensions of like are wrong')
    assert(all(all(like>0)),'likecalc_logit: likelihood has zero values');
    assert(~(any(any(like<0))),'likecalc_logit: likelihood has negative values');
end