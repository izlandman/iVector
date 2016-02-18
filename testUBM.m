% given a known ubm built from train_data, test it against another set of
% data. either its own training data, or perhaps a different subject's data

function testUBM(train_data,test_data,ubm)

% file parameters
[speakers, channels] = size(train_data);
gmm_speakers = cell(speakers,1);
[speakers_test, channels_test] = size(test_data);

% build gmms for each speaker in relation to the ubm
map_tau = 19;
config = 'mwv';

for i=1:speakers
    gmm_speakers{i} = mapAdapt(train_data(i,:), ubm, map_tau, config); 
end

trials = zeros(speakers_test*channels_test*speakers_test, 2);
answers = zeros(speakers_test*channels_test*speakers_test, 1);
for ix = 1 : speakers_test,
    b = (ix-1)*speakers_test*channels_test + 1;
    e = b + speakers_test*channels_test - 1;
    trials(b:e, :)  = [ix * ones(speakers_test*channels_test, 1), (1:speakers_test*channels_test)'];
    answers((ix-1)*channels_test+b : (ix-1)*channels_test+b+channels_test-1) = 1;
end

% this 2nd bit needs to be test data!
gmm_scores = score_gmm_trials(gmm_speakers, reshape(test_data', speakers_test*channels_test,1), trials, ubm);

% plots!
figure('numbertitle','off','name','ubm  results');
imagesc(reshape(gmm_scores,speakers_test*channels_test, speakers_test))
title('Channel Verification Likelihood (GMM Model)');
ylabel('Test # (Channel x Segment)'); xlabel('Channel #');
colorbar; drawnow; axis xy;

eer = compute_eer_2(gmm_scores, answers, true);
display(eer);

end