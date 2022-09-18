%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_first_vs_begin_corr_poisson=null                : float   # correlation between conditions
psth_first_vs_mid_corr_poisson=null                  : float   # correlation
psth_first_vs_end_corr_poisson=null                  : float   # correlation
psth_begin_vs_end_corr_poisson=null                  : float   # correlation
psth_begin_vs_mid_corr_poisson=null                  : float   # correlation
psth_mid_vs_end_corr_poisson=null                    : float   # correlation

peaktime_psth_first_poisson=null                    : float   # first trials in block
peaktime_psth_begin_poisson=null                    : float   # trials in the beginning of the block
peaktime_psth_mid_poisson=null                      : float   # trials in the middle of the block
peaktime_psth_end_poisson=null                      : float   # trials in the end of the block

block_mean_first_poisson=null                       : float   # %averaged across trial time, and cells
block_mean_begin_poisson=null                       : float   #
block_mean_mid_poisson=null                         : float   #
block_mean_end_poisson=null                         : float   #
block_mean_pval_first_begin_poisson=null            : float   #
block_mean_pval_first_end_poisson=null              : float   #
block_mean_pval_begin_end_poisson=null              : float   #

block_peak_first_poisson=null                       : float   # response at peak. peak determined based on full psth, averaged across cells
block_peak_begin_poisson=null                       : float   #
block_peak_mid_poisson=null                         : float   #
block_peak_end_poisson=null                         : float   #
block_peak_pval_first_begin_poisson=null            : float   #
block_peak_pval_first_end_poisson=null              : float   #
block_peak_pval_begin_end_poisson=null              : float   #
%}


classdef ROILick2DPSTHBlockStatsSpikesPoisson < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            
            
        end
    end
end
