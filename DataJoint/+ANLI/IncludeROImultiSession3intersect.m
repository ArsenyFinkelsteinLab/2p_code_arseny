%{
#  Significance of a activity for different task-related epochs/features
-> IMG.FOVmultiSessions
-> IMG.ROI
---
%}

classdef IncludeROImultiSession3intersect < dj.Computed
    properties
        %         keySource = EXP.Session & EPHYS.TrialSpikes
        keySource = (IMG.FOVmultiSessions);
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            k=fetch(IMG.FOVmultiSessions & key,'*');
            k=rmfield(k,'session');
            k=fetch(IMG.FOVmultiSessions & k,'*');
            
            
            
            
            roi_intersect=[];
            for i_s =1:1:numel(k)
                kkk=k(i_s);
                roi_number_list{i_s} = fetchn(ANLI.IncludeROI3 & kkk, 'roi_number', 'ORDER BY roi_number');
                if i_s==1
                    roi_intersect = roi_number_list{i_s};
                else
                    roi_intersect=intersect(roi_intersect, roi_number_list{i_s});
                end
            end
            
            k_insert=key;
            k_insert= repmat(k_insert,numel(roi_intersect),1);
            
            for i_roi=1:1:numel(roi_intersect)
                k_insert(i_roi).roi_number = roi_intersect(i_roi);
            end
            insert(self,k_insert);
            
        end
    end
end