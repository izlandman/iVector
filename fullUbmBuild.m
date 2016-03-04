% generate all the ubm models from all the data sets and collect the
% results against the testing sets. assume a list of only the training
% files is passed in and the mixtures can be passed as well, along with the
% workers, and the full flag. this is here to pass in arguments to the
% populateUBMfolder function

function fullUbmBuild(split_folder, mixtures, workers)

% forces populateUBMfolder to return results
full = 1;

file_list = findMatchingFiles(split_folder,'train_');

file_count = numel(file_list);

% errors come back as double array based upon mixtures length
num_mix = numel(mixtures);
ubm_results = -1*ones(file_count,num_mix);
index = zeros(file_count,2);

poolobj = gcp('nocreate');
delete(poolobj);

cluster = parcluster('local');
cluster.NumWorkers = workers;
parpool(workers);

parfor i=1:file_count
    [a,~,~] = fileparts(file_list{i});
    index(i,:) = splitNumbers(a);
    disp(index(i,:));
    try
        [~,ubm_results(i,:)] = populateUBMfolder(a,workers,full,mixtures);
    catch
        disp( [a,' failed to populate UBM folder'] );
    end
end
disp('fullUbmbuild whos');
whos

% write results to file
[a,~,~] = fileparts(file_list{1});
d = strsplit(a,filesep);

error_ind = [ index , ubm_results ];

save_file = fullfile( d{1}, [d{end} '_ubm-results.mat']);

save(save_file,'error_ind');

end

function [result] = splitNumbers(file_name)
a = strsplit(file_name,filesep);
b = strsplit(a{2},'_');
c = strsplit(b{2},'R');
subject_num = str2double(c{1}(2:end));
trial_num = str2double(c{2});
result = [subject_num trial_num];
end