% will find folders labeled with 'figure' where data is stored

% INPUTS: FOLDER_NAME and KEY_WORD are strings ''

% OUTPUTS: DATA_FOLDERS is a cell containing strings of the matched
% KEY_WORD

function data_folders = folderFinder(folder_name,key_word,varargin)

switch nargin
    case 2
        % looks only in present directory
        list = dir(folder_name);
    case 3
        % looks in all sub-directories
        list = rdir([folder_name,filesep,'**',filesep]);
end

k = 1;
for i=1:length(list)
    % only find directories!
    if( list(i).isdir == 1 )
        % match the keyword in the path!
        if( findstr(list(i).name,key_word) ~= 0 )
            data_folders{k,1} = list(i).name;
            k = k + 1;
        end
    end
end

end