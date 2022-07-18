%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins            : int   #
---
psth_position_concat                                  : longblob   # PSTH computed for each target position and then concatenated across all target positions. Computed for all trials, including trials with large or no reward
psth_position_concat_odd_even_corr                    : double     # 
psth_position_concat_regularreward                    : longblob   # Same as above using only regular reward trials
psth_position_concat_regularreward_odd_even_corr      : double     #
pos_x_bins_centers        : blob       #
pos_z_bins_centers        : blob       #
psthmap_time              : blob   #

%}


classdef ROILick2DContactenatedSpikes < dj.Imported
    properties
%                 keySource = (EXP2.SessionEpoch*IMG.FOV) & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock & IMG.Mesoscope;
                        keySource = (EXP2.SessionEpoch*IMG.FOV) & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock & IMG.ROISpikes;

    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            rel_data = IMG.ROISpikes & key;
            
            fr_interval = [-1, 3]; %s
%             fr_interval = [-2, 5]; % used it for the mesoscope
            fn_compute_Lick2D_concatenated(key,self, rel_data, fr_interval);
            
            
        end
    end
end