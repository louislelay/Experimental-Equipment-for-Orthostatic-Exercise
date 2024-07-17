%% Initialization
if exist('dq', 'var') == 0      % In the case "dq" does not exist
    global dq;                  % Ensure the "dq" variable can be accessed and modified globally.
    dq = init_dq;               % Initialization of the sensors and the actuators
end

clearvars -except varargin dq;  % Clear all previous values that were initialized




move_motor("BR", 0.7)
pause(1)
move_motor("BL", -0.7)
pause(1)
move_motor("FL", -0.7)
pause(1)
move_motor("ALL", 0)

%% Stopping the communication with the drivers
stop(dq{1});
stop(dq{2});