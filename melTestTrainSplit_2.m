function [test_set,train_set] = melTestTrainSplit_2( coefficents, split_percent, data_folder, file_name )

% input size
[row, column] = size(coefficents);

test_set = cell(row,1);
train_set = cell(row,1);
data_dip = (cat(1,coefficents{1,:}));
[coef_count,sample_count] = size(data_dip);
true_perc = split_percent/100;

test_index = randperm(sample_count,floor(sample_count*true_perc));


% put the data back inline to split randomly, don't split a whole chunk
    % out as that makes the results terrible and isn't really random
    

for k=1:row
    full_data = (cat(2, coefficents{k,:}));
    % build test set
    test_set{k} = full_data(:,test_index);
    % deletes data, but remember to reshape
    full_data(:,test_index) = [];
    train_set{k} = full_data;
end

% save split because it'll be unique every time you run this!
folder_name = [data_folder,'/','test_train-', file_name];
if( exist(folder_name,'dir') == 0)
    % directy does not exist, makeone
    mkdir(folder_name);
end

name_count = folderNameCount('perc',folder_name);

last_name = [num2str(name_count),'_', file_name];

% subfolder name, label the split
percent_count = folderNameCount('perct_',folder_name);
middle_name = ['perct_', num2str(split_percent),'_',num2str(percent_count)];

test_save = [folder_name,'/',middle_name,'/','test_',last_name,'.mat'];
train_save = [folder_name,'/',middle_name,'/','train_',last_name,'.mat'];

% check to see if folder exists
if ( exist( [folder_name,'/',middle_name], 'dir' ) == 0 )
    mkdir( [folder_name,'/',middle_name]);
end

if ( exist(test_save,'file') == 2 )
    delete(test_save,train_save);
    save(test_save,'test_set');
    save(train_save,'train_set');
else
    save(test_save,'test_set');
    save(train_save,'train_set');
end

end