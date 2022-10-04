function Supplementary_Figure_2__Cell_Stats
close all;

rel_roi=(IMG.ROI-IMG.ROIBad) &IMG.Mesoscope;
rel= LICK2D.ROILick2DmapStatsSpikes3bins*LICK2D.ROILick2DangleStatsSpikes3bins*LICK2D.ROILick2DPSTHStatsSpikes* LICK2D.ROILick2DPSTHSimilarityAcrossPositionsSpikes*LICK2D.ROILick2DmapRewardStatsSpikes3bins & rel_roi;

% rel=rel & 'psth_position_concat_regular_odd_even_corr>0.5' & 'reward_peak_pval_regular_small<=0.001' & 'modulation_percent_regular_vs_small>0';
% rel=rel & 'psth_position_concat_regular_odd_even_corr>0.25' & 'reward_peak_pval_regular_large<=0.01' & 'modulation_percent_regular_vs_large>0';
% rel=rel & 'psth_position_concat_regular_odd_even_corr>0.5' & 'reward_mean_pval_regular_large<=0.001' & 'modulation_percent_regular_vs_large>50' & 'percent_2d_map_coverage_large_odd>0.75' & 'percent_2d_map_coverage_large_even>0.75';
% rel=rel & 'psth_position_concat_regular_odd_even_corr>0.25';
rel=rel & 'information_per_spike_regular>0.05';


D=fetch(rel,'lickmap_regular_odd_vs_even_corr','psth_position_concat_regular_odd_even_corr',...
    'theta_tuning_odd_even_corr_regular','information_per_spike_regular',...
    'rayleigh_length_regular','field_size_regular','centroid_without_baseline_regular',...
    'preferred_bin_regular', 'psth_regular_odd_vs_even_corr',...
    'preferred_theta_regular_odd','preferred_theta_regular_even','psth_corr_across_position_regular',...
    'preferred_theta_regular_odd','preferred_theta_regular_even','psth_corr_across_position_regular',...
    'corr_deltamap_regular_vs_large_odd_even','corr_deltamap_regular_vs_small_odd_even',...
    'centroid_without_baseline_deltamap_regular_vs_large','centroid_without_baseline_deltamap_regular_vs_small',...
    'preferred_bin_deltamap_regular_vs_large','preferred_bin_deltamap_regular_vs_small');

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Connectivity_paper_figures\plots\'];

filename=[sprintf('Supplementary_Figure_2__Cell_Stats')];


%directionl tuning criteria



%Graphics
%---------------------------------
fig=gcf;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);
left_color=[0 0 0];
right_color=[0 0 0];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

horizontal_dist=0.25;
vertical_dist=0.35;

panel_width1=0.3;
panel_height1=0.3;
position_y1(1)=0.38;
position_x1(1)=0.07;
position_x1(end+1)=position_x1(end)+horizontal_dist*1.5;


panel_width2=0.09;
panel_height2=0.08;
horizontal_dist2=0.25;
vertical_dist2=0.25;

position_x2(1)=0.1;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2*0.8;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;

position_x3(1)=0.05;
position_x3(end+1)=position_x3(end)+horizontal_dist2;
position_x3(end+1)=position_x3(end)+horizontal_dist2;
position_x3(end+1)=position_x3(end)+horizontal_dist2;
position_x3(end+1)=position_x3(end)+horizontal_dist2;


position_y2(1)=0.8;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;

position_y3(1)=0.2;
position_y3(end+1)=position_y3(end)-vertical_dist2;
position_y3(end+1)=position_y3(end)-vertical_dist2;
position_y3(end+1)=position_y3(end)-vertical_dist2;
%---------------------------------




subplot(4,4,1)
h=histogram([D.psth_regular_odd_vs_even_corr],50);
xlabel(sprintf('PSTH stability r \n(odd trials,even trials)'))
ylabel('Counts');
xlim([-1,1]);

subplot(4,4,2)
h=histogram([D.psth_position_concat_regular_odd_even_corr],50);
xlabel(sprintf('PSTH contact. stability r \n(odd trials,even trials)'))
ylabel('Counts');
xlim([-1,1]);

subplot(4,4,3)
h=histogram([D.theta_tuning_odd_even_corr_regular],50);
xlabel(sprintf('Angular tuning stability r \n(odd trials,even trials)'))
ylabel('Counts');
xlim([-1,1]);

subplot(4,4,4)
histogram([D.lickmap_regular_odd_vs_even_corr],50);
xlabel(sprintf('2D map stability r \n(odd trials,even trials)'))
ylabel('Counts');
title(sprintf('n = %d cells',size(D,1)))
xlim([-1,1]);

subplot(4,4,5)
h=histogram([D.information_per_spike_regular],[linspace(0,0.2,20),inf]);
xlabel('Spatial information (bits/spike)');
ylabel('Counts');
xlim([0,0.21])

subplot(4,4,6)
histogram([D.rayleigh_length_regular],50);
xlabel(sprintf('Directiona tuning\nRayleigh vector lengh'))
ylabel('Counts');

subplot(4,4,7)
histogram([D.field_size_regular],8);
xlabel(sprintf('Field size (%%)'))
ylabel('Counts');


subplot(4,4,8)
centroid_without_baseline_regular=cell2mat({D.centroid_without_baseline_regular}');
[centroids_mat] = histcounts2(centroid_without_baseline_regular(:,1),centroid_without_baseline_regular(:,2),linspace(1,3,9),linspace(1,3,9));
% [centroids_mat] = histcounts2(centroid_without_baseline_regular(:,1),centroid_without_baseline_regular(:,2),linspace(1,3,4),linspace(1,3,4));
imagesc(centroids_mat);
title('Centroids without baseline');
set(gca,'YDir','normal');

subplot(4,4,9)
bin_mat_coordinate_ver= repmat([1:1:3],3,1);
bin_mat_coordinate_hor= repmat([1:1:3]',1,3);
[preferred_bin_mat] = histcounts2(bin_mat_coordinate_ver([D.preferred_bin_regular]),bin_mat_coordinate_hor([D.preferred_bin_regular]),[1:1:3+1],[1:1:3+1]);
imagesc([-1,0,1],[-1,0,1],preferred_bin_mat);
% imagesc(1:3,1:3,flipud(preferred_bin_mat));
title('Preferred position');
caxis([0,nanmax(preferred_bin_mat(:))])
set(gca,'YDir','normal');

subplot(4,4,10)
histogram([[D.preferred_theta_regular_odd] - [D.preferred_theta_regular_even]],8);
xlabel(sprintf('Delta Preferred direction \n odd minus even'))
ylabel('Counts');

subplot(4,4,11)
histogram([D.psth_corr_across_position_regular]);
xlabel(sprintf('Tuning similarity across positions\nr'))
ylabel('Counts');
xlim([-1,1]);



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

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r500']);
eval(['print ', figure_name_out, ' -dpdf -r200']);




