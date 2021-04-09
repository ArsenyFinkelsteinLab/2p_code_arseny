function lick2D_map_onFOV_clusters_preferred_non_preferred_meso(key, flag_plot_clusters_individually)
close all;
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 

    
    key.number_of_bins=3;
    key.fr_interval_start=-1000;
    key.fr_interval_end=2000;

if nargin<2
    flag_plot_clusters_individually=0;
    % key.subject_id = 463195;
    % key.session =3;
    
    % key.subject_id = 462455;
    % key.session =2;
    
    % key.subject_id = 462458;
    % key.session =12;
    key.subject_id = 463189;
    key.session =4;
    
    % key.subject_id = 463190;
    % key.session =1;
    
    key.number_of_bins=3;
    key.fr_interval_start=-1000;
    key.fr_interval_end=2000;
    % key.fr_interval_start=-1000;
    % key.fr_interval_end=0;
    % session_date = fetch1(EXP2.Session & key,'session_date');
end



smooth_bins=1; % one element backward, current element, and one element forward

flag_all_or_signif=1;  % 1 all cells, 2 signif cells in 2D lick maps, 3 signf cells in PSTH motor responses
filename=[];
dir_current_fig = [dir_base  '\Lick2D\population\onFOV_clusters_preferred_non_preferred_meso\bins' num2str(key.number_of_bins) '\'];
if flag_all_or_signif ==1
    rel= (ANLI.ROILick2DPSTH * ANLI.ROILick2Dselectivity*IMG.PlaneCoordinates * ANLI.ROIHierarClusterShapeAndSelectivity )* IMG.ROI  & IMG.ROIGood & key ;
elseif flag_all_or_signif ==2
    %     rel= (ANLI.ROILick2DPSTH  * ANLI.ROILick2Dselectivity*IMG.PlaneCoordinates * ANLI.ROIHierarClusterShapeAndSelectivity )* IMG.ROI  & IMG.ROIGood & key  & (ANLI.ROILick2Dmap  & 'lickmap_odd_even_corr>=-1');
    rel= (IMG.PlaneCoordinates * ANLI.ROIHierarClusterShapeAndSelectivity )* IMG.ROI  & IMG.ROIGood & key  & (ANLI.ROILick2Dmap  & 'lickmap_odd_even_corr>=-1');
    
    filename=['signif_2Dlick'];
end

session_date = fetch1(EXP2.Session & key,'session_date');

filename = [filename 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date]



dir_current_fig_original = dir_current_fig;
filename_original = filename;


% rel = rel & 'heirar_cluster_percent>2' & (ANLI.IncludeROI4 & 'number_of_events>25');
% rel = rel & 'heirar_cluster_percent>2' & 'psth_selectivity_odd_even_corr>0.5';
rel = rel & 'heirar_cluster_percent>=1';


%Graphics
%---------------------------------
figure;
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



horizontal_dist2=0.07;
vertical_dist2=0.12;

panel_width2=0.05;
panel_height2=0.08;



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
M=fetch(rel ,'*');
M=struct2table(M);
number_of_planes = unique(M.plane_num);
roi_cluster_id = M.heirar_cluster_id;
heirar_cluster_percent = M.heirar_cluster_percent;
[unique_cluster_id,ia,ic]  = unique(roi_cluster_id);
heirar_cluster_percent = heirar_cluster_percent(ia);
[B,I]  = sort(heirar_cluster_percent,'descend');
heirar_cluster_percent = heirar_cluster_percent(I);
unique_cluster_id = unique_cluster_id(I);
for ic=1:1:numel(roi_cluster_id)
    roi_cluster_renumbered(ic) = find(unique_cluster_id ==roi_cluster_id(ic));
end

roi_cluster_renumbered_original = roi_cluster_renumbered;

my_colormap=hsv(numel(unique_cluster_id));
my_colormap(1,:)=[0.5 0.5 0.5];
my_colormap(2,:)=[0 0 0];
my_colormap(3,:)=[1 0 0];
my_colormap(4,:)=[0 0 1];
my_colormap(5,:)=[0 0.8 0];
my_colormap(6,:)=[0.94 0.9 0];
my_colormap(7,:)=[0 0.8 0.8];
my_colormap(8,:)=[1 0 1];

my_colormap(100,:)=[0.94 0.93 0.93];


for i_clus = 1:1:min([numel(unique_cluster_id),10])
    roi_cluster_renumbered=roi_cluster_renumbered_original;
    if flag_plot_clusters_individually==1
        roi_cluster_renumbered(roi_cluster_renumbered~=i_clus)=100;
        
        dir_current_fig = dir_current_fig_original;
        filename  = filename_original;
    end
    
    % All planes
    ax1=axes('position',[position_x1(1), position_y1(1), panel_width1*4, panel_height1*3]);
    
    % imagesc(x_dim, y_dim, mean_img_enhanced);
    % colormap(ax1,gray);
    % hold on;
    
    x = M.roi_centroid_x + M.x_pos_relative;
    y = M.roi_centroid_y + M.y_pos_relative;
    hold on;
    for i_roi=1:1:size(M,1)
        plot(x(i_roi)*pix2dist, y(i_roi)*pix2dist,'.','Color',my_colormap(roi_cluster_renumbered(i_roi),:),'MarkerSize',7)
    end
    axis xy
    set(gca,'YDir','reverse')
    % title(sprintf('Motor map, left ALM\n n = %d tuned neurons (%.1f%%) \n',size(M,1), 100*size(M,1)/rel_all_good_cells.count   ));
    % set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, 800], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,800],'TickLength',[0.01,0],'TickDir','out')
    axis tight
    axis equal
    xlabel('Anterior - Posterior (\mum)');
    ylabel('Lateral - Medial (\mum)');
    title(sprintf('anm%d session %d,  Total planes = %d \nCluster #%d', key.subject_id,key.session, number_of_planes, i_clus));
    
    
    
    
    %% Plot clusters
    
    PSTH1= M.psth_preferred;
    PSTH1 = movmean(PSTH1 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
    PSTH1_before_scaling=PSTH1;
    PSTH1 = PSTH1./nanmax(PSTH1,[],2);
    
    PSTH2= M.psth_non_preferred;
    PSTH2 = movmean(PSTH2 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
    PSTH2 = PSTH2./nanmax(PSTH2,[],2);
    
    PSTH3= M.selectivity;
    PSTH3 = movmean(PSTH3 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
    PSTH3 = PSTH3./nanmax(PSTH1_before_scaling,[],2);

    
    for ic=1:1:min([numel(unique_cluster_id),10])
        psth_cluster(ic,:)=mean(PSTH1(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
        axes('position',[position_x2(ic), position_y2(ic), panel_width2, panel_height2]);
        hold on;
        plot([0 0],[0,1],'-k');
        plot(M.psth_time(1,:),psth_cluster(ic,:))
        title(sprintf('C%d %.1f %%',ic, heirar_cluster_percent(ic)),'Color',my_colormap(ic,:))
        ylim([0, 1]);
        xlim([-2,5]);
        
        psth_cluster(ic,:)=mean(PSTH2(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
        axes('position',[position_x2(ic), position_y2(ic)-0.12, panel_width2, panel_height2]);
        hold on;
        plot([0 0],[0,1],'-k');
        plot(M.psth_time(1,:),psth_cluster(ic,:))
        %     title(sprintf('Cluster %d %.1f %%',ic, heirar_cluster_percent(ic)),'Color',my_colormap(ic,:))
        %     ylim([0, 1]);
        xlim([-2,5]);
        
        psth_cluster(ic,:)=mean(PSTH3(M.heirar_cluster_id == unique_cluster_id(ic),:),1);
        axes('position',[position_x2(ic), position_y2(ic)-0.25, panel_width2, panel_height2]);
        hold on;
        plot([0 0],[0,1],'-k');
        plot(M.psth_time(1,:),psth_cluster(ic,:))
        %     title(sprintf('Cluster %d %.1f %%',ic, heirar_cluster_percent(ic)),'Color',my_colormap(ic,:))
        %     ylim([0, 1]);
        xlim([-2,5]);
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
    eval(['print ', figure_name_out, ' -dtiff  -r300']);
    % eval(['print ', figure_name_out, ' -dpdf -r200']);
    
    if flag_plot_clusters_individually==1
        clf
    else
        break;
    end
    
end

