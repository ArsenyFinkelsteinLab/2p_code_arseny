%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
reward_mean_small=null        : double   # %averaged across trial time, and cells
reward_mean_regular=null        : double   #
reward_mean_large=null          : double   #
reward_mean_pval_regular_small=null          : double   #
reward_mean_pval_regular_large=null        : double   #
reward_mean_pval_small_large=null      : double   #

reward_peak_small=null        : double   # response at peak. peak determined based on full psth, averaged across cells
reward_peak_regular=null        : double   #
reward_peak_large=null          : double   #
reward_peak_pval_regular_small=null          : double   #
reward_peak_pval_regular_large=null        : double   #
reward_peak_pval_small_large=null      : double   #
%}


classdef ROILick2DRewardStats < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            
            
        end
    end
end

