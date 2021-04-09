%{
#  Exlusion of ROIs based on baseline flourescence
-> IMG.ROI
---
%}

classdef ExcludeROI < dj.Computed
    properties
        %         keySource = EXP2.Session & EPHYS.TrialSpikes
        keySource = (EXP2.Session  & IMG.ROI);
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            minimal_fl_median = 10; 
            
            key=fetch(IMG.FOV & key);
           
            roi_list = fetchn(IMG.ROI & key, 'roi_number','ORDER BY roi_number');
            for iROI = 1:numel(roi_list)
                key.roi_number = roi_list (iROI);
                baseline_fl_median=fetchn(IMG.ROI & key ,'baseline_fl_median');
                if baseline_fl_median < minimal_fl_median
                    insert(self,key);
                end
            end
        
        end
    end
end