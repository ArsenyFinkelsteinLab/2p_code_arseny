%{
# Response trace to each photostim group, averaged across rois
-> IMG.PhotostimGroup
num_svd_components_removed      : int         # how many of the first svd components were removed
flag_distance                   : int         # 0 (0-25um), 1 (25-100um), 2 (100-200um), 3 (>200 um)
response_sign                   : varchar(200)# all, excited, or inhibited pairs
response_p_val                  : double      # response p-value for inclusion. 1 means we take all pairs
---
num_pairs                       : int         #
response_trace_mean             : blob        #  trial-average  response trace to photostimulation with response to control sites subtracted
response_trace_mean_odd         : blob        #
response_trace_mean_even        : blob        # 
baseline_trace_mean              : blob        # trial-average response trace to control site photostimulation
responseraw_trace_mean          : blob        # trial-average  response trace to photostimulation without subtracting control sites
%} 

classdef ROIInfluenceTrace2 < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
        end
    end
end
