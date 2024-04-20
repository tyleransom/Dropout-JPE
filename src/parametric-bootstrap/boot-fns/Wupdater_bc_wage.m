function X = Wupdater_bc_wage(X,age,cumSch,scimaj,a,j,g,e,wce,c2,c4)
    X(:,10)      = (age+a)<=0;
    X(:,11)      = (age+a)==1;
    X(:,12)      = (age+a)==2;
    X(:,13)      = (X(:,13)+e);
    X(:,14)      = (X(:,14)+wce);
    X(:,16)      = g;
    X(:,17)      = scimaj*g;
    X(:,34)      = ismember(j,[3 8 13 16]); % current PT
end
