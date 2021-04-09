%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
threshold_for_event             : double                           #      threshold in deltaf_overf
---
corr_with_licks          : double   # correlation between dff and lick rate
%} 


classdef ROILick2DLickRate < dj.Imported
    properties
        keySource = (EXP2.SessionEpoch*IMG.FOV)  & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock & IMG.Mesoscope & TRACKING.VideoNthLickTrial;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            threshold_for_event=[0,0.25,0.5,1];
            rel_data = IMG.ROIdeltaF;
            fn_computer_Lick2DLickRate(key,self, rel_data, threshold_for_event);
            
        end
    end
end
