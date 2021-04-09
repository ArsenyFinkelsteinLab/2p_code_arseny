%{
#
task_signif_name                         : varchar(400)      # element of the task that we check for significance - i.e. delay epoch selectivity, ramping etc
---
task_signif_name_description=null        : varchar(4000)     #
%}


classdef TaskSignifName < dj.Lookup
    properties
        contents = {
            'Stimulus'                              'Selectivity during sample period - i.e. response to stimulus'
            'LateDelay'                             'Selectivity during late delay'
            'Ramping'                               'Ramping, not necessarily selective. Computed in the beginning of the trial versus end of delay'
            'Movement'                              'Selectivity during movement'
            }
    end
end