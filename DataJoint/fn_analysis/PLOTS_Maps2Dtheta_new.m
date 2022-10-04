function PLOTS_Maps2Dtheta_new(key, dir_current_fig, flag_spikes)
rel_meso = IMG.Mesoscope & key;

close all;
% clf;
column_radius = 20; %in um
min_num_cells = 5;

if flag_spikes==1
    rel_data=LICK2D.ROILick2DangleStatsSpikes3bins;
    dir_current_fig=[dir_current_fig 'spikes\'];
else
    %     rel_data=LICK2D.ROILick2Dangle;
end

rel_rois= (IMG.ROI-IMG.ROIBad) &  (rel_data  & key & 'theta_tuning_odd_even_corr_regular>0.25');

session_date = fetch1(EXP2.Session & key,'session_date');
filename = [ 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date]

rel = rel_rois*rel_data*IMG.PlaneCoordinates ;
rel_all = (IMG.ROI-IMG.ROIBad)*IMG.PlaneCoordinates  & key;

lateral_distance_bins = [0:10:120,inf]; % in microns
% euclidean_distance_bins = [10:20:200];

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
% figure
fff = figure("Visible",false);
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
M_all_all=fetch(rel_all ,'*');
M_all_all=struct2table(M_all_all);
roi_number_all=M_all_all.roi_number;


if rel_meso.count>0 % if its mesoscope data
    x_all = M.roi_centroid_x + M.x_pos_relative;
    y_all = M.roi_centroid_y + M.y_pos_relative;
    
    x_all=x_all/0.75;
    y_all=y_all/0.5;
    
    x_all_all = M_all_all.roi_centroid_x + M_all_all.x_pos_relative;
    y_all_all = M_all_all.roi_centroid_y + M_all_all.y_pos_relative;
    
    x_all_all=x_all_all/0.75;
    y_all_all=y_all_all/0.5;
end


%% Distance (lateral, axial) and theta
theta_all = M.preferred_theta_regular;
z_all=M.z_pos_relative;

dXY=zeros(numel(theta_all),numel(theta_all));
dZ=zeros(numel(theta_all),numel(theta_all));
d3D=zeros(numel(theta_all),numel(theta_all));
dtheta=zeros(numel(theta_all),numel(theta_all));

parfor ii=1:1:numel(theta_all)
    
    x=x_all(ii);
    y=y_all(ii);
    z=z_all(ii);
    
    dXY(ii,:)= sqrt((x_all-x).^2 + (y_all-y).^2); % in um
    dZ(ii,:)= abs(z_all - z); % in um
    %     d3D(ii,:) = sqrt((x_all-x).^2 + (y_all-y).^2 + (z_all-z).^2); % in um
    
    theta = M.preferred_theta_regular(ii);
    dtheta_temp = circ_dist(deg2rad(theta_all),deg2rad(theta));
    dtheta(ii,:) = abs(rad2deg(dtheta_temp));
end


dXY=dXY(:);
idx_not_self = dXY>0;
dXY=dXY(idx_not_self);

dZ=dZ(idx_not_self);
d3D=d3D(idx_not_self);
dtheta=dtheta(idx_not_self);

%% Lateral distance

[N,~,bin] = histcounts(dXY(:),lateral_distance_bins);
idx_valid_bins = [N>=min_num_cells,1]>0;
lateral_distance_bins=lateral_distance_bins(idx_valid_bins);
[N,~,bin] = histcounts(dXY(:),lateral_distance_bins);

for i=1:1:numel(lateral_distance_bins)-1
    idx = (bin ==i);
    dtheta_XYdist_mean(i) = rad2deg(circ_mean(deg2rad(dtheta(idx))));
    dtheta_XYdist_var(i) = rad2deg(circ_var(deg2rad(dtheta(idx))))/sqrt(sum(idx));
end

%shuffled
idx_shuffled = randperm(numel(dtheta(:)));
dtheta_shuffled = dtheta(idx_shuffled);

for i=1:1:numel(lateral_distance_bins)-1
    idx = (bin ==i);
    dtheta_XYdist_shuffled(i) = rad2deg(circ_mean(deg2rad(dtheta_shuffled(idx))));
end

ax1=axes('position',[position_x2(3), position_y2(3), panel_width2, panel_height2]);
hold on;
plot(lateral_distance_bins(1:1:end-1),dtheta_XYdist_mean,'-r')
plot(lateral_distance_bins(1:1:end-1),dtheta_XYdist_shuffled,'-k')
ylim([0,110]);
xlabel('Lateral distance (\mum)');
ylabel('\Delta\theta (\circ)');
title(sprintf('Preferred Direction \nLateral distance'));
xlim([0,lateral_distance_bins(end-1)]);
set(gca,'YTick',[0, 45, 90]);



%% Axial Distance dependence
if max(dZ)>0
    idx_within_column = dXY<=column_radius;
    
    dtheta_column = dtheta(idx_within_column);
    %     dtheta_column_neuropil = dtheta_neuropil(idx_within_column);
    
    dZ_column = dZ(idx_within_column);
    axial_distance_bins = unique(dZ_column)';
    axial_distance_bins=[axial_distance_bins,inf];
    [N,edges,bin] = histcounts(dZ_column,axial_distance_bins);
    for i=1:1:numel(axial_distance_bins)-1
        idx = (bin ==i);
        dtheta_Zdist_mean(i) = rad2deg(circ_mean(deg2rad(dtheta_column(idx))));
        dtheta_Zdist_var(i) = rad2deg(circ_var(deg2rad(dtheta_column(idx))))/sqrt(sum(idx));
        
        %         dtheta_Zdist_mean_neuropil(i) = rad2deg(circ_mean(deg2rad(dtheta_column_neuropil(idx))));
        %         dtheta_Zdist_var_neuropil(i) = rad2deg(circ_var(deg2rad(dtheta_column_neuropil(idx))))/sqrt(sum(idx));
    end
    
    %shuffled
    idx_shuffled = randperm(numel(dtheta_column(:)));
    dtheta_column_shuffled = dtheta_shuffled(idx_within_column);
    %     dtheta_column_shuffled_neuropil = dtheta_shuffled_neuropil(idx_within_column);
    
    for i=1:1:numel(axial_distance_bins)-1
        idx = (bin ==i);
        dtheta_Zdist_mean_shuffled(i) = rad2deg(circ_mean(deg2rad(dtheta_column_shuffled(idx))));
        %         dtheta_Zdist_mean_shuffled_neuropil(i) = rad2deg(circ_mean(deg2rad(dtheta_column_shuffled_neuropil(idx))));
        
        %     dtheta_Zdist_var(i) = rad2deg(circ_var(deg2rad(dtheta_shuffled(idx))))/sqrt(sum(idx));
    end
    
    ax1=axes('position',[position_x2(4), position_y2(3), panel_width2, panel_height2]);
    hold on;
    plot(axial_distance_bins(1:1:end-1),dtheta_Zdist_mean,'.-r')
    plot(axial_distance_bins(1:1:end-1),dtheta_Zdist_mean_shuffled,'.-k')
    ylim([0,110]);
    xlabel('Axial distance (\mum)');
    ylabel('\Delta\theta (\circ)');
    title(sprintf('Preferred Direction \nAxial distance'));
    xlim([0,axial_distance_bins(end-1)]);
    set(gca,'YTick',[0, 45, 90]);
end


%%
axes('position',[position_x2(4)+0.15, position_y2(1), panel_width2, panel_height2]);
theta_bins=-179:45:181;
theta_bins_centers=theta_bins(1:end-1)+mean(diff(theta_bins))/2;
a=histogram(M.preferred_theta_regular,theta_bins);
BinCounts=a.BinCounts;
polarplot(deg2rad([theta_bins_centers,theta_bins_centers(1)]),[BinCounts, BinCounts(1)]);
title(sprintf('Preferred direction \nof tuned neurons'));
ax=gca;
ax.ThetaTick = [0 90 180 270];
ax.ThetaTickLabel = [0 90 180 -90];
ax.RTick=[max(BinCounts)];

axes('position',[position_x2(4)+0.15, position_y2(1)-0.2, panel_width2, panel_height2]);
histogram(M.preferred_theta_regular);
title(sprintf('Preferred direction \nbased on VM fit'));
xlabel('Direction deg')
ylabel('Counts');


% axes('position',[position_x2(1), position_y2(3), panel_width2, panel_height2]);
% b=histogram(M.lickmap_odd_even_corr,10);
% title(sprintf('2D MAP Tuning stability \n'));
% xlabel(sprintf('Correlation (odd,even) trials'));
% ylabel('Counts')
% box off;
% xlim([-1,1])

axes('position',[position_x2(1), position_y2(3), panel_width2, panel_height2]);
b1=histogram(M.theta_tuning_odd_even_corr_regular,10);
title(sprintf('Directional-tuning stability \n'));
xlabel(sprintf('Correlation (odd,even) trials'));
ylabel('Counts')
box off;
xlim([-1,1])

axes('position',[position_x2(2), position_y2(3), panel_width2, panel_height2]);
b1=histogram(M.rayleigh_length_regular,10);
title(sprintf('Directional tuning \n'));
xlabel(sprintf('Rayleigh vector length'));
ylabel('Counts')
box off;
xlim([0,b1.BinLimits(2)])


%% Map with preferred orientations


ax1=axes('position',[position_x1(1), position_y1(1), panel_width1*2, panel_height1*2]);
% x_dim = [0:1:(size(mean_img_enhanced,1)-1)]*pix2dist;
% y_dim = [0:1:(size(mean_img_enhanced,2)-1)]*pix2dist;
%
% imagesc(x_dim, y_dim, mean_img_enhanced);
% colormap(ax1,gray);
hold on;
my_colormap=hsv(360);

% %%up down
% my_colormap(1:1:180,:)=repmat([1 0 0],180,1);
% my_colormap(180:1:end,:)=repmat([0 0 1],181,1);

% % 4 directions
% my_colormap(1:1:90,:)=repmat([1 0 0],90,1);
% my_colormap(91:1:180,:)=repmat([0 0 1],90,1);
% my_colormap(181:1:270,:)=repmat([0 0 0],90,1);
% my_colormap(271:1:360,:)=repmat([0 1 0],90,1);

% % left right
% my_colormap(1:1:90,:)=repmat([1 0 0],90,1);
% my_colormap(91:1:180,:)=repmat([0 0 1],90,1);
% my_colormap(181:1:270,:)=repmat([1 0 0],90,1);
% my_colormap(271:1:360,:)=repmat([0 0 1],90,1);


preferred_theta =M.preferred_theta_regular;
% idx_rand = randperm(numel(x));
%     preferred_theta=preferred_theta(idx_rand);
for i_roi=1:1:size(M_all_all,1)
    %     plot(M.roi_centroid_x(i_roi)*pix2dist, M.roi_centroid_y(i_roi)*pix2dist,'o','Color',my_colormap(prefered_angle,:),'MarkerSize',10*M.rayleigh_length(i_roi))
    plot(x_all_all(i_roi)*pix2dist, y_all_all(i_roi)*pix2dist,'.','Color',[0.9 0.9 0.9],'MarkerSize',7)
    %     text(M.roi_centroid_x(i_roi)*pix2dist, M.roi_centroid_y(i_roi)*pix2dist,'\rightarrow','Rotation',prefered_angle-180,'FontSize',ceil(20*(M.preferred_radius(i_roi))),'Color',my_colormap(prefered_angle,:),'HorizontalAlignment','left','VerticalAlignment','middle');
end

for i_roi=1:1:size(M,1)
    
    prefered_angle=floor(preferred_theta(i_roi)+180);
    %     plot(M.roi_centroid_x(i_roi)*pix2dist, M.roi_centroid_y(i_roi)*pix2dist,'o','Color',my_colormap(prefered_angle,:),'MarkerSize',10*M.rayleigh_length(i_roi))
    plot(x_all(i_roi)*pix2dist, y_all(i_roi)*pix2dist,'.','Color',my_colormap(prefered_angle,:),'MarkerSize',7)
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

ax2=axes('position',[0.75, 0.6, panel_width1, panel_height1]);
colormap(ax2,my_colormap)
cb1 = colorbar(ax2,'Position',[0.72, 0.6 0.01 panel_height1], 'Ticks',[0,0.25, 0.5, 0.75, 1],...
    'TickLabels',[-180,-90,0,90,180]);
axis off;



if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r300']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);




