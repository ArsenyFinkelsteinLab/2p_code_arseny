%{
# 
-> EXP2.Session
trial                       : smallint                      # 
---
trial_uid                   : int                           # unique across sessions/animals
start_time                  : decimal(8,4)                  # (s) % relative to session beginning
%}


classdef SessionTrial < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
        end
    end
end
