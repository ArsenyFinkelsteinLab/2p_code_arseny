%{
# In case of moving lickport, lickport entrance and exit time based on video tracking of the lickport
-> EXP2.BehaviorTrial
---
lickport_t_entrance=null                           : double               # (s) relative to Go cue, average between entrance start and entrance end
lickport_t_entrance_relative_to_trial_start=null   : double               # (s) relative to beginning of the trial, average between entrance start and entrance end
lickport_t_entrance_start=null                     : double               # (s) relative to Go cue
lickport_t_entrance_end=null                       : double               # (s) relative to Go cue
lickport_lickable_duration=null                    : double               # (s) duration for which the lickport stay in lickable position lickport_t_entrance_end-lickport_t_entrance_start

%}


%



classdef VideoLickportTrial < dj.Computed
    properties
        keySource = (EXP2.Session  & TRACKING.VideoFiducialsTrial) ;
    end
    methods(Access=protected)
        
        function makeTuples(self, key)
        end
        
    end
end

