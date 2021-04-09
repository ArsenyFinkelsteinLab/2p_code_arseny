function lick2D_map_distance_dependence()
close all;
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 

%
key.subject_id = 463195;
key.session =3;

% key.subject_id = 462455;
% key.session =2;

% key.subject_id = 462458;
% key.session =5;


key.number_of_bins=4;
key.fr_interval_start=-1000;
key.fr_interval_end=2000;
% key.fr_interval_start=-1000;
% key.fr_interval_end=0;
% session_date = fetch1(EXP2.Session & key,'session_date');

smooth_bins=1; % one element backward, current element, and one element forward

flag_plot_rois =1; % 1 to plot ROIs on top of the image plane, 0 not to plot

flag_all_or_signif=2;  % 1 all cells, 2 signif cells in 2D lick maps, 3 signf cells in PSTH motor responses
filename=[];
dir_current_fig = [dir_base  '\Lick2D\population\onFOV_theta_distance\bins' num2str(key.number_of_bins) '\'];
if flag_all_or_signif ==1
    rel= (ANLI.ROILick2Dmap * ANLI.ROILick2DPSTH * ANLI.ROIHierarCluster * ANLI.ROILick2Dangle)* IMG.ROI  & IMG.ROIGood & key ;
elseif flag_all_or_signif ==2
    rel= (ANLI.ROILick2Dmap * ANLI.ROILick2DPSTH * ANLI.ROIHierarCluster * ANLI.ROILick2Dangle)* IMG.ROI  & IMG.ROIGood & key  & 'rayleigh_length>0.0' & 'theta_tuning_odd_even_corr>0.5';
    filename=['signif_2Dlick'];
end

session_date = fetch1(EXP2.Session & key,'session_date');

filename = [filename 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date]

if flag_plot_rois==0
    filename=[filename '_norois'];
end
% rel = rel & 'heirar_cluster_percent>2' & (ANLI.IncludeROI4 & 'number_of_events>25');
rel = rel & 'heirar_cluster_percent>2' ;


distance_bins = [5:10:205,inf]; % in microns


%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

horizontal_dist=0.25;
vertical_dist=0.25;

panel_width1=0.2;
panel_height1=0.2;

position_x1(1)=0.1;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;

position_y1(1)=0.7;
position_y1(end+1)=position_y1(end)-vertical_dist*1.1;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;



horizontal_dist2=0.12;
vertical_dist2=0.12;

panel_width2=0.08;
panel_height2=0.08;



position_x2(1)=0.35;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(1);
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;

position_y2(1)=0.8;
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1)-vertical_dist2;
position_y2(end+1)=position_y2(1)-vertical_dist2;
position_y2(end+1)=position_y2(1)-vertical_dist2;
position_y2(end+1)=position_y2(1)-vertical_dist2;


pix2dist= fetch1(IMG.Parameters & 'parameter_name="fov_size_microns_z1.1"', 'parameter_value')/fetch1(IMG.FOV & key, 'fov_x_size');


%% MAPS
mean_img_enhanced = fetch1(IMG.Plane & key & 'plane_num=1','mean_img_enhanced');
x_dim = [0:1:(size(mean_img_enhanced,1)-1)]*pix2dist;
y_dim = [0:1:(size(mean_img_enhanced,2)-1)]*pix2dist;


% All planes
ax1=axes('position',[position_x1(1), position_y1(1), panel_width1, panel_height1]);



imagesc(x_dim, y_dim, mean_img_enhanced);
colormap(ax1,gray);
hold on;

M=fetch(rel ,'*');
M=struct2table(M);

roi_cluster_id = M.heirar_cluster_id;
heirar_cluster_percent = M.heirar_cluster_percent;
[unique_cluster_id,ia,ic]  = unique(roi_cluster_id);
heirar_cluster_percent = heirar_cluster_percent(ia);
[B,I]  = sort(heirar_cluster_percent,'descend')
heirar_cluster_percent = heirar_cluster_percent(I);
unique_cluster_id = unique_cluster_id(I);
for ic=1:1:numel(roi_cluster_id)
    roi_cluster_renumbered(ic) = find(unique_cluster_id ==roi_cluster_id(ic));
end
my_colormap=hsv(numel(unique_cluster_id));

for i_roi=1:1:size(M,1)
    plot(M.roi_centroid_x(i_roi)*pix2dist, M.roi_centroid_y(i_roi)*pix2dist,'.','Color',my_colormap(roi_cluster_renumbered(i_roi),:),'MarkerSize',10)
end
axis xy
set(gca,'YDir','reverse')
% title(sprintf('Motor map, left ALM\n n = %d tuned neurons (%.1f%%) \n',size(M,1), 100*size(M,1)/rel_all_good_cells.count   ));
set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, 800], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,800],'TickLength',[0.01,0],'TickDir','out')
axis equal
axis tight
xlabel('Anterior - Posterior (\mum)');
ylabel('Lateral - Medial (\mum)');
title(sprintf('anm%d session %d\nAll planes', key.subject_id,key.session));




        theta_all = M.preferred_theta;
x_all=M.roi_centroid_x*pix2dist;
y_all=M.roi_centroid_y*pix2dist;

for ii=1:1:numel(roi_cluster_id)
    
    x=M.roi_centroid_x(ii)*pix2dist;
    y=M.roi_centroid_y(ii)*pix2dist;
    d(ii,:)= sqrt((x_all-x).^2 + (y_all-y).^2);
    
    theta = M.preferred_theta(ii);
    dtheta_temp = circ_dist(deg2rad(theta_all),deg2rad(theta));
%     dtheta_temp = dtheta_temp - 2*180*floor( (dtheta_temp+180)/(2*180) );
    
    dtheta(ii,:) = abs(rad2deg(dtheta_temp));
    
    
end
d=d(:);
dtheta=dtheta(:);

[N,edges,bin] = histcounts(d(:),distance_bins);

for i=1:1:numel(distance_bins)-1
idx = (bin ==i);
    dtheta_dist(i) = rad2deg(circ_mean(deg2rad(dtheta(idx))));
    
end

ax1=axes('position',[position_x1(2), position_y1(1), panel_width1, panel_height1]);
plot(distance_bins(1:1:end-1),dtheta_dist)
ylim([0,90]);
xlabel('Distance (\mum)');
ylabel('\Delta\theta (\circ)');


% figure
% plot(d(:),dtheta(:),'.')

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r300']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);




