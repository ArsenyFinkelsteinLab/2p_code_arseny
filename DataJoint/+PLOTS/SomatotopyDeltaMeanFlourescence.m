%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP2.SessionEpoch
%}


classdef SomatotopyDeltaMeanFlourescence < dj.Computed
    properties
        
        keySource = EXP2.SessionEpoch*EXP2.SessionEpochSomatotopy;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            k=key;
            if ~strcmp(fetch1(EXP2.SessionEpochSomatotopy & k,'sensory_stimulation_area'),'control')
            PLOTS_SomatotopyDeltaMeanFlourescence(k);
            insert(self,key);
            end
        end
    end
end