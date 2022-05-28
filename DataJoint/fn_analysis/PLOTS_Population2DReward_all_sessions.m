function PLOTS_Population2DReward_all_sessions
close all;

key = ((EXP2.Session & 'session>=0')&  LICK2D.ROILick2DRewardStatsSpikes &  LICK2D.ROILick2DangleSpikes) - IMG.Mesoscope ;



dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Lick2D\population\reward_not_meso\'];

filename=['all_sessions_spikes'];

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


rel_signif_largereward=  (rel_all   & 'reward_mean_pval_regular_large<0.05');
rel_signif_smallreward=  (rel_all   & 'reward_mean_pval_regular_small<0.05');
     
Slarge_signif=struct2table(fetch(rel_signif_largereward ,'*'));

Ssmall_signif=struct2table(fetch(rel_signif_smallreward ,'*'));

% rel_psth_signif = rel_psth & rel_signif;


change_peak_largereward_signif = 100*((Slarge_signif.reward_peak_large./Slarge_signif.reward_peak_regular)-1);

change_peak_smallreward_signif = 100*((Ssmall_signif.reward_peak_small./Ssmall_signif.reward_peak_regular)-1);





%% Reward preference histogram

%% Regular Reward versus large Reward
axes('position',[position_x2(1), position_y2(1), panel_width2, panel_height2]);
step=40;
bins2 = [-inf,-160:step:160,inf];
bins2_centers=[bins2(2)-step/2, bins2(2:end-1)+step/2];

yyaxis left
a=histogram(change_peak_largereward_signif,bins2);
y =100*a.BinCounts/rel_all.count;
bar(bins2_centers,y,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5]);
% title(sprintf('Response time of tuned neurons'));
% ylim([0 ceil(max(y))]);
ylabel(sprintf('Reward-modulated\n neurons (%%)'),'Color',[0.5 0.5 0.5]);
xlabel(sprintf('Activity change (%%)\n [Large reward - Regular reward] '));
title(sprintf('Neurons modulated\n by reward increase\n'),'Color',[1 0.5 0]);

% of directionally tuned cells as a function of reward modulation
%-----------------------------------------------------------------
idx_directional = Slarge_signif.theta_tuning_odd_even_corr>threshold_theta_tuning_odd_even_corr & Slarge_signif.goodness_of_fit_vmises>threshold_goodness_of_fit_vmises;
tuned_in_change_bins=[];
for ib = 1:1:numel(bins2)-1
    idx_change_bin = change_peak_largereward_signif>=bins2(ib) & change_peak_largereward_signif<bins2(ib+1);
    % percentage tuned in each time bin
    if sum(idx_change_bin)>20 % to avoid spurious values
        tuned_in_change_bins(ib) =100*sum(idx_change_bin&idx_directional)/sum(idx_change_bin);
    else
        tuned_in_change_bins(ib)=NaN;
    end
end
yyaxis right

plot(bins2_centers,tuned_in_change_bins,'.-','LineWidth',2,'MarkerSize',15,'Color',[0 0 1],'Clipping','off')
% xlabel(sprintf('Response time of neurons\n relative to first lickport contact (s)'));
ylabel(sprintf('Directionally tuned\n neurons (%%)'),'Color',[0 0 1]);
set(gca,'Xtick',[-200,0,200],'TickLength',[0.05,0.05],'TickDir','out');
box off
xlim([-200,200]);
ylim([0 ceil(max(tuned_in_change_bins))]);




%% Regular reward versus Reward omission
axes('position',[position_x2(2), position_y2(1), panel_width2, panel_height2]);
step=25;
bins2 = [-inf,-100:step:100,inf];
bins2_centers=[bins2(2)-step/2, bins2(2:end-1)+step/2];

yyaxis left
a=histogram(change_peak_smallreward_signif,bins2);
y =100*a.BinCounts/rel_all.count;
bar(bins2_centers,y,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5]);
% title(sprintf('Response time of tuned neurons'));
% ylim([0 ceil(max(y))]);
ylabel(sprintf('Reward-modulated\n neurons (%%)'),'Color',[0.5 0.5 0.5]);
xlabel(sprintf('Activity change (%%)\n [Reward omission - Regular reward] '));
title(sprintf('Neurons modulated\n by reward omission\n'),'Color',[0 0.7 0.2]);

% of directionally tuned cells as a function of reward modulation
%-----------------------------------------------------------------
idx_directional = Ssmall_signif.theta_tuning_odd_even_corr>threshold_theta_tuning_odd_even_corr & Ssmall_signif.goodness_of_fit_vmises>threshold_goodness_of_fit_vmises ;
tuned_in_change_bins=[];
for ib = 1:1:numel(bins2)-1
    idx_change_bin = change_peak_smallreward_signif>=bins2(ib) & change_peak_smallreward_signif<bins2(ib+1);
    % percentage tuned in each time bin
    if sum(idx_change_bin)>20 % to avoid spurious values
        tuned_in_change_bins(ib) =100*sum(idx_change_bin&idx_directional)/sum(idx_change_bin);
    else
        tuned_in_change_bins(ib)=NaN;
    end
end
yyaxis right

plot(bins2_centers,tuned_in_change_bins,'.-','LineWidth',2,'MarkerSize',15,'Color',[0 0 1],'Clipping','off')
% xlabel(sprintf('Response time of neurons\n relative to first lickport contact (s)'));
ylabel(sprintf('Directionally tuned\n neurons (%%)'),'Color',[0 0 1]);
set(gca,'Xtick',[-100,0,100],'TickLength',[0.05,0.05],'TickDir','out');
box off
xlim([-125,125]);
ylim([0 ceil(max(tuned_in_change_bins))]);



%% Preferred time histogram, for reward increasing or reward decreasing cells
%----------------------------------------------------------------------------

%% Regular reward versus large reward
%----------------------------------------------------------------------------
axes('position',[position_x2(1), position_y2(2), panel_width2, panel_height2]);
psth_time =fetch1(rel_psth & key,'psth_time','LIMIT 1');

time_bins=floor(psth_time(1)):0.5:ceil(psth_time(end));
time_bins_centers=time_bins(1:end-1)+mean(diff(time_bins))/2;

yyaxis left
idx = change_peak_largereward_signif>=0;
a=histogram(Slarge_signif.peaktime_psth(idx),time_bins);
y1 =100*a.BinCounts/sum(a.BinCounts);
bar(time_bins_centers,y1,'FaceColor',[1 0 1],'EdgeColor',[1 0 1],'BarWidth',0.8);
% title(sprintf('Response time of tuned neurons'));
xlim([time_bins(1),time_bins(end)]);
% ylim([0 ceil(max(y1))]);
ylabel(sprintf('Enhanced\n neurons (%%)'),'Color',[1 0 1]);

yyaxis right
idx = change_peak_largereward_signif<0;
a=histogram(Slarge_signif.peaktime_psth(idx),time_bins);
y2 =100*a.BinCounts/sum(a.BinCounts);
bar(time_bins_centers,y2,'FaceColor','none','EdgeColor',[0.5 0 0.5],'BarWidth',0.5,'LineWidth',2);
% title(sprintf('Response time of tuned neurons'));
xlabel(sprintf('Peak response time of neurons\n relative to first lickport contact (s)'));
ylabel(sprintf('Suppressed\n neurons (%%)'),'Color',[0.5 0 0.5]);
set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
box off
xlim([time_bins(1),time_bins(end)]);
ylim([0 ceil(max([y1,y2]))]);
title(sprintf('Neurons modulated\n by reward increase\n'),'Color',[1 0.5 0]);



%% Regular reward versus Reward omission
%----------------------------------------------------------------------------
axes('position',[position_x2(2), position_y2(2), panel_width2, panel_height2]);
psth_time =fetch1(rel_psth & key,'psth_time','LIMIT 1');

time_bins=floor(psth_time(1)):0.5:ceil(psth_time(end));
time_bins_centers=time_bins(1:end-1)+mean(diff(time_bins))/2;

yyaxis left
idx = change_peak_smallreward_signif>=0;
a=histogram(Ssmall_signif.peaktime_psth(idx),time_bins);
y1 =100*a.BinCounts/sum(a.BinCounts);
bar(time_bins_centers,y1,'FaceColor',[1 0 1],'EdgeColor',[1 0 1],'BarWidth',0.8);
% title(sprintf('Response time of tuned neurons'));
xlim([time_bins(1),time_bins(end)]);
% ylim([0 ceil(max(y1))]);
ylabel(sprintf('Enhanced\n neurons (%%)'),'Color',[1 0 1]);

yyaxis right
idx = change_peak_smallreward_signif<0;
a=histogram(Ssmall_signif.peaktime_psth(idx),time_bins);
y2 =100*a.BinCounts/sum(a.BinCounts);
bar(time_bins_centers,y2,'FaceColor','none','EdgeColor',[0.5 0 0.5],'BarWidth',0.5,'LineWidth',2);
% title(sprintf('Response time of tuned neurons'));
xlabel(sprintf('Peak response time of neurons\n relative to first lickport contact (s)'));
ylabel(sprintf('Suppressed\n neurons (%%)'),'Color',[0.5 0 0.5]);
set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
box off
xlim([time_bins(1),time_bins(end)]);
ylim([0 ceil(max([y1,y2]))]);
title(sprintf('Neurons modulated\n by reward omission\n'),'Color',[0 0.7 0.2]);



count_total=count(rel_all);
A_count_largereward=count(rel_signif_largereward);
B_count_smallreward=count(rel_signif_smallreward);

rel_directional = rel_all & 'theta_tuning_odd_even_corr>0.25' & 'goodness_of_fit_vmises>0.5' ;
C_count_directional=count(rel_directional);

rel_signif_largereward=  (rel_all   & 'reward_mean_pval_regular_large<0.05');
rel_signif_smallreward=  (rel_all   & 'reward_mean_pval_regular_small<0.05');

AB= count(rel_all   & 'reward_mean_pval_regular_large<0.05' & 'reward_mean_pval_regular_small<0.05');
AC= count(rel_all   & 'reward_mean_pval_regular_large<0.05' & 'theta_tuning_odd_even_corr>0.25' & 'goodness_of_fit_vmises>0.5' );
BC= count(rel_all   & 'reward_mean_pval_regular_small<0.05' & 'theta_tuning_odd_even_corr>0.25' & 'goodness_of_fit_vmises>0.5' );
ABC= count(rel_all   & 'reward_mean_pval_regular_large<0.05' & 'reward_mean_pval_regular_small<0.05' & 'theta_tuning_odd_even_corr>0.25' & 'goodness_of_fit_vmises>0.5' );


axes('position',[position_x2(3), position_y2(2), panel_width2*3, panel_width2*3]);

% [h,v]=venn([A_count_largereward,B_count_smallreward,C_count_directional], [AB, AC, BC, ABC],'FaceColor',{[1 0.5 0],[0 0.5 1],[1 0 1]}) 
[h,v]=venn([A_count_largereward,B_count_smallreward,C_count_directional], [AB, AC, BC, ABC],'FaceColor',{[1 0.5 0],[0 0.7 0.2],[0 0 1]}) 

%by itself plots circles with total areas A, and intersection area(s) I. 
% A is a three element vector [c1 c2 c3], and I is a four element vector [i12 i13 i23 i123], specifiying the two-circle intersection areas i12, i13, i23, and the three-circle intersection i123.
for i_v=1:1:3%numel(v.ZonePop)
text(v.ZoneCentroid(i_v,1)-v.ZoneCentroid(i_v,1)*0.2,v.ZoneCentroid(i_v,2),sprintf('%.1f%%',(100*v.ZonePop(i_v)/count_total)),'Color',[1 1 1],'FontSize',17,'HorizontalAlignment','left');
end
axis off
box off


text(v.Position(1,1)-v.Radius(1)*1.3,v.Position(1,2)-v.Radius(1)*1.4,sprintf('Reward-increase\n modulated'),'Color',[1 0.5 0],'FontSize',17);
text(v.Position(2,1)-v.Radius(1)*0.5,v.Position(2,2)-v.Radius(2)*1.6,sprintf('Reward-omission\n modulated'),'Color',[0 0.7 0.2],'FontSize',17);
text(v.Position(3,1)-v.Radius(1)*1.3,v.Position(3,2)+v.Radius(3)*1.2,sprintf('Directionally tuned'),'Color',[0 0 1],'FontSize',17);

axes('position',[position_x2(1), position_y2(3), panel_width2, panel_width2]);

pt=fetchn(rel_all,'peaktime_psth');

%% all neurons peak response time
a=histogram(pt,time_bins);
y2 =100*a.BinCounts/sum(a.BinCounts);
bar(time_bins_centers,y2,'FaceColor','none','EdgeColor',[0 0 0],'BarWidth',1,'LineWidth',2);
% title(sprintf('Response time of tuned neurons'));
xlabel(sprintf('Peak response time of neurons\n relative to first lickport contact (s)'));
ylabel(sprintf('Neurons (%%)'));
set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
box off
xlim([time_bins(1),time_bins(end)]);
ylim([0 ceil(max([y1,y2]))]);
title(sprintf('All neurons'),'Color',[0 0 0]);



% %% Scatters
% Sall=struct2table(fetch(rel_signif_largereward ,'*'));
% 
% change_peak_largereward = abs(100*((Sall.reward_peak_large./Sall.reward_peak_regular)-1));
% change_peak_smallreward = abs(100*((Sall.reward_peak_small./Sall.reward_peak_regular)-1));
% 
% goodness_of_fit_vmises = Sall.theta_tuning_odd_even_corr;
% 
% % signal2=100*((DATA_SIGNAL_ALL2.reward_peak_large-DATA_SIGNAL_ALL2.reward_peak_regular)./DATA_SIGNAL_ALL2.reward_peak_regular);
% % signal2_abs=100*abs((DATA_SIGNAL_ALL2.reward_peak_large-DATA_SIGNAL_ALL2.reward_peak_regular)./DATA_SIGNAL_ALL2.reward_peak_regular);
% % 
% % signal22=100*((DATA_SIGNAL_ALL2.reward_peak_small-DATA_SIGNAL_ALL2.reward_peak_regular)./DATA_SIGNAL_ALL2.reward_peak_regular);
% % signal22_abs=100*abs((DATA_SIGNAL_ALL2.reward_peak_small-DATA_SIGNAL_ALL2.reward_peak_regular)./DATA_SIGNAL_ALL2.reward_peak_regular);
% % 
% % signal3 = DATA_SIGNAL_ALL3.psth_odd_even_corr;
% 
% axes('position',[position_x2(3), position_y2(3), panel_width2, panel_height2]);
% plot(goodness_of_fit_vmises,change_peak_largereward,'.')
% 
% mdl = fitlm(goodness_of_fit_vmises,change_peak_largereward)
% 
% 
% axes('position',[position_x2(4), position_y2(3), panel_width2, panel_height2]);
% plot(goodness_of_fit_vmises,change_peak_smallreward,'.')















% %% PSTHs all
% smooth_bins=1; % one element backward, current element, and one element forward
% 
% PSTH_regular = cell2mat(fetchn(rel_psth_signif, 'psth_regular', 'ORDER BY roi_number'));
% PSTH_small = cell2mat(fetchn(rel_psth_signif, 'psth_small', 'ORDER BY roi_number'));
% PSTH_large = cell2mat(fetchn(rel_psth_signif, 'psth_large', 'ORDER BY roi_number'));
% 
% smooth_bins=1;
% 
% ax1=axes('position',[position_x3(1), position_y3(1), panel_width2, panel_height2*1.5]);
% PSTH1 = movmean(PSTH_regular ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% % PSTH=PSTH(:,time_idx);
% PSTH_norm = PSTH1./nanmax(PSTH1,[],2);
% [~,idx]=max(PSTH_norm,[],2);
% [~,idxs]=sort(idx);
% imagesc(psth_time,1:1:numel(idxs),PSTH_norm(idxs,:));
% xlabel('Time (s)');
% ylabel('Neurons');
% title(sprintf('Normalized responses\n regular trials'));
% set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
% cmp=parula;
% colormap(ax1, cmp)
% caxis([nanmin(PSTH_norm(:)) nanmax(PSTH_norm(:))]);
% 
% 
% ax2=axes('position',[position_x3(2), position_y3(1), panel_width2, panel_height2*1.5]);
% PSTH2 = movmean(PSTH_small ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% % PSTH=PSTH(:,time_idx);
% PSTH2_norm = PSTH2./nanmax(PSTH1,[],2);
% imagesc(psth_time,1:1:numel(idxs),PSTH2_norm(idxs,:));
% xlabel('Time (s)');
% ylabel('Neurons');
% title(sprintf('Normalized responses\n smaller reward'));
% set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
% cmp=parula;
% colormap(ax2, cmp)
% caxis([nanmin(PSTH_norm(:)) nanmax(PSTH_norm(:))]);
% 
% 
% 
% 
% ax3=axes('position',[position_x3(3), position_y3(1), panel_width2, panel_height2*1.5]);
% PSTH3 = movmean(PSTH_large ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% % PSTH=PSTH(:,time_idx);
% PSTH3_norm = PSTH3./nanmax(PSTH1,[],2);
% imagesc(psth_time,1:1:numel(idxs),PSTH3_norm(idxs,:));
% xlabel('Time (s)');
% ylabel('Neurons');
% title(sprintf('Normalized responses\n larger reward'));
% set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
% cmp=parula;
% colormap(ax3, cmp)
% caxis([nanmin(PSTH_norm(:)) nanmax(PSTH_norm(:))]);
% 
% 
% ax4=axes('position',[position_x3(4), position_y3(1), panel_width2, panel_height2*1.5]);
% PSTH4 = PSTH2-PSTH1;
% PSTH4 = PSTH4./nanmax(PSTH1,[],2);
% imagesc(psth_time,1:1:numel(idxs),PSTH4(idxs,:));
% xlabel('Time (s)');
% ylabel('Neurons');
% title(sprintf('Smaller-Regular responses'));
% set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
% cmp=parula;
% colormap(ax4, cmp)
% caxis([nanmin(PSTH4(:)) nanmax(PSTH4(:))]);
% 
% ax5=axes('position',[position_x3(5), position_y3(1), panel_width2, panel_height2*1.5]);
% PSTH5 = PSTH3-PSTH1;
% PSTH5 = PSTH5./nanmax(PSTH1,[],2);
% imagesc(psth_time,1:1:numel(idxs),PSTH5(idxs,:));
% xlabel('Time (s)');
% ylabel('Neurons');
% title(sprintf('Larger-Regular responses'));
% set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
% cmp=parula;
% colormap(ax5, cmp)
% caxis([nanmin(PSTH5(:)) nanmax(PSTH5(:))]);

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r500']);
eval(['print ', figure_name_out, ' -dpdf -r200']);




