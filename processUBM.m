% take a .mat file of cell contain mel coefficients and generate a matched
% universal background model

% file name needs only be '_xx_xx' of coefficients and window size
function processUBM(folder_name, mixtures,iterations, ds_factor, workers)

close all;

% find folder matching folder_name query
target_folder = findDirectoryMatch(folder_name);
% input file is the one that starts with data_
mel_file = findDirectoryMatch('data',target_folder{1});
% remove index of mel folder foro use in ubm foldername
mel_index = strsplit(target_folder{1},'_');

% make new ubm folder
ubm_folder = ['ubm_',num2str(mel_index{2})];
% save the generated coefficents and time stamps
if( exist(ubm_folder,'dir') == 0)
    % directy does not exist, makeone
    mkdir(ubm_folder);
end

% output file
output_file = ['./',ubm_folder,'/ubm_m',num2str(mixtures),'_i',num2str(iterations),'_f',num2str(ds_factor),'.mat'];
% the variable loaded is set_c
load([target_folder{1},'/',mel_file{1}]);
[speakers, channels] = size(set_c);
gmm_speakers = cell(speakers,1);

% save the gmm/ubm
ubm = gmm_em(set_c(:),mixtures,iterations,ds_factor,workers,output_file);

% build gmms for each speaker in relation to the ubm
map_tau = 10;
config = 'mwv';

for i=1:speakers
    gmm_speakers{i} = mapAdapt(set_c(i,:), ubm, map_tau, config); 
end

trials = zeros(speakers*channels*speakers, 2);
answers = zeros(speakers*channels*speakers, 1);
for ix = 1 : speakers,
    b = (ix-1)*speakers*channels + 1;
    e = b + speakers*channels - 1;
    trials(b:e, :)  = [ix * ones(speakers*channels, 1), (1:speakers*channels)'];
    answers((ix-1)*channels+b : (ix-1)*channels+b+channels-1) = 1;
end

gmm_scores = score_gmm_trials(gmm_speakers, reshape(set_c', speakers*channels,1), trials, ubm);

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