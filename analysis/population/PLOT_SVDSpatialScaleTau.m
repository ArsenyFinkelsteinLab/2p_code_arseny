function PLOT_SVDSpatialScaleTau()
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim\photostim_distance\'];
clf;


rel_data1 = POP.ROISVDDistanceScale  & (IMG.Mesoscope- IMG.Volumetric);

smooth_window_scale = 10;

DefaultFontSize =16;
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
panel_height1=0.2;
position_x1(1)=0.2;
position_x1(end+1)=position_x1(end)+horizontal_dist;

position_y1(1)=0.5;
position_y1(end+1)=position_y1(end)-vertical_dist;

DATA=fetch(rel_data1 & 'session_epoch_type="behav_only"','*');
num_sessions = numel(DATA);
num_components_behav = min([DATA.num_components]);
for i=1:1:num_sessions
    Scale_behav (i,:) = smooth(DATA(i).distance_tau(1:1:num_components_behav),smooth_window_scale);
end

Scale_behav_mean =  mean(Scale_behav,1);
Scale_behav_stem =  std(Scale_behav,1)./sqrt(num_sessions);



DATA=fetch(rel_data1 & 'session_epoch_type="spont_only"' ,'*');
num_sessions = numel(DATA);
num_components_spont = min([DATA.num_components]);
for i=1:1:num_sessions
    Scale_spont (i,:) = smooth(DATA(i).distance_tau(1:1:num_components_spont),smooth_window_scale);
end

Scale_spont_mean =  mean(Scale_spont,1);
Scale_spont_stem =  std(Scale_spont,1)./sqrt(num_sessions);

%% PLOT
x_behav = 1:1:num_components_behav;
y_behav = Scale_behav_mean;
err_behav = [Scale_behav_mean+Scale_behav_stem; Scale_behav_mean - Scale_behav_stem];     

x_spont= 1:1:num_components_spont;
y_spont = Scale_spont_mean;
err_spont = [Scale_spont_mean+Scale_spont_stem; Scale_spont_mean - Scale_spont_stem];                                                     

subplot(2,2,1)
hold on
patch([x_behav, fliplr(x_behav)], [err_behav(1,:), fliplr(err_behav(2,:))], 'b', 'FaceAlpha',0.5, 'EdgeColor', 'none')   % Shaded Confidence Intervals
plot(x_behav, y_behav,'-b')

patch([x_spont, fliplr(x_spont)], [err_spont(1,:), fliplr(err_spont(2,:))], 'r', 'FaceAlpha',0.5, 'EdgeColor', 'none')   % Shaded Confidence Intervals
plot(x_spont, y_spont,'-r')

set(gca, 'XScale','log', 'YScale','log')
xlabel('PC dimension');
ylabel('Spatial scale (\um)');
text(100,0.01,'Behavior', 'Color', [0 0 1]);
text(100,0.005,'Spontaneous', 'Color', [1 0 0]);
box off
text(50,1500,'Behavior', 'Color', [0 0 1]);
text(50,1000,'Spontaneous', 'Color', [1 0 0]);


fig = gcf;    %or one particular figure whose handle you already know, or 0 to affect all figures
set( findall(fig, '-property', 'fontsize'), 'fontsize', DefaultFontSize)

