% find the number of folders sharing the same keyword inthe present
% directory

function folder_count = folderCount(input_string)

files = dir();
all_dir = files([files(:).isdir]);
num_dir = numel(all_dir);
tags = cell(num_dir,1);
for k=1:num_dir
    tags{k}  = all_dir(k).name;
end

folder_count = cellfun(@(S) strfind(S,input_string), tags,'uniformoutput',0);
folder_count = sum( [folder_count{:}] );

end