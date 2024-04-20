function [final_like_nm,final_like_maj,final_like_gpa,final_like_majgpa] = likecalc(base,df,num_GPA_pctiles,S)
    %--------------------------------------------------------------------------
    % unit testing for 0 likelihood values in component likelihoods
    %--------------------------------------------------------------------------
    e4 = any(any(base<=0));
    if e4
        softAssert(~(any(~any(base<0))),'base likelihood has negative values');
        softAssert(all(all(base>0)),'base likelihood has zero values');
        error('likecalc: a likelihood value is exactly zero');
    end


    %--------------------------------------------------------------------------
    % Combine likelihoods
    %--------------------------------------------------------------------------
    % case 1: no missing data
    nm_flag = 1:df.baseN;
    final_like_nm = base(nm_flag,:);


    % case 2: missing major but no missing grades
    maj_flag = [df.Ntilde1+1:df.Ntilde2 df.Ntilde3+1:df.Ntilde4];
    final_like_maj = base(maj_flag,:);
    final_like_maj = permute(reshape(final_like_maj,[df.NimpMaj 2 S]),[1 3 2]);
    % unit testing
    tester = permute(reshape(repmat(df.IDImps(maj_flag),1,S),[df.NimpMaj 2 S]),[1 3 2]);
    teste2 = [1*ones(df.NimpMaj,S);2*ones(df.NimpMaj,S)];
    teste3 = permute(reshape(teste2,[df.NimpMaj 2 S]),[1 3 2]); 
    assert(all(all(tester(1,:,:)==4)),'final_like_maj not lined up appropriately');
    assert(all(all(teste3(:,:,1)==1)),'final_like_maj not lined up appropriately');
    assert(all(all(teste3(:,:,2)==2)),'final_like_maj not lined up appropriately');


    % case 3: missing grades but no missing major
    gpa_flag = df.baseN+1:df.Ntilde1;
    final_like_gpa = base(gpa_flag,:);
    final_like_gpa = permute(reshape(final_like_gpa,[df.NimpGPA num_GPA_pctiles S]),[1 3 2]);
    % unit testing
    tester = permute(reshape(repmat(df.IDImps(gpa_flag),1,S),[df.NimpGPA num_GPA_pctiles S]),[1 3 2]);
    teste2 = [1*ones(df.NimpGPA,S);2*ones(df.NimpGPA,S);3*ones(df.NimpGPA,S);4*ones(df.NimpGPA,S)];
    teste3 = permute(reshape(teste2,[df.NimpGPA num_GPA_pctiles S]),[1 3 2]); 
    assert(all(all(tester(1,:,:)==9)),'final_like_gpa not lined up appropriately');
    assert(all(all(teste3(:,:,1)==1)),'final_like_gpa not lined up appropriately');
    assert(all(all(teste3(:,:,2)==2)),'final_like_gpa not lined up appropriately');
    assert(all(all(teste3(:,:,3)==3)),'final_like_gpa not lined up appropriately');
    assert(all(all(teste3(:,:,4)==4)),'final_like_gpa not lined up appropriately');


    % case 4: missing grades and major
    majgpa_flag = [df.Ntilde2+1:df.Ntilde3 df.Ntilde4+1:df.Ntilde5];
    final_like_majgpa = base(majgpa_flag,:);
    final_like_majgpa = permute(reshape(final_like_majgpa,[df.NimpMajGPA num_GPA_pctiles 2 S]),[1 4 3 2]);
    % unit testing
    tester = permute(reshape(repmat(df.IDImps(majgpa_flag),1,S),[df.NimpMajGPA num_GPA_pctiles 2 S]),[1 4 3 2]); 
    teste2 = [11*ones(df.NimpMajGPA,S);12*ones(df.NimpMajGPA,S);13*ones(df.NimpMajGPA,S);14*ones(df.NimpMajGPA,S);21*ones(df.NimpMajGPA,S);22*ones(df.NimpMajGPA,S);23*ones(df.NimpMajGPA,S);24*ones(df.NimpMajGPA,S)];
    teste3 = permute(reshape(teste2,[df.NimpMajGPA num_GPA_pctiles 2 S]),[1 4 3 2]); 
    assert(all(all(all(tester(1,:,:,:)==1 ))),'final_like_majgpa not lined up appropriately');
    assert(all(all(all(tester(2,:,:,:)==29))),'final_like_majgpa not lined up appropriately');
    assert(all(all(teste3(:,:,1,1)==11)),     'final_like_majgpa not lined up appropriately');
    assert(all(all(teste3(:,:,1,2)==12)),     'final_like_majgpa not lined up appropriately');
    assert(all(all(teste3(:,:,1,3)==13)),     'final_like_majgpa not lined up appropriately');
    assert(all(all(teste3(:,:,1,4)==14)),     'final_like_majgpa not lined up appropriately');
    assert(all(all(teste3(:,:,2,1)==21)),     'final_like_majgpa not lined up appropriately');
    assert(all(all(teste3(:,:,2,2)==22)),     'final_like_majgpa not lined up appropriately');
    assert(all(all(teste3(:,:,2,3)==23)),     'final_like_majgpa not lined up appropriately');
    assert(all(all(teste3(:,:,2,4)==24)),     'final_like_majgpa not lined up appropriately');


    %--------------------------------------------------------------------------
    % unit testing for 0 likelihood values in component likelihoods
    %--------------------------------------------------------------------------
    e4 = any(any(base<=0));
    if e4
        softAssert(~(any(any(base<0))),'base likelihood has negative values');
        softAssert(all(all(base>0)),'base likelihood has zero values');
        error('likecalc: a likelihood value is exactly zero');
    end


    %--------------------------------------------------------------------------
    % unit testing for NaN likelihood values in overall likelihoods
    %--------------------------------------------------------------------------
    assert(all(all(~isnan(final_like_nm)))              ,'non-missing likelihood has NaN values');
    assert(all(all(all(~isnan(final_like_maj))))        ,'missing major likelihood has NaN values');
    assert(all(all(all(~isnan(final_like_gpa))))        ,'missing gpa likelihood has NaN values');
    assert(all(all(all(all(~isnan(final_like_majgpa))))),'missing major & gpa likelihood has NaN values');


    %--------------------------------------------------------------------------
    % unit testing for 0 likelihood values in overall likelihoods
    %--------------------------------------------------------------------------
    assert(all(all(final_like_nm>0))              ,'non-missing likelihood has zero values');
    assert(all(all(all(final_like_maj>0)))        ,'missing major likelihood has zero values');
    assert(all(all(all(final_like_gpa>0)))        ,'missing gpa likelihood has zero values');
    assert(all(all(all(all(final_like_majgpa>0)))),'missing major & gpa likelihood has zero values');
end