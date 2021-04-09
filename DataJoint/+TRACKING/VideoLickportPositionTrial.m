%{
# lickport position relative to mouse mouth
-> EXP2.BehaviorTrial
---
lickport_x       =null             : double                    # Medio-Lateral coordinate in mm, . Left negative, Right positive, relative to midline. Measured based on front/bottom camera
lickport_y1      =null             : double                    # Anterior-Posterior coordinate in mm. Measured based on side camera relative to mouth
lickport_y2      =null             : double                    # Anterior-Posterior coordinate  in mm. Measured based on front/bottom camera relative to mouth
lickport_z       =null             : double                    # Dorso-Ventral coordinate in mm. Measured based on side camera relative to mouth


%}

classdef VideoLickportPositionTrial < dj.Computed
    properties
        keySource = (EXP2.Session  & TRACKING.VideoFiducialsTrial) ;
    end
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            % Rig specific settings
            %--------------------------------------------------------------
            k_camera1.tracking_device_id = 3; %side camera
            k_camera2.tracking_device_id = 4; %bottom (or top/front) camera
            side_camera_facing = 'left'; %'left' or 'right' mouse-facing direction as seen from the side view camera
            bottom_or_front_camera_facing = 'up'; %'up' or 'down' mouse-facing direction as seen from the front/bottom view camera
            % For the Mesoscope (Camera tracking_device_id =4, front) we set mouse-facing direction to 'up', because after intital clockwise 90 rotation in TRACKING.VideoFiducialsTrial the mouse appears to face 'up'
            reverse_cam2_x = -1; % '-1' left/right flip along the midline' '1' - no flip
            
            camera1_pixels_to_mm = 1; %% UPDATE
            camera2_pixels_to_mm=1; %% UPDATE
            
            % Analysis Parameters
            %--------------------------------------------------------------
                 
            p_threshold =0.99999;
            MinPeakInterval=0.075; %minimal time interval between peaks (licks) in time (seconds)
            tinterval_lickport_lickable =[0.5 1.5]; % (s) time interval in which we expect to see the lickport in lickable position (in case its a moving lickport). It doesn't have to be the full time interval
             
            
            %% Fetching trial and camera information
            rel_behavior_trial = (EXP2.BehaviorTrialEvent & key & 'trial_event_type="go"') - TRACKING.TrackingTrialBad ;
            rel_video_trial = (TRACKING.TrackingTrial & key & k_camera1) - TRACKING.TrackingTrialBad ;
            
            if rel_video_trial.count==0
                return
            end
            
            rel_fiducials_trial_cam1 = (TRACKING.VideoFiducialsTrial & key & k_camera1) - TRACKING.TrackingTrialBad ;
            rel_fiducials_session_cam1 =(TRACKING.VideoFiducialsSessionAvg & key & k_camera1);
            
            rel_fiducials_trial_cam2 = (TRACKING.VideoFiducialsTrial & key & k_camera2) - TRACKING.TrackingTrialBad ;
            rel_fiducials_session_cam2 =(TRACKING.VideoFiducialsSessionAvg & key & k_camera2);
            
            
            time_go = fetchn(rel_behavior_trial ,'trial_event_time','ORDER BY trial'); %relative to trial start
            tracking_start_time = fetchn(rel_video_trial ,'tracking_start_time','ORDER BY trial'); % relative to trial start
            num_frames = fetchn(rel_video_trial ,'tracking_num_samples','ORDER BY trial');
            tracking_datafile_num = fetchn(rel_video_trial ,'tracking_datafile_num','ORDER BY trial');
            tracking_datafile_path = fetchn(rel_video_trial ,'tracking_datafile_path','ORDER BY trial');
            
            trials = fetchn(rel_behavior_trial ,'trial','ORDER BY trial'); %relative to trial start
            frame_rate = fetch1(rel_video_trial ,'tracking_sampling_rate','LIMIT 1');
            
            
            %% Fiducial Tongue
            num=1;
            k.video_fiducial_name='TongueTip'; %from Camera1
            switch side_camera_facing
                case 'left'
                    offset_cam1_x =  fetchn(rel_fiducials_session_cam1& k,'fiduical_x_max_session');
                    reverse_cam1_x  = -1 ; %reverse
                case 'right'
                    offset_cam1_x =  fetchn(rel_fiducials_session_cam1& k,'fiduical_x_min_session');
                    reverse_cam1_x  = 1; % no reverse
            end
            offset_cam1_y =  fetchn(rel_fiducials_session_cam1 & k,'fiduical_y_min_session');
            reverse_cam1_y=1; % no reverse
            
            
            num=2;
            k.video_fiducial_name='TongueTip'; %from Camera2
            offset_cam2_x =  fetchn(rel_fiducials_session_cam2 & k,'fiduical_x_median_session');
            switch bottom_or_front_camera_facing
                case 'up'
                    offset_cam2_y =  fetchn(rel_fiducials_session_cam2& k,'fiduical_y_max_session');
                    reverse_cam2_y = -1 ; %reverse
                case 'down'
                    offset_cam2_y =  fetchn(rel_fiducials_session_cam2& k,'fiduical_y_min_session');
                    reverse_cam2_y = 1 ; % no reverse
            end
            fSession=[];
            fTrial=[];
            
            
            %Camera 1
            num=0;
            
            camera_num = 1;
            fiducial_names = fetchn(TRACKING.VideoFiducialsType & k_camera1,'video_fiducial_name');
            for i_f = 1:1:numel(fiducial_names)
                num = num+1;
                k.video_fiducial_name = fiducial_names{i_f};
                [fSession,fTrial] = fn_TRACKING_extract_and_center_fiducials (fSession, fTrial, rel_fiducials_session_cam1, rel_fiducials_trial_cam1, k, num, offset_cam1_x, offset_cam1_y, reverse_cam1_x, reverse_cam1_y,camera_num, camera1_pixels_to_mm, p_threshold);
            end
            
            %Camera 2
            camera_num = 2;
            fiducial_names = fetchn(TRACKING.VideoFiducialsType & k_camera2,'video_fiducial_name');
            for i_f = 1:1:numel(fiducial_names)
                num = num+1;
                k.video_fiducial_name = fiducial_names{i_f};
                [fSession,fTrial] = fn_TRACKING_extract_and_center_fiducials (fSession, fTrial, rel_fiducials_session_cam2, rel_fiducials_trial_cam2, k, num, offset_cam2_x, offset_cam2_y, reverse_cam2_x, reverse_cam2_y,camera_num, camera2_pixels_to_mm, p_threshold);
            end
            
            
            
            
            %% Looping over individual trials
            % Number of trials, filenames etc.
            key.session_date=fetch1(EXP2.Session & key,'session_date');
            insert_key_lickport_position = [];
            
            for ii =1:1:numel(trials)
                ii;
                
                
                % time vector
                t = [0:(1/frame_rate): (num_frames(ii)-1)/frame_rate] + tracking_start_time(ii)  - time_go(ii); % relative to Go cue. We will set it later relative to lickport move onset, in case of moving lickport
                
                
                %% Extracting lickport entrance/exit timing, in case there was a moving lickport
                
                num1=find([fTrial.camera]==1 & strcmp({fTrial.label}','lickport')');
                LICKPORT_AP_Cam1 = fTrial(num1).x{ii};
                LICKPORT_Z_Cam1 = fTrial(num1).y{ii};
                
                num2=find([fTrial.camera]==2 & strcmp({fTrial.label}','lickport')');
                LICKPORT_ML_Cam2 = fTrial(num2).x{ii};
                LICKPORT_AP_Cam2 = fTrial(num2).y{ii};
                
                idx_lickport_in = t>=tinterval_lickport_lickable(1) & t<tinterval_lickport_lickable(2);
                Z_lickport_in  = nanmedian(LICKPORT_Z_Cam1(idx_lickport_in));
                Z_lickport_before  = nanmedian(LICKPORT_Z_Cam1(t<0));
                %                 y_lickport_end  = nanmedian(y(end-100:end));
                
                idx_lickport_t_entrance_start = find(LICKPORT_Z_Cam1(t>0) < (Z_lickport_before -(Z_lickport_before - Z_lickport_in)*0.1),1,'first') + find(t>0,1,'first')-1;
                idx_lickport_t_entrance_end = find(LICKPORT_Z_Cam1(t>0)< (Z_lickport_in +(Z_lickport_before - Z_lickport_in)*0.1),1,'first') + find(t>0,1,'first')-1;
                idx_lickport_t_exit_start = find(LICKPORT_Z_Cam1(t>1)> (Z_lickport_in +(Z_lickport_before - Z_lickport_in)*0.1),1,'first') + find(t>1,1,'first');
                idx_lickport_t_exit_end = find(LICKPORT_Z_Cam1(t>1)> (Z_lickport_before -(Z_lickport_before - Z_lickport_in)*0.1),1,'first') + + find(t>1,1,'first');
                
                lickport_t_entrance_avg = nanmean([t(idx_lickport_t_entrance_start);t(idx_lickport_t_entrance_end)]);
                
                idx_lickport_lickable = idx_lickport_t_entrance_start:1:idx_lickport_t_exit_start;
                
                %% Lickport averge positon
                insert_key_lickport_position (ii).subject_id = key.subject_id;
                insert_key_lickport_position(ii).session = key.session;
                insert_key_lickport_position(ii).trial = trials(ii);
                insert_key_lickport_position(ii).lickport_x = nanmedian(LICKPORT_ML_Cam2(idx_lickport_lickable));
                insert_key_lickport_position(ii).lickport_y1 = nanmedian(LICKPORT_AP_Cam1(idx_lickport_lickable));
                insert_key_lickport_position(ii).lickport_y2 = nanmedian(LICKPORT_AP_Cam2(idx_lickport_lickable));
                insert_key_lickport_position(ii).lickport_z = nanmedian(LICKPORT_Z_Cam1(idx_lickport_lickable));
            end
            
            insert(self,insert_key_lickport_position);
            
        end
    end
end


