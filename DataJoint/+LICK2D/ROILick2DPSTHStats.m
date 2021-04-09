%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_odd_even_corr              : double   #
peaktime_psth                   : double   # peak time of the psth
peaktime_psth_odd               : double   #
peaktime_psth_even              : double   #

peaktime_psth_first=null        : double   # first trial in block
peaktime_psth_begin=null        : double   #  trials in the beginning of the block
peaktime_psth_mid=null          : double   # trials in the middle of the block
peaktime_psth_end=null          : double   # trials in the end of the block
peaktime_psth_small=null        : double   # during no rewarded trials
peaktime_psth_regular=null      : double   # during trials with typical reward
peaktime_psth_large=null        : double   # during trials with large reward

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
