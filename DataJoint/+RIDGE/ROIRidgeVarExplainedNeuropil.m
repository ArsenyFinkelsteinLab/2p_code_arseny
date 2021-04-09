%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
variance_explained          : double   # variance of individual neuron activity explained by the ridge model
%} 


classdef ROIRidgeVarExplainedNeuropil < dj.Imported
    properties
        keySource = (EXP2.SessionEpoch)  & IMG.ROI & 'session_epoch_type="behav_only"' & RIDGE.Predictors;
    end
    methods(Access=protected)
        function makeTuples(self, key)
                        
        end
    end
end
