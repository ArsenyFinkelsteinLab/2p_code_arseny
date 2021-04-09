%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins            : int   #
---
psth_preferred_odd_even_corr=null       : double     #
selectivity_odd_even_corr=null          : double     #
peaktime_preferred=null               : double   # peak time of the psth
peaktime_preferred_odd=null           : double   #
peaktime_preferred_even=null          : double   #

peaktime_selectivity               : double   # peak time of the psth
peaktime_selectivity_odd           : double   #
peaktime_selectivity_even          : double   #
peaktime_selectivity_first=null          : double   # first trial in block
peaktime_selectivity_begin=null    : double   #  trials in the beginning of the block
peaktime_selectivity_mid=null      : double   # trials in the middle of the block
peaktime_selectivity_end=null      : double   # trials in the end of the block
peaktime_selectivity_small=null    : double   # during no rewarded trials
peaktime_selectivity_regular=null  : double   # during trials with typical reward
peaktime_selectivity_large=null    : double   # during trials with large reward

%}


classdef ROILick2DSelectivityStats < dj.Part
    properties(SetAccess=protected)
        master=LICK2D.ROILick2DSelectivity
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
        end
    end
end