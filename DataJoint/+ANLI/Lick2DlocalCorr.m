%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP2.SessionEpoch
%}


classdef Lick2DlocalCorr < dj.Computed
    properties
        
        keySource = EXP2.SessionEpoch & POP.ROICorrLocal  & IMG.Mesoscope;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            dir_base =fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\CorrLocal\'];
            
            
%             lick2D_local_corr_map(key);
            
%             radius_size_vector=[30,40,50,100];
                        radius_size_vector=[20, 100];

            for i_r = 1:1:numel(radius_size_vector)
                lick2D_local_corr_map(key, radius_size_vector(i_r), dir_current_fig);
            end
            insert(self,key);
            
            
        end
    end
end