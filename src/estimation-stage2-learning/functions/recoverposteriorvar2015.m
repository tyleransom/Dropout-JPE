function [output] = recoverposteriorvar2015(dataStruct,priorabilstruct,PmajgpaType,S);
    disp('printing some summary stats on prior variances');
    %load everything11834288.mat
    [dataStruct.anyFlagImps,dataStruct.anyFlaglImps] = makegrid(dataStruct.anyFlag,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S);
    [dataStruct.yearImps,dataStruct.yearlImps] = makegrid(dataStruct.year,dataStruct.impMajlp,dataStruct.impGPAlp,dataStruct.impMajGPAlp,dataStruct.num_GPA_pctiles,S);

    % unweighted
    summarize([squeeze(priorabilstruct.vabilpriormat(dataStruct.yearlImps==2015 & dataStruct.anyFlaglImps==0,1,1)) squeeze(priorabilstruct.vabilpriormat(dataStruct.yearlImps==2015 & dataStruct.anyFlaglImps==0,2,2)) squeeze(priorabilstruct.vabilpriormat(dataStruct.yearlImps==2015 & dataStruct.anyFlaglImps==0,3,3)) squeeze(priorabilstruct.vabilpriormat(dataStruct.yearlImps==2015 & dataStruct.anyFlaglImps==0,4,4)) squeeze(priorabilstruct.vabilpriormat(dataStruct.yearlImps==2015 & dataStruct.anyFlaglImps==0,5,5))]);

    % weighted by q's
    options = struct('Detail','off','Weights',PmajgpaType(dataStruct.yearlImps==2015 & dataStruct.anyFlaglImps==0));
    summarize([squeeze(priorabilstruct.vabilpriormat(dataStruct.yearlImps==2015 & dataStruct.anyFlaglImps==0,1,1)) squeeze(priorabilstruct.vabilpriormat(dataStruct.yearlImps==2015 & dataStruct.anyFlaglImps==0,2,2)) squeeze(priorabilstruct.vabilpriormat(dataStruct.yearlImps==2015 & dataStruct.anyFlaglImps==0,3,3)) squeeze(priorabilstruct.vabilpriormat(dataStruct.yearlImps==2015 & dataStruct.anyFlaglImps==0,4,4)) squeeze(priorabilstruct.vabilpriormat(dataStruct.yearlImps==2015 & dataStruct.anyFlaglImps==0,5,5))],options);
    output = NaN;
end
