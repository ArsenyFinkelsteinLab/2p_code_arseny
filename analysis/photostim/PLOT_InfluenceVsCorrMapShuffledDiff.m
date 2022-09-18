function PLOT_InfluenceVsCorrMapShuffledDiff()
close all

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim\Connectivity_vs_Tuning\'];
filename = 'influence_vs_tuning_by_map_stability';

% rel_data = STIMANAL.InfluenceVsCorrQuadrants & 'session_epoch_number<3' & 'num_targets>=30' & 'num_pairs>=2000' ;
% rel_shuffled = STIMANAL.InfluenceVsCorrQuadrantsShuffled  & 'session_epoch_number<3' & 'num_targets>=30' & 'num_pairs>=2000';

rel_data = STIMANAL.InfluenceVsCorrMap  & 'num_pairs>=0' & 'num_targets>=50' ...
    &  (STIMANAL.SessionEpochsIncludedFinal & IMG.Volumetric & 'stimpower>=100' & 'flag_include=1')   ...;
    %     & (STIMANAL.NeuronOrControlNumber2 & 'num_targets_neurons>=0') ...
%     & (STIMANAL.NeuronOrControlNumber2 & 'num_targets_controls>=0');

rel_shuffled = STIMANAL.InfluenceVsCorrMapShuffled & 'num_pairs>=0' & 'num_targets>=50' ...
    &  (STIMANAL.SessionEpochsIncludedFinal & IMG.Volumetric & 'stimpower>=100' & 'flag_include=1')   ...;
    %     & (STIMANAL.NeuronOrControlNumber2 & 'num_targets_neurons>=0') ...
%     & (STIMANAL.NeuronOrControlNumber2 & 'num_targets_controls>=0');



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
    y_min_max=[-0.01, 0.01];
    if i_c ==1
        plot([bins_corr_edges(1),bins_corr_edges(end)],[0,0],'-k');
        %         plot([0,0],[min(y_mean-y_stem),max(y_mean+y_stem)],'-k');
        plot([0,0],[y_min_max(1),y_min_max(2)],'-k');
        xlim([bins_corr_edges(1), bins_corr_edges(end)]);
    end
    shadedErrorBar(bins_influence_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap(i_c,:)})
    xlabel (['Connection stength' newline '(\Delta z-score activity)']);
        ylabel('Tuning Similarity, \itr');
    box off
    xlim([bins_influence_edges(1), bins_influence_edges(end)]);
    
    subplot(2,2,idx_subplot+2)
    hold on
    y=DATA.influence_binned_by_corr - DATA_SHUFFLED.influence_binned_by_corr;
    y_mean = nanmean(y,1);
    y_stem = nanstd(y,1)./sqrt(size(DATA,1));
    y_min_max=[-0.006, 0.01];
    y_min_max_tick=[-0.005, 0.01];
    if i_c ==1
        plot([bins_corr_edges(1),bins_corr_edges(end)],[0,0],'-k');
        %         plot([0,0],[min(y_mean-y_stem),max(y_mean+y_stem)],'-k');
        plot([0,0],[y_min_max(1),y_min_max(2)],'-k');
        xlim([bins_corr_edges(1), bins_corr_edges(end)]);
    end
    %     shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap(i_c,:)})
    shadedErrorBar(bins_corr_centers,y_mean,y_stem,'lineprops',{'-','Color',colormap})
    plot(bins_corr_centers,y_mean,'.-','Color',colormap)
    xlabel('Tuning Similarity, \itr');
    ylabel (['Connection stength' newline '(\Delta z-score activity)']);
        title(sprintf('Tuning to target position\n'));
    box off
    ylim(y_min_max)
    set(gca,'Ytick',[y_min_max_tick(1), 0, y_min_max_tick(2)])
end


if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r300']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);


