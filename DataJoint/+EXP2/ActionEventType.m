%{
# 
action_event_type           : varchar(32)                   # 
---
action_event_description    : varchar(1000)                 # 
%}


classdef ActionEventType < dj.Lookup
    properties
        contents = {
            'left lick' ''
            'right lick' ''
            'lick'       ''
            }
    end
end