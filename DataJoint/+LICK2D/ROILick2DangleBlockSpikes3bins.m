%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
theta_tuning_first=null         : blob   #
theta_tuning_first_odd=null     : blob   #
theta_tuning_first_even=null    : blob   #
theta_tuning_first_vmises=null  : blob   #
theta_tuning_first_stem=null    : blob   #

theta_tuning_begin=null         : blob   #
theta_tuning_begin_odd=null     : blob   #
theta_tuning_begin_even=null    : blob   #
theta_tuning_begin_vmises=null  : blob   #
theta_tuning_begin_stem=null    : blob   #

theta_tuning_mid=null         : blob   #
theta_tuning_mid_odd=null     : blob   #
theta_tuning_mid_even=null    : blob   #
theta_tuning_mid_vmises=null  : blob   #
theta_tuning_mid_stem=null    : blob   #

theta_tuning_end=null         : blob   #
theta_tuning_end_odd=null     : blob   #
theta_tuning_end_even=null    : blob   #
theta_tuning_end_vmises=null  : blob   #
theta_tuning_end_stem=null    : blob   #
%}


classdef ROILick2DangleBlockSpikes3bins< dj.Imported
    properties
          end
    methods(Access=protected)
        function makeTuples(self, key)
            
            %Populated by LICK2D.ROILick2DangleSpikes3bins
            
        end
    end
end