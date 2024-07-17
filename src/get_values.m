% Load the .mat file
data = load('stored_data.mat');

% Assuming the struct array is named 'data_stored'
structArray = data.data_stored;

% Initialize the time vector assuming 100 samples over 7 seconds
time = linspace(0, 7, 100);

% Create a figure for the plot
figure;
hold on;
title('F\_FR\_arr values over time');
xlabel('Time (s)');
ylabel('F\_FR\_arr values');

% Loop through each struct and plot the F_FR_arr values
for i = 1:length(structArray)
    plot(time, structArray(i).data_stored.F_FR_arr, 'DisplayName', structArray(i).data_stored.name);
end

% Add legend
legend('show');

% Show the plot
hold off;
