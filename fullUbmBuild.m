% generate all the ubm models from all the data sets and collect the
% results against the testing sets. assume a list of only the training
% files is passed in and the mixtures can be passed as well, along with the
% workers, and the full flag. this is here to pass in arguments to the
% populateUBMfolder function

function fullUbmBuild(file_list, mixtures, workers)

% forces populateUBMfolder to return results
full = 1;

file_count = numel(file_list);

% errors come back as double array based upon mixtures length
num_mix = numel(mixtures);
ubm_results = -1*ones(file_count,num_mix);

parfor i=1:file_count
    [a{i},~,~] = fileparts(file_list{i});
    try
        [~,ubm_results(i,:)] = populateUBMfolder(a{i},workers,full,mixtures);
    catch
        disp( [a{i},' failed to populate UBM folder'] );
        failure_list{i} = file_list{i};
    end
end

% write results to file
d = strsplit(a{1},'/');

save_file = [ d{1}, '/', d{end}, '_ubm-results.mat'];
failure_file = [ d{1}, '/', d{end}, '_ubm-failures.mat'];

save(save_file,'ubm_results');
save(failure_file,'failure_list');

end