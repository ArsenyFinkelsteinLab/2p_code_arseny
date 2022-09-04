%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins            : int    #
---
psth_preferred_regular            : blob   # psth averaged across the preferred 2D map position/positions, computed across trials with typical reward
psth_preferred_regular_odd        : blob   # same as above for odd trials
psth_preferred_regular_even       : blob   # same as above for even trials
psth_non_preferred_regular        : blob   # psth averaged across the non-preferred 2D map position/positions, computed across trials with typical reward
selectivity_regular               : blob   # psth preferred - non-preferred, computed across trials with typical reward
selectivity_regular_odd           : blob   # same as above for odd trials
selectivity_regular_even          : blob   # same as above for even trials
selectivity_small=null            : blob   # across no rewarded trials
selectivity_large=null            : blob   # across trials with large reward
selectivity_first=null            : blob   # across first trials in block
selectivity_begin=null            : blob   # across trials in the beginning of the block
selectivity_mid=null              : blob   # across trials in the middle of the block
selectivity_end=null              : blob   # across trials in the end of the block
psth_preferred_regular_stem       : blob   # standard error of the mean
psth_non_preferred_regular_stem   : blob   # standard error of the mean
%}


classdef ROILick2DSelectivitySpikes < dj.Computed
    properties
    end
    methods(Access=protected)
        function makeTuples(self, key)
        % Computed in Lick2D.ROILick2DmapSpikes
        end
    end
end
