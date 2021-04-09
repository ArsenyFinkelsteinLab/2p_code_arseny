%{
# ROI responses to each photostim group
-> EXP2.SessionEpoch
-> IMG.ROI
radius_size                      : double           # radius size
---
corr_local=null   : double           # correlation of dff between a given cell  and all of its neihgbors within radius_size
%}


classdef ROICorrLocal < dj.Computed
    properties
        keySource = (EXP2.SessionEpoch  & IMG.ROI & IMG.ROIdeltaF & IMG.Mesoscope) - EXP2.SessionEpochSomatotopy;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            radius_size_vector=[20,30,40,50,100];
            try
                frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            catch
                frame_rate= fetch1(IMG.FOV & key, 'imaging_frame_rate');
            end
            
            key_ROI=fetch(IMG.ROI&key,'ORDER BY roi_number');
            
            x_all=fetchn(IMG.ROI &key,'roi_centroid_x','ORDER BY roi_number');
            y_all=fetchn(IMG.ROI &key,'roi_centroid_y','ORDER BY roi_number');
            
            x_pos_relative=fetchn(IMG.ROI*IMG.PlaneCoordinates &key,'x_pos_relative','ORDER BY roi_number');
            y_pos_relative=fetchn(IMG.ROI*IMG.PlaneCoordinates &key,'y_pos_relative','ORDER BY roi_number');
            
            x_all = x_all + x_pos_relative;
            y_all = y_all + y_pos_relative;
            x_all = x_all/0.75;
            y_all = y_all/0.5;

            roi_list=fetchn(IMG.ROIdeltaF &key,'roi_number','ORDER BY roi_number');
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
            
            for ir=1:1:numel(radius_size_vector)
                fn_local_correlations_space(key, key_ROI,Fall,x_all, y_all, radius_size_vector(ir) )
            end
            
        end
    end
end


