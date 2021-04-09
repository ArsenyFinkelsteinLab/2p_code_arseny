%{
#
scanimage_zoom                     :  double
---
fov_microns_size_x                      :  double
fov_microns_size_y                      :  double

%}

classdef Zoom2Microns < dj.Lookup
     properties
        contents = { 
            1.1 891.4 777.4
            1.2 814.8  732.8
            1.3 738.2 688.2
            1.4 661.6  643.6
            1.5 585   599
            1.6  576   550
            }
    end
end


