%{
#
trial_epoch_name                         : varchar(400)      # 
---
trial_epoch_name_name_description=null        : varchar(4000)     #
%}


classdef EpochName2 < dj.Lookup
    properties
        contents = {
            'sample'                              ''
            'delay'                               ''
            'response'                            ''
            'all'                                 ''
            }
    end
end