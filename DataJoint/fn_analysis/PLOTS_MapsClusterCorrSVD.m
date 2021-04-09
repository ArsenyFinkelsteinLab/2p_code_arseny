function PLOTS_MapsClusterCorrSVD(key, flag_plot_clusters_individually,  M_all, dir_current_fig)
close all;

n_clust = key.n_clust;
threshold_for_event= key.threshold_for_event;
if isfield(key,'num_svd_components_removed')
    svd_removed = key.num_svd_components_removed;
else
    svd_removed=0;
end

smooth_bins=1; % one element backward, current element, and one element forward

flag_all_or_signif=1;  % 1 all cells, 2 signif cells in 2D lick maps, 3 signf cells in PSTH motor responses
filename=[];

rel = IMG.ROI &  ((POP.ROIClusterCorrSVD& key) & 'heirar_cluster_percent>=1')  & IMG.ROIGood ;
rel1 = ((IMG.ROI*POP.ROIClusterCorrSVD*IMG.PlaneCoordinates) & IMG.ROIGood & key) & 'heirar_cluster_percent>=1';


rel2 = LICK2D.ROILick2DPSTH * LICK2D.ROILick2DSelectivity & rel;


session_date = fetch1(EXP2.Session & key,'session_date');

session_epoch_type = fetch1(EXP2.SessionEpoch & key, 'session_epoch_type');
if strcmp(session_epoch_type,'spont_only')
    session_epoch_label = 'Spontaneous';
elseif strcmp(session_epoch_type,'behav_only')
    session_epoch_label = 'Behavior';
end

filename = [filename 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date '_' session_epoch_label num2str(key.session_epoch_number) '_nsplits' num2str(n_clust) sprintf('threshold%.0f', 100*threshold_for_event) sprintf('_SVDsremoved%d',svd_removed)]



dir_current_fig_original = dir_current_fig;
filename_original = filename;
filename_original = [filename_original ];

% rel = rel & 'heirar_cluster_percent>2' & (ANLI.IncludeROI4 & 'number_of_events>25');
% rel = rel & 'heirar_cluster_percent>2' & 'psth_selectivity_odd_even_corr>0.5';


%Graphics
%---------------------------------
fff = figure("Visible",false);
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

horizontal_dist=0.25;
vertical_dist=0.25;

panel_width1=0.2;
panel_height1=0.2;

position_x1(1)=0.1;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;

position_y1(1)=0.05;
position_y1(end+1)=position_y1(end)-vertical_dist*1.1;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;



horizontal_dist2=0.09;
vertical_dist2=0.12;

panel_width2=0.07;
panel_height2=0.06;



position_x2(1)=0.05;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;

position_y2(1)=0.85;
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);
position_y2(end+1)=position_y2(1);

position_y2(end+1)=position_y2(1)-vertical_dist2;
position_y2(end+1)=position_y2(1)-vertical_dist2;
position_y2(end+1)=position_y2(1)-vertical_dist2;
position_y2(end+1)=position_y2(1)-vertical_dist2;
position_y2(end+1)=position_y2(1)-vertical_dist2;
position_y2(end+1)=position_y2(1)-vertical_dist2;
position_y2(end+1)=position_y2(1)-vertical_dist2;
position_y2(end+1)=position_y2(1)-vertical_dist2;


% pix2dist= fetch1(IMG.Parameters & 'parameter_name="fov_size_microns_z1.1"', 'parameter_value')/fetch1(IMG.FOV & key, 'fov_x_size');
pix2dist=1;

%% MAPS
% mean_img_enhanced = fetch1(IMG.Plane & key & 'plane_num=1','mean_img_enhanced');
% x_dim = [0:1:(size(mean_img_enhanced,1)-1)]*pix2dist;
% y_dim = [0:1:(size(mean_img_enhanced,2)-1)]*pix2dist;
M=fetch(rel1 ,'*', 'ORDER BY roi_number');
M=struct2table(M);
number_of_planes = max(M.plane_num);
roi_cluster_id = M.heirar_cluster_id;
heirar_cluster_percent = M.heirar_cluster_percent;
[unique_cluster_id,ia,ic]  = unique(roi_cluster_id);
heirar_cluster_percent = heirar_cluster_percent(ia);
roi_cluster_id_original = roi_cluster_id;

% [B,I]  = sort(heirar_cluster_percent,'descend');
% heirar_cluster_percent = heirar_cluster_percent(I);
% unique_cluster_id = unique_cluster_id(I);
% for ic=1:1:numel(roi_cluster_id)
%     roi_cluster_renumbered(ic) = find(unique_cluster_id ==roi_cluster_id(ic));
% end
%
% roi_cluster_renumbered_original = roi_cluster_renumbered;

my_colormap=hsv(numel(unique_cluster_id));
my_colormap(1,:)=[0.5 0.5 0.5];
my_colormap(2,:)=[0 0 0];
my_colormap(3,:)=[1 0 0];
my_colormap(4,:)=[0 0 1];
my_colormap(5,:)=[0 0.8 0];
my_colormap(6,:)=[0.94 0.9 0];
my_colormap(7,:)=[0 0.8 0.8];
my_colormap(8,:)=[1 0 1];
my_colormap(9,:)=[0.9100    0.4100    0.1700];
my_colormap(10,:)=[0 1 1];

my_colormap(100,:)=[0.94 0.93 0.93];
% my_colormap(11:end,:)=repmat([0.94 0.93 0.93], numel(unique_cluster_id)-10,1);

x_all = [M_all.roi_centroid_x]' + [M_all.x_pos_relative]';
y_all = [M_all.roi_centroid_y]' + [M_all.y_pos_relative]';
x_all=x_all/0.75;
y_all=y_all/0.5;

marker_size=7;
factor_axis=1;
if number_of_planes>1
    factor_axis = 1.3;
    marker_size=7;
end
% All planes
ax1=axes('position',[position_x1(1), position_y1(1), panel_width1*3/factor_axis, panel_height1*3/factor_axis]);
hold on
parfor i_roi=1:1:size(M_all,1)
    plot(x_all(i_roi)*pix2dist, y_all(i_roi)*pix2dist,'.','Color',[0.9 0.9 0.9],'MarkerSize',marker_size)
end

for i_clus = 1:1:min([numel(unique_cluster_id),10])
    roi_cluster_id=roi_cluster_id_original;
    if flag_plot_clusters_individually==1
        roi_cluster_id(roi_cluster_id~=i_clus)=100;
        
        dir_current_fig = dir_current_fig_original;
        filename  = filename_original;
    end
    
    
    % imagesc(x_dim, y_dim, mean_img_enhanced);
    % colormap(ax1,gray);
    % hold on;
    
    x = M.roi_centroid_x + M.x_pos_relative;
    y = M.roi_centroid_y + M.y_pos_relative;
    x=x/0.75;
    y=y/0.5;
    
    hold on;
    for i_roi=1:1:size(M,1)
        plot(x(i_roi)*pix2dist, y(i_roi)*pix2dist,'.','Color',my_colormap(roi_cluster_id(i_roi),:),'MarkerSize',marker_size)
    end
    axis xy
    set(gca,'YDir','reverse')
    % title(sprintf('Motor map, left ALM\n n = %d tuned neurons (%.1f%%) \n',size(M,1), 100*size(M,1)/rel_all_good_cells.count   ));
    % set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, 800], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,800],'TickLength',[0.01,0],'TickDir','out')
    axis tight
    axis equal
    xlabel('Anterior - Posterior (\mum)');
    ylabel('Lateral - Medial (\mum)');
    percent_clustered = 100*numel(roi_cluster_id)/size(M_all,1);
    title(sprintf('%s %d\n anm%d session %d,  Total planes = %d\nsplits = %d, threshold =%.2f %.1f%% cells shown\n%d SVD components removed', session_epoch_label, key.session_epoch_number, key.subject_id,key.session, number_of_planes, n_clust, threshold_for_event, percent_clustered,svd_removed));
    
    
    % Plot Plane frames
    fov_num =  unique(fetchn(IMG.FOV & key,'fov_num'));
    for i_f = 1:1:numel(fov_num)
        keyfov.fov_num = fov_num(i_f);
        ROI_rect= fetch(IMG.FOV*IMG.PlaneCoordinates & key & keyfov,'*','LIMIT 1');
        x1=ROI_rect.x_pos_relative/0.75;
        x2=ROI_rect.fov_x_size/0.75 + x1;
        y1=ROI_rect.y_pos_relative/0.5;
        y2=ROI_rect.fov_y_size/0.5 + y1;
        plot([x1,x1],[y1,y2],'-k');
    end
    
    
    %% Plot clusters
    try
        psth_time = fetch1(rel2, 'psth_time', 'LIMIT 1');
        PSTH1=cell2mat(fetchn(rel2 ,'psth_preferred', 'ORDER BY roi_number'));
        PSTH2=cell2mat(fetchn(rel2 ,'psth_non_preferred', 'ORDER BY roi_number'));
        PSTH3=cell2mat(fetchn(rel2 ,'selectivity', 'ORDER BY roi_number'));
        
        
        PSTH1 = movmean(PSTH1 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
        PSTH1_before_scaling=PSTH1;
        PSTH1 = PSTH1./nanmax(PSTH1,[],2);
        
        PSTH2 = movmean(PSTH2 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
        PSTH2 = PSTH2./nanmax(PSTH2,[],2);
        
        PSTH3 = movmean(PSTH3 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
        PSTH3 = PSTH3./nanmax(PSTH1_before_scaling,[],2);
        
        xl=[-2,3]; %xlimit
        for ic=1:1:min([numel(unique_cluster_id),10])
            
            %Preferred
            axes('position',[position_x2(ic), position_y2(ic), panel_width2, panel_height2]);
            psth_cluster(ic,:)=mean(PSTH1(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
            hold on;
            plot([0 0],[0,1],'-k');
            plot(psth_time(1,:),psth_cluster(ic,:))
            title(sprintf('C%d %.1f %%',ic, heirar_cluster_percent(ic)),'Color',my_colormap(ic,:))
            yl = [0, 1];
            ylim(yl);
            xlim(xl);
            if ic ==1
                ylabel('Preferred');
                set(gca,'YTick',yl ,'XTick',[-2,0,2], 'XTickLabel',[]);
            else
                set(gca,'YTick',[],'XTick',[-2,0,2] ,'XTickLabel',[]);
            end
            
            %Non-preferred
            axes('position',[position_x2(ic), position_y2(ic)-0.08, panel_width2, panel_height2]);
            psth_cluster(ic,:)=mean(PSTH2(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
            hold on;
            plot([0 0],[0,1],'-k');
            plot(psth_time(1,:),psth_cluster(ic,:))
            %     title(sprintf('Cluster %d %.1f %%',ic, heirar_cluster_percent(ic)),'Color',my_colormap(ic,:))
            yl = [0, 1];
            ylim(yl);
            xlim(xl);
            if ic ==1
                ylabel('Non-prefer.');
                set(gca,'YTick',yl,'XTick',[-2,0,2] ,'XTickLabel',[]);
            else
                set(gca,'YTick',[],'XTick',[-2,0,2] ,'XTickLabel',[]);
            end
            
            %Selectivity
            axes('position',[position_x2(ic), position_y2(ic)-0.16, panel_width2, panel_height2]);
            psth_cluster(ic,:)=mean(PSTH3(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
            hold on;
            plot([0 0],[0,1],'-k');
            plot(psth_time(1,:),psth_cluster(ic,:))
            %     title(sprintf('Cluster %d %.1f %%',ic, heirar_cluster_percent(ic)),'Color',my_colormap(ic,:))
            yl = [0, 0.5];
            ylim(yl);
            xlim(xl);
            if ic ==1
                ylabel('Selectivity');
                xlabel('Time to Lick (s)');
                set(gca,'YTick',yl,'XTick',[-2,0,2]);
                
            else
                set(gca,'YTick',[],'XTick',[-2,0,2]);
            end
        end
        
    catch
        disp('No behavioral data');
    end
    
    if flag_plot_clusters_individually==1
        dir_current_fig = [dir_current_fig 'indiv_clusters\'];
        filename = [filename '_cluster' num2str(i_clus)];
    else
        dir_current_fig = [dir_current_fig 'all_clusters_superimposed\'];
    end
    
    if isempty(dir(dir_current_fig))
        mkdir (dir_current_fig)
    end
    %
    figure_name_out=[ dir_current_fig filename];
    eval(['print ', figure_name_out, ' -dtiff  -r150']);
    % eval(['print ', figure_name_out, ' -dpdf -r200']);
    
    if flag_plot_clusters_individually==1
        clf
    else
        break;
    end
    
end

