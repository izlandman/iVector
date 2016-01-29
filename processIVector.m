% assume processUBM has been run already which means a ubm already exists
% for the given data.

function processIVector(file_name, tvDim, iterations, workers)

close all;

coeff_file = ['mel_coef',file_name,'.mat'];
ubm_file = ['ubm',file_name,'.mat'];
% the variable loaded is set_c, features from melcep
load(coeff_file);
[speakers, channels] = size(set_c);
% the variable loaded is ubm, ubm from melcep
load(ubm_file);
ubm = gmm;
clear gmm;

sID = (1:1:speakers)';
speakerID = repmat(sID,1,channels);

%%
% Step2.1: Calculate the statistics needed for the iVector model.
stats = cell(speakers, channels);
for s=1:speakers
    for c=1:channels
        [N,F] = compute_bw_stats(set_c{s,c}, ubm);
        stats{s,c} = [N; F];
    end
end

T = train_tv_space(stats(:), ubm, tvDim, iterations, workers);
%
% Now compute the ivectors for each speaker and channel.  The result is size
%   tvDim x nSpeakers x nChannels
devIVs = zeros(tvDim, speakers, channels);
for s=1:speakers
    for c=1:channels
        devIVs(:, s, c) = extract_ivector(stats{s, c}, ubm, T);
    end
end

%%
% Step3.1: Now do LDA on the iVectors to find the dimensions that matter.
ldaDim = min(100, speakers-1);
devIVbySpeaker = reshape(devIVs, tvDim, speakers*channels);
[V,D] = lda(devIVbySpeaker, speakerID(:));
finalDevIVs = V(:, 1:ldaDim)' * devIVbySpeaker;

% Step3.2: Now train a Gaussian PLDA model with development i-vectors
nphi = ldaDim;                  % should be <= ldaDim
niter = 10;
pLDA = gplda_em(finalDevIVs, speakerID(:), nphi, niter);

%%
% Step4.1: OK now we have the channel and LDA models. Let's build actual speaker
% models. Normally we do that with new enrollment data, but now we'll just
% reuse the development set.
averageIVs = mean(devIVs, 3);           % Average IVs across channels.
modelIVs = V(:, 1:ldaDim)' * averageIVs;

% Step4.2: Now compute the ivectors for the test set 
% and score the utterances against the models
testIVs = zeros(tvDim, speakers, channels); 
for s=1:speakers
    for c=1:channels
        [N, F] = compute_bw_stats(set_c{s, c}, ubm);
        testIVs(:, s, c) = extract_ivector([N; F], ubm, T);
    end
end
testIVbySpeaker = reshape(permute(testIVs, [1 3 2]), ...
                            tvDim, speakers*channels);
finalTestIVs = V(:, 1:ldaDim)' * testIVbySpeaker;

%%
% Step5: Now score the models with all the test data.
ivScores = score_gplda_trials(pLDA, modelIVs, finalTestIVs);
imagesc(ivScores)
title('Speaker Verification Likelihood (iVector Model)');
xlabel('Test # (Channel x Speaker)'); ylabel('Model #');
colorbar; axis xy; drawnow;

answers = zeros(speakers*channels*speakers, 1);
for ix = 1 : speakers,
    b = (ix-1)*speakers*channels + 1;
    answers((ix-1)*channels+b : (ix-1)*channels+b+channels-1) = 1;
end

ivScores = reshape(ivScores', speakers*channels* speakers, 1);
figure;
eer = compute_eer(ivScores, answers, true);
display(eer);
end