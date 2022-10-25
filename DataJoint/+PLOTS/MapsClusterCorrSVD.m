%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP2.SessionEpoch
%}


classdef MapsClusterCorrSVD < dj.Computed
    properties
        
        keySource = EXP2.SessionEpoch  & IMG.Mesoscope & POP.ROIClusterCorrSVD & 'subject_id="464724" OR subject_id="464725"';
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base =fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\CorrClusters\clusters_corr_SVD\'];
            
            %             num_svd_components_removed_vector = [0, 1, 10];
%             num_svd_components_removed_vector = [0, 1, 5, 10];
            num_svd_components_removed_vector = [2,3,4];

%             threshold_for_event_vector = [0, 0.25];
             threshold_for_event_vector = [0];
            n_clust_vector = [20, 100];

%             n_clust_vector = [20, 100];
            
            rel_roi = (IMG.ROI-IMG.ROIBad) & key;
            rel_all = rel_roi*IMG.PlaneCoordinates  & key;
            M_all=fetch(rel_all ,'*');
            
            k=key;
            
            for ith = 1:1:numel(threshold_for_event_vector)
                for i_svd = 1:1:numel(num_svd_components_removed_vector)
                    for ic = 1:1:numel(n_clust_vector)
                        k.threshold_for_event = threshold_for_event_vector(ith);
                        k.n_clust = n_clust_vector(ic);
                        k.num_svd_components_removed = num_svd_components_removed_vector(i_svd);
                        flag_plot_clusters_individually=0;
%                         PLOTS_MapsClusterCorrSVD(k, flag_plot_clusters_individually, M_all, dir_current_fig);
                        PLOTS_MapsClusterCorrSVD_CCF(k, flag_plot_clusters_individually, M_all, dir_current_fig);
                        %                   flag_plot_clusters_individually=1;
                        %                 lick2D_map_onFOV_clusters_corr_meso(key, flag_plot_clusters_individually, n_clust);
                    end
                end
            end
                            insert(self,key);
        end
    end
end