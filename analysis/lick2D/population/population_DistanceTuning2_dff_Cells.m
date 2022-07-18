function population_DistanceTuning2_dff_Cells
close all

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Lick2D\population\distance_dependence2\'];
filename = 'population_summary_dff';



key.odd_even_corr_threshold=0;
rel_data= (LICK2D.DistanceCorrConcat2 *EXP2.SessionID & 'num_cells_included>=200') - IMG.Mesoscope;
D=fetch(rel_data	 & key,'*');
bins_lateral_distance=D(1).lateral_distance_bins;
bins_lateral_center = bins_lateral_distance(1:end-1) + mean(diff(bins_lateral_distance))/2;
bins_axial_distance=D(1).axial_distance_bins;

subplot(3,3,1)
% all sessions
distance_lateral_all = cell2mat({D.distance_corr_lateral}');
d_lateral_mean =  nanmean(distance_lateral_all,1);
d_lateral_stem =  nanstd(distance_lateral_all,1)/sqrt(size(D,1));
shadedErrorBar(bins_lateral_center,d_lateral_mean,d_lateral_stem,'lineprops',{'.-','Color',[0 0 0]})
xlabel('Lateral Distance (um)');
ylabel (sprintf('PSTH concatenated \n(correlation)'));
box off
% title(sprintf('Temporal and Directional \ntuning, concat'));
% ylim([0, max(d_lateral_mean+d_lateral_stem)])

subplot(3,3,2)
hold on
% all sessions
idx_column_radius=2; %10 to 30 microns
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
% title(sprintf('Temporal and Directional \ntuning, concat'));

idx_column_radius=16; %30 to 50 microns
distance_axial_all=[];
for i_s=1:1:size(D,1)
    distance_axial_all(i_s,:) = D(i_s).distance_corr_axial_columns(:,idx_column_radius); %index 1 refers to the radius of the axial column we take
end
d_axial_mean2 =  nanmean(distance_axial_all,1);
d_axial_stem =  nanstd(distance_axial_all,1)/sqrt(size(D,1));
shadedErrorBar(bins_axial_distance,d_axial_mean2,d_axial_stem,'lineprops',{'.-','Color',[0 0 0]})

idx_column_radius=25; %50 to 250 microns
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
xlabel([sprintf('Lateral or Axial distance ') '(\mum)']);
ylabel (sprintf('PSTH concatenated \n(correlation)'));



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
ylabel([sprintf('Axial Distance ') '(\mum)']);
% colorbar
% set(gca,'YTick',[],'XTick',[20,100:100:500]);
set(gca,'YTick',[bins_axial_distance],'XTick',[0,50:50:200]);
ylabel([sprintf('Axial      \nDistance ') '(\mum)        ']);


cb1=colorbar;
text(350, 100, ['Correlation'],'Rotation',90);



if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end

figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);
