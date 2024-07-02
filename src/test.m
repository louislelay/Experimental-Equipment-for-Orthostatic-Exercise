fileName = 'stored_data_mat.mat';
data_to_store = struct();
data_to_store.name= 'Lois';
data_to_store.value = [5,3];

if isfile(fileName)
    % Load existing data
    existingData = load(fileName);

    % Append the new data
    data_stored = existingData.data_stored;
    data_stored(end+1).data_stored = data_to_store;
else
    % File does not exist, create a new structure with the data
    data_stored = struct('data_stored', data_to_store);
end

% Save the data structure to the file
save(fileName, 'data_stored');