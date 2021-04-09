%{
#
-> EXP.SessionTrial
-> ANLI.EpochName
clustering_option_name       : varchar(400)      # i.e. using all signficant cells based on euclidean
---
trial_cluster_id                : int     # 
trial_cluster_group             : int     # group 1 - largest cluster, group 2 - second largest cluster etc.

%}


classdef TrialCluster < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            
        end
    end
end