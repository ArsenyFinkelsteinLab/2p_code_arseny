%{
# 
skull_reference             : varchar(60)                   # 
%}


classdef SkullReference < dj.Lookup
     properties
        contents = {
            'Bregma'
            'Lambda'
            }
    end
end