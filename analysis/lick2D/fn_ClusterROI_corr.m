function [cl_id, cluster_percent]=fn_ClusterROI_corr(M, key, clusterparam, dir_save_figure, flag_plot)



min_cluster_percent =1;
min_cluster_agregate =100;

if nargin>3
    n_clust = clusterparam.n_clust;
    agregate_clusters_flag  = clusterparam.agregate_clusters_flag;
    corr_thresh_across_clusters_for_merging = clusterparam.corr_thresh_across_clusters_for_merging;
    corr_thresh_within_cluster_origin = clusterparam.corr_thresh_within_cluster_origin;
    corr_thresh_within_cluster_target = clusterparam.corr_thresh_within_cluster_target;
    metric = clusterparam.metric;
else
    n_clust=2000;
    agregate_clusters_flag = 1; %itiratively agregate clusters smaller than min_cluster_percent by merging them to clusters with higest correlation to them
    corr_thresh_across_clusters_for_merging = 0.9; %won't merge clusters that has correlation value below that
    corr_thresh_within_cluster_origin = 0.8; %won't merge clusters that has correlation value below that
    corr_thresh_within_cluster_target = 0.8;
    metric='euclidean'; %euclidean or correlation
end


%
% corr_thresh_across_clusters_for_merging = 0.9; %won't merge clusters that has correlation value below that
% corr_thresh_within_cluster = 0.75; %won't merge clusters that has correlation value below that

% n_clust=200;
% agregate_clusters_flag = 1; %itiratively agregate clusters smaller than min_cluster_percent by merging them to clusters with higest correlation to them
% min_cluster_percent =1;
% min_cluster_agregate =100;

% corr_thresh_across_clusters_for_merging = 0.8; %won't merge clusters that has correlation value below that
% corr_thresh_within_cluster_origin = 0.9; %won't merge clusters that has correlation value below that
% corr_thresh_within_cluster_target = 0.8;

% corr_thresh_across_clusters_for_merging = 0.9; %won't merge clusters that has correlation value below that
% corr_thresh_within_cluster_origin = 0.8; %won't merge clusters that has correlation value below that
% corr_thresh_within_cluster_target = 0.8;

%% Hierarchical cluster analysis.
try 
    M = gpuArray(M);
    d = pdist(M,metric);
    M=gather(M);
    d_sq = squareform(d);
    
    d=gather(d);
    d_sq=gather(d_sq);
catch %in case GPU is out of memory
    M=gather(M);
    d = pdist(M,metric);
    d_sq = squareform(d);
    disp('GPU out of memory');
end



%     d = pdist(M,metric);
%     d_sq = squareform(d);


% Linkage.
link = linkage(d,'average');

% Cluster.
cl_id = cluster(link,'MaxClust',n_clust);
% temp=inconsistent(link);
% nanmax(temp(:,4))
% cl_id = cluster(link,'cutoff',1.15);

% Cophenetic correlation.
corr_cop = cophenet(link,d)

% Plot Clusters dengrogram and pairwise distance
fff = figure("Visible",false);
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);

panel_width=0.3;
panel_height=0.3;
horizontal_distance=0.75;
vertical_distance=0.6;

position_x(1)=0.05;
position_x(2)=position_x(1)+horizontal_distance;
position_y(1)=0.7;
position_y(2)=position_y(1)-vertical_distance;

% Figure Title
axes('position',[position_x(1), position_y(1)+0.1, panel_width, panel_height*0.25]);
yl = ylim(); xl = xlim();
% text(xl(1) + diff(xl)*0.0, yl(2)*1.8, sprintf('%s      Cell-type: %s      Contains: %s units' , P.anatomy, P.unit_quality, P.Pyr_FS),'HorizontalAlignment','Left','FontSize', 10);
axis off;

% plot dengrogram
axes('position',[position_x(1), position_y(1), 0.75, 0.2]);
[h_dend bar order] = dendrogram(link,0);
set(gca,'xticklabel',[],'yticklabel',[],'xtick',[],'ytick',[])
axis off;

% Heatmap of pairwise distances.
axes('position',[position_x(1), position_y(2), 0.75, 0.6]);
imagesc(1-d_sq(order,order)); hold on
set(gca,'xtick',[],'ytick',[])
xlabel('Neurons, Pairwise distance')
ylabel('Neurons, Pairwise distance')




%% agregate clusters

if agregate_clusters_flag ==1
    n_clust_before_merging=1;
    n_clust_after_merging=0;
    while n_clust_before_merging> n_clust_after_merging
        n_clust_before_merging = numel(unique(cl_id)); %before agregation
        [cl_id] = function_agregate_clusters(M, cl_id, min_cluster_agregate, corr_thresh_across_clusters_for_merging, corr_thresh_within_cluster_origin, corr_thresh_within_cluster_target);
        n_clust_after_merging = numel(unique(cl_id)); %after agregation
    end
end
n_clust_after_merging= numel(unique(cl_id)); %after agregationl
% Resort clusters from large to small
cluster_percent=100*histcounts(cl_id,1:1:(numel(unique(cl_id))+1))/size(M,1);
[B,I] = sort(cluster_percent,'descend');

cl_id_new = cl_id;
for  ii = 1:1:numel(I)
    idxxx = find(cl_id==I(ii));
    cl_id_new(idxxx)=ii;
end
cl_id=cl_id_new;

cluster_percent=100*histcounts(cl_id,1:1:(numel(unique(cl_id))+1))/size(M,1);

if flag_plot==1
    
    clust_mean=zeros(numel(unique(cl_id)),size(M,1));
    clust_mean_corr=zeros(numel(unique(cl_id)),1);
    parfor ii = 1:1:numel(unique(cl_id))
        idxxx = find(cl_id==ii);
        clust_mean(ii,:) =   nanmean(M(idxxx,:),1);
        r = corr([clust_mean(ii,:)',M(idxxx,:)']);
        clust_mean_corr(ii) = mean(r(1,2:end)); %correlation of each cell to the cluster average
    end
    
    
    
    
    % Labels for cluster identity on distance matrix.
    
    col2plot = hsv(n_clust_after_merging);
    col2plot_dark = col2plot./2;
    axes('position',[position_x(2), position_y(2), 0.2, 0.6]);
    for i = 1:n_clust_after_merging
        ind_plot = find(cl_id(order)==i);
        plot(i*ones(1,length(ind_plot)),size(M,1)-ind_plot,'o','color',col2plot(i,:)); hold on
    end
    set(gca,'xtick',[],'ytick',[]);
    xlim([-1 n_clust_after_merging+1]);
    ylim([0 size(M,1)]);
    
    % Figure Title
    ax1=axes('position',[0.3 0.9, panel_width, panel_height*0.25]);
    yl = ylim(); xl = xlim();
    if  isfield(key,'heirar_cluster_id')
        text(xl(1) + diff(xl)*0.0, yl(2), sprintf('Includes: %d units clustered\n Cophenetic correlation = %.2f, splits = %d \n Cluster = %d  splits subclust = %d' ,...
            size(M,1), corr_cop, key.n_clust, key.heirar_cluster_id,  n_clust),'HorizontalAlignment','Left','FontSize', 10);
    else
        text(xl(1) + diff(xl)*0.0, yl(2), sprintf('Includes: %d units clustered\n Cophenetic correlation = %.2f, splits = %d' ,...
            size(M,1), corr_cop, key.n_clust),'HorizontalAlignment','Left','FontSize', 10);
    end
    
    axis off;
    
    
    
    if strcmp(key.session_epoch_type,'spont_only')
        session_epoch_label = 'Spont';
    elseif strcmp(key.session_epoch_type,'behav_only')
        session_epoch_label = 'Behav';
    end
    
    % Saving the figure
    %--------------------------------------------------------------------------
    if isempty(dir(dir_save_figure))
        mkdir (dir_save_figure)
    end
    if isfield(key,'subject_id')
        if  isfield(key,'heirar_cluster_id')
            filename =['anm' num2str(key.subject_id) 's' num2str(key.session) '_' session_epoch_label '_' metric(1:4) '_agregate' num2str(agregate_clusters_flag) '_splits' num2str(key.n_clust)  'cluster' num2str(key.heirar_cluster_id) '_splits_subclust' num2str(n_clust)];
        else
            filename =['anm' num2str(key.subject_id) 's' num2str(key.session) '_' session_epoch_label '_' metric(1:4) '_agregate' num2str(agregate_clusters_flag) '_splits' num2str(n_clust)];
            
        end
    else
        filename = ['all_' metric '_agregate' num2str(agregate_clusters_flag)];
    end
    figure_name_out=[dir_save_figure filename];
    eval(['print ', figure_name_out, ' -dtiff -cmyk -r200']);
end
close all;