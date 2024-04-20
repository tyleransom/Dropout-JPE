function [AdjNG,AdjG] = run_FV_CCP(staticparms,learnparms,gradparameters,learnStruct,dataStruct,consumpstructMCint,A,S,PmajgpaType,Beta,interestrate,Clb,CRRA,guess,ipath)

    %------------------------------------------------------------------------------
    % Read in data and parameters from all previous steps
    %------------------------------------------------------------------------------
    v2struct(staticparms.searchparms);
    load(strcat(ipath,'cmapoutput_',num2str(guess),'.mat'));
    cmapParms = struct('cmap_nograd',cmap_nograd,'cmap_nograd_work',cmap_nograd_work,'cmap_grad_work',cmap_grad_work,'scaler_nograd',scaler_nograd,'scaler_nograd_work',scaler_nograd_work,'scaler_grad_work',scaler_grad_work);
    load(strcat(ipath,'cmapoutput_t1_',num2str(guess),'.mat'));
    cmapParms_t1 = struct('cmap_nograd',cmap_nograd,'cmap_nograd_work',cmap_nograd_work,'cmap_grad_work',cmap_grad_work,'scaler_nograd',scaler_nograd,'scaler_nograd_work',scaler_nograd_work,'scaler_grad_work',scaler_grad_work); 
    load(strcat(ipath,'cmapoutput_t2_',num2str(guess),'.mat'));
    cmapParms_t2 = struct('cmap_nograd',cmap_nograd,'cmap_nograd_work',cmap_nograd_work,'cmap_grad_work',cmap_grad_work,'scaler_nograd',scaler_nograd,'scaler_nograd_work',scaler_nograd_work,'scaler_grad_work',scaler_grad_work); 
    intrate = 0.05;


    %------------------------------------------------------------------------------
    % Read in graduation logit estimates
    %------------------------------------------------------------------------------
    Xgrad          = gradparameters.Xlogit;
    P_grad_betas4  = gradparameters.P_grad_betas4;


    %------------------------------------------------------------------------------
    % Stack learning results data to conform to search-offer stacked data
    %------------------------------------------------------------------------------
    idelta = learnparms.Delta\eye(5,5);
    dataStruct.ideltaMat = repmat(reshape(idelta,[1 5 5]),[size(dataStruct.yrcl,1) 1 1]);
    priorabilstructsearch = prior_ability_DDC_search(learnparms,learnStruct,dataStruct,S);


    %------------------------------------------------------------------------------
    % Create future value terms from CCPs
    %------------------------------------------------------------------------------
    tic
    D = 10;
    CRRA
    boffer
    [AdjNG,AdjG] = formFVfricIntFast_b(Beta,staticparms.Utilstruct,boffer,P_grad_betas4,Xgrad,dataStruct,priorabilstructsearch,learnparms,staticparms.AR1parms,A,S,Clb,CRRA,intrate,D,bstrucsearch,dataStruct.Yl,cmapParms,cmapParms_t1,cmapParms_t2);
    save([ipath,'adjIntMatsSearchStructuralFast10D',num2str(guess)],'-v7.3','AdjNG','AdjG');
    disp(['Time spent creating FV terms: ',num2str(toc/60),' minutes']);

end
