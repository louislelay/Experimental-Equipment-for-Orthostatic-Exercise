function temp_f = read_f(dq)
    temp = read(dq{1}, "OutputFormat", "Matrix");

    for motor_id = 1:4
        temp_f{motor_id} = (temp(-2+3*motor_id:3*motor_id) - 2.5) * 500;
    end

end