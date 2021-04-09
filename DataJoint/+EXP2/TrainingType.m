%{
# Mouse training
training_type                      : varchar(100)                   # mouse training
---
training_type_description          : varchar(2000)                  #

%}


classdef TrainingType < dj.Lookup
    properties
        contents = {
            'regular sound' 'regular training on the sound task'
            'no training'   ''}

    end
end