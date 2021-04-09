%{
# Imaging plane
-> IMG.FOV
plane_num              : int           # imaging plane within this field of view
channel_num            : int           # imaging channel (e.g. 1 green, 2 red etc)
---
mean_img               : longblob      #  mean image from suite2p
mean_img_enhanced      : longblob      # enahnced mean image from suite2p
%}


classdef Plane < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            insert(self, key);
        end
    end
end