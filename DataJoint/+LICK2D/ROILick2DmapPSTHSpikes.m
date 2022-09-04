%{
# Positional tuning of a neuron across time (PSTH) with each PSTH corresponding to neuronal response to a specific lick-port position in 2D
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins                          : int   #
---
psth_per_position_regular               : longblob   # PSTH per position, averaged across trials with typical reward
psth_per_position_small=null            : longblob   # averaged across no rewarded trials
psth_per_position_large=null            : longblob   # averaged across trials with large reward
psth_per_position_first=null            : longblob   # averaged across first trial in block
psth_per_position_begin=null            : longblob   # averaged across trials in the beginning of the block
psth_per_position_mid=null              : longblob   # averaged across trials in the middle of the block
psth_per_position_end=null              : longblob   # averaged across trials in the end of the block

psth_per_position_regular_odd           : longblob   # averaged across trials with typical reward  -- only odd trials
psth_per_position_regular_even          : longblob   # averaged across trials with typical reward  -- only even trials
psth_per_position_small_odd=null        : longblob   # 
psth_per_position_small_even=null       : longblob   # 
psth_per_position_large_odd=null        : longblob   # 
psth_per_position_large_even=null       : longblob   # 
psth_per_position_first_odd=null        : longblob   # 
psth_per_position_first_even=null       : longblob   # 
psth_per_position_begin_odd=null        : longblob   # 
psth_per_position_begin_even=null       : longblob   # 
psth_per_position_mid_odd=null          : longblob   # 
psth_per_position_mid_even=null         : longblob   # 
psth_per_position_end_odd=null          : longblob   # 
psth_per_position_end_even=null         : longblob   # 


psth_per_position_regular_stem          : longblob   # standard error of the mean, across trials with typical reward
psth_per_position_small_stem=null       : longblob   # standard error of the mean, across trials with small reward
psth_per_position_large_stem=null       : longblob   # standard error of the mean, across trials with large reward
psth_per_position_first_stem=null       : longblob   # standard error of the mean, across first trial in block
psth_per_position_begin_stem=null       : longblob   # standard error of the mean, across trials in the beginning of the block
psth_per_position_mid_stem=null         : longblob   # standard error of the mean, across trials in the middle of the block
psth_per_position_end_stem=null         : longblob   # standard error of the mean, across trials in the end of the block
psthmap_time                            : blob       #
%}


classdef ROILick2DmapPSTHSpikes < dj.Computed
    properties
    end
    methods(Access=protected)
        function makeTuples(self, key)
            % Computed in Lick2D.ROILick2DmapSpikes
        end
    end
end