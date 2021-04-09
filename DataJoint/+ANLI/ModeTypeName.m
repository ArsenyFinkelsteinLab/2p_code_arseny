%{
#
mode_type_name                         : varchar(400)      # mode-type name
---
mode_type_name_description=null        : varchar(4000)     #
%}


classdef ModeTypeName < dj.Lookup
    properties
        contents = {
            'Stimulus'                              'Selectivity during sample period - i.e. response to stimulus, computed using all L/R trials'
            'LateDelay'                             'Selectivity during late delay, computed using all L/R trials'
            'Ramping'                               'Ramping during delay, computed using all L/R trials'
            'Movement'                              'Selectivity during movement, computed using all L/R trials'
            
            
            }
    end
end