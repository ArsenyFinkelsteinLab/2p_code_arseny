%{
#
-> EXP2.SessionTrial
-> RIDGE.PredictorType
time_bin                   : double        # time window used for binning the data
---
trial_predictor  = null        : blob                        # predictor time series, resampled according to neural data rate
%}

classdef Predictors < dj.Imported
    properties
        keySource =  (EXP2.SessionTrial & TRACKING.TrackingTrial)-TRACKING.TrackingTrialBad - (TRACKING.VideoGroomingTrial);
    end
    methods(Access=protected)
        
        function makeTuples(self, key)
            time_bin_vector = [0.2, 0.5, 1];
            for i=1:1:numel(time_bin_vector)
                time_bin=time_bin_vector(i);
                key.time_bin = time_bin;
                fn_compute_predictors (key,self, time_bin);
            end
            
        end
    end
    
end