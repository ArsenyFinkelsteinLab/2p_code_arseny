%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
fr_interval_start         : int   # %in miliseconds, window to compute the firing rate for the activity maps
fr_interval_end           : int   # %in miliseconds, window to compute the firing rate for the activity maps
---
pval_rayleigh_length=null       : double   #
pval_theta_tuning_odd_even_corr = null  : double   #
%}


classdef ROILick2DangleShuffle< dj.Imported
    properties
        keySource = EXP2.SessionEpoch & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
%             key.fr_interval_start = -2000;
%             key.fr_interval_end = 0;
%             fn_computer_Lick2Dangle_shuffle(key,self);
%             
%             key.fr_interval_start = -1000;
%             key.fr_interval_end = 0;
%             fn_computer_Lick2Dangle_shuffle(key,self);
%             
%             key.fr_interval_start = 0;
%             key.fr_interval_end = 1000;
%             fn_computer_Lick2Dangle_shuffle(key,self);
%             
%             key.fr_interval_start = -1000;
%             key.fr_interval_end = 1000;
%             fn_computer_Lick2Dangle_shuffle(key,self);
            
            key.fr_interval_start = -1000;
            key.fr_interval_end = 2000;
            fn_computer_Lick2Dangle_shuffle(key,self);
            
        end
    end
end