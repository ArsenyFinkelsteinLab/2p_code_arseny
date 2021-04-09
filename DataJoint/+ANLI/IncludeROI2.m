%{
#  Significance of a activity for different task-related epochs/features
-> IMG.ROI
---
threshold_deltaf_overf   : double                           #

%}

classdef IncludeROI2 < dj.Computed
    properties
        %         keySource = EXP2.Session & EPHYS.TrialSpikes
        keySource = (EXP2.Session  & IMG.ROI);
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            key=fetch(IMG.FOV & key);
            key.threshold_deltaf_overf = 0.25;
%             key.minimal_number_of_suprahtreshold_events = 5;
            
            roi_list = fetchn(IMG.ROI-IMG.ExcludeROImultiSession & key, 'roi_number','ORDER BY roi_number');
            for iROI = 1:numel(roi_list)
                key.roi_number = roi_list (iROI);
                Favg=fetchn(ANLI.FPSTHaverage & key  & 'outcome!="ignore"' ,'psth_avg');
                maxF = cellfun(@max,Favg);
                if sum(maxF>=key.threshold_deltaf_overf)>0
                    insert(self,key);
                end
            end
        
        end
    end
end