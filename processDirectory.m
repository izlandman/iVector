function [error_PLDA, true_positive, iv_map] = processDirectory(folder_name, varargin)
close all;
% make it easier on me
if (nargin == 1)
    workers = 4;
else
    workers = varargin{1};
end

% gather ubm files, there will be two extra files that contain error and
% structures that should not be compared
ubm_files = findDirectoryMatch('ubm',folder_name);
ubm_count = numel(ubm_files) - 2;

% father test files
test_files = findDirectoryMatch('test',folder_name);

% gather train files
train_files = findDirectoryMatch('train',folder_name);

% if you don't have test and train, it means there is only one set of data.
% find it and use it instead for both
if(  isempty(train_files) )
    train_files = findDirectoryMatch('data_',folder_name);
end
if( isempty(test_files) )
    test_files = train_files;
end
train_count = numel(train_files);
test_count = numel(test_files);

% try to avoid any funny business by verifing the number of files match
if( train_count ~= test_count )
    display('test and training files do not match.');
else
    % predfine result variables
    error_PLDA = zeros(test_count,ubm_count);
    true_positive = error_PLDA;
    iv_map = cell(test_count,ubm_count);
    
    % loop one set of test/train through all the gmm models
    for i=1:test_count
        a = load([folder_name,'\',train_files{i}]);
        b = fieldnames(a);
        train_set = a.(b{1});
        a = load([folder_name,'\',test_files{i}]);
        b = fieldnames(a);
        test_set = a.(b{1});
        for k=1:ubm_count
            load([folder_name, '\',ubm_files{k}]);
            % score the i-vectors via PLDA
            display('Crunch PLDA.');
            [error_PLDA(i,k), model_ivs, test_ivs] = scoreIvector(gmm,train_set,test_set,workers);
            display('Crunch cosine.');
            [iv_map{i,k}, true_positive(i,k)] = findIvectorMatch(model_ivs, test_ivs);
        end
    end
end

% save results!

save( [folder_name,'/','_errorPLDA.mat'], 'error_PLDA');
save( [folder_name,'/','_errorSens.mat'], 'true_positive');
save( [folder_name,'/','_ivMap.mat'], 'iv_map');

end