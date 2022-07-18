function population_DistanceTuningNeuropil
close all

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Lick2D\population\distance_dependence2\'];
filename = 'population_summary2_neuropil_vs_cells';



key.odd_even_corr_threshold=0.25;

%% dFF Cells versus Neuropil
subplot(3,3,1)

rel_data= (LICK2D.DistanceCorrConcat*EXP2.SessionID & 'num_cells_included>=200') - IMG.Mesoscope;
rel_data_neuropil= (LICK2D.DistanceCorrConcatNeuropil *EXP2.SessionID & 'num_cells_included>=200') - IMG.Mesoscope;

%dFF Cells
D=fetch(rel_data	 & key,'*');
bins_lateral_distance=D(1).lateral_distance_bins;
bins_lateral_center = bins_lateral_distance(1:end-1) + mean(diff(bins_lateral_distance))/2;
distance_lateral_all = cell2mat({D.distance_corr_lateral}');
d_lateral_mean =  nanmean(distance_lateral_all,1);
d_lateral_stem =  nanstd(distance_lateral_all,1)/sqrt(size(D,1));
shadedErrorBar(bins_lateral_center,d_lateral_mean,d_lateral_stem,'lineprops',{'.-','Color',[0 0 0]})


%dFF Neuropil
D=fetch(rel_data_neuropil	 & key,'*');
distance_lateral_all = cell2mat({D.distance_corr_lateral}');
d_lateral_mean =  nanmean(distance_lateral_all,1);
d_lateral_stem =  nanstd(distance_lateral_all,1)/sqrt(size(D,1));
shadedErrorBar(bins_lateral_center,d_lateral_mean,d_lateral_stem,'lineprops',{'.-','Color',[0 1 0]})
xlabel('Lateral Distance (um)');
ylabel (sprintf('PSTH concatenated \n(correlation)'));
box off
title(sprintf('Temporal and Directional \ntuning, concat'));
% ylim([0, max(d_lateral_mean+d_lateral_stem)])


%% Axial
subplot(3,3,2)
D=fetch(rel_data	 & key,'*');

D=D([2,5,7:10,14],:);
bins_axial_distance=D(1).axial_distance_bins;

hold on
% all sessions
idx_column_radius=2;
distance_axial_all=[];
for i_s=1:1:size(D,1)
    distance_axial_all(i_s,:) = D(i_s).distance_corr_axial_columns(:,idx_column_radius); %index 1 refers to the radius of the axial column we take
end
d_axial_mean1 =  nanmean(distance_axial_all,1);
d_axial_stem =  nanstd(distance_axial_all,1)/sqrt(size(D,1));
shadedErrorBar(bins_axial_distance,d_axial_mean1,d_axial_stem,'lineprops',{'.-','Color',[0 0 0]})
xlabel('Axial Distance (um)');
ylabel (sprintf('PSTH concatenated \n(correlation)'));
box off
title(sprintf('Temporal and Directional \ntuning, concat'));

idx_column_radius=4;
distance_axial_all=[];
for i_s=1:1:size(D,1)
    distance_axial_all(i_s,:) = D(i_s).distance_corr_axial_columns(:,idx_column_radius); %index 1 refers to the radius of the axial column we take
end
d_axial_mean2 =  nanmean(distance_axial_all,1);
d_axial_stem =  nanstd(distance_axial_all,1)/sqrt(size(D,1));
shadedErrorBar(bins_axial_distance,d_axial_mean2,d_axial_stem,'lineprops',{'.-','Color',[0 0 0]})

idx_column_radius=16;
distance_axial_all=[];
for i_s=1:1:size(D,1)
    distance_axial_all(i_s,:) = D(i_s).distance_corr_axial_columns(:,idx_column_radius); %index 1 refers to the radius of the axial column we take
end
d_axial_mean3 =  nanmean(distance_axial_all,1);
d_axial_stem =  nanstd(distance_axial_all,1)/sqrt(size(D,1));
shadedErrorBar(bins_axial_distance,d_axial_mean3,d_axial_stem,'lineprops',{'.-','Color',[0 0 0]})

% idx_column_radius=30;
% for i_s=1:1:size(D,1)
%     distance_axial_all(i_s,:) = D(i_s).distance_corr_axial_columns(:,idx_column_radius); %index 1 refers to the radius of the axial column we take
% end
% d_axial_mean4 =  nanmean(distance_axial_all,1);
% d_axial_stem =  nanstd(distance_axial_all,1)/sqrt(size(D,1));
% shadedErrorBar(bins_axial_distance,d_axial_mean4,d_axial_stem,'lineprops',{'.-','Color',[0 0 0]})


subplot(3,3,3)
hold on
plot(bins_lateral_center,d_lateral_mean,'.-r')
plot(bins_axial_distance,d_axial_mean1,'.-b')
xlim([0,120])



% 2D
subplot(3,3,4)
distance_corr_2d_all=[];
% all sessions
for i_s=1:1:size(D,1)
    distance_corr_2d_all(i_s,:,:) = D(i_s).distance_corr_2d; %index 1 refers to the radius of the axial column we take
end
distance_corr_2d_mean=squeeze(nanmean(distance_corr_2d_all,1));
imagesc(bins_lateral_center,bins_axial_distance,  distance_corr_2d_mean)
xlabel('Lateral Distance (um)');
ylabel('Axial Distance (um)');
% colorbar
colormap(inferno)
c_lim(1)=min([nanmin(distance_corr_2d_mean(:))]);
c_lim(2) = nanmax(distance_corr_2d_mean(:));
caxis([c_lim]);

axis tight
axis equal
% set(gca,'XTick',OUT1.distance_lateral_bins_centers)
xlabel([sprintf('Lateral Distance ') '(\mum)']);
% ylabel([sprintf('Axial Distance ') '(\mum)']);
% colorbar
% set(gca,'YTick',[],'XTick',[20,100:100:500]);
set(gca,'YTick',[bins_axial_distance],'XTick',[0,50:50:200]);
ylabel([sprintf('Axial      \nDistance ') '(\mum)        ']);

% colormap(ax2, inferno)
% caxis(c_lim);
cb1=colorbar;
text(400, 150, ['Correlation'],'Rotation',90);
axis off



if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end

figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);
