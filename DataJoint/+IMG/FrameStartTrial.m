%{
# Frame timestamps
-> EXP2.SessionEpoch
-> EXP2.SessionTrial
---
session_epoch_trial_bitcode=null   : int      # trial detected based on bitcode, after transforming from binary to integers
session_epoch_trial_start_frame    : double   #  trial epoch start frame relative to the beginning of  the session epoch. Start frame is the closest frame to the beginning of bpod trial. Closeness is defined according to absolute time difference, so it could be the frame preceding the trial start.
session_epoch_trial_end_frame      : double   #  trial epoch file file start time relative to the beginning of  the session epoch
%}


classdef FrameStartTrial < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            insert(self, key);
        end
    end
end