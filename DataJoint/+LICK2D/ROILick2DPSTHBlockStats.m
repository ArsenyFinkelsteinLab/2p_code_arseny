%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
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


classdef ROILick2DPSTHBlockStats < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            
            
        end
    end
end
