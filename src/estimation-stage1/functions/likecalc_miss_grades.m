function [like] = likecalc_miss_grades(x, theta, y, f, df, N, T, G, S, sector)
    b     = theta(1:end-1);
    sigma = theta(end);


    % get predicted values
    p = x*b;


    % missing grades percentiles and cut points
    % create helpful flags for later use
    assert(G==4,'likecalc_miss_grades: number of GPA percentiles must be 4');
    fi  = (f & df.miss_gradeslImps & df.good_gradeslImps); 
    fi1 = (f & df.miss_gradeslImps & df.good_gradeslImps & y==df.pctilemat(1)); 
    fi2 = (f & df.miss_gradeslImps & df.good_gradeslImps & y==df.pctilemat(2)); 
    fi3 = (f & df.miss_gradeslImps & df.good_gradeslImps & y==df.pctilemat(3)); 
    fi4 = (f & df.miss_gradeslImps & df.good_gradeslImps & y==df.pctilemat(4)); 
    % unit testing
    assert(all(ismember(y(fi),df.pctilemat)),'likecalc_miss_grades: Grades not lined up properly');
    assert(all(y(fi1)==df.pctilemat(1)),'likecalc_miss_grades: Grades not lined up properly');
    assert(all(y(fi2)==df.pctilemat(2)),'likecalc_miss_grades: Grades not lined up properly');
    assert(all(y(fi3)==df.pctilemat(3)),'likecalc_miss_grades: Grades not lined up properly');
    assert(all(y(fi4)==df.pctilemat(4)),'likecalc_miss_grades: Grades not lined up properly');


    % build likelihood object
    like = ones(size(y));

    % first quartile (cutmat(2))
    like(fi1) =   normcdf(df.cutmat(2) - p(fi1),0,sigma);    % g1
    % second quartile minus first quartile (cutmat(3)-cutmat(2))
    like(fi2) =   normcdf(df.cutmat(3) - p(fi2),0,sigma) - ... g2 - g1
                  normcdf(df.cutmat(2) - p(fi2),0,sigma);
    % third quartile minus second quartile (cutmat(4)-cutmat(3))
    like(fi3) =   normcdf(df.cutmat(4) - p(fi3),0,sigma) - ... g3 - g2
                  normcdf(df.cutmat(3) - p(fi3),0,sigma);
    % 1 minus third quartile (cutmat(4))
    like(fi4) = 1-normcdf(df.cutmat(4) - p(fi4),0,sigma); % g4

    
    % examine and replace values if likelihood ever returns zero
    if any(like(fi1)==0) || any(like(fi2)==0) || any(like(fi3)==0) || any(like(fi4)==0)
        %disp('Some likelihoods are 0; here is summary stats on predicted values');
        %optis.Detail = 'on';
        %summarize([p(fi1) p(fi2) p(fi3) p(fi4)],optis);

        % likelihood for first quartile
        flg1 = fi1 & like==0;
        %sum(flg1)
        %Tfi1 = table(df.IDlImps(flg1),...
        %             y(flg1),...
        %             p(flg1),...
        %             df.cutmat(2) - p(flg1),...
        %             -Inf*ones(sum(flg1),1),...
        %             normcdf(df.cutmat(2) - p(flg1),0,sigma),...
        %             like(flg1),...
        %             'VariableNames',{'ID','GPA','pred_val','normcdf arg upper','norm cdf arg lower','normcdf diff','like'});
        %if any(flg1)
        %    Tfi1
        %end

        % likelihood for second quartile
        flg2 = fi2 & like==0;
        %sum(flg2)
        %Tfi2 = table(df.IDlImps(flg2),...
        %             y(flg2),...
        %             p(flg2),...
        %             df.cutmat(3) - p(flg2),...
        %             df.cutmat(2) - p(flg2),...
        %             normcdf(df.cutmat(3) - p(flg2),0,sigma)-normcdf(df.cutmat(2) - p(flg2),0,sigma),...
        %             like(flg2),...
        %             'VariableNames',{'ID','GPA','pred_val','normcdf arg upper','norm cdf arg lower','normcdf diff','like'});
        %if any(flg2)
        %    Tfi2
        %end

        % likelihood for third quartile
        flg3 = fi3 & like==0;
        %sum(flg3)
        %Tfi3 = table(df.IDlImps(flg3),...
        %             y(flg3),...
        %             p(flg3),...
        %             df.cutmat(4) - p(flg3),...
        %             df.cutmat(3) - p(flg3),...
        %             normcdf(df.cutmat(4) - p(flg3),0,sigma)-normcdf(df.cutmat(3) - p(flg3),0,sigma),...
        %             like(flg3),...
        %             'VariableNames',{'ID','GPA','pred_val','normcdf arg upper','norm cdf arg lower','normcdf diff','like'});
        %if any(flg3)
        %    Tfi3
        %end

        % likelihood for fourth quartile
        flg4 = fi4 & like==0;
        %sum(flg4)
        %Tfi4 = table(df.IDlImps(flg4),...
        %             y(flg4),...
        %             p(flg4),...
        %             Inf*ones(sum(flg4),1),...
        %             df.cutmat(4) - p(flg4),...
        %             1-normcdf(df.cutmat(4) - p(flg4),0,sigma),...
        %             like(flg4),...
        %             'VariableNames',{'ID','GPA','pred_val','normcdf arg upper','norm cdf arg lower','normcdf diff','like'});
        %if any(flg4)
        %    Tfi4
        %end
    

        % recode likelihoods that are zero to be epsilon
        if any(flg1)
            like(flg1) = eps;
            disp([sector,' grades: replaced ',num2str(sum(flg1)),' zero-likelihood values with eps in quartile 1'])
        end
        if any(flg2)
            like(flg2) = eps;
            disp([sector,' grades: replaced ',num2str(sum(flg2)),' zero-likelihood values with eps in quartile 2'])
        end
        if any(flg3)
            like(flg3) = eps;
            disp([sector,' grades: replaced ',num2str(sum(flg3)),' zero-likelihood values with eps in quartile 3'])
        end
        if any(flg4)
            like(flg4) = eps;
            disp([sector,' grades: replaced ',num2str(sum(flg4)),' zero-likelihood values with eps in quartile 4'])
        end
    end


    % formulate likelihood
    like = squeeze(prod(permute(reshape(like,[T N S]),[2 1 3]),2));
    

    % unit testing
    assert(size(like,1)==N && size(like,2)==S,'likecalc_miss_grades: dimensions of like are wrong')
    assert(all(all(like>0)),'likecalc_miss_grades: likelihood has zero values after prod over T');
    assert(~(any(any(like<0))),'likecalc_miss_grades: likelihood has negative values after prod over T');
end