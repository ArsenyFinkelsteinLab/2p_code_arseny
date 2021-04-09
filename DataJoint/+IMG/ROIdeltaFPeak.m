%{
# Flourescent trace
-> EXP2.SessionEpoch
-> IMG.ROI
threshold_for_event   : double                           #      threshold in deltaf_overf
---
number_of_events       : int           #

%}


classdef ROIdeltaFPeak < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & IMG.ROIdeltaF;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            threshold_for_event_vector = [0.25, 0.5, 1, 2, 3];
            
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
            
            key_ROI=fetch(IMG.ROI*EXP2.SessionEpoch &key,'ORDER BY roi_number');
            
            for i_th = 1:1:numel(threshold_for_event_vector)
                key_peaks=key_ROI;
                threshold = threshold_for_event_vector(i_th);
                number_of_events = sum(Fall>=threshold,2);
                
                for iROI = 1:1:numel(key_ROI)
                    key_peaks(iROI).number_of_events = number_of_events(iROI);
                    key_peaks(iROI).threshold_for_event = threshold;
                end
                insert(self,key_peaks);
            end
            
        end
    end
end