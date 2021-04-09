%{
# 
-> EXP2.Session
%}


classdef Maps2DthetaSpikesPhoto < dj.Computed
    properties
        
        keySource = EXP2.Session  & IMG.Volumetric &  LICK2D.ROILick2DangleSpikesPhoto;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\lick2D\theta_photorig_spikes\'];

rel_data=LICK2D.ROILick2DangleSpikesPhoto;
            
            PLOTS_Maps2Dtheta_distance(key, dir_current_fig, rel_data);
            
%             insert(self,key);
            
        end
    end
end