%{
# ROI (Region of interest - e.g. cells)
-> IMG.Plane
roi_number                      : int           # roi number (restarts for every session)
---
roi_centroid_x_corrected                  : double        # ROI centroid x, pixels, within plane coordinates, corrected for ETL distortion
roi_centroid_y_corrected                  : double        # ROI centroid  y, pixels, within plane coordinates, corrected for ETL distortion
%}


classdef ROIPositionETL2 < dj.Imported
    properties
%         keySource = IMG.Plane & (EXP2.Session*EXP2.SessionID & IMG.Volumetric & (STIMANAL.SessionEpochsIncludedFinal & 'flag_include=1'));
        keySource = (IMG.Plane & IMG.PlaneCoordinates) - IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            D=fetch (IMG.ROI & key, 'roi_centroid_x','roi_centroid_y', 'ORDER BY roi_number');
            roi_centroid_x= [D.roi_centroid_x];
            roi_centroid_y= [D.roi_centroid_y];
            D= rmfield(D,'roi_centroid_x');
            D= rmfield(D,'roi_centroid_y');
            
            numberROI = size(D,1);
            
            z_pos_relative =fetchn(IMG.PlaneCoordinates &  key,'z_pos_relative');
            
            if z_pos_relative==0 ||  z_pos_relative==40 || z_pos_relative==30 || z_pos_relative==10 || z_pos_relative==20% no correction needed
                for iROI=1:1:numberROI
                    D(iROI).roi_centroid_x_corrected = roi_centroid_x(iROI);
                    D(iROI).roi_centroid_y_corrected = roi_centroid_y(iROI);
                end
                insert(self,D);
                
            elseif (z_pos_relative==60 ||  z_pos_relative==90 ||  z_pos_relative==120) % affine transform to correct for ETL abberations
                Affine_transform = fetchn(IMG.PlaneETLTransform*IMG.PlaneCoordinates & key & 'num_fiducials>=8' & sprintf('z_pos_relative=%d',z_pos_relative),'etl_affine_transform');
                if isempty(Affine_transform)
                   Affine_transform = fetchn(IMG.ETLTransform2 & key & sprintf('plane_depth=%d',z_pos_relative),'etl_affine_transform');
                end
                Affine_transform = cell2mat(Affine_transform);
                XY = [roi_centroid_x;roi_centroid_y; ones(1,size(roi_centroid_x,2))];
                XY_trans=Affine_transform*XY;
                for iROI=1:1:numberROI
                    D(iROI).roi_centroid_x_corrected = XY_trans(1,iROI);
                    D(iROI).roi_centroid_y_corrected = XY_trans(2,iROI);
                end
                insert(self,D);
                
            elseif z_pos_relative==80
               z_pos_relative=90;
                Affine_transform = fetchn(IMG.PlaneETLTransform*IMG.PlaneCoordinates & key & 'num_fiducials>=8' & sprintf('z_pos_relative=%d',z_pos_relative),'etl_affine_transform');
                if isempty(Affine_transform)
                   Affine_transform = fetchn(IMG.ETLTransform2 & key & sprintf('plane_depth=%d',z_pos_relative),'etl_affine_transform');
                end
                Affine_transform = cell2mat(Affine_transform);
                XY = [roi_centroid_x;roi_centroid_y; ones(1,size(roi_centroid_x,2))];
                XY_trans=Affine_transform*XY;
                for iROI=1:1:numberROI
                    D(iROI).roi_centroid_x_corrected = XY_trans(1,iROI);
                    D(iROI).roi_centroid_y_corrected = XY_trans(2,iROI);
                end
                insert(self,D);
            end
%             figure
%             hold on
%             mean_img=fetch1(IMG.Plane & key,'mean_img');
%             imagesc(mean_img);
%             colormap(gray)
%             plot(roi_centroid_x,roi_centroid_y,'.r')
%             plot(XY_trans(1,:),XY_trans(2,:),'.b')
%             axis equal;
        end
            
    end
end
