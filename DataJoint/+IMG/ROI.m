%{
# ROI (Region of interest - e.g. cells)
-> IMG.Plane
roi_number                      : int           # roi number (restarts for every session)
---
roi_number_uid                  : int           # roi uid (unique across sessions). Same roi registered across sessions would have the same uid. It wasn't unique until 2020.01.13
roi_centroid_x                  : double        # ROI centroid  x, pixels, within plane coordinates
roi_centroid_y                  : double        # ROI centroid  y, pixels, within plane coordinates
roi_radius                      : double        # ROI radius, pixels
roi_x_pix                       : longblob      # pixel indices, x
roi_y_pix                       : longblob      # pixel indices, y
roi_pixel_weight                : longblob      # pixel mask (fluorescence = sum(pixel_weight * frames[ypix,xpix,:]))
neuropil_pixels                 : longblob      # pixel indices, for the linearized matrix
f_mean                          : double        # mean ROI flouresence
f_median                        : double        # median ROI flouresence

%}


classdef ROI < dj.Imported
    properties
        keySource = IMG.Plane;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            local_path_plane_registered = fetchn(IMG.PlaneDirectory & key,'local_path_plane_registered');
            if isempty(local_path_plane_registered)==0 %for newer code
                S2P=load([local_path_plane_registered{1} 'Fall.mat']);
            else %for older code
                dir_data2 = fetchn(EXP2.SessionEpochDirectory &key,'local_path_session_registered');
                dir_data2 = dir_data2{1};
                S2P=load([dir_data2 '\suite2p\plane0\Fall.mat']);
            end
            
            numberROI = numel(S2P.stat);
            
            % Ensures cells are numbered across planes/FOVs for the same session
            kkkkk.subject_id=key.subject_id;
            kkkkk.session=key.session	;
            rel_temp = IMG.ROI & kkkkk;
            number_of_existing_ROIs_session = rel_temp.count;
            
            % Ensures the roi_number uid are unique. It wasn't unique until 2020.01.13
            rel_temp2 = IMG.ROI;
            number_of_existing_ROIs_all = rel_temp2.count;
            roi_number_uid = fetchn(IMG.ROI,'roi_number_uid');
            last_uniqueid = max(max(roi_number_uid),number_of_existing_ROIs_all);
            
            
            z_pos_relative =fetchn(IMG.PlaneCoordinates &  key,'z_pos_relative');
            for iROI=1:1:numberROI
                %                 iROI
                F = S2P.F(iROI,:);
                
                key_ROI=key;
                key_ROI.roi_number = iROI + number_of_existing_ROIs_session;
                key_ROI.roi_number_uid = iROI + last_uniqueid;
                key_ROI.roi_centroid_x = S2P.stat{iROI}.med(2); %note the unintuitive order in suite2p output
                key_ROI.roi_centroid_y = S2P.stat{iROI}.med(1);  %note the unintuitive order in suite2p output
                key_ROI.roi_x_pix = S2P.stat{iROI}.xpix;
                key_ROI.roi_y_pix = S2P.stat{iROI}.ypix;
                key_ROI.roi_pixel_weight = S2P.stat{iROI}.lam; %pixel mask (fluorescence = sum(pixel_weight * frames[ypix,xpix,:]))
                key_ROI.roi_radius = S2P.stat{iROI}.radius;
                key_ROI.neuropil_pixels = 1; %S2P.stat{iROI}.ipix_neuropil;
                key_ROI.f_mean = mean(F);
                key_ROI.f_median = median(F);
                insert(IMG.ROI,key_ROI);
                
                key_ROIdept=key;
                key_ROIdept.roi_number = iROI + number_of_existing_ROIs_session;
                key_ROIdept.z_pos_relative = z_pos_relative;
                
                insert(IMG.ROIdepth,key_ROIdept);
                
                
            end
            
        end
    end
end