%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> IMG.ROI
heirar_cluster_time_st             : double         #  beginning of the time interval used for heirarchical clustering (seconds, relative to go cue).
heirar_cluster_time_end            : double         #  end of the time interval used for heirarchical clustering (seconds, relative to go cue).
---
heirar_cluster_id                  : int            # cluster to which this cell belongs. Note that this id is not unique, because clustering is done independently for different combinations of the primary keys, and the cluster_id would change accordingly
heirar_cluster_percent          : double         # percentage of cells belonging to this cluster
%}


classdef ROIHierarClusterShape < dj.Computed
    properties
        
        keySource = EXP2.Session &  EXP2.TrialLickBlock & ANLI.ROILick2DPSTH;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base =fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_save_figure = [dir_base 'Lick2D\Clusters\ClustersByShape\'];

            smooth_bins=1; % one element backward, current element, and one element forward
            
            
            %             key=[];
            time_interval(1) = -2;
            time_interval(2) =  4;
            
            clusterparam.metric='euclidean'; %euclidean or correlation
            
            clusterparam.n_clust=1000;
            clusterparam.agregate_clusters_flag = 1; %itiratively agregate clusters smaller than min_cluster_percent by merging them to clusters with higest correlation to them
            
            clusterparam.corr_thresh_across_clusters_for_merging = 0.9; %won't merge clusters that has correlation value below that
            clusterparam.corr_thresh_within_cluster_origin = 0.8; %won't merge clusters that has correlation value below that
            clusterparam.corr_thresh_within_cluster_target = 0.8;

            
            
            key.heirar_cluster_time_st = time_interval(1);
            key.heirar_cluster_time_end = time_interval(2);
            
            
            PSTH1 = cell2mat(fetchn(IMG.ROI*ANLI.ROILick2DPSTH & key , 'psth_averaged_over_all_positions', 'ORDER BY roi_number_uid'));
            %             psth_selectivity_odd_even_corr = fetchn(ANLI.ROILick2Dmap & key, 'psth_selectivity_odd_even_corr', 'ORDER BY roi_number');
            PSTH1 = movmean(PSTH1 ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');
            PSTH1_before_scaling=PSTH1;
            PSTH1 = PSTH1./nanmax(PSTH1,[],2);
            
            [~,idx]=max(PSTH1,[],2);
            [~,idxs]=sort(idx);
%             imagesc(PSTH1(idxs,:))
            
            
            psth_time = fetch1(ANLI.ROILick2DPSTH & key, 'psth_time', 'LIMIT 1');
            idx_time = psth_time>= time_interval(1) & psth_time< time_interval(2);
            
            PSTH1=PSTH1(:,idx_time);
            
            PSTH = [PSTH1];
            
            
            time_vec = 1:1:size(PSTH,2); %fetch1(ANLI.ROILick2DPSTH & key, 'time_psth', 'LIMIT 1');
            key_ROIs = fetch(IMG.ROI & key, 'ORDER BY roi_number_uid');
            
            %Perform Hierarchical Clustering
            if ~ishandle(1)
                close all;
                figure;
                set(gcf,'DefaultAxesFontName','helvetica');
                set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 30]);
                set(gcf,'PaperOrientation','portrait');
                set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            end
            [cl_id, cluster_percent] = fn_ClusterROI2(PSTH, time_vec, key, clusterparam, dir_save_figure);
            
            % Insert
            for i=1:1:size(key_ROIs,1)
                key(i).subject_id=key_ROIs(i).subject_id;
                key(i).session=key_ROIs(i).session;
                key(i).fov_num=key_ROIs(i).fov_num;
                key(i).plane_num=key_ROIs(i).plane_num;
                key(i).channel_num=key_ROIs(i).channel_num;
                key(i).roi_number=key_ROIs(i).roi_number;
                
                key(i).heirar_cluster_time_st=key(1).heirar_cluster_time_st;
                key(i).heirar_cluster_time_end=key(1).heirar_cluster_time_end;
                key(i).heirar_cluster_id = cl_id(i);
                key(i).heirar_cluster_percent = cluster_percent(cl_id(i));
                
            end
            
            insert(self,key);
            
            
        end
    end
end