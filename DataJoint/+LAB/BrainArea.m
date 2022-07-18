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
            'hippocampus' 'CA1'
            'MOp'       'Primary somatomotor area'
            'MOs'       'Secondary somatomotor area'
            'RSPagl'	'Retrosplenial area, lateral agranular part'
            'RSPd'      'Retrosplenial area, dorsal part'
            'SSp-bfd'	'Primary somatosensory area, barrel field'
            'SSp-ll'	'Primary somatosensory area, lower limb'
            'SSp-m'     'Primary somatosensory area, mouth'
            'SSp-n'     'Primary somatosensory area, nose'
            'SSp-tr'	'Primary somatosensory area, trunk'
            'SSp-ul'	'Primary somatosensory area, upper limb'
            'SSp-un'	'Primary somatosensory area, unassigned'
            'SSs'       'Supplementary somatosensory area'
            'VISa'      'Anterior visual area'
            'VISal'     'Anterolateral visual area' 
            'VISam'     'Anteromedial visual area'
            'VISrl'     'Rostrolateral visual area';
            }
    end
end
