function lick2D_local_corr_map_spont_vs_behav(key, radius_size, dir_current_fig)
close all;
prctile_threshold = 99; %90

if nargin<3
  % key.subject_id = 463189;
% key.session = 6;
% key.session_epoch_number = 1;
key.radius_size = 100;
else
    key.radius_size = radius_size;
    dir_current_fig = [dir_current_fig '\radius\'];
end


rel_spont = IMG.ROI* POP.ROICorrLocal*IMG.PlaneCoordinates & key & 'session_epoch_type="spont_only"';
rel_behav = IMG.ROI* POP.ROICorrLocal*IMG.PlaneCoordinates & key & 'session_epoch_type="behav_only"';

if rel_spont.count ==0 || rel_behav.count==0
    return
end
session_date = fetch1(EXP2.Session & key,'session_date');

filename = [ 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date]

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



horizontal_dist2=0.07;
vertical_dist2=0.12;

panel_width2=0.05;
panel_height2=0.08;



% pix2dist= fetch1(IMG.Parameters & 'parameter_name="fov_size_microns_z1.1"', 'parameter_value')/fetch1(IMG.FOV & key, 'fov_x_size');
pix2dist=1;

%% MAPS
% mean_img_enhanced = fetch1(IMG.Plane & key & 'plane_num=1','mean_img_enhanced');
% x_dim = [0:1:(size(mean_img_enhanced,1)-1)]*pix2dist;
% y_dim = [0:1:(size(mean_img_enhanced,2)-1)]*pix2dist;
M=fetch(rel_spont ,'*');
M=struct2table(M);
number_of_planes = unique(M.plane_num);
corr_local_spont=M.corr_local;


Mbehav=fetch(rel_behav ,'*');
Mbehav=struct2table(Mbehav);
corr_local_behav=Mbehav.corr_local;


corr_local=corr_local_spont - corr_local_behav;
range_corr = max([abs(prctile(corr_local,1)), abs(prctile(corr_local,prctile_threshold))]);
bins = [-inf,linspace(-range_corr,range_corr,500),inf];
nun_bins =numel(bins);


% All planes
ax1=axes('position',[position_x1(1), position_y1(1), panel_width1*4, panel_height1*3]);
% colormap jet(502)
% redblue
cmap = flip(redblue(nun_bins));
colormap (cmap);

% colormap(bluewhitered(502))
% bluewhitered;
% my_map=bluewhitered(length(bins));
% cmap = my_map;
% colormap (cmap);
% colormap(bluewhitered(length(bins)));
corr_local(isnan(corr_local))=0;

[~,~,bins_idx]=histcounts(corr_local,bins);
% imagesc(x_dim, y_dim, mean_img_enhanced);
% colormap(ax1,gray);
% hold on;

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
title(sprintf('anm %d session %d \n Spontaneous-Behavior,  Corr radius=%d \n Total planes = %d ', key.subject_id, key.session ,key.radius_size,  number_of_planes));

c=colorbar;
c.Ticks=[0,0.5,1];
c.TickLabels={sprintf('%.2f', -range_corr),0,sprintf('%.2f', range_corr)};
c.Label.String = 'Local Corr, Spontaneous - Behavior';

filename = [filename '_radius' num2str(key.radius_size)];



if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r150']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);
