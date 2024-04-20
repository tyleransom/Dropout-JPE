function SSE = wolslambda_joint(b,yn,xn,idxn,abiln,vabiln,sectorn,weightn,yg,xg,idxg,abilg,vabilg,sectorg,weightg,sig2vg,sig2vn)
sxn       = size(xn,2);
lambdaydg = 1; %b(end-2);
lambdag0  = b(end-1);
lambdag1  = b(end);
betag     = b(sxn+3:end-2);
lambdan0  = b(sxn+1);
lambdan1  = b(sxn+2);
betan     = b(1:sxn);
if ~isempty(idxg)
    nidxg = setdiff(1:size(xg,2),idxg);
end

% sector=1 corresponds to subset of observations that get hit by lambda
% sector=0 corresponds to all other observations
lambdag0v             = zeros(size(yg));
lambdag0v(sectorg==1) = lambdag0;
lambdag1v             = ones(size(yg));
lambdag1v(sectorg==1) = lambdag1;
lambdan0v             = zeros(size(yn));
lambdan0v(sectorn==1) = lambdan0;
lambdan1v             = ones(size(yn));
lambdan1v(sectorn==1) = lambdan1;


if ~isequal(size(yg),size(sectorg))
	error('sector g variable is wrong')
end

if ~isequal(size(yn),size(sectorn))
	error('sector n variable is wrong')
end

residg = weightg.*(log(sig2vg) + (1./sig2vg).*(vabilg.*(lambdag1v).^2 + (yg-lambdaydg*(xg(:,idxg)*betan(idxn)) - lambdag0v - lambdag1v.*(xg(:,nidxg)*betag       +abilg)).^2)); %betag doesn't have the year dummies in it
residn = weightn.*(log(sig2vn) + (1./sig2vn).*(vabiln.*(lambdan1v).^2 + (yn-           xn(:,idxn)*betan(idxn)  - lambdan0v - lambdan1v.*(xn(:,nidxg)*betan(nidxg)+abiln)).^2)); %betan has the year dummies in it

SSE = sum([residg;residn]); 
