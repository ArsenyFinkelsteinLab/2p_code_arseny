%{
#
-> IMG.ROI
-> EXP2.TrialNameType
-> EXP2.Outcome
-> EXP2.SessionTrial
---
psth_trial                      : longblob    # PSTH aligned to go cue time, expressed as deltaF/F, where F is the baseline flourescene in the beginning of each trial
psth_timestamps                 : longblob    # timestamps of each frame relative to go cue
time_sample_start               : double      # time of sample start relative to go cue
time_sample_end               : double      # time of sample end relative to go cue
%}


classdef FPSTHtrial < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            
        end
    end
end