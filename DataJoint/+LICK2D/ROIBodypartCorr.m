%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
-> TRACKING.VideoBodypartType
threshold_for_event             : double                           #      threshold in deltaf_overf
---
corr_with_bodypart          : double   # correlation between dff and bodypart trace
%}


classdef ROIBodypartCorr < dj.Imported
    properties
        keySource = (EXP2.SessionEpoch*IMG.FOV)  & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock & IMG.Mesoscope & TRACKING.VideoBodypartTrajectTrial;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            threshold_for_event=[0,0.25];
            rel_data = IMG.ROIdeltaF;
            bodypart_name={'pawfrontleft','pawfrontright','whiskers'};
            for i=1:1:numel(bodypart_name)
                key.bodypart_name = bodypart_name{i};
                fn_compute_ActivityBodypart_corr(key,self, rel_data, threshold_for_event);
            end
        end
    end
end
