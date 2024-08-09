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

setpoint = [30, 30, 30, 30];
time_sleep = 4;
debug_arr = [false, false, false, false];
PID_control(setpoint, time_sleep, debug_arr);

disp("Beginning the loop");

flag = true;
while flag
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

    disp("Resultant Forces Values.")
    disp("Measured Force BR : " + force(1));
    disp("Measured Force BL : " + force(2));
    disp("Measured Force FR : " + force(3));
    disp("Measured Force FL : " + force(4));

    if ((force(1) < 20) || (force(2) < 25)) && ((force(3) > 45) || (force(4) > 35))
        setpoint = [300,300,300,300];
        time_sleep = 1.5;
        PID_control(setpoint, time_sleep, debug_arr);
        flag = false;
    end
    
end


%% Stopping the communication with the drivers
stop(dq{1});
stop(dq{2});