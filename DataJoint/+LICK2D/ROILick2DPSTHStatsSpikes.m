%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_regular_odd_vs_even_corr               : float   # stability
psth_small_odd_vs_even_corr=null                 : float   # stability
psth_large_odd_vs_even_corr=null                 : float   # stability

psth_regular_vs_small_corr=null                  : float   # correlation
psth_regular_vs_large_corr=null                  : float   # correlation
psth_small_vs_large_corr=null                  : float   # correlation

peaktime_psth_regular                       : float   # peak time of the psth during regular reward trials
peaktime_psth_regular_odd                   : float   #
peaktime_psth_regular_even                  : float   #

peaktime_psth_small=null                    : float   # during no rewarded trials
peaktime_psth_large=null                    : float   # during trials with large reward

reward_mean_small=null                      : float   # %averaged across trial time
reward_mean_regular=null                    : float   #
reward_mean_large=null                      : float   #
reward_mean_pval_regular_small=null         : float   #
reward_mean_pval_regular_large=null         : float   #
reward_mean_pval_small_large=null           : float   #

reward_peak_small=null                      : float   # response at peak. peak determined based on full psth
reward_peak_regular=null                    : float   #
reward_peak_large=null                      : float   #
reward_peak_pval_regular_small=null         : float   #
reward_peak_pval_regular_large=null         : float   #
reward_peak_pval_small_large=null           : float   #
%}


classdef ROILick2DPSTHStatsSpikes < dj.Computed
    properties(SetAccess=protected)
        master=LICK2D.ROILick2DPSTHSpikes
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
        end
    end
end
