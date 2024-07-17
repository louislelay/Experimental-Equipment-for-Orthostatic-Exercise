function move_motor(motor_type, voltage)

    global dq;

    if sum(voltage < -1.5) > 0 || sum(voltage > 1.5) > 0
        disp("Input is outside the -1.5 to 1.5 V range");
        return
    end

    persistent output;

    % Initialize last_signals if it's empty
    if isempty(output)
        output = zeros(1, 12);
    end


    if voltage >= 0
        signal = [voltage, 0, 1];
    else
        signal = [-voltage, 1, 0];
    end

    
    % motor_type: "BR", "BL", "FR", "FL", "F", "B", "ALL"
    switch motor_type
        case "BR"
            % Control Back Right Motor
            output(1:3) = signal;
        case "BL"
            % Control Back Left Motor
            output(4:6) = signal;
        case "FR"
            % Control Front Right Motor
            output(7:9) = signal;
        case "FL"
            % Control Front Left Motor
            output(10:12) = signal;
        case "F"
            % Control Front Motors
            output(7:9) = signal;
            output(10:12) = signal;
        case "B"
            % Control Back Motors
            output(1:3) = signal;
            output(4:6) = signal;
        case "ALL"
            % Control All Motors
            output(1:3) = signal;
            output(4:6) = signal;
            output(7:9) = signal;
            output(10:12) = signal;
        otherwise
            disp("Are you sure about your motor_type ?");
    end
    
    % (p1.0 p1.1)=(0,0)or(1,1) : stop
    % (p1.0 p1.1)=(1,0) : going up
    % (p1.0 p1.1)=(0,1) : going down

    output_matrix = [output(1:3), output(4:6), output(7:9), output(10:12)];

    % Send to the motor
    write(dq{2}, output_matrix);

end