function table = tabulate_wgt(x, frequency)
    %TABULATE Frequency table.
    %   TABLE = TABULATE(X, FREQUENCY) takes a vector X and returns a matrix, TABLE.
    %   The first column of TABLE contains the unique values of X.  The
    %   second is the number of instances of each value.  The last column
    %   contains the percentage of each value.  If the elements of X are
    %   non-negative integers, then the output includes 0 counts for any
    %   integers that are between 1 and max(X) but do not appear in X. The counts
    %   (second column) and percentage (third column) use frequency.
    %
    %   TABLE = TABULATE(X), where X is a categorical variable, character
    %   array, or a cell array of strings, returns TABLE as a cell array.  The
    %   first column contains the unique string values in X, and the other two
    %   columns are as above. The last row of the table is the total
    %
    %   TABULATE with no output arguments returns a formatted table
    %   in the command window.
    %
    %   If X is numeric, missing values are removed
    %
    %   See also PARETO.

    %   Copyright 1993-2011 The MathWorks, Inc.
    %   Modified 5/13/14 - Kristofer D. Kusano (github link: https://gist.github.com/KrisKusano/243cb7befc5a358a0735)

    isnum = isnumeric(x);
    if isnum && ~isfloat(x)
        % use of hist() below requires float
        x = double(x);
    end
    if isnum
        if min(size(x)) > 1,
            error(message('stats:tabulate:InvalidData'));
        end

        y = x(~isnan(x));
        wgt = frequency(~isnan(x));
    else
        y = x;
        wgt = frequency;
    end

    if ~isnum || any(y ~= round(y)) || any(y < 1);
        docell = true;
        [y,yn,yl] = grp2idx(y);

        imissing = isnan(y);
        y = y(~imissing);
        wgt = wgt(~imissing); 

        maxlevels = length(yn);
    else
        docell = false;
        maxlevels = max(y);
        %yn = cellstr(num2str((1:maxlevels)'));
    end

    [~, values] = hist(y,(1:maxlevels));

    % kdk: use freqnecy
    [~, Ni] = histc(y, linspace(min(y), max(y), maxlevels));
    counts = zeros(1, maxlevels);
    for j = 1:maxlevels
        counts(j) = sum(wgt(Ni == j));
    end

    % total = sum(counts);
    % percents = 100*counts./total;

    % kdk total and sum are weight
    total = sum(wgt);
    percents = 100*counts./total;

    if nargout == 0
        if docell
            width = max(cellfun('length',yn));
            width = max(5, min(50, width));
        else
            width = 5;
        end

        % Create format strings similar to:   '  %5s    %5d    %6.2f%%\n'
        % kdk: expand for big numbers
        fmt1 = sprintf('  %%%ds    %%8.0f    %%6.2f%%%%\n',width);
        fmt2 = sprintf('  %%%ds    %%8s   %%6s\n',width);
        fprintf(1,fmt2,'Value','Count','Percent');
        if docell
            for j=1:maxlevels
                fprintf(1,fmt1,yn{j},counts(j),percents(j));
            end
        else
            fprintf(1,'  %5d    %8.0f    %6.2f%%\n',[values' counts' percents']');
        end
        fprintf(1, fmt1, 'Total', total, sum(percents))
    else
        if ~docell
            table = [values' counts' percents'];
            table = vertcat(table, [NaN, total, sum(percents)]);
        elseif isnum
            table = [yl(:) counts' percents'];
            table = vertcat(table, [NaN, total, sum(percents)]);
        else
            table = [yn num2cell([counts' percents'])];
            table = vertcat(table, {'Total', total, sum(percents)});
        end
    end
end
