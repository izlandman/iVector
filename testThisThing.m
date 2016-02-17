function eer = testThisThing(input_data, ubm)

[speakers,channels] = size(input_data);
gmm_speakers = cell(speakers,1);

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
% figure('numbertitle','off','name','ubm  results');
% imagesc(reshape(gmm_scores,speakers*channels, speakers))
% title('Speaker Verification Likelihood (GMM Model)');
% ylabel('Test # (Channel x Speaker)'); xlabel('Model #');
% colorbar; drawnow; axis xy;

eer = compute_eer_2(gmm_scores, answers, false);
% display(eer);

end