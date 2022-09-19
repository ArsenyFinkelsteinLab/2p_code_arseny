%{
# Delta 2D tuning maps between different reward conditions, and corresponding stats
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins                                                   : int      #
---
corr_deltamap_regular_vs_large_odd_even=null                     : double   #
corr_deltamap_regular_vs_small_odd_even=null                     : double   #

corr_deltamap_regular_vs_large_with_map_regular=null             : double   #
corr_deltamap_regular_vs_small_with_map_regular=null             : double   #

information_per_spike_deltamap_regular_vs_large=null             : double   #
information_per_spike_deltamap_regular_vs_small=null             : double   #

preferred_bin_deltamap_regular_vs_large=null                     : double   #
preferred_bin_deltamap_regular_vs_small=null                     : double   #

centroid_without_baseline_deltamap_regular_vs_large=null         : blob     #
centroid_without_baseline_deltamap_regular_vs_small=null         : blob     #

field_size_deltamap_regular_vs_large=null                        : double   # 2D Field size at half max, expressed as percentage
field_size_deltamap_regular_vs_small=null                        : double   # 2D Field size at half max, expressed as percentage

modulation_percent_regular_vs_large=null                              : double   # modulation percentage
modulation_percent_regular_vs_small=null                              : double   #


%}


classdef ROILick2DmapRewardStatsSpikes3bins < dj.Computed
    properties
    end
    methods(Access=protected)
        function makeTuples(self, key)
            % Populated by LICK2D.ROILick2DmapRewardSpikes3bins
        end
    end
end