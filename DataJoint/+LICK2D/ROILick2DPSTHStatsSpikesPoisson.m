%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_regular_vs_small_corr_poisson=null             : float   # correlation
psth_regular_vs_large_corr_poisson=null             : float   # correlation
psth_small_vs_large_corr_poisson=null               : float   # correlation

peaktime_psth_regular_poisson                       : float   # peak time of the psth during regular reward trials
peaktime_psth_small_poisson=null                    : float   # during no rewarded trials
peaktime_psth_large_poisson=null                    : float   # during trials with large reward

reward_mean_small_poisson=null                      : float   # %averaged across trial time
reward_mean_regular_poisson=null                    : float   #
reward_mean_large_poisson=null                      : float   #
reward_mean_pval_regular_small_poisson=null         : float   #
reward_mean_pval_regular_large_poisson=null         : float   #
reward_mean_pval_small_large_poisson=null           : float   #

reward_peak_small_poisson=null                      : float   # response at peak. peak determined based on full psth
reward_peak_regular_poisson=null                    : float   #
reward_peak_large_poisson=null                      : float   #
reward_peak_pval_regular_small_poisson=null         : float   #
reward_peak_pval_regular_large_poisson=null         : float   #
reward_peak_pval_small_large_poisson=null           : float   #
%}


classdef ROILick2DPSTHStatsSpikesPoisson < dj.Computed
    properties(SetAccess=protected)
        master=LICK2D.ROILick2DPSTHSpikes
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
        end
    end
end
