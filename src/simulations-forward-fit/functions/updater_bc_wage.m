function X = updater_bc_wage(X,age,scimaj,a,j,g)
    X(:,10)      = (age+a)<=0;
    X(:,11)      = (age+a)==1;
    X(:,12)      = (age+a)==2;
    X(:,16)      = g;
    X(:,17)      = scimaj*g;
    X(:,34)      = ismember(j,[3 8 13 16 23]); % current PT
end
