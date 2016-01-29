% take a .mat file of cell contain mel coefficients and generate a matched
% universal background model

% file name needs only be '_xx_xx' of coefficients and window size
function processUBM(file_name, mixtures,iterations, ds_factor, workers)

coeff_file = ['mel_coef',file_name,'.mat'];
% the variable loaded is set_c
load(coeff_file);
output_file = ['ubm',file_name,'.mat'];
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