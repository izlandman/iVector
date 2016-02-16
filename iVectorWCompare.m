function [result, ttest_8, ttest_16] = iVectorWCompare()

matched_directories = findDirectoryMatch('single');

matched_count = numel(matched_directories);

% raw feature data from each single channel test
data_files = cell(matched_count,1);
% only using 16 and 32 mixture files
ubm_files = cell(matched_count,2);
% output
result = -1*ones(matched_count,matched_count,2);

for i=1:matched_count
    directory_files = getAllFiles(matched_directories{i});
    % loading these will generate a set_c variable
    data_files{i} = pullFile(directory_files,'train');
    % loading these will generate a gmm variable
    ubm_files{i,1} = pullFile(directory_files,'m8');
    ubm_files{i,2} = pullFile(directory_files,'m16');
end

for j=1:matched_count
    load(data_files{j});
    for k=1:matched_count
        % 16 component data
        load(ubm_files{k,1});
        result(j,k,1) = testThisThing(set_c,gmm);
        % 32 component data
        load(ubm_files{k,2});
        result(j,k,2) = testThisThing(set_c,gmm);
    end
    close all;
end

plotHelp(result(:,:,1),'gmm-8');
plotHelp(result(:,:,2),'gmm-16');

% run a ttest to see if the model change is statistically significant on
% based upon the resultant error rates

ttest_8 = ttestFullArray(result(:,:,1));
ttest_16 = ttestFullArray(result(:,:,2));

end

function result = ttestFullArray(data)

[row,column] = size(data);
result = -1*ones(2,column,row,column);

for i = 1 : column
    for j = 1 : row
        for k = 1 : column
            result(:,i,j,r) = ttest(data(i,j),data(i,r));
        end
    end
end

end

function plotHelp(result,title)
figure('numbertitle','off','name',title);
surf(result);
xlabel('gmm model');
ylabel('data model');
end

function result = pullFile(directory_files, query)

index = strfind(directory_files,query);
data_index = find(~cellfun(@isempty,index));

result = directory_files{data_index};

end