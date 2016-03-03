% function to combine training and testing data for specific subjects to
% build full subject UBMs. specific the split percentage results to be
% combined as well as the root directory of the files.

function fullSubjectTrain(root_directory,split)

% find folders that contain the split data
data_paths = folderFinder(root_directory,['perct_',num2str(split)],1);

% determine how many paths are present for each subject
total_paths = numel(data_paths);

% sort out how  many channels there are!
i = 1;
while i < total_paths
    % add leading zeros and find subjects, i will increment only as valid
    % subjects are found!
    formated_subject = num2str(i,'%03.0f');
    q{i} = strfind(data_paths,['S',formated_subject]);
    subject_paths(i) = numel(cell2mat(q{i}));
    subject_index{i} = find(~cellfun(@isempty,q{i}));
    if( ~isempty(subject_paths(i)))
        % there are valid subject paths, pull test and training data from
        % them!
        subject_folders = data_paths(subject_index{i});
        subject_count = numel(subject_folders);
        if( i == 1)
            a = findMatchingFiles(subject_folders{1},'train_');
            a = load(a{1});
            [channels,~] = size(a.train_set);
        end
        train_set = cell(channels,subject_count);
        test_set = cell(channels,subject_count);
        for j=1:subject_count
            train_1 = findMatchingFiles(subject_folders{j},'train_');
            test_1 = findMatchingFiles(subject_folders{j},'test_');
            train_1 = load(train_1{1});
            test_1 = load(test_1{1});
            
            train_set(:,j) = train_1.train_set;
            test_set(:,j)= test_1.test_set;
        end
        % train and test set are created, save them to new location
        
    end
    
end

end