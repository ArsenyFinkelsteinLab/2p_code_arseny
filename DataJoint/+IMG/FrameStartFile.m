%{
# Frame timestamps
-> EXP2.SessionEpoch
session_epoch_file_num            : int      # first and last frame of each tiff file, relative to the beginning of the session epoch
---
session_epoch_file_start_frame    : double   # (s) session epoch start frame relative to the beginning of  the session epoch
session_epoch_file_end_frame      : double   # (s) session epoch file file start time relative to the beginning of  the session epoch
%}


classdef FrameStartFile < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            insert(self, key);
        end
    end
end