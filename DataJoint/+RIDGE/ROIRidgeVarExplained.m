%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
threshold_for_event        : double        # threshold in zscore, after binning. 0 means we don't threshold. 1 means we take only positive events exceeding 1 std, 2 means 2 std etc.
time_bin                   : double        # time window used for binning the data. 0 means no binning
---
variance_explained          : double   # variance of individual neuron activity explained by the ridge model
%} 


classdef ROIRidgeVarExplained < dj.Imported
    properties
        keySource = (EXP2.SessionEpoch)  & IMG.ROI & 'session_epoch_type="behav_only"' & RIDGE.Predictors;
    end
    methods(Access=protected)
        function makeTuples(self, key)
                        
        end
    end
end
