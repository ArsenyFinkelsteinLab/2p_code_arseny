function [psth_time] = fn_plot_single_cell_psth_example (rel_example, roi_number_uid, xlabel_flag, ylabel_flag)
key_roi.roi_number_uid =roi_number_uid;
P =fetch(rel_example & key_roi,'*');

psth_time = P.psth_time;
psth_reward_max = max([P.psth_regular+P.psth_regular_stem]);
psth_regular= P.psth_regular/psth_reward_max;
psth_regular_stem= P.psth_regular_stem/psth_reward_max;

hold on;
plot([0,0],[0,1],'-k','linewidth',0.25)
shadedErrorBar(psth_time,psth_regular, psth_regular_stem,'lineprops',{'-','Color',[ 0 0 0.8],'linewidth',1});
xl = [floor(psth_time(1)) ceil(psth_time(end))];
xlim(xl);
ylim([0, 1]);
if xlabel_flag ==1
xlabel('Time to lick (s)');
end
if ylabel_flag==1
ylabel(sprintf('Acitivity \n(norm.)'));
end
set(gca,'XTick',[0,xl(end)],'Ytick',[0, 1],'TickLength',[0.05,0], 'FontSize',6);