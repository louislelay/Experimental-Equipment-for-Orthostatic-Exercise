% Load the .mat file
data = load('stored_data.mat');

% Assuming the struct array is named 'data_stored'
structArray = data.data_stored;

% Initialize the time vector assuming 100 samples over 7 seconds
time = linspace(0, 7, 100);

% Create a figure for the plots
figure;

% Subplot for F_FR_arr
subplot(2, 2, 1);
hold on;
title('F\_FR\_arr values over time');
xlabel('Time (s)');
ylabel('F\_FR\_arr values');
for i = 1:length(structArray)
    plot(time, structArray(i).data_stored.F_FR_arr, 'DisplayName', structArray(i).data_stored.name);
end
legend('show');
hold off;

% Subplot for F_FL_arr
subplot(2, 2, 2);
hold on;
title('F\_FL\_arr values over time');
xlabel('Time (s)');
ylabel('F\_FL\_arr values');
for i = 1:length(structArray)
    plot(time, structArray(i).data_stored.F_FL_arr, 'DisplayName', structArray(i).data_stored.name);
end
legend('show');
hold off;

% Subplot for F_BR_arr
subplot(2, 2, 3);
hold on;
title('F\_BR\_arr values over time');
xlabel('Time (s)');
ylabel('F\_BR\_arr values');
for i = 1:length(structArray)
    plot(time, structArray(i).data_stored.F_BR_arr, 'DisplayName', structArray(i).data_stored.name);
end
legend('show');
hold off;

% Subplot for F_BL_arr
subplot(2, 2, 4);
hold on;
title('F\_BL\_arr values over time');
xlabel('Time (s)');
ylabel('F\_BL\_arr values');
for i = 1:length(structArray)
    plot(time, structArray(i).data_stored.F_BL_arr, 'DisplayName', structArray(i).data_stored.name);
end
legend('show');
hold off;
