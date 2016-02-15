function [test_set,train_set] = melTestTrainSplit( coefficents, split_percent, data_folder, file_name )

% input size
[row, column] = size(coefficents);
% find percent inteveral
p_interval = 100 / column;

if ( p_interval > 90 )
    display('This is an unusually high amount of testing data.');
end

if ( mod(p_interval,split_percent) < p_interval )
    % split_percent is lower than p_interval, default to p_interval
    split_percent = p_interval;
else
    % use floor to determine split_percent
    split_percent = floor(split_percent/p_interval) * p_interval;
end

% turn split_percent into column_count
column_count = split_percent / 100 * column;

test_set = cell(row,column_count);
train_set = coefficents;
% i'd rather not deal with cellfun to solve this problem
for k=1:row
    test_index = randperm(column,column_count);
    % add data to test set
    data = coefficents(k,:);
    for j=1:column_count
        test_set(k,j) = data(test_index(j));
        % deletes data, but remember to reshape
        train_set{k,test_index(j)} = [];
    end
end

% need to rotate to preserve order!
temp_set= train_set';
empties=find(cellfun(@isempty,temp_set));
temp_set(empties)=[];
train_set = reshape(temp_set,column-column_count,row)';

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