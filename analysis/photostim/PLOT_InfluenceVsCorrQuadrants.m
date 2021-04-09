function PLOT_InfluenceVsCorrQuadrants()
close all

rel_data = STIMANAL.InfluenceVsCorrQuadrants & 'session_epoch_number<3' & 'num_targets>=30' & 'num_pairs>=2000' ;
rel_shuffled = STIMANAL.InfluenceVsCorrQuadrantsShuffled  & 'session_epoch_number<3' & 'num_targets>=30' & 'num_pairs>=2000';
% rel_data = STIMANAL.InfluenceVsCorr & 'session_epoch_number<3';
% rel_shuffled = STIMANAL.InfluenceVsCorrShuffled  & 'session_epoch_number<3';
key.neurons_or_control=1;
k.response_p_val=1;



num_svd_components_removed_vector_corr = [0,1,5];
colormap=viridis(numel(num_svd_components_removed_vector_corr));

for i_c = 1:1:numel(num_svd_components_removed_vector_corr)
    key.num_svd_components_removed_corr=num_svd_components_removed_vector_corr(i_c);
    num_comp = num_svd_components_removed_vector_corr(i_c);
    DATA=struct2table(fetch(rel_data & key & k,'*'));
    DATA_SHUFFLED=struct2table(fetch(rel_shuffled & key,'*'));
    
    bins_corr_edges = DATA.bins_corr_edges(1,:);
    bins_corr_centers = bins_corr_edges(1:1:end-1) + diff(bins_corr_edges);
    
     bins_influence_edges = DATA.bins_influence_edges(1,:);
    if bins_influence_edges(1)==-inf
    bins_influence_edges(1)=bins_influence_edges(2) - (bins_influence_edges(3) - bins_influence_edges(2));
    bins_influence_edges(end)=bins_influence_edges(end-1) + (bins_influence_edges(end-2) - bins_influence_edges(end-3));
    end
    bins_influence_centers = bins_influence_edges(1:1:end-1) + diff(bins_influence_edges)/2;
    
    
    idx_subplot = 0;
    subplot(2,2,idx_subplot+1)
    y=DATA.corr_binned_by_influence;
    y_mean = nanmean(y,1);
    y_stem = nanstd(y,1)./sqrt(size(DATA,1));
    hold on
    shadedErrorBar(bins_influence_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap(i_c,:)})
    xlabel ('Influence (delta zscore)');
    ylabel('Signal Correlation, r');
    title('Observed');
    
    idx_subplot = 2;
    subplot(2,2,idx_subplot+1)
    y=DATA_SHUFFLED.corr_binned_by_influence;
    y_mean = nanmean(y,1);
    y_stem = nanstd(y,1)./sqrt(size(DATA,1));
    shadedErrorBar(bins_influence_centers,y_mean,y_stem,'lineprops',{'.','Color',colormap(i_c,:)})
    xlabel ('Influence (delta zscore)');
    ylabel('Signal Correlation, r');
    title('                                             Shuffled influence, within the same lateral-axial distance');
    
    
    
    idx_subplot = 0;
    subplot(2,2,idx_subplot+2)
    y=DATA.influence_binned_by_corr;
    y_mean = nanmean(y,1);
    y_stem = nanstd(y,1)./sqrt(size(DATA,1));
    hold on
    shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap(i_c,:)})
    xlabel('Signal Correlation, r');
    ylabel ('Influence (delta zscore)');
    
    idx_subplot = 2;
    subplot(2,2,idx_subplot+2)
    y=DATA_SHUFFLED.influence_binned_by_corr;
    y_mean = nanmean(y,1);
    y_stem = nanstd(y,1)./sqrt(size(DATA_SHUFFLED,1));
    hold on
    shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'.','Color',colormap(i_c,:)})
    xlabel('Signal Correlation, r');
    ylabel ('Influence (delta zscore)');
end
