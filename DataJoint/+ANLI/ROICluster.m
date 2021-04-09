%{
#
-> IMG.ROI
-> ANLI.EpochName
clustering_option_name       : varchar(400)      # i.e. using all signficant cells based on euclidean
---
roi_cluster_id        : int            # cluster to which this cell belongs. Note that this id is not unique, because clustering is done independently for different combinations of the primary keys, and the cluster_id would change accordingly

%}


classdef ROICluster < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            
        end
    end
end