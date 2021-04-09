%{
# If there was grooming during the trial
-> EXP2.BehaviorTrial
---
%}


%



classdef VideoGroomingTrial < dj.Computed
    properties
        keySource = (EXP2.Session  & TRACKING.VideoFiducialsTrial) ;
    end
    methods(Access=protected)
        
        function makeTuples(self, key)
        end
        
    end
end

