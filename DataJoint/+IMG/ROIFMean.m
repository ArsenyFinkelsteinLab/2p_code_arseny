%{
# Mean of dff
-> EXP2.SessionEpoch
-> IMG.ROI
---
mean_f      : double   # mean of  f
%}


classdef ROIFMean < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & IMG.ROITrace;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            roi_list=fetchn(IMG.ROITrace & key,'roi_number','ORDER BY roi_number');
            chunk_size=500;
            for i_chunk=1:chunk_size:numel(roi_list)
                roi_interval = [i_chunk, i_chunk+chunk_size];
                if roi_interval(end)>numel(roi_list)
                    roi_interval(end) = numel(roi_list)+1;
                end
                try
                    temp_Fall=cell2mat(fetchn(IMG.ROITrace & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'f_trace','ORDER BY roi_number'));
                catch
                    temp_Fall=cell2mat(fetchn(IMG.ROITrace & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'f_trace','ORDER BY roi_number'));
                end
                temp_roi_num=fetchn(IMG.ROITrace & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'roi_number','ORDER BY roi_number');
                Fall(temp_roi_num,:)=temp_Fall;
            end
            
            key_ROI=fetch(IMG.ROI*EXP2.SessionEpoch &key,'ORDER BY roi_number');
            mean_f = mean(Fall,2);
            
            for iROI = 1:1:numel(key_ROI)
                key_ROI(iROI).mean_f = mean_f(iROI);
            end
            insert(self,key_ROI);
        end
        
    end
end
