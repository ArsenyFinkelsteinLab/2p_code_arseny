function [cl_id] = function_agregate_clusters(PTSH, cl_id, min_cluster_agregate, corr_thresh_across_clusters_for_merging, corr_thresh_within_cluster_origin, corr_thresh_within_cluster_target)

% Agregate clusters
cluster_percent=100*histcounts(cl_id,1:1:(numel(unique(cl_id))+1))/size(PTSH,1);


[B,I] = sort(cluster_percent,'ascend');

cl_id_new = cl_id;
for  ii = 1:1:numel(I)
    idxxx = find(cl_id==I(ii));
    cl_id_new(idxxx)=ii;
end
cl_id=cl_id_new;
cluster_percent=100*histcounts(cl_id,1:1:(numel(unique(cl_id))+1))/size(PTSH,1);
minor_clusters = find(cluster_percent<min_cluster_agregate);


for ii = 1:1:numel(unique(cl_id))
    idxxx = find(cl_id==ii);
    clust_mean(ii,:) =   nanmean(PTSH(idxxx,:),1);
    r = corr([clust_mean(ii,:)',PTSH(idxxx,:)']);
    clust_mean_corr(ii) = mean(r(1,2:end)); %correlation of each cell to the cluster average
end
counter=1;

while ~isempty(minor_clusters) %while there are clusters to merge (i.e. there are clusters smaller than min_cluster_percent)
    clust_mean_all=[];
    for i = 1:1:numel(unique(cl_id)) %find the mean of all cluster before merging
        clust_mean_all(i,:) =   nanmean(PTSH(cl_id==i,:),1);
    end
    corr_across_clust = corr(clust_mean_all');
    diag_idx = 1:size(corr_across_clust, 1)+1:numel(corr_across_clust);
    corr_across_clust (diag_idx) = NaN;
    
    %         cluster_percent=100*histcounts(cl_id,1:1:numel(unique(cl_id))+1)/size(PTSH,1)
    %         clust_mean_corr
    
    current_minor_clusters = minor_clusters(1);
    [max_corr,cl_to_merge_with_idx]= nanmax( corr_across_clust(current_minor_clusters,current_minor_clusters:1:end));
    cl_to_merge_with_id = cl_to_merge_with_idx + current_minor_clusters -1;
    if max_corr < corr_thresh_across_clusters_for_merging || clust_mean_corr(1)<=corr_thresh_within_cluster_origin
        minor_clusters(1) = [];
        clust_mean_corr(1) = [];
        counter = counter +1;
    else
        if clust_mean_corr(cl_to_merge_with_idx)<corr_thresh_within_cluster_target
            minor_clusters(1) = [];
            clust_mean_corr(1) = [];
            counter = counter +1;
            continue
        end
        if size(clust_mean_all,1)==current_minor_clusters
            break
        end
        cl_id (cl_id==current_minor_clusters) = cl_to_merge_with_id;
        
        idxxx = find(cl_id==cl_to_merge_with_id);
        clust_mean_temp =   nanmean(PTSH(idxxx,:),1);
        r = corr([clust_mean_temp',PTSH(idxxx,:)']);
        clust_mean_corr(cl_to_merge_with_idx) = mean(r(1,2:end)); %correlation of each cell to the cluster average
        %             clust_mean_corr(current_minor_clusters)=[];
        
        cl_id(cl_id>current_minor_clusters) =  cl_id(cl_id>current_minor_clusters) -1;
        %             cluster_percent=100*histcounts(cl_id,1:1:numel(unique(cl_id))+1)/size(PTSH_RLconcat,1);
        minor_clusters(1) = [];
        minor_clusters=minor_clusters-1;
        cluster_percent=100*histcounts(cl_id,1:1:(numel(unique(cl_id))+1))/size(PTSH,1);
        
        clust_mean_corr(1) = [];
        
        
        %             minor_clusters = find(cluster_percent<min_cluster_agregate & cluster_percent~=0 );
        
        
    end
end




