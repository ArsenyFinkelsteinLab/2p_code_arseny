function PLOT_InfluenceVsCorrAngle()
close all

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim\Connectivity\'];
filename = 'infleunce_vs_angular_not_difference';

% rel_data = STIMANAL.InfluenceVsCorrAngle2 & 'session_epoch_number<7' & 'num_targets>=10' & 'num_pairs>=1000' ;
% rel_shuffled = STIMANAL.InfluenceVsCorrAngleShuffled2  & 'session_epoch_number<7' & 'num_targets>=10' & 'num_pairs>=1000';
rel_data = STIMANAL.InfluenceVsCorrAngle & 'session_epoch_number<3' & 'num_targets>=5' & 'num_pairs>=100' ;
rel_shuffled = STIMANAL.InfluenceVsCorrAngleShuffled  & 'session_epoch_number<3' & 'num_targets>=5' & 'num_pairs>=100';

key.neurons_or_control=1;
k.response_p_val=1;



num_svd_components_removed_vector_corr = [0];
colormap=viridis(numel(num_svd_components_removed_vector_corr));

for i_c = 1:1:numel(num_svd_components_removed_vector_corr)
    key.num_svd_components_removed_corr=num_svd_components_removed_vector_corr(i_c);
    num_comp = num_svd_components_removed_vector_corr(i_c);
    DATA=struct2table(fetch(rel_data & key & k,'*'));
    DATA_SHUFFLED=struct2table(fetch(rel_shuffled & key,'*'));

    bins_corr_edges = DATA.bins_corr_edges(1,:);
    bins_corr_centers = bins_corr_edges(1:1:end-1) + diff(bins_corr_edges)/2;
    
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
    ylabel('Delta Angle (deg)');
    title('Observed');
    
    idx_subplot = 2;
    subplot(2,2,idx_subplot+1)
    y=DATA_SHUFFLED.corr_binned_by_influence;
    y_mean = nanmean(y,1);
    y_stem = nanstd(y,1)./sqrt(size(DATA,1));
    shadedErrorBar(bins_influence_centers,y_mean,y_stem,'lineprops',{'.','Color',colormap(i_c,:)})
    xlabel ('Influence (delta zscore)');
    ylabel('Delta Angle (deg)');
    title('                                             Shuffled influence, within the same lateral-axial distance');

    
    
    idx_subplot = 0;
    subplot(2,2,idx_subplot+2)
    y=DATA.influence_binned_by_corr;
    y_mean = nanmean(y,1);
    y_stem = nanstd(y,1)./sqrt(size(DATA,1));
    hold on
    shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap(i_c,:)})
    xlabel('Delta Angle (deg)');
    ylabel ('Influence (delta zscore)');
    
    idx_subplot = 2;
        subplot(2,2,idx_subplot+2)
    y=DATA_SHUFFLED.influence_binned_by_corr;
    y_mean = nanmean(y,1);
    y_stem = nanstd(y,1)./sqrt(size(DATA_SHUFFLED,1));
    hold on
    shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'.','Color',colormap(i_c,:)})
    xlabel('Delta Angle (deg)');
    ylabel ('Influence (delta zscore)');
end



if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);

