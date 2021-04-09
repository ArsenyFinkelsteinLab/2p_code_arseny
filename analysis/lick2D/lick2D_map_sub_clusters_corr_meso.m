function lick2D_map_sub_clusters_corr_meso(key, flag_plot_clusters_individually,  M_all)
close all;
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 


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

filename=[];
dir_current_fig = [dir_base  '\Lick2D\brain_maps\clusters_sub_corr\'];
rel = IMG.ROI &  (POP.ROISubClusterCorr & key)  & IMG.ROIGood ;


rel1 = ((IMG.ROI*POP.ROISubClusterCorr*IMG.PlaneCoordinates) & IMG.ROIGood & key);
rel2 = ANLI.ROILick2DPSTH * ANLI.ROILick2Dselectivity & rel;


session_date = fetch1(EXP2.Session & key,'session_date');

session_epoch_type = fetch1(EXP2.SessionEpoch & key, 'session_epoch_type');
if strcmp(session_epoch_type,'spont_only')
    session_epoch_label = 'Spontaneous';
elseif strcmp(session_epoch_type,'behav_only')
    session_epoch_label = 'Behavior';
end

filename =['anm' num2str(key.subject_id) 's' num2str(key.session) '_' session_epoch_label '_splits' num2str(key.n_clust)  '_Cluster' num2str(key.heirar_cluster_id) '_subsplits' num2str(key.n_sub_clust)];



dir_current_fig_original = dir_current_fig;
filename_original = filename;
filename_original = [filename_original ];

% rel = rel & 'heirar_cluster_percent>2' & (ANLI.IncludeROI4 & 'number_of_events>25');
% rel = rel & 'heirar_cluster_percent>2' & 'psth_selectivity_odd_even_corr>0.5';


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
if isempty(M)
    key
    disp('No data');
    return
end
M=struct2table(M);
number_of_planes = max(M.plane_num);
roi_cluster_id = M.heirar_sub_cluster_id;
heirar_cluster_percent = M.heirar_sub_cluster_percent;
[unique_cluster_id,ia,ic]  = unique(roi_cluster_id);

roi_cluster_id_original = roi_cluster_id;
heirar_cluster_percent = heirar_cluster_percent(ia);
% [B,I]  = sort(heirar_cluster_percent,'descend');
% heirar_cluster_percent = heirar_cluster_percent(I);
% unique_cluster_id = unique_cluster_id(I);
% for ic=1:1:numel(roi_cluster_id)
%     roi_cluster_renumbered(ic) = find(unique_cluster_id ==roi_cluster_id(ic));
% end


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

my_colormap(11:end,:)=repmat([0.94 0.93 0.93], numel(unique_cluster_id)-10,1);

x_all = [M_all.roi_centroid_x]' + [M_all.x_pos_relative]';
y_all = [M_all.roi_centroid_y]' + [M_all.y_pos_relative]';
x_all=x_all/0.75;
y_all=y_all/0.5;

marker_size=10;
factor_axis=1;
if number_of_planes>1
    factor_axis = 1.3;
    marker_size=9;
end
% All planes
ax1=axes('position',[position_x1(1), position_y1(1), panel_width1*3/factor_axis, panel_height1*3/factor_axis]);
hold on
for i_roi=1:1:size(M_all,1)
    plot(x_all(i_roi)*pix2dist, y_all(i_roi)*pix2dist,'.','Color',[0.9 0.9 0.9],'MarkerSize',marker_size)
end

num_clust_2_plot = min([numel(unique_cluster_id),10]);
for i_clus = 1:1:num_clust_2_plot
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
    percent_clustered = 100*sum(roi_cluster_id<=num_clust_2_plot)/size(M_all,1);
    title(sprintf('%s \n anm%d session %d,  Total planes = %d\nsplits = %d  Cluster %d nsubsplits = %d\n%.1f%% cells shown', session_epoch_label, key.subject_id,key.session, number_of_planes, key.n_clust, key.heirar_cluster_id  ,key.n_sub_clust,  percent_clustered));
    
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
        
        
        for ic=1:1:num_clust_2_plot
            psth_cluster(ic,:)=mean(PSTH1(roi_cluster_id == unique_cluster_id(ic),:),1);
            axes('position',[position_x2(ic), position_y2(ic), panel_width2, panel_height2]);
            hold on;
            plot([0 0],[0,1],'-k');
            plot(psth_time(1,:),psth_cluster(ic,:))
            title(sprintf('C%d %.1f %%',ic, heirar_cluster_percent(ic)),'Color',my_colormap(ic,:))
            ylim([0, 1]);
            xlim([-2,5]);
            if ic ==1
                ylabel('Preferred');
            end
            
            psth_cluster(ic,:)=mean(PSTH2(roi_cluster_id == unique_cluster_id(ic),:),1);
            axes('position',[position_x2(ic), position_y2(ic)-0.08, panel_width2, panel_height2]);
            hold on;
            plot([0 0],[0,1],'-k');
            plot(psth_time(1,:),psth_cluster(ic,:))
            %     title(sprintf('Cluster %d %.1f %%',ic, heirar_cluster_percent(ic)),'Color',my_colormap(ic,:))
            %     ylim([0, 1]);
            xlim([-2,5]);
            if ic ==1
                ylabel('Non-prefer.');
            end
            
            psth_cluster(ic,:)=mean(PSTH3(roi_cluster_id == unique_cluster_id(ic),:),1);
            axes('position',[position_x2(ic), position_y2(ic)-0.16, panel_width2, panel_height2]);
            hold on;
            plot([0 0],[0,1],'-k');
            plot(psth_time(1,:),psth_cluster(ic,:))
            %     title(sprintf('Cluster %d %.1f %%',ic, heirar_cluster_percent(ic)),'Color',my_colormap(ic,:))
            %     ylim([0, 1]);
            xlim([-2,5]);
            if ic ==1
                ylabel('Selectivity');
                xlabel('Time to Lick (s)');
                
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

