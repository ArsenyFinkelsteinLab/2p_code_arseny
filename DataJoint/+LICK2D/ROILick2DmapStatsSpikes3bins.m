%{
# Stats on 2D tuning maps
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins            : int   #
---
number_of_response_trials                 : int      # number of trials with responses
lickmap_regular_odd_vs_even_corr          : double   # 2D map correlation across odd vs even regular trials
lickmap_regular_vs_small_corr=null        : double   # 2D map correlation across regular reward versus no reward trials
lickmap_regular_vs_large_corr=null        : double   # 2D map correlation across regular reward versus large reward trials

lickmap_first_vs_begin_corr=null          : double   # 
lickmap_first_vs_mid_corr=null            : double   # 
lickmap_first_vs_end_corr=null            : double   # 
lickmap_begin_vs_end_corr=null            : double   # 
lickmap_begin_vs_mid_corr=null            : double   #
lickmap_mid_vs_end_corr=null              : double   #

psth_position_concat_regular_odd_even_corr    : double   # correlation of the PSTH concatenated across all positions, across trials with typical reward
psth_position_concat_small_odd_even_corr=null : double   #
psth_position_concat_large_odd_even_corr=null : double   #
psth_position_concat_first_odd_even_corr=null : double   #
psth_position_concat_begin_odd_even_corr=null : double   #
psth_position_concat_mid_odd_even_corr=null   : double   #
psth_position_concat_end_odd_even_corr=null   : double   #

information_per_spike_regular=null          : double   # Spatial Information per spike (Skaags et al 1996) for 2D map computed across trials with typical reward
information_per_spike_small=null            : double   # across no rewarded trials
information_per_spike_large=null            : double   # across trials with large reward
information_per_spike_first=null            : double   # across first trial in block
information_per_spike_begin=null            : double   # across trials in the beginning of the block
information_per_spike_mid=null              : double   # across trials in the middle of the block
information_per_spike_end=null              : double   # across trials in the end of the block

preferred_bin_regular=null                  : double   #
preferred_bin_small=null                    : double   #
preferred_bin_large=null                    : double   #
preferred_bin_first=null                    : double   #
preferred_bin_begin=null                    : double   #
preferred_bin_mid=null                      : double   #
preferred_bin_end=null                      : double   #

preferred_radius_regular=null               : double   #
preferred_radius_small=null                 : double   #
preferred_radius_large=null                 : double   #

field_size_regular=null                     : double   # 2D Field size at half max, expressed as percentage
field_size_small=null                       : double   #
field_size_large=null                       : double   #
field_size_first=null                       : double   # 
field_size_begin=null                       : double   # 
field_size_mid=null                         : double   # 
field_size_end=null                         : double   # 

field_size_without_baseline_regular=null    : double   # 2D Field size at half max, expressed as percentage, computed after removing the baseline firing rate
field_size_without_baseline_small=null      : double   #
field_size_without_baseline_large=null      : double   #
field_size_without_baseline_first=null      : double   #
field_size_without_baseline_begin=null      : double   #
field_size_without_baseline_mid=null        : double   #
field_size_without_baseline_end=null        : double   #

centroid_without_baseline_regular=null      : blob     # Centroid of the 2D field, computed after removing the baseline firing rate
centroid_without_baseline_small=null        : blob     #
centroid_without_baseline_large=null        : blob     #
centroid_without_baseline_first=null        : blob     #
centroid_without_baseline_begin=null        : blob     #
centroid_without_baseline_mid=null          : blob     #
centroid_without_baseline_end=null          : blob     #
 
percent_2d_map_coverage_regular             : double   #
percent_2d_map_coverage_regular_odd         : double   #
percent_2d_map_coverage_regular_even        : double   #

percent_2d_map_coverage_small=null          : double   #
percent_2d_map_coverage_small_odd=null      : double   #
percent_2d_map_coverage_small_even=null     : double   #

percent_2d_map_coverage_large=null          : double   #
percent_2d_map_coverage_large_odd=null      : double   #
percent_2d_map_coverage_large_even=null     : double   #

percent_2d_map_coverage_first=null          : double   #
percent_2d_map_coverage_first_odd=null      : double   #
percent_2d_map_coverage_first_even=null     : double   #

percent_2d_map_coverage_begin=null          : double   #
percent_2d_map_coverage_begin_odd=null      : double   #
percent_2d_map_coverage_begin_even=null     : double   #

percent_2d_map_coverage_mid=null            : double   #
percent_2d_map_coverage_mid_odd=null        : double   #
percent_2d_map_coverage_mid_even=null       : double   #

percent_2d_map_coverage_end=null            : double   #
percent_2d_map_coverage_end_odd=null        : double   #
percent_2d_map_coverage_end_even=null       : double   #

%}


classdef ROILick2DmapStatsSpikes3bins < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            % Computed in Lick2D.ROILick2DmapSpikes
        end
    end
end