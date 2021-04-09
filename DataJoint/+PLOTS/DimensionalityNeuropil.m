%{
#
-> LAB.Subject
---
%}


classdef DimensionalityNeuropil < dj.Computed
    properties
        
        keySource = LAB.Subject &  POP.SVDSingularValuesNeuropil;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\dimensionality_neuropil\'];
            threshold_variance_explained=0.9;
            k=key;
            k.session_epoch_type='spont_only';
            V = fetch(POP.SVDSingularValuesNeuropil & k,'*');
            for i=1:1:numel(V)
                
                singular_values=V(i).singular_values;
                variance_explained=singular_values.^2/sum(singular_values.^2); % a feature of SVD. proportion of variance explained by each component
                cumulative_variance_explained=cumsum(variance_explained);
                num_comp{1}(i) = find(cumulative_variance_explained>threshold_variance_explained,1,'first');
            end
            
            
            k.session_epoch_type='behav_only';
            V = fetch(POP.SVDSingularValuesNeuropil & k,'*');
            for i=1:1:numel(V)
                
                singular_values=V(i).singular_values;
                variance_explained=singular_values.^2/sum(singular_values.^2); % a feature of SVD. proportion of variance explained by each component
                cumulative_variance_explained=cumsum(variance_explained);
                num_comp{2}(i) = find(cumulative_variance_explained>threshold_variance_explained,1,'first');
            end
            clf
            plot(num_comp{1},'-k')
            hold on
            plot(num_comp{2},'-b')
            pause(3)

        end
    end
end