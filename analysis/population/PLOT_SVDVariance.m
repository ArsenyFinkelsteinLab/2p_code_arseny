function PLOT_SVDVariance()
close all
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim\photostim_distance\'];

rel_data2 = POP.SVDSingularValuesSpikes  & (IMG.Mesoscope- IMG.Volumetric) & 'threshold_for_event=0' & 'time_bin=1.5';


DefaultFontSize =16;
figure
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


%% BEHAVIOR
DATA=fetch(rel_data2 & 'session_epoch_type="behav_only"','*');
num_sessions = numel(DATA);

for i=1:1:num_sessions
    num_components_behav(i) = numel(DATA(i).singular_values);
end
num_components_behav = min(num_components_behav);

for i=1:1:num_sessions
    v = DATA(i).singular_values;
    ve =v.^2/sum(v.^2); % a feature of SVD. proportion of variance explained by each component
    VE_behav (i,:) = ve(1:1:num_components_behav);
end
VE_behav_mean =  mean(VE_behav,1);
VE_behav_stem =  std(VE_behav,1)./sqrt(num_sessions);

%% SPONT
DATA=fetch(rel_data2 & 'session_epoch_type="spont_only"' ,'*');
num_sessions = numel(DATA);
for i=1:1:num_sessions
    num_components_spont(i) = numel(DATA(i).singular_values);
end
num_components_spont = min(num_components_spont);

for i=1:1:num_sessions
    v = DATA(i).singular_values;
    ve =v.^2/sum(v.^2); % a feature of SVD. proportion of variance explained by each component
    VE_spont (i,:) = ve(1:1:num_components_spont);
end
VE_spont_mean =  mean(VE_spont,1);
VE_spont_stem =  std(VE_spont,1)./sqrt(num_sessions);

    
%     cumulative_variance_explained=cumsum(variance_explained);
    %             plot(cumulative_variance_explained);
    %             xlabel('Component')
    %             ylabel('Cumulative explained variance');


    %% PLOT
x_behav = 1:1:num_components_behav;
err_behav = [VE_behav_mean+VE_behav_stem; VE_behav_mean - VE_behav_stem];                                                       
x_spont= 1:1:num_components_spont;
err_spont = [VE_spont_mean+VE_spont_stem; VE_spont_mean - VE_spont_stem];                                                     

subplot(2,2,1)
hold on
patch([x_behav, fliplr(x_behav)], [err_behav(1,:), fliplr(err_behav(2,:))], 'b', 'FaceAlpha',0.2, 'EdgeColor', 'none')   % Shaded Confidence Intervals
plot(x_behav, VE_behav_mean,'-b')

patch([x_spont, fliplr(x_spont)], [err_spont(1,:), fliplr(err_spont(2,:))], 'r', 'FaceAlpha',0.2, 'EdgeColor', 'none')   % Shaded Confidence Intervals
plot(x_spont, VE_spont_mean,'-r')
set(gca, 'XScale','log', 'YScale','log')
xlabel('PC dimension');
ylabel('Spatial scale (\mum)');
text(100,0.01,'Behavior', 'Color', [0 0 1]);
text(100,0.005,'Spontaneous', 'Color', [1 0 0]);
box off

% loglog (1:1:num_components_behav, smooth(VE_behav_mean,10),'-b')
% hold on
% loglog (1:1:num_components_spont, smooth(VE_spont_mean,10),'-r')



fig = gcf;    %or one particular figure whose handle you already know, or 0 to affect all figures
set( findall(fig, '-property', 'fontsize'), 'fontsize', DefaultFontSize)

