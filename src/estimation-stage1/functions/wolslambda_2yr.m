function SSE = wolslambda_2yr(b,y,x,abil,vabil,weight,sig2v)

SSE = sum(weight.*(log(sig2v) + (1./sig2v).*(vabil + (y - (x*b+abil)).^2)));
