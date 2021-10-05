%{
#
-> EXP2.BehaviorTrial
---
%}


classdef TrackingTrialBad < dj.Imported
    properties
        keySource = (EXP2.Session  & TRACKING.TrackingTrial);
    end
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            max_difference_in_num_frames=1; %if there only 1 frame difference between the 2 cameras, we tolerate it and not consider it a bad trial
            
            trials = fetchn(EXP2.BehaviorTrial & key,'trial','ORDER BY trial');
            go_t = fetchn(EXP2.BehaviorTrialEvent & key & 'trial_event_type="go"', 'trial_event_time','ORDER BY trial');
            
            
            ids = unique(fetchn(TRACKING.TrackingTrial & key,'tracking_device_id'));
            if numel(ids)<2 %in case only one camera is available
                for i =1:1:numel(trials)
                    key.trial=trials(i);
                    insert(self, key)
                end
                return
            end
            cam1 =struct2table(fetch(TRACKING.TrackingTrial & key & sprintf('tracking_device_id=%d',ids(1)),'*'));
            cam2 =struct2table(fetch(TRACKING.TrackingTrial & key & sprintf('tracking_device_id=%d',ids(2)),'*'));
            
            for i =1:1:numel(trials)
                
                idx1 = find(cam1.trial == trials(i));
                idx2 = find(cam2.trial == trials(i));
                key.trial=trials(i);
                
                if cam1.tracking_num_samples(idx1) ~=cam2.tracking_num_samples(idx2) % if there is a mismatch in the number of samples between the two cameras
                    
                    cam1_num_smp = cam1.tracking_num_samples(idx1);
                    cam2_num_smp = cam2.tracking_num_samples(idx2);
                    cam1_cam2_diff = abs(cam2_num_smp-cam1_num_smp);
                    if cam1_cam2_diff<=max_difference_in_num_frames
                        
                        [~,camera_idx_more_frames]=max([cam1_num_smp,cam2_num_smp]);
                        kkkk=key;
                        kkkk.tracking_device_id=ids(camera_idx_more_frames);
                        
                        KKKK=fetch(TRACKING.TrackingTrial & kkkk,'*');
                        KKKK_key = fetch(TRACKING.TrackingTrial & kkkk);
                        KKKK.tracking_num_samples=KKKK.tracking_num_samples-cam1_cam2_diff;
                        KKKK.tracking_duration=KKKK.tracking_duration-(1/KKKK.tracking_sampling_rate)*cam1_cam2_diff;
                        delQuick(TRACKING.TrackingTrial & KKKK_key);
                        insert(TRACKING.TrackingTrial,KKKK);
                        %                         pause(0.25);
                        
                    else
                        insert(self, key)
                        continue
                    end
                end
                
                if isempty(idx1) || isempty(idx2) %if one of the cameras did not record during this trial
                    insert(self, key)
                    continue
                end
                
                if cam1.tracking_start_time(idx1)>= go_t(i) || cam2.tracking_start_time(idx2)>= go_t(i) % in case of aberant (too short) trials
                    insert(self, key)
                    continue
                end
                
                if cam1.tracking_start_time(idx1)<0 || cam2.tracking_start_time(idx2)<0  % in case of aberant (too short) trials
                    insert(self, key)
                    continue
                end
                
            end
            
        end
    end
end