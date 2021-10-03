%{
# How many times the same stimulus is repeated across consecutive frames
-> EXP2.SessionEpoch
---
same_photostim_duration_in_frames               : double     # frames here will refer to frames or planes for single/multi plane imaging, respectively
photostim_volume_ratio                          : double     # same_photostim_duration_in_frames/num_of_planes    for volumetric imaging, it tells how many stimuli there are during the time it takes to aquire a volume
%}


classdef PhotostimProtocol < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)

            insert(self, key);
            
        end
    end
end