%% Initialization
if exist('dq', 'var') == 0      % In the case "dq" does not exist
    global dq;                  % Ensure the "dq" variable can be accessed and modified globally.
    dq = init_dq;               % Initialization of the sensors and the actuators
end

% File Name : experiment.m
% This program will run a 10 trials for an experiment where the user will
% try the chair going from soft to tighten. It then stores the data with
% some other informations.

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

name = input("Name of the person : ", 's');     % Store the name to associate it to the data

k = 1;
j = 1;

% 10 times trial loop (choice of a while loop in case data fail and we just
% want to rerun it)
while k <= 10
    
    disp("----");
    input("Press enter to get 30N", "s");
    disp("Starting motors to get them at 30N")

    setpoint = [30, 30, 30, 30];                    % Aim values for the sensors
    time_sleep = 4;                                 % Duration of the PID loop
    debug_arr = [false, false, false, false];       % Indicates the debug values we want for the PID loop
    PID_control(setpoint, time_sleep, debug_arr);   % Run the PID loop
    
    flag_pid = true;    % Flag to continue trying to detect if the user want to stand up
    flag_w = true;      % flag for the while loop

    duration = 0;       % Time initialization
    motor_time = 0;     % Time initialization (will indicates when the motor is activated)
    
    %% Initialization of the data we'll store through each trials
    data = struct();                        % Set the data var as a structure

    data.name = name + "_" + string(k);     % Associate it to a name

    % Set up arrays to store values of each sensors
    data.F_BR_arr = [];
    data.F_BL_arr = [];
    data.F_FR_arr = [];
    data.F_FL_arr = [];

    % Set up an array to store values of time for each values of sensors
    data.time_arr = [];

    % Set up a var to store the time the motor is activated.
    data.motor_time = 0;
    
    % Initialize the vars
    F_BR_arr = [];
    F_BL_arr = [];
    F_FR_arr = [];
    F_FL_arr = [];
    time_arr = [];
    
    disp("----")
    disp("Recording n°"+ k +", you will incline yourself when told so.");
    input("Press enter to begin", "s");
    disp("Beginning of the recording.");
    
    % Run the loop while the flag is activated
    while flag_w
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
    
        % Append the new force data to the array
        F_BR_arr = [F_BR_arr, force(1)];
        F_BL_arr = [F_BL_arr, force(2)];
        F_FR_arr = [F_FR_arr, force(3)];
        F_FL_arr = [F_FL_arr, force(4)];
        time_arr = [time_arr, duration];
    
        if ((force(1) < 20) || (force(2) < 25)) && ((force(3) > 45) || (force(4) > 35)) && flag_pid
            disp("Starting motors to get them at 300N")

            setpoint = [300,300,300,300];   % Aim values for the sensors
            time_sleep = 0.7;               % Duration of the PID loop

            [F_BR_arr_temp, F_BL_arr_temp, F_FR_arr_temp, F_FL_arr_temp, time_arr_temp] = PID_control_r(setpoint, time_sleep, debug_arr);

            flag_pid = false;               % Flag to stop running the detection if

            motor_time=duration;            % Set the var to know when the motors have been detected

            duration = duration+time_sleep; % Add the time of the pid to keep a correct track of the time

            F_BR_arr = [F_BR_arr, F_BR_arr_temp];
            F_BL_arr = [F_BL_arr, F_BL_arr_temp];
            F_FR_arr = [F_FR_arr, F_FR_arr_temp];
            F_FL_arr = [F_FL_arr, F_FL_arr_temp];
            time_arr = [time_arr, (time_arr_temp+time_sleep)];
        else 
            duration = duration+0.01;
            pause(0.01);
            disp(duration);
        end
        
        if duration >= motor_time + 3
            flag_w =  false;
        end
        
    end
    
    failed_ans = input("data is good (yes, no) : ", "s");

    if failed_ans == "yes"
        k = k+1;
        j = 1;
    end

    if failed_ans == "no"
        data.name = name + "_" + string(k) + "_failed_" + string(j);
        j = j + 1;
    end 

    % Update the stored data
    data.F_BR_arr = F_BR_arr;
    data.F_BL_arr = F_BL_arr;
    data.F_FR_arr = F_FR_arr;
    data.F_FL_arr = F_FL_arr;
    data.time_arr = time_arr;
    data.motor_time = motor_time;

    fileName = 'data_exp_soft_to_tighten.mat';
    
    if isfile(fileName)
        % Load existing data
        existingData = load(fileName);
    
        % Append the new data
        data_stored = existingData.data_stored;
        data_stored(end+1).data_stored = data;
    else
        % File does not exist, create a new structure with the data
        data_stored = struct('data_stored', data);
        disp("'data_stored.mat' file created, you will find the records in here.");
    end
    % Save the data structure to the file
    save(fileName, 'data_stored');
end

%% Stopping the communication with the drivers
stop(dq{1});
stop(dq{2});