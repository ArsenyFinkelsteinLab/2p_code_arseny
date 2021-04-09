%{
# 
-> EXP2.SessionTrial
---
-> EXP2.RewardSizeType
reward_size_valve_time            : double                    # reward size valve time (s)
%}


classdef TrialRewardSize < dj.Imported
     methods(Access=protected)
        function makeTuples(self, key)
        end
    end
end