function fn_plot_psth_by_reward_size (M,psth_time,i_roi, plot_legend_flag)

psth_reward_max = max([M.psth_regular{i_roi}+M.psth_regular_stem{i_roi},M.psth_small{i_roi}+M.psth_small_stem{i_roi},M.psth_large{i_roi}+ M.psth_large_stem{i_roi}]);
psth_regular= M.psth_regular{i_roi}/psth_reward_max;
psth_small= M.psth_small{i_roi}/psth_reward_max;
psth_large= M.psth_large{i_roi}/psth_reward_max;
psth_regular_stem= M.psth_regular_stem{i_roi}/psth_reward_max;
psth_small_stem= M.psth_small_stem{i_roi}/psth_reward_max;
psth_large_stem= M.psth_large_stem{i_roi}/psth_reward_max;
shadedErrorBar(psth_time,psth_large, psth_large_stem,'lineprops',{'-','Color',[ 1 0.5 0],'linewidth',1});
shadedErrorBar(psth_time,psth_small, psth_small_stem,'lineprops',{'-','Color',[0 0.7 0.2],'linewidth',1});
shadedErrorBar(psth_time,psth_regular, psth_regular_stem,'lineprops',{'-','Color',[ 0 0 0.8],'linewidth',1});
xl = [floor(psth_time(1)) ceil(psth_time(end))];
xlim(xl);
ylim([0, 1]);
xlabel('Time to lick (s)', 'FontSize',10);
ylabel('Response (normalized)', 'FontSize',10);
set(gca,'XTick',[xl(1),0,xl(end)],'Ytick',[0, 1],'TickLength',[0.05,0], 'FontSize',10);
if plot_legend_flag==1
    text(5, 0.7,  sprintf('Regular trials\n'),'Color',[0 0 1]);
    text(5, 0.5, sprintf('Reward increase\n'),'Color',[ 1 0.5 0]);
    text(5, 0.3, sprintf('Reward omission\n'),'Color',[0 0.7 0.2]);
end