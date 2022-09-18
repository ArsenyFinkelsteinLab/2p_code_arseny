function PLOTS_Population2DReward_all_sessions___vsPoisson__sum
close all;

key = ((EXP2.Session & 'session>=0' ) & LICK2D.ROILick2DPSTHStatsSpikesPoisson & LICK2D.ROILick2DPSTHStatsSpikes) - IMG.Mesoscope ;



dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Lick2D\population\reward_not_meso\'];

filename=['all_sessions_real_vs_poisson__sum'];

flag_spikes = 1; % 1 spikes, 0 dff

%directionl tuning criteria
threshold_theta_tuning_odd_even_corr=0.5;
threshold_goodness_of_fit_vmises=0.5;


%Graphics
%---------------------------------
fig=gcf;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);
left_color=[0 0 0];
right_color=[0 0 0];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

horizontal_dist=0.25;
vertical_dist=0.35;

panel_width1=0.3;
panel_height1=0.3;
position_y1(1)=0.38;
position_x1(1)=0.07;
position_x1(end+1)=position_x1(end)+horizontal_dist*1.5;


panel_width2=0.09;
panel_height2=0.08;
horizontal_dist2=0.25;
vertical_dist2=0.25;

position_x2(1)=0.1;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2*0.8;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;

position_x3(1)=0.05;
position_x3(end+1)=position_x3(end)+horizontal_dist2;
position_x3(end+1)=position_x3(end)+horizontal_dist2;
position_x3(end+1)=position_x3(end)+horizontal_dist2;
position_x3(end+1)=position_x3(end)+horizontal_dist2;


position_y2(1)=0.8;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;

position_y3(1)=0.2;
position_y3(end+1)=position_y3(end)-vertical_dist2;
position_y3(end+1)=position_y3(end)-vertical_dist2;
position_y3(end+1)=position_y3(end)-vertical_dist2;
%---------------------------------




if flag_spikes==1
    rel_all=LICK2D.ROILick2DPSTHStatsSpikes * LICK2D.ROILick2DPSTHStatsSpikesPoisson & key;
else
%     rel_all=LICK2D.ROILick2DRewardStats*LICK2D.ROILick2DPSTHStats*LICK2D.ROILick2Dangle & key;
end



subplot(2,2,1)
rel_signif=  (rel_all   & 'reward_mean_pval_regular_large<1');
PSTH = fetch(rel_signif,'*');
large = [PSTH.reward_mean_large]-[PSTH.reward_mean_regular]./([PSTH.reward_mean_large]+[PSTH.reward_mean_regular]);
large_poisson = [PSTH.reward_mean_large_poisson]-[PSTH.reward_mean_regular_poisson]./([PSTH.reward_mean_large_poisson]+[PSTH.reward_mean_regular_poisson]);

% large = [PSTH.reward_mean_large]./[PSTH.reward_mean_regular];
% large_poisson = [PSTH.reward_mean_large_poisson]./[PSTH.reward_mean_regular_poisson];
plot(large,large_poisson,'.','Color',[1 0.5 0])
hold on
plot([0 2],[0 2])
xlabel(sprintf('Data'))
ylabel(sprintf('Poisson model'))
title('Reward increase modulation');
axis equal
set(gca,'FontSize',12)

subplot(2,2,2)
rel_signif =  (rel_all   & 'reward_mean_pval_regular_small<1');
PSTH = fetch(rel_signif,'*');
small = [PSTH.reward_mean_small]-[PSTH.reward_mean_regular]./([PSTH.reward_mean_small]+[PSTH.reward_mean_regular]);
small_poisson = [PSTH.reward_mean_small_poisson]-[PSTH.reward_mean_regular_poisson]./([PSTH.reward_mean_small_poisson]+[PSTH.reward_mean_regular_poisson]);

% small = [PSTH.reward_mean_small]./[PSTH.reward_mean_regular];
% small_poisson = [PSTH.reward_mean_small_poisson]./[PSTH.reward_mean_regular_poisson];
plot(small,small_poisson,'.','Color',[0 0.5 0])
hold on
plot([0 2],[0 2])
xlabel(sprintf('Data'))
ylabel(sprintf('Poisson model'))
title('Reward Omission modulation');
axis equal
set(gca,'FontSize',12)


if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r500']);
eval(['print ', figure_name_out, ' -dpdf -r200']);




