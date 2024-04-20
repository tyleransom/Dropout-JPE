function s = injectnoise(s, fields, noiselevel)

    % Define the lower and upper bounds for the uniform random number
    lowerBound = -1*noiselevel;
    upperBound = noiselevel;

    % Loop over each field of the struct
    for i = 1:length(fields)
        % Get the value of the current field
        value = s.(fields{i});
        
        % Check if the value is numeric
        if isnumeric(value)
            % Generate a uniform random number of the same size as the value
            uniformNoise = lowerBound + (upperBound - lowerBound) * rand(size(value));
            
            % Scale and add the noise to the value
            noisyValue = value + value .* uniformNoise;
            
            % Assign the noisy value to the same field of the struct
            s.(fields{i}) = noisyValue;
        end
    end
end
