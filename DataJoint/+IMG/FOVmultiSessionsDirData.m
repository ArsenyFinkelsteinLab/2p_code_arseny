%{
# 
-> IMG.FOVmultiSessions
----
multiple_sessions_data_dir    : varchar(4000)    # directory of the suite2p data coregistered across sessions
%}


classdef FOVmultiSessionsDirData < dj.Part
     properties(SetAccess=protected)
        master= IMG.FOVmultiSessions
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
        end
    end
end


