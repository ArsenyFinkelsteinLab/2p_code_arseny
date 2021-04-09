%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
fr_interval_start         : int   # %in miliseconds, window to compute the firing rate for the activity maps
fr_interval_end           : int   # %in miliseconds, window to compute the firing rate for the activity maps
---
theta_tuning_curve         : blob   #
theta_tuning_curve_odd         : blob   #
theta_tuning_curve_even        : blob   #
theta_bins_centers         : blob   #
preferred_theta=null       : double   #
rayleigh_length=null       : double   #
theta_tuning_odd_even_corr = null  : double   #
theta_tuning_curve_vmises         : blob   #
preferred_theta_vmises         : double   #
goodness_of_fit_vmises  : double   #
%} 


classdef ROILick2DangleNeuropil< dj.Imported
    properties
        keySource = (EXP2.SessionEpoch*IMG.FOV) & IMG.ROIdeltaFNeuropil & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
          
            
              rel_data = IMG.ROIdeltaFNeuropil;            
            
%             fr_interval = [-1, 3]; %s
            fr_interval = [-2, 5]; % used it for the mesoscope
            fn_computer_Lick2Dangle(key,self, rel_data, fr_interval);
            
        end
    end
end