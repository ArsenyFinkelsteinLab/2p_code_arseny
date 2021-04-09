%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP2.SessionEpoch
%}


classdef Lick2DMeanFiringRate < dj.Computed
    properties
        
        keySource = EXP2.SessionEpoch & IMG.ROIdeltaFMean  & IMG.Mesoscope;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            lick2D_MeanFiringRate_map(key);
            insert(self,key);
        end
    end
end