% File Name : test.m
% By default, it won't display any values. You need to pass arguments to view specific data.

% - `debug` - No display.
% - `debug('-raw')` - Displays raw sensor values.
% - `debug('-filt')` - Displays filtered sensor values.
% - `debug('-calib')` - Displays calibrated, filtered values.
% - `debug('-f')` - Displays resultant forces from each motor.

% You can combine arguments to view multiple data sets simultaneously, 
% such as `debug('-filt', '-calib')` to display both filtered and calibrated values.

function debug(varargin)

    %% Initialization
    if exist('dq', 'var') == 0          % In the case "dq" does not exist
        global dq;                      % Ensure the "dq" variable can be accessed and modified globally.
        dq = init_dq;                   % Initialization of the sensors and the actuators
    end

    clearvars -except varargin dq;      % Clear all previous values that were initialized
    
    filtered = 0;                       % Indicating that the values have never been filtered
        
    jsonData = fileread('offset.json'); % Read JSON file
    data = jsondecode(jsonData);        % Parse JSON data
    offset = data.offset;               % Access vectors
    
    %% Setting up the flags 
    % Create an input parser object
    p = inputParser;

    % Add optional parameters
    addOptional(p, 'arg1', '', @(x) ischar(x));
    addOptional(p, 'arg2', '', @(x) ischar(x));
    addOptional(p, 'arg3', '', @(x) ischar(x));
    addOptional(p, 'arg4', '', @(x) ischar(x));

    % Parse inputs
    parse(p, varargin{:});

    % Get the values of the arguments
    arg1 = p.Results.arg1;
    arg2 = p.Results.arg2;
    arg3 = p.Results.arg3;
    arg4 = p.Results.arg4;

    % Initialize flags
    raw_flag = false;
    filt_flag = false;
    calib_flag = false;
    f_flag = false;

    % Check the arguments and set flags
    if strcmp(arg1, '-raw') || strcmp(arg2, '-raw') || strcmp(arg3, '-raw') || strcmp(arg4, '-raw')
        raw_flag = true;
    end
    if strcmp(arg1, '-filt') || strcmp(arg2, '-filt') || strcmp(arg3, '-filt') || strcmp(arg4, '-filt')
        filt_flag = true;
    end
    if strcmp(arg1, '-calib') || strcmp(arg2, '-calib') || strcmp(arg3, '-calib') || strcmp(arg4, '-calib')
        calib_flag = true;
    end
    if strcmp(arg1, '-f') || strcmp(arg2, '-f') || strcmp(arg3, '-f') || strcmp(arg4, '-f')
        f_flag = true;
    end
    
    %% Infinite loop : Displaying the values
    while 1
    
        %% Getting the raw values from the 4 sensors (BR, BL, FR, FL)
        temp_f = read_f(dq);    
        
        % Displaying the raw values from the 4 sensors
        if raw_flag
            disp("Raw Values.")
            disp("Raw Values of BR : " + temp_f{1}(1) + ", " + temp_f{1}(2) + ", " + temp_f{1}(3));
            disp("Raw Values of BL : " + temp_f{2}(1) + ", " + temp_f{2}(2) + ", " + temp_f{2}(3));
            disp("Raw Values of FR : " + temp_f{3}(1) + ", " + temp_f{3}(2) + ", " + temp_f{3}(3));
            disp("Raw Values of FL : " + temp_f{4}(1) + ", " + temp_f{4}(2) + ", " + temp_f{4}(3));
        end
            
        %% Filtering the raw values from the 4 sensors
        % Initialize the filtered voltage with the first input value
        if filtered == 0
            prev_filtered_values = [temp_f{1}, temp_f{2}, temp_f{3}, temp_f{4}];
    
            filtered = 1;       % Indicating that the values have been filtered
        end
        
        % Filtering the raw values using a low pass filter
        F_BR = lowPassFilter(temp_f{1}, 1, prev_filtered_values);
        F_BL = lowPassFilter(temp_f{2}, 2, prev_filtered_values);
        F_FR = lowPassFilter(temp_f{3}, 3, prev_filtered_values);
        F_FL = lowPassFilter(temp_f{4}, 4, prev_filtered_values);

        prev_filtered_values = [F_BR, F_BL, F_FR, F_FL];

        % Displaying the filtered values from the 4 sensors
        if filt_flag
            disp("Filtered Values from Low Pass Filter.")
            disp("Filtered Values of BR : " + F_BR(1) + ", " + F_BR(2) + ", " + F_BR(3));
            disp("Filtered Values of BL : " + F_BL(1) + ", " + F_BL(2) + ", " + F_BL(3));
            disp("Filtered Values of FR : " + F_FR(1) + ", " + F_FR(2) + ", " + F_FR(3));
            disp("Filtered Values of FL : " + F_FL(1) + ", " + F_FL(2) + ", " + F_FL(3));
        end
    
        %% Applying the calibration offsets to the filtered values
        % Applying the offset to the filtered values
        F_BR = F_BR - [offset(1), offset(5), offset(9)];
        F_BL = F_BL - [offset(2), offset(6), offset(10)];
        F_FR = F_FR - [offset(3), offset(7), offset(11)];
        F_FL = F_FL - [offset(4), offset(8), offset(12)];
    
        % Displaying the calibrated values from the 4 sensors
        if calib_flag
            disp("Calibrated and Filtered Values.")
            disp("Calibrated Values of BR : " + F_BR(1) + ", " + F_BR(2) + ", " + F_BR(3));
            disp("Calibrated Values of BL : " + F_BL(1) + ", " + F_BL(2) + ", " + F_BL(3));
            disp("Calibrated Values of FR : " + F_FR(1) + ", " + F_FR(2) + ", " + F_FR(3));
            disp("Calibrated Values of FL : " + F_FL(1) + ", " + F_FL(2) + ", " + F_FL(3));
        end
    
        %% Calculating the resultant forces for each motor
        force(1) = sqrt((F_BR(1).^2) + (F_BR(2).^2) + (F_BR(3).^2)); % BR
        force(2) = sqrt((F_BL(1).^2) + (F_BL(2).^2) + (F_BL(3).^2)); % BL
        force(3) = sqrt((F_FR(1).^2) + (F_FR(2).^2) + (F_FR(3).^2)); % FR
        force(4) = sqrt((F_FL(1).^2) + (F_FL(2).^2) + (F_FL(3).^2)); % FL
    
        % Displaying the resultant forces values from the 4 sensors
        if f_flag
            disp("Resultant Forces Values.")
            disp("Measured Force BR : " + force(1));
            disp("Measured Force BL : " + force(2));
            disp("Measured Force FR : " + force(3));
            disp("Measured Force FL : " + force(4));
        end
    
        %% Pause
        pause(1);

    end 
end