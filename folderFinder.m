% will find folders labeled with 'figure' where data is stored

% INPUTS: FOLDER_NAME and KEY_WORD are strings ''

% OUTPUTS: DATA_FOLDERS is a cell containing strings of the matched
% KEY_WORD

function data_folders = folderFinder(folder_name,key_word)

% looks only in present directory
list = dir(folder_name);

k = 1;
for i=1:length(list)
    if( findstr(list(i).name,key_word) ~= 0 )
        data_folders{k} = list(i).name;
        k = k + 1;
    end
end

end