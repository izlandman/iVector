function result = folderNameCount(input_string, folder_name)
% count ubm files alread present
files = dir(folder_name);
all_files = files(~[files(:).isdir]);
num_files = numel(all_files);
tags = cell(num_files,1);
for k=1:num_files
    tags{k}  = all_files(k).name;
end
result = cellfun(@(S) strfind(S,input_string), tags,'uniformoutput',0);
result = sum( [result{:}] );
end