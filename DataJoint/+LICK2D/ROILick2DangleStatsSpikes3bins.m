%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
preferred_theta_regular=null                : double   #
rayleigh_length_regular=null                : double   #
preferred_theta_vmises_regular              : double   #
goodness_of_fit_vmises_regular              : double   #
theta_tuning_odd_even_corr_regular = null   : double   #

preferred_theta_small=null                : double   #
rayleigh_length_small=null                : double   #
preferred_theta_vmises_small              : double   #
goodness_of_fit_vmises_small              : double   #
theta_tuning_odd_even_corr_small = null   : double   #

preferred_theta_large=null                : double   #
rayleigh_length_large=null                : double   #
preferred_theta_vmises_large              : double   #
goodness_of_fit_vmises_large              : double   #
theta_tuning_odd_even_corr_large = null   : double   #

theta_bins_centers                 : blob   #

%}


classdef ROILick2DangleStatsSpikes3bins< dj.Imported
    properties
        keySource = ((EXP2.SessionEpoch*IMG.FOV) & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock) - IMG.Mesoscope;
%                 keySource = (EXP2.SessionEpoch*IMG.FOV) & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
               dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\behavior\lickport_position_angles_3bins\'];

            
            rel_data = IMG.ROISpikes;
            fr_interval = [-1, 3]; %s
            %fr_interval = [-2, 5]; % used it for the mesoscope
            flag_threshold_events=0;
            threshold_events_cutoff=0;
            fn_computer_Lick2Dangle_3bins(key,self, rel_data,fr_interval,flag_threshold_events,threshold_events_cutoff,dir_current_fig);
            
            
            
        end
    end
end