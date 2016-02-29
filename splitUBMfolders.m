% after all the feature files are created using edfFolderGen. process the
% valid features to build training and testing samples. and populate the
% folders with ubm models

function splitUBMfolders(file_list,split,mixtures,iterations,ds_factor,workers)

% assuming the file_list is only valid .mat files generated as feature sets

file_count = numel(file_list);

parfor i=1:file_count
    % be careful since every feature set is labeled 'set_c'
    a(i) = load(file_list{i});
    [b{i},c{i},~] = fileparts(file_list{i});
    d{i} = strsplit(b(i),'/');
    [train(i),test(i)] = melTestTrainSplit_2(a(i).set_c,split,d{i}(end),c{i});
    [ubm_res{i},ubm_err{i}] = populateUBMfolder(
end

end