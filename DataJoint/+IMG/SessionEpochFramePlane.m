%{
# Session epoch frames for each plane in case some planes has 1 frame less due to volumetric imaging
-> EXP2.SessionEpoch
-> IMG.Plane
---
session_epoch_plane_start_frame    : double   #  session epoch start frame relative to the beginning of  the session,
session_epoch_plane_end_frame      : double   #  session epoch start frame relative to the beginning of  the session
missing_frames_epoch_plane         : int      # how many frames, if any, are missing at the end of the epoch for a given plane
%}


classdef SessionEpochFramePlane < dj.Computed
    properties
        %         keySource = EXP2.SessionEpoch*IMG.Plane & IMG.PlaneSuite2p;
        keySource = IMG.Plane & IMG.PlaneSuite2p;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            k.session=key.session;
            k.subject_id=key.subject_id;
            frames_per_folder_all_planes = cell2mat(fetchn(IMG.PlaneSuite2p & k,'frames_per_folder'));
            max_frames_all_planes_epochs = max(frames_per_folder_all_planes,[],1);
            frames_current_plane = cell2mat(fetchn(IMG.PlaneSuite2p & key,'frames_per_folder'));
            
            session_epoch_type = fetchn(EXP2.SessionEpoch & key,'session_epoch_type', 'ORDER BY session_epoch_number');
            
            end_frame=0;
            for i_epochs = 1:1:numel(max_frames_all_planes_epochs)
                start_frame = end_frame+1;
                end_frame = start_frame + frames_current_plane(i_epochs)-1;
                key.session_epoch_plane_start_frame = start_frame;
                key.session_epoch_plane_end_frame= end_frame;
                if frames_current_plane(i_epochs) < max_frames_all_planes_epochs(i_epochs)
                    key.missing_frames_epoch_plane = max_frames_all_planes_epochs(i_epochs) - frames_current_plane(i_epochs);
                else
                    key.missing_frames_epoch_plane=0;
                end
                
                key.session_epoch_number = i_epochs;
                key.session_epoch_type = session_epoch_type {i_epochs};
                insert(self, key);
            end
        end
    end
end