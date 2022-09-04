%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_first=null          : blob   # first trial in block
psth_first_odd=null          : blob   # first trial in block
psth_first_even=null          : blob   # first trial in block

psth_begin=null          : blob   # trials in the beginning of the block
psth_begin_odd=null          : blob   # trials in the beginning of the block
psth_begin_even=null          : blob   # trials in the beginning of the block

psth_mid=null            : blob   # trials in the middle of the block
psth_mid_odd=null            : blob   # trials in the middle of the block
psth_mid_even=null            : blob   # trials in the middle of the block

psth_end=null            : blob   # trials in the end of the block
psth_end_odd=null            : blob   # trials in the end of the block
psth_end_even=null            : blob   # trials in the end of the block

psth_first_stem=null     : blob   # 
psth_begin_stem=null     : blob   # 
psth_mid_stem=null       : blob   # 
psth_end_stem=null       : blob   # 

psth_first_odd_vs_even_corr   : float   # stability
psth_begin_odd_vs_even_corr   : float   # stability
psth_mid_odd_vs_even_corr     : float   # stability
psth_even_odd_vs_even_corr    : float   # stability

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


classdef ROILick2DBlockStats < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            
            
        end
    end
end
