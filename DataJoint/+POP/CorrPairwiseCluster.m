%{
# ROI responses to each photostim group
-> EXP2.SessionEpoch
heirar_cluster_id           : int            # cluster to which this cell belongs. Note that this id is not unique, because clustering is done independently for different combinations of the primary keys, and the cluster_id would change accordingly. 0 means all cells
---
roi_corr_all                : longblob               # pearson coeff
%}


classdef CorrPairwiseCluster < dj.Computed
    properties
        keySource = EXP2.SessionEpoch  & IMG.ROI & IMG.ROIdeltaF & IMG.Mesoscope
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            x_all=fetchn(IMG.ROI &key,'roi_centroid_x','ORDER BY roi_number');
            y_all=fetchn(IMG.ROI &key,'roi_centroid_y','ORDER BY roi_number');
            
            x_pos_relative=fetchn(IMG.ROI*IMG.PlaneCoordinates &key,'x_pos_relative','ORDER BY roi_number');
            y_pos_relative=fetchn(IMG.ROI*IMG.PlaneCoordinates &key,'y_pos_relative','ORDER BY roi_number');
            
            x_all = x_all + x_pos_relative;
            y_all = y_all + y_pos_relative;
            x_all = x_all/0.75;
            y_all = x_all/0.5;

            roi_list=fetchn(IMG.ROIdeltaF &key,'roi_number','ORDER BY roi_number');
            chunk_size=500;
            for i_chunk=1:chunk_size:numel(roi_list)
                roi_interval = [i_chunk, i_chunk+chunk_size];
                if roi_interval(end)>numel(roi_list)
                    roi_interval(end) = numel(roi_list)+1;
                end
                temp_Fall=cell2mat(fetchn(IMG.ROIdeltaF & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
                temp_roi_num=fetchn(IMG.ROIdeltaF & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'roi_number','ORDER BY roi_number');
                Fall(temp_roi_num,:)=temp_Fall;
            end
            
            
           [rho,~]=corr(Fall');

           clust_id = 0:1:5; 
           heirar_cluster_id = fetchn(POP.ROIClusterCorr & key & 'n_clust=5', 'heirar_cluster_id', 'ORDER BY roi_number');
           
           for ic=1:1:numel(clust_id)
               if ic==0
               r_clust =  rho;
               else
               idx = heirar_cluster_id == ic;
               r_clust =  rho(idx,idx);
               end
               key.heirar_cluster_id =ic ;
               r_clust = tril(r_clust);
               r_clust(r_clust==0)=[];
               key.roi_corr_all = r_clust;
               insert(self,key);
           end
           
        end
    end
end

