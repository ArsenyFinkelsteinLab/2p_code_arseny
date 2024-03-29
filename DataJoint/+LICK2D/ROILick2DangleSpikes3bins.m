%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
theta_tuning_regular            : blob   #
theta_tuning_regular_odd        : blob   #
theta_tuning_regular_even       : blob   #
theta_tuning_regular_vmises     : blob   #
theta_tuning_regular_stem       : blob   #

theta_tuning_small=null         : blob   #
theta_tuning_small_odd=null     : blob   #
theta_tuning_small_even=null    : blob   #
theta_tuning_small_vmises=null  : blob   #
theta_tuning_small_stem=null    : blob   #

theta_tuning_large=null         : blob   #
theta_tuning_large_odd=null     : blob   #
theta_tuning_large_even=null    : blob   #
theta_tuning_large_vmises=null  : blob   #
theta_tuning_large_stem=null    : blob   #

theta_bins_centers              : blob   #

%}


classdef ROILick2DangleSpikes3bins< dj.Imported
    properties
        keySource = ((EXP2.SessionEpoch*IMG.FOV) & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock) - IMG.Mesoscope;
%     keySource = (EXP2.SessionEpoch*IMG.FOV) & IMG.ROISpikes & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
           flag_electric_video = 1; %detect licks with electric contact or video (if available) 1 - electric, 2 - video
            rel_data = IMG.ROISpikes;
            rel_meso = IMG.Mesoscope & key;
            if rel_meso.count>0 % if its mesoscope data
                fr_interval = [0, 4]; % used it for the mesoscope
            else  % if its not mesoscope data
                fr_interval = [0, 3];
            end

            fn_computer_Lick2Dangle_3bins(key, self, rel_data, fr_interval,flag_electric_video);
            
            % % also populates
            %     self2=LICK2D.ROILick2DangleStatsSpikes3bins;
            %     self3=LICK2D.ROILick2DangleBlockSpikes3bins ;
            %     self4=LICK2D.ROILick2DangleBlockStatsSpikes3bins;

            
        end
    end
end