
function fullEDFbuild(file_name, channels, segments, mel_win, mel_coef, split_percent, workers)

% this file_name needs to point to the raw edf file
set_c = processEDF(file_name,channels,segments,mel_win,mel_coef);

[path,name,ext] = fileparts(file_name);

folder_name = ['edfData_',name];
new_file = ['melCoef',num2str(mel_coef),'_melWin',num2str(mel_win*1000),'_c',num2str(segments)];

% this folder needs to point into the subject data parent folder, the
% file_name can probably be found from the previously used variables
melTestTrainSplit(set_c,split_percent,folder_name,new_file);

folder_count = folderNameCount(['perct_',num2str(segments)],[folder_name,'/','test_train-',new_file]);

folder_name = [folder_name,'/','test_train-',new_file,'/perct_',num2str(split_percent),'_',num2str(folder_count)];
% this folder needs to point into the split percent folder
populateUBMfolder(folder_name,workers);

% this folder needs to point into the split percent folder
processDirectory(folder_name);

end