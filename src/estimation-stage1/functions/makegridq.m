function output = makegridq(d,f1,f2,f3,ngpct,S)

    output = [d(~f1 & ~f2 & ~f3,:);kron(ones(ngpct,1),(1/ngpct)*d(f2,:));(1/2)*d(f1,:);kron(ones(ngpct,1),(1/(2*ngpct))*d(f3,:));(1/2)*d(f1,:);kron(ones(ngpct,1),(1/(2*ngpct))*d(f3,:))];

end
