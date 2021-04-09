%{
# 
-> IMG.Plane
---
plane_num_in_suite2p    :smallint    #
frames_per_folder       :blob    # number of frames for this plane read by suite2p from each folder. Folders typically correspond to session epochs. Some planes will have 1 frame less  than other planes, if the acquistion was stopped during volumetricimaging before finished reading the entire volume
%}


classdef PlaneSuite2p < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            insert(self, key);
        end
    end
end