%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_regular             : blob   # averaged over all positions, during trials with typical reward
psth_regular_odd         : blob   # averaged over all positions, during odd trials with typical reward
psth_regular_even        : blob   # averaged over all positions, during odd trials with typical reward

psth_small=null          : blob   # during no rewarded trials
psth_small_odd=null      : blob   # during no rewarded trials
psth_small_even=null     : blob   # during no rewarded trials

psth_large=null          : blob   # during trials with large reward
psth_large_odd=null      : blob   # during trials with large reward
psth_large_even=null     : blob   # during trials with large reward

psth_regular_stem        : blob   # standard error of the mean
psth_small_stem=null     : blob   # 
psth_large_stem=null     : blob   # 

psth_time                : longblob   # time vector
%}


classdef ROILick2DPSTHSpikesResampledlikePoisson < dj.Imported
    properties
        keySource = ((EXP2.SessionEpoch*IMG.FOV) & IMG.ROI & IMG.ROISpikes & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock) - IMG.Mesoscope;
%                 keySource = (EXP2.SessionEpoch*IMG.FOV)  & IMG.ROI & IMG.ROISpikes & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
           flag_electric_video = 1; %detect licks with electric contact or video (if available) 1 - electric, 2 - video
            rel_data = IMG.ROISpikes;
            rel_temp = IMG.Mesoscope & key;
            if rel_temp.count>0 % if its mesoscope data
                fr_interval = [-2, 5]; % used it for the mesoscope
                fr_interval_limit= [-2, 5]; % for comparing firing rates between conditions and computing firing-rate maps
            else  % if its not mesoscope data
                fr_interval = [-1, 4];
                fr_interval_limit= [0, 3]; % for comparing firing rates between conditions and computing firing-rate maps
            end
            time_resample_bin=0.5;
            fn_computer_Lick2DPSTH(key,self, rel_data,fr_interval, fr_interval_limit, flag_electric_video, time_resample_bin);
            
            %Also populates: 
            %LICK2D.ROILick2DPSTHStatsSpikesResampledlikePoisson
            %LICK2D.ROILick2DPSTHBlockSpikesResampledlikePoisson
            %LICK2D.ROILick2DPSTHBlockStatsSpikesResampledlikePoisson
            
        end
    end
end
