%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_regular_odd_vs_even_corr   : float   # stability
psth_small_odd_vs_even_corr     : float   # stability
psth_large_odd_vs_even_corr     : float   # stability



peaktime_psth_regular           : float   # peak time of the psth during regular reward trials
peaktime_psth_regular_odd       : float   #
peaktime_psth_regular_even      : float   #

peaktime_psth_small=null        : float   # during no rewarded trials
peaktime_psth_large=null        : float   # during trials with large reward

peaktime_psth_first=null        : float   # first trials in block
peaktime_psth_begin=null        : float   # trials in the beginning of the block
peaktime_psth_mid=null          : float   # trials in the middle of the block
peaktime_psth_end=null          : float   # trials in the end of the block

%}


classdef ROILick2DPSTHStats < dj.Part
    properties(SetAccess=protected)
        master=LICK2D.ROILick2DPSTH
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
        end
    end
end
