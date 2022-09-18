%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_regular_poisson             : blob   # averaged over all positions, during trials with typical reward
psth_small_poisson=null          : blob   # during no rewarded trials
psth_large_poisson=null          : blob   # during trials with large reward

psth_regular_stem_poisson        : blob   # standard error of the mean
psth_small_stem_poisson=null     : blob   # 
psth_large_stem_poisson=null     : blob   # 

psth_time_poisson                : longblob   # time vector
%}


classdef ROILick2DPSTHSpikesPoisson < dj.Imported
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
            fn_computer_Lick2DPSTH_Poisson2(key,self, rel_data,fr_interval, fr_interval_limit,flag_electric_video, time_resample_bin);
            
            %Also populates: 
            % LICK2D.ROILick2DPSTHStatsSpikesPoisson
            % LICK2D.ROILick2DPSTHBlockSpikesPoisson 
            % LICK2D.ROILick2DPSTHBlockStatsSpikesPoisson
            
        end
    end
end
