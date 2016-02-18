% find files
function data_files = findMatchingFiles(folder_name,varargin)

% grab all the file names
data_files = getAllFiles(folder_name);

for i=1:nargin-1
    % prune the list given the arguments passed in
    data_files = helpSearch(data_files,varargin{i});
end

end

function matching_files = helpSearch(data_files_1,query)

data_files_index = strfind(data_files_1,query);
data_index = find(~cellfun(@isempty,data_files_index));
matching_files = data_files_1(data_index);

end