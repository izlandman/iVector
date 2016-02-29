% after all the feature files are created using edfFolderGen. process the
% valid features to build training and testing samples. and populate the
% folders with ubm models

function splitFeaturesFolders(file_list,split)

% assuming the file_list is only valid .mat files generated as feature sets

file_count = numel(file_list);

parfor i=1:file_count
    % be careful since every feature set is labeled 'set_c'
    a(i) = load(file_list{i});
    [b{i},c{i},~] = fileparts(file_list{i});
    d{i} = strsplit(b{i},'/');
    % don't process the calibration trials
    true_folder{i} = d{i}(end);
    r01_check(i) = strfind(true_folder{i},'R01');
    r02_check(i) = strfind(true_folder{i},'R02');
    if( ~isempty(r01_check{i}) && ~isempty(r02_check{i}) )
        try
            melTestTrainSplit_2(a(i).set_c,split,b{i},c{i});
        catch
            disp(['Train/Test Split Failed: ',file_list{i}]);
        end
    else
        % what to do with calibration trials
        disp( ['Skipped :', file_list{i}] );
    end
    
end

end