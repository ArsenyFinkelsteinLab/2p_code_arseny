%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP2.SessionEpoch
%}


classdef SomatotopyDeltaFiringRate < dj.Computed
    properties
        
        keySource = (EXP2.SessionEpoch*EXP2.SessionEpochSomatotopy) &  IMG.ROIdeltaFPeak;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
           threshold_for_event_vector = [0.25];
            
            k=key;
            if ~strcmp(fetch1(EXP2.SessionEpochSomatotopy & k,'sensory_stimulation_area'),'control')
                for i=1:1:numel(threshold_for_event_vector)
                    k.threshold_for_event = threshold_for_event_vector(i);
                    PLOTS_SomatotopyDeltaFiringRate(k);
                end
                insert(self,key);
            end
        end
    end
end