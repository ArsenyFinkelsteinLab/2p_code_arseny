%{
# Positional tuning of a neuron across time (PSTH) with each PSTH corresponding to neuronal response to a specific lick-port position in 2D
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins                          : int   #
---
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
%}


classdef ROILick2DmapPSTHStabilitySpikesExample < dj.Computed
    properties
    end
    methods(Access=protected)
        function makeTuples(self, key)
            % Computed in Lick2D.ROILick2DmapSpikesExample
        end
    end
end