%{
# 
-> EXP2.SessionTrial
---
-> EXP2.TaskProtocol
-> EXP2.TrialInstruction
-> EXP2.EarlyLick
-> EXP2.Outcome
%}


classdef BehaviorTrial < dj.Imported
     methods(Access=protected)
        function makeTuples(self, key)
        end
    end
end