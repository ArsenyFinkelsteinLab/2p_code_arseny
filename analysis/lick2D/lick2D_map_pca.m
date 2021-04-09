function lick2D_map_pca(key,  M)
close all;
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 




filename=[];
dir_current_fig = [dir_base  '\Lick2D\brain_maps\pca_coeff\'];
rel =POP.ROIPCA  & IMG.ROIGood & key;



session_date = fetch1(EXP2.Session & key,'session_date');

session_epoch_type = fetch1(EXP2.SessionEpoch & key, 'session_epoch_type');
if strcmp(session_epoch_type,'spont_only')
    session_epoch_label = 'Spontaneous';
elseif strcmp(session_epoch_type,'behav_only')
    session_epoch_label = 'Behavior';
end

filename =['anm' num2str(key.subject_id) 's' num2str(key.session) '_' session_epoch_label '_pca' num2str(key.component_id)];



dir_current_fig_original = dir_current_fig;
filename_original = filename;
filename_original = [filename_original ];

% rel = rel & 'heirar_cluster_percent>2' & (ANLI.IncludeROI4 & 'number_of_events>25');
% rel = rel & 'heirar_cluster_percent>2' & 'psth_selectivity_odd_even_corr>0.5';


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

position_y1(1)=0.05;
position_y1(end+1)=position_y1(end)-vertical_dist*1.1;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;

% pix2dist= fetch1(IMG.Parameters & 'parameter_name="fov_size_microns_z1.1"', 'parameter_value')/fetch1(IMG.FOV & key, 'fov_x_size');
pix2dist=1;

%% MAPS
% mean_img_enhanced = fetch1(IMG.Plane & key & 'plane_num=1','mean_img_enhanced');
% x_dim = [0:1:(size(mean_img_enhanced,1)-1)]*pix2dist;
% y_dim = [0:1:(size(mean_img_enhanced,2)-1)]*pix2dist;
roi_coeff=fetchn(rel ,'roi_coeff', 'ORDER BY roi_number');

range_corr = max([abs(prctile(roi_coeff,1)), abs(prctile(roi_coeff,99))]);
bins = [-inf,linspace(-range_corr,range_corr,500),inf];
num_bins =numel(bins);


% All planes
ax1=axes('position',[position_x1(1), position_y1(1), panel_width1*4, panel_height1*3]);
cmap = jet(num_bins);
% cmap = flip(redblue(nun_bins));
colormap (cmap);

% colormap(bluewhitered(502))
% bluewhitered;
% my_map=bluewhitered(length(bins));
% cmap = my_map;
% colormap (cmap);
% colormap(bluewhitered(length(bins)));
roi_coeff(isnan(roi_coeff))=0;

[~,~,bins_idx]=histcounts(roi_coeff,bins);
% imagesc(x_dim, y_dim, mean_img_enhanced);
% colormap(ax1,gray);
% hold on;
number_of_planes = unique(M.plane_num);

x = M.roi_centroid_x + M.x_pos_relative;
x=x/0.75;
y = M.roi_centroid_y + M.y_pos_relative;
y=y/0.5;

hold on;
for i_roi=1:1:size(M,1)
    plot(x(i_roi)*pix2dist, y(i_roi)*pix2dist,'.','Color',cmap(bins_idx(i_roi),:),'MarkerSize',7)
end
axis xy
set(gca,'YDir','reverse')
% title(sprintf('Motor map, left ALM\n n = %d tuned neurons (%.1f%%) \n',size(M,1), 100*size(M,1)/rel_all_good_cells.count   ));
% set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, 800], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,800],'TickLength',[0.01,0],'TickDir','out')
axis tight
axis equal
xlabel('Anterior - Posterior (\mum)');
ylabel('Lateral - Medial (\mum)');
title(sprintf('anm %d session %d \n %s  \n Total planes = %d \nPCA=%d', key.subject_id, key.session,session_epoch_label,  number_of_planes ,key.component_id));
c=colorbar;
c.Ticks=[0,0.5,1];
c.TickLabels={sprintf('%.2f', -range_corr),0,sprintf('%.2f', range_corr)};
c.Label.String = 'PC Coefficient';



if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r150']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);


end

