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

name = input("Name of the person : ", 's');

k = 1;
j = 1;

while k < 10
    
    disp("----");
    input("Press enter to get 30N", "s");
    disp("starting motors to get them at 30N")

    setpoint = [30, 30, 30, 30];
    time_sleep = 4;
    debug_arr = [false, false, false, false];
    PID_control(setpoint, time_sleep, debug_arr);
    
    flag_pid = true;
    flag_w = true;

    duration = 0;
    motor_time = 0;
    
    %% Initialization of the data to store
    data_to_store = struct();
    data_to_store.name = name + "_" + string(k);
    data_to_store.F_BR_arr = [];
    data_to_store.F_BL_arr = [];
    data_to_store.F_FR_arr = [];
    data_to_store.F_FL_arr = [];
    data_to_store.time_arr = [];
    data_to_store.motor_time = 0;
        
    F_BR_arr = [];
    F_BL_arr = [];
    F_FR_arr = [];
    F_FL_arr = [];
    time_arr = [];
    
    disp("Recording n°"+ k +", you will incline yourself when told so.");
    input("Press enter to begin", "s");
    disp("Beginning of the recording.");
    
    while flag_w
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
    
        % Append the new force data to the array
        F_BR_arr = [F_BR_arr, force(1)];
        F_BL_arr = [F_BL_arr, force(2)];
        F_FR_arr = [F_FR_arr, force(3)];
        F_FL_arr = [F_FL_arr, force(4)];
        time_arr = [time_arr, duration];
    
        if ((force(1) < 20) || (force(2) < 25)) && ((force(3) > 45) || (force(4) > 35)) && flag_pid
            disp("PID in Action")
            setpoint = [300,300,300,300];
            time_sleep = 0.7;
            [F_BR_arr_temp, F_BL_arr_temp, F_FR_arr_temp, F_FL_arr_temp, time_arr_temp] = PID_control_r(setpoint, time_sleep, debug_arr);
            flag_pid = false;
            motor_time=duration;
            duration = duration+time_sleep;
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
        data_to_store.name = name + "_" + string(k) + "_failed_" + string(j);
        j = j + 1;
    end 

    % Update the stored data
    data_to_store.F_BR_arr = F_BR_arr;
    data_to_store.F_BL_arr = F_BL_arr;
    data_to_store.F_FR_arr = F_FR_arr;
    data_to_store.F_FL_arr = F_FL_arr;
    data_to_store.time_arr = time_arr;
    data_to_store.motor_time = motor_time;

    fileName = 'data_exp.mat';
    
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

%% Stopping the communication with the drivers
stop(dq{1});
stop(dq{2});