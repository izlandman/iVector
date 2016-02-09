% pass in two matrices of i-vectors, compare each train vector against all
% the test vectors to 'match' them. generate error/accuracy report

function pruned_result = findIvectorMatch(train,test)

% row gives the number of LDA dimensions that were significant
% column gives the number of original models
[row_model, column_model]  = size(train);
[row_test, column_test] = size(test);

% result matrix that is indexed in 3d, where 3d is model index
result = zeros(column_test+1,column_test+1,column_model);

% for each
for k=1:column_model
    result(:,:,k) = cosineDistance( [train(:,k),test] );
end

% the first column is all that is required, and the first row can be dumped
% as it is just going to be a match against itself
pruned_result = squeeze(result(1,2:end,:));

% pruned_result comes out as one row for each test i-vector and a column
% for each of the known training models. using the min distance as a metric
% to compute accuracy a rough estimate of the algorithms accuracy can be
% generated
[min_distance, min_distance_index] = min(pruned_result,[],2);

% as long as the test set stays in order, we can build known labels easily
v1 = 1:column_model;
v1 = repmat(v1,column_test/column_model,1);
labels = reshape(v1,column_test,1);

true_positive = sum(labels==min_distance_index);
display(['The true positive percentage is ',num2str(true_positive/column_test)]);

end