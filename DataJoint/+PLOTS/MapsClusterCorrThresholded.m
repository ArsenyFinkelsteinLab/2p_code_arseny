%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP2.SessionEpoch
%}


classdef MapsClusterCorrThresholded < dj.Computed
    properties
        
        keySource = EXP2.SessionEpoch  & IMG.Mesoscope & POP.ROIClusterCorrThresholded;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base =fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
           dir_current_fig = [dir_base  '\Lick2D\brain_maps\CorrClusters\clusters_corr_thresholded\'];

%             threshold_for_event_vector = [0, 0.1, 0.25, 0.5];
            threshold_for_event_vector = [0, 0.1, 0.25];
%             n_clust_vector = [100, 500, 1000];
            n_clust_vector = [100, 500];

            
            rel_all = IMG.ROI*IMG.PlaneCoordinates  & IMG.ROIGood & key;
            M_all=fetch(rel_all ,'*');

            k=key;
            for ic = 1:1:numel(n_clust_vector)
                 for ith = 1:1:numel(threshold_for_event_vector)
                k.threshold_for_event = threshold_for_event_vector(ith);
                k.n_clust = n_clust_vector(ic);
                flag_plot_clusters_individually=0;
                PLOTS_MapsClusterCorrThresholded(k, flag_plot_clusters_individually, M_all, dir_current_fig);
%                   flag_plot_clusters_individually=1;
%                 lick2D_map_onFOV_clusters_corr_meso(key, flag_plot_clusters_individually, n_clust);
                 end
            end
            
            insert(self,key);
            
            
        end
    end
end