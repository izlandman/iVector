% function to combine training and testing data for specific subjects to
% build full subject UBMs. specific the split percentage results to be
% combined as well as the root directory of the files.

function fullSubjectTrain(root_directory,split)

% find folders that contain the split data
data_paths = folderFinder(root_directory,['perct_',num2str(split)],1);

% determine how many paths are present for each subject
total_paths = numel(data_paths);
subject_paths = zeros(total_paths,1);
q = cell(total_paths,1);
subject_index = cell(total_paths,1);

% sort out how  many channels there are!
i = 1;
matched_paths = 0;
while matched_paths < total_paths
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
        file_labels = strsplit(subject_folders{1},filesep);
        save_folder = ['_combine', filesep, formated_subject, filesep,...
            file_labels{end-1}, filesep, file_labels{end} ];
        
        % check starting with this folder!
        if( exist(save_folder,'dir') == 0)
            % directy does not exist, makeone
            mkdir(save_folder);
        end
        
        % file names
        save( [save_folder, filesep, 'test.mat'], 'test_set');
        save( [save_folder, filesep, 'train.mat'], 'train_set');
        
        % track what was built so the loop ends
        matched_paths = sum(subject_paths);
    end
    % iterate to the next subject
    i = i + 1;
end

end