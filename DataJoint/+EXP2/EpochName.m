%{
#
trial_epoch_name                         : varchar(400)      # 
---
trial_epoch_name_name_description=null        : varchar(4000)     #
%}


classdef EpochName < dj.Lookup
    properties
        contents = {
            'delay'                               ''
            'response'                            ''
            'delay and response'                  ''
            }
    end
end