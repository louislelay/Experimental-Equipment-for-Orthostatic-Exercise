% File name : "PID_control.m"
% Using a PID loop, it will attempt to aim a force for each sensors by
% using the motors. That's why is will take in argument a value to aim for
% and an array telling what values to display for the debugging process.

function [F_BR_arr, F_BL_arr, F_FR_arr, F_FL_arr, time_arr] = PID_control(setpoint, time_sleep, debug_arr)
    %% Initialization
    global dq;                          % Set dq as a global value
    
    Kp = 0.025;                         % Proportional gain
    Ki = 0.000;                         % Integral gain
    Kd = 0.001;                         % Derivative gain
    %setpoint = [100, 100, 100, 100];   % Desired Force In Newtons
 
    integral = zeros(4);
    previous_error = zeros(4);
    
    measured_force = zeros(4);          % Initial Force Measurement
    dt  = 0.1;                          % Time Step in Seconds
    
    prev_filtered_values = 0;
    previous_voltage = zeros(4);
    
    jsonData = fileread('offset.json'); % Read JSON file
    data = jsondecode(jsonData);        % Parse JSON data
    offset = data.offset;               % Access vectors

    F_BR_arr = [];
    F_BL_arr = [];
    F_FR_arr = [];
    F_FL_arr = [];
    time_arr = [];

    n = time_sleep/dt;

    %% PID Loop (for 50*dt seconds)
    for i = 1:n
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
    
        F_BR_arr = [F_BR_arr, force(1)];
        F_BL_arr = [F_BL_arr, force(2)];
        F_FR_arr = [F_FR_arr, force(3)];
        F_FL_arr = [F_FL_arr, force(4)];
        time_arr = [time_arr, i*dt];

        %% Update The PID Controller
        for i = 1:4
            % Calculate the Error
            error(i) = setpoint(i) - force(i);
        
            % Update Integral Term
            integral(i) = integral(i) + error(i) * dt;
        
            % Calculate Derivative Term
            derivative(i) = (error(i) - previous_error(i)) / dt;
        
            % Compute PID Output
            output(i) = Kp * error(i) + Ki * integral(i) + Kd * derivative(i);
        
            % Clamp Output to Range [-1.5, 1.5]
            voltage(i) = max(min(output(i), 5), -5);
        
            % Update Previous Error
            previous_error(i) = error(i);
        end
    
        %% For Debuggin Purposes
        % Displaying the raw values from the 4 sensors
        if debug_arr(1)
            disp("Raw Values.")
            disp("Raw Values of BR : " + temp_f{1}(1) + ", " + temp_f{1}(2) + ", " + temp_f{1}(3));
            disp("Raw Values of BL : " + temp_f{2}(1) + ", " + temp_f{2}(2) + ", " + temp_f{2}(3));
            disp("Raw Values of FR : " + temp_f{3}(1) + ", " + temp_f{3}(2) + ", " + temp_f{3}(3));
            disp("Raw Values of FL : " + temp_f{4}(1) + ", " + temp_f{4}(2) + ", " + temp_f{4}(3));
        end

        % Displaying the filtered values from the 4 sensors
        if debug_arr(2)
            disp("Filtered Values.")
            disp("Filtered Values of BR : " + F_BR(1) + ", " + F_BR(2) + ", " + F_BR(3));
            disp("Filtered Values of BL : " + F_BL(1) + ", " + F_BL(2) + ", " + F_BL(3));
            disp("Filtered Values of FR : " + F_FR(1) + ", " + F_FR(2) + ", " + F_FR(3));
            disp("Filtered Values of FL : " + F_FL(1) + ", " + F_FL(2) + ", " + F_FL(3));
        end

        % Displaying the calibrated values from the 4 sensors
        if debug_arr(3)
            disp("Calibrated and Filtered Values.")
            disp("Calibrated Values of BR : " + F_BR(1) + ", " + F_BR(2) + ", " + F_BR(3));
            disp("Calibrated Values of BL : " + F_BL(1) + ", " + F_BL(2) + ", " + F_BL(3));
            disp("Calibrated Values of FR : " + F_FR(1) + ", " + F_FR(2) + ", " + F_FR(3));
            disp("Calibrated Values of FL : " + F_FL(1) + ", " + F_FL(2) + ", " + F_FL(3));
        end
        
        % Displaying the resultant forces values from the 4 sensors
        if debug_arr(4)
            disp("Resultant Forces Values.")
            disp("Measured Force BR: " + force(1) + " and Voltage: " + voltage(1));
            disp("Measured Force BL: " + force(2) + " and Voltage: " + voltage(2));
            disp("Measured Force FR: " + force(3) + " and Voltage: " + voltage(3));
            disp("Measured Force FL: " + force(4) + " and Voltage: " + voltage(4));
        end
    
    
        %% Launch Motor
        motor_type = ["BR", "BL", "FR", "FL"];

        for i = 1:4
            if previous_voltage(i) ~= voltage(i)
                if abs(voltage(i)) > 0.7
                    move_motor(motor_type(i), voltage(i));
                    previous_voltage(i) = voltage(i);
                else
                    if abs(voltage(i)) > 0.3
                        if voltage(i) > 0
                            sig = 1;
                        else
                            sig = -1;
                        end
                        move_motor(motor_type(i), sig*0.7);
                        previous_voltage(i) = voltage(i);
                    else
                        move_motor(motor_type(i), 0);
                        previous_voltage(i) = voltage(i);
                    end
                end
            end

            pause(dt/4);
        end

    end

    move_motor("ALL", 0);

end
