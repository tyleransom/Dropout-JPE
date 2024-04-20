function [PType,PType_ms,PTypeTilde,PmajgpaType,pi_maj,pi_gpa,jointlike,prior]=typeprob_complex(prior,base_nm,base_maj,base_gpa,base_majgpa,df,iter,G,S)
    %---------------------------------------------------------------------------
    % check that inputs are well-conditioned
    %---------------------------------------------------------------------------
    assert(all(~isnan(base_nm(:))),    'non-missing likelihood has NaNs');
    assert(all(~isnan(base_gpa(:))),   'missing GPA likelihood has NaNs');
    assert(all(~isnan(base_maj(:))),   'missing major likelihood has NaNs');
    assert(all(~isnan(base_majgpa(:))),'missing major & GPA likelihood has NaNs');
    assert(all(base_nm(:)>0),          'non-missing likelihood has 0s');
    assert(all(base_gpa(:)>0),         'missing GPA likelihood has 0s');
    assert(all(base_maj(:)>0),         'missing major likelihood has 0s');
    assert(all(base_majgpa(:)>0),      'missing major & GPA likelihood has 0s');


    %---------------------------------------------------------------------------
    % initialize and create helpful flags
    %---------------------------------------------------------------------------
    PType      = nan(df.N,S);
    PTypeTilde = nan(df.Ntilde,S);

    nm_flag     = 1:df.baseN;
    maj_flag    = df.baseN+df.NimpGPA+1:df.baseN+df.NimpGPA+df.NimpMaj;
    gpa_flag    = df.baseN+1:df.baseN+df.NimpGPA;
    majgpa_flag = df.baseN+df.NimpGPA+df.NimpMaj+1:df.N;


    %---------------------------------------------------------------------------
    % recover posterior type probabilities
    %---------------------------------------------------------------------------
    % case 1: nothing missing (eq. D.1)
    temp0 = nan(df.baseN,S);
    for s=1:S
        temp0(nm_flag,s) = prior(s)*base_nm(:,s)./(base_nm*prior');
    end
    PType(nm_flag,:) = temp0;
    temp0denom = base_nm*prior';

    % case 2: missing major (eq. D.2)
    temp1 = nan(df.NimpMaj,S,2);
    for s=1:S
        for m=1:2
            temp1(:,s,m) = (prior(s)*base_maj(:,s,m))./(sum(base_maj,3)*prior');
        end
    end
    PType(maj_flag,:) = sum(temp1,3);
    temp1denom = sum(base_maj,3)*prior';

    % case 3: missing GPA (eq. D.3) 
    temp2 = nan(df.NimpGPA,S,G);
    for s=1:S
        for g=1:G
            temp2(:,s,g) = (prior(s)*base_gpa(:,s,g))./(sum(base_gpa,3)*prior');
        end
    end
    PType(gpa_flag,:) = sum(temp2,3);
    temp2denom = sum(base_gpa,3)*prior';

    % case 4: missing major and GPA (eq. D.4) 
    temp3 = nan(df.NimpMajGPA,S,2,G);
    for s=1:S
        for m=1:2
            for g=1:G
                temp3(:,s,m,g) = (prior(s)*base_majgpa(:,s,m,g))./(sum(sum(base_majgpa,4),3)*prior');
            end
        end
    end
    PType(majgpa_flag,:) = sum(sum(temp3,4),3);
    temp3denom = sum(sum(base_majgpa,4),3)*prior';

    %---------------------------------------------------------------------------
    % reshape posterior probabilities
    %---------------------------------------------------------------------------
    % create PTypeTilde which is Ntilde x S instead of N x S (like PType)
    % non-missings
    PTypeTilde(nm_flag,:) = temp0;
    % missing major
    PTypeTilde(df.Ntilde1+1:df.Ntilde2,:) = temp1(:,:,1);
    PTypeTilde(df.Ntilde3+1:df.Ntilde4,:) = temp1(:,:,2);
    % missing GPA
    for g=1:G
        PTypeTilde(df.baseN+(g-1)*df.NimpGPA+1:df.baseN+g*df.NimpGPA,:) = temp2(:,:,g);
    end
    % missing major and GPA
    for g=1:G
        PTypeTilde(df.Ntilde2+(g-1)*df.NimpMajGPA+1:df.Ntilde2+g*df.NimpMajGPA,:) = temp3(:,:,1,g);
        PTypeTilde(df.Ntilde4+(g-1)*df.NimpMajGPA+1:df.Ntilde4+g*df.NimpMajGPA,:) = temp3(:,:,2,g);
    end

    % reshape
    PmajgpaTypew = kron(PTypeTilde,ones(df.T,1));
    PmajgpaType  = PmajgpaTypew(:);
    
    % PType ordered according to measurement system data
    PType_ms = PType(df.invIDImp,:);

    %---------------------------------------------------------------------------
    % recover missing major and missing GPA "population" probabilities
    %---------------------------------------------------------------------------
    qm     = [squeeze(sum(temp1,2));squeeze(sum(sum(temp3,4),2))];
    qg     = [squeeze(sum(temp2,2));squeeze(sum(sum(temp3,3),2))];
    pi_maj = mean(qm,1);
    pi_gpa = mean(qg,1);

    %---------------------------------------------------------------------------
    % backend unit testing
    %---------------------------------------------------------------------------
    % make sure there are no NaNs in updated likelihoods
    [rr,cc,vv] = find(temp0==0);
    assert(all(all(~isnan(temp0))),['NaNs in non-missing q''s at rows ',num2str(unique(rr'))]);
    assert(all(~isnan(temp1(:))),'NaNs in missing major q''s');
    assert(all(~isnan(temp2(:))),'NaNs in missing GPA q''s');
    assert(all(~isnan(temp3(:))),'NaNs in missing major & GPA q''s');

    % make sure there are no NaNs in q's
    assert(sum(isnan(PTypeTilde(:)))==0,['PTypeTilde has NaNs in ',num2str(sum(isnan(PTypeTilde(:)))/S),' rows']);


    % make sure things sum to 1
    assert(all(abs(sum(temp0,2)               - 1) < 1e-10),'Each row of temp0 should sum to 1');
    assert(all(abs(sum(sum(temp1,3),2)        - 1) < 1e-10),'Each row of temp1 should sum to 1');
    assert(all(abs(sum(sum(temp2,3),2)        - 1) < 1e-10),'Each row of temp2 should sum to 1');
    assert(all(abs(sum(sum(sum(temp3,4),3),2) - 1) < 1e-10),'Each row of temp3 should sum to 1');

    if iter<3
        % make sure transformed PmajgpaType sums to 1 within person
        %summarize(PmajgpaType);
        %PmajgpaType(df.IDlImps==2)
        %size(df.IDlImps)
        %size(PmajgpaType)
        sum_IDlImps = nan(df.N,1);
        for i = 1:df.N
            sum_IDlImps(i) = sum(PmajgpaType(df.IDlImps==i));
            softAssert(abs(sum_IDlImps(i) - df.T) < 1e-10,['ID ',num2str(i),' does not have q''s that sum to 1; instead, they sum to ',num2str(sum(df.IDlImps(i)))]);
        end
        assert(all(abs(sum_IDlImps - df.T) < 1e-10),'q''s need to sum to 1 within ID');
    end

    prior = mean(PType);

    alldenom  = [sum(temp0denom,2);sum(temp1denom,2);sum(temp2denom,2);sum(temp3denom,2)];
    jointlike = sum(log(alldenom));
end
