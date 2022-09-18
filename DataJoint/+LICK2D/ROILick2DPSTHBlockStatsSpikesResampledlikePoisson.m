%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_first_odd_vs_even_corr=null               : float   # stability
psth_begin_odd_vs_even_corr=null               : float   # stability
psth_mid_odd_vs_even_corr=null                 : float   # stability
psth_end_odd_vs_even_corr=null                 : float   # stability

psth_first_vs_begin_corr=null                : float   # correlation between conditions
psth_first_vs_mid_corr=null                  : float   # correlation
psth_first_vs_end_corr=null                  : float   # correlation
psth_begin_vs_end_corr=null                  : float   # correlation
psth_begin_vs_mid_corr=null                  : float   # correlation
psth_mid_vs_end_corr=null                    : float   # correlation

peaktime_psth_first=null                    : float   # first trials in block
peaktime_psth_begin=null                    : float   # trials in the beginning of the block
peaktime_psth_mid=null                      : float   # trials in the middle of the block
peaktime_psth_end=null                      : float   # trials in the end of the block

block_mean_first=null                       : float   # %averaged across trial time, and cells
block_mean_begin=null                       : float   #
block_mean_mid=null                         : float   #
block_mean_end=null                         : float   #
block_mean_pval_first_begin=null            : float   #
block_mean_pval_first_end=null              : float   #
block_mean_pval_begin_end=null              : float   #

block_peak_first=null                       : float   # response at peak. peak determined based on full psth, averaged across cells
block_peak_begin=null                       : float   #
block_peak_mid=null                         : float   #
block_peak_end=null                         : float   #
block_peak_pval_first_begin=null            : float   #
block_peak_pval_first_end=null              : float   #
block_peak_pval_begin_end=null              : float   #
%}


classdef ROILick2DPSTHBlockStatsSpikesResampledlikePoisson < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            
            
        end
    end
end
