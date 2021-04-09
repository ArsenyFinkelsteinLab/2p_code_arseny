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
number_of_theta_not_nan    : int   #

%}


classdef ROILick2Dangle< dj.Imported
    properties
        keySource = (EXP2.SessionEpoch*IMG.FOV) & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\behavior\lickport_position_angles\'];
            
            
            rel_data = IMG.ROIdeltaF;
            fr_interval = [-1, 3]; %s
            %fr_interval = [-2, 5]; % used it for the mesoscope
            flag_threshold_events=0;
            threshold_events_cutoff=0;
            fn_computer_Lick2Dangle(key,self, rel_data,fr_interval,flag_threshold_events,threshold_events_cutoff,dir_current_fig);
            
            
        end
    end
end