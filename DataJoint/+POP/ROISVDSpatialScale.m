%{
# Local correlation
-> EXP2.SessionEpoch
---
similarity_local_mean      : blob           # correlation of principal components weights between a given cell  and all of its neihgbors within radius_size, for each principal component. We  ecxlude neurons within min_lateral_distanceb from the seed
similarity_local_mean_shuffled      : blob           # correlation of principal components weights between a given cell  and all of its neihgbors within radius_size, for each principal component. We  ecxlude neurons within min_lateral_distanceb from the seed
radius_size_vector    : blob          # radius size, in um in lateral dimension
num_components        : int            # number of components analyzed, is limited to 1000
%}


classdef ROISVDSpatialScale < dj.Computed
    properties
        keySource = EXP2.SessionEpoch  & IMG.ROI & IMG.ROISpikes   & POP.ROISVD & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            min_lateral_distance =25;
            
            rel_roi = (IMG.ROI - IMG.ROIBad) & key;
            rel_data = (POP.ROISVD & 'threshold_for_event=0' & 'time_bin=1.5') & rel_roi & key;
            
            radius_size_vector=[50, 100, 500, 1000];
            %                         radius_size_vector=[100, 200, 500, 1000];
            
            x_all=fetchn(rel_roi,'roi_centroid_x','ORDER BY roi_number');
            y_all=fetchn(rel_roi,'roi_centroid_y','ORDER BY roi_number');
            
            x_pos_relative=fetchn(rel_roi*IMG.PlaneCoordinates ,'x_pos_relative','ORDER BY roi_number');
            y_pos_relative=fetchn(rel_roi*IMG.PlaneCoordinates,'y_pos_relative','ORDER BY roi_number');
            
            x_all = x_all + x_pos_relative;
            y_all = y_all + y_pos_relative;
            x_all = x_all/0.75;
            y_all = y_all/0.5;
            
            DATA=fetch(rel_data,'*');
            ROI_WEIGHTS = cell2mat({DATA.roi_components}');
            
            
            for ir = 1:1:numel(radius_size_vector)
                
                [similarity_local,similarity_local_shuffled] =       fn_local_similarity_space(ROI_WEIGHTS,x_all, y_all, radius_size_vector(ir), min_lateral_distance );
                
                SPATIAL_SCALE_mean(ir,:) = nanmean(cell2mat(similarity_local),1);
                SPATIAL_SCALE_mean_shuffled(ir,:) = nanmean(cell2mat(similarity_local_shuffled),1);
            end
            
            key.similarity_local_mean = SPATIAL_SCALE_mean;
            key.similarity_local_mean_shuffled = SPATIAL_SCALE_mean_shuffled;
            key.radius_size_vector = radius_size_vector;
            key.num_components = size(SPATIAL_SCALE_mean,2);
            
            insert(self,key);
        end
    end
end
