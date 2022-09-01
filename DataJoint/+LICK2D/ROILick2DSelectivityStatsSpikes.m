%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins            : int   #
---
psth_preferred_regular_odd_even_corr=null  : double   #
selectivity_regular_odd_even_corr=null     : double   #
peaktime_preferred_regular=null            : double   # peak time of the psth in the preferred 2D map position/positions, computed across trials with typical reward
peaktime_preferred_regular_odd=null        : double   # same as above for odd trials
peaktime_preferred_regular_even=null       : double   # same as above for even trials
peaktime_selectivity_regular               : double   # psth preferred - non-preferred, computed across trials with typical reward
peaktime_selectivity_regular_odd           : double   # same as above for odd trials
peaktime_selectivity_regular_even          : double   # same as above for even trials
peaktime_selectivity_small=null            : double   # across no rewarded trials
peaktime_selectivity_large=null            : double   # across trials with large reward
peaktime_selectivity_first=null            : double   # across first trials in block
peaktime_selectivity_begin=null            : double   # across trials in the beginning of the block
peaktime_selectivity_mid=null              : double   # across trials in the middle of the block
peaktime_selectivity_end=null              : double   # across trials in the end of the block

%}


classdef ROILick2DSelectivityStatsSpikes < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
                        % Computed in Lick2D.ROILick2DmapSpikes
        end
    end
end