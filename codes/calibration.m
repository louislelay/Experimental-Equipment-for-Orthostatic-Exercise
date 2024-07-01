% Use this program to get the calibration values of the different forces
clear all;

global dq;
dq = init_dq;

% Read JSON file
jsonData = fileread('offset.json');

% Parse JSON data
data = jsondecode(jsonData);

% Access offset
offset = data.offset;

% Display offset
disp("Previous Offset : ");
disp(offset);

% Initialize an array to store the input values
F_BR_values = [zeros(1, 200), zeros(1, 200), zeros(1, 200)];
F_BL_values = [zeros(1, 200), zeros(1, 200), zeros(1, 200)];
F_FR_values = [zeros(1, 200), zeros(1, 200), zeros(1, 200)];
F_FL_values = [zeros(1, 200), zeros(1, 200), zeros(1, 200)];

prev_filtered_values = 0;

% Loop to get 200 input values
for i = 1:1000
    temp_f = read_f(dq);

    if prev_filtered_values == 0
        % Initialize the filtered voltage with the first input value
        prev_filtered_values = [temp_f{1}, temp_f{2}, temp_f{3}, temp_f{4}];
    end

    F_BR = lowPassFilter(temp_f{1}, 0.5, 1, prev_filtered_values);
    F_BL = lowPassFilter(temp_f{2}, 0.5, 2, prev_filtered_values);
    F_FR = lowPassFilter(temp_f{3}, 0.5, 3, prev_filtered_values);
    F_FL = lowPassFilter(temp_f{4}, 0.5, 4, prev_filtered_values);
    
    prev_filtered_values = [F_BR, F_BL, F_FR, F_FL];
    F_BR_values= F_BR;
    F_BL_values= F_BL;
    F_FR_values = F_FR;
    F_FL_values = F_FL;

    pause(0.1);
end

% Calculate the mean of the input values
calib_BR = [mean(F_BR_values(1)), mean(F_BR_values(2)), mean(F_BR_values(3))];
calib_BL = [mean(F_BL_values(1)), mean(F_BL_values(2)), mean(F_BL_values(3))];
calib_FR = [mean(F_FR_values(1)), mean(F_FR_values(2)), mean(F_FR_values(3))];
calib_FL = [mean(F_FL_values(1)), mean(F_FL_values(2)), mean(F_FL_values(3))];

% Display the mean value
disp("Calibrations Values for BR : " + calib_BR(1) + ", " + calib_BR(2) + ", " + calib_BR(3));
disp("Calibrations Values for BL : " + calib_BL(1) + ", " + calib_BL(2) + ", " + calib_BL(3));
disp("Calibrations Values for FR : " + calib_FR(1) + ", " + calib_FR(2) + ", " + calib_FR(3));
disp("Calibrations Values for FL : " + calib_FL(1) + ", " + calib_FL(2) + ", " + calib_FL(3));

stop(dq{1});
stop(dq{2});

% Write it in the JSON file
data.offset(1) = calib_BR(1);
data.offset(5) = calib_BR(2);
data.offset(9) = calib_BR(3);

data.offset(2) = calib_BL(1);
data.offset(6) = calib_BL(2);
data.offset(10) = calib_BL(3);

data.offset(3) = calib_FR(1);
data.offset(7) = calib_FR(2);
data.offset(11) = calib_FR(3);

data.offset(4) = calib_FL(1);
data.offset(8) = calib_FL(2);
data.offset(12) = calib_FL(3);

% Convert back to JSON string
jsonDataUpdated = jsonencode(data);

% Save updated JSON data to file
fid = fopen('offset.json', 'w');
if fid == -1
    error('Cannot create JSON file');
end
fwrite(fid, jsonDataUpdated, 'char');
fclose(fid);
