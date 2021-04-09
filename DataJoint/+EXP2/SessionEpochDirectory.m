%{
# Session Epoch directory
-> EXP2.SessionEpoch
---
local_path_session    :varchar(5000)                     # path to the local directory with relevant files
local_path_session_registered    :varchar(5000)          # path to the local directory with relevant files after registration
local_path_session_epoch    :varchar(5000)               # path to the local directory with relevant files
local_path_session_epoch_registered    :varchar(5000)    # path to the local directory with relevant files after registration


%}


classdef SessionEpochDirectory < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            insert(self, key);
        end
    end
end