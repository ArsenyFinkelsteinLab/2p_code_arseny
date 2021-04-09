function PLOT_InfluenceVsCorrAngularTuningShuffledDiff()
close all

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim\Connectivity\'];
filename = 'infleunce_vs_angular_tuning';


rel_data = STIMANAL.InfluenceVsCorrAngleTuning & 'session_epoch_number<3' & 'num_targets>=30' & 'num_pairs>=2000' ;
rel_shuffled = STIMANAL.InfluenceVsCorrAngleTuningShuffled  & 'session_epoch_number<3' & 'num_targets>=30' & 'num_pairs>=2000';
% rel_data = STIMANAL.InfluenceVsCorr & 'session_epoch_number<3';
% rel_shuffled = STIMANAL.InfluenceVsCorrShuffled  & 'session_epoch_number<3';
key.neurons_or_control=1;
key.response_p_val=1;

a=fetch(rel_data & key,'*');

num_svd_components_removed_vector_corr =[0];
% colormap=viridis(numel(num_svd_components_removed_vector_corr));
colormap=[0 0 1];

for i_c = 1:1:numel(num_svd_components_removed_vector_corr)
    key.num_svd_components_removed_corr=num_svd_components_removed_vector_corr(i_c);
    num_comp = num_svd_components_removed_vector_corr(i_c);
    DATA=struct2table(fetch(rel_data & key,'*'));
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
    hold on
    y=DATA.corr_binned_by_influence - DATA_SHUFFLED.corr_binned_by_influence;
    y_mean = nanmean(y,1);
    y_stem = nanstd(y,1)./sqrt(size(DATA,1));
    if i_c ==1
        plot([bins_influence_centers(1),bins_influence_centers(end)],[0,0],'-k');
        plot([0,0],[min(y_mean-y_stem),max(y_mean+y_stem)],'-k');
    end
    shadedErrorBar(bins_influence_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap(i_c,:)})
    xlabel ('Influence (delta zscore)');
    ylabel('Residual Signal Correlation, r');
    box off
    xlim([bins_influence_edges(1), bins_influence_edges(end)]);
    
    subplot(2,2,idx_subplot+2)
    hold on
    y=DATA.influence_binned_by_corr - DATA_SHUFFLED.influence_binned_by_corr;
    y_mean = nanmean(y,1);
    y_stem = nanstd(y,1)./sqrt(size(DATA,1));
    if i_c ==1
        plot([bins_corr_edges(1),bins_corr_edges(end)],[0,0],'-k');
        plot([0,0],[min(y_mean-y_stem),max(y_mean+y_stem)],'-k');
            xlim([bins_corr_edges(1), bins_corr_edges(end)]);
    end
    shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap(i_c,:)})
    xlabel('Residual Signal Correlation, r');
    ylabel ('Influence (delta zscore)');
    box off
    
end


if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);
