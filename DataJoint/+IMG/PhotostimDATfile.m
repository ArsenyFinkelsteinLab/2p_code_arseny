%{
# Session Epoch directory
-> EXP2.SessionEpoch
---
dat_file    :longblob                   # dat file with parameters used for photostimulation


%}


classdef PhotostimDATfile < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            insert(self, key);
        end
    end
end