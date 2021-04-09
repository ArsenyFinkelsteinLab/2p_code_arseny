%{
#  Significance of a activity for different task-related epochs/features
-> IMG.ROI
---
task_signif_pval_threshold  = null    : double           # pval at some epoch used for signficance
%}

classdef TaskSignifROIsomeEpoch3 < dj.Computed
    properties
        %         keySource = EXP2.Session & EPHYS.TrialSpikes
        keySource = (EXP2.Session  & IMG.ROI);
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            pval_threshold = 0.00001;
            
            key=fetch(IMG.FOV & key);
            
            roi_list=fetchn((IMG.ROI - IMG.ExcludeROI) & key,'roi_number','ORDER BY roi_number');
            for i_roi = 1:1:numel(roi_list)
                key.roi_number =roi_list(i_roi);
                pval=    fetchn(ANLI.TaskSignifROI & key & 'task_signif_name="LateDelay" or task_signif_name="Movement"','task_signif_pval');
                if sum(pval< pval_threshold)>0
                    key.task_signif_pval_threshold =pval_threshold;
                    insert(self,key);
                end
                
            end
        end
    end
end