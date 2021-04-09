%{
#
early_lick                  : varchar(32)                   #
---
early_lick_description      : varchar(4000)                   #
%}


classdef EarlyLick < dj.Lookup
    properties
        contents = {
            'early' 'early lick during sample and/or delay'
            'no early' ''
            }
    end
end