%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP2.SessionEpoch
%}


classdef Lick2DPlotPCA < dj.Computed
    properties
        
        keySource = EXP2.SessionEpoch  & IMG.Mesoscope & POP.ROIPCA;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            num_components=10;
            
            rel_all = IMG.ROI*IMG.PlaneCoordinates  & IMG.ROIGood & key;
            M_all=fetch(rel_all ,'*');
            M_all=struct2table(M_all);
            kkk=key;
            for i_c = 1:1:num_components
                kkk.component_id = i_c;
                        lick2D_map_pca(kkk,M_all);
               
            end
            
            insert(self,key);
            
            
        end
    end
end