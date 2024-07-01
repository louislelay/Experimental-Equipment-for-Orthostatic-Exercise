% Read JSON file
jsonData = fileread('offset.json');

% Parse JSON data
data = jsondecode(jsonData);

% Access vectors
offset = data.offset;

% Display vectors
disp(offset);

% Example of writing to the JSON file
disp(offset(4) + ", " + offset(8) +  ", " + offset(12))

% Convert back to JSON string
jsonDataUpdated = jsonencode(data);

% Save updated JSON data to file
fid = fopen('offset.json', 'w');
if fid == -1
    error('Cannot create JSON file');
end
fwrite(fid, jsonDataUpdated, 'char');
fclose(fid);
