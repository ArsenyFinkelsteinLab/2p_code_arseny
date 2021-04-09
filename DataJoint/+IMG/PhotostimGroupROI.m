%{
# PhotostimGroup ROI
-> IMG.PhotostimGroup
-> IMG.ROI
---
flag_neuron_or_control            :int                    # 1 neuron 0 control
photostim_center_x                : double                # (pixels)
photostim_center_y                : double                # (pixels)
closest_neuron_center_x           : double                # (pixels)
closest_neuron_center_y           : double                # (pixels)
distance_to_closest_neuron        : double                # (pixels)
%}


classdef PhotostimGroupROI < dj.Imported
    properties
        %         keySource = IMG.PhotostimGroup;
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            pixel_offset = 0;
            non_neural_targets = 0; % assuming the first targets are neuorns and the last non_neural_targets targets are control sites
            
            % load dat file containing the photostimulation groups info
            dir_data1 = fetch1(EXP2.SessionEpochDirectory & key,'local_path_session');
            allFiles = dir(dir_data1); %gets  the names of all files and nested directories in this folder
            allFileNames = {allFiles(~[allFiles.isdir]).name}; %gets only the names of all files
            allFileNames =allFileNames(contains(allFileNames,'dat.mat'))';
            if ~isempty(allFileNames) % if dat file is common to all session
                dat = (load([dir_data1 'dat.mat']));
            else %if there is a dat file specific to session epoch
                dir_data2 = fetch1(EXP2.SessionEpochDirectory & key,'local_path_session_epoch');
                dat = (load([dir_data2 'dat.mat']));
            end
            dat=dat.dat;
            
            dat2.photostim_groups=dat.photostim_groups;
            
            if ~isfield(dat,'rect')
                rect = [-4.9091, -4.9091; 4.9091 -4.9091; 4.9091 4.9091; -4.9091 4.9091]; %Have to be fixed. Check why this is missing in some of the dat files. This is likely true only for the typical zoom size
                dat.rect = rect;
            end
            if ~isfield(dat,'plane')
                dat.plane=1;
            end
            dat2.rect=dat.rect;
            dat2.plane=dat.plane; %the photostim plane. 1 by default
            dat2.roi=dat.roi;
            k5=key;
            k5.dat_file=dat2;
            insert(IMG.PhotostimDATfile,k5);
            
            roi=dat.roi;
            close all;
            SI_xy = cell2mat({roi.centroid}'); % from SI
            SI_xy(:,1) = SI_xy(:,1) - pixel_offset;
            
            key.plane_num = dat.plane; %the photostim plane. 1 by default (top most)
            key.fov_num =  1; % 1 by default
            key.channel_num =  1;
            
            ROI=fetch((IMG.ROI & IMG.ROIGood) & key,'*', 'ORDER BY roi_number'); % from DataJoint
            DJ_xy(:,1) =  [ROI.roi_centroid_x]';
            DJ_xy(:,2) =  [ROI.roi_centroid_y]';
%             
%             k1 = fetch(IMG.Plane & key);
%             key.fov_num =  k1.fov_num;
%             key.plane_num =  k1.plane_num;
%             key.channel_num =  k1.channel_num;
            


            k2 = repmat(key,size(SI_xy,1),1);
            for i_g=1:1:size(SI_xy,1)
                dx = SI_xy(i_g,1) - DJ_xy(:,1);
                dy = SI_xy(i_g,2) - DJ_xy(:,2);
                [distance_to_closest_ROI , idx_closest_ROI] = min(sqrt(dx.^2 + dy.^2));
                %for debug                 DJ_xy(idx_closest_ROI,:);
                k2(i_g).photostim_group_num = i_g;
                k2(i_g).roi_number = ROI(idx_closest_ROI).roi_number;
                k2(i_g).photostim_center_x = SI_xy(i_g,1);
                k2(i_g).photostim_center_y = SI_xy(i_g,2);
                k2(i_g).closest_neuron_center_x = DJ_xy(idx_closest_ROI,1);
                k2(i_g).closest_neuron_center_y = DJ_xy(idx_closest_ROI,2);
                k2(i_g).distance_to_closest_neuron = distance_to_closest_ROI;
                
                if i_g>(size(SI_xy,1)-non_neural_targets +2) %finds non-neural targets
                    k2(i_g).flag_neuron_or_control  = 0;
                else
                    k2(i_g).flag_neuron_or_control  = 1;
                end
            end
            
            %             hold on;
            %             plot(DJ_xy(:,1),DJ_xy(:,2),'ok');
            %             plot(SI_xy(:,1),SI_xy(:,2),'om');
            
            insert(self, k2);
        end
    end
end