%{
#
-> EXP2.Task
trial_type_name                          : varchar(200)      # trial-type name
---
trial_type_name_description=null         : varchar(4000)     #
%}


classdef TrialNameType < dj.Lookup
    properties
        contents = {
            'sound' 'l' ''
            'sound' 'r' ''
            'waterCue' 'l' ''
            'waterCue' 'r' ''
            }
    end
end