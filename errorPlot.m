function errorPlot(folder_name)
% load data: _errorPLDA.mat, _errorSens.mat, & ubm_errors.mat which produce
% the variables: error_PLDA, error_UBM & true_positive

load([folder_name,'\','_errorPLDA.mat']);
load([folder_name,'\','_errorSens.mat']);
load([folder_name,'\','ubm_errors.mat']);

figure('numbertitle','off','name',['Error Comparison: ',folder_name]);
plot([error_PLDA/100; error_ubm/100; 1-true_positive]','LineWidth',2);
legend({ 'i-Vector PLDA' 'UBM log likelihood' 'i-vector COSINE' },'Location','best');
ylabel('Percent Error');grid on;

ax = gca;
% adjust xTick labels, if known
if (numel(error_PLDA) == 8 )
    ax.XTickLabel = {'2' '4' '8' '16' '32' '64' '128' '256'};
    xlabel('UBM GMM Mixtures');
end

end