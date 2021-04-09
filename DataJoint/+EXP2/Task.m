%{
# Type of tasks
task                        : varchar(12)                   # task type
---
task_description            : varchar(4000)                 # 
%}


classdef Task < dj.Lookup
    properties
        contents = {
            'sound' 'sound task (2AFC)'
            'lick2D' 'lick upon presentation of a lickport in 2D'
            'waterCue' 'lick the lickport that was cued with water before (2AFC)'
            }
    end
end