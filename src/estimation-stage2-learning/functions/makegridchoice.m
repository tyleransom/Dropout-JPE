function [output,output2] = makegridchoice(d1,d2,d3,f1,f2,f3,ngpct,S)
    
    if size(d1,2)==1
        output = [d1(~f1 & ~f2 & ~f3);kron(ones(ngpct,1),d1(f2));d2(f1);kron(ones(ngpct,1),d2(f3));d3(f1);kron(ones(ngpct,1),d3(f3))];
        output2 = kron(ones(S,1),output);
    else
        output = [d1(~f1 & ~f2 & ~f3,:);kron(ones(ngpct,1),d1(f2,:));d2(f1,:);kron(ones(ngpct,1),d2(f3,:));d3(f1,:);kron(ones(ngpct,1),d3(f3,:))];
        output2 = cat(2,kron(ones(S,1),output),kron(eye(S,S-1),ones(size(output,1),1)));
    end
    
end
