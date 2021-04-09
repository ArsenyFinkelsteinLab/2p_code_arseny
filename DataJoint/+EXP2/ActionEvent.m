%{
# 
-> EXP2.BehaviorTrial
-> EXP2.ActionEventType
action_event_time           : decimal(8,4)                  # (s) from trial start
%}


classdef ActionEvent < dj.Imported
     methods(Access=protected)
        function makeTuples(self, key)
        end
    end
end