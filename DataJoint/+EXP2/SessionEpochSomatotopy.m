%{
# Session epoch time
-> EXP2.SessionEpoch
---
sensory_stimulation_area    : varchar(2000)                  # are that was touched during somatotopic mapping
%}


classdef SessionEpochSomatotopy < dj.Imported
    properties
        keySource = EXP2.Session;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
           insert(self,key);
            
        end
    end
end