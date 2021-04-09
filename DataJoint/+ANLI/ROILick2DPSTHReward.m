%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
fr_interval_start1         : int   # %in miliseconds, window to compute the firing rate change
fr_interval_end1           : int   # %in miliseconds, window to compute the firing rate change
fr_interval_start2         : int   # %in miliseconds, window to compute the firing rate change
fr_interval_end2           : int   # %in miliseconds, window to compute the firing rate change
---
psth_averaged_over_all_positions_regular     : longblob   #
psth_averaged_over_all_positions_large     : longblob   #
psth_averaged_over_all_positions_small     : longblob   #
%}


classdef ROILick2DPSTHReward < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialRewardSize;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            key.fr_interval_start1 = -1000;
            key.fr_interval_end1 = 0;
            key.fr_interval_start2 = 0;
            key.fr_interval_end2 = 1000;
            
            fn_computer_Lick2DPSTH_reward(key,self);
            
            
        end
    end
end
