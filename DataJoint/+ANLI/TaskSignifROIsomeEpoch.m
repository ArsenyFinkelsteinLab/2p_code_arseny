%{
#  Significance of a activity for different task-related epochs/features
-> IMG.ROI
---
task_signif_pval_threshold  = null    : double           # pval at some epoch used for signficance
%}

classdef TaskSignifROIsomeEpoch < dj.Computed
    properties
        %         keySource = EXP2.Session & EPHYS.TrialSpikes
        keySource = (EXP2.Session  & IMG.ROI);
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            rel=ANLI.TaskSignifName;
            pval_threshold = 0.01/rel.count;
            
            key=fetch(IMG.FOV & key);
            
            roi_list=fetchn((IMG.ROI - IMG.ExcludeROI) & key,'roi_number','ORDER BY roi_number');
            for i_roi = 1:1:numel(roi_list)
                key.roi_number =roi_list(i_roi);
                pval=    fetchn(ANLI.TaskSignifROI & key,'task_signif_pval');
                if sum(pval< pval_threshold)>0
                    key.task_signif_pval_threshold =pval_threshold;
                    insert(self,key);
                end
                
            end
        end
    end
end