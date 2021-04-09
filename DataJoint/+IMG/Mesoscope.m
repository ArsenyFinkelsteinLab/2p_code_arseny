%{
# If this sessioon was recorded on  mesoscope
-> EXP2.Session
%}


classdef Mesoscope < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            insert(self, key);
        end
    end
end