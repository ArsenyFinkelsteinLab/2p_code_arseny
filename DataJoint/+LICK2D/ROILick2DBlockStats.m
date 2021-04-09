%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
block_mean_first=null        : double   # %averaged across trial time, and cells
block_mean_begin=null        : double   #
block_mean_mid=null          : double   #
block_mean_end=null          : double   #
block_mean_pval_first_begin=null          : double   #
block_mean_pval_first_end=null        : double   #
block_mean_pval_begin_end=null      : double   #

block_peak_first=null        : double   # response at peak. peak determined based on full psth, averaged across cells
block_peak_begin=null        : double   #
block_peak_mid=null        : double   #
block_peak_end=null          : double   #
block_peak_pval_first_begin=null          : double   #
block_peak_pval_first_end=null        : double   #
block_peak_pval_begin_end=null      : double   #
%}


classdef ROILick2DBlockStats < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            
            
        end
    end
end
