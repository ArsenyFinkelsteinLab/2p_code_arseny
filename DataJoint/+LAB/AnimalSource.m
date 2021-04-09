%{
# 
animal_source               : varchar(30)                   # 
%}


classdef AnimalSource < dj.Lookup
    properties
        contents = {
            'Jackson Labs'
            'Charles River'
            'MMRRC'
            'Taconic'
            'Other'
            }
    end
end