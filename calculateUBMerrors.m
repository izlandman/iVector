% point this at the specific folder containing the UBM models of a given
% channel. it will find the error rates for all the ubm models against the
% training and testing data sets

function error_results = calculateUBMerrors(folder_name)

% only the first eight elements are ubm models
ubm_files = findMatchingFiles(folder_name,'ubm_');

ubm_files_count = 8;

fig_folder = [folder_name,'\_figures'];
if ( exist(fig_folder,'dir') == 0 )
    % it isn't there, make it
    mkdir(fig_folder);
end

error_results = -1*ones(ubm_files_count,2);

% find and load test/train data sets
test_data = findMatchingFiles(folder_name,'test_');
load(test_data{1});
train_data = findMatchingFiles(folder_name,'train_');
load(train_data{1});

% loop through each ubm with each data set

for i=1:ubm_files_count
    % will populate as gmm
    load(ubm_files{i});
    [error_results(i,1), fig_handle] = testUBM(train_set,train_set,gmm);
    savefig(fig_handle,[fig_folder,'\conf_train',num2str(i),'.fig']);
    [error_results(i,2), fig_handle] = testUBM(train_set,test_set,gmm);
    savefig(fig_handle,[fig_folder,'\conf_test',num2str(i),'.fig']);
    close all;
end

save([folder_name,'/ubm_error.mat','error_results']);

end