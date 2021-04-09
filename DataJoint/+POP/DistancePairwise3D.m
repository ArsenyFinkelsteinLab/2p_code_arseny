%{
# Distance of each ROI from all the other ROIs
-> EXP2.Session
---
roi_distance_3d            : longblob          # matrix of eucledian 3d distances of each roi from all the other rois
roi_numbers                : longblob          # numbers of all rois

%}


classdef DistancePairwise3D < dj.Computed
    properties
        keySource = EXP2.Session & IMG.ROI & IMG.Mesoscope
    end
    methods(Access=protected)
        function makeTuples(self, key)
           
            
        end
    end
end

