%{
#
-> EXP2.Session
---
%}


classdef Maps2DLickRate < dj.Computed
    properties
        
        keySource = EXP2.Session  & IMG.Mesoscope &  LICK2D.ROILick2DLickRate;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\lick2D\lick_rate\'];
            flag_spikes = 0; % 1 spikes, 0 dff
            
            
            threshold=[0,0.25,0.5,1];
            
            for i = 1:1:numel(threshold)
                key.threshold_for_event=threshold(i);
                PLOTS_Maps2DLickRate(key, dir_current_fig, flag_spikes);
            end
            
            key=rmfield(key,'threshold_for_event');
            insert(self,key);
            
        end
    end
end