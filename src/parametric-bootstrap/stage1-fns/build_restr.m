function restrMat = build_restr(vct,num_total_b,S)

% Unpack structure of the vector
nzparms   = unique(vct(vct~=0));
numnzparm = length(unique(vct(vct~=0)));

% Build restrictions
restrMat = zeros(0,5);

% non-zero restrictions
for j=1:numnzparm
    for k=find(vct==nzparms(j),length(find(vct==nzparms(j)))-1,'Last')'
        restrMat = cat(1,restrMat,[num_total_b-S+k num_total_b-S+find(vct==nzparms(j),1) 1 1 0]);
    end
end

% zero restrictions
for k=find(vct==0)'
    restrMat = cat(1,restrMat,[num_total_b-S+k 0 0 0 0]);
end

restrMat = sortrows(restrMat,1);

end
