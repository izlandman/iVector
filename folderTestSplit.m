function folderTestSplit(folder_name, split, file_name)

% find the raw data file in the given folder
raw_data = findMatchingFiles(folder_name,'data_');

% should load as set_c
load(raw_data{1});

melTestTrainSplit_2(set_c,split,folder_name,file_name);
end