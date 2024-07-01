% File Name : main.m (still in devloppment)
% This program instructs the motors to apply a 40N force to the strap using a PID loop. 
% It monitors real-time values to detect when the user intends to stand. 
% By increasing the force to 100N, the strap tightens, 
% making it easier for the user to stand by converting the chair from soft to firm.

% By default, it won't display any values. You need to pass arguments to view specific data.

% - `main` - No display.
% - `main('-raw')` - Displays raw sensor values.
% - `main('-filt')` - Displays filtered sensor values.
% - `main('-calib')` - Displays calibrated, filtered values.
% - `main('-f')` - Displays resultant forces AND voltages from each motor.

% You can combine arguments to view multiple data sets simultaneously, 
% such as `main('-filt', '-calib')` to display both filtered and calibrated values.

function main(varargin)

    %% Initialization
    if exist('dq', 'var') == 0      % In the case "dq" does not exist
        global dq;                  % Ensure the "dq" variable can be accessed and modified globally.
        dq = init_dq;               % Initialization of the sensors and the actuators
    end

    clearvars -except varargin dq;  % Clear all previous values that were initialized
    
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

    %% Running the PID loop for 100N
    setpoint = [100, 100, 100, 100];
    PID_control(setpoint, debug_arr);
    
    pause(3);

    %% Running the PID loop for 20N
    setpoint = [20, 20, 20, 20];
    PID_control(setpoint, debug_arr);

    pause(3);

    %% Stopping the communication with the drivers
    stop(dq{1});
    stop(dq{2});

end










