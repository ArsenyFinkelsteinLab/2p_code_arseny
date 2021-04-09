function PLOTS_MapsSVD(key, dir_current_fig, W, x_all, y_all, components_2plot , rd_distance, distance_bins_centers, distance_tau)
close all;
% clf;

if contains(key.session_epoch_type,'spont')
    session_epoch_label = 'Spontaneous';
elseif contains(key.session_epoch_type,'behav')
    session_epoch_label = 'Behavior';
end

filename =[session_epoch_label '_PC' num2str(components_2plot)];

session_date = fetch1(EXP2.Session & key,'session_date');

horizontal_dist=0.25;
vertical_dist=0.35;

panel_width1=0.7;
panel_height1=0.7;

position_x1(1)=0.27;
position_y1(1)=0.14;

panel_width2=0.09;
panel_height2=0.08;
horizontal_dist2=0.16;
vertical_dist2=0.35;

position_x2(1)=0.06;
position_x2(end+1)=position_x2(end)+horizontal_dist2;

position_y2(1)=0.8;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;

%Graphics
%---------------------------------
fff = figure("Visible",false);
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 15]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);


%% Map
bins_colormap = prctile(W,[2:2:98]);
max_abs = max( [ abs(prctile(W,2)), abs(prctile(W,98)) ] );
bins_colormap = linspace(-max_abs,max_abs,50);
bins_colormap(1) = -inf;
bins_colormap(end) = inf;



[N,edges,bin]=histcounts(W,bins_colormap);
ax1=axes('position',[position_x1(1), position_y1(1), panel_width1, panel_height1]);
my_colormap=jet(numel(bins_colormap));
hold on;

for i_roi=1:1:size(W,1)
    plot(x_all(i_roi), y_all(i_roi),'.','Color',my_colormap(bin(i_roi),:),'MarkerSize',7)
end
axis xy
set(gca,'YDir','reverse')
% title(sprintf('Motor map, left ALM\n n = %d tuned neurons (%.1f%%) \n',size(M,1), 100*size(M,1)/rel_all_good_cells.count   ));
% set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, 800], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,800],'TickLength',[0.01,0],'TickDir','out')
axis equal
axis tight
xlabel('Anterior - Posterior (\mum)');
ylabel('Lateral - Medial (\mum)');
title([ 'anm' num2str(key.subject_id) ' s' num2str(key.session) ' ' session_date newline session_epoch_label ' session' ' PC = ' num2str(components_2plot) newline]);

%% PLOT ALLEN MAP
allen2mm=1000*3.2/160;
bregma_x_mm=1000*fetchn(IMG.Bregma & key,'bregma_x_cm');
if ~isempty(bregma_x_mm)
    allenDorsalMapSM_Musalletal2019 = load('allenDorsalMapSM_Musalletal2019.mat');
    edgeOutline = allenDorsalMapSM_Musalletal2019.dorsalMaps.edgeOutline;
    
    bregma_x_allen = allenDorsalMapSM_Musalletal2019.dorsalMaps.bregmaScaled(2);
    bregma_y_allen = allenDorsalMapSM_Musalletal2019.dorsalMaps.bregmaScaled(1);
    for i_a = 1:1:numel(edgeOutline)
        hold on
        xxx = -1*([edgeOutline{i_a}(:,1)]-bregma_x_allen);
        yyy= [edgeOutline{i_a}(:,2)]-bregma_y_allen;
        
        xxx=xxx*allen2mm;
        yyy=yyy*allen2mm;
        plot(xxx, yyy,'.','Color', [0 0 0], 'MarkerSize', 5)
        %         plot(0,0  ,'*')
    end
end
xlim([min(x_all),3300]);
%     xlim([min(x),max(x)]);
ylim([0,max(y_all)]);
set(gca,'Ytick', [0:1000:max(y_all)])
set(gca, 'FontSize', 16)



%% Colorbar
ax2=axes('position',[position_x2(1), position_y2(1), panel_width2, panel_height2/4]);
colormap(ax2,my_colormap)
% cb1 = colorbar(ax2,'Position',[position_x2(4)+0.15, position_y2(1)+0.1, panel_width2, panel_height2/4], 'Ticks',[0, 0.5, 1],...
%     'TickLabels',[-5,0,5],'Location','NorthOutside');
cb1 = colorbar(ax2,'Position',[position_x2(1), position_y2(1)+0.15, panel_width2, panel_height2/4], 'Ticks',[0, 0.5, 1],...
    'TickLabels',[],'Location','NorthOutside');
axis off;






%% Histogram
axes('position',[position_x2(1), position_y2(1), panel_width2, panel_height2]);
bins_histogram = linspace(-max_abs,max_abs,50);
bins_histogram_centers=bins_histogram(1:end-1) + diff(bins_histogram)/2;
counts=histogram(W,bins_histogram);
counts = counts.Values/numel(W);
bar(bins_histogram_centers,counts,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5]);
hold on
plot([0,0], [0, max(counts)], '-k');
% title(sprintf('Response time of tuned neurons'));
% ylim([0 ceil(max(y))]);
xlabel(sprintf('\nPC coefficients'));
ylabel(sprintf('Probability'));
title(sprintf('PC = %d', components_2plot),'Color',[0.5 0.5 0.5]);
set(gca,'Xtick', [-max_abs, 0, max_abs])
box off



% Spatial scale
axes('position',[position_x2(1), position_y2(2), panel_width2, panel_height2]);
semilogx([distance_bins_centers(1),distance_bins_centers(end)],[0,0],'-','Color',[0.5 0.5 0.5]);
hold on;
semilogx (distance_bins_centers, rd_distance,'-k');
xlabel(['Lateral Distance' newline '(\mum)']);
ylabel(sprintf('Similarity Index'));
title([sprintf('Spatial scale \n = %d', distance_tau) ' (\mum)' newline]);
xlim([0, max(distance_bins_centers)]);
set(gca,'Xtick', [25, 250, 2500])
box off

% Spatial scale
axes('position',[position_x2(1), position_y2(3), panel_width2, panel_height2]);
semilogx([distance_bins_centers(1),distance_bins_centers(end)],[0,0],'-','Color',[0.5 0.5 0.5]);
hold on;
semilogx (distance_bins_centers, rd_distance,'-k');
xlabel(['Lateral Distance' newline '(\mum)']);
ylabel(sprintf('Similarity Index'));
title([sprintf('Spatial scale \n = %d', distance_tau) ' (\mum)' newline]);
xlim([0, max(distance_bins_centers)]);
set(gca,'Xtick', [25, 250, 2500],'Ylim', [0 max(rd_distance)])
box off

dir_current_fig =[dir_current_fig '\' 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date '\'];
if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);




