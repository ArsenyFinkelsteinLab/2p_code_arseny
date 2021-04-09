%{
# 
brain_area="ALM"            : varchar(32)                   # 
---
brain_area_description=null : varchar(1000)                 # 
%}


classdef BrainArea < dj.Lookup
     properties
        contents = {
            'ALM' 'anterior lateral motor cortex'
            'vS1' 'vibrissal primary somatosensory cortex ("barrel cortex")'
            'all' 'all areas'
            }
    end
end
