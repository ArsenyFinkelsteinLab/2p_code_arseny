%{
# Frame timestamps
-> EXP2.Session
---
frame_timestamps      : longblob   # (s) frame times relative to the beginning of  the session
%}


classdef FrameTime < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            insert(self, key);
        end
    end
end