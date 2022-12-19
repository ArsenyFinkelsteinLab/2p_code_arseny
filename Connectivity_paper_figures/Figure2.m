function Figure2
close all;
filename=[sprintf('Figure2')];

rel_roi=(IMG.ROI& IMG.ROIGood-IMG.ROIBad) -IMG.Mesoscope;
% rel_stats= LICK2D.ROILick2DmapStatsSpikes3bins*LICK2D.ROILick2DPSTHStatsSpikes* LICK2D.ROILick2DPSTHSimilarityAcrossPositionsSpikes3bins & rel_roi;
rel_stats= LICK2D.ROILick2DmapStatsSpikes*LICK2D.ROILick2DPSTHStatsSpikes* LICK2D.ROILick2DPSTHSimilarityAcrossPositionsSpikes & rel_roi ...
    & 'number_of_bins=4';



% rel_stats=rel_stats & 'psth_position_concat_regular_odd_even_corr>0.25';

rel_example = IMG.ROI*LICK2D.ROILick2DPSTHSpikesExample*LICK2D.ROILick2DmapSpikesExample*LICK2D.ROILick2DmapPSTHSpikesExample*LICK2D.ROILick2DmapPSTHStabilitySpikesExample;


rel_psth = LICK2D.ROILick2DPSTHSpikes & rel_roi & rel_stats;

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Connectivity_paper_figures\plots\'];
dir_embeded_graphics=dir_current_fig;

%% Graphics
%---------------------------------
figure;
% figure("Visible",false);
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

%% behavior cartoon
panel_width1=0.15;
panel_height1=0.15;
horizontal_dist1=0.1;
vertical_dist1=0.1;
position_x1(1)=0.05;
position_x1(end+1)=position_x1(end)+horizontal_dist1;

position_y1(1)=0.745;
position_y1(end+1)=position_y1(end)-vertical_dist1;

%% fov
panel_width1_fov=0.07;
panel_height1_fov=0.07;
horizontal_dist1_fov=0.007;
vertical_dist1_fov=0.007;
position_x1_fov(1)=0.22;
position_x1_fov(end+1)=position_x1_fov(end)-horizontal_dist1_fov;
position_x1_fov(end+1)=position_x1_fov(end)-horizontal_dist1_fov;
position_x1_fov(end+1)=position_x1_fov(end)-horizontal_dist1_fov;

position_y1_fov(1)=0.79;
position_y1_fov(end+1)=position_y1_fov(end)-vertical_dist1_fov;
position_y1_fov(end+1)=position_y1_fov(end)-vertical_dist1_fov;
position_y1_fov(end+1)=position_y1_fov(end)-vertical_dist1_fov;


%% ROI traces 
panel_width1_trace=0.08;
panel_height1_trace=0.015;
horizontal_dist1_trace=0.04;
vertical_dist1_trace=0.025;
position_x1_trace(1)=0.34;
position_x1_trace(end+1)=position_x1_trace(end)+horizontal_dist1_trace;
position_x1_trace(end+1)=position_x1_trace(end)+horizontal_dist1_trace;
position_x1_trace(end+1)=position_x1_trace(end)+horizontal_dist1_trace;

position_y1_trace(1)=0.84;
position_y1_trace(end+1)=position_y1_trace(end)-vertical_dist1_trace;
position_y1_trace(end+1)=position_y1_trace(end)-vertical_dist1_trace;
position_y1_trace(end+1)=position_y1_trace(end)-vertical_dist1_trace;
position_y1_trace(end+1)=position_y1_trace(end)-vertical_dist1_trace;


% PSTH - position averaged
panel_width2=0.03;
panel_height2=0.03;
horizontal_dist2=0.04;
vertical_dist2=0.1;
position_x2(1)=0.45;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;

position_y2(1)=0.82;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;


% Histograms
panel_width3=0.05;
panel_height3=0.04;
horizontal_dist3=0.1;
vertical_dist3=0.1;
position_x3(1)=0.1;
position_x3(end+1)=position_x3(end)+horizontal_dist3*0.4;
position_x3(end+1)=position_x3(end)+horizontal_dist3;
position_x3(end+1)=position_x3(end)+horizontal_dist3;

position_y3(1)=0.5;
position_y3(end+1)=position_y3(end)-vertical_dist3;
position_y3(end+1)=position_y3(end)-vertical_dist3;
position_y3(end+1)=position_y3(end)-vertical_dist3;


% 2d tuning on grid
horizontal_dist_between_cells_grid1=0.15;
vertical_dist_between_cells_grid1=0.1;

position_x1_grid(1)=0.1;
position_x1_grid(end+1)=position_x1_grid(end)+horizontal_dist_between_cells_grid1;
position_x1_grid(end+1)=position_x1_grid(end)+horizontal_dist_between_cells_grid1;
position_x1_grid(end+1)=position_x1_grid(end)+horizontal_dist_between_cells_grid1;

position_y1_grid(1)=0.6;
position_y1_grid(end+1)=position_y1_grid(end)-vertical_dist_between_cells_grid1;
position_y1_grid(end+1)=position_y1_grid(end)-vertical_dist_between_cells_grid1;

% 2d tuning 100 cells from a given session
position_x2_grid(1)=0.37;
position_y2_grid(1)=0.65;


panel_width4=0.05;
panel_height4=0.04;
horizontal_dist4=0.1;
vertical_dist4=0.1;
position_x4(1)=0.1;
position_x4(end+1)=position_x4(end)+horizontal_dist4;
position_x4(end+1)=position_x4(end)+horizontal_dist4;
position_x4(end+1)=position_x4(end)+horizontal_dist4;
position_x4(end+1)=position_x4(end)+horizontal_dist4;
position_x4(end+1)=position_x4(end)+horizontal_dist4;
position_x4(end+1)=position_x4(end)+horizontal_dist4;

position_y4(1)=0.4;
position_y4(end+1)=position_y4(end)-vertical_dist4;
position_y4(end+1)=position_y4(end)-vertical_dist4;
position_y4(end+1)=position_y4(end)-vertical_dist4;




%% Single cell PSTH example

% Example Cell 1 PSTH
axes('position',[position_x2(1),position_y2(1), panel_width2, panel_height2])
roi_number_uid = 62450;
psth_time = fn_plot_single_cell_psth_example(rel_example,roi_number_uid , 1, 1);

% Example Cell 2 PSTH
axes('position',[position_x2(2),position_y2(1), panel_width2, panel_height2])
roi_number_uid = 70899;
fn_plot_single_cell_psth_example(rel_example,roi_number_uid, 0, 0);

% Example Cell 3 PSTH
axes('position',[position_x2(3),position_y2(1), panel_width2, panel_height2])
roi_number_uid = 73685;
fn_plot_single_cell_psth_example(rel_example,roi_number_uid, 0, 0);

% Example Cell 4 PSTH
axes('position',[position_x2(4),position_y2(1), panel_width2, panel_height2])
roi_number_uid = 74265;
fn_plot_single_cell_psth_example(rel_example,roi_number_uid, 0, 0);


%% Single cell PSTH by position examples
% Example Cell 1 PSTH
roi_number_uid = 1260652;%1304681;
fn_plot_single_cell_psth_by_position_example (rel_example,roi_number_uid , 1, 1, position_x1_grid(1), position_y1_grid(1));

roi_number_uid = 1261173; %70899;
fn_plot_single_cell_psth_by_position_example(rel_example,roi_number_uid, 0, 0, position_x1_grid(2), position_y1_grid(1));

% Example Cell 3 PSTH
roi_number_uid = 1261985;
fn_plot_single_cell_psth_by_position_example(rel_example,roi_number_uid, 0, 0, position_x1_grid(1), position_y1_grid(2));

% Example Cell 3 PSTH
roi_number_uid = 1261777;
fn_plot_single_cell_psth_by_position_example(rel_example,roi_number_uid, 0, 0, position_x1_grid(2), position_y1_grid(2));


%% fetching stats
D=fetch(rel_stats, 'psth_regular_odd_vs_even_corr', ...
    'psth_position_concat_regular_odd_even_corr',...
    'lickmap_regular_odd_vs_even_corr',...
    'information_per_spike_regular',...
    'field_size_regular',...
    'centroid_without_baseline_regular',...
    'preferred_bin_regular',...
    'psth_corr_across_position_regular');


D_tuned=fetch(rel_stats & 'information_per_spike_regular>=0.1', 'psth_regular_odd_vs_even_corr', ...
    'psth_position_concat_regular_odd_even_corr',...
    'lickmap_regular_odd_vs_even_corr',...
    'information_per_spike_regular',...
    'field_size_regular',...
    'centroid_without_baseline_regular',...
    'preferred_bin_regular',...
    'psth_corr_across_position_regular');


%% Plotting Stats


subplot(4,4,12)
bin_mat_coordinate_ver= repmat([1:1:3],3,1);
bin_mat_coordinate_hor= repmat([1:1:3]',1,3);
XXX=[D.preferred_bin_deltamap_regular_vs_large];
XXX(isnan(XXX))=[];
[preferred_bin_mat] = histcounts2(bin_mat_coordinate_ver(XXX),bin_mat_coordinate_hor(XXX),[1:1:3+1],[1:1:3+1]);
imagesc([-1,0,1],[-1,0,1],preferred_bin_mat);
title(sprintf('Preferred position\ndelta regular vs large'));
caxis([0,nanmax(preferred_bin_mat(:))])
set(gca,'YDir','normal');


subplot(4,4,13)
bin_mat_coordinate_ver= repmat([1:1:3],3,1);
bin_mat_coordinate_hor= repmat([1:1:3]',1,3);
XXX=[D.preferred_bin_deltamap_regular_vs_small];
XXX(isnan(XXX))=[];
[preferred_bin_mat] = histcounts2(bin_mat_coordinate_ver(XXX),bin_mat_coordinate_hor(XXX),[1:1:3+1],[1:1:3+1]);
imagesc([-1,0,1],[-1,0,1],preferred_bin_mat);
title(sprintf('Preferred position\ndelta regular vs small'));
caxis([0,nanmax(preferred_bin_mat(:))])
set(gca,'YDir','normal');


subplot(4,4,14)
histogram([D.corr_deltamap_regular_vs_large_odd_even]);
xlabel(sprintf('Stability delta regular vs large\ncorr (odd ,even) corr'))
ylabel('Counts');
xlim([-1,1]);

subplot(4,4,15)
histogram([D.corr_deltamap_regular_vs_small_odd_even]);
xlabel(sprintf('Stability delta regular vs small\ncorr (odd ,even) corr'))
ylabel('Counts');
xlim([-1,1]);








%% PSTH of all cells
ax5=axes('position',[position_x2(1),position_y2(2), panel_width3, panel_height3]);
PSTH_all = cell2mat(fetchn(rel_psth,'psth_regular'));
PSTH_all = PSTH_all./max(PSTH_all,[],2);
[~,idx_max_time] = max(PSTH_all,[],2);
[~, idx_neurons_sorted] = sort(idx_max_time);
imagesc(psth_time,[],PSTH_all(idx_neurons_sorted,:))
colormap(ax5,inferno)
xl = [floor(psth_time(1)) ceil(psth_time(end))];
xlabel('Time to lick (s)', 'FontSize',6);
text(-2.5,numel(idx_neurons_sorted),sprintf('Neurons'),'Rotation',90, 'FontSize',6);
set(gca,'XTick',[0,xl(end)],'Ytick',[],'TickLength',[0.05,0], 'FontSize',6);
% set(gca,'XTick',[0,xl(end)],'Ytick',[1, 100000],'YtickLabel',[{'1', '100,000'}],'TickLength',[0.05,0], 'FontSize',6);

%colorbar
ax8=axes('position',[position_x2(2),position_y2(2), panel_width3, panel_height3]);
colormap(ax8,inferno)
cb1 = colorbar();
axis off
set(cb1,'Ticks',[0, 1], 'FontSize',6);
text(5,0.5,sprintf('Acitivity \n(norm.)'),'Rotation',90, 'FontSize',6,'HorizontalAlignment','Center');
set(gca, 'FontSize',6);

%% Preferred time all PSTHs
axes('position',[position_x2(1),position_y2(2)+0.04, panel_width3, panel_height3*0.5])
h=histogram(psth_time(idx_max_time),10,'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
yl = [0, max(h.Values)];
xl = [floor(psth_time(1)) ceil(psth_time(end))];
text(xl(1)-diff(xl)*0.25,yl(1)+diff(yl)*0,sprintf('Counts'),'Rotation',90, 'FontSize',6,'VerticalAlignment','bottom');
xlim(xl);
ylim(yl)
set(gca,'XTick',[],'Ytick',[0, 25000],'YtickLabel',[{'0', '25,000'}],'TickLength',[0.05,0], 'FontSize',6);
box off;
% title(sprintf('Response-time tuning'), 'FontSize',6);

%% Stability all PSTHs
axes('position',[position_x2(4),position_y2(2), panel_width4, panel_height4])
h=histogram([D.psth_regular_odd_vs_even_corr],10,'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
yl = [0, max(h.Values)];
xl = [-1,1];
xlabel(sprintf('Tuning stability, \\itr\\it'))
text(xl(1)-diff(xl)*0.25,yl(1)+diff(yl)*0,sprintf('Counts'),'Rotation',90, 'FontSize',6,'VerticalAlignment','bottom');
title(sprintf('Response-time\n tuning'), 'FontSize',6);
xlim(xl);
ylim(yl)
set(gca,'XTick',[-1, 0, 1],'Ytick',[0, 50000],'YtickLabel',[{'0', '50,000'}],'TickLength',[0.05,0], 'FontSize',6);
box off


axes('position',[position_x4(1),position_y4(1), panel_width4, panel_height4])
h=histogram([D.psth_position_concat_regular_odd_even_corr],10,'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
% xlabel(sprintf('Stability across position and response time\n r (odd trials,even trials)'))
yl = [0, max(h.Values)];
xl = [-1,1];
xlabel(sprintf('Tuning stability, \\itr\\it'))
text(xl(1)-diff(xl)*0.25,yl(1)+diff(yl)*0,sprintf('Counts'),'Rotation',90, 'FontSize',6,'VerticalAlignment','bottom');
title(sprintf('Response-time and\n Positional tuning'), 'FontSize',6);
xlim(xl);
ylim(yl)
set(gca,'XTick',[-1, 0, 1],'Ytick',[0, 30000],'YtickLabel',[{'0', '30,000'}],'TickLength',[0.05,0], 'FontSize',6);
box off

axes('position',[position_x4(2),position_y4(1), panel_width4, panel_height4])
h=histogram([D.lickmap_regular_odd_vs_even_corr],10,'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
% xlabel(sprintf('Stability across position and response time\n r (odd trials,even trials)'))
yl = [0, max(h.Values)];
xl = [-1,1];
xlabel(sprintf('Tuning stability, \\itr\\it'))
text(xl(1)-diff(xl)*0.25,yl(1)+diff(yl)*0,sprintf('Counts'),'Rotation',90, 'FontSize',6,'VerticalAlignment','bottom');
title(sprintf('Positional tuning'), 'FontSize',6);
xlim(xl);
ylim(yl)
set(gca,'XTick',[-1, 0, 1],'Ytick',[0, 25000],'YtickLabel',[{'0', '25,000'}],'TickLength',[0.05,0], 'FontSize',6);
box off

axes('position',[position_x4(3),position_y4(1), panel_width4, panel_height4])
h=histogram([D.information_per_spike_regular],[linspace(0,0.2,10),inf],'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
yl = [0, max(h.Values)];
xl = [0,0.22];
xlabel(sprintf('Spatial information \n(bits/spike)'));
text(xl(1)-diff(xl)*0.25,yl(1)+diff(yl)*0,sprintf('Counts'),'Rotation',90, 'FontSize',6,'VerticalAlignment','bottom');
title(sprintf('Positional tuning'), 'FontSize',6);
xlim(xl);
ylim(yl)
set(gca,'XTick',[0, 0.2],'Ytick',[0, 75000],'YtickLabel',[{'0', '75,000'}],'TickLength',[0.05,0], 'FontSize',6);
box off

axes('position',[position_x4(4),position_y4(1), panel_width4, panel_height4])
h=histogram([D.field_size_regular],10,'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
yl = [0, max(h.Values)];
xl = [0,110];
xlabel(sprintf('Field size (%%)'))
title(sprintf('Positional tuning'), 'FontSize',6);
text(xl(1)-diff(xl)*0.25,yl(1)+diff(yl)*0,sprintf('Counts'),'Rotation',90, 'FontSize',6,'VerticalAlignment','bottom');
xlim(xl);
ylim(yl)
set(gca,'XTick',[0,100],'Ytick',[0, 90000],'YtickLabel',[{'1', '90,000'}],'TickLength',[0.05,0], 'FontSize',6);
box off

axes('position',[position_x4(5),position_y4(1), panel_width4, panel_height4])
h=histogram([D.psth_corr_across_position_regular],10,'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
yl = [0, max(h.Values)];
xl = [-1,1];
xlabel(sprintf('Tuning similarity,\nacross positions, \\itr\\it'))
text(xl(1)-diff(xl)*0.25,yl(1)+diff(yl)*0,sprintf('Counts'),'Rotation',90, 'FontSize',6,'VerticalAlignment','bottom');
title(sprintf('Response-time tuning'), 'FontSize',6);
xlim(xl);
ylim(yl)
set(gca,'XTick',[-1, 0, 1],'Ytick',[0, 25000],'YtickLabel',[{'0', '25,000'}],'TickLength',[0.05,0], 'FontSize',6);
box off

% axes('position',[position_x4(7),position_y4(1), panel_width4, panel_height4])
% centroid_without_baseline_regular=cell2mat({D_tuned.centroid_without_baseline_regular}');
% % [centroids_mat] = histcounts2(centroid_without_baseline_regular(:,1),centroid_without_baseline_regular(:,2),linspace(1,3,10),linspace(1,3,10));
% [centroids_mat] = histcounts2(centroid_without_baseline_regular(:,2),centroid_without_baseline_regular(:,1),linspace(1,4,9),linspace(1,4,9));
% imagesc(centroids_mat);
% title('Centroids without baseline');
% axis equal
%         axis tight
%         set(gca,'YDir','normal', 'FontSize',6);
% axis off

ax10=axes('position',[position_x4(6),position_y4(1), panel_width4, panel_height4]);
bin_mat_coordinate_hor= repmat([1:1:4],4,1);
bin_mat_coordinate_ver= repmat([1:1:4]',1,4);
[preferred_bin_mat] = histcounts2(bin_mat_coordinate_ver([D_tuned.preferred_bin_regular]),bin_mat_coordinate_hor([D_tuned.preferred_bin_regular]),[1:1:4+1],[1:1:4+1]);
preferred_bin_mat=100*preferred_bin_mat./max(preferred_bin_mat(:));
imagesc([-1,0,1],[-1,0,1],preferred_bin_mat);
% imagesc(1:3,1:3,flipud(preferred_bin_mat));
colormap(ax10,viridis);
title(sprintf('Preferred position\nall tuned cells'));
caxis([0,nanmax(preferred_bin_mat(:))])
axis equal
axis tight
set(gca,'YDir','normal', 'FontSize',6);
axis off


%colorbar
ax11=axes('position',[position_x4(6)+0.04,position_y4(1), panel_width4, panel_height4]);
colormap(ax11,viridis)
cb2 = colorbar;
axis off
set(cb2,'Ticks',[0, 1],'TickLabels',[{'0','100'}], 'FontSize',6);
text(5,0.5,sprintf('Percentage \ncells(%%)'),'Rotation',90, 'FontSize',6,'HorizontalAlignment','Center');
set(gca, 'FontSize',6);

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r500']);
eval(['print ', figure_name_out, ' -dpdf -r200']);




