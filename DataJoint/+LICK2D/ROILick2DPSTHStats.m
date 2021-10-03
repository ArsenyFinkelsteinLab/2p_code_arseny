%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_odd_even_corr              : float   #
peaktime_psth                   : float   # peak time of the psth
peaktime_psth_odd               : float   #
peaktime_psth_even              : float   #

peaktime_psth_first=null        : float   # first trial in block
peaktime_psth_begin=null        : float   #  trials in the beginning of the block
peaktime_psth_mid=null          : float   # trials in the middle of the block
peaktime_psth_end=null          : float   # trials in the end of the block
peaktime_psth_small=null        : float   # during no rewarded trials
peaktime_psth_regular=null      : float   # during trials with typical reward
peaktime_psth_large=null        : float   # during trials with large reward

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
