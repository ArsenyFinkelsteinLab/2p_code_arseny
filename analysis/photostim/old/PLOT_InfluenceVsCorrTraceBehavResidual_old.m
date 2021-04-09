function PLOT_InfluenceVsCorrTraceBehavResidual_old()
% close all
clf;
rel_data = STIMANAL.InfluenceVsCorrTraceBehavResidual & 'session_epoch_number<3' & 'num_targets>=30';
% rel_data = STIMANAL.InfluenceVsCorr & 'session_epoch_number<3';
% rel_shuffled = STIMANAL.InfluenceVsCorrShuffled  & 'session_epoch_number<3';
key.neurons_or_control=1;
key.response_p_val=1;



% num_svd_components_removed_vector_corr =[0,1,3,5];
num_svd_components_removed_vector_corr =[0];
colormap=viridis(numel(num_svd_components_removed_vector_corr));

for i_c = 1:1:numel(num_svd_components_removed_vector_corr)
    key.num_svd_components_removed_corr=num_svd_components_removed_vector_corr(i_c);
    num_comp = num_svd_components_removed_vector_corr(i_c);
    DATA=struct2table(fetch(rel_data & key,'*'));
    
    
    
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
    
    
    
    
    
    idx_subplot = 0;
    subplot(2,2,idx_subplot+1)
    hold on
    y=DATA.corr_binned_by_influence;
    y_mean = nanmean(y,1);
    y_stem = nanstd(y,1)./sqrt(size(DATA,1));
    if i_c ==1
        plot([bins_influence_centers(1),bins_influence_centers(end)],[0,0],'-k');
        plot([0,0],[min(y_mean-y_stem),max(y_mean+y_stem)],'-k');
    end
    shadedErrorBar(bins_influence_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap(i_c,:)})
    xlabel ('Influence (\Delta Activity)');
    ylabel('Residual  Correlation');
    box off
    xlim([bins_influence_edges(1), bins_influence_edges(end)]);
    
    subplot(2,2,idx_subplot+2)
    hold on
    y=DATA.influence_binned_by_corr;
    y_mean = nanmean(y,1);
    y_stem = nanstd(y,1)./sqrt(size(DATA,1));
    if i_c ==1
        plot([bins_corr_edges(1),bins_corr_edges(end)],[0,0],'-k');
        plot([0,0],[min(y_mean-y_stem),max(y_mean+y_stem)],'-k');
        xlim([bins_corr_edges(1), bins_corr_edges(end)]);
    end
    shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap(i_c,:)})
    xlabel('Residual  Correlation');
    ylabel ('Influence (\Delta Activity)');
    box off
    
end
