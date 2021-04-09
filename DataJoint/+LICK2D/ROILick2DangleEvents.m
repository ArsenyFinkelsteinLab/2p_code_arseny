%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
preferred_theta=null       : double   #
rayleigh_length=null       : double   #
theta_tuning_odd_even_corr = null  : double   #
preferred_theta_vmises     : double   #
goodness_of_fit_vmises     : double   #
theta_tuning_curve_vmises  : blob   #
theta_tuning_curve         : blob   #
theta_tuning_curve_odd     : blob   #
theta_tuning_curve_even    : blob   #
theta_bins_centers         : blob   #
%}


classdef ROILick2DangleEvents< dj.Imported
    properties
        keySource = (EXP2.SessionEpoch*IMG.FOV) & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            rel_data = IMG.ROIdeltaF;
            
            flag_threshold_events=1; % threshold the trace, set values <threshold_events_cutoff to 0
            threshold_events_cutoff =0.5;
            
            fr_interval = [-3, 4]; %s
            fn_computer_Lick2Dangle(key,self, rel_data, fr_interval, flag_threshold_events, threshold_events_cutoff);
            
        end
    end
end