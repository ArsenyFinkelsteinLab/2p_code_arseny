%{
# Flourescent trace
-> EXP2.SessionEpoch
-> IMGROI
---
mean_dff   : double                          #
min_dff   : double                           #
max_dff   : double                           #
median_dff   : double                        #
%}


classdef ROIdeltaFStats < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & IMG.ROIdeltaF;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            roi_list=fetchn(IMG.ROIdeltaF & key,'roi_number','ORDER BY roi_number');
            chunk_size=500;
            for i_chunk=1:chunk_size:numel(roi_list)
                roi_interval = [i_chunk, i_chunk+chunk_size];
                if roi_interval(end)>numel(roi_list)
                    roi_interval(end) = numel(roi_list)+1;
                end
                try
                    temp_Fall=cell2mat(fetchn(IMG.ROIdeltaF & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
                catch
                    temp_Fall=cell2mat(fetchn(IMG.ROIdeltaF & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
                end
                temp_roi_num=fetchn(IMG.ROIdeltaF & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'roi_number','ORDER BY roi_number');
                Fall(temp_roi_num,:)=temp_Fall;
            end
            
            key_ROI=fetch(IMG.ROI*EXP2.SessionEpoch & key,'ORDER BY roi_number');
            for iROI = 1:1:numel(key_ROI)
                key_ROI(iROI).mean_dff = mean(Fall(iROI,:));
                key_ROI(iROI).min_dff =  min(Fall(iROI,:));
                key_ROI(iROI).max_dff =  max(Fall(iROI,:));
                key_ROI(iROI).median_dff =  median(Fall(iROI,:));

            end
            insert(self,key_ROI);
        end
        
    end
end
