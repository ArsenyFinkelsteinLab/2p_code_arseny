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
                    insert(self, key)
                    continue
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