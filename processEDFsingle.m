% function to process single recording and build i-vectors for each channel
% to compare the channels to each other. much like how you would compare x
% speakers against each other, we're going to compare each channel against
% the other channels.

% new thought: assume that each recording is a 'channel' like the speech
% example, however there is no difference between test and training data as
% it just learns on everything all at once... the UBM isn't what you would
% use to match new data in, that would be the i-vector

function set_c = processEDFsingle(file_name, target_directory, channels, mel_window, mel_coef)

[path,name,ext] = fileparts(file_name);

[edf_header, edf_data] = edfread(file_name);

edf_data = edf_data(1:channels,:);
sample_rate = edf_header.samples(1);
data_samples = length(edf_data(1,:));

% number of samples per segment
data_window_size = sample_rate * mel_window;
data_windows = floor(data_samples/data_window_size) - 1;

% setup results matrix
mfcc_size = mel_window * sample_rate / 2 - 1;
features = ones(mfcc_size*data_windows, mel_coef);
set_c = cell(channels,1);

% mel options, ensure linear frequency scaling, hence the f
mel_options = 'Mtaf';

for q=1:channels
    for e=1:data_windows
        data_index = 1 + data_window_size*(e-1);
        data_end = data_index + data_window_size - 1;
        data_mel = edf_data(q,data_index:data_end);
        feature_start = 1 + mfcc_size*(e-1);
        feature_end = feature_start + mfcc_size - 1;
        [features(feature_start:feature_end,:),~] = ...
            melcepst( data_mel, sample_rate, mel_options, mel_coef);
    end
    set_c{q}= features';
end

% folder to store results of feature creation
mel_folder = [target_directory,'/edfData_',name];
if( exist(mel_folder,'dir') == 0)
    % directy does not exist, makeone
    mkdir(mel_folder);
end

save_file = [mel_folder,'/','data_melCoef',num2str(mel_coef),...
    '_melWin',num2str(mel_window*1000),'.mat'];
save(save_file,'set_c');

end