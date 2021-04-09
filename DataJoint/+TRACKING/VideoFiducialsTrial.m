%{
#
-> TRACKING.TrackingTrial
-> TRACKING.VideoFiducialsType
---
fiducial_x                 : longblob                   # fiducial coordinate along the X axis of the video image
fiducial_y                 : longblob                   # fiducial coordinate along the Y axis of the video image
fiducial_p                          : longblob                   # fiducial probability
fiduical_x_median=null     : double
fiduical_y_median=null     : double
fiduical_x_min=null     : double
fiduical_y_min=null     : double
fiduical_x_max=null     : double
fiduical_y_max=null     : double
%}


classdef VideoFiducialsTrial < dj.Imported
    properties
        keySource = (EXP2.Session  & TRACKING.TrackingTrial)*(TRACKING.TrackingDevice& TRACKING.TrackingTrial);
    end
    methods(Access=protected)
        
        function makeTuples(self, key)
            % Remember that 0,0 is the upper left corner of the image
            % Note the for the Mesocscope Side Camera, defined as "Camera 4", we rotate the image because it was aquired when the camera was rotated by 90 degrees. It results in rotating the image 90 clockwise, and then flipping it along the left/right axis
            p_threshold =1; %for session average values we only take those values that passed
            
            V =fetch(TRACKING.TrackingTrial  & key,'*'); 
            if isempty(V) %one of the cameras is missing
                return
            end
            [~,temp_fiducial_labels,~] = xlsread(V(1).tracking_datafile_path,'B2:XX3');
            fiducial_labels = unique(temp_fiducial_labels(1,:));
            
            key_insert=fetch(TRACKING.TrackingTrial  & key,'LIMIT 1');
            key_insert=repmat(key_insert,1,numel(fiducial_labels));
            
            for ii =1:1:length(V) %loops over trials
                data = csvread(V(ii).tracking_datafile_path,3,1);
                kk.trial = V(ii).trial;
                
                % finding the index when the lickport is not moving
                idx_lickport_stationary = ((1:1:V(ii).tracking_num_samples)*0)';
                go_t = fetch1(EXP2.BehaviorTrialEvent & key & kk & 'trial_event_type="go"', 'trial_event_time');
                idx(1)= floor((go_t+0.5 -  V(ii).tracking_start_time)*  V(ii).tracking_sampling_rate);
                idx(2)= ceil((go_t+1.5 -  V(ii).tracking_start_time)*  V(ii).tracking_sampling_rate);
                if idx>0 %in case of some bad videos the trials are too short which generates negative values
                    idx_lickport_stationary(idx(1):idx(2))=1;
                end
                
                for jj= 1: length(fiducial_labels) %loops over fiducials
                    column_idx = find(strcmp(temp_fiducial_labels(1,:),fiducial_labels{jj}),1);
                    
                    fiducials_idx(jj).XColumn=column_idx;
                    fiducials_idx(jj).YColumn=column_idx+1;
                    fiducials_idx(jj).ProbColumn=column_idx+2;
                    
                    X=data(:,fiducials_idx(jj).XColumn);
                    Y=data(:,fiducials_idx(jj).YColumn);
                    
                    if key.tracking_device_id ==4 % Mesoscope specific setting! For front camera we rotate the image. It results in rotating the image 90 clockwise, and then flipping it along the left/right axis
                        X=data(:,fiducials_idx(jj).YColumn);
                        Y=data(:,fiducials_idx(jj).XColumn);
                    end
                    
                    P=data(:,fiducials_idx(jj).ProbColumn);
                    
                    key_insert(jj).trial=V(ii).trial;
                    key_insert(jj).video_fiducial_name=fiducial_labels{jj};
                    
                    key_insert(jj).fiducial_x=X;
                    key_insert(jj).fiducial_y=Y;
                    key_insert(jj).fiducial_p=P;
                    
                    if contains(fiducial_labels{jj},'lickport')
                        idx_include= P>=p_threshold  & idx_lickport_stationary;
                    else
                        idx_include= P>=p_threshold;
                    end
                    key_insert(jj).fiduical_x_median=nanmedian(X(idx_include));  %for median/min/max values we only take those values that passed
                    key_insert(jj).fiduical_y_median=nanmedian(Y(idx_include));  %for median/min/max values we only take those values that passed
                    key_insert(jj).fiduical_x_min=nanmin(X(idx_include));  %for median/min/max values we only take those values that passed
                    key_insert(jj).fiduical_y_min=nanmin(Y(idx_include));  %for median/min/max values we only take those values that passed
                    key_insert(jj).fiduical_x_max=nanmax(X(idx_include));  %for median/min/max values we only take those values that passed
                    key_insert(jj).fiduical_y_max=nanmax(Y(idx_include));  %for median/min/max values we only take those values that passed
                    
                end
                insert(self,key_insert);
                
            end
        end
    end
end