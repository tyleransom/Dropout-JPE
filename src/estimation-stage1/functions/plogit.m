function P=plogit(b,nb,X,nc)

if ~isequal(nb*(nc-1),numel(b))
	error('number of alternatives don''t match with 2nd dimension of X!');
end

j=1;

num=zeros(size(X,1),1);
dem=0;
while j<nc
    
    temp=X*b(1+(j-1)*nb:j*nb);
    
    num(:,j)=exp(temp);
    
    dem=exp(temp)+dem;
    
    j=j+1;
end

num=[num ones(size(X,1),1)];
dem=dem+1;

P=num./(dem*ones(1,nc));


    
    
    
