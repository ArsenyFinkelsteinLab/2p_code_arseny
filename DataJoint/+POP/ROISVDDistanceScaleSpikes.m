%{
# Local correlation
-> EXP2.SessionEpoch
---
distance_tau     : blob           # spatial scale for each component of the similarity of its weights
num_components        : int            # number of components analyzed, is limited to 1000
rd_distance_components : blob             #  mean relative difference between weights values for each component as a funciton of distance betwee pairs. shuffled values are already subtracted. high values mean high similarity
distance_bins_centers : blob              #
%}


classdef ROISVDDistanceScaleSpikes < dj.Computed
    properties
        keySource = EXP2.SessionEpoch  & IMG.ROI  & POP.ROISVDSpikes & (IMG.Mesoscope);
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            minimal_distance=25; %microns
            
            rel_roi = (IMG.ROI - IMG.ROIBad) & key;
            rel_data = (POP.ROISVDSpikes & 'threshold_for_event=0' & 'time_bin=1.5') & rel_roi & key;
            
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
            
            
            dXY_mat=zeros(numel(x_all),numel(x_all));
            %             d3D=zeros(numel(x_all),numel(x_all));
            parfor iROI=1:1:numel(x_all)
                x=x_all(iROI);
                y=y_all(iROI);
                %                 z=z_all(iROI);
                dXY_mat(iROI,:)= sqrt((x_all-x).^2 + (y_all-y).^2); % in um
                %                 d3D(iROI,:) = sqrt((x_all-x).^2 + (y_all-y).^2 + (z_all-z).^2); % in um
            end
            
            idx_diagonal = 1:size(dXY_mat, 1)+1:numel(dXY_mat);
            idx_up_triangle=~logical(tril(dXY_mat));
            idx_up_triangle(idx_diagonal) = false;
            idx_up_triangle(dXY_mat<minimal_distance) = false;

            dXY_mat = dXY_mat(idx_up_triangle);
            
%              distance_bins=[0:50:200,300,400,500:250:2000, 2500:500:4000, inf]; % in microns
            distance_bins=[0:50:200,300:100:1000, 1250:250:2000, inf];
            distance_bins_centers= distance_bins(1:end-1)+diff(distance_bins(1:end))/2;
            distance_bins_centers(end)=distance_bins_centers(end-1) + distance_bins_centers(end-2)-distance_bins_centers(end-3);

            for i_d=1:1:numel(distance_bins)-1
                DISTANCE_IDX{i_d} = dXY_mat >= distance_bins(i_d) & dXY_mat < distance_bins(i_d+1);
            end
            
            num_components = min(size(ROI_WEIGHTS,2),1000);
            tic
            [distance_tau,rd_distance_components] =   fn_spatial_scale(ROI_WEIGHTS, DISTANCE_IDX,idx_up_triangle, distance_bins_centers, num_components);
            toc
            key.distance_tau = distance_tau;
            key.num_components = num_components;
            key.rd_distance_components = rd_distance_components;
            key.distance_bins_centers = distance_bins_centers;

            insert(self,key);
        end
    end
end

