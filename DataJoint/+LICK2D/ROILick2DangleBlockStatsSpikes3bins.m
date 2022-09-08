%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
preferred_theta_first=null                : double   #
preferred_theta_first_odd=null            : double   #
preferred_theta_first_even=null           : double   #
rayleigh_length_first=null                : double   #
preferred_theta_vmises_first=null         : double   #
preferred_theta_vmises_first_odd=null     : double   #
preferred_theta_vmises_first_even=null    : double   #
goodness_of_fit_vmises_first=null         : double   #
theta_tuning_odd_even_corr_first = null   : double   #

preferred_theta_begin=null                : double   #
preferred_theta_begin_odd=null            : double   #
preferred_theta_begin_even=null           : double   #
rayleigh_length_begin=null=null           : double   #
preferred_theta_vmises_begin=null         : double   #
preferred_theta_vmises_begin_odd=null     : double   #
preferred_theta_vmises_begin_even=null    : double   #
goodness_of_fit_vmises_begin=null         : double   #
theta_tuning_odd_even_corr_begin = null   : double   #

preferred_theta_mid=null                  : double   #
preferred_theta_mid_odd=null              : double   #
preferred_theta_mid_even=null             : double   #
rayleigh_length_mid=null                  : double   #
preferred_theta_vmises_mid=null           : double   #
preferred_theta_vmises_mid_odd=null       : double   #
preferred_theta_vmises_mid_even=null      : double   #
goodness_of_fit_vmises_mid=null           : double   #
theta_tuning_odd_even_corr_mid = null     : double   #

preferred_theta_end=null                : double   #
preferred_theta_end_odd=null            : double   #
preferred_theta_end_even=null           : double   #
rayleigh_length_end=null                : double   #
preferred_theta_vmises_end=null         : double   #
preferred_theta_vmises_end_odd=null     : double   #
preferred_theta_vmises_end_even=null    : double   #
goodness_of_fit_vmises_end=null         : double   #
theta_tuning_odd_even_corr_end = null   : double   #


percent_theta_coverage_first=null          : double   #
percent_theta_coverage_first_odd=null      : double   #
percent_theta_coverage_first_even=null     : double   #

percent_theta_coverage_begin=null          : double   #
percent_theta_coverage_begin_odd=null      : double   #
percent_theta_coverage_begin_even=null     : double   #

percent_theta_coverage_mid=null            : double   #
percent_theta_coverage_mid_odd=null        : double   #
percent_theta_coverage_mid_even=null       : double   #

percent_theta_coverage_end=null            : double   #
percent_theta_coverage_end_odd=null        : double   #
percent_theta_coverage_end_even=null       : double   #
%}


classdef ROILick2DangleBlockStatsSpikes3bins< dj.Imported
    properties
    end
    methods(Access=protected)
        function makeTuples(self, key)
            %Populated by LICK2D.ROILick2DangleSpikes3bins
            
        end
    end
end