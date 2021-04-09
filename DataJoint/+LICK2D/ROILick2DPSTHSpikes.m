%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth            : blob   # averaged_over_all_positions
psth_stem       : blob   #
psth_odd        : blob   #
psth_even       : blob   #

psth_first=null          : blob   # first trial in block
psth_begin=null          : blob   #  trials in the beginning of the block
psth_mid=null            : blob   # trials in the middle of the block
psth_end=null            : blob   # trials in the end of the block
psth_small=null          : blob   # during no rewarded trials
psth_regular=null        : blob   # during trials with typical reward
psth_large=null          : blob   # during trials with large reward

psth_time                            : longblob   # time vector
%}


classdef ROILick2DPSTHSpikes < dj.Imported
    properties
%         keySource = ((EXP2.SessionEpoch*IMG.FOV) & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock) - IMG.Mesoscope;
        
                keySource = (EXP2.SessionEpoch*IMG.FOV)  & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            rel_data = IMG.ROISpikes;
%             fr_interval = [-1, 3]; %s
            fr_interval = [-2, 5]; % used it for the mesoscope
            fn_computer_Lick2DPSTH(key,self, rel_data,fr_interval);
            
        end
    end
end
