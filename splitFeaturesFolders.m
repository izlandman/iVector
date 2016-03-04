% after all the feature files are created using edfFolderGen. process the
% valid features to build training and testing samples. and populate the
% folders with ubm models

function splitFeaturesFolders(root_directory,split,workers)

disp(['Starting directory: ',pwd]);

% pulls all .mat files, so the directories need to be clean
file_list = findMatchingFiles(root_directory,'.mat');
disp(['First file: ' file_list{1}]);
disp(['Last file: ' file_list{end}]);
% assuming the file_list is only valid .mat files generated as feature sets

file_count = numel(file_list);
disp(['File count: ' num2str(file_count)]);

poolobj = gcp('nocreate');
delete(poolobj);

cluster = parcluster('local');
cluster.NumWorkers = workers;
parpool(workers);

parfor i=1:file_count
    % be careful since every feature set is labeled 'set_c'
    a = load(file_list{i});
    [b,c,~] = fileparts(file_list{i});
    d = strsplit(b,root_directory);
    try
        melTestTrainSplit_2(a.set_c,split,strcat('_split',d{end}),c);
    catch
        disp(['Train/Test Split Failed: ' file_list{i}]);
        disp(['d: ' d{end}]);
        disp(['c: ' c]);
    end
    
    
end
whos
whos global
end