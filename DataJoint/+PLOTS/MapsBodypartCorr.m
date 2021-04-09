%{
#
-> EXP2.Session
---
%}


classdef MapsBodypartCorr < dj.Computed
    properties
        
        keySource = EXP2.Session  & IMG.Mesoscope &  LICK2D.ROIBodypartCorr;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\lick2D\bodypart_corr\'];
            flag_spikes = 0; % 1 spikes, 0 dff
            bodypart_name={'pawfrontleft','pawfrontright','whiskers'};
            
            threshold=[0,0.25];
            for j=1:1:numel(bodypart_name)
                for i = 1:1:numel(threshold)
                    key.bodypart_name = bodypart_name{j};
                    key.threshold_for_event=threshold(i);
                    PLOTS_MapsBodypartCorr(key, dir_current_fig, flag_spikes);
                end
            end
            
            key=rmfield(key,'threshold_for_event');
            key=rmfield(key,'bodypart_name');
            insert(self,key);
            
        end
    end
end