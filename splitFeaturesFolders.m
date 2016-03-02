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

cluster = parcluster('local');
cluster.NumWorkers = workers;
parpool(workers);

parfor i=1:file_count
    % be careful since every feature set is labeled 'set_c'
    a(i) = load(file_list{i});
    [b{i},c{i},~] = fileparts(file_list{i});
    d{i} = strsplit(b{i},root_directory);
    try
        melTestTrainSplit_2(a(i).set_c,split,strcat('_split',d{i}{end}),c{i});
    catch
        disp(['Train/Test Split Failed: ' file_list{i}]);
        disp(['d: ' d{i}{end}]);
        disp(['c: ' c{i}]);
    end
    
    
end

end