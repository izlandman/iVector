% after all the feature files are created using edfFolderGen. process the
% valid features to build training and testing samples. and populate the
% folders with ubm models

function splitFeaturesFolders(root_directory,split,workers)

cluster = parcluster('local');
cluster.NumWorkers = workers;
parpool(workers);

disp(['Starting directory: ',pwd]);

cd(root_directory);

disp(['Changed directory to: ',pwd]);

% pulls all .mat files, so the directories need to be clean
file_list = findMatchingFiles('.','.mat');
disp(['First file: ',file_list{1}]);
disp(['Last file: ',file_list{end}]);
% assuming the file_list is only valid .mat files generated as feature sets

file_count = numel(file_list);
disp(file_count);
parfor i=1:file_count
    % be careful since every feature set is labeled 'set_c'
    a(i) = load(file_list{i});
    [b{i},c{i},~] = fileparts(file_list{i});
    d{i} = strsplit(b{i},'.');
    try
        melTestTrainSplit_2(a(i).set_c,split,['/_split',d{i}(end)],c{i});
    catch
        disp(['Train/Test Split Failed: ',file_list{i}]);
    end
    
    
end

end