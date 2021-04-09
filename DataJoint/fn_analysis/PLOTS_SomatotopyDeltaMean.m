function PLOTS_SomatotopyDeltaMean(key, dir_current_fig, rel_data)
close all;
rel_roi = (IMG.ROI - IMG.ROIBad) & key;

rel = rel_roi* rel_data*IMG.PlaneCoordinates & key;



key2 = rmfield(key,'session_epoch_number');
rel_control = rel_roi* rel_data*IMG.PlaneCoordinates &  key2 & (EXP2.SessionEpochSomatotopy & 'sensory_stimulation_area="control"');

if rel_control.count ==0
    rel_control = (rel_roi* rel_data*IMG.PlaneCoordinates &  key2) - EXP2.SessionEpochSomatotopy;
end

session_date = fetch1(EXP2.Session & key,'session_date');
session_epoch_label=fetch1(EXP2.SessionEpochSomatotopy & key,'sensory_stimulation_area');

filename = [ 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date '_' session_epoch_label]

%Graphics
%---------------------------------
fff = figure("Visible",false);
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 11 8]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

horizontal_dist=0.25;
vertical_dist=0.25;

panel_width1=0.8;
panel_height1=0.8;

position_x1(1)=0.15;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;

position_y1(1)=0.15;
position_y1(end+1)=position_y1(end)-vertical_dist*1.1;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;



horizontal_dist2=0.07;
vertical_dist2=0.12;

panel_width2=0.05;
panel_height2=0.08;



% pix2dist= fetch1(IMG.Parameters & 'parameter_name="fov_size_microns_z1.1"', 'parameter_value')/fetch1(IMG.FOV & key, 'fov_x_size');
pix2dist=1;

%% MAPS
% mean_img_enhanced = fetch1(IMG.Plane & key & 'plane_num=1','mean_img_enhanced');
% x_dim = [0:1:(size(mean_img_enhanced,1)-1)]*pix2dist;
% y_dim = [0:1:(size(mean_img_enhanced,2)-1)]*pix2dist;
M=fetch(rel ,'*');
M=struct2table(M);
number_of_planes = numel(unique(M.plane_num));

M2=fetch(rel_control ,'*');
M2=struct2table(M2);

x1 = M.mean_dff;
x2 = M2.mean_dff;
number_of_events=(x1 - x2)./(x1 + x2);
bins = [-inf,linspace(prctile(number_of_events,5),prctile(number_of_events,95),100),inf];

cmap = jet(length(bins));
colormap (cmap);
number_of_events(isnan(number_of_events))=0;

[~,~,bins_idx]=histcounts(number_of_events,bins);


% All planes
ax1=axes('position',[position_x1(1), position_y1(1), panel_width1, panel_height1]);

% imagesc(x_dim, y_dim, mean_img_enhanced);
% colormap(ax1,gray);
% hold on;

x = M.roi_centroid_x + M.x_pos_relative;
x=x/0.75;
y = M.roi_centroid_y + M.y_pos_relative;
y=y/0.5;


% aligning relative to bregma
bregma_x_mm=1000*fetchn(IMG.Bregma & key,'bregma_x_cm');
if ~isempty(bregma_x_mm)
    bregma_y_mm=1000*fetchn(IMG.Bregma & key,'bregma_y_cm');

    x=x-[max(x) - bregma_x_mm]; % anterior posterior
    y=y-min(y)+bregma_y_mm; % medial lateral
    
end



hold on;
for i_roi=1:1:size(M,1)
    plot(x(i_roi)*pix2dist, y(i_roi)*pix2dist,'.','Color',cmap(bins_idx(i_roi),:),'MarkerSize',5)
end
axis xy
set(gca,'YDir','reverse')
% title(sprintf('Motor map, left ALM\n n = %d tuned neurons (%.1f%%) \n',size(M,1), 100*size(M,1)/rel_all_good_cells.count   ));
% set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, 800], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,800],'TickLength',[0.01,0],'TickDir','out')
axis tight
axis equal
xlabel('Anterior - Posterior (\mum)');
ylabel('Lateral - Medial (\mum)');
title(sprintf('anm %d session %d %s', key.subject_id, key.session,  session_epoch_label));


%% PLOT ALLEN MAP
allen2mm=1000*3.2/160;
if ~isempty(bregma_x_mm)
    allenDorsalMapSM_Musalletal2019 = load('allenDorsalMapSM_Musalletal2019.mat');
    edgeOutline = allenDorsalMapSM_Musalletal2019.dorsalMaps.edgeOutline;
    
    bregma_x_allen = allenDorsalMapSM_Musalletal2019.dorsalMaps.bregmaScaled(2);
    bregma_y_allen = allenDorsalMapSM_Musalletal2019.dorsalMaps.bregmaScaled(1);
    for i_a = 1:1:numel(edgeOutline)
        hold on
        %         pgon = polyshape(-1*([edgeOutline{i_a}(:,1)]-bregma_y_allen),[edgeOutline{i_a}(:,2)]-bregma_x_allen);
        xxx = -1*([edgeOutline{i_a}(:,1)]-bregma_x_allen);
        yyy= [edgeOutline{i_a}(:,2)]-bregma_y_allen;
        
        xxx=xxx*allen2mm;
        yyy=yyy*allen2mm;
        plot(xxx, yyy,'.')
        %         plot(0,0  ,'*')
    end
end
xlim([min(x),3500]);
%     xlim([min(x),max(x)]);
ylim([0,max(y)]);



if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r150']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);
