% after all the feature files are created using edfFolderGen. process the
% valid features to build training and testing samples. and populate the
% folders with ubm models

function splitFeaturesFolders(root_directory,split,workers)

cluster = parcluster('local');
cluster.NumWorkers = workers;
parpool(workers);

% pulls all .mat files, so the directories need to be clean
file_list = findMatchingFiles(root_directory,'.mat');

% assuming the file_list is only valid .mat files generated as feature sets

file_count = numel(file_list);

parfor i=1:file_count
    % be careful since every feature set is labeled 'set_c'
    a(i) = load(file_list{i});
    [b{i},c{i},~] = fileparts(file_list{i});
    
    try
        melTestTrainSplit_2(a(i).set_c,split,b{i},c{i});
    catch
        disp(['Train/Test Split Failed: ',file_list{i}]);
    end
    
    
end

end