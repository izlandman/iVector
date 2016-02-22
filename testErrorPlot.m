function testErrorPlot(test_error,sub)

% row are number of tests, nMixtures
% column are number of subjects
[row,column] = size(test_error);

% generate proper data labels for subjects
legend_labels = cell(column,1);
for i=1:column
    if( sub == 's' )
        legend_labels{i} = ['Subject-',num2str(i)];
    elseif( sub == 't')
        legend_labels{i} = ['Trial-',num2str(i)];
    end
end

% generate x axis tick labels
x_labels = cell(row,1);
for i=1:row
    x_labels{i} = num2str(2^i);
end

line_flash = {'--+', ':o', '--*', ':.', '--s', ':x'};

figure('numbertitle','off','name','UBM EER Result');
ax = gca;
hold on;
grid on;

for i=1:column
    plot(test_error(:,i),line_flash{i},'linewidth',2,'MarkerSize',14);
end
legend(legend_labels,'location','eastoutside');
ylabel('EER %','FontSize',14);
xlabel('Gaussian Mixtures','FontSize',14);
title('Subject Training Set: EER versus Gaussian Mixture Size','FontSize',14)
set(ax,'XTick',[1:row]);
set(ax,'XTickLabel',x_labels);
set(ax,'FontSize',14);

end