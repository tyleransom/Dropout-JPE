function [learningparms,gradparms,dataStruct,learnStruct] = run_learning(PType,PTypel,learnparms,allst,currst,A,S)

    %------------------------------------------------------------------------------
    % Process data
    %------------------------------------------------------------------------------
    % load the main database and manipulate it
    dataStruct  = createchoicedata(allst,currst,S);

    % This creates the main elements for the learning data
    learnStruct = createlearningdata(dataStruct,A,S);

    %------------------------------------------------------------------------------
    % Estimate the learning model and update parameter values (incl. prior abil.)
    %------------------------------------------------------------------------------
    tic
    learningparms = estimatelearning(dataStruct,learnStruct,learnparms,PType,PTypel,S);
    disp(['Time spent running learning estimation: ',num2str(toc/60),' minutes']);

    % update prior abilities
    priorabilstruct = prior_ability_DDC(learnparms,learnStruct,dataStruct,S);

    %------------------------------------------------------------------------------
    % graduation estimation
    %------------------------------------------------------------------------------
    tic
    test = false;        
    gradparms = estimategradlogit(dataStruct,priorabilstruct,PTypel,A,S);
    disp(['Time spent running graduation logit estimation: ',num2str(toc),' seconds']);

end