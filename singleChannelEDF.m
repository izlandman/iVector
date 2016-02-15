function [ubm_dat,ubm_err] = singleChannelEDF(folder_name, channel_index, window)

folder_list = findDirectoryMatch(['Win',window],folder_name);

matching_folders = numel(folder_list);

for i=1:matching_folders
    load([folder_name,'/',folder_list{i}]);
    test_channels(i,:) = set_c(channel_index,:);
end
clear set_c;
set_c = test_channels;
% now all the coefficents are present, make a new folder and save them

new_folder = [folder_name,'/','singleChannel'];
if( exist(new_folder,'dir') == 0)
    % directy does not exist, makeone
    mkdir(new_folder);
end

folder_count = folderNameCount('index',new_folder);

new_file = [new_folder,'\train_index',num2str(channel_index),...
     '_',num2str(folder_count),'.mat' ];
 
 save(new_file,'set_c');
 
 % call in ubm tools on folder and file name
 
 [ubm_dat,ubm_err] = populateUBMfolder(new_folder,4);
 
 

