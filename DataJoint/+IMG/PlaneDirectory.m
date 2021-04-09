%{
# Relative coordinates of the image plane, in case of multiplane, or multiFOV (e.g. mesoscope) imaging
-> IMG.Plane
---
local_path_plane_registered    :varchar(5000)    # path to the local directory with relevant files for this plane after registration
%}


classdef PlaneDirectory < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            insert(self, key);
        end
    end
end