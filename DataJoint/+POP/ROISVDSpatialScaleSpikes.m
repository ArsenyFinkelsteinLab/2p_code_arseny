%{
# Local correlation
-> EXP2.SessionEpoch
---
similarity_local_mean      : blob           # correlation of principal components weights between a given cell  and all of its neihgbors within radius_size, for each principal component. We  ecxlude neurons within min_lateral_distanceb from the seed
similarity_local_mean_shuffled      : blob           # correlation of principal components weights between a given cell  and all of its neihgbors within radius_size, for each principal component. We  ecxlude neurons within min_lateral_distanceb from the seed
radius_size_vector    : blob          # radius size, in um in lateral dimension
num_components        : int            # number of components analyzed, is limited to 1000
%}


classdef ROISVDSpatialScaleSpikes < dj.Computed
    properties
        keySource = EXP2.SessionEpoch  & IMG.ROI & IMG.ROISpikes   & POP.ROISVDSpikes & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            min_lateral_distance =25;
            
            rel_roi = (IMG.ROI - IMG.ROIBad) & key;
            rel_data = (POP.ROISVDSpikes & 'threshold_for_event=0' & 'time_bin=1.5') & rel_roi & key;
            
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

            %             function  [similarity_local,similarity_local_shuffled] = fn_local_similarity_space(W,x_all, y_all, radius_size, min_lateral_distance )

%                 radius_size = radius_size_vector(ir);
                %                 ir;
                %                 for i_c = 1:1:min(size(ROI_WEIGHTS,2),1000)
                %                     i_c;
                %                     W = ROI_WEIGHTS(:,i_c);
                %
                %                     % %                 %%% MAP for debug
                %                     %                 bins1 = prctile(current_svd_weigts, [0:5:100]);
                %                     %                 [N,edges,bin]=histcounts(current_svd_weigts,bins1);
                %                     %                 % ax1=axes('position',[position_x1(1), position_y1(1), panel_width1*2, panel_height1*2]);
                %                     %                 my_colormap=jet(numel(bins1));
                %                     %                 % my_colormap=plasma(numel(time_bins1));
                %                     %                 hold on
                %                     %                 for i_roi=1:1:size(key_ROI,1)
                %                     %                     plot(x_all(i_roi), y_all(i_roi),'.','Color',my_colormap(bin(i_roi),:),'MarkerSize',7)
                %                     %                 end
                %
