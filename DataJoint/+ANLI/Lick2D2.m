%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP2.Session
%}


classdef Lick2D2 < dj.Computed
    properties
        
        keySource = EXP2.Session &  EXP2.TrialLickBlock & ANLI.ROILick2DPSTH & IMG.Mesoscope;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            flag_plot_clusters_individually=0;
            
            lick2D_map_onFOV_clusters_shape_meso(key, flag_plot_clusters_individually);
            
            lick2D_map_onFOV_clusters_shapeandselectivity_meso(key, flag_plot_clusters_individually);
            
            lick2D_map_onFOV_clusters_selectivity_meso(key, flag_plot_clusters_individually);
            
            insert(self,key);
            
            
        end
    end
end