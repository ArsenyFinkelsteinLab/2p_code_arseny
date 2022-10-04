%{
#
-> EXP2.Session
%}


classdef Maps2Dtheta < dj.Computed
    properties
        keySource = (EXP2.Session &  LICK2D.ROILick2DangleStatsSpikes3bins)  & IMG.Mesoscope ;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            rel_meso = IMG.Mesoscope & key;
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            
            if rel_meso.count>0 % if its mesoscope data
                dir_current_fig = [dir_base  '\Lick2D\brain_maps\lick2D\theta_meso\less_tuned\'];
            else  % if its not mesoscope data
                dir_current_fig = [dir_base  '\Lick2D\brain_maps\lick2D\theta_photostim_rig\less_tuned\'];
            end
            
            flag_spikes = 1; % 1 spikes, 0 dff
            PLOTS_Maps2Dtheta_new(key, dir_current_fig, flag_spikes);
            
            insert(self,key);
            
        end
    end
end