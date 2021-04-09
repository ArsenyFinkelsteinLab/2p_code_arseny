%{
# 
-> EXP2.Session
%}


classdef Maps2DPSTHpreferred < dj.Computed
    properties
        
        keySource = EXP2.Session  & IMG.Mesoscope &  LICK2D.ROILick2DSelectivity;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\lick2D\psth_preferred_distance_meso\'];

            PLOTS_Maps2DPSTHpreferred(key, dir_current_fig);
            
%             insert(self,key);
            
        end
    end
end