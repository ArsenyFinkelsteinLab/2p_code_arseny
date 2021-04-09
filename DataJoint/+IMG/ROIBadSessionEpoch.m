%{
# bad ROI that were considered cell by suite2p
-> EXP2.SessionEpoch
-> IMG.ROI
%}


classdef ROIBadSessionEpoch < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & IMG.ROIdeltaFStats;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            rel_temp=IMG.Mesoscope &key;
            if rel_temp.count>0
                threshold_max=15;
                threshold_min=-1;
            else
                threshold_max=100;
                threshold_min=-5;
            end
            
            key_roi = fetch(EXP2.SessionEpoch*IMG.ROI & key,'ORDER BY roi_number');
            rel=(IMG.ROIdeltaFStats)-EXP2.SessionEpochSomatotopy;
            
            m=fetchn(rel & key,'max_dff','ORDER BY roi_number');
            % histogram(m,[0:1:max(m)])
            idx_bad_max=(m>threshold_max) | m==0; % we exlude rois that have exactly zero values, because that indicate flat responses
            
            m=fetchn(rel & key,'min_dff','ORDER BY roi_number');
            % histogram(m)
            idx_bad_min=(m<threshold_min) | m==0;
            
            idx_bad_combined = idx_bad_max | idx_bad_min;
           
            key_roi = key_roi(idx_bad_combined);
            
            insert(self,key_roi);
            
        end
    end
end