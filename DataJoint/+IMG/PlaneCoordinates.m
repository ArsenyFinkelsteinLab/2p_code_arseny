%{
# Relative coordinates of the image plane, in case of multiplane, or multiFOV (e.g. mesoscope) imaging
-> IMG.Plane
---
flag_mesoscope      : smallint                      # 1 if mesoscope, 0 if not
x_pos_relative      : double                        # relative plane coordinates, in um (doublecheck, units)
y_pos_relative      : double                        # relative plane coordinates, in um (doublecheck, units)
z_pos_relative      : double                        # relative plane depth, in um
%}


classdef PlaneCoordinates < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            
            insert(self, key);
        end
    end
end