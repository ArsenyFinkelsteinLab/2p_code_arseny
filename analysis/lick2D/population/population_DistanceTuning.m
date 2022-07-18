function population_DistanceTuning
close all

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Lick2D\population\distance_dependence\'];
filename = 'population_summary';



subplot(2,3,1)
distance_lateral_all=[];
rel_data= LICK2D.DistancePSTHCorrVolumetricSpikes *EXP2.SessionID;
key.odd_even_corr_threshold=0.50;

D=fetch(rel_data	 & key,'*');
bins_lateral_distance=D(1).lateral_distance_bins;

% all sessions
distance_lateral_all = cell2mat({D.distance_corr_lateral}');

% for i_s=1:1:size(D,1)
%     distance_lateral_all(i_s,:) = mean( [D(i_s).distance_corr_2d],1);
% end


d_lateral_mean =  mean(distance_lateral_all,1);
d_lateral_stem =  std(distance_lateral_all,1)/sqrt(size(D,1));

shadedErrorBar(bins_lateral_distance(1:1:end-1),d_lateral_mean,d_lateral_stem,'lineprops',{'.-','Color',[0 0 0]})
xlabel('Lateral Distance (um)');
ylabel ('PSTH (correlation)');
box off
title('Temporal tuning');


subplot(2,3,2)
distance_lateral_all=[];
rel_data= LICK2D.DistanceQuadrantsCorrVolumetricSpikes*EXP2.SessionID;
key.odd_even_corr_threshold=0.50;

D=fetch(rel_data	 & key,'*');
bins_lateral_distance=D(1).lateral_distance_bins;

% all sessions
distance_lateral_all = cell2mat({D.distance_corr_lateral}');


d_lateral_mean =  mean(distance_lateral_all,1);
d_lateral_stem =  std(distance_lateral_all,1)/sqrt(size(D,1));

shadedErrorBar(bins_lateral_distance(1:1:end-1),d_lateral_mean,d_lateral_stem,'lineprops',{'.-','Color',[0 0 0]})
xlabel('Lateral Distance (um)');
ylabel ('PSTH qudrants (correlation)');
box off
title('Temporal and Directional tuning');


subplot(2,3,3)
distance_lateral_all=[];
rel_data= LICK2D.DistanceAngularTuningCorrVolumetricSpikes *EXP2.SessionID;
key.odd_even_corr_threshold=0.50;

D=fetch(rel_data	 & key,'*');
bins_lateral_distance=D(1).lateral_distance_bins;

% all sessions
distance_lateral_all = cell2mat({D.distance_corr_lateral}');


d_lateral_mean =  mean(distance_lateral_all,1);
d_lateral_stem =  std(distance_lateral_all,1)/sqrt(size(D,1));

shadedErrorBar(bins_lateral_distance(1:1:end-1),d_lateral_mean,d_lateral_stem,'lineprops',{'.-','Color',[0 0 0]})
xlabel('Lateral Distance (um)');
ylabel ('Angular tuning (correlation)');
title('Directional tuning');
box off


subplot(2,3,4)
rel_data= LICK2D.DistanceAngleSpikes*EXP2.SessionID;

key.vn_mises_correlation_treshold=0.50;
key.column_radius=50;

D=fetch(LICK2D.DistanceAngleSpikes & key,'*');
bins_lateral_distance=D(1).bins_lateral_distance;

theta_lateral_distance=(cell2mat(fetchn(rel_data & key,'theta_lateral_distance', 'ORDER BY session_uid')));
theta_lateral_distance_shuffled=(cell2mat(fetchn(rel_data & key,'theta_lateral_distance_shuffled', 'ORDER BY session_uid')));

% theta_distance_sessions=theta_lateral_distance_shuffled - theta_lateral_distance;
% theta_distance_mean=mean(theta_distance_sessions);

theta_distance_mean = mean(theta_lateral_distance);
theta_distance_mean_stem =  std(theta_lateral_distance,1)/sqrt(size(theta_lateral_distance,1));

% ax1=axes('position',[position_x2(3), position_y2(3), panel_width2, panel_height2]);
hold on;
shadedErrorBar(bins_lateral_distance(1:1:end-1),theta_distance_mean,theta_distance_mean_stem,'lineprops',{'.-','Color',[0 0 0]})

% plot(bins_lateral_distance(1:1:end-1),theta_lateral_distance_shuffled,'-k')
ylim([60,90]);
xlabel('Lateral distance (\mum)');
ylabel('\Delta\theta (\circ)');
title(sprintf('Preferred Direction'));
xlim([0,bins_lateral_distance(end-1)]);
set(gca,'YTick',[45,60,75, 90]);

subplot(2,3,5)
distance_lateral_all=[];
rel_data= LICK2D.DistanceCorrConcatSpikes *EXP2.SessionID;
key.odd_even_corr_threshold=0;
D=fetch(rel_data	 & key,'*');
bins_lateral_distance=D(1).lateral_distance_bins;

% all sessions
distance_lateral_all = cell2mat({D.distance_corr_lateral}');

d_lateral_mean =  nanmean(distance_lateral_all,1);
d_lateral_stem =  nanstd(distance_lateral_all,1)/sqrt(size(D,1));

shadedErrorBar(bins_lateral_distance(1:1:end-1),d_lateral_mean,d_lateral_stem,'lineprops',{'.-','Color',[0 0 0]})
xlabel('Lateral Distance (um)');
ylabel ('PSTH concatenated (correlation)');
box off
title('Temporal and Directional tuning, concat');


if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);
