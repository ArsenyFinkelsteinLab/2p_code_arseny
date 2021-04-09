%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
component_id             : int
---
roi_coeff               : double            # for this component
%}

classdef ROIPCA < dj.Computed
    properties
        
        keySource = EXP2.SessionEpoch & IMG.ROIdeltaF & IMG.Mesoscope;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)

            num_components = 20;
            
            roi_list=fetchn(IMG.ROIdeltaF & key,'roi_number','ORDER BY roi_number');
            chunk_size=500;
            for i_chunk=1:chunk_size:numel(roi_list)
                roi_interval = [i_chunk, i_chunk+chunk_size];
                if roi_interval(end)>numel(roi_list)
                    roi_interval(end) = numel(roi_list)+1;
                end
                temp_Fall=cell2mat(fetchn(IMG.ROIdeltaF & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
                temp_roi_num=fetchn(IMG.ROIdeltaF & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'roi_number','ORDER BY roi_number');
                Fall(temp_roi_num,:)=temp_Fall;
            end
            
            Fall=zscore(Fall,[],2);
            [coeff,score,~, ~, explained]=pca(Fall','NumComponents',num_components);
            

            key_ROIs= fetch(IMG.ROIdeltaF & key, 'ORDER BY roi_number');
            
            for ic = 1:1:num_components
                for i=1:1:size(key_ROIs,1)
                    k(i).subject_id=key_ROIs(i).subject_id;
                    k(i).session=key_ROIs(i).session;
                    k(i).session_epoch_type=key_ROIs(i).session_epoch_type;
                    k(i).session_epoch_number=key_ROIs(i).session_epoch_number;
                    k(i).fov_num=key_ROIs(i).fov_num;
                    k(i).plane_num=key_ROIs(i).plane_num;
                    k(i).channel_num=key_ROIs(i).channel_num;
                    k(i).roi_number=key_ROIs(i).roi_number;
                    
                    k(i).component_id=ic;
                    k(i).roi_coeff = coeff(i,ic);
                end
                insert(self,k);
            end
            
            
        end
    end
end
