%{
# Distance of each ROI from all the other ROIs
-> EXP2.Session
---
roi_distance_lateral       : longblob          # matrix of lateral distances of each roi from all the other rois; we flatten the matrix into a 1D array, to reshape back use  mat = reshape(roi_distance_lateral,numel(roi_numbers),numel(roi_numbers))
roi_numbers                : longblob          # numbers of all rois

%}


classdef DistancePairwiseLateral < dj.Computed
    properties
        keySource = EXP2.Session & IMG.ROI & IMG.Mesoscope
    end
    methods(Access=protected)
        function makeTuples(self, key)
            key1=key;
            key2=key;
            
            roi_numbers=fetchn(IMG.ROI &key,'roi_number','ORDER BY roi_number');
            x_all=fetchn(IMG.ROI &key,'roi_centroid_x','ORDER BY roi_number');
            y_all=fetchn(IMG.ROI &key,'roi_centroid_y','ORDER BY roi_number');
            z_all=fetchn(IMG.ROI*IMG.PlaneCoordinates & key,'z_pos_relative','ORDER BY roi_number');

            x_pos_relative=fetchn(IMG.ROI*IMG.PlaneCoordinates &key,'x_pos_relative','ORDER BY roi_number');
            y_pos_relative=fetchn(IMG.ROI*IMG.PlaneCoordinates &key,'y_pos_relative','ORDER BY roi_number');
            
            x_all = x_all + x_pos_relative; x_all = x_all/0.75;
            y_all = y_all + y_pos_relative; y_all = x_all/0.5;
            
            
            
            dXY=zeros(numel(roi_numbers),numel(roi_numbers));
            d3D=zeros(numel(roi_numbers),numel(roi_numbers));
            parfor iROI=1:1:numel(roi_numbers)
                x=x_all(iROI);
                y=y_all(iROI);
                z=z_all(iROI);
                dXY(iROI,:)= sqrt((x_all-x).^2 + (y_all-y).^2); % in um
                d3D(iROI,:) = sqrt((x_all-x).^2 + (y_all-y).^2 + (z_all-z).^2); % in um
            end

            % we flatten the matrix into a 1D array, to reshape back use  mat = reshape(dXY,numel(roi_numbers),numel(roi_numbers))
            
            key1.roi_distance_lateral = dXY(:); %we flatten the matrix
            key1.roi_numbers = roi_numbers;
            key1.roi_distance_lateral=uint16(round(dXY(:)));
            % to reshape back use  mat = reshape(roi_distance_lateral,numel(roi_numbers),numel(roi_numbers))
            insert(self,key1);
            
            key2.roi_distance_3d = uint16(round(dXY(d3D(:)))); %we flatten the matrix
            key2.roi_numbers = roi_numbers;
            insert(self,key2);

            
        end
    end
end

