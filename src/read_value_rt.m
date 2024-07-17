% File name : "read_value.m"

%% Initialization
if exist('dq', 'var') == 0      % In the case "dq" does not exist
    global dq;                  % Ensure the "dq" variable can be accessed and modified globally.
    dq = init_dq;               % Initialization of the sensors and the actuators
end

clearvars -except dq;  % Clear all previous values that were initialized

measured_force = zeros(4);          % Initial Force Measurement
dt  = 0.1;                          % Time Step in Seconds

prev_filtered_values = 0;

jsonData = fileread('offset.json'); % Read JSON file
data = jsondecode(jsonData);        % Parse JSON data
offset = data.offset;               % Access vectors


for i = 1:10
    % Get the Current Force Measurement From the Sensor (BR, BL, FR and FN)
    temp_f = read_f(dq);
    
    if prev_filtered_values == 0
        % Initialize the filtered voltage with the first input value
        prev_filtered_values = [temp_f{1}, temp_f{2}, temp_f{3}, temp_f{4}];
    end
    
    F_BR = lowPassFilter(temp_f{1}, 1, prev_filtered_values);
    F_BL = lowPassFilter(temp_f{2}, 2, prev_filtered_values);
    F_FR = lowPassFilter(temp_f{3}, 3, prev_filtered_values);
    F_FL = lowPassFilter(temp_f{4}, 4, prev_filtered_values);
    
    prev_filtered_values = [F_BR, F_BL, F_FR, F_FL];
    
    % Applying the offset to the filtered values
    F_BR = F_BR - [offset(1), offset(5), offset(9)];
    F_BL = F_BL - [offset(2), offset(6), offset(10)];
    F_FR = F_FR - [offset(3), offset(7), offset(11)];
    F_FL = F_FL - [offset(4), offset(8), offset(12)];
    
    % Calculate the resultant forces for each motor
    force(1) = sqrt((F_BR(1).^2) + (F_BR(2).^2) + (F_BR(3).^2)); % BR
    force(2) = sqrt((F_BL(1).^2) + (F_BL(2).^2) + (F_BL(3).^2)); % BL
    force(3) = sqrt((F_FR(1).^2) + (F_FR(2).^2) + (F_FR(3).^2)); % FR
    force(4) = sqrt((F_FL(1).^2) + (F_FL(2).^2) + (F_FL(3).^2)); % FL
    
    %% For Debuggin Purposes
    % Displaying the raw values from the 4 sensors
    if false
        disp("Raw Values.")
        disp("Raw Values of BR : " + temp_f{1}(1) + ", " + temp_f{1}(2) + ", " + temp_f{1}(3));
        disp("Raw Values of BL : " + temp_f{2}(1) + ", " + temp_f{2}(2) + ", " + temp_f{2}(3));
        disp("Raw Values of FR : " + temp_f{3}(1) + ", " + temp_f{3}(2) + ", " + temp_f{3}(3));
        disp("Raw Values of FL : " + temp_f{4}(1) + ", " + temp_f{4}(2) + ", " + temp_f{4}(3));
    end
    
    % Displaying the filtered values from the 4 sensors
    if false
        disp("Filtered Values.")
        disp("Filtered Values of BR : " + F_BR(1) + ", " + F_BR(2) + ", " + F_BR(3));
        disp("Filtered Values of BL : " + F_BL(1) + ", " + F_BL(2) + ", " + F_BL(3));
        disp("Filtered Values of FR : " + F_FR(1) + ", " + F_FR(2) + ", " + F_FR(3));
        disp("Filtered Values of FL : " + F_FL(1) + ", " + F_FL(2) + ", " + F_FL(3));
    end
    
    % Displaying the calibrated values from the 4 sensors
    if false
        disp("Calibrated and Filtered Values.")
        disp("Calibrated Values of BR : " + F_BR(1) + ", " + F_BR(2) + ", " + F_BR(3));
        disp("Calibrated Values of BL : " + F_BL(1) + ", " + F_BL(2) + ", " + F_BL(3));
        disp("Calibrated Values of FR : " + F_FR(1) + ", " + F_FR(2) + ", " + F_FR(3));
        disp("Calibrated Values of FL : " + F_FL(1) + ", " + F_FL(2) + ", " + F_FL(3));
    end
    
    % Displaying the resultant forces values from the 4 sensors
    if true
        disp("Resultant Forces Values.")
        disp("Measured Force BR: " + force(1));
        disp("Measured Force BL: " + force(2));
        disp("Measured Force FR: " + force(3));
        disp("Measured Force FL: " + force(4));
    end

    pause(dt);
end
stop(dq{1});
stop(dq{2});