%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins            : int   #
fr_interval_start         : int   # %in miliseconds, window to compute the firing rate for the activity maps
fr_interval_end           : int   # %in miliseconds, window to compute the firing rate for the activity maps
---
psth_per_position         : longblob   #
psth_per_position_odd     : longblob   #
psth_per_position_even    : longblob   #
psth_time                 : longblob   #
lickmap_fr                : longblob   #
lickmap_fr_odd            : longblob   #
lickmap_fr_even           : longblob   #
lickmap_odd_even_corr     : double     #
pos_x_bins_centers        : blob       #
pos_z_bins_centers        : blob       #
information_per_spike     : double     #
preferred_bin             : double     #
preferred_radius          : double     #

%}


classdef ROILick2DmapBlock < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialRewardSize;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            for i_numbin=[4]
                key.number_of_bins = i_numbin;
                
%                 key.fr_interval_start = -1000;
%                 key.fr_interval_end = 0;
%                 fn_computer_Lick2Dmap(key,self);
%                 
%                 key.fr_interval_start = 0;
%                 key.fr_interval_end = 1000;
%                 fn_computer_Lick2Dmap(key,self);
                
                key.fr_interval_start = 0;
                key.fr_interval_end = 2000;
                fn_computer_Lick2DmapBlock(key,self);
                
            end
        end
    end
end