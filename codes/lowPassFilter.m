function filtered_values = lowPassFilter(raw_values, motor_id, prev_filtered_values)
    alpha = 0.3;

    % Apply the low-pass filter formula
    filtered_values = alpha * raw_values + (1 - alpha) * prev_filtered_values(-2+3*motor_id:3*motor_id);
end
