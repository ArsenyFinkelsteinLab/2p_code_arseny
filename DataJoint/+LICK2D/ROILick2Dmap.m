%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins            : int   #
---
psth_per_position         : longblob   #
psth_per_position_odd     : longblob   #
psth_per_position_even    : longblob   #
psthmap_time              : blob   #
lickmap_fr                : blob   #
lickmap_fr_odd            : blob   #
lickmap_fr_even           : blob   #
lickmap_odd_even_corr     : double     #
pos_x_bins_centers        : blob       #
pos_z_bins_centers        : blob       #
information_per_spike     : double     #
preferred_bin             : double     #
preferred_radius          : double     #
%}


classdef ROILick2Dmap < dj.Imported
    properties
        keySource = (EXP2.SessionEpoch*IMG.FOV) & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
                
                rel_data = IMG.ROIdeltaF;
%                             fr_interval = [-1, 3]; %s
            fr_interval = [-2, 5]; % used it for the mesoscope
                fn_compute_Lick2D_map_and_selectivity(key,self, rel_data, fr_interval);
               
        end
    end
end