%{
#
-> EXP2.SessionTrial
-> RIDGE.PredictorType
---
trial_predictor  = null        : blob                        # predictor time series, resampled according to neural data rate
%}

classdef Predictors < dj.Imported
    properties
        keySource =  (EXP2.SessionTrial & TRACKING.TrackingTrial)-TRACKING.TrackingTrialBad - (TRACKING.VideoGroomingTrial);
    end
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            fn_compute_predictors (key,self);
            
        end
    end
    
end