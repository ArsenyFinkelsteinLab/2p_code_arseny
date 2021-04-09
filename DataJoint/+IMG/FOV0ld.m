%{
# Field of View
-> EXP2.Session
fov_num                   : int                   # field of view number (restarts for every session)
---
fov_name                  : varchar(200)          # field of view name
fov_x_size                : double                # (pixels)              
fov_y_size                : double                # (pixels)            
imaging_frame_rate        : double                # (Hz) Should  be removed in  future versions. The frame rate is saved in FOV epoch
%}


classdef FOV < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            dir_data = fetchn(EXP2.SessionEpochDirectory &key,'local_path_session_epoch');
            dir_data = dir_data{1};
            allFiles = dir(dir_data); %gets  the names of all files and nested directories in this folder
            allFileNames = {allFiles(~[allFiles.isdir]).name}; %gets only the names of all files
            allFileNames =allFileNames(contains(allFileNames,'.tif'))';
            
            dir_data2 = fetchn(EXP2.SessionEpochDirectory &key,'local_path_session_registered');
            dir_data2 = dir_data2{1};
            
            try
                S2P=load([dir_data2 '\suite2p\plane' num2str(0) '\Fall.mat']);
            catch
                disp('Suite2p output file not found')
                return
            end
            
            [header]=scanimage.util.opentif([dir_data,allFileNames{1}]);
            % IMG.FOV
            k1=key;
            k1.fov_name='fov';
            k1.imaging_frame_rate = 0; %header.SI.hRoiManager.scanFrameRate  ;  Should  be removed in  future versions. The frame rate is saved in FOV epoch
            
            
            num_planes =  header.SI.hFastZ.numFramesPerVolume; %number of planes, for each FOV.
            
            
            if isfield(S2P.ops,'nrois') %mesoscope
                flag_mesoscope=1;
                FOVnums=S2P.ops.nrois;
                
                % Suite2p first saves the top(?) plane for FOV1, FOV2, etc... Then it saves the next (middle?) plane for FOV1, FOV2, etc
                %----------------------------------------------------------
                % So if there were 2 FOV, each imaged at 3 depth then it will save into directory as:
                % plane=0 FOV1, depth   1
                % plane1= FOV2, depth   1
                % plane2 = FOV1 depth   2
                % plane 3 = FOV2 depth  2
                % plane4 = FOV1 depth   3
                % plane 5 = FOV2 depth  3
                % FOVs in Suite2P are referred to as nrois
            else
                flag_mesoscope=0;
                FOVnums=1;
            end
            
            counter =0;
            for i_p=1:1:num_planes %loops across planes  we lop[ loop first across planes, because of the numbering in suite2p mesoscope output
                for i_f=1:1:FOVnums %loops across planes
                    k1.fov_num=i_f;
                    try
                        %count starts at plane0, and accumulates across FOVs
                        dir_suite2p_plane = [dir_data2 '\suite2p\plane' num2str(counter) '\'];
                        S2P=load([dir_suite2p_plane 'Fall.mat']);
                        counter =counter+1;
                    catch
                        disp('Suite2p output file not found')
                        return
                    end
                    
                    % IMG.FOV
                    if i_p==1
                        k1.fov_x_size = size(S2P.ops.meanImg,2);
                        k1.fov_y_size = size(S2P.ops.meanImg,1);
                        insert(IMG.FOV, k1);
                    end
                    
                    
                    % IMG.Plane
                    k2=key;
                    k2.fov_num=i_f;
                    k2.plane_num=i_p;
                    k2.channel_num=1;
                    k2.mean_img=S2P.ops.meanImg;
                    k2.mean_img_enhanced=S2P.ops.meanImgE;
                    insert(IMG.Plane, k2);
                    
                    
                    % IMG.PlaneCoordinates
                    k3=key;
                    k3.fov_num=i_f;
                    k3.plane_num=i_p;
                    k3.channel_num=1;
                    k3.flag_mesoscope=flag_mesoscope;
                    %                     k3.imaging_frame_rate_plane = header.SI.hRoiManager.scanFrameRate  ;
                    %                     k3.imaging_frame_rate_volume = header.SI.hRoiManager.scanVolumeRate	 ;
                    %                     k3.zoom = header.SI.hRoiManager.scanZoomFactor  ;
                    %                     k3.fov_x_size = size(S2P.ops.meanImg,2);
                    %                     k3.fov_y_size = size(S2P.ops.meanImg,1);
                    %                     k3.imaging_fov_deg = header.SI.hRoiManager.imagingFovDeg  ;
                    %                     k3.imaging_fov_um = header.SI.hRoiManager.imagingFovUm  ;
                    Zs =  header.SI.hFastZ.userZs;
                    if flag_mesoscope==0
                        Zs = Zs*(-1); %for some reason the Zs on Kayvon's rig are inverted. So the most negative z appears as the deepest. Here we invert it, so that positive numbers mean deeper.
                        
                        k3.x_pos_relative = 0;
                        k3.y_pos_relative = 0;
                        k3.z_pos_relative = Zs(i_p);
                        
                    elseif flag_mesoscope==1
                        k3.x_pos_relative = S2P.ops.dx;
                        k3.y_pos_relative = S2P.ops.dy;
                        k3.z_pos_relative = Zs(i_p)-Zs(1);
                    end
                    insert(IMG.PlaneCoordinates, k3);
                    
                    
                    % IMG.PlaneDirectory
                    k4=key;
                    k4.fov_num=i_f;
                    k4.plane_num=i_p;
                    k4.channel_num=1;
                    k4.local_path_plane_registered = dir_suite2p_plane;
                    insert(IMG.PlaneDirectory, k4);
                    
                end
            end
        end
    end
end