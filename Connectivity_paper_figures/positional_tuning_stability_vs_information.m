function positional_tuning_stability_vs_information
close all;

rel_roi=((IMG.ROI & IMG.ROIGood)-IMG.ROIBad) -IMG.Mesoscope;
rel= LICK2D.ROILick2DmapSpikes3bins*LICK2D.ROILick2DmapStatsSpikes3bins & rel_roi & 'lickmap_regular_odd_vs_even_corr>0.7';
number_of_bins=3;
D=fetch(rel & sprintf('number_of_bins=%d',number_of_bins),'*');

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Connectivity_paper_figures\plots\'];

filename=[sprintf('stability_vs_information_vs_field_size_bins%d',number_of_bins)];


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

for i=1:1:size(D,1)
    m=D(i).lickmap_fr_regular;
    max_m=nanmax(m(:));
    field_size(i)=100*sum(m(:)>max_m*0.5)/size(m(:),1);
    props = regionprops(true(size(m)), m, 'WeightedCentroid');
    x_centroid(i)=props.WeightedCentroid(1);
    y_centroid(i)=props.WeightedCentroid(2);
%     clf
%     imagesc(m);
%     hold on
%     plot(x_centroid(i),y_centroid(i),'*');

    
    %without baseline
    m=m-nanmin(m(:));
    max_m=nanmax(m(:));
    field_size_without_baseline(i) =100*sum(m(:)>max_m*0.5)/size(m(:),1);
    m(isnan(m))=0;
    
    m(m<max_m*0.5)=0;
    props = regionprops(true(size(m)), m, 'WeightedCentroid');
    x_centroid_without_baseline(i)=props.WeightedCentroid(1);
    y_centroid_without_baseline(i)=props.WeightedCentroid(2);
    clf
    imagesc(m);
    hold on
    plot(x_centroid_without_baseline(i),y_centroid_without_baseline(i),'*');
    
end



subplot(3,3,1)
histogram([D.lickmap_regular_odd_vs_even_corr]);
xlabel(sprintf('Stability r \n(odd trials,even trials)'))
ylabel('Counts');
title(sprintf('n = %d cells \n bins = %d X %d',size(D,1),number_of_bins,number_of_bins))

subplot(3,3,2)
histogram([D.field_size_regular],10);
xlabel(sprintf('Field size (%%)'))
ylabel('Counts');

subplot(3,3,3)
histogram([D.information_per_spike_regular]);
xlabel('Spatial information (bits/spike)');
ylabel('Counts');

subplot(3,3,4)
plot([D.lickmap_regular_odd_vs_even_corr],[D.information_per_spike_regular],'.')
xlabel(sprintf('Stability r \n(odd trials,even trials)'))
ylabel('Spatial information (bits/spike)');

subplot(3,3,5)
plot([D.lickmap_regular_odd_vs_even_corr],[D.field_size_regular],'.')
xlabel(sprintf('Stability r \n(odd trials,even trials)'))
ylabel(sprintf('Field size (%%)'))

subplot(3,3,6)
plot([D.information_per_spike_regular],[D.field_size_regular],'.')
xlabel('Spatial information (bits/spike)');
ylabel(sprintf('Field size (%%)'))


subplot(3,3,7)
centroid_without_baseline_regular=cell2mat({D.centroid_without_baseline_regular}');
[centroids_mat] = histcounts2(centroid_without_baseline_regular(:,2),centroid_without_baseline_regular(:,1),linspace(1,number_of_bins,9),linspace(1,number_of_bins,9));
imagesc(1:number_of_bins,1:number_of_bins,centroids_mat);
title('Centroids without baseline');

subplot(3,3,8)
bin_mat_coordinate_x= repmat([1:1:number_of_bins],number_of_bins,1);
bin_mat_coordinate_y= repmat([1:1:number_of_bins]',1,number_of_bins);

[preferred_bin_mat] = histcounts2(bin_mat_coordinate_y([D.preferred_bin_regular]),bin_mat_coordinate_x([D.preferred_bin_regular]),[1:1:number_of_bins+1],[1:1:number_of_bins+1]);
imagesc(1:number_of_bins,1:number_of_bins,preferred_bin_mat);
title('Preferred position');

% subplot(2,2,2)
% histogram(field_size_without_baseline);
% xlabel(sprintf('Field size baseline subtracted(%%)'))
% ylabel('Counts');

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r500']);
eval(['print ', figure_name_out, ' -dpdf -r200']);




