function PLOTS_Population2DReward(key, dir_current_fig,flag_spikes, flag_reward)
% close all;
clf;

%directionl tuning criteria
threshold_theta_tuning_odd_even_corr=0.5;
threshold_goodness_of_fit_vmises=0.5;
threshold_rayleigh_length=0.1;

column_radius = 20; %in um
min_num_cells = 5;
if nargin<1
    
    % key.subject_id =447991;
    % key.subject_id = 445978;
    % key.subject_9id = 443627;
    % key.subject_id = 447990;
    % key.session =3;
    % key.subject_id = 445980;
    % key.session =7;
    %
    % key.subject_id = 463195;
    % key.session =3;
    
    % key.subject_id = 462458;
    % key.session =12;
    
    % key.subject_id = 463190;
    % key.session =8;
    key.subject_id = 463189;
    key.session =5;
    
    %     key.subject_id = 464725;
    %     key.session =10;
    %
    % key.fr_interval_start=-1000;
    % key.fr_interval_end=2000;
    % key.fr_interval_start=-1000;
    % key.fr_interval_end=0;
    dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
    dir_current_fig = [dir_base  '\Lick2D\population\psth_distance_meso\'];
    
    
end


if flag_spikes==1
    rel_data=LICK2D.ROILick2DPSTHSpikes;
    rel_stats=LICK2D.ROILick2DRewardStatsSpikes*LICK2D.ROILick2DPSTHStatsSpikes*LICK2D.ROILick2DangleSpikes;
else
    rel_data=LICK2D.ROILick2DPSTH;
    rel_stats=LICK2D.ROILick2DRewardStats*LICK2D.ROILick2DPSTHStats*LICK2D.ROILick2Dangle;
end


switch flag_reward
    case 0 %regular versus large
        rel_rois=  IMG.ROIGood & (rel_stats & key  & 'reward_mean_pval_regular_large<0.05');
        filename_suffix = 'RegularVsLarge';
    case 1 %regular versus large
        rel_rois=  IMG.ROIGood & (rel_stats & key  & 'reward_mean_pval_regular_small<0.05');
        filename_suffix = 'RegularVsSmall';
    case 2 %regular versus large
        rel_rois=  IMG.ROIGood & (rel_stats & key  & 'reward_mean_pval_small_large<0.05');
        filename_suffix = 'SmallVsLarge';
end


session_date = fetch1(EXP2.Session & key,'session_date');

filename = [ 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date filename_suffix];

rel = rel_stats*IMG.PlaneCoordinates*IMG.ROI & rel_rois;
% rel_neuropil = LICK2D.ROILick2DangleNeuropil*IMG.PlaneCoordinates & rel_rois;

rel_all = IMG.ROI*IMG.PlaneCoordinates  & IMG.ROIGood & key;


psth_time =fetch1(rel_data & key,'psth_time','LIMIT 1');
rel_psth = rel_data & rel_rois;


lateral_distance_bins = [0:20:500,inf]; % in microns
euclidean_distance_bins = [10:20:500];

horizontal_dist=0.25;
vertical_dist=0.35;

panel_width1=0.3;
panel_height1=0.3;
position_y1(1)=0.38;
position_x1(1)=0.07;
position_x1(end+1)=position_x1(end)+horizontal_dist*1.5;


panel_width2=0.09;
panel_height2=0.08;
horizontal_dist2=0.16;
vertical_dist2=0.21;

position_x2(1)=0.05;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2*1.5;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;

position_x3(1)=0.05;
position_x3(end+1)=position_x3(end)+horizontal_dist2;
position_x3(end+1)=position_x3(end)+horizontal_dist2;
position_x3(end+1)=position_x3(end)+horizontal_dist2;
position_x3(end+1)=position_x3(end)+horizontal_dist2;


position_y2(1)=0.8;
position_y2(end+1)=position_y2(end)-vertical_dist2*0.9;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;

position_y3(1)=0.2;
position_y3(end+1)=position_y3(end)-vertical_dist2;
position_y3(end+1)=position_y3(end)-vertical_dist2;
position_y3(end+1)=position_y3(end)-vertical_dist2;


% mean_img_enhanced = fetch1(IMG.Plane & key & 'plane_num=1','mean_img_enhanced');
% pix2dist= fetch1(IMG.Parameters & 'parameter_name="fov_size_microns_z1.1"', 'parameter_value')/fetch1(IMG.FOV & key &'fov_num=1', 'fov_x_size');
pix2dist=1;





M=fetch(rel ,'*');

M=struct2table(M);
roi_number=M.roi_number;

% M_neuropil=fetch(rel_neuropil ,'*');
% M_neuropil=struct2table(M_neuropil);



M_all_all=fetch(rel_all ,'*');
M_all_all=struct2table(M_all_all);
roi_number_all=M_all_all.roi_number;

x_all = M.roi_centroid_x + M.x_pos_relative;
y_all = M.roi_centroid_y + M.y_pos_relative;

mesoscope_check=IMG.Mesoscope & key;
if count(mesoscope_check) % if mesoscope
    x_all=x_all/0.75;
    y_all=y_all/0.5;
end

x_all_all = M_all_all.roi_centroid_x + M_all_all.x_pos_relative;
y_all_all = M_all_all.roi_centroid_y + M_all_all.y_pos_relative;

if count(mesoscope_check) % if mesoscope
    x_all_all=x_all_all/0.75;
    y_all_all=y_all_all/0.5;
end


%% Distance (lateral, axial) and time
switch flag_reward
    case 0 %regular versus large
        x=M.reward_peak_regular;
        y=M.reward_peak_large;
    case 1 %regular versus small
        x=M.reward_peak_regular;
        y=M.reward_peak_small;
    case 2 %small versus large
        x=M.reward_peak_small;
        y=M.reward_peak_large;
end



change_mean = 100*((y./x)-1);

% time_all_neuropil =M_neuropil.peaktime_psth;

%% cells vs neuropil
% dtime_cells_vs_neuropil= circ_dist(deg2rad(time_all),deg2rad(time_all_neuropil));
% %     dtime_temp = dtime_temp - 2*180*floor( (dtime_temp+180)/(2*180) );
% dtime_cells_vs_neuropil = abs(rad2deg(dtime_cells_vs_neuropil));
% % histogram(time_all)
% % histogram(time_all_neuropil)
% histogram(dtime_cells_vs_neuropil)
% % plot(time_all,time_all_neuropil,'.')
%
% % plot(M.rayleigh_length,M_neuropil.rayleigh_length,'.')
% histogram(M.rayleigh_length-M_neuropil.rayleigh_length)
% histogram(M.time_tuning_odd_even_corr-M_neuropil.time_tuning_odd_even_corr)
%
% % plot(M.time_tuning_odd_even_corr,M_neuropil.time_tuning_odd_even_corr,'.')


% x_all=M.roi_centroid_x*pix2dist;
% y_all=M.roi_centroid_y*pix2dist;
z_all=M.z_pos_relative;
%                     dx = g_x - R_x(i_r);
%                     dy = g_y - R_y(i_r);
%                     distance = sqrt(dx.^2 + dy.^2); %pixels
%                     distance3D = sqrt( (dx*pix2dist).^2 + (dy*pix2dist).^2 + roi_z(i_r).^2); %um

%{
for ii=1:1:numel(time_all)
    
    x=x_all(ii);
    y=y_all(ii);
    z=z_all(ii);
    
    dXY(ii,:)= sqrt((x_all-x).^2 + (y_all-y).^2); % in um
    dZ(ii,:)= abs(z_all - z); % in um
    d3D(ii,:) = sqrt((x_all-x).^2 + (y_all-y).^2 + (z_all-z).^2); % in um
    
    time = M.peaktime_psth(ii);
    dtime(ii,:)  = abs(time_all-time);
    %     dtime_temp = dtime_temp - 2*180*floor( (dtime_temp+180)/(2*180) );
    
%     time_neuropil = time_all_neuropil(ii);
%     dtime_temp_neuropil = circ_dist(deg2rad(time_all_neuropil),deg2rad(time_neuropil));
%     %     dtime_temp = dtime_temp - 2*180*floor( (dtime_temp+180)/(2*180) );
%     dtime_neuropil(ii,:) = abs(rad2deg(dtime_temp_neuropil));
    
end
dXY=dXY(:);

idx_not_self = dXY>0;
dXY=dXY(idx_not_self);

dZ=dZ(idx_not_self);
d3D=d3D(idx_not_self);
dtime=dtime(idx_not_self);
% dtime_neuropil =dtime_neuropil(idx_not_self);

%% Lateral distance

[N,~,bin] = histcounts(dXY(:),lateral_distance_bins);
idx_valid_bins = [N>=min_num_cells,1]>0;
lateral_distance_bins=lateral_distance_bins(idx_valid_bins);
[N,~,bin] = histcounts(dXY(:),lateral_distance_bins);

for i=1:1:numel(lateral_distance_bins)-1
    idx = (bin ==i);
    dtime_XYdist_mean(i) = mean(dtime(idx));
%     dtime_XYdist_var(i) = rad2deg(circ_var(deg2rad(dtime(idx))))/sqrt(sum(idx));
    
%     dtime_XYdist_mean_neuropil(i) = rad2deg(circ_mean(deg2rad(dtime_neuropil(idx))));
%     dtime_XYdist_var_neuropil(i) = rad2deg(circ_var(deg2rad(dtime_neuropil(idx))))/sqrt(sum(idx));
    
end

%shuffled
idx_shuffled = randperm(numel(dtime(:)));
dtime_shuffled = dtime(idx_shuffled);
% dtime_shuffled_neuropil = dtime_neuropil(idx_shuffled);

for i=1:1:numel(lateral_distance_bins)-1
    idx = (bin ==i);
    dtime_XYdist_shuffled(i) =  mean(dtime_shuffled(idx));
%     dtime_XYdist_shuffled_neuropil(i) = rad2deg(circ_mean(deg2rad(dtime_shuffled_neuropil(idx))));
end

ax1=axes('position',[position_x2(3), position_y2(3), panel_width2, panel_height2]);
hold on;
plot(lateral_distance_bins(1:1:end-1),dtime_XYdist_mean,'-r')
plot(lateral_distance_bins(1:1:end-1),dtime_XYdist_shuffled,'-k')
ylim([0,5]);
xlabel('Lateral distance (\mum)');
    ylabel('\Delta Time (s)');
    title(sprintf('Response Time \nLateral distance'));
xlim([0,lateral_distance_bins(end-1)]);
set(gca,'YTick',[0,5]);

% ax1=axes('position',[position_x2(3), position_y2(4), panel_width2, panel_height2]);
% hold on;
% plot(lateral_distance_bins(1:1:end-1),dtime_XYdist_mean_neuropil,'-r')
% plot(lateral_distance_bins(1:1:end-1),dtime_XYdist_shuffled_neuropil,'-k')
% ylim([0,110]);
% xlabel('Lateral distance (\mum)');
% ylabel('\Delta\time (\circ)');
% title(sprintf('Neuropil'));
% xlim([0,lateral_distance_bins(end-1)]);
% set(gca,'YTick',[0, 45, 90]);

%% Axial Distance dependence
if max(dZ)>0
    idx_within_column = dXY<=column_radius;
    
    dtime_column = dtime(idx_within_column);
    dtime_column_neuropil = dtime_neuropil(idx_within_column);
    
    dZ_column = dZ(idx_within_column);
    axial_distance_bins = unique(dZ_column)';
    axial_distance_bins=[axial_distance_bins,inf];
    [N,edges,bin] = histcounts(dZ_column,axial_distance_bins);
    for i=1:1:numel(axial_distance_bins)-1
        idx = (bin ==i);
        dtime_Zdist_mean(i) = mean(dtime_column(idx));
        dtime_Zdist_var(i) = var(dtime_column(idx))/sqrt(sum(idx));
        
%         dtime_Zdist_mean_neuropil(i) = rad2deg(circ_mean(deg2rad(dtime_column_neuropil(idx))));
%         dtime_Zdist_var_neuropil(i) = rad2deg(circ_var(deg2rad(dtime_column_neuropil(idx))))/sqrt(sum(idx));
    end
    
    %shuffled
    idx_shuffled = randperm(numel(dtime_column(:)));
    dtime_column_shuffled = dtime_shuffled(idx_within_column);
%     dtime_column_shuffled_neuropil = dtime_shuffled_neuropil(idx_within_column);
    
    for i=1:1:numel(axial_distance_bins)-1
        idx = (bin ==i);
        dtime_Zdist_mean_shuffled(i) = mean(dtime_column_shuffled(idx));
%         dtime_Zdist_mean_shuffled_neuropil(i) = rad2deg(circ_mean(deg2rad(dtime_column_shuffled_neuropil(idx))));
        
        %     dtime_Zdist_var(i) = rad2deg(circ_var(deg2rad(dtime_shuffled(idx))))/sqrt(sum(idx));
    end
    
    ax1=axes('position',[position_x2(4), position_y2(3), panel_width2, panel_height2]);
    hold on;
    plot(axial_distance_bins(1:1:end-1),dtime_Zdist_mean,'.-r')
    plot(axial_distance_bins(1:1:end-1),dtime_Zdist_mean_shuffled,'.-k')
    ylim([0,5]);
    xlabel('Axial distance (\mum)');
    ylabel('\Delta Time (s)');
    title(sprintf('Response Time \nAxial distance'));
    xlim([0,axial_distance_bins(end-1)]);
    set(gca,'YTick',[0,5]);
    
%     ax1=axes('position',[position_x2(4), position_y2(4), panel_width2, panel_height2]);
%     hold on;
%     plot(axial_distance_bins(1:1:end-1),dtime_Zdist_mean_neuropil,'.-r')
%     plot(axial_distance_bins(1:1:end-1),dtime_Zdist_mean_shuffled_neuropil,'.-k')
%     ylim([0,110]);
%     xlabel('Axial distance (\mum)');
%     ylabel('\Delta\time (\circ)');
%     title(sprintf('Neuropil'));
%     xlim([0,axial_distance_bins(end-1)]);
%     set(gca,'YTick',[0, 45, 90]);
    
    %     %% 3D Distance dependence
    %     % euclidean_distance_bins = lateral_distance_bins(2:end);
    %     [N,~,bin] = histcounts(d3D(:),euclidean_distance_bins);
    %     for i=1:1:numel(euclidean_distance_bins)-1
    %         idx = (bin ==i);
    %         dtime_3Ddist_mean(i) = rad2deg(circ_mean(deg2rad(dtime(idx))));
    %         dtime_3Ddist_var(i) = rad2deg(circ_var(deg2rad(dtime(idx))))/sqrt(sum(idx));
    %     end
    %
    %     %shuffled
    %     idx_shuffled = randperm(numel(dtime(:)));
    %     for i=1:1:numel(euclidean_distance_bins)-1
    %         idx = (bin ==i);
    %         dtime_shuffled = dtime(idx_shuffled);
    %         dtime_3Ddist_shuffled(i) = rad2deg(circ_mean(deg2rad(dtime_shuffled(idx))));
    %     end
    %
    %     ax1=axes('position',[position_x2(5), position_y2(3), panel_width2, panel_height2]);
    %     hold on;
    %     plot(euclidean_distance_bins(1:1:end-1),dtime_3Ddist_mean,'-r')
    %     plot(euclidean_distance_bins(1:1:end-1),dtime_3Ddist_shuffled,'-k')
    %     ylim([0,110]);
    %     xlabel('Euclidean (3D) distance (\mum)');
    %     ylabel('\Delta\time (\circ)');
    %     title(sprintf('Preferred Direction \nEuclidean (3D)  distance'));
    %     xlim([0,euclidean_distance_bins(end-1)]);
    %     set(gca,'YTick',[0, 45, 90]);
end
%}





%%

% ax=gca;
% ax.timeTick = [0 90 180 270];
% ax.timeTickLabel = [0 90 180 -90];
% ax.RTick=[max(BinCounts)];

% axes('position',[position_x2(4)-0.02, position_y2(1), panel_width2, panel_height2]);
% b=histogram(M.preferred_radius,4);
% title(sprintf('Preferred amplitude \nof tuned neurons\n'));
% xlabel('Radial distance (normalized)')
% ylabel('Counts')
% box off;
% xlim([0,b.BinEdges(end)])
%
% axes('position',[position_x2(1), position_y2(3), panel_width2, panel_height2]);
% b=histogram(M.lickmap_odd_even_corr,10);
% title(sprintf('2D MAP Tuning stability \n'));
% xlabel(sprintf('Correlation (odd,even) trials'));
% ylabel('Counts')
% box off;
% xlim([-1,1])

% axes('position',[position_x2(1), position_y2(3), panel_width2, panel_height2]);
% b1=histogram(M.time_tuning_odd_even_corr,10);
% title(sprintf('Directional-tuning stability \n'));
% xlabel(sprintf('Correlation (odd,even) trials'));
% ylabel('Counts')
% box off;
% xlim([-1,1])
%
% axes('position',[position_x2(1), position_y2(4), panel_width2, panel_height2]);
% b2=histogram(M_neuropil.time_tuning_odd_even_corr,10);
% title(sprintf('Neuropil'));
% xlabel(sprintf('Correlation (odd,even) trials'));
% ylabel('Counts')
% box off;
% xlim([-1,1])

% axes('position',[position_x2(3), position_y2(3), panel_width2, panel_height2]);
% b=histogram(M.information_per_spike,10);
% title(sprintf('Positional (2D) tuning \n'));
% xlabel(sprintf('Information (bits/spike)'));
% ylabel('Counts')
% box off;
% % xlim([-1,1])

% axes('position',[position_x2(2), position_y2(3), panel_width2, panel_height2]);
% b1=histogram(M.rayleigh_length,10);
% title(sprintf('Directional tuning \n'));
% xlabel(sprintf('Rayleigh vector length'));
% ylabel('Counts')
% box off;
% xlim([0,b1.BinLimits(2)])
%
% axes('position',[position_x2(2), position_y2(4), panel_width2, panel_height2]);
% b2=histogram(M_neuropil.rayleigh_length,10);
% title(sprintf('Neuropil'));
% xlabel(sprintf('Rayleigh vector length'));
% ylabel('Counts')
% box off;
% xlim([0,b1.BinLimits(2)])

% axes('position',[position_x2(5), position_y2(4), panel_width2, panel_height2]);
% b2=histogram(dtime_cells_vs_neuropil,18);
% title(sprintf('Neurons vs. Neuropil'));
% xlabel('Neurons vs Neuropil \Delta\time(\circ)');
% ylabel('Counts')
% box off;
% xlim([0,180])


%% Map of reward response
bins1 = [-inf,-100:1:100,inf];
[N,edges,bin]=histcounts(change_mean,bins1);
ax1=axes('position',[position_x1(1), position_y1(1), panel_width1*2, panel_height1*2]);
hold on;
my_colormap=jet(numel(bins1));
% my_colormap=plasma(numel(time_bins1));

for i_roi=1:1:size(M_all_all,1)
    plot(x_all_all(i_roi)*pix2dist, y_all_all(i_roi)*pix2dist,'.','Color',[0.9 0.9 0.9],'MarkerSize',7)
end

for i_roi=1:1:size(M,1)
    plot(x_all(i_roi)*pix2dist, y_all(i_roi)*pix2dist,'.','Color',my_colormap(bin(i_roi),:),'MarkerSize',7)
end
axis xy
set(gca,'YDir','reverse')
% title(sprintf('Motor map, left ALM\n n = %d tuned neurons (%.1f%%) \n',size(M,1), 100*size(M,1)/rel_all_good_cells.count   ));
% set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, 800], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,800],'TickLength',[0.01,0],'TickDir','out')
axis equal
axis tight
xlabel('Anterior - Posterior (\mum)');
ylabel('Lateral - Medial (\mum)');
title([ 'anm' num2str(key.subject_id) ' s' num2str(key.session) ' ' session_date filename_suffix]);
% Colorbar
ax2=axes('position',[position_x2(4)+0.15, position_y2(1)+0.08, panel_width2, panel_height2/4]);
colormap(ax2,my_colormap)
% cb1 = colorbar(ax2,'Position',[position_x2(4)+0.15, position_y2(1)+0.1, panel_width2, panel_height2/4], 'Ticks',[0, 0.5, 1],...
%     'TickLabels',[-5,0,5],'Location','NorthOutside');
cb1 = colorbar(ax2,'Position',[position_x2(4)+0.15, position_y2(1)+0.1, panel_width2, panel_height2/4], 'Ticks',[0, 0.5, 1],...
    'TickLabels',[],'Location','NorthOutside');
axis off;



%% Reward preference histogram

axes('position',[position_x2(4)+0.15, position_y2(1), panel_width2, panel_height2]);
step=25;
bins2 = [-inf,-80:step:80,inf];
bins2_centers=[bins2(2)-step/2, bins2(2:end-1)+step/2];

yyaxis left
a=histogram(change_mean,bins2);
y =100*a.BinCounts/rel_all.count;
bar(bins2_centers,y,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5]);
% title(sprintf('Response time of tuned neurons'));
% ylim([0 ceil(max(y))]);
ylabel(sprintf('Reward-modulated\n neurons (%%)'),'Color',[0.5 0.5 0.5]);
xlabel(sprintf('Reward-modulation (%% increase)'));

%% of directionally tuned cells as a function of preferred PSTH time
% axes('position',[position_x2(4)+0.15, position_y2(2), panel_width2, panel_height2]);
idx_directional = M.theta_tuning_odd_even_corr>threshold_theta_tuning_odd_even_corr & M.goodness_of_fit_vmises>threshold_goodness_of_fit_vmises & M.rayleigh_length>threshold_rayleigh_length;
for ib = 1:1:numel(bins2)-1
    idx_change_bin = change_mean>=bins2(ib) & change_mean<bins2(ib+1);
    % percentage tuned in each time bin
    if sum(idx_change_bin)>20 % to avoid spurious values
        tuned_in_change_bins(ib) =100*sum(idx_change_bin&idx_directional)/sum(idx_change_bin);
    else
        tuned_in_change_bins(ib)=NaN;
    end
end
yyaxis right

plot(bins2_centers,tuned_in_change_bins,'.-','LineWidth',2,'MarkerSize',15)
% xlabel(sprintf('Response time of neurons\n relative to first lickport contact (s)'));
ylabel(sprintf('Directionally tuned\n neurons (%%)'));
set(gca,'Xtick',[-100,0,100],'TickLength',[0.05,0.05],'TickDir','out');
box off
xlim([-100,100]);
ylim([0 ceil(max(tuned_in_change_bins))]);



%% Preferred time histogram, for reward increasing or reward decreasing cells
axes('position',[position_x2(4)+0.15, position_y2(2), panel_width2, panel_height2]);
time_bins=floor(psth_time(1)):1:ceil(psth_time(end));
time_bins_centers=time_bins(1:end-1)+mean(diff(time_bins))/2;

yyaxis left
idx = change_mean>=0;
a=histogram(M.peaktime_psth(idx),time_bins);
y1 =100*a.BinCounts/sum(a.BinCounts);
bar(time_bins_centers,y1,'FaceColor',[1 0 0],'EdgeColor',[1 0 0]);
% title(sprintf('Response time of tuned neurons'));
xlim([time_bins(1),time_bins(end)]);
% ylim([0 ceil(max(y1))]);
ylabel(sprintf('Reward-enhanced\n neurons (%%)'),'Color',[1 0 0]);

yyaxis right
idx = change_mean<0;
a=histogram(M.peaktime_psth(idx),time_bins);
y2 =100*a.BinCounts/sum(a.BinCounts);
bar(time_bins_centers,y2,'FaceColor','none','EdgeColor',[0 0 1]);
% title(sprintf('Response time of tuned neurons'));
xlabel(sprintf('Peak response time of neurons\n relative to first lickport contact (s)'));
ylabel(sprintf('Reward-suppressed\n neurons (%%)'),'Color',[0 0 1]);
set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
box off
xlim([time_bins(1),time_bins(end)]);
ylim([0 ceil(max([y1,y2]))]);





%% PSTHs all
smooth_bins=1; % one element backward, current element, and one element forward

% switch flag_reward
%     case 0 %regular versus large
%         PSTH2 = cell2mat(fetchn(rel_psth, 'psth_regular', 'ORDER BY roi_number'));
%         PSTH3 = cell2mat(fetchn(rel_psth, 'psth_large', 'ORDER BY roi_number'));
%     case 1 %regular versus small
%         PSTH2 = cell2mat(fetchn(rel_psth, 'psth_regular', 'ORDER BY roi_number'));
%         PSTH3 = cell2mat(fetchn(rel_psth, 'psth_small', 'ORDER BY roi_number'));
%         
%     case 2 %small versus large
%         PSTH2 = cell2mat(fetchn(rel_psth, 'psth_small', 'ORDER BY roi_number'));
%         PSTH3 = cell2mat(fetchn(rel_psth, 'psth_large', 'ORDER BY roi_number'));
% end


PSTH_regular = cell2mat(fetchn(rel_psth, 'psth_regular', 'ORDER BY roi_number'));
PSTH_small = cell2mat(fetchn(rel_psth, 'psth_small', 'ORDER BY roi_number'));
PSTH_large = cell2mat(fetchn(rel_psth, 'psth_large', 'ORDER BY roi_number'));


ax1=axes('position',[position_x3(1), position_y3(1), panel_width2, panel_height2*1.5]);
PSTH1 = movmean(PSTH_regular ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% PSTH=PSTH(:,time_idx);
PSTH_norm = PSTH1./nanmax(PSTH1,[],2);
[~,idx]=max(PSTH_norm,[],2);
[~,idxs]=sort(idx);
imagesc(psth_time,1:1:numel(idxs),PSTH_norm(idxs,:));
xlabel('Time (s)');
ylabel('Neurons');
title(sprintf('Normalized responses\n regular trials'));
set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
cmp=parula;
colormap(ax1, cmp)
caxis([nanmin(PSTH_norm(:)) nanmax(PSTH_norm(:))]);


ax2=axes('position',[position_x3(2), position_y3(1), panel_width2, panel_height2*1.5]);
PSTH2 = movmean(PSTH_small ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% PSTH=PSTH(:,time_idx);
PSTH2_norm = PSTH2./nanmax(PSTH1,[],2);
imagesc(psth_time,1:1:numel(idxs),PSTH2_norm(idxs,:));
xlabel('Time (s)');
ylabel('Neurons');
title(sprintf('Normalized responses\n smaller reward'));
set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
cmp=parula;
colormap(ax2, cmp)
caxis([nanmin(PSTH_norm(:)) nanmax(PSTH_norm(:))]);




ax3=axes('position',[position_x3(3), position_y3(1), panel_width2, panel_height2*1.5]);
PSTH3 = movmean(PSTH_large ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% PSTH=PSTH(:,time_idx);
PSTH3_norm = PSTH3./nanmax(PSTH1,[],2);
imagesc(psth_time,1:1:numel(idxs),PSTH3_norm(idxs,:));
xlabel('Time (s)');
ylabel('Neurons');
title(sprintf('Normalized responses\n larger reward'));
set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
cmp=parula;
colormap(ax3, cmp)
caxis([nanmin(PSTH_norm(:)) nanmax(PSTH_norm(:))]);


ax4=axes('position',[position_x3(4), position_y3(1), panel_width2, panel_height2*1.5]);
PSTH4 = PSTH2-PSTH1;
PSTH4 = PSTH4./nanmax(PSTH1,[],2);
imagesc(psth_time,1:1:numel(idxs),PSTH4(idxs,:));
xlabel('Time (s)');
ylabel('Neurons');
title(sprintf('Smaller-Regular responses'));
set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
cmp=parula;
colormap(ax4, cmp)
caxis([nanmin(PSTH4(:)) nanmax(PSTH4(:))]);

ax5=axes('position',[position_x3(5), position_y3(1), panel_width2, panel_height2*1.5]);
PSTH5 = PSTH3-PSTH1;
PSTH5 = PSTH5./nanmax(PSTH1,[],2);
imagesc(psth_time,1:1:numel(idxs),PSTH5(idxs,:));
xlabel('Time (s)');
ylabel('Neurons');
title(sprintf('Larger-Regular responses'));
set(gca,'Xtick',[time_bins(1),0,time_bins(end)],'TickLength',[0.05,0.05],'TickDir','out');
cmp=parula;
colormap(ax5, cmp)
caxis([nanmin(PSTH5(:)) nanmax(PSTH5(:))]);

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);




