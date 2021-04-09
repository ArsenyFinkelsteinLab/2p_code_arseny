%{
# Field of View
-> IMG.FOV
-> EXP2.Outcome
-> EXP2.TrialNameType
-> EXP2.EpochName2
---
map_activity_f           : longblob      # trial-averaged map of activity, flourescence for different trial epochs
map_activity_dff         : longblob    # trial-averaged map of activity df/f - relative to trial baseline, flourescence for different trial epochs

%}


classdef FOVMapActivity < dj.Imported
    properties
        keySource = IMG.FOVRegisteredMovie;
    end
    methods(Access=protected)
        function makeTuples(self, key)
                        smoothing_3D_size=5;
            smoothing_2D_size=3; % the actual smoothing window is (smoothing_2D_size*2 +1)
            z_score_threshold=1; %zero pixels with absolute z-score below 0.5, in the deltaf map
            
            
            psth_timestamps = fetch1(IMG.FOVRegisteredMovie & key, 'psth_timestamps');
            typical_time_sample_start = fetch1(IMG.FOVRegisteredMovie & key, 'typical_time_sample_start');
            typical_time_sample_end = fetch1(IMG.FOVRegisteredMovie & key, 'typical_time_sample_end');
            
            temp = fetchn(IMG.FOVRegisteredMovieFrame & key, 'fov_movie_trial_avg', 'ORDER BY movie_frame_number');
            M_avg=zeros([size(temp{1}),size(temp,1)]);
            for i_fr=1:1:size(temp,1)
                M_avg(:,:,i_fr)=temp{i_fr};
            end
            
            
            %baseline flourescence for each pixel (based on 1 sec of the presample period averaged over all trial-types/conditions)
            frame_idx = psth_timestamps>=psth_timestamps(1) & psth_timestamps<(psth_timestamps(1)+1);
            
%             b=M_avg(:,:,frame_idx);
% %             smoothing_3D_size=5;
% %             b = smooth3(b,'gaussian',smoothing_3D_size); %3D smoothing in x-y-z
%             
%             
%             baselineF_2D=median(b,3);
            baselineF_2D = fetch1(IMG.FOVMapBaselineF & key, 'map_baseline_f');
            baselineF_2D_smoothed = smooth2a(baselineF_2D,smoothing_2D_size,smoothing_2D_size);
            blank_idx=zscore(baselineF_2D_smoothed(:))<-1;
%             z=zscore(b(:));
%             b(z<-1)=1000;
            
            % average over all trial epochs
            key.trial_epoch_name = 'all';
            frame_idx = 1:1:numel(psth_timestamps);
            map = M_avg(:,:,frame_idx);
            [map_f_smoothed, map_dff_smoothed] = fn_compute_map_dff2 (map,  smoothing_3D_size, baselineF_2D_smoothed, z_score_threshold, blank_idx);
            key.map_activity_f = mean(map_f_smoothed,3);
            key.map_activity_dff = mean(map_dff_smoothed,3);
            insert(self,key);
            
            
            % average over sample epoch
            key.trial_epoch_name = 'sample';
            frame_idx = psth_timestamps>=typical_time_sample_start & psth_timestamps<typical_time_sample_end;
            map = M_avg(:,:,frame_idx);
            [map_f_smoothed, map_dff_smoothed] =fn_compute_map_dff2 (map,  smoothing_3D_size, baselineF_2D_smoothed, z_score_threshold, blank_idx);
            key.map_activity_f = mean(map_f_smoothed,3);
            key.map_activity_dff = mean(map_dff_smoothed,3);
            insert(self,key);
            
            % average over delay epoch
            key.trial_epoch_name = 'delay';
            frame_idx = psth_timestamps>=typical_time_sample_end & psth_timestamps<0;
            map = M_avg(:,:,frame_idx);
            [map_f_smoothed, map_dff_smoothed] = fn_compute_map_dff2 (map,  smoothing_3D_size, baselineF_2D_smoothed, z_score_threshold, blank_idx);
            key.map_activity_f = mean(map_f_smoothed,3);
            key.map_activity_dff = mean(map_dff_smoothed,3);
            insert(self,key);
            
            % average over response epoch
            key.trial_epoch_name = 'response';
            frame_idx = psth_timestamps>=0;
            map = M_avg(:,:,frame_idx);
            [map_f_smoothed, map_dff_smoothed] =fn_compute_map_dff2 (map,  smoothing_3D_size, baselineF_2D_smoothed, z_score_threshold, blank_idx);
            key.map_activity_f = mean(map_f_smoothed,3);
            key.map_activity_dff = mean(map_dff_smoothed,3);
            insert(self,key);
            
        end
    end
end