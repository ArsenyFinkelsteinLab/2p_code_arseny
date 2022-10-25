function PLOT_InfluenceVsCorrTraceBehavResidual()
% close all
clf;

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim\influence_vs_corr\populations_plots\'];
filename = 'InfluenceVsCorrTraceBehavResidual'

key.num_svd_components_removed_corr=0;

rel_data_neurons_residual = STIMANAL.InfluenceVsCorrTraceBehavResidual  & 'neurons_or_control=1' & key ...
    &  (STIMANAL.SessionEpochsIncludedFinal & IMG.Volumetric & 'stimpower>=100' & 'flag_include=1' )  ...
    & (STIMANAL.NeuronOrControlNumber & 'num_targets_neurons>=25') ...
    & (STIMANAL.NeuronOrControlNumber & 'num_targets_controls>=25');

rel_data_control_residual = STIMANAL.InfluenceVsCorrTraceBehavResidual & 'neurons_or_control=0' & key ...
    &  (STIMANAL.SessionEpochsIncludedFinal & IMG.Volumetric & 'stimpower>=100' & 'flag_include=1' )  ...
    & (STIMANAL.NeuronOrControlNumber & 'num_targets_neurons>=25') ...
    & (STIMANAL.NeuronOrControlNumber & 'num_targets_controls>=25');

%     & (STIMANAL.NeuronOrControlNumber & 'num_targets_neurons>=0') ...
%     & (STIMANAL.NeuronOrControlNumber & 'num_targets_controls>=0');



rel_data_neurons_raw = STIMANAL.InfluenceVsCorrTraceBehav & 'neurons_or_control=1' & key ...
    &  (STIMANAL.SessionEpochsIncludedFinal & IMG.Volumetric & 'stimpower>=100' & 'flag_include=1' )  ...
    & (STIMANAL.NeuronOrControlNumber & 'num_targets_neurons>=25') ...
    & (STIMANAL.NeuronOrControlNumber & 'num_targets_controls>=25');

rel_data_neurons_shuffled = STIMANAL.InfluenceVsCorrTraceBehavShuffled & 'neurons_or_control=1' & key ...
    &  (STIMANAL.SessionEpochsIncludedFinal & IMG.Volumetric & 'stimpower>=100' & 'flag_include=1' )  ...
    & (STIMANAL.NeuronOrControlNumber & 'num_targets_neurons>=25') ...
    & (STIMANAL.NeuronOrControlNumber & 'num_targets_controls>=25');

DefaultFontSize =16;
figure
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);





DATA_neurons_residual=struct2table(fetch(rel_data_neurons_residual,'*'));
DATA_control_residual=struct2table(fetch(rel_data_control_residual,'*'));
DATA=struct2table(fetch(rel_data_neurons_raw,'*'));
DATA_SHUFFLED=struct2table(fetch(rel_data_neurons_shuffled,'*'));

%%
bins_corr_edges = DATA.bins_corr_edges(1,:);
if bins_corr_edges(1)==-inf
    bins_corr_edges(1)=bins_corr_edges(2) - (bins_corr_edges(3) - bins_corr_edges(2));
end
if bins_corr_edges(end)==inf
    bins_corr_edges(end)=bins_corr_edges(end-1) + (bins_corr_edges(end-2) - bins_corr_edges(end-3));
end
bins_corr_centers = bins_corr_edges(1:1:end-1) + diff(bins_corr_edges)/2;


bins_influence_edges = DATA.bins_influence_edges(1,:);
if bins_influence_edges(1)==-inf
    bins_influence_edges(1)=bins_influence_edges(2) - (bins_influence_edges(3) - bins_influence_edges(2));
end
if bins_influence_edges(end)==inf
    bins_influence_edges(end)=bins_influence_edges(end-1) + (bins_influence_edges(end-2) - bins_influence_edges(end-3));
end
bins_influence_centers = bins_influence_edges(1:1:end-1) + diff(bins_influence_edges)/2;


% Data and shuffled side by side
subplot(4,4,1)
yl =[-0.1, 1];
hold on
y=DATA.influence_binned_by_corr;
y_mean = nanmean(y,1);
y_stem = nanstd(y,1)./sqrt(size(DATA,1));
plot([bins_influence_edges(1),bins_influence_edges(end)],[0,0],'-k');
plot([0,0],yl,'-k');
xlim([bins_influence_edges(1), bins_influence_edges(end)]);
ylim(yl);
shadedErrorBar(bins_influence_centers(2:1:end-1),y_mean,y_stem,'lineprops',{'-','Color',[1 0 1], 'LineWidth',1})

ylabel('Noise Correlation, \itr');
xlabel (['Connection stength' newline '(\Delta z-score activity)']);
box off
title(sprintf('Comparing Effective Connectivity\n to ''Noise Correlations''\nacross behavioral states'));


% Data and shuffled side by side
subplot(4,4,4)
yl =[-0.1, 1.5];
hold on
y=DATA.corr_binned_by_influence;
y_mean = nanmean(y,1);
y_stem = nanstd(y,1)./sqrt(size(DATA,1));
plot([bins_corr_edges(1),bins_corr_edges(end)],[0,0],'-k');
plot([0,0],yl,'-k');
xlim([bins_corr_edges(1), bins_corr_edges(end)]);
ylim(yl);
shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',[1 0 1], 'LineWidth',1})
ylabel('Noise Correlation, \itr');
xlabel (['Connection stength' newline '(\Delta z-score activity)']);
box off
title(sprintf('Comparing Effective Connectivity,\n to ''Noise Correlations''\nacross behavioral states'));



y=DATA_SHUFFLED.influence_binned_by_corr;
y_mean = nanmean(y,1);
y_stem = nanstd(y,1)./sqrt(size(DATA_SHUFFLED,1));
shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',[1 0.7 0.5], 'LineWidth',1})
% plot(bins_corr_centers,y_mean,'-','Color',[0.8 0 0.8])
xlabel('Trace Correlation, \itr');
ylabel (['Connection stength' newline '(\Delta z-score activity)']);
box off
title(sprintf('Trace Correlations,\n Behavior'));

text(0.01,1.4,'Neuron targets','Color',[1 0 1]);
text(0.01,1.2,sprintf('Shuffled'),'Color',[1 0.7 0.5]);

% %% Data minus Shuffled
%     bins_corr_edges = DATA.bins_corr_edges(1,:);
%     bins_corr_centers = bins_corr_edges(1:1:end-1) + diff(bins_corr_edges)/2;
    
subplot(4,4,2)
yl =[-0.1, 1.5];
hold on
y=DATA.influence_binned_by_corr - DATA_SHUFFLED.influence_binned_by_corr;
y_mean = nanmean(y,1);
y_stem = nanstd(y,1)./sqrt(size(DATA,1));
plot([bins_corr_edges(1),bins_corr_edges(end)],[0,0],'-k');
plot([0,0],yl,'-k');
xlim([bins_corr_edges(1), bins_corr_edges(end)]);
ylim(yl);
shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',[1 0 1], 'LineWidth',1})
xlabel('Trace Correlation, \itr');
ylabel (['Connection stength' newline '(\Delta z-score activity)']);
box off
title(sprintf('Trace Correlations,\n Behavior\residual'));
text(0.01,1.4,'Neuron targets','Color',[1 0 1]);



%%

subplot(4,4,9:10)
yl =[-0.1, 1];
hold on
y=DATA_neurons_residual.influence_binned_by_corr;
y_mean = nanmean(y,1);
y_stem = nanstd(y,1)./sqrt(size(DATA_neurons_residual,1));
plot([bins_corr_edges(1),bins_corr_edges(end)],[0,0],'-k');
plot([0,0],yl,'-k');
xlim([bins_corr_edges(1), bins_corr_edges(end)]);
ylim(yl);
shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',[1 0 1], 'LineWidth',1})
y=DATA_control_residual.influence_binned_by_corr;
y_mean = nanmean(y,1);
y_stem = nanstd(y,1)./sqrt(size(DATA_control_residual,1));
shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',[0.5 0.5 0.5], 'LineWidth',1})
xlabel('Trace Correlation, \itr');
ylabel (['Connection stength' newline '(\Delta z-score activity)']);
box off
title(sprintf('Behavior\n activity'));
text(0.01,-1.4,'Neuron targets','Color',[1 0 1]);
text(0.01,-1.2,sprintf('Control targets'),'Color',[0.5 0.5 0.5]);

%% Zoom in
subplot(4,4,11)
yl =[-0.02, 0.03];
xl = [-0.07, 0.07];
hold on
y=DATA_neurons_residual.influence_binned_by_corr;
y_mean = nanmean(y,1);
y_stem = nanstd(y,1)./sqrt(size(DATA_neurons_residual,1));
plot([bins_corr_edges(1),bins_corr_edges(end)],[0,0],'-k');
plot([0,0],yl,'-k');
xlim(xl);
ylim(yl);
shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',[1 0 1], 'LineWidth',1})
y=DATA_control_residual.influence_binned_by_corr;
y_mean = nanmean(y,1);
y_stem = nanstd(y,1)./sqrt(size(DATA_control_residual,1));
shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',[0.5 0.5 0.5], 'LineWidth',1})
xlabel('Trace Correlation, \itr');
% ylabel ('Influence (\Delta Activity)');
box off
title('Zoom in');
set(gca,'XTick',[-0.05  0 0.05 ],'XTickLabel',[{'-0.05'  '   0' '0.05'} ],'TickLength',[0.05 0.05]);


fig = gcf;    %or one particular figure whose handle you already know, or 0 to affect all figures
set( findall(fig, '-property', 'fontsize'), 'fontsize', DefaultFontSize)






if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);
