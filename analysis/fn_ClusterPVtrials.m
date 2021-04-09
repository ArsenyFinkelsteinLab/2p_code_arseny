function [cl_id, mat, order]=fn_ClusterPVtrials(data)

% if size(data,1)<20
%     n_clust =10;
% elseif  size(data,1)<50
%     n_clust =20;
% elseif size(data,1)<100
%     n_clust =50;
% elseif size(data,1)>100
%     n_clust =100;
% end

if size(data,1)<20
    n_clust =10;
elseif  size(data,1)<100
    n_clust =20;
elseif size(data,1)>100
    n_clust =100;
end

agregate_clusters_flag = 1; %itiratively agregate clusters smaller than min_cluster_percent by merging them to clusters with higest correlation to them
min_cluster_percent =5;
corr_thresh_for_merging = 0.7; %won't merge clusters that has correlation value below that


%% Hierarchical cluster analysis.
% Get distances.
d = pdist(data,'correlation');
d_sq = squareform(d);

% Linkage.
link = linkage(d,'average');

% Cluster.
cl_id = cluster(link,'MaxClust',n_clust);
% temp=inconsistent(link);
% nanmax(temp(:,4))
% cl_id = cluster(link,'cutoff',1.15);

% Cophenetic correlation.
corr_cop = cophenet(link,d)

%Plot Clusters dengrogram and pairwise distance
figure;
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

% % Figure Title
% axes('position',[position_x(1), position_y(1)+0.1, panel_width, panel_height*0.25]);
% yl = ylim(); xl = xlim();
% % text(xl(1) + diff(xl)*0.0, yl(2)*1.8, sprintf('%s      Cell-type: %s      Contains: %s units' , P.anatomy, P.unit_quality, P.Pyr_FS),'HorizontalAlignment','Left','FontSize', 10);
% axis off;

% plot dengrogram
axes('position',[position_x(1), position_y(1), 0.75, 0.2]);
[h_dend b order] = dendrogram(link,0);
set(gca,'xticklabel',[],'yticklabel',[],'xtick',[],'ytick',[])
axis off;

% Heatmap of pairwise distances.
axes('position',[position_x(1), position_y(2), 0.75, 0.6]);
mat=1-d_sq(order,order);
imagesc(mat); hold on
set(gca,'xtick',[],'ytick',[])
xlabel('Trials, Pairwise distance')
ylabel('Trials, Pairwise distance')

% Agregate clusters
cluster_percent=100*histcounts(cl_id,1:1:numel(unique(cl_id))+1)/size(data,1);
minor_clusters = find(cluster_percent<min_cluster_percent);
if agregate_clusters_flag ==1
    while ~isempty(minor_clusters) %while there are clusters to merge (i.e. there are clusters smaller than min_cluster_percent)
        clust_mean_all = [];
        for i = 1:1:numel(unique(cl_id)) %find the mean of all cluster before merging
            clust_mean_all(i,:) =   nanmean(data(cl_id==i,:),1);
        end
        corr_across_clust = corr(clust_mean_all');
        diag_idx = 1:size(corr_across_clust, 1)+1:numel(corr_across_clust);
        corr_across_clust (diag_idx) = NaN;
        
        current_minor_clusters = minor_clusters(1);
        [max_corr,cl_to_merge_with_id]= nanmax( corr_across_clust(current_minor_clusters,:));
        if max_corr < corr_thresh_for_merging
            minor_clusters(1) = [];
        else
            cl_id (cl_id==current_minor_clusters) = cl_to_merge_with_id;
            cl_id(cl_id>current_minor_clusters) =  cl_id(cl_id>current_minor_clusters) -1;
            cluster_percent=100*histcounts(cl_id,1:1:numel(unique(cl_id))+1)/size(data,1);
            minor_clusters = find(cluster_percent<min_cluster_percent & cluster_percent~=0 );
        end
    end
end

% % Labels for cluster identity on distance matrix.
% n_clust_after_merging = numel(unique(cl_id));
% col2plot = hsv(n_clust_after_merging);
% col2plot_dark = col2plot./2;
% axes('position',[position_x(2), position_y(2), 0.2, 0.6]);
% for i = 1:n_clust_after_merging
%     ind_plot = find(cl_id(order)==i);
%     plot(i*ones(1,length(ind_plot)),size(PTSH_RLconcat,1)-ind_plot,'o','color',col2plot(i,:)); hold on
% end
% set(gca,'xtick',[],'ytick',[]);
% xlim([-1 n_clust_after_merging+1]);
% ylim([0 size(PTSH_RLconcat,1)]);
% [y,bins]=hist(cl_id,[min(cl_id):max(cl_id)]);
% bar(bins,y,'FaceColor','none');
% close

close;
% % Figure Title
% ax1=axes('position',[0.3 0.9, panel_width, panel_height*0.25]);
% yl = ylim(); xl = xlim();
% text(xl(1) + diff(xl)*0.0, yl(2), sprintf('%s %s side   Training: %s    CellQuality: %s  Cell-type: %s    \n [%.2f  %.2f] s    Includes: %d units clustered\n Cophenetic correlation = %.2f' ,...
%     key.brain_area, key.hemisphere, key.training_type, key.unit_quality, key.cell_type, key.heirar_cluster_time_st, key.heirar_cluster_time_end, size(PTSH_RLconcat,1), corr_cop),'HorizontalAlignment','Left','FontSize', 10);
% axis off;
% 
% 
% 
% % Saving the figure
% %--------------------------------------------------------------------------
% if isempty(dir(dir_save_figure))
%     mkdir (dir_save_figure)
% end
% filename =[sprintf('%s%s_Training_%s_UnitQuality_%s_Type_%s__metrics' ,key.brain_area, key.hemisphere, key.training_type, key.unit_quality, key.cell_type)];
% figure_name_out=[dir_save_figure filename];
% eval(['print ', figure_name_out, ' -dtiff -cmyk -r300']);
% clf;
% 
% %% Plot original data, partitioned by cluster.
% ix1 = 1:size(PTSH_RLconcat,2)/2;
% ix2 = size(PTSH_RLconcat,2)/2+1:size(PTSH_RLconcat,2);
% t1=ix1;
% t2=ix2;
% clusters_2plot = find(cluster_percent>=min_cluster_percent);
% n_clust_2plot = numel (clusters_2plot);
% 
% [~,cluster_order] = sort (cluster_percent(clusters_2plot),'descend');
% for ii = 1:1:n_clust_2plot
%     i = clusters_2plot(ii);
%     i2plot = find(cl_id==i);
%     subplot(ceil(n_clust_2plot/sqrt(n_clust_2plot)),ceil(n_clust_2plot/sqrt(n_clust_2plot)),find(ii == cluster_order))
%     clust_mean =   nanmean(PTSH_RLconcat(i2plot,:),1);
%     
%     for j = 1:length(i2plot)
%         hold on;
%         plot(t1,PTSH_RLconcat(i2plot(j),ix1),'color',[0.7 0.7 1]); hold on
%         plot(t2,PTSH_RLconcat(i2plot(j),ix2),'color',[1 0.7 0.7]); hold on
%     end
%     r = corr([clust_mean',PTSH_RLconcat(i2plot,:)']);
%     clust_mean_corr = mean(r(2:end)); %correlation of each cell to the cluster average
%     plot(t1,clust_mean(ix1),'color',[0 0 1],'linewidth',2); hold on
%     plot(t2,clust_mean(ix2),'color',[1 0 0],'linewidth',2); hold on
%     
%     title(sprintf('%.1f of cells \n r = %.2f ',cluster_percent(i),clust_mean_corr),'FontSize',8);
%     
%     axis tight;
%     box off;
% end
% 
% % Figure Title
% ax1=axes('position',[0.3 0.9, panel_width, panel_height*0.25]);
% yl = ylim(); xl = xlim();
% percent_of_all = sum(cluster_percent(clusters_2plot));
% text(xl(1) + diff(xl)*0.0, yl(2), sprintf('%s %s side   Training: %s    CellQuality: %s  Cell-type: %s    \n [%.2f  %.2f] s    Includes: %d units    %.1f %% of total units clustered' ,...
%     key.brain_area, key.hemisphere, key.training_type, key.unit_quality, key.cell_type, key.heirar_cluster_time_st, key.heirar_cluster_time_end, size(PTSH_RLconcat,1), percent_of_all),'HorizontalAlignment','Left','FontSize', 10);
% axis off;
% 
% 
% 
% % Saving the figure
% %--------------------------------------------------------------------------
% if isempty(dir(dir_save_figure))
%     mkdir (dir_save_figure)
% end
% 
% filename =[sprintf('%s%s_Training_%s_UnitQuality_%s_Type_%s__clusters' ,key.brain_area, key.hemisphere, key.training_type, key.unit_quality, key.cell_type)];
% 
% figure_name_out=[dir_save_figure filename];
% eval(['print ', figure_name_out, ' -dtiff -cmyk -r300']);
% clf;