function PLOT_ConnectionProbabilityDistance()
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim\Connectivity\'];
filename = 'Distance_Connection_probability';

clf;


DefaultFontSize =12;
% figure
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

% set(gcf,'DefaultAxesFontSize',6);



horizontal_dist=0.35;
vertical_dist=0.35;

panel_width1=0.2;
panel_height1=0.25;
position_x1(1)=0.2;
position_x1(end+1)=position_x1(end)+horizontal_dist;

position_y1(1)=0.5;
position_y1(end+1)=position_y1(end)-vertical_dist;

rel_data = (STIMANAL.InfluenceDistance222 & 'flag_divide_by_std=0' & 'flag_withold_trials=1' & 'flag_normalize_by_total=1') ...
    &  (STIMANAL.SessionEpochsIncludedFinal& IMG.Volumetric & 'stimpower=100' & 'flag_include=1'  ...
     & (STIMANAL.NeuronOrControlNumber2 & 'num_targets_neurons>=50') ...
    & (STIMANAL.NeuronOrControlNumber2 & 'num_targets_controls>=50'));

key.num_svd_components_removed=0;
key.is_volumetric =1; % 1 volumetric, 1 single plane
distance_axial_bins=[0,60,90,120];
distance_axial_bins_plot=[0,30,60,90,120];
% key.session_epoch_number=2;
flag_response= 1; %0 all, 1 excitation, 2 inhibition, 3 absolute
response_p_val=0.05;


key.neurons_or_control =1; % 1 neurons, 0 control sites
rel_neurons = rel_data & key & sprintf('response_p_val=%.3f',response_p_val);

rel_all = rel_data & key & sprintf('response_p_val=1');

rel_sessions_neurons= EXP2.SessionEpoch & rel_neurons; % only includes sessions with responsive neurons



%% 2D plots - Neurons
ax1=axes('position',[position_x1(1), position_y1(1), panel_width1, panel_height1]);
D1=fetch(rel_neurons,'*');  % response p-value for inclusion. 1 means we take all pairs
D1_all=fetch(rel_all,'*');  % response p-value for inclusion. 1 means we take all pairs
OUT1=fn_PLOT_ConnectionProbabilityDistance_averaging(D1,D1_all,distance_axial_bins,flag_response);

xl=[OUT1.distance_lateral_bins_centers(1),OUT1.distance_lateral_bins_centers(end)];
xl=[0,400];

imagesc(OUT1.distance_lateral_bins_centers(3:end), distance_axial_bins_plot,  OUT1.map(:,3:end))
axis tight
axis equal
cmp = bluewhitered(2048); %
colormap(ax1, cmp)
caxis([OUT1.minv max(max(OUT1.map(:,3:end)))]);
% set(gca,'XTick',OUT1.distance_lateral_bins_centers)
xlabel([sprintf('Lateral Distance ') '(\mum)']);
% ylabel([sprintf('Axial Distance ') '(\mum)']);
% colorbar
% set(gca,'YTick',[],'XTick',[20,100:100:500]);
set(gca,'YTick',[0 60 120],'XTick',[25,100:100:500]);
ylabel([sprintf('Axial      \nDistance ') '(\mum)        ']);
xlim(xl)

ax2=axes('position',[position_x1(1)+0.2, position_y1(1)+0.09, panel_width1/5, panel_height1/4]);
cmp = bluewhitered(512); %
colormap(ax2, cmp)
caxis([OUT1.minv max(max(OUT1.map(:,3:end)))]);
colorbar
axis off
text(8, 0.1, sprintf('\n\nConnection \n Probability'),'Rotation',90);



%% 2D plots - Control sites
key.neurons_or_control =0; % 1 neurons, 0 control sites
rel_control = rel_data & rel_sessions_neurons & key & sprintf('response_p_val=%.3f',response_p_val);
rel_control_all = rel_data & rel_sessions_neurons & key & sprintf('response_p_val=1');

D2=fetch(rel_control,'*');  % response p-value for inclusion. 1 means we take all pairs
D2_all=fetch(rel_control_all,'*');  % response p-value for inclusion. 1 means we take all pairs
OUT2=fn_PLOT_ConnectionProbabilityDistance_averaging(D2,D2_all,distance_axial_bins,flag_response);

% ax2=axes('position',[position_x1(1), position_y1(2), panel_width1, panel_height1]);
% imagesc(OUT2.distance_lateral_bins_centers,  distance_axial_bins_plot, OUT2.map)
% axis tight
% axis equal
% colormap(ax2,cmp)
% % colorbar
% xlabel([sprintf('Lateral Distance ') '(\mum)']);
% ylabel([sprintf('Axial Distance ') '(\mum)']);
% set(gca,'YTick',[0 60 90 120],'XTick',[25,100:100:500]);
% ylabel([sprintf('Axial \nDistance\n ') '(\mum)']);



%% Marginal distribution - lateral
axes('position',[position_x1(1), position_y1(1)+0.175, panel_width1, panel_height1*0.5]);
hold on
% plot(xl, [0 0],'-k')
shadedErrorBar(OUT1.distance_lateral_bins_centers(3:end),OUT1.marginal_lateral_mean(3:end),OUT1.marginal_lateral_stem(3:end),'lineprops',{'-','Color',[1 0 1]})
shadedErrorBar(OUT1.distance_lateral_bins_centers(3:end),OUT2.marginal_lateral_mean(3:end),OUT2.marginal_lateral_stem(3:end),'lineprops',{'-','Color',[0.5 0.5 0.5]})
% yl(1)=-2*abs(min([OUT1.marginal_lateral_mean,OUT2.marginal_lateral_mean]));
% yl(2)=abs(max([OUT1.marginal_lateral_mean,OUT2.marginal_lateral_mean]));
yl(1)=0;
yl(2)=0.15;
ylim(yl)
set(gca,'XTick',[],'XLim',xl);
box off
% ylabel([sprintf('         Response\n') '        (z-score)']);
ylabel(sprintf('Connection \nProbability '));
set(gca,'YTick',[0,yl(2)]);

% % Marginal distribution - lateral (zoom)
% axes('position',[position_x1(1)+0.06, position_y1(1)+0.25, panel_width1*0.5, panel_height1*0.5]);
% hold on
% plot(xl, [0 0],'-k')
% shadedErrorBar(OUT1.distance_lateral_bins_centers,OUT1.marginal_lateral_mean,OUT1.marginal_lateral_stem,'lineprops',{'-','Color',[1 0 1]})
% shadedErrorBar(OUT1.distance_lateral_bins_centers,OUT2.marginal_lateral_mean,OUT2.marginal_lateral_stem,'lineprops',{'-','Color',[0.5 0.5 0.5]})
% % yl(1)=1.2*min([OUT1.marginal_lateral_mean,OUT2.marginal_lateral_mean]);
% % yl(2)=1.21*abs(min([OUT1.marginal_lateral_mean,OUT2.marginal_lateral_mean]));
% yl=[-0.0075 0.0075];
% ylim(yl)
% set(gca,'XLim',xl);
% box off
% set(gca,'YTick',[-0.005 0 0.005],'XTick',[100 200 400],'XTickLabel',{'100' '     200' '400'},'TickLength',[0.05 0.05]);
% text(150,0.0065,'Neuron targets','Color',[1 0 1]);
% text(150,0.004,sprintf('Control targets'),'Color',[0.5 0.5 0.5]);
% 



% %% Marginal distribution - axial NEAR
% axm=axes('position',[position_x1(1), position_y1(1)-0.18, panel_width1*0.4, panel_height1*0.4]);
% hold on
% plot([distance_axial_bins(1),distance_axial_bins(end)],[0 0],'-k')
% shadedErrorBar(distance_axial_bins,OUT1.marginal_axial_in_column_mean,OUT1.marginal_axial_in_column_stem,'lineprops',{'.-','Color',[1 0 1]})
% shadedErrorBar(distance_axial_bins,OUT2.marginal_axial_in_column_mean,OUT2.marginal_axial_in_column_stem,'lineprops',{'.-','Color',[0.5 0.5 0.5]})
% axm.View = [90 90]
% xlabel([sprintf('Axial \nDistance ') '(\mum)']);
% ylabel([sprintf('       Connection Probability')]);
% set(gca,'XTick',[0 60 120]);
% title([sprintf('25< Lateral <100     \n') '(\mum)'],'FontSize',6)

% %% Marginal distribution - axial FAR
% axm=axes('position',[position_x1(1)+0.12, position_y1(1)-0.18, panel_width1*0.4, panel_height1*0.4]);
% hold on
% plot([distance_axial_bins(1),distance_axial_bins(end)],[0 0],'-k')
% shadedErrorBar(distance_axial_bins,OUT1.marginal_axial_out_column_mean,OUT1.marginal_axial_out_column_stem,'lineprops',{'.-','Color',[1 0 1]})
% shadedErrorBar(distance_axial_bins,OUT2.marginal_axial_out_column_mean,OUT2.marginal_axial_out_column_stem,'lineprops',{'.-','Color',[0.5 0.5 0.5]})
% axm.View = [90 90]
% % xlabel([sprintf('Axial Distance ') '(\mum)']);
% set(gca,'XTick',[0 60 120],'XTickLabel',[]);
% title([sprintf('    100< Lateral <200\n ') '(\mum)'],'FontSize',6)

% plot( distance_axial_bins_plot, OUT1.marginal_axial_mean, '-b')
% plot( distance_axial_bins_plot, OUT2.marginal_axial_mean,'-m')
% set(gca,'Ydir','reverse')
% % Marginal distribution - lateral (zoom)
% axes('position',[position_x1(2), position_y1(1)+0.2, panel_width1, panel_height1/2]);
% hold on
% plot([0,OUT1.distance_lateral_bins_centers(end)], [0 0],'-k')
% plot(OUT1.distance_lateral_bins_centers, OUT1.lateral_marginal,'-b')
% plot(OUT2.distance_lateral_bins_centers, OUT2.lateral_marginal,'-m')
% yl(1)=min([OUT1.lateral_marginal,OUT2.lateral_marginal]);
% yl(2)=2*abs(min([OUT1.lateral_marginal,OUT2.lateral_marginal]));
% ylim(yl)

fig = gcf;    %or one particular figure whose handle you already know, or 0 to affect all figures
set( findall(fig, '-property', 'fontsize'), 'fontsize', DefaultFontSize)

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);
