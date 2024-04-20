function Xgrad = createXgrad(data,priorabilstruct,j);
    c2 = data.cum_2yr;
    c4 = data.cum_4yr;
    Xgrad = [ones(size(data.black)) data.black data.hispanic data.HS_grades data.Parent_college data.born1980 data.born1981 data.born1982 data.born1983 data.famInc c2==0 c2>=2 c4==2 c4==3 c4==4 c4==5 c4>=6 (c4==2).*(c2==0) (c4==4).*(c2==0) (c4==5).*(c2==0) (c4>=6).*(c2==0) ismember(j,6:10)*ones(size(data.black)) priorabilstruct.prior_ability_4S.*ismember(j,6:10) priorabilstruct.prior_ability_4NS.*ismember(j,11:15) ismember(j,[8 9 13 14])*ones(size(data.black)) ismember(j,[6 7 11 12])*ones(size(data.black)) ismember(data.utype,1:4) ismember(data.utype,[1:2 5:6]) ismember(data.utype,[1 3 5 7])];
end
