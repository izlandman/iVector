% function to process single recording and build i-vectors for each channel
% to compare the channels to each other. much like how you would compare x
% speakers against each other, we're going to compare each channel against
% the other channels.

function set_c = processEDF(file_name,segments, mel_window, mel_coef)

[path,name,ext] = fileparts(file_name);

% hard code to only use specific channels
channels = 64;

[edf_header, edf_data] = edfread(file_name);
edf_data = edf_data(1:channels,:);
sample_rate = edf_header.samples(1);
samples = length(edf_data(1,:));

% number of samples per segment
data_segment = floor(samples/segments);
data_window = sample_rate * mel_window;
segment_window = floor(data_segment/data_window);

% setup results matrix
mfcc_feat = zeros(mel_coef, segments);
set_c = cell(channels, segments);

% mel options, ensure linear frequency scaling, hence the f
mel_options = 'Mtaf';

for q=1:channels
    for w=1:segments
        segment_shift = (w-1) * data_segment;
        for e=1:segment_window
            data_index = 1 + data_window*(e-1) + segment_shift;
            data_end = data_index + data_window - 1;
            data_mel = edf_data(q,data_index:data_end);
            [mfcc_feat,~] = melcepst( data_mel, sample_rate, mel_options, mel_coef);
        end
        set_c{q,w} = mfcc_feat;
    end
end

% folder to store results of feature creation
mel_folder = ['edfData_',name];
if( exist(mel_folder,'dir') == 0)
    % directy does not exist, makeone
    mkdir(mel_folder);
end

save_file = [mel_folder,'/','data_melCoef',num2str(mel_coef),...
    '_melWin',num2str(mel_window*1000),'_c',num2str(segments),'.mat'];
save(save_file,'set_c');

end