function ubm = makeUBMonly(folder_name, train_file,  mixtures, iterations, ds_factor, workers)

% load the stored data into a new variable name
train_file = load(train_file);
var_name = fieldnames(train_file);
train_data = train_file.(var_name{1});

% count ubm files alread present
ubm_count = folderNameCount('ubm',folder_name);

% output file
output_file = ['./',folder_name,'/ubm_',num2str(ubm_count),'_m',num2str(mixtures),'_i',num2str(iterations),'_f',num2str(ds_factor),'.mat'];

% save the gmm/ubm
ubm = gmm_em(train_data(:),mixtures,iterations,ds_factor,workers,output_file);

end