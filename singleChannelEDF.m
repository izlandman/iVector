function [ubm_dat,ubm_err] = singleChannelEDF(folder_name, channel_index, window)

% this is tricky, but the user must pass in the parent directory. we need
% to search for valid data files first

operational_files = findMatchingFiles(folder_name,'train_0_',window);
test_files = findMatchingFiles(folder_name,'test_0_',window);

% store the training data
set_c = packageData(operational_files,channel_index);

% now all the coefficents are present, make a new folder and save them
folder_count = folderCount('single');

new_folder = ['singleChannel',num2str(folder_count)];
if( exist(new_folder,'dir') == 0)
    % directy does not exist, makeone
    mkdir(new_folder);
end

new_file = [new_folder,'\train_melWin',num2str(window),'_index',num2str(channel_index),...
    '_',num2str(folder_count),'.mat' ];

save(new_file,'set_c');

% now save the test data
set_c = packageData(test_files,channel_index);

new_file = [new_folder,'\test_melWin',num2str(window),'_index',num2str(channel_index),...
    '_',num2str(folder_count),'.mat' ];

save(new_file,'set_c');

% call in ubm tools on folder and file name

[ubm_dat,ubm_err] = populateUBMfolder(new_folder,4);
end

% collect and rename files
function set_c = packageData(operational_files,channel_index)

matching_files = numel(operational_files);

for i=1:matching_files
    a = load(operational_files{i});
    b = fieldnames(a);
    data_p = a.(b{1});
    test_channels(i,:) = data_p(channel_index,:);
end

set_c = test_channels;

end

% find files
function operational_files = findMatchingFiles(folder_name,query,window)

data_files_1 = getAllFiles(folder_name);
data_files_index = strfind(data_files_1,query);


% now, search the known data_files for strings that match the window
% length. different window lengths cannot be mixed and matched for the UBM
% process!
data_index = find(~cellfun(@isempty,data_files_index));
matching_files = data_files_1(data_index);
matching_index_1 = strfind(matching_files,['Win',num2str(window)]);
matching_index_2 = find(~cellfun(@isempty,matching_index_1));

operational_files = matching_files(matching_index_2);
end


