%{
# bad ROI that were considered cell by suite2p
-> IMG.ROI
%}


classdef ROIBad < dj.Imported
    properties
        keySource = EXP2.Session & IMG.ROIBadSessionEpoch;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            key_roi = fetch(IMG.ROIBadSessionEpoch & key);
            key_roi = rmfield(key_roi, 'session_epoch_type');
            key_roi = rmfield(key_roi, 'session_epoch_number');
            
            [C,ia,ic]  = unique([key_roi.roi_number]); %take unique across session epochs
            insert(self,key_roi(ia));
            
        end
    end
end