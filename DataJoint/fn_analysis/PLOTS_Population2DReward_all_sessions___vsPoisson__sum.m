function PLOTS_Population2DReward_all_sessions___vsPoisson__sum
close all;

key = ((EXP2.Session & 'session>=0' )&  LICK2D.ROILick2DRewardStatsSpikes &  LICK2D.ROILick2DangleSpikes) - IMG.Mesoscope ;



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
    rel_psth=LICK2D.ROILick2DPSTHSpikes & key;
    rel_all=LICK2D.ROILick2DRewardStatsSpikes*LICK2D.ROILick2DPSTHStatsSpikes*LICK2D.ROILick2DangleSpikes & key;

else
    rel_psth=LICK2D.ROILick2DPSTH & key;
    rel_all=LICK2D.ROILick2DRewardStats*LICK2D.ROILick2DPSTHStats*LICK2D.ROILick2Dangle & key;
end



subplot(2,2,1)

rel_signif_largereward=  (rel_all   & 'reward_mean_pval_regular_large<0.01');


PSTH = fetch(LICK2D.ROILick2DPSTHSpikesPoisson &rel_signif_largereward,'*');

for i=1:1:length(PSTH)
    sum_PSTH= sum(PSTH(i).psth);
    large_peak_real(i) = sum(PSTH(i).psth_large)./sum_PSTH;
    large_peak_posson(i) =  sum(PSTH(i).psth_large_poisson)./sum_PSTH;
end


plot(large_peak_real,large_peak_posson,'.','Color',[1 0.5 0])
    hold on
    plot([0 2],[0 2])
    xlabel(sprintf('Data'))
    ylabel(sprintf('Poisson model'))
    title('Reward increase modulation');
axis equal
set(gca,'FontSize',12)




subplot(2,2,2)
rel_signif_smallreward=  (rel_all   & 'reward_mean_pval_regular_small<0.01');

PSTH = fetch(LICK2D.ROILick2DPSTHSpikesPoisson &rel_signif_smallreward,'*');

for i=1:1:length(PSTH)
    sum_PSTH= sum(PSTH(i).psth);
    small_peak_real(i) =  sum(PSTH(i).psth_small)./sum_PSTH;
    small_peak_posson(i) =  sum(PSTH(i).psth_small_poisson)./sum_PSTH;
end

plot(small_peak_real,small_peak_posson,'.','Color',[0 0.7 0.2])
    hold on
    plot([0 2],[0 2])

    xlabel(sprintf('Data'))
    ylabel(sprintf('Poisson model'))
    title('Reward omission modulation');
axis equal
set(gca,'FontSize',12)




% subplot(2,2,3)
% 
% rel_nonsignif_largereward=  (rel_all   & 'reward_mean_pval_regular_large>0.5');
% 
% 
% PSTH = fetch(LICK2D.ROILick2DPSTHSpikesPoisson &rel_nonsignif_largereward,'*');
% 
% for i=1:1:length(PSTH)
%     sum_PSTH= sum(PSTH(i).psth);
%     large_peak_real(i) = sum(PSTH(i).psth_large)./sum_PSTH;
%     large_peak_posson(i) =  sum(PSTH(i).psth_large_poisson)./sum_PSTH;
% end
% 
% plot(large_peak_real,large_peak_posson,'.','Color',[1 0.5 0])
%     hold on
%     plot([0 2],[0 2])
%     xlabel(sprintf('Data'))
%     ylabel(sprintf('Poisson model'))
%     title('Reward increase modulation');
% axis equal
% set(gca,'FontSize',12)
% 
% 
% 
% subplot(2,2,4)
% rel_nonsignif_smallreward=  (rel_all   & 'reward_mean_pval_regular_small>0.5');
% 
% PSTH = fetch(LICK2D.ROILick2DPSTHSpikesPoisson &rel_nonsignif_smallreward,'*');
% 
% for i=1:1:length(PSTH)
%     sum_PSTH= sum(PSTH(i).psth);
%     small_peak_real(i) =  sum(PSTH(i).psth_small)./sum_PSTH;
%     small_peak_posson(i) =  sum(PSTH(i).psth_small_poisson)./sum_PSTH;
% end
% 
% 
% plot(small_peak_real,small_peak_posson,'.','Color',[0 0.7 0.2])
%     hold on
%     plot([0 2],[0 2])
% 
%     xlabel(sprintf('Data'))
%     ylabel(sprintf('Poisson model'))
%     title('Reward omission modulation');
% axis equal
% set(gca,'FontSize',12)



if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r500']);
eval(['print ', figure_name_out, ' -dpdf -r200']);




