function test(varargin)
    % Create an input parser object
    p = inputParser;

    % Add optional parameters
    addOptional(p, 'arg1', '', @(x) ischar(x));
    addOptional(p, 'arg2', '', @(x) ischar(x));

    % Parse inputs
    parse(p, varargin{:});

    % Get the values of the arguments
    arg1 = p.Results.arg1;
    arg2 = p.Results.arg2;

    % Initialize flags
    zeroFlag = false;
    oneFlag = false;

    % Check the arguments and set flags
    if strcmp(arg1, '-zero') || strcmp(arg2, '-zero')
        zeroFlag = true;
    end
    if strcmp(arg1, '-one') || strcmp(arg2, '-one')
        oneFlag = true;
    end

    % Determine the output based on flags
    if zeroFlag && oneFlag
        disp(1);
    elseif zeroFlag
        disp(3);
    else
        disp(0);
    end
end
