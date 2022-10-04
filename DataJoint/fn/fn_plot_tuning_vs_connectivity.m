function fn_plot_tuning_vs_connectivity(rel_data, rel_shuffled, key,title_string, colormap, i_c)


DATA=struct2table(fetch(rel_data & key,'*', 'ORDER BY session_uid'));
DATA_SHUFFLED=struct2table(fetch(rel_shuffled & key,'*', 'ORDER BY session_uid'));

bins_corr_edges = DATA.bins_corr_edges(1,:);
bins_corr_centers = bins_corr_edges(1:1:end-1) + diff(bins_corr_edges)/2;

bins_influence_edges = DATA.bins_influence_edges(1,:);
if bins_influence_edges(1)==-inf
    bins_influence_edges(1)=bins_influence_edges(2) - (bins_influence_edges(3) - bins_influence_edges(2));
    bins_influence_edges(end)=bins_influence_edges(end-1) + (bins_influence_edges(end-2) - bins_influence_edges(end-3));
end
bins_influence_centers = bins_influence_edges(1:1:end-1) + diff(bins_influence_edges)/2;


idx_subplot = 0;
%% Correlation versus connectivity
subplot(2,2,idx_subplot+1)
hold on
y=DATA.corr_binned_by_influence;
y_mean = nanmean(y,1);
y_stem = nanstd(y,1)./sqrt(size(DATA,1));
y_shuf=DATA_SHUFFLED.corr_binned_by_influence;
y_mean_shuf = nanmean(y_shuf,1);
y_stem_shuf = nanstd(y_shuf,1)./sqrt(size(DATA_SHUFFLED,1));
%     y_min_max=[min([y_mean,y_mean_shuf]), max([y_mean,y_stem_shuf])];
if i_c ==1
    %         plot([bins_influence_centers(1),bins_influence_centers(end)],[0,0],'-k');
    plot([0,0],[min(y_mean-y_stem),max(y_mean+y_stem)],'-k');
end
shadedErrorBar(bins_influence_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap(i_c,:)})
shadedErrorBar(bins_influence_centers,y_mean_shuf,y_stem_shuf,'lineprops',{'-','Color',[0.5 0.5 0.5]})
plot(bins_influence_centers,y_mean_shuf,'.-','Color',[0.5 0.5 0.5])
plot(bins_influence_centers,y_mean,'.-','Color',colormap)

xlabel (['Connection stength' newline '(\Delta z-score activity)']);
ylabel('Tuning Similarity, \itr');
title(sprintf(title_string));
box off
xlim([bins_influence_edges(1), bins_influence_edges(end)]);
%% Connectivity versus correlation
subplot(2,2,idx_subplot+2)
hold on
y=DATA.influence_binned_by_corr;
y_mean = nanmean(y,1);
y_stem = nanstd(y,1)./sqrt(size(DATA,1));
y_shuf=DATA_SHUFFLED.influence_binned_by_corr;
y_mean_shuf = nanmean(y_shuf,1);
y_stem_shuf = nanstd(y_shuf,1)./sqrt(size(DATA_SHUFFLED,1));
y_min_max=[min([y_mean,y_mean_shuf]), max([y_mean,y_stem_shuf])];
%     y_min_max_tick=[-0.005, 0.02];
if i_c ==1
    %         plot([bins_corr_edges(1),bins_corr_edges(end)],[0,0],'-k');
    %         plot([0,0],[min(y_mean-y_stem),max(y_mean+y_stem)],'-k');
    plot([0,0],[y_min_max(1),y_min_max(2)],'-k');
    xlim([bins_corr_edges(1), bins_corr_edges(end)]);
end
%     shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap(i_c,:)})
shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap})
shadedErrorBar(bins_corr_centers,y_mean_shuf,y_stem_shuf,'lineprops',{'-','Color',[0.5 0.5 0.5]})
plot(bins_corr_centers,y_mean_shuf,'.-','Color',[0.5 0.5 0.5])
plot(bins_corr_centers,y_mean,'.-','Color',colormap)

xlabel('Tuning Similarity, \itr');
ylabel (['Connection stength' newline '(\Delta z-score activity)']);
title(sprintf(title_string));
box off
%     ylim(y_min_max)
%     set(gca,'Ytick',[y_min_max_tick(1), 0, y_min_max_tick(2)])



%% Residual correlation (i.e. Shuffled subtracted) versus connectivity
subplot(2,2,idx_subplot+3)
hold on
y=DATA.corr_binned_by_influence - DATA_SHUFFLED.corr_binned_by_influence;
y_mean = nanmean(y,1);
y_stem = nanstd(y,1)./sqrt(size(DATA,1));
if i_c ==1
    plot([bins_influence_centers(1),bins_influence_centers(end)],[0,0],'-k');
    plot([0,0],[min(y_mean-y_stem),max(y_mean+y_stem)],'-k');
end
shadedErrorBar(bins_influence_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap(i_c,:)})
plot(bins_influence_centers,y_mean,'.-','Color',colormap)
xlabel (['Connection stength' newline '(\Delta z-score activity)']);
ylabel('Residual Tuning Similarity, \itr');
%     title(sprintf(title_string));
box off
xlim([bins_influence_edges(1), bins_influence_edges(end)]);

%% Residual (i.e. Shuffled subtracted) Connectivity versus correlation
subplot(2,2,idx_subplot+4)
hold on
y=DATA.influence_binned_by_corr - DATA_SHUFFLED.influence_binned_by_corr;
y_mean = nanmean(y,1);
y_stem = nanstd(y,1)./sqrt(size(DATA,1));
% y_min_max=[-0.006, 0.02];
% y_min_max_tick=[-0.005, 0.02];
if i_c ==1
    plot([bins_corr_edges(1),bins_corr_edges(end)],[0,0],'-k');
    %         plot([0,0],[min(y_mean-y_stem),max(y_mean+y_stem)],'-k');
    plot([0,0],[min(y_mean-y_stem),max(y_mean+y_stem)],'-k');
end
%     shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap(i_c,:)})
shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap})
plot(bins_corr_centers,y_mean,'.-','Color',colormap)
xlabel('Tuning Similarity, \itr');
ylabel (['Residual Connection stength' newline '(\Delta z-score activity)']);
%     title(sprintf(title_string));
box off
% ylim(y_min_max)
% set(gca,'Ytick',[y_min_max_tick(1), 0, y_min_max_tick(2)])
    xlim([bins_corr_edges(1), bins_corr_edges(end)]);
