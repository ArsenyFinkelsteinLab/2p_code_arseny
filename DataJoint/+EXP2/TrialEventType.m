%{
# 
trial_event_type            : varchar(24)                   # 
%}


classdef TrialEventType < dj.Lookup
     properties
        contents = {
            'delay'
            'go'
            'trigger imaging'
            'sound sample start'
            'sound sample end'
            'sample'
            'firstlick'
            'reward'
            'bitcodestart'
            'trialend'
            }
    end
end