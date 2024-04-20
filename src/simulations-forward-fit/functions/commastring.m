function [nstr,nfmt] = commastring(N);
if N<1e3
	nstr  = num2str(N)
	nfmt  = cat(2,['%'],num2str(length(nstr)),['s']);
elseif N>=1e3 && N<1e6
	% Convenience terms
	p1 = floor(N/1e3);
	p  = floor(N/1e3)*1e3;
	% First three digits
	nstr1 = num2str(p1);
	% Last three digits
	if N-p <100 && N-p >=10
		nstr2 = cat(2,['0'],num2str(N-p));
	elseif N-p <10
		nstr2 = cat(2,['00'],num2str(N-p));
	else
		nstr2 = num2str(N-p);
	end
	% Combine
	nstr  = cat(2,nstr1,[','],nstr2);
	nfmt  = cat(2,['%'],num2str(length(nstr)),['s']);
elseif N>=1e6 && N<1e9
	% Convenience terms
	p2 = floor(N/1e6);
	p1 = floor(N/1e3);
	p0 = floor(N/1e6)*1e3;
	p  = (p1-p0)*1e3+p2*1e6;
	% First three digits
	nstr1 = num2str(p2);
	% Next three digits
	if p1-p0<100 && p1-p0>=10
		nstr2 = cat(2,['0'],num2str(p1-p0));
	elseif p1-p0<10
		nstr2 = cat(2,['00'],num2str(p1-p0));
	else
		nstr2 = num2str(p1-p0);
	end
	% Last three digits
	if N-p <100 && N-p >=10
		nstr3 = cat(2,['0'],num2str(N-p));
	elseif N-p <10
		nstr3 = cat(2,['00'],num2str(N-p));
	else
		nstr3 = num2str(N-p);
	end
	nstr  = cat(2,nstr1,[','],nstr2,[','],nstr3);
	nfmt  = cat(2,['%'],num2str(length(nstr)),['s']);
else
	error('This function only works for numbers strictly between 1 and 1,000,000,000)')
end