%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_quadrants                  : blob   # PSTH concatenated for the 4 different quadrants
psth_quadrants_stem                       : blob   #
psth_quadrants_odd                        : blob   #
psth_quadrants_even                       : blob   #
psth_quadrants_odd_even_corr              : float  #
psth_quadrants_time                       : blob   # time vector, for the non-concatenated PSTH
%}


classdef ROILick2DQuadrantsSpikes < dj.Imported
    properties
%         keySource = ((EXP2.SessionEpoch*IMG.FOV)  & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"') - IMG.Mesoscope;
        keySource = ((EXP2.SessionEpoch*IMG.FOV)  & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"') & IMG.Mesoscope;

    end
    methods(Access=protected)
        function makeTuples(self, key)
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\behavior\lickport_position_quadrants\'];

            rel_data = IMG.ROISpikes;
%             fr_interval = [-1, 3]; %s
            fr_interval = [-2, 5]; % used it for the mesoscope
            fn_computer_Lick2DQuadrantsPSTH(key,self, rel_data,fr_interval,dir_current_fig);
            
        end
    end
end
