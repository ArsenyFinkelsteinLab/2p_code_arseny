%{
# Response trace to each photostim group, averaged across rois
-> IMG.PhotostimGroup
num_svd_components_removed      : int         # how many of the first svd components were removed
flag_within_column              : boolean     # 1 pairs within column, 0 outside of the column
response_sign                   : varchar(200)# all, excited, or inhibited pairs
response_p_val                  : double      # response p-value for inclusion. 1 means we take all pairs
---
num_pairs                       : int         #
response_trace_mean             : blob        # trial-average df over f response trace to photostimulation
response_trace_mean_1half       : blob        # trial-average df over f response trace to photostimulation
response_trace_mean_2half       : blob        # trial-average df over f response trace to photostimulation
response_trace_mean_odd         : blob        # trial-average df over f response trace to photostimulation
response_trace_mean_even        : blob        # trial-average df over f response trace to photostimulation
%}

classdef ROIResponseTraceZscore < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
        end
    end
end
