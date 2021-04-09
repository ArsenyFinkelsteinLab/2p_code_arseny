function PLOTS_MapsRidgeVarianceExplained(key, dir_current_fig, rel_data)

close all;

rel_all = IMG.ROI*IMG.PlaneCoordinates  & IMG.ROIGood & key & rel_data;
rel_data = rel_data & IMG.ROIGood & key;
session_date = fetch1(EXP2.Session & key,'session_date');

filename = [ 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date];

horizontal_dist=0.25;
vertical_dist=0.35;

panel_width1=0.6;
panel_height1=0.6;
position_x1(1)=0.14;
position_y1(1)=0.25;


panel_width2=0.13;
panel_height2=0.15;
horizontal_dist2=0.16;
vertical_dist2=0.21;

position_x2(1)=0.83;
position_y2(1)=0.7;

%Graphics
%---------------------------------
fff = figure("Visible",false);
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 15 10]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

% mean_img_enhanced = fetch1(IMG.Plane & key & 'plane_num=1','mean_img_enhanced');
% pix2dist= fetch1(IMG.Parameters & 'parameter_name="fov_size_microns_z1.1"', 'parameter_value')/fetch1(IMG.FOV & key &'fov_num=1', 'fov_x_size');
pix2dist=1;

R = fetchn(rel_data,'variance_explained','ORDER BY roi_number');
M=fetch(rel_all ,'*');


M=struct2table(M);
roi_number=M.roi_number;

x_all = M.roi_centroid_x + M.x_pos_relative;
y_all = M.roi_centroid_y + M.y_pos_relative;

x_all=x_all/0.75;
y_all=y_all/0.5;





%% Map with regression beta
bounds=prctile(R,98);
v = linspace(0,bounds,20);
step =mean(diff(v));
hist_bins1 = [0:step:bounds,inf];

ax1=axes('position',[position_x1(1), position_y1(1), panel_width1, panel_height1]);
hold on;
my_colormap=jet(numel(hist_bins1)-1);
% my_colormap=plasma(numel(time_bins1));

% for i_roi=1:1:size(M_all_all,1)
%     %     plot(M.roi_centroid_x(i_roi)*pix2dist, M.roi_centroid_y(i_roi)*pix2dist,'o','Color',my_colormap(prefered_angle,:),'MarkerSize',10*M.rayleigh_length(i_roi))
%     plot(x_all_all(i_roi)*pix2dist, y_all_all(i_roi)*pix2dist,'.','Color',[0.9 0.9 0.9],'MarkerSize',7)
%     %     text(M.roi_centroid_x(i_roi)*pix2dist, M.roi_centroid_y(i_roi)*pix2dist,'\rightarrow','Rotation',prefered_angle-180,'FontSize',ceil(20*(M.preferred_radius(i_roi))),'Color',my_colormap(prefered_angle,:),'HorizontalAlignment','left','VerticalAlignment','middle');
% end
[~,~,idx_bin] = histcounts(R,hist_bins1);

for i_roi=1:1:size(M,1)
    plot(x_all(i_roi)*pix2dist, y_all(i_roi)*pix2dist,'.','Color',my_colormap(idx_bin(i_roi),:),'MarkerSize',7)
end
axis xy
set(gca,'YDir','reverse')
% title(sprintf('Motor map, left ALM\n n = %d tuned neurons (%.1f%%) \n',size(M,1), 100*size(M,1)/rel_all_good_cells.count   ));
% set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, 800], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,800],'TickLength',[0.01,0],'TickDir','out')
axis equal
axis tight
xlabel('Anterior - Posterior (\mum)');
ylabel('Lateral - Medial (\mum)');
title(sprintf('anm %d s%d %s\n Variance explained by Ridge Regression Model', key.subject_id, key.session, session_date));

%% Colorbar
colormap(ax1,my_colormap)
% cb1 = colorbar(ax2,'Position',[position_x2(4)+0.15, position_y2(1)+0.1, panel_width2, panel_height2/4], 'Ticks',[0, 0.5, 1],...
%     'TickLabels',[-5,0,5],'Location','NorthOutside');
cb1 = colorbar(ax1,'Position',[position_x2(1), position_y2(1)+0.2, panel_width2, panel_height2/4], 'Ticks',[0, 0.5, 1],...
    'TickLabels',[],'Location','NorthOutside');




%% Beta histogram
axes('position',[position_x2(1), position_y2(1), panel_width2, panel_height2]);
a=histogram(R,hist_bins1);
hist_bins1(end)=bounds+step;
bins_centers=hist_bins1(1:end-1)+mean(diff(hist_bins1))/2;
y =100*a.BinCounts/numel(M);
% y =100*a.BinCounts/sum(a.BinCounts);
% BinCounts=a.BinCounts;
% yyaxis left
bar(bins_centers,y);
% title(sprintf('Response time of tuned neurons'));
xlabel(sprintf('\nVariance Explained'));
ylabel(sprintf('Neurons (%%)'));
    set(gca,'Xtick',[0,hist_bins1(end)],'TickLength',[0.05,0.05],'TickDir','out');
    xlim([0,hist_bins1(end)]);
box off
ylim([0 ceil(max(y))]);
% title(sprintf('Threshold for event %.2f', key.threshold_for_flourescence_event));

% dir_current_fig = [dir_current_fig key.predictor_name '\'];
if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end

filename =[filename];

% filename =[filename '_' sprintf('threshold%d',floor(100*(key.threshold_for_event)))];
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);




