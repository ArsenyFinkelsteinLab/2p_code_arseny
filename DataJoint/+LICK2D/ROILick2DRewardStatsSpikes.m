%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
reward_mean_small=null        : float   # %averaged across trial time, and cells
reward_mean_regular=null        : float   #
reward_mean_large=null          : float   #
reward_mean_pval_regular_small=null          : float   #
reward_mean_pval_regular_large=null        : float   #
reward_mean_pval_small_large=null      : float   #

reward_peak_small=null        : float   # response at peak. peak determined based on full psth, averaged across cells
reward_peak_regular=null        : float   #
reward_peak_large=null          : float   #
reward_peak_pval_regular_small=null          : float   #
reward_peak_pval_regular_large=null        : float   #
reward_peak_pval_small_large=null      : float   #
%}


classdef ROILick2DRewardStatsSpikes < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            
            
        end
    end
end

