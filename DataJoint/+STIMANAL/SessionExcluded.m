%{
# If this sessioon was recorded on  mesoscope
-> EXP2.Session
%}

classdef SessionExcluded < dj.Lookup
     properties
        contents = {
            447990 9 %this session is combined processing of multiple days
            }
    end
end