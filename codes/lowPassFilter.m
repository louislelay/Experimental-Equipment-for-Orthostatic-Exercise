function filtered_values = lowPassFilter(raw_values, alpha, motor_id, prev_filtered_values)

    if isempty(prev_filtered_values(motor_id))
        % Initialize the filtered voltage with the first input value
        prev_filtered_values(motor_id) = raw_values;
    end
    
    % Apply the low-pass filter formula
    filtered_values = alpha * raw_values + (1 - alpha) * prev_filtered_values(motor_id);
end
