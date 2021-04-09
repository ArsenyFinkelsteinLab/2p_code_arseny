function [key]=Lick2D_DistanceAngle(key,  flag_spikes, goodness_of_fit_vmises_threshold, column_radius)


% column_radius = 20; %in um
min_num_cells = 5;

if flag_spikes==1
    rel_data=LICK2D.ROILick2DangleSpikes;
else
    rel_data=LICK2D.ROILick2Dangle;
end

%     rel_rois=  IMG.ROIGood & (rel_data  & key  & 'theta_tuning_odd_even_corr>0.5' & 'goodness_of_fit_vmises>0.5' & 'rayleigh_length>0.1');
rel_rois=  IMG.ROIGood & (rel_data  & key & sprintf('goodness_of_fit_vmises>%.2f',goodness_of_fit_vmises_threshold));


rel = rel_data*IMG.PlaneCoordinates*IMG.ROI & rel_rois;

% lateral_distance_bins = [0:20:200,inf]; % in microns
lateral_distance_bins = [0:20:200,inf]; % in microns

% mean_img_enhanced = fetch1(IMG.Plane & key & 'plane_num=1','mean_img_enhanced');
% pix2dist= fetch1(IMG.Parameters & 'parameter_name="fov_size_microns_z1.1"', 'parameter_value')/fetch1(IMG.FOV & key &'fov_num=1', 'fov_x_size');
pix2dist=1;


M=fetch(rel ,'*');
M=struct2table(M);

x_all = M.roi_centroid_x + M.x_pos_relative;
y_all = M.roi_centroid_y + M.y_pos_relative;

x_all=x_all/0.75;
y_all=y_all/0.5;


%% Distance (lateral, axial) and theta
theta_all = M.preferred_theta_vmises;
z_all=M.z_pos_relative;

dXY=zeros(numel(theta_all),numel(theta_all));
dZ=zeros(numel(theta_all),numel(theta_all));
% d3D=zeros(numel(theta_all),numel(theta_all));
dtheta=zeros(numel(theta_all),numel(theta_all));

parfor ii=1:1:numel(theta_all)
    
    x=x_all(ii);
    y=y_all(ii);
    z=z_all(ii);
    
    dXY(ii,:)= sqrt((x_all-x).^2 + (y_all-y).^2); % in um
    dZ(ii,:)= abs(z_all - z); % in um
%     d3D(ii,:) = sqrt((x_all-x).^2 + (y_all-y).^2 + (z_all-z).^2); % in um
       
    theta = M.preferred_theta_vmises(ii);
    dtheta_temp = circ_dist(deg2rad(theta_all),deg2rad(theta));
    dtheta(ii,:) = abs(rad2deg(dtheta_temp));
    
end


dXY=dXY(:);
idx_not_self = dXY>0;
dXY=dXY(idx_not_self);

dZ=dZ(idx_not_self);
% d3D=d3D(idx_not_self);
dtheta=dtheta(idx_not_self);

%% Lateral distance

[N,~,bin] = histcounts(dXY(:),lateral_distance_bins);
% idx_valid_bins = [N>=min_num_cells,1]>0;
% lateral_distance_bins=lateral_distance_bins(idx_valid_bins);
% [N,~,bin] = histcounts(dXY(:),lateral_distance_bins);

for i=1:1:numel(lateral_distance_bins)-1
    idx = (bin ==i);
    if N(i)>=min_num_cells
    dtheta_XYdist_mean(i) = rad2deg(circ_mean(deg2rad(dtheta(idx))));
%     dtheta_XYdist_var(i) = rad2deg(circ_var(deg2rad(dtheta(idx))))/sqrt(sum(idx));
    else
        dtheta_XYdist_mean(i)=NaN;
    end
end

%shuffled
idx_shuffled = randperm(numel(dtheta(:)));
dtheta_shuffled = dtheta(idx_shuffled);

for i=1:1:numel(lateral_distance_bins)-1
    idx = (bin ==i);
    if N(i)>=min_num_cells
    dtheta_XYdist_mean_shuffled(i) = rad2deg(circ_mean(deg2rad(dtheta_shuffled(idx))));
    else
        dtheta_XYdist_mean_shuffled(i)=NaN;
    end
end

% ax1=axes('position',[position_x2(3), position_y2(3), panel_width2, panel_height2]);
% hold on;
% plot(lateral_distance_bins(1:1:end-1),dtheta_XYdist_mean,'-r')
% plot(lateral_distance_bins(1:1:end-1),dtheta_XYdist_mean_shuffled,'-k')
% ylim([0,110]);
% xlabel('Lateral distance (\mum)');
% ylabel('\Delta\theta (\circ)');
% title(sprintf('Preferred Direction \nLateral distance'));
% xlim([0,lateral_distance_bins(end-1)]);
% set(gca,'YTick',[0, 45, 90]);

%% Axial Distance dependence

axial_distance_bins=[];
dtheta_Zdist_mean=[];
dtheta_Zdist_mean_shuffled=[];

if max(dZ)>0
    idx_within_column = dXY<=column_radius;
    
    dtheta_column = dtheta(idx_within_column);
    
    dZ_column = dZ(idx_within_column);
    axial_distance_bins = unique(dZ_column)';
    axial_distance_bins=[axial_distance_bins,inf];
    [N,edges,bin] = histcounts(dZ_column,axial_distance_bins);
    for i=1:1:numel(axial_distance_bins)-1
        idx = (bin ==i);
        dtheta_Zdist_mean(i) = rad2deg(circ_mean(deg2rad(dtheta_column(idx))));
        dtheta_Zdist_var(i) = rad2deg(circ_var(deg2rad(dtheta_column(idx))))/sqrt(sum(idx));
    end
    
    %shuffled
    idx_shuffled = randperm(numel(dtheta_column(:)));
    dtheta_column_shuffled = dtheta_shuffled(idx_within_column);
    
    for i=1:1:numel(axial_distance_bins)-1
        idx = (bin ==i);
        dtheta_Zdist_mean_shuffled(i) = rad2deg(circ_mean(deg2rad(dtheta_column_shuffled(idx))));
    end
    
%     ax1=axes('position',[position_x2(4), position_y2(3), panel_width2, panel_height2]);
%     hold on;
%     plot(axial_distance_bins(1:1:end-1),dtheta_Zdist_mean,'.-r')
%     plot(axial_distance_bins(1:1:end-1),dtheta_Zdist_mean_shuffled,'.-k')
%     ylim([0,110]);
%     xlabel('Axial distance (\mum)');
%     ylabel('\Delta\theta (\circ)');
%     title(sprintf('Preferred Direction \nAxial distance'));
%     xlim([0,axial_distance_bins(end-1)]);
%     set(gca,'YTick',[0, 45, 90]);
    
end



%%
% axes('position',[position_x2(4)+0.15, position_y2(1), panel_width2, panel_height2]);
% theta_bins=-180:40:180;
% theta_bins_centers=theta_bins(1:end-1)+mean(diff(theta_bins))/2;
% a=histogram(M.preferred_theta_vmises,theta_bins);
% BinCounts=a.BinCounts;
% polarplot(deg2rad([theta_bins_centers,theta_bins_centers(1)]),[BinCounts, BinCounts(1)]);
% title(sprintf('Preferred direction \nof tuned neurons'));
% ax=gca;
% ax.ThetaTick = [0 90 180 270];
% ax.ThetaTickLabel = [0 90 180 -90];
% ax.RTick=[max(BinCounts)];
% 
% axes('position',[position_x2(4)+0.15, position_y2(1)-0.2, panel_width2, panel_height2]);
% histogram(M.preferred_theta_vmises);
% title(sprintf('Preferred direction \nbased on VM fit'));
% xlabel('Direction deg')
% ylabel('Counts');

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
% b1=histogram(M.theta_tuning_odd_even_corr,10);
% title(sprintf('Directional-tuning stability \n'));
% xlabel(sprintf('Correlation (odd,even) trials'));
% ylabel('Counts')
% box off;
% xlim([-1,1])
% 
% 
% axes('position',[position_x2(2), position_y2(3), panel_width2, panel_height2]);
% b1=histogram(M.rayleigh_length,10);
% title(sprintf('Directional tuning \n'));
% xlabel(sprintf('Rayleigh vector length'));
% ylabel('Counts')
% box off;
% xlim([0,b1.BinLimits(2)])



key.theta_lateral_distance = dtheta_XYdist_mean;
key.theta_lateral_distance_shuffled = dtheta_XYdist_mean_shuffled;
key.bins_lateral_distance = lateral_distance_bins;

key.theta_axial_distance = dtheta_Zdist_mean;
key.theta_axial_distance_shuffled = dtheta_Zdist_mean_shuffled;
key.bins_axial_distance = axial_distance_bins;


key.vn_mises_correlation_treshold = goodness_of_fit_vmises_threshold;
key.column_radius = column_radius;

