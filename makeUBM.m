function makeUBM(input_data, mel_index,  mixtures, iterations, ds_factor, workers)

% make new ubm folder
ubm_folder = ['ubm_',num2str(mel_index)];
% save the generated coefficents and time stamps
if( exist(ubm_folder,'dir') == 0)
    % directy does not exist, makeone
    mkdir(ubm_folder);
end

% count ubm files alread present
files = dir(ubm_folder);
all_files = files(~[files(:).isdir]);
num_files = numel(all_files);
tags = cell(num_files,1);
for k=1:num_files
    tags{k}  = all_files(k).name;
end
ubm_count = cellfun(@(S) strfind(S,'ubm'), tags,'uniformoutput',0);
ubm_count = sum( [ubm_count{:}] );

% output file
output_file = ['./',ubm_folder,'/ubm_',num2str(ubm_count),'_m',num2str(mixtures),'_i',num2str(iterations),'_f',num2str(ds_factor),'.mat'];

% file parameters
[speakers, channels] = size(input_data);
gmm_speakers = cell(speakers,1);

% save the gmm/ubm
ubm = gmm_em(input_data(:),mixtures,iterations,ds_factor,workers,output_file);

% build gmms for each speaker in relation to the ubm
map_tau = 10;
config = 'mwv';

for i=1:speakers
    gmm_speakers{i} = mapAdapt(input_data(i,:), ubm, map_tau, config); 
end

trials = zeros(speakers*channels*speakers, 2);
answers = zeros(speakers*channels*speakers, 1);
for ix = 1 : speakers,
    b = (ix-1)*speakers*channels + 1;
    e = b + speakers*channels - 1;
    trials(b:e, :)  = [ix * ones(speakers*channels, 1), (1:speakers*channels)'];
    answers((ix-1)*channels+b : (ix-1)*channels+b+channels-1) = 1;
end

gmm_scores = score_gmm_trials(gmm_speakers, reshape(input_data', speakers*channels,1), trials, ubm);

% plots!
figure(1);
imagesc(reshape(gmm_scores,speakers*channels, speakers))
title('Speaker Verification Likelihood (GMM Model)');
ylabel('Test # (Channel x Speaker)'); xlabel('Model #');
colorbar; drawnow; axis xy;
figure(2);
eer = compute_eer(gmm_scores, answers, true);
display(eer);

end