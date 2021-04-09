%{
# Field of View parameters for each epoch. We save it separately for each epoch because the frame rate can change for every epoch. 
-> EXP2.SessionEpoch
---
imaging_frame_rate               : double     # from scanimage (Hz). Imaging rate of a volume (or of a single plane, if there is only one plane)
imaging_frame_rate_plane         : double     # from scanimage (Hz). Imaging rate of a single plane
imaging_frame_rate_volume        : double     # from scanimage (Hz). Imaging rate of a volume (multiple planes, or FOVs in case of mesoscope).  In case there is only a single plane, than the imaging_frame_rate_volume is the same as the imaging_frame_rate_plane
zoom                             : double     # from scanimage    Should be moved to a separate table (under FOV, not under Epochs in future versions
imaging_fov_deg = null           : blob       # from scanimage    Should be moved to a separate table (under FOV, not under Epochs in future versions
imaging_fov_um = null            : blob       # from scanimage    Should be moved to a separate table (under FOV, not under Epochs in future versions
%}


classdef FOVEpoch < dj.Imported
    methods(Access=protected)
        function makeTuples(self, key)
            dir_data = fetchn(EXP2.SessionEpochDirectory &key,'local_path_session_epoch');
            
            dir_data = dir_data{1};
         
            
            allFiles = dir(dir_data); %gets  the names of all files and nested directories in this folder
            allFileNames = {allFiles(~[allFiles.isdir]).name}; %gets only the names of all files
            allFileNames =allFileNames(contains(allFileNames,'.tif'))';
            
            if isempty(allFileNames)
                disp('No tiff files found')
                return
            end
            [header]=scanimage.util.opentif([dir_data,allFileNames{1}]);
            k1=key;

            k1.imaging_frame_rate = header.SI.hRoiManager.scanVolumeRate  ;
            k1.imaging_frame_rate_plane = header.SI.hRoiManager.scanFrameRate  ;
            k1.imaging_frame_rate_volume = header.SI.hRoiManager.scanVolumeRate	 ;

            k1.zoom = header.SI.hRoiManager.scanZoomFactor  ;
            k1.imaging_fov_deg = header.SI.hRoiManager.imagingFovDeg  ;
            k1.imaging_fov_um = header.SI.hRoiManager.imagingFovUm  ;

            insert(self, k1);
            
        end
    end
end