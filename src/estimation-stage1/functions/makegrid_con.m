function [output,output2] = makegrid_con(d,f1,f2,f3,ngpct,S)

    A=[1 1 1; 1 1 0; 1 0 1; 1 0 0; 0 1 1; 0 1 0; 0 0 1; 0 0 0];

    if size(d,2)==1
        output = [d(~f1 & ~f2 & ~f3);kron(ones(ngpct,1),d(f2));d(f1);kron(ones(ngpct,1),d(f3));d(f1);kron(ones(ngpct,1),d(f3))];
        output2 = kron(ones(S,1),output);
    else
        output = [d(~f1 & ~f2 & ~f3,:);kron(ones(ngpct,1),d(f2,:));d(f1,:);kron(ones(ngpct,1),d(f3,:));d(f1,:);kron(ones(ngpct,1),d(f3,:))];
        output2 = cat(2,kron(ones(S,1),output),kron(A,ones(size(output,1),1)));
    end

end
