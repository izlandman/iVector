% returns the folders that matches the search query
function result = findDirectoryMatch(query,varargin)

% if a second argument is given, use it as the directory location
if ( nargin > 1 )
    files = dir(varargin{1});
else
    % only looks in present directory
    files = dir();
end

% set result to empty cell
result = {};

file_num = numel(files);

for i=1:file_num
    if( strfind(files(i).name,query) )
        result{end+1} = files(i).name;
    end
end

end