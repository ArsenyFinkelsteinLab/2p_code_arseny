%{
#
-> IMG.ROI
-> EXP2.SessionTrial
---
f_trace                 : longblob                      # flourescence values for each frame within a trial, from this ROI
f_trace_timestamps      : longblob                      # timestamps of each frame relative to the beginning of each trial
frames_per_trial        : int                           # number of frames in each trial
%}


classdef ROITrial < dj.Imported
    methods (Access=protected)
        function makeTuples(self, key)
        end
    end
end