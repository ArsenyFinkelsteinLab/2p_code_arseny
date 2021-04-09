%{
#
bodypart_name         : varchar(200)                  #
---
bodypart_description  : varchar(1000)                 #
%}


classdef VideoBodypartType < dj.Lookup
    properties
        contents = {
            'tongue'               'tongue'
            'pawfrontleft'         'front paw left'
            'pawfrontright'        'fron paw right'
            'whiskers'             'whiskers'
            'nose'             'nose'
            'jaw'             'jaw'
            };
    end
end

