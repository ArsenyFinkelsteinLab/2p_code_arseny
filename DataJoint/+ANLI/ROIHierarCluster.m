%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> IMG.ROI
heirar_cluster_time_st             : double         #  beginning of the time interval used for heirarchical clustering (seconds, relative to go cue).
heirar_cluster_time_end            : double         #  end of the time interval used for heirarchical clustering (seconds, relative to go cue).
---
heirar_cluster_id                  : int            # cluster to which this cell belongs. Note that this id is not unique, because clustering is done independently for different combinations of the primary keys, and the cluster_id would change accordingly
heirar_cluster_percent          : double         # percentage of cells belonging to this cluster
%}


classdef ROIHierarCluster < dj.Computed
    properties
        
        keySource = EXP2.Session &  EXP2.TrialLickBlock;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            smooth_bins=1; % one element backward, current element, and one element forward
            
            
            key=[];
            key.heirar_cluster_time_st = -3;
            key.heirar_cluster_time_end = 3;
            
                        PSTH = cell2mat(fetchn(IMG.ROI*ANLI.ROILick2Dmap & key & 'psth_selectivity_odd_even_corr>=-1', 'selectivity', 'ORDER BY roi_number_uid'));

            PSTH = cell2mat(fetchn(ANLI.ROILick2DPSTH*IMG.ROI & key, 'psth_averaged_over_all_positions', 'ORDER BY roi_number_uid'));
            PSTH = movmean(PSTH ,[smooth_bins smooth_bins], 2,'omitnan', 'Endpoints','shrink');

            PSTH = PSTH./nanmax(PSTH,[],2);
            [~,idx]=max(PSTH,[],2);
            
            [~,idxs]=sort(idx);
            imagesc(PSTH(idxs,:))
            
            time_psth = fetch1(ANLI.ROILick2DPSTH & key, 'time_psth', 'LIMIT 1');
            key_ROIs = fetch(IMG.ROI*ANLI.ROILick2Dmap & key, 'ORDER BY roi_number_uid');
            
            %Perform Hierarchical Clustering
            if ~ishandle(1)
                close all;
                figure;
                set(gcf,'DefaultAxesFontName','helvetica');
                set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 30]);
                set(gcf,'PaperOrientation','portrait');
                set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            end
            [cl_id, cluster_percent] = fn_ClusterROI2(PSTH, time_psth, key);
            
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