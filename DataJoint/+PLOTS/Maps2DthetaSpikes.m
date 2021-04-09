%{
# 
-> EXP2.Session
%}


classdef Maps2DthetaSpikes < dj.Computed
    properties
        
        keySource = EXP2.Session  & IMG.Mesoscope &  LICK2D.ROILick2DangleSpikes;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\lick2D\theta_meso_spikes\'];

            flag_spikes = 1; % 1 spikes, 0 dff
            PLOTS_Maps2Dtheta(key, dir_current_fig, flag_spikes);
            
%             insert(self,key);
            
        end
    end
end