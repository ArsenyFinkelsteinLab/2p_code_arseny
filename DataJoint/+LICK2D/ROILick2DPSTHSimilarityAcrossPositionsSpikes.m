%{
# Similarity of the PSTH across positions 
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins                                  : int   #
---
psth_corr_across_position_regular=null          : double   # correlation of the PSTH across positions, averaged across regular reward trials
psth_corr_across_position_small=null            : double   # averaged across no rewarded trials
psth_corr_across_position_large=null            : double   # averaged across trials with large reward
psth_corr_across_position_first=null            : double   # averaged across first trial in block
psth_corr_across_position_begin=null            : double   # averaged across trials in the beginning of the block
psth_corr_across_position_mid=null              : double   # averaged across trials in the middle of the block
psth_corr_across_position_end=null              : double   # averaged across trials in the end of the block

%}


classdef ROILick2DPSTHSimilarityAcrossPositionsSpikes < dj.Computed
    properties
        keySource = (EXP2.SessionEpoch*IMG.FOV) & LICK2D.ROILick2DmapPSTHSpikes3bins - IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            min_modulation = 0.25; %every PSTH below this modulation is ignored
            
            key_roi = fetch(LICK2D.ROILick2DmapPSTHSpikes3bins & key);
            D = fetch(LICK2D.ROILick2DmapPSTHSpikes3bins & key,'psth_per_position_regular','psth_per_position_large','psth_per_position_small','psth_per_position_first','psth_per_position_begin','psth_per_position_mid','psth_per_position_end');
            
            for i_roi = 1:1:numel(key_roi)
                key_roi(i_roi).psth_corr_across_position_regular = fn_compute_correlations_between_positions(D(i_roi).psth_per_position_regular, min_modulation);
                key_roi(i_roi).psth_corr_across_position_small = fn_compute_correlations_between_positions(D(i_roi).psth_per_position_small, min_modulation);
                key_roi(i_roi).psth_corr_across_position_large = fn_compute_correlations_between_positions(D(i_roi).psth_per_position_large, min_modulation);
                key_roi(i_roi).psth_corr_across_position_first = fn_compute_correlations_between_positions(D(i_roi).psth_per_position_first, min_modulation);
                key_roi(i_roi).psth_corr_across_position_begin = fn_compute_correlations_between_positions(D(i_roi).psth_per_position_begin, min_modulation);
                key_roi(i_roi).psth_corr_across_position_mid = fn_compute_correlations_between_positions(D(i_roi).psth_per_position_mid, min_modulation);
                key_roi(i_roi).psth_corr_across_position_end = fn_compute_correlations_between_positions(D(i_roi).psth_per_position_end, min_modulation);
            end
            insert(self,key_roi);
        end
    end
end