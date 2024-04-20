function X = updater_wc_wage(X,age,scimaj,a,j,g)
    X(:,10)      = (age+a)<=0;
    X(:,11)      = (age+a)==1;
    X(:,12)      = (age+a)==2;
    X(:,16)      = g;
    X(:,17)      = scimaj*g;
    X(:,34)      = ismember(j,[4 9 14 17 24]); % current PT
end
