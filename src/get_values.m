% File Name : get_values.m
% By default, it won't display any values. You need to pass arguments to view specific data.

% - get_values - No display.
% - get_values('-raw') - Displays raw sensor values.
% - getvalues('-filt') - Displays filtered sensor values.
% - get_values('-calib') - Displays calibrated, filtered values.
% - get_values('-f') - Displays resultant forces from each motor.

% You can combine arguments to view multiple data sets simultaneously, 
% such as debug('-filt', '-calib') to display both filtered and calibrated values.

function get_values(varargin)

    %% Initialization
    if exist('dq', 'var') == 0          % In the case "dq" does not exist
        global dq;                      % Ensure the "dq" variable can be accessed and modified globally.
        dq = init_dq;                   % Initialization of the sensors and the actuators
    end

    clearvars -except varargin dq name;      % Clear all previous values that were initialized
    
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
   
    % Creating the array with the flag for the debugging
    debug_arr = [raw_flag, filt_flag, calib_flag, f_flag];

    name = input("Name of the person : ", 's');

    %% Runnin 10 time the loop for 5 secs
    for k = 1:10

        disp("----------");
        input("Press enter to begin 30 N", "s");

        %% Running the PID loop for 30N
        setpoint = [30, 30, 30, 30];
        %setpoint = [300, 300, 300, 300];

        disp("---");
        time_sleep = 5;
    
        disp("Running the PID Loop aiming for 10N.");
        PID_control(setpoint, time_sleep, debug_arr);
    
        disp("End of the PID loop.");

        %% Initialization of the data to store
        data_to_store = struct();
        data_to_store.name = name + "_" + string(k);
        data_to_store.F_BR_arr = [];
        data_to_store.F_BL_arr = [];
        data_to_store.F_FR_arr = [];
        data_to_store.F_FL_arr = [];
    
        F_BR_arr = [];
        F_BL_arr = [];
        F_FR_arr = [];
        F_FL_arr = [];

        %% Storing the data
        disp("Recording n°"+ k +" (7 sec), you will incline yourself when told so.");
        % input("Press enter to begin", "s");
        disp("Beginning of the recording.");
        
        n = 100;
        sec = 7;
    
        % Infinite loop : Displaying the values
        for i = 1:n
    
            if i == int64(n/sec*2)
                disp("You will now incline yourself.");
            end
        
            % Getting the raw values from the 4 sensors (BR, BL, FR, FL)
            temp_f = read_f(dq);
                
            % Filtering the raw values from the 4 sensors
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
        
            % Applying the calibration offsets to the filtered values
            % Applying the offset to the filtered values
            F_BR = F_BR - [offset(1), offset(5), offset(9)];
            F_BL = F_BL - [offset(2), offset(6), offset(10)];
            F_FR = F_FR - [offset(3), offset(7), offset(11)];
            F_FL = F_FL - [offset(4), offset(8), offset(12)];
        
            % Calculating the resultant forces for each motor
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
            
            % Append the new force data to the array
            F_BR_arr = [F_BR_arr, force(1)];
            F_BL_arr = [F_BL_arr, force(2)];
            F_FR_arr = [F_FR_arr, force(3)];
            F_FL_arr = [F_FL_arr, force(4)];
    
            % Pause
            pause(sec/n);
    
        end 
    
        disp("End of the time");
    
        % Update the stored data
        data_to_store.F_BR_arr = F_BR_arr;
        data_to_store.F_BL_arr = F_BL_arr;
        data_to_store.F_FR_arr = F_FR_arr;
        data_to_store.F_FL_arr = F_FL_arr;
        
        fileName = 'experiment_data_soft.mat';
        %fileName = 'experiment_data_tighten.mat';
    
        if isfile(fileName)
            % Load existing data
            existingData = load(fileName);
        
            % Append the new data
            data_stored = existingData.data_stored;
            data_stored(end+1).data_stored = data_to_store;
        else
            % File does not exist, create a new structure with the data
            data_stored = struct('data_stored', data_to_store);
            disp("'data_stored.mat' file created, you will find the records in here.");
        end
        % Save the data structure to the file
        save(fileName, 'data_stored');
    end
    disp("----------")
    disp("End");
end