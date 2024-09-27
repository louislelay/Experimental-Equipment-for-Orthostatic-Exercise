% File Name : test.m
% This program will make the chair soft, detect when you'll begin standing
% and then tighten it.

%% Initialization
if exist('dq', 'var') == 0      % In the case "dq" does not exist
    global dq;                  % Ensure the "dq" variable can be accessed and modified globally.
    dq = init_dq;               % Initialization of the sensors and the actuators
end

clearvars -except varargin dq;  % Clear all previous values that were initialized

filtered = 0;                       % Indicating that the values have never been filtered
    
jsonData = fileread('offset.json'); % Read JSON file
data = jsondecode(jsonData);        % Parse JSON data
offset = data.offset;               % Access vectors

%% Softening the chair
disp("Running the PID loop for 30N.")
setpoint = [30, 30, 30, 30];        % Aim values for the sensors
time_sleep = 4;                     % Duration of the PID loop
debug_arr = [false, false, false, false];       % Indicates the debug values we want for the PID loop
PID_control(setpoint, time_sleep, debug_arr);   % Run the PID loop

disp("----");
disp("You can now try to stand up.");

flag = true;
while flag
    % Getting the raw values from the 4 sensors (BR, BL, FR, FL)
    temp_f = read_f(dq);
        
    % Filtering the raw values from the 4 sensors
    if filtered == 0
        % Initialize the filtered voltage with the first input value
        prev_filtered_values = [temp_f{1}, temp_f{2}, temp_f{3}, temp_f{4}];
        
        % Indicating that the values have been filtered
        filtered = 1;
    end
    
    % Filtering the raw values using a low pass filter
    F_BR = lowPassFilter(temp_f{1}, 1, prev_filtered_values);
    F_BL = lowPassFilter(temp_f{2}, 2, prev_filtered_values);
    F_FR = lowPassFilter(temp_f{3}, 3, prev_filtered_values);
    F_FL = lowPassFilter(temp_f{4}, 4, prev_filtered_values);
    
    % Storing the values for the next iteration
    prev_filtered_values = [F_BR, F_BL, F_FR, F_FL];

    % Applying the calibration offsets to the filtered values
    F_BR = F_BR - [offset(1), offset(5), offset(9)];
    F_BL = F_BL - [offset(2), offset(6), offset(10)];
    F_FR = F_FR - [offset(3), offset(7), offset(11)];
    F_FL = F_FL - [offset(4), offset(8), offset(12)];

    % Calculating the resultant forces for each motor
    force(1) = sqrt((F_BR(1).^2) + (F_BR(2).^2) + (F_BR(3).^2)); % BR
    force(2) = sqrt((F_BL(1).^2) + (F_BL(2).^2) + (F_BL(3).^2)); % BL
    force(3) = sqrt((F_FR(1).^2) + (F_FR(2).^2) + (F_FR(3).^2)); % FR
    force(4) = sqrt((F_FL(1).^2) + (F_FL(2).^2) + (F_FL(3).^2)); % FL
    
    % Detect if the user is trying to stand up using value obtained through
    % experimentation. (see get_values.m and plot_analyze_inclining.m)
    if ((force(1) < 20) || (force(2) < 25)) && ((force(3) > 45) || (force(4) > 35))
    setpoint = [300,300,300,300];                       % Aim values for the sensors
        time_sleep = 1.5;                               % Duration of the PID loop
        PID_control(setpoint, time_sleep, debug_arr);   % Run the PID loop

        flag = false;                                    % Set the flag to false to stop the while loop
    end
    
end


%% Stopping the communication with the drivers
stop(dq{1});
stop(dq{2});