function output2 = makegrid2_con(d,f1,f2,f3,ngpct,S)
    tempora = [d(~f1 & ~f2 & ~f3,:);kron(ones(ngpct,1),d(f2,:));d(f1,:);kron(ones(ngpct,1),d(f3,:));d(f1,:);kron(ones(ngpct,1),d(f3,:))];
    output2 = kron(ones(S,1),tempora);
end
