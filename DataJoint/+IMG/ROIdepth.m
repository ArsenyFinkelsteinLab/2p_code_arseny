%{
# ROI (Region of interest - e.g. cells)
-> IMG.Plane
roi_number                      : int           # roi number (restarts for every session)
---
z_pos_relative                  : double           # roi relative depth, in case of volumetric imaging. Increasing value means deeper.
%}


classdef ROIdepth < dj.Imported
    properties
        keySource = IMG.Plane;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
%             z=fetch(IMG.ROI*IMG.PlaneCoordinates & key,'*');
%             key = rmfield(z,{'f_mean', 'roi_number_uid',  'roi_centroid_x','roi_centroid_y','roi_radius','roi_x_pix','roi_y_pix','roi_pixel_weight','neuropil_pixels','f_mean','f_median','flag_mesoscope','x_pos_relative','y_pos_relative'});
%             insert(self,key);
            
        end
        
    end
end
