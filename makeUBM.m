function [ubm,eer] = makeUBM(folder_name, train_file, test_file,  mixtures, iterations, ds_factor, workers)

% load the stored data into a new variable name
train_file = load(train_file);
var_name = fieldnames(train_file);
train_data = train_file.(var_name{1});

% grab the test data!
test_file = load(test_file);
var_name = fieldnames(test_file);
test_data = test_file.(var_name{1});

% count ubm files alread present
ubm_count = folderNameCount('ubm',folder_name);

% output file
output_file = [folder_name,filesep,'ubm_',num2str(ubm_count),'_m',num2str(mixtures),'_i',num2str(iterations),'_f',num2str(ds_factor),'.mat'];

% file parameters
[speakers, channels] = size(train_data);
gmm_speakers = cell(speakers,1);
[speakers_test, channels_test] = size(test_data);

% save the gmm/ubm
ubm = gmm_em(train_data(:),mixtures,iterations,ds_factor,workers,output_file);

% build gmms for each speaker in relation to the ubm
map_tau = 10;
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