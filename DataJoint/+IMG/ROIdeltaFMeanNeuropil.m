%{
# Flourescent trace
-> EXP2.SessionEpoch
-> IMG.ROI
---
mean_dff      : double   # mean of  delta f over f
%}


classdef ROIdeltaFMeanNeuropil < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & IMG.ROI & IMG.ROIdeltaFNeuropil;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            
            
            key_mean_dff=fetch(IMG.ROI&key,'ORDER BY roi_number');

            Fall=fetchn(IMG.ROIdeltaFNeuropil &key,'dff_trace','ORDER BY roi_number');
            
            for iROI=1:1:size(Fall,1)
                F=Fall{iROI};
                key_mean_dff(iROI).mean_dff = mean(F);
                key_mean_dff(iROI).session_epoch_type = key.session_epoch_type;
                key_mean_dff(iROI).session_epoch_number = key.session_epoch_number;
            end
                insert(self,key_mean_dff);

        end
    end
end