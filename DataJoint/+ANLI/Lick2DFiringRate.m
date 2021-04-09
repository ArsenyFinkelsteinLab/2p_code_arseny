%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP2.SessionEpoch
%}


classdef Lick2DFiringRate < dj.Computed
    properties
        
        keySource = EXP2.SessionEpoch & IMG.ROIdeltaFPeak  & IMG.Mesoscope;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            k=key;
            k.threshold_for_event=0.5;
            lick2D_FiringRate_map(k);
            insert(self,key);
            
        end
    end
end