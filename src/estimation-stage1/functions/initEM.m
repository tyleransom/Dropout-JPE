function [PTypes,PmajgpaTypes,PmajgpaTypew,PmajgpaType,oPmajgpaType] = initEM(PType,inputStruct,ngpct,S)
    v2struct(inputStruct)
    
    % Set up EM weights
    PTypes       = cat(1,PType(~everImpMaj & ~everImpGPA & ~everImpMajGPA,:),PType(everImpGPA,:),PType(everImpMaj,:),PType(everImpMajGPA,:));
    PmajgpaTypes = makegridq(PType,everImpMaj,everImpGPA,everImpMajGPA,ngpct,S);
    assert(size(PmajgpaTypes,1)==Ntilde,'Problem creating PmajgpaTypes')

    PmajgpaTypew = kron(PmajgpaTypes,ones(T,1));
    PmajgpaType  = PmajgpaTypew(:);
    oPmajgpaType = zeros(Ntilde*T*S,1);
    
end
