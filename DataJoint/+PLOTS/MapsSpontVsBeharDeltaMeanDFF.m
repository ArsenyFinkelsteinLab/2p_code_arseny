%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP2.Session
%}


classdef MapsSpontVsBeharDeltaMeanDFF < dj.Computed
    properties
        
        keySource = (EXP2.Session & IMG.ROIdeltaFMean  & IMG.Mesoscope) - EXP2.SessionEpochSomatotopy;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            dir_base =fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            flag_contrast_index = 0;
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\SpontVSBehav_DeltaMeanDFF\'];
            PLOTS_MapsSpontVsBeharDeltaMeanDFF(key, dir_current_fig, flag_contrast_index);
            
            flag_contrast_index = 1;
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\SpontVSBehav_DeltaMeanDFF_contrast_index\'];
            PLOTS_MapsSpontVsBeharDeltaMeanDFF(key, dir_current_fig, flag_contrast_index);
            
            insert(self,key);
            
            
        end
    end
end