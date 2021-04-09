function PLOTS_Maps2DPSTHpreferred(key, dir_current_fig)
close all;
% clf;


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
    dir_current_fig = [dir_base  '\Lick2D\population\psth_preferred_distance_meso\'];
    
    
end



rel_rois=  IMG.ROIGood & (LICK2D.ROILick2DSelectivityStats  & key  & 'psth_preferred_odd_even_corr>0.75');
session_date = fetch1(EXP2.Session & key,'session_date');

filename = [ 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date];

rel = LICK2D.ROILick2DSelectivityStats*IMG.PlaneCoordinates*IMG.ROI & rel_rois;
% rel_neuropil = LICK2D.ROILick2DangleNeuropil*IMG.PlaneCoordinates & rel_rois;

rel_all = IMG.ROI*IMG.PlaneCoordinates  & IMG.ROIGood & key;




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


position_y2(1)=0.65;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2*0.9;
position_y2(end+1)=position_y2(end)-vertical_dist2*0.7;

%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

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

x_all=x_all/0.75;
y_all=y_all/0.5;

x_all_all = M_all_all.roi_centroid_x + M_all_all.x_pos_relative;
y_all_all = M_all_all.roi_centroid_y + M_all_all.y_pos_relative;


x_all_all=x_all_all/0.75;
y_all_all=y_all_all/0.5;


%% Distance (lateral, axial) and time
time_all = M.peaktime_preferred;

% time_all_neuropil =M_neuropil.peaktime_selectivity;

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
    
    time = M.peaktime_selectivity(ii);
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


%% Map with preferred orientations


ax1=axes('position',[position_x1(1), position_y1(1), panel_width1*2, panel_height1*2]);
hold on;
my_colormap=jet(11);

% for i_roi=1:1:size(M_all_all,1)
%     %     plot(M.roi_centroid_x(i_roi)*pix2dist, M.roi_centroid_y(i_roi)*pix2dist,'o','Color',my_colormap(prefered_angle,:),'MarkerSize',10*M.rayleigh_length(i_roi))
%     plot(x_all_all(i_roi)*pix2dist, y_all_all(i_roi)*pix2dist,'.','Color',[0.9 0.9 0.9],'MarkerSize',7)
%     %     text(M.roi_centroid_x(i_roi)*pix2dist, M.roi_centroid_y(i_roi)*pix2dist,'\rightarrow','Rotation',prefered_angle-180,'FontSize',ceil(20*(M.preferred_radius(i_roi))),'Color',my_colormap(prefered_angle,:),'HorizontalAlignment','left','VerticalAlignment','middle');
% end

for i_roi=1:1:size(M,1)
    
    preferred_time=ceil(time_all(i_roi)+5);
    %     plot(M.roi_centroid_x(i_roi)*pix2dist, M.roi_centroid_y(i_roi)*pix2dist,'o','Color',my_colormap(prefered_angle,:),'MarkerSize',10*M.rayleigh_length(i_roi))
    plot(x_all(i_roi)*pix2dist, y_all(i_roi)*pix2dist,'.','Color',my_colormap(preferred_time,:),'MarkerSize',7)
    %     text(M.roi_centroid_x(i_roi)*pix2dist, M.roi_centroid_y(i_roi)*pix2dist,'\rightarrow','Rotation',prefered_angle-180,'FontSize',ceil(20*(M.preferred_radius(i_roi))),'Color',my_colormap(prefered_angle,:),'HorizontalAlignment','left','VerticalAlignment','middle');
end
axis xy
set(gca,'YDir','reverse')
% title(sprintf('Motor map, left ALM\n n = %d tuned neurons (%.1f%%) \n',size(M,1), 100*size(M,1)/rel_all_good_cells.count   ));
% set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, 800], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,800],'TickLength',[0.01,0],'TickDir','out')
axis equal
axis tight
xlabel('Anterior - Posterior (\mum)');
ylabel('Lateral - Medial (\mum)');

% Colorbar
ax2=axes('position',[position_x2(4)+0.15, position_y2(1)+0.1, panel_width2, panel_height2/4]);
colormap(ax2,my_colormap)
% cb1 = colorbar(ax2,'Position',[position_x2(4)+0.15, position_y2(1)+0.1, panel_width2, panel_height2/4], 'Ticks',[0, 0.5, 1],...
%     'TickLabels',[-5,0,5],'Location','NorthOutside');
cb1 = colorbar(ax2,'Position',[position_x2(4)+0.15, position_y2(1)+0.1, panel_width2, panel_height2/4], 'Ticks',[0, 0.5, 1],...
    'TickLabels',[],'Location','NorthOutside');
axis off;

%Preferred time histogram
axes('position',[position_x2(4)+0.15, position_y2(1), panel_width2, panel_height2]);
time_bins=-3:0.5:4;
time_bins_centers=time_bins(1:end-1)+mean(diff(time_bins))/2;
a=histogram(M.peaktime_preferred,time_bins);
% BinCounts=a.BinCounts;
bar(time_bins_centers,a.BinCounts);
title(sprintf('Response time of tuned neurons'));
xlabel(sprintf('Time (s)\n relative to first lickport contact'));
ylabel('Neurons');

%% PSTHs
ax1=axes('position',[position_x2(1), position_y2(3), panel_width2, panel_height2*1.5]);
rel_psth = LICK2D.ROILick2DSelectivity & rel_rois;
psth_time =fetch1(LICK2D.ROILick2DSelectivity & key,'selectivity_time','LIMIT 1');
smooth_bins=0; % one element backward, current element, and one element forward
PSTH = cell2mat(fetchn(rel_psth, 'psth_preferred', 'ORDER BY roi_number'));
PSTH = movmean(PSTH ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
% PSTH=PSTH(:,time_idx);
PSTH = PSTH./nanmax(PSTH,[],2);
[~,idx]=max(PSTH,[],2);
[~,idxs]=sort(idx);
imagesc(psth_time,1:1:numel(idxs),PSTH(idxs,:));
xlabel('Time (s)');
ylabel('Neurons');
title('Normalized responses');

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r300']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);




