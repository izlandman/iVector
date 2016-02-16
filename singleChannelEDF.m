function [ubm_dat,ubm_err] = singleChannelEDF(folder_name, channel_index, window)

% this is tricky, but the user must pass in the parent directory. we need
% to search for valid data files first

data_files_1 = getAllFiles(folder_name);
data_files_index = strfind(data_files_1,'data_');

% now, search the known data_files for strings that match the window
% length. different window lengths cannot be mixed and matched for the UBM
% process!
data_index = find(~cellfun(@isempty,data_files_index));
matching_files = data_files_1(data_index);
matching_index_1 = strfind(matching_files,['Win',num2str(window)]);
matching_index_2 = find(~cellfun(@isempty,matching_index_1));

operational_files = matching_files(matching_index_2);

matching_files = numel(operational_files);

for i=1:matching_files
    load(operational_files{i});
    test_channels(i,:) = set_c(channel_index,:);
end
clear set_c;
set_c = test_channels;
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

% call in ubm tools on folder and file name

[ubm_dat,ubm_err] = populateUBMfolder(new_folder,4);



