function [output,output2] = makegrid(d,f1,f2,f3,ngpct,S)

    if size(d,2)==1
        output = [d(~f1 & ~f2 & ~f3);kron(ones(ngpct,1),d(f2));d(f1);kron(ones(ngpct,1),d(f3));d(f1);kron(ones(ngpct,1),d(f3))];
        output2 = kron(ones(S,1),output);
    else
        output = [d(~f1 & ~f2 & ~f3,:);kron(ones(ngpct,1),d(f2,:));d(f1,:);kron(ones(ngpct,1),d(f3,:));d(f1,:);kron(ones(ngpct,1),d(f3,:))];
        output2 = cat(2,kron(ones(S,1),output),kron(eye(S,S-1),ones(size(output,1),1)));
    end

end
