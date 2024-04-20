 function [output,output2] = makegrid_maj_id(d,f1,f2,f3,ngpct,S)
%f1 = impMaj
%f2 = impGPA
%f3 = impBoth

    if size(d,2)==1
        assert(all(d==1),'wrong function!')
        output = [0*d(~f1 & ~f2 & ~f3);0*kron(ones(ngpct,1),d(f2));d(f1);kron(ones(ngpct,1),d(f3));2*d(f1);kron(ones(ngpct,1),2*d(f3))];
        output2 = kron(ones(S,1),output);
    else
        output = [d(~f1 & ~f2 & ~f3,:);kron(ones(ngpct,1),d(f2,:));d(f1,:);kron(ones(ngpct,1),d(f3,:));d(f1,:);kron(ones(ngpct,1),d(f3,:))];
        output2 = cat(2,kron(ones(S,1),output),kron(eye(S,S-1),ones(size(output,1),1)));
    end

end 
