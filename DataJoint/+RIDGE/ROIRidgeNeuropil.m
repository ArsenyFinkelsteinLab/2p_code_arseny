%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
-> RIDGE.PredictorType
time_shift                        : int             #     in units of 2p-imaging frames
---
predictor_beta          : double   # beta coefficient of the ridge regression 
%} 


classdef ROIRidgeNeuropil < dj.Imported
    properties
        keySource = (EXP2.SessionEpoch)  & IMG.ROI & 'session_epoch_type="behav_only"' & RIDGE.Predictors;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            time_shift_vec=[-2:1:7];
            rel_data1 = POP.ROISVDNeuropil;
            rel_data2 = POP.SVDSingularValuesNeuropil;
            rel_data3 = POP.SVDTemporalComponentsNeuropil;
            self2 = RIDGE.ROIRidgeVarExplainedNeuropil;
            fn_compute_Ridge_svd(key,self,self2, rel_data1,rel_data2,rel_data3, time_shift_vec);
            
        end
    end
end
