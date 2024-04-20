function [] = mywritetable(tbl, filename)
    C = table2cell(tbl);
    fid = fopen(filename,'w');
    for i=1:size(C,1)
        % Initialize an empty format string
        fmt = '';
        % Loop over the cells in the current row
        for j=1:size(C,2)
            % Check the class of the cell and append the format specifier
            switch class(C{i,j})
                case 'double'
                    fmt = [fmt '%f,'];
                case 'char'
                    fmt = [fmt '%s,'];
                case 'logical'
                    fmt = [fmt '%d,'];
                % Add more cases for other data types if needed
            end
        end
        % Remove the last comma from the format string
        fmt = fmt(1:end-1);
        % Add a newline character at the end of the format string
        fmt = [fmt '\n'];
        % Write the current row to the file using the format string
        fprintf(fid,fmt,C{i,:});
    end
    fclose(fid);
end