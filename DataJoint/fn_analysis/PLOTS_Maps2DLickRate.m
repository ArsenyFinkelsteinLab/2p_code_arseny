function PLOTS_Maps2DLickRate(key, dir_current_fig,flag_spikes)
close all;
% clf;

if flag_spikes==1
else
        rel_data=LICK2D.ROILick2DLickRate;
end

rel_all = IMG.ROI*IMG.PlaneCoordinates  & IMG.ROIGood & key;
rel_data = rel_data & IMG.ROIGood & key;

session_date = fetch1(EXP2.Session & key,'session_date');

filename = [ 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date];



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



R = fetchn(rel_data,'corr_with_licks','ORDER BY roi_number');


M=fetch(rel_all ,'*');

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




%% Map with preferred time
upper=prctile(R(:),95);
lower=prctile(R(:),5);
bounds = max([abs(lower), abs(upper)]);
                    
hist_bins1 = [-1,-upper:step:upper,1];

ax1=axes('position',[position_x1(1), position_y1(1), panel_width1*2, panel_height1*2]);
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
    %     plot(M.roi_centroid_x(i_roi)*pix2dist, M.roi_centroid_y(i_roi)*pix2dist,'o','Color',my_colormap(prefered_angle,:),'MarkerSize',10*M.rayleigh_length(i_roi))
    plot(x_all(i_roi)*pix2dist, y_all(i_roi)*pix2dist,'.','Color',my_colormap(idx_bin(i_roi),:),'MarkerSize',7)
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
title([ 'anm' num2str(key.subject_id) ' s' num2str(key.session) ' ' session_date]);
% Colorbar
ax2=axes('position',[position_x2(4)+0.15, position_y2(1)+0.08, panel_width2, panel_height2/4]);
colormap(ax2,my_colormap)
% cb1 = colorbar(ax2,'Position',[position_x2(4)+0.15, position_y2(1)+0.1, panel_width2, panel_height2/4], 'Ticks',[0, 0.5, 1],...
%     'TickLabels',[-5,0,5],'Location','NorthOutside');
cb1 = colorbar(ax2,'Position',[position_x2(4)+0.15, position_y2(1)+0.1, panel_width2, panel_height2/4], 'Ticks',[0, 0.5, 1],...
    'TickLabels',[],'Location','NorthOutside');
axis off;

%Preferred time histogram
axes('position',[position_x2(4)+0.15, position_y2(1), panel_width2, panel_height2]);
a=histogram(R,hist_bins1);
hist_bins1(1)=-upper-step;
hist_bins1(end)=upper+step;
bins_centers=hist_bins1(1:end-1)+mean(diff(hist_bins1))/2;
y =100*a.BinCounts/rel_all.count;
% y =100*a.BinCounts/sum(a.BinCounts);
% BinCounts=a.BinCounts;
% yyaxis left
bar(bins_centers,y);
% title(sprintf('Response time of tuned neurons'));
xlabel(sprintf('Correlation with\n lick rate'));
ylabel(sprintf('Neurons (%%)'));
set(gca,'Xtick',[hist_bins1(1),0,hist_bins1(end)],'TickLength',[0.05,0.05],'TickDir','out');
box off
xlim([hist_bins1(1),hist_bins1(end)]);
ylim([0 ceil(max(y))]);
title(sprintf('Threshold for event %.2f', key.threshold_for_event));


if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end


filename =[filename '_' sprintf('threshold%d',floor(100*(key.threshold_for_event)))];
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);




