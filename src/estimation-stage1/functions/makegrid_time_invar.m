function output = makegrid_time_invar(d,f1,f2,f3)
    output = [d(~f1 & ~f2 & ~f3);d(f2);d(f1);d(f3)];
    %IDImp = [dataStruct.ID(~dataStruct.everImpMaj & ~dataStruct.everImpGPA & ~dataStruct.everImpMajGPA);dataStruct.ID(dataStruct.everImpGPA);dataStruct.ID(dataStruct.everImpMaj);dataStruct.ID(dataStruct.everImpMajGPA)];
end