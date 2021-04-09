%{
# 
-> EXP2.Session
%}


classdef Maps2DPSTHSpikes < dj.Computed
    properties
        
        keySource = EXP2.Session  & IMG.Mesoscope &  LICK2D.ROILick2DPSTHSpikes;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\lick2D\psth_distance_meso_spikes\'];
            flag_spikes = 1; % 1 spikes, 0 dff
            PLOTS_Maps2DPSTH(key, dir_current_fig, flag_spikes);
            
%             insert(self,key);
            
        end
    end
end