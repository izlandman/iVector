% function to combine training and testing data for specific subjects to
% build full subject UBMs. specific the split percentage results to be
% combined as well as the root directory of the files.

function fullSubjectTrain(root_directory,split)

% find folders that contain the split data
data_paths = folderFinder([root_directory,'/**/'],['perct_',num2str(split)],1);

% determine how many paths are present for each subject
total_paths = numel(data_paths);
i = 1;
while i < total_paths
    % add leading zeros and find subjects, i will increment only as valid
    % subjects are found!
    formated_subject = num2str(i,'%03.0f');
    q{i} = strfind(data_paths,['S',formated_subject]);
    subject_paths(i) = numel(cell2mat(q{i}));
    subject_index(i,:) = find(~cellfun(@isempty,q{i}));
    if( ~isempty(subject_paths(i)) 
        % there are valid subject paths, pull test and training data from
        % them!
        subject_folders = total_paths(subject_index(i,:));
        for j=1:numel(subject_folders)
            train_1 = findMatchingFiles(subject_folders{j},'train_');
            test_1 = findMatchingFiles(subject_folders{j},'test_');
            if( j == 1)
                % initialize cat array
                train_set = train_1.train_set;
                test_set = test_1.test_set;
            else
                % cat them together to make them formatted for processing
                train_set = cat(1,train_set,train_1.train_set);
                test_set = cat(1,test_set,test_1.test_set);
            end
        end
        % train and test set are created, save them to new location
        
    end
    
end

end