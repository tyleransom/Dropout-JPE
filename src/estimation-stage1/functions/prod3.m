function result = prod3(varargin)
    % Concatenate the input arguments along the third dimension
    inputs = cat(3,varargin{:});
    % Take the product across the third dimension
    result = prod(inputs,3);
end
