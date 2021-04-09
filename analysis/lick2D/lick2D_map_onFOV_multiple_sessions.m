function lick2D_map_onFOV_multiple_sessions()
close all;
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 


% key.subject_id =442411;
% key.subject_id = 445978;
% key.subject_id = 443627;
% key.session =1;
% key.session_epoch_number = 2;
key.number_of_bins=5;
key.fr_interval_start=0;
key.fr_interval_end=1000;

flag_all_or_signif=2;  % 1 all cells, 2 signif cells in 2D lick maps, 3 signf cells in PSTH motor responses

dir_current_fig = [dir_base  '\Lick2D\population\bins' num2str(key.number_of_bins) '\'];
if flag_all_or_signif ==2
    rel= (ANLI.ROILick2Dmap * ANLI.ROILick2Dangle * ANLI.ROILick2DangleShuffle * ANLI.ROILick2DmapShuffle * ANLI.ROILick2DPSTH)* IMG.ROI  & IMG.ROIGood & key  & 'pval_information_per_spike<=0.001';
    filename=['signif_2Dlick'];
elseif flag_all_or_signif ==3
    rel= (ANLI.ROILick2Dmap * ANLI.ROILick2Dangle * ANLI.ROILick2DangleShuffle * ANLI.ROILick2DmapShuffle * ANLI.ROILick2DPSTH)* IMG.ROI  & IMG.ROIGood & key  & 'pval_psth<=0.01';
    filename=['signif_motor'];
end

rel = rel & 'information_per_spike>=0.05';
rel_all_good_cells=  ANLI.ROILick2Dmap * IMG.ROI & IMG.ROIGood & key ;


horizontal_dist=0.25;
vertical_dist=0.25;

panel_width2=0.15;
panel_height2=0.15;

position_x2(1)=0.07;
position_x2(end+1)=position_x2(end)+horizontal_dist;
position_x2(end+1)=position_x2(end)+horizontal_dist;
position_x2(end+1)=position_x2(end)+horizontal_dist;


position_y2(1)=0.7;
position_y2(end+1)=position_y2(end)-vertical_dist;
position_y2(end+1)=position_y2(end)-vertical_dist;


%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);


M=fetch(rel ,'*');
M=struct2table(M);


axes('position',[position_x2(1), position_y2(1), panel_width2, panel_height2]);
theta_bins=-180:30:180;
theta_bins_centers=theta_bins(1:end-1)+mean(diff(theta_bins))/2;
a=histogram(M.preferred_theta,theta_bins);
BinCounts=a.BinCounts;
polarplot(deg2rad([theta_bins_centers,theta_bins_centers(1)]),[BinCounts, BinCounts(1)]);
ax=gca;
ax.ThetaTick = [0 90 180 270];
ax.ThetaTickLabel = [0 90 180 -90];
title(sprintf('Motor map, left ALM\n n = %d tuned neurons (%.1f%%) \n \n Preferred direction \nof tuned neurons',size(M,1), 100*size(M,1)/rel_all_good_cells.count));

axes('position',[position_x2(2), position_y2(1), panel_width2, panel_height2]);
b=histogram(M.preferred_radius,4);
title(sprintf('Preferred amplitude \nof tuned neurons\n'));
xlabel('Radial distance (normalized)')
ylabel('Counts')
box off;
xlim([0,b.BinEdges(end)])

axes('position',[position_x2(1), position_y2(2), panel_width2, panel_height2]);
b=histogram(M.lickmap_odd_even_corr,20);
title(sprintf('Tuning stability \n'));
xlabel(sprintf('Correlation (odd,even) trials'));
ylabel('Counts')
box off;
xlim([-1,1])

axes('position',[position_x2(2), position_y2(2), panel_width2, panel_height2]);
b=histogram(M.information_per_spike,20);
title(sprintf('Positional (2D) tuning \n'));
xlabel(sprintf('Information (bits/spike)'));
ylabel('Counts')
box off;
% xlim([-1,1])

axes('position',[position_x2(3), position_y2(2), panel_width2, panel_height2]);
b=histogram(M.rayleigh_length,20);
title(sprintf('Directional tuning \n'));
xlabel(sprintf('Rayleigh vector length'));
ylabel('Counts')
box off;


if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
filename=['population_multiple_session'];
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);




