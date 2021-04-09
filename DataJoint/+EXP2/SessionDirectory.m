%{
# Session directory - only updated in case there are multiple sessions with the same date
-> EXP2.Session
---
local_path_orignal_session    :varchar(5000)                     # path to the local directory with relevant files
%}


classdef SessionDirectory < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            insert(self, key);
        end
    end
end