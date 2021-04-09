%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP2.SessionEpoch
%}


classdef Lick2Dsubcorr < dj.Computed
    properties
        
        keySource = EXP2.SessionEpoch  & IMG.Mesoscope & POP.ROISubClusterCorr;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            %             n_clust_vector = [20, 100, 500, 1000, 2000, 5000];
            n_clust_vector = [100,500];
            n_sub_clust_vector = [100,500];
            n_master_clust = 5;
            
            rel_all = IMG.ROI*IMG.PlaneCoordinates  & IMG.ROIGood & key;
            M_all=fetch(rel_all ,'*');
            
            kkk=key;
            for i_nc = 1:1:numel(n_clust_vector)
                n_clust = n_clust_vector(i_nc);
                kkk.n_clust = n_clust;
                
                for i_sub_nc = 1:1:numel(n_clust_vector)
                    n_sub_clust = n_sub_clust_vector(i_sub_nc);
                    kkk.n_sub_clust = n_sub_clust;
                    
                    for i_master_clust = 1:1:n_master_clust
                        kkk.heirar_cluster_id = i_master_clust;
                        
                        flag_plot_clusters_individually=0;
                        lick2D_map_sub_clusters_corr_meso(kkk, flag_plot_clusters_individually,M_all);
                    end
                    %                   flag_plot_clusters_individually=1;
                    %                 lick2D_map_onFOV_clusters_corr_meso(key, flag_plot_clusters_individually, n_clust);
                end
            end
            
            insert(self,key);
            
            
        end
    end
end