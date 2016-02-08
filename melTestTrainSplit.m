function [test_set,train_set] = melTestTrainSplit( coefficents, split_percent )

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
    
end