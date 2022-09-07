function PLOTS_CellsReward2(key, dir_current_fig, flag_spikes, plot_one_in_x_cell)
close all;


% rel_rois=  IMG.ROIGood & (LICK2D.ROILick2DangleSpikes*LICK2D.ROILick2DPSTHStatsSpikes*LICK2D.ROILick2DmapSpikes  & key  & 'psth_odd_even_corr>0.5' & 'theta_tuning_odd_even_corr>0.5' & 'lickmap_regular_odd_vs_even_corr>0.5' & 'goodness_of_fit_vmises>0.5');
if flag_spikes==0 % if based on dff
    rel_rois=  (IMG.ROI& IMG.ROIGood - IMG.ROIBad) & (LICK2D.ROILick2DRewardStatsSpikes  & key    & 'reward_mean_pval_regular_small<=0.01 OR reward_mean_pval_regular_large<=0.01 ');
    rel_map_and_psth = LICK2D.ROILick2DmapSpikes *LICK2D.ROILick2DmapPSTHSpikes *LICK2D.ROILick2DmapStatsSpikes * LICK2D.ROILick2DPSTHSpikes  & rel_rois;
    rel_angle = LICK2D.ROILick2DangleSpikes  & rel_rois;
    rel_stats = LICK2D.ROILick2DPSTHStatsSpikes *LICK2D.ROILick2DSelectivityStatsSpikes  & rel_rois;
else  % if based on spikes
%     rel_rois=  (IMG.ROI& IMG.ROIGood - IMG.ROIBad) & (LICK2D.ROILick2DRewardStatsSpikes & 'reward_mean_pval_regular_small<=0.05 OR reward_mean_pval_regular_large<=0.05 ' ) & (LICK2D.ROILick2DmapStatsSpikes & 'lickmap_regular_odd_vs_even_corr>=0.75' & 'percent_2d_map_coverage_small>=75' & 'number_of_response_trials>=500') & key;
%     rel_rois=  (IMG.ROI& IMG.ROIGood - IMG.ROIBad) & (LICK2D.ROILick2DRewardStatsSpikes & 'reward_mean_pval_regular_small<=0.05 OR reward_mean_pval_regular_large<=0.05 ' ) & (LICK2D.ROILick2DmapStatsSpikes & 'percent_2d_map_coverage_small>=75' & 'number_of_response_trials>=500') & (LICK2D.ROILick2DContactenatedSpikes2 & 'psth_position_concat_regularreward_odd_even_corr>=0.25') & key;
    rel_rois=  (IMG.ROI& IMG.ROIGood - IMG.ROIBad) & ...
        (LICK2D.ROILick2DmapStatsSpikes & 'percent_2d_map_coverage_small>=90' & 'number_of_response_trials>=500' & ...
        ('information_per_spike_regular>=0.05 OR information_per_spike_small>=0.05 OR information_per_spike_large>=0.05')) & ...
        (LICK2D.ROILick2DContactenatedSpikes2 & 'psth_position_concat_regularreward_odd_even_corr>=0.5') & key;
    
    rel_map_and_psth = LICK2D.ROILick2DmapSpikes *LICK2D.ROILick2DmapPSTHSpikes *LICK2D.ROILick2DmapStatsSpikes * LICK2D.ROILick2DPSTHSpikes  & rel_rois;
    rel_angle = LICK2D.ROILick2DangleSpikes  & rel_rois;
    rel_stats = LICK2D.ROILick2DPSTHStatsSpikes *LICK2D.ROILick2DmapStatsSpikes * LICK2D.ROILick2DRewardStatsSpikes*LICK2D.ROILick2DContactenatedSpikes2  & rel_rois;
end

session_date = fetch1(EXP2.Session & key,'session_date');
filename_prefix = [ 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date];



roi_number=fetchn(rel_rois  & key,'roi_number','ORDER BY roi_number');
if isempty(roi_number)
    return
end
    
psthmap_time =fetch1(rel_map_and_psth & key,'psthmap_time','LIMIT 1');
psth_time =fetch1(rel_map_and_psth & key,'psth_time','LIMIT 1');
number_of_bins =fetch1(rel_map_and_psth & key,'number_of_bins','LIMIT 1');
pos_x_bins_centers =fetch1(rel_map_and_psth  & key,'pos_x_bins_centers','LIMIT 1');


smooth_bin = 1;


horizontal_dist1=(1/(number_of_bins+2))*0.7;
vertical_dist1=(1/(number_of_bins+2))*0.6;
panel_width1=(1/(number_of_bins+6))*0.8;
panel_height1=(1/(number_of_bins+6))*0.7;
position_x1(1)=0.1;
position_y1(1)=0.1;
for i=1:1:number_of_bins-1
    position_x1(end+1)=position_x1(end)+horizontal_dist1;
    position_y1(end+1)=position_y1(end)+vertical_dist1;
end

plots_order_mat_x=repmat([1:1:number_of_bins],number_of_bins,1);
plots_order_mat_y=repmat([1:1:number_of_bins]',1,number_of_bins);

horizontal_dist2=(1/(number_of_bins+2))*1.2;
vertical_dist2=(1/(number_of_bins+2));
panel_width2=(1/(number_of_bins+5));
panel_height2=(1/(number_of_bins+5));
position_x2(1)=0.1;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;

position_y2(1)=0.73;
position_y2(end+1)=position_y2(end)-vertical_dist2*1.3;
position_y2(end+1)=position_y2(end)-vertical_dist2*1.5;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;


%Graphics
%---------------------------------
% figure;
figure("Visible",false);
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

% M.psth_stem=[fetchn(rel_map_and_psth,'psth_stem','ORDER BY roi_number')];
M.psth=[fetchn(rel_map_and_psth,'psth_regular','ORDER BY roi_number')];
M.psth_per_position_regular =[fetchn(rel_map_and_psth,'psth_per_position_regular','ORDER BY roi_number')];
M.psth_per_position_regular_odd=[fetchn(rel_map_and_psth,'psth_per_position_regular_odd','ORDER BY roi_number')];
M.psth_per_position_regular_even=[fetchn(rel_map_and_psth,'psth_per_position_regular_even','ORDER BY roi_number')];
M.psth_per_position_small =[fetchn(rel_map_and_psth,'psth_per_position_small','ORDER BY roi_number')];
M.psth_per_position_large =[fetchn(rel_map_and_psth,'psth_per_position_large','ORDER BY roi_number')];

% M.psth_preferred=[fetchn(rel_map_and_psth,'psth_preferred','ORDER BY roi_number')];
% M.psth_non_preferred=[fetchn(rel_map_and_psth,'psth_non_preferred','ORDER BY roi_number')];
% M.selectivity=[fetchn(rel_map_and_psth,'selectivity','ORDER BY roi_number')];
M.lickmap_fr_regular=[fetchn(rel_map_and_psth,'lickmap_fr_regular','ORDER BY roi_number')];
M.lickmap_fr_regular_odd=[fetchn(rel_map_and_psth,'lickmap_fr_regular_odd','ORDER BY roi_number')];
M.lickmap_fr_regular_even=[fetchn(rel_map_and_psth,'lickmap_fr_regular_even','ORDER BY roi_number')];
M.lickmap_fr_small=[fetchn(rel_map_and_psth,'lickmap_fr_small','ORDER BY roi_number')];
M.lickmap_fr_large=[fetchn(rel_map_and_psth,'lickmap_fr_large','ORDER BY roi_number')];
M.lickmap_regular_odd_vs_even_corr=[fetchn(rel_map_and_psth,'lickmap_regular_odd_vs_even_corr','ORDER BY roi_number')];
M.information_per_spike_regular=fetchn(rel_map_and_psth,'information_per_spike_regular','ORDER BY roi_number');
M.information_per_spike_small=fetchn(rel_map_and_psth,'information_per_spike_small','ORDER BY roi_number');
M.information_per_spike_large=fetchn(rel_map_and_psth,'information_per_spike_large','ORDER BY roi_number');
M.psth_odd_even_corr=[fetchn(rel_stats,'psth_odd_even_corr','ORDER BY roi_number')];
M.field_size_regular=[fetchn(rel_map_and_psth,'field_size_regular','ORDER BY roi_number')];
M.field_size_small=[fetchn(rel_map_and_psth,'field_size_small','ORDER BY roi_number')];
M.field_size_large=[fetchn(rel_map_and_psth,'field_size_large','ORDER BY roi_number')];
M.field_size_without_baseline_regular=[fetchn(rel_map_and_psth,'field_size_without_baseline_regular','ORDER BY roi_number')];
M.field_size_without_baseline_small=[fetchn(rel_map_and_psth,'field_size_without_baseline_small','ORDER BY roi_number')];
M.field_size_without_baseline_large=[fetchn(rel_map_and_psth,'field_size_without_baseline_large','ORDER BY roi_number')];
M.centroid_without_baseline_regular=[fetchn(rel_map_and_psth,'centroid_without_baseline_regular','ORDER BY roi_number')];
M.centroid_without_baseline_small=[fetchn(rel_map_and_psth,'centroid_without_baseline_small','ORDER BY roi_number')];
M.centroid_without_baseline_large=[fetchn(rel_map_and_psth,'centroid_without_baseline_large','ORDER BY roi_number')];

% M.preferred_odd_even_corr=[fetchn(rel_stats,'psth_preferred_odd_even_corr','ORDER BY roi_number')];
% M.selectivity_odd_even_corr=[fetchn(rel_stats,'selectivity_odd_even_corr','ORDER BY roi_number')];
% M.psth_quadrants=[fetchn(rel_map_and_psth,'psth_quadrants','ORDER BY roi_number')];
% M.psth_quadrants_odd_even_corr=[fetchn(rel_map_and_psth,'psth_quadrants_odd_even_corr','ORDER BY roi_number')];

M.psth_small=[fetchn(rel_map_and_psth,'psth_small','ORDER BY roi_number')];
M.psth_regular=[fetchn(rel_map_and_psth,'psth_regular','ORDER BY roi_number')];
M.psth_large=[fetchn(rel_map_and_psth,'psth_large','ORDER BY roi_number')];
M.reward_mean_pval_regular_small=[fetchn(rel_stats,'reward_mean_pval_regular_small','ORDER BY roi_number')];
M.reward_mean_pval_regular_large=[fetchn(rel_stats,'reward_mean_pval_regular_large','ORDER BY roi_number')];
M.reward_peak_pval_regular_small=[fetchn(rel_stats,'reward_peak_pval_regular_small','ORDER BY roi_number')];
M.reward_peak_pval_regular_large=[fetchn(rel_stats,'reward_peak_pval_regular_large','ORDER BY roi_number')];
M.psth_position_concat_regularreward_odd_even_corr=[fetchn(rel_stats,'psth_position_concat_regularreward_odd_even_corr','ORDER BY roi_number')];


M = struct2table(M);

M_angle=fetch(rel_angle,'*','ORDER BY roi_number');



for i_roi=1:plot_one_in_x_cell:numel(roi_number)
    %     kkkroi.roi_number=roi_number(i_roi);
    %     M=fetch(rel & kkkroi,'*');
    
    %     i_roi=1;
    %     i_roi
    xl = [floor(psthmap_time(1)) ceil(psthmap_time(end))];
    
    psth_max_regular= cell2mat(reshape(M.psth_per_position_regular{i_roi},[number_of_bins^2,1]));
    psth_max_small= cell2mat(reshape(M.psth_per_position_small{i_roi},[number_of_bins^2,1]));
    psth_max_large= cell2mat(reshape(M.psth_per_position_large{i_roi},[number_of_bins^2,1]));
    
    %     psth_max= psth_max(:,psthmap_time>-2 & psthmap_time<=3);
    
    psth_max_all=max([psth_max_regular(:);psth_max_small(:);psth_max_large(:)]);
    for  i_l=1:1:number_of_bins^2
        axes('position',[position_x1(plots_order_mat_x(i_l)), position_y1(plots_order_mat_y(i_l)), panel_width1, panel_height1]);
        hold on;
        plot(psthmap_time,smooth(M.psth_per_position_regular{i_roi}{i_l}./psth_max_all,smooth_bin),'-','Color',[ 0 0 0],'LineWidth',2);
        try
            plot(psthmap_time,smooth(M.psth_per_position_regular_odd{i_roi}{i_l}./psth_max_all,smooth_bin),'-','Color',[0.25 0.25 0.25]);
            plot(psthmap_time,smooth(M.psth_per_position_regular_even{i_roi}{i_l}./psth_max_all,smooth_bin),'-','Color',[0.75 0.75 0.75]);
        end
        try
            plot(psthmap_time,smooth(M.psth_per_position_small {i_roi}{i_l}./psth_max_all,smooth_bin),'-','Color',[ 0 0.7 0.2 ],'LineWidth',2);
            plot(psthmap_time,smooth(M.psth_per_position_large{i_roi}{i_l}./psth_max_all,smooth_bin),'-','Color',[1 0.5 0],'LineWidth',2);
        end
        ylims=[0,1+eps];
        ylim(ylims);
        xlim(xl);
        if i_l ==1
            xlabel('Time to lick (s)', 'FontSize',14);
            ylabel('Normalized response', 'FontSize',14);
            set(gca,'XTick',[xl(1),0,xl(2)],'Ytick',ylims, 'FontSize',10,'TickLength',[0.05,0]);
        else
            set(gca,'XTick',[xl(1),0,xl(2)],'Ytick',ylims,'YtickLabel',[], 'FontSize',10,'TickLength',[0.05,0]);
        end
        %         title(num2str(plots_order(i_l)))
    end
    
    
    %     % PSTH averaged across all positions
    %     axes('position',[position_x2(1),position_y2(1), panel_width2, panel_height2])
    %     hold on;
    %     xl = [floor(psth_time(1)) ceil(psth_time(end))];
    %     xlim(xl);
    %     psth_m= smooth(M.psth{i_roi},smooth_bin);
    %     max_psth = nanmax(psth_m);
    %     psth_m=psth_m/max_psth;
    % %     psth_stem = smooth(M.psth_stem{i_roi},smooth_bin)/max_psth;
    % %     shadedErrorBar(psth_time,psth_m, psth_stem,'lineprops',{'-','Color','r','markeredgecolor','r','markerfacecolor','r','linewidth',1});
    %
    %     ylim([0, 1]);
    %     title(sprintf('All positions \n odd even r = %.2f ', M.psth_odd_even_corr(i_roi)), 'FontSize',10);
    %     xlabel('Time to lick (s)', 'FontSize',10);
    %     ylabel('Normalized response', 'FontSize',10);
    %     set(gca,'XTick',[xl(1),0,xl(end)],'Ytick',[0, 1],'TickLength',[0.05,0], 'FontSize',10);
    
    %     % PSTH by quadrants
    %     axes('position',[position_x2(2),position_y2(1), panel_width2, panel_height2])
    %     hold on;
    %     %     psth_quadrants= smooth(M.psth_quadrants{i_roi},smooth_bin)';
    %     psth_quadrants= M.psth_quadrants{i_roi};
    %     psth_quadrants = psth_quadrants/nanmax(psth_quadrants);
    %     tttt=numel(psth_quadrants)/4;
    %     psth_q1 = smooth(psth_quadrants(1:tttt),smooth_bin)';
    %     psth_q2 = smooth(psth_quadrants(tttt +1 :tttt*2),smooth_bin)';
    %     psth_q3 = smooth(psth_quadrants(tttt*2 +1 :tttt*3),smooth_bin)';
    %     psth_q4 = smooth(psth_quadrants(tttt*3 +1 :tttt*4),smooth_bin)';
    %
    %     plot(psth_quadrants_time,psth_q1,'-b');
    %     plot(psth_quadrants_time,psth_q2,'-r');
    %     plot(psth_quadrants_time,psth_q3,'-g');
    %     plot(psth_quadrants_time,psth_q4,'-k');
    %
    %     xl = [floor(psth_quadrants_time(1)) ceil(psth_quadrants_time(end))];
    %     xlim(xl);
    %     ylim([0, 1]);
    %     title(sprintf('PSTH per Quadrant \n odd even r = %.2f ', M.psth_quadrants_odd_even_corr(i_roi)), 'FontSize',10);
    %     xlabel('Time to lick (s)', 'FontSize',10);
    %     ylabel('Normalized response', 'FontSize',10);
    %     set(gca,'XTick',[xl(1),0,xl(end)],'Ytick',[0, 1],'TickLength',[0.05,0], 'FontSize',10);
    
    
    
    % PSTH by Reward size
    axes('position',[position_x2(1),position_y2(1), panel_width2, panel_height2])
    hold on;
    psth_small= M.psth_small{i_roi};
    psth_regular= M.psth_regular{i_roi};
    psth_large= M.psth_large{i_roi};
    
    psth_reward_max = max([psth_small,psth_regular,psth_large]);
    psth_small = smooth(psth_small/psth_reward_max,smooth_bin)';
    psth_regular = smooth(psth_regular/psth_reward_max,smooth_bin)';
    psth_large = smooth(psth_large/psth_reward_max,smooth_bin)';
    
    plot(psth_time,psth_regular,'-','Color',[ 0 0 0],'LineWidth',2);
    plot(psth_time,psth_large,'-','Color',[ 1 0.5 0],'LineWidth',2);
    plot(psth_time,psth_small,'-','Color',[0 0.7 0.2],'LineWidth',2);
    
    xl = [floor(psth_time(1)) ceil(psth_time(end))];
    xlim(xl);
    ylim([0, 1]);
    %     title(sprintf('Reward Omission p = %.3f \nIncrease p = %.3f all bins \n \nReward Omission p = %.3f \nIncrease p = %.3f at peak', M.reward_mean_pval_regular_small(i_roi),M.reward_mean_pval_regular_large(i_roi), M.reward_peak_pval_regular_small(i_roi),M.reward_peak_pval_regular_large(i_roi)), 'FontSize',10);
    title(sprintf('ROI %d anm%d s%d\n%s \n\n \nStability concat %.2f \nReward Omission p = %.3f \nIncrease p = %.3f all bins\n',roi_number(i_roi),key.subject_id,key.session, session_date, M.psth_position_concat_regularreward_odd_even_corr(i_roi),M.reward_mean_pval_regular_small(i_roi),M.reward_mean_pval_regular_large(i_roi)), 'FontSize',10);
    xlabel('Time to lick (s)', 'FontSize',10);
    ylabel('Normalized response', 'FontSize',10);
    set(gca,'XTick',[xl(1),0,xl(end)],'Ytick',[0, 1],'TickLength',[0.05,0], 'FontSize',10);
    
    text(5, 0.7,  sprintf('Regular trials\n'),'Color',[0 0 0]);
    text(5, 0.5, sprintf('Reward increase\n'),'Color',[ 1 0.5 0]);
    text(5, 0.3, sprintf('Reward omission\n'),'Color',[0 0.7 0.2]);
    
    
    %     % Preferred, non-preferred and selectivity
    %     axes('position',[position_x2(2),position_y2(1), panel_width2, panel_height2])
    %     hold on;
    %     psth_preferred= smooth(M.psth_preferred{i_roi},smooth_bin)';
    %     psth_non_preferred= smooth(M.psth_non_preferred{i_roi},smooth_bin)';
    %     selectivity = smooth(M.selectivity{i_roi},smooth_bin)';
    %     plot(psthmap_time,psth_preferred,'-b');
    %     plot(psthmap_time,psth_non_preferred,'-r');
    %     plot(psthmap_time,selectivity,'-g');
    %     xlim(time_bin);
    %     ylim([0, (nanmax([psth_preferred,psth_non_preferred]))]);
    %     title(sprintf('Preferred position \n versus all others \n preferred r = %.2f ', M.preferred_odd_even_corr(i_roi)), 'FontSize',10);
    %     xlabel('Time to lick (s)', 'FontSize',10);
    %     ylabel('Spikes/s', 'FontSize',10);
    %     set(gca,'XTick',[time_bin(1),0,time_bin(2)],'Ytick',[0, (nanmax([psth_preferred,psth_non_preferred]))],'TickLength',[0.05,0], 'FontSize',10);
    
    %% Angular tuning
    axes('position',[position_x2(3),position_y2(1), panel_width2, panel_height2])
    hold on;
    xxx=M_angle(i_roi).theta_bins_centers;
    yyy=M_angle(i_roi).theta_tuning_curve;
    yyy_max = nanmax(yyy);
    yyy=yyy./yyy_max;
    yyy_vnmises=(M_angle(i_roi).theta_tuning_curve_vmises)/yyy_max;
    plot([-180:1:179],yyy_vnmises,'-g','LineWidth',2);
    plot(xxx,yyy,'-b','LineWidth',2);
    plot(xxx,M_angle(i_roi).theta_tuning_curve_odd/yyy_max,'-','Color',[0 0 0]);
    plot(xxx,M_angle(i_roi).theta_tuning_curve_even/yyy_max,'-','Color',[0.5 0.5 0.5]);
    
    %     try
    %         title(sprintf('Directional tuning \n RV = %.2f p-val = %.2f \n r = %.2f  p-val = %.4f \n theta = %d thetaVM = %d deg',M(i_roi).rayleigh_length,M(i_roi).pval_rayleigh_length, M(i_roi).theta_tuning_odd_even_corr,  M(i_roi).pval_theta_tuning_odd_even_corr, floor(M(i_roi).preferred_theta), floor(M(i_roi).preferred_theta_vmises)), 'FontSize',10);
    %     catch
    title(sprintf('Directional tuning \n RV = %.2f\n r = %.2f  r^2 fit VM = %.2f \n theta = %d VM = %d deg',M_angle(i_roi).rayleigh_length, M_angle(i_roi).theta_tuning_odd_even_corr, M_angle(i_roi).goodness_of_fit_vmises,  floor(M_angle(i_roi).preferred_theta), floor(M_angle(i_roi).preferred_theta_vmises)), 'FontSize',10);
    %     end
    xlim([-180,180])
    ylim([0, 1])
    xlabel('Direction ({\circ})', 'FontSize',10);
    ylabel('Spikes/s', 'FontSize',10);
    set(gca,'XTick',[-180,0,180],'Ytick',[0, 1], 'FontSize',10,'TickLength',[0.05,0]);
    
    %% Maps regular reward
    axes('position',[position_x2(1),position_y2(2)-0.03, panel_width2*1.5, panel_height2*1.5])
    mmm=M.lickmap_fr_regular{i_roi};
    mmm=mmm./nanmax(mmm(:));
    imagescnan(mmm);
    %     imagescnan(pos_x_bins_centers, pos_x_bins_centers, mmm)
    max_map=max(mmm(:));
    hold on
    plot(M.centroid_without_baseline_regular{i_roi}(1),M.centroid_without_baseline_regular{i_roi}(2),'*');
    caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
    colormap(parula)
    title(sprintf('Regular trials\n I = %.2f bits/spike  \nField size %.1f %%\nField size wob %.1f %%\n', M.information_per_spike_regular(i_roi),M.field_size_regular(i_roi),M.field_size_without_baseline_regular(i_roi)), 'FontSize',10);
    axis xy
    axis equal;
    axis tight
    colorbar
    %     xlabel(sprintf('Lickport X-pos \n(normalized)'), 'FontSize',10);
    %     ylabel(sprintf('Lickport  Z-pos '), 'FontSize',10);
    set(gca,'YDir','normal');
    set(gca, 'FontSize',10);
    axis off
    
    %% Maps reard omission
    axes('position',[position_x2(2),position_y2(2)-0.03, panel_width2*1.5, panel_height2*1.5])
    mmm=M.lickmap_fr_small{i_roi};
    mmm=mmm./nanmax(mmm(:));
    imagescnan(mmm);
    max_map=max(mmm(:));
    hold on
    plot(M.centroid_without_baseline_small{i_roi}(1),M.centroid_without_baseline_small{i_roi}(2),'*');
    caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
    colormap(parula)
    title(sprintf('Reward omission\n I = %.2f bits/spike \nField size %.1f %%\nField size wob %.1f %%\n',M.information_per_spike_small(i_roi), M.field_size_small(i_roi),M.field_size_without_baseline_small(i_roi)), 'FontSize',10);
    axis xy
    axis equal;
    axis tight
    colorbar
    %     xlabel(sprintf('Lickport X-pos \n(normalized)'), 'FontSize',10);
    %     ylabel(sprintf('Lickport  Z-pos '), 'FontSize',10);
    set(gca,'YDir','normal');
    set(gca, 'FontSize',10);
    axis off
    
    %% Maps reward increase
    axes('position',[position_x2(3),position_y2(2)-0.03, panel_width2*1.5, panel_height2*1.5])
    mmm=M.lickmap_fr_large{i_roi};
    mmm=mmm./nanmax(mmm(:));
    imagescnan(mmm);
    max_map=max(mmm(:));
    hold on
    plot(M.centroid_without_baseline_large{i_roi}(1),M.centroid_without_baseline_large{i_roi}(2),'*');
    caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
    colormap(parula)
    title(sprintf('Reward increase\n I = %.2f bits/spike \nField size %.1f %%\nField size wob %.1f %%\n',M.information_per_spike_large(i_roi),M.field_size_large(i_roi),M.field_size_without_baseline_large(i_roi)), 'FontSize',10);
    axis xy
    axis equal;
    axis tight
    colorbar
    %     xlabel(sprintf('Lickport X-pos \n(normalized)'), 'FontSize',10);
    %     ylabel(sprintf('Lickport  Z-pos '), 'FontSize',10);
    set(gca,'YDir','normal');
    set(gca, 'FontSize',10);
    axis off
    
    %% Map regular reward stability
    
    axes('position',[position_x2(4),position_y2(2)-0.03, panel_width2*1.5, panel_height2*1.5])
    mmm=M.lickmap_fr_regular_odd{i_roi};
    mmm=mmm./nanmax(mmm(:));
    imagescnan(mmm);
    max_map=max(mmm(:));
    caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
    colormap(parula)
    title(sprintf('Regular reward\nStability r \n<odd,even> = %.2f \n \n Odd trials\n', M.lickmap_regular_odd_vs_even_corr(i_roi)), 'FontSize',10);
    axis xy
    axis equal;
    axis tight
    set(gca,'YDir','normal');
    colorbar
    axis off
    
    axes('position',[position_x2(5)-0.02,position_y2(2)-0.03, panel_width2*1.5, panel_height2*1.5])
    mmm=M.lickmap_fr_regular_even{i_roi};
    mmm=mmm./nanmax(mmm(:));
    imagescnan(mmm);
    max_map=max(mmm(:));
    caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
    colormap(parula)
    title(sprintf('\n  \n \n\nEven trials\n'), 'FontSize',10);
    axis xy
    axis equal;
    axis tight;
    set(gca,'YDir','normal');
    colorbar
    axis off
    
    
    %     x_bins=M(i_roi).pos_x_bins_centers;
    %     z_bins =M(i_roi).pos_z_bins_centers;
    %     counter=1;
    %     for ix=1:1:numel(x_bins)
    %         for iz=1:1:numel(z_bins)
    %             pos_x(counter) = x_bins(ix);
    %             pos_z(counter) = z_bins(iz);
    %             counter=counter+1;
    %         end
    %     end
    %     [theta, radius] = cart2pol(pos_x,pos_z);
    %     theta=rad2deg(theta);
    %     theta_bins=linspace(-180,180,9);
    %     theta_bins = theta_bins - mean(diff(theta_bins))/2;
    %     theta_bins_centers=theta_bins(1:end-1)+mean(diff(theta_bins))/2;
    %
    %
    %     [temp,~,theta_idx] = histcounts(theta,theta_bins);
    %
    %     theta_idx(theta_idx==0)=1;
    %
    %     map=M(i_roi).lickmap_fr_regular;
    %
    %     for i_theta=1:1:numel(theta_bins_centers)
    %         idx= find( (theta_idx==i_theta));
    %         theta_spikes_binned(i_theta) = sum(map(idx));
    %         theta_timespent_binned(i_theta)=numel(idx);
    %     end
    %
    %     [~, theta_firing_rate_smoothed, preferred_theta,Rayleigh_length]  = fn_compute_generic_1D_tuning2 ...
    %         (theta_timespent_binned, theta_spikes_binned, theta_bins_centers, 1,  1, 1, 1);
    %     plot(theta_bins_centers,theta_firing_rate_smoothed,'-r')
    %
    
    
    
    
    
    if isempty(dir(dir_current_fig))
        mkdir (dir_current_fig)
    end
    %
    filename=[filename_prefix 'roi_' num2str(roi_number(i_roi))];
    figure_name_out=[ dir_current_fig filename];
    eval(['print ', figure_name_out, ' -dtiff  -r100']);
    % eval(['print ', figure_name_out, ' -dpdf -r200']);
    
    
    clf
end
