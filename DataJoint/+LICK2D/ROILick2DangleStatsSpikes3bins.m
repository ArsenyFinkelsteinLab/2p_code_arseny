%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
preferred_theta_regular=null                : double   #
preferred_theta_regular_odd=null            : double   #
preferred_theta_regular_even=null           : double   #
rayleigh_length_regular                     : double   #
preferred_theta_vmises_regular              : double   #
preferred_theta_vmises_regular_odd=null     : double   #
preferred_theta_vmises_regular_even=null    : double   #
goodness_of_fit_vmises_regular              : double   #
theta_tuning_odd_even_corr_regular = null   : double   #

preferred_theta_small=null                : double   #
preferred_theta_small_odd=null            : double   #
preferred_theta_small_even=null           : double   #
rayleigh_length_small=null                : double   #
preferred_theta_vmises_small=null         : double   #
preferred_theta_vmises_small_odd=null     : double   #
preferred_theta_vmises_small_even=null    : double   #
goodness_of_fit_vmises_small=null         : double   #
theta_tuning_odd_even_corr_small = null   : double   #

preferred_theta_large=null                : double   #
preferred_theta_large_odd=null            : double   #
preferred_theta_large_even=null           : double   #
rayleigh_length_large=null                : double   #
preferred_theta_vmises_large=null         : double   #
preferred_theta_vmises_large_odd=null     : double   #
preferred_theta_vmises_large_even=null    : double   #
goodness_of_fit_vmises_large=null         : double   #
theta_tuning_odd_even_corr_large = null   : double   #

percent_theta_coverage_regular             : double   #
percent_theta_coverage_regular_odd         : double   #
percent_theta_coverage_regular_even        : double   #

percent_theta_coverage_small=null          : double   #
percent_theta_coverage_small_odd=null      : double   #
percent_theta_coverage_small_even=null     : double   #

percent_theta_coverage_large=null          : double   #
percent_theta_coverage_large_odd=null      : double   #
percent_theta_coverage_large_even=null     : double   #



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