%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
preferred_theta_regular=null                : double   #
rayleigh_length_regular=null                : double   #
preferred_theta_vmises_regular              : double   #
goodness_of_fit_vmises_regular              : double   #
theta_tuning_odd_even_corr_regular = null   : double   #

preferred_theta_small=null                  : double   #
rayleigh_length_small=null                  : double   #
preferred_theta_vmises_small                : double   #
goodness_of_fit_vmises_small                : double   #
theta_tuning_odd_even_corr_small = null     : double   #

preferred_theta_large=null                  : double   #
rayleigh_length_large=null                  : double   #
preferred_theta_vmises_large                : double   #
goodness_of_fit_vmises_large                : double   #
theta_tuning_odd_even_corr_large = null     : double   #

theta_bins_centers                 : blob   #

%}


classdef ROILick2DangleStatsSpikes3bins< dj.Imported
    properties
    end
    methods(Access=protected)
        function makeTuples(self, key)
            %Populated by LICK2D.ROILick2DangleSpikes3bins
            
        end
    end
end