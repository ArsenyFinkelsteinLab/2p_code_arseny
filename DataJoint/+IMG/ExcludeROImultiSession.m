%{
#  Exlusion of ROIs based on baseline flourescence
-> IMG.FOVmultiSessions
-> IMG.ROI
---
%}

classdef ExcludeROImultiSession < dj.Computed
    properties
        %         keySource = EXP.Session & EPHYS.TrialSpikes
        keySource = (IMG.FOVmultiSessions);
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            k=fetch(IMG.FOVmultiSessions & key,'*');
            k=rmfield(k,'session');
            k=fetch(IMG.FOVmultiSessions & k,'*');
            
            
            
            
            roi_union=[];
            for i_s =1:1:numel(k)
                kkk=k(i_s);
                roi_number_list{i_s} = fetchn(IMG.ExcludeROI & kkk, 'roi_number', 'ORDER BY roi_number');
                if i_s==1
                    roi_union = roi_number_list{i_s};
                else
                    roi_union=union(roi_union, roi_number_list{i_s});
                end
            end
            
            k_insert=key;
            k_insert= repmat(k_insert,numel(roi_union),1);
            
           for i_roi=1:1:numel(roi_union)
                k_insert(i_roi).roi_number = roi_union(i_roi);
            end
            insert(self,k_insert);
            
        end
    end
end