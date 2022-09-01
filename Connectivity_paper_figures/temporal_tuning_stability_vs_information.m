function temporal_tuning_stability_vs_information
close all;

rel_roi=((IMG.ROI & IMG.ROIGood)-IMG.ROIBad) -IMG.Mesoscope;
rel= LICK2D.ROILick2DmapSpikes& rel_roi;
number_of_bins=3;
D=fetch(rel & sprintf('number_of_bins=%d',number_of_bins),'information_per_spike','lickmap_odd_even_corr','lickmap_fr');

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Connectivity_paper_figures\plots\'];

filename=[sprintf('temporal_stability_vs_information_vs_field_size_bins%d',number_of_bins)];


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
    m=D(i).lickmap_fr(:);
    field_size(i)=100*sum(m>nanmean(m))/size(m,1);
    
    m=m-nanmean(m);
    m(m<0)=0;
    field_size_without_baseline(i) = 100*sum(m>nanmean(m))/size(m,1);
end


subplot(2,3,1)
histogram([D.lickmap_odd_even_corr]);
xlabel(sprintf('Stability r \n(odd trials,even trials)'))
ylabel('Counts');
title(sprintf('n = %d cells \n bins = %d X %d',size(D,1),number_of_bins,number_of_bins))

subplot(2,3,2)
histogram(field_size,10);
xlabel(sprintf('Field size (%%)'))
ylabel('Counts');

subplot(2,3,3)
histogram([D.information_per_spike]);
xlabel('Spatial information (bits/spike)');
ylabel('Counts');

subplot(2,3,4)
plot([D.lickmap_odd_even_corr],[D.information_per_spike],'.')
xlabel(sprintf('Stability r \n(odd trials,even trials)'))
ylabel('Spatial information (bits/spike)');

subplot(2,3,5)
plot([D.lickmap_odd_even_corr],field_size,'.')
xlabel(sprintf('Stability r \n(odd trials,even trials)'))
ylabel(sprintf('Field size (%%)'))

subplot(2,3,6)
plot([D.information_per_spike],field_size,'.')
xlabel('Spatial information (bits/spike)');
ylabel(sprintf('Field size (%%)'))


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




