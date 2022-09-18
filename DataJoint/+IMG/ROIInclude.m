%{
# include IMG.ROIGood that were considered cell by suite2p and also exclude bad ROIs IMG.ROIBad that had abberent responses
-> IMG.ROI
%}


classdef ROIInclude < dj.Imported
    properties
        keySource = IMG.Plane;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            R=fetch(((IMG.ROI & IMG.ROIGood) - IMG.ROIBad) & key,'ORDER BY roi_number');
            insert(self, R);
        end
    end
end