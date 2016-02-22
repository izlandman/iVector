% return the error rate between the test and training i-vectors, while also
% returning the model_ivs and the final_test_ivs too

function [eer, model_IVs, final_test_IVs ] = scoreIvector(ubm_data, train_data, test_data, workers)

% define variables needed for script
[speakers, channels] = size(train_data);
[speakers_test, channels_test] = size(test_data);
sID = (1:1:speakers)';
speaker_id = repmat(sID,1,channels);

% Calculate the statistics needed for the iVector model.
stats = cell(speakers, channels);
for s=1:speakers
    for c=1:channels
        [N,F] = compute_bw_stats(train_data{s,c}, ubm_data);
        stats{s,c} = [N; F];
    end
end

% Learn the total variability subspace from all the speaker data.
tv_dim = 100;
iterations = 5;
T = train_tv_space(stats(:), ubm_data, tv_dim, iterations, workers);
%
% Now compute the ivectors for each speaker and channel.  The result is size
%   tvDim x nSpeakers x nChannels
develop_IVs = zeros(tv_dim, speakers, channels);
for s=1:speakers
    for c=1:channels
        develop_IVs(:, s, c) = extract_ivector(stats{s, c}, ubm_data, T);
    end
end
% save develop_IVs
% Now do LDA on the iVectors to find the dimensions that matter.
lda_dim = min(tv_dim, speakers-1);
devevlop_IV_Speaker = reshape(develop_IVs, tv_dim, speakers*channels);
[V,D] = lda(devevlop_IV_Speaker, speaker_id(:));
final_develop_IVs = V(:, 1:lda_dim)' * devevlop_IV_Speaker;

% Now train a Gaussian PLDA model with development i-vectors
nphi = lda_dim;                  % should be <= ldaDim
iterations = 10;
pLDA = gplda_em(final_develop_IVs, speaker_id(:), nphi, iterations);


% OK now we have the channel and LDA models. Let's build actual speaker
% models. Normally we do that with new enrollment data, but now we'll just
% reuse the development set.
average_IVs = mean(develop_IVs, 3);           % Average IVs across channels.
model_IVs = V(:, 1:lda_dim)' * average_IVs;

% save model_IVs as those are being compared to the test data


% Now compute the ivectors for the test set 
% and score the utterances against the models
test_IVs = zeros(tv_dim, speakers_test, channels_test); 
for s=1:speakers_test
    for c=1:channels_test
        [N, F] = compute_bw_stats(test_data{s, c}, ubm_data);
        test_IVs(:, s, c) = extract_ivector([N; F], ubm_data, T);
    end
end
test_IV_Speaker = reshape(permute(test_IVs, [1 3 2]), ...
                            tv_dim, speakers_test*channels_test);
final_test_IVs = V(:, 1:lda_dim)' * test_IV_Speaker;

% Now score the models with all the test data.
iv_scores = score_gplda_trials(pLDA, model_IVs, final_test_IVs);
figure('numbertitle','off','name','i-vector confusion');
imagesc(iv_scores)
title('Speaker Verification Likelihood (iVector Model)');
xlabel('Test # (Channel x Speaker)'); ylabel('Model #');
colorbar; axis xy; drawnow;

answers = zeros(speakers*channels*speakers, 1);
for ix = 1 : speakers,
    b = (ix-1)*speakers*channels + 1;
    answers((ix-1)*channels+b : (ix-1)*channels+b+channels-1) = 1;
end

iv_scores = reshape(iv_scores', speakers_test*channels_test* speakers_test, 1);
eer = compute_eer_2(iv_scores, answers, true);

end