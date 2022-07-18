%{
# Flourescent trace
-> EXP2.SessionEpoch
-> IMG.ROI
---
spikes_trace      : longblob   # (s) deconvolved trace for each frame
%}


classdef ROISpikes < dj.Imported
    properties
        keySource = (EXP2.SessionEpoch & IMG.ROI) - IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            
            local_path_plane_registered = fetchn(IMG.PlaneDirectory & key,'local_path_plane_registered');
            if isempty(local_path_plane_registered) % for older code
                dir_data2 = fetchn(EXP2.SessionEpochDirectory &key,'local_path_session_registered');
                dir_data2 = dir_data2{1};
                try
                    S2P=load([dir_data2 '\suite2p\plane0\Fall.mat']);
                catch
                    disp('Suite2p output file not found')
                    return
                end
            end
            
            key_ROITrace=fetch(IMG.ROI&key,'ORDER BY roi_number');
            numberROI=numel(key_ROITrace);
            
            
            previous_plane_num =0;
            previous_fov_num =0;
            s2p_roi=0;
            
            current_plane_num =key_ROITrace(1).plane_num;
            current_fov_num =key_ROITrace(1).fov_num;
            kkkk.plane_num = current_plane_num;
            kkkk.fov_num = current_fov_num;
            start_frame = fetchn(IMG.SessionEpochFramePlane & key & kkkk,'session_epoch_plane_start_frame');
            end_frame = fetchn(IMG.SessionEpochFramePlane & key & kkkk,'session_epoch_plane_end_frame');
            missing_frames_epoch_plane = fetchn(IMG.SessionEpochFramePlane & key & kkkk,'missing_frames_epoch_plane');
            
            
            for iROI=1:1:numberROI
                iROI;
                
                current_plane_num =key_ROITrace(iROI).plane_num;
                current_fov_num =key_ROITrace(iROI).fov_num;
                
                if previous_fov_num~=current_fov_num || previous_plane_num~=current_plane_num
                    keydirectory=key;
                    keydirectory.fov_num=key_ROITrace(iROI).fov_num;
                    keydirectory.plane_num=key_ROITrace(iROI).plane_num;
                    keydirectory.channel_num=key_ROITrace(iROI).channel_num;
                    local_path_plane_registered = fetch1(IMG.PlaneDirectory & keydirectory,'local_path_plane_registered');
                    try
                        S2P=load([local_path_plane_registered 'Fall.mat']);
                    catch
                        local_path_plane_registered(1)='G';
                        try
                            S2P=load([local_path_plane_registered 'Fall.mat']);
                        catch
                            disp('Suite2p output file not found')
                            return
                        end
                    end
                    s2p_roi = 1;
                    
                    kkkk.plane_num = current_plane_num;
                    kkkk.fov_num = current_fov_num;
                    start_frame = fetchn(IMG.SessionEpochFramePlane & key & kkkk,'session_epoch_plane_start_frame');
                    end_frame = fetchn(IMG.SessionEpochFramePlane & key & kkkk,'session_epoch_plane_end_frame');
                    missing_frames_epoch_plane = fetchn(IMG.SessionEpochFramePlane & key & kkkk,'missing_frames_epoch_plane');
                    
                end
                
                % in case they are missing frames in this plane at the end of the epoch (should be no more than 1 missing frame per epoch, due to volumetric imaging) we 'pad' it by adding frames identical to the last one
                key_ROITrace(iROI).spikes_trace = [S2P.spks(s2p_roi,start_frame:end_frame),  repmat(S2P.spks(s2p_roi,end_frame),1,missing_frames_epoch_plane)]; % if missing_frames_epoch_plane=0 then we don't add anything
                
                key_ROITrace(iROI).session_epoch_type = key.session_epoch_type;
                key_ROITrace(iROI).session_epoch_number = key.session_epoch_number;
                
                
                
                k2=key_ROITrace(iROI);
                insert(self, k2);
                s2p_roi = s2p_roi +1;
                previous_fov_num = current_fov_num;
                previous_plane_num = current_plane_num;
            end
        end
    end
end




%             key_ROITrace=fetch(IMG.ROI&key,'ORDER BY roi_number');
%             dir_data2 = fetchn(EXP2.SessionEpochDirectory &key,'local_path_session_registered');
%             dir_data2 = dir_data2{1};
%             try
%             S2P=load([dir_data2 '\suite2p\plane0\Fall.mat']);
%             catch
%                 disp('Suite2p output file no found')
%                 return
%             end
%             numberROI = numel(S2P.stat);
%
%             start_frame = fetchn(IMG.SessionEpochFrame & key,'session_epoch_start_frame');
%             end_frame = fetchn(IMG.SessionEpochFrame & key,'session_epoch_end_frame');
%
%             for iROI=1:1:numberROI
%                 iROI;
%                 key_ROITrace(iROI).spikes_trace = S2P.spks(iROI,start_frame:end_frame);
%                 key_ROITrace(iROI).session_epoch_type = key.session_epoch_type;
%                 key_ROITrace(iROI).session_epoch_number = key.session_epoch_number;
%
%                 k2=key_ROITrace(iROI);
%                 insert(self, k2);
%             end
%         end
%     end
% end