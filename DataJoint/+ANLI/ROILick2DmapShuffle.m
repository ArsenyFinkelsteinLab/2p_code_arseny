%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins            : int   #
fr_interval_start         : int   # %in miliseconds, window to compute the firing rate for the activity maps
fr_interval_end           : int   # %in miliseconds, window to compute the firing rate for the activity maps
---
pval_information_per_spike  = null     : double   #
pval_lickmap_odd_even_corr = null  : double   #

%}


classdef ROILick2DmapShuffle < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock;;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            for i_numbin=[4]
                
                key.number_of_bins = i_numbin;
                
%                 key.fr_interval_start = -2000;
%                 key.fr_interval_end = 0;
%                 fn_computer_Lick2Dmap_shuffle(key,self);
%                 
%                 key.fr_interval_start = -1000;
%                 key.fr_interval_end = 0;
%                 fn_computer_Lick2Dmap_shuffle(key,self);
%                 
%                 key.fr_interval_start = 0;
%                 key.fr_interval_end = 1000;
%                 fn_computer_Lick2Dmap_shuffle(key,self);
%                 
%                 key.fr_interval_start = -1000;
%                 key.fr_interval_end = 1000;
%                 fn_computer_Lick2Dmap_shuffle(key,self);
                
                key.fr_interval_start = -1000;
                key.fr_interval_end = 2000;
                fn_computer_Lick2Dmap_shuffle(key,self);
                
            end
        end
    end
end