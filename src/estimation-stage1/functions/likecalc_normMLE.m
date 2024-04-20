function [like] = likecalc_normMLE(x, theta, y, f, N, T, S)
    b     = theta(1:end-1);
    sigma = theta(end);

    % get predicted values
    p = x*b;
    
    % don't include NaNs that are outside of f
    y(isnan(y) & ~f) = 0;
    
    % reshape objects
    p = permute(reshape(p,[T N S]),[2 1 3]);
    y = permute(reshape(y,[T N S]),[2 1 3]); 
    f = permute(reshape(f,[T N S]),[2 1 3]); 
    
    like = squeeze(prod(normpdf(p, y, sigma) .^ f,2));
    assert(size(like,1)==N && size(like,2)==S,'likecalc_normMLE: dimensions of like are wrong')
    assert(all(all(like>0)),'likecalc_normMLE: likelihood has zero values');
    assert(~(any(any(like<0))),'likecalc_normMLE: likelihood has negative values');
end