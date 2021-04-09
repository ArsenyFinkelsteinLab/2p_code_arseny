%{
#
-> EXP2.Session
---
session_uid                 : int          # unique across sessions/animals
%}


classdef SessionID < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            session_uid=max(fetchn(EXP2.SessionID,'session_uid'));
            if isempty(session_uid)
                session_uid=0;
            end
            key.session_uid=session_uid+1;
            self.insert(key)
        end
    end
end