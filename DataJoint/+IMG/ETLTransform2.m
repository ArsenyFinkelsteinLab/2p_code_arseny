%{ 
# Correction based on anatomical fiducials. Transform is averaged across all sessions with sufficient number of fiducials
plane_depth              : double           # imaging plane depth in um
---
etl_affine_transform=null   : blob      #  affine transform to correct for ETL abberations,computed across sessions, to align position of deeper planes to the most superficial plane
%}


classdef ETLTransform2 < dj.Lookup
    methods(Access=protected)
        function makeTuples(self, key)
            
        % To populate run this function: session_avg_affine_transform_from_fiducials_ETL()
            
        end
    end
end