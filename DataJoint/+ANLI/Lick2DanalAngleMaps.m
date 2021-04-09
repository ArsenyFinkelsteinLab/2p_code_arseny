%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP2.Session
%}


classdef Lick2DanalAngleMaps < dj.Computed
    properties
        
        keySource = EXP2.Session & ANLI.ROILick2Dangle  & IMG.Mesoscope;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            

            lick2D_map_onFOV_angles__meso(key);
            
            insert(self,key);
            
        end
    end
end