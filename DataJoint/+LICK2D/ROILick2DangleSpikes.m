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


classdef ROILick2DangleSpikes< dj.Imported
    properties
    end
    methods(Access=protected)
        function makeTuples(self, key)
           
        end
    end
end