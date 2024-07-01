clear all;

global dq;
dq = init_dq;

setpoint = [100, 100, 100, 100];
PID_control(setpoint);

pause(3);

setpoint = [20, 20, 20, 20];
PID_control(setpoint);

stop(dq{1});
stop(dq{2});
