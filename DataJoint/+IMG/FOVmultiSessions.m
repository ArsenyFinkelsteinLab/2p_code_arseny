%{
# Table indicating that this field of view was registered across multiple sessions. FOV that are not in this table were not registered across multiple sessions
-> IMG.FOV
----
multiple_sessions_uid         : int           # unique id that identifies sessions that were coregistered together. 
%}


classdef FOVmultiSessions < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            
        end
    end
end