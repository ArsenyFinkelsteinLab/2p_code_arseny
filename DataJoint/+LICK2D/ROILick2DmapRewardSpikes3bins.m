%{
# Delta 2D tuning maps between different reward conditions, and corresponding stats
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins                          : int   #
---
delta_lickmap_fr_regular_vs_large             : blob   # Delta 2D tuning map, between regular and large reward
delta_lickmap_fr_regular_vs_large_odd         : blob   # Delta 2D tuning map, between regular and large odd reward  trials
delta_lickmap_fr_regular_vs_large_even        : blob   # Delta 2D tuning map, between regular and large even reward  trials
delta_lickmap_fr_regular_vs_small             : blob   # Delta 2D tuning map, between regular and small reward
delta_lickmap_fr_regular_vs_small_odd         : blob   # Delta 2D tuning map, between regular and small odd reward  trials
delta_lickmap_fr_regular_vs_small_even        : blob   # Delta 2D tuning map, between regular and small even reward  trials
%}


classdef ROILick2DmapRewardSpikes3bins < dj.Computed
    properties
%         keySource = (EXP2.SessionEpoch*IMG.FOV) & LICK2D.ROILick2DmapPSTHSpikes3bins - IMG.Mesoscope;
        keySource = (EXP2.SessionEpoch*IMG.FOV) & LICK2D.ROILick2DmapPSTHSpikes3bins & IMG.Mesoscope;

    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            min_percent_coverage=50; % minimal coverage needed for 2D map calculation
            
            rel_meso = IMG.Mesoscope & key;
            if rel_meso.count>0 % if its mesoscope data
                fr_interval = [-2, 5]; % used it for the mesoscope
                fr_interval_limit= [-2, 5]; % for comparing firing rates between conditions and computing firing-rate maps
            else  % if its not mesoscope data
                fr_interval = [-1, 4];
                fr_interval_limit= [0, 3]; % for comparing firing rates between conditions and computing firing-rate maps
            end
            
            key_rois1 = fetch(LICK2D.ROILick2DmapPSTHSpikes3bins & key); %self
            key_rois2 = fetch(LICK2D.ROILick2DmapPSTHSpikes3bins & key); %self2
            self2=LICK2D.ROILick2DmapRewardStatsSpikes3bins;
            
            rel=LICK2D.ROILick2DmapPSTHSpikes3bins*LICK2D.ROILick2DmapSpikes3bins*LICK2D.ROILick2DmapPSTHStabilitySpikes3bins*LICK2D.ROILick2DPSTHStatsSpikes;
            D = fetch(rel & key,'psth_per_position_regular','psth_per_position_large','psth_per_position_small',...
                'psth_per_position_regular_odd', 'psth_per_position_regular_even', ...
                'psth_per_position_small_odd', 'psth_per_position_small_even',...
                'psth_per_position_large_odd','psth_per_position_large_even',...,
                'lickmap_fr_regular','lickmap_fr_small','lickmap_fr_large',...
                'reward_mean_regular','reward_mean_large','reward_mean_small');
            
            psthmap_time = fetch1(rel,'psthmap_time','LIMIT 1');
            for i_roi = 1:1:numel(key_rois1)
                
                %% Regular vs Large reward
                PSTH_bins1 = D(i_roi).psth_per_position_regular;
                PSTH_bins2 = D(i_roi).psth_per_position_large;
                PSTH_bins2_odd = D(i_roi).psth_per_position_large_odd;
                PSTH_bins2_even = D(i_roi).psth_per_position_large_even;
                
                meanFR1 = D(i_roi).reward_mean_regular;
                meanFR2 = D(i_roi).reward_mean_large;
                
                delta_MAP = fn_compute_delta_map_from_PSTH_per_bin_difference(PSTH_bins1, PSTH_bins2, psthmap_time, fr_interval_limit,meanFR1,meanFR2 );
                
                [delta_MAP_odd, delta_MAP_even, r_odd_even ] = fn_compute_delta_map_from_PSTH_per_bin_difference_odd_even(PSTH_bins1,PSTH_bins2_odd,PSTH_bins2_even, psthmap_time, fr_interval_limit, meanFR1, meanFR2, min_percent_coverage);
                
                [information_per_spike,field_size, ~, ~, centroid_without_baseline, ~, preferred_bin] ...
                    = fn_compute_generic_2D_field_stats (delta_MAP, min_percent_coverage);
                
                r_with_map_regular=corr([delta_MAP(:),D(i_roi).lickmap_fr_regular(:)],'Rows' ,'pairwise');
                r_with_map_regular=r_with_map_regular(2);
                
                key_rois1(i_roi).delta_lickmap_fr_regular_vs_large       = delta_MAP;
                key_rois1(i_roi).delta_lickmap_fr_regular_vs_large_odd   = delta_MAP_odd;
                key_rois1(i_roi).delta_lickmap_fr_regular_vs_large_even   = delta_MAP_even;
                key_rois2(i_roi).corr_deltamap_regular_vs_large_odd_even  = r_odd_even;
                key_rois2(i_roi).corr_deltamap_regular_vs_large_with_map_regular    = r_with_map_regular;
                key_rois2(i_roi).information_per_spike_deltamap_regular_vs_large = information_per_spike;
                key_rois2(i_roi).preferred_bin_deltamap_regular_vs_large     = preferred_bin;
                key_rois2(i_roi).centroid_without_baseline_deltamap_regular_vs_large       = centroid_without_baseline;
                key_rois2(i_roi).field_size_deltamap_regular_vs_large          = field_size;
                key_rois2(i_roi).modulation_percent_regular_vs_large = (100*meanFR2/meanFR1) - 100;
                
                
                %% Regular vs Small reward
                
                PSTH_bins1 = D(i_roi).psth_per_position_regular;
                PSTH_bins2 = D(i_roi).psth_per_position_small;
                PSTH_bins2_odd = D(i_roi).psth_per_position_small_odd;
                PSTH_bins2_even = D(i_roi).psth_per_position_small_even;
                
                meanFR1 = D(i_roi).reward_mean_regular;
                meanFR2 = D(i_roi).reward_mean_small;
                
                delta_MAP = fn_compute_delta_map_from_PSTH_per_bin_difference(PSTH_bins1, PSTH_bins2, psthmap_time, fr_interval_limit,meanFR1,meanFR2 );
                
                [delta_MAP_odd, delta_MAP_even, r_odd_even ] = fn_compute_delta_map_from_PSTH_per_bin_difference_odd_even(PSTH_bins1,PSTH_bins2_odd,PSTH_bins2_even, psthmap_time, fr_interval_limit, meanFR1, meanFR2, min_percent_coverage);
                
                [information_per_spike,field_size, ~, ~, centroid_without_baseline, ~, preferred_bin] ...
                    = fn_compute_generic_2D_field_stats (delta_MAP, min_percent_coverage);
                
                r_with_map_regular=corr([delta_MAP(:),D(i_roi).lickmap_fr_regular(:)],'Rows' ,'pairwise');
                r_with_map_regular=r_with_map_regular(2);
                
                
                key_rois1(i_roi).delta_lickmap_fr_regular_vs_small       = delta_MAP;
                key_rois1(i_roi).delta_lickmap_fr_regular_vs_small_odd   = delta_MAP_odd;
                key_rois1(i_roi).delta_lickmap_fr_regular_vs_small_even   = delta_MAP_even;
                key_rois2(i_roi).corr_deltamap_regular_vs_small_odd_even  = r_odd_even;
                key_rois2(i_roi).corr_deltamap_regular_vs_small_with_map_regular    = r_with_map_regular;
                key_rois2(i_roi).information_per_spike_deltamap_regular_vs_small = information_per_spike;
                key_rois2(i_roi).preferred_bin_deltamap_regular_vs_small     = preferred_bin;
                key_rois2(i_roi).centroid_without_baseline_deltamap_regular_vs_small       = centroid_without_baseline;
                key_rois2(i_roi).field_size_deltamap_regular_vs_small          = field_size;
                key_rois2(i_roi).modulation_percent_regular_vs_small = (100*meanFR2/meanFR1) - 100;
                
                
            end
            insert(self,key_rois1);
            insert(self2,key_rois2); % also populates self2=LICK2D.ROILick2DmapRewardStatsSpikes3bins;
            
        end
    end
end
