%{
# Field of View
-> IMG.FOV
-> EXP.Outcome
-> EXP.TrialNameType
-> ANLI.EpochName2
---
map_activity_f           : longblob      # trial-averaged map of activity, flourescence for different trial epochs
map_activity_dff           : longblob      # trial-averaged map of activity df/f - relative to trial baseline, flourescence for different trial epochs

%}


classdef FOVMapActivity < dj.Imported
    properties
        keySource = IMG.FOVMovie;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            smoothing_3D_size=3;
%             blank_percentile=10; % blanking dark spots in the video (for display in movies only, not for savign in DJ)
            
            psth_timestamps = fetch1(IMG.FOVMovie & key, 'psth_timestamps');
            typical_time_sample_start = fetch1(IMG.FOVMovie & key, 'typical_time_sample_start');
            typical_time_sample_end = fetch1(IMG.FOVMovie & key, 'typical_time_sample_end');
            
            temp = fetchn(IMG.FOVMovieFrame & key, 'fov_movie_trial_avg', 'ORDER BY movie_frame_number');
            M_avg=zeros([size(temp{1}),size(temp,1)]);
            for i_fr=1:1:size(temp,1)
                M_avg(:,:,i_fr)=temp{i_fr};
            end
            
            
            
            %baseline flourescence for each pixel (based on 1 sec of the presample period)
            frame_idx = psth_timestamps>=(typical_time_sample_start-1) & psth_timestamps<typical_time_sample_start;
            key_baseline=key;
            baselineF_2D=median(M_avg(:,:,frame_idx),3);
            key_baseline.map_baseline_f =baselineF_2D;
            insert(IMG.FOVMapBaselineF, key_baseline);
            
            M_avg_rescaled=rescale(M_avg); % to prevent division of very smal numbers by very small numbers later
            baselineF_2D_rescaled=median(M_avg_rescaled(:,:,frame_idx),3);

            
            % average over all trial epochs
            key.trial_epoch_name = 'all';
            frame_idx = 1:1:numel(psth_timestamps);
            map = M_avg(:,:,frame_idx);
            map_rescaled = M_avg_rescaled(:,:,frame_idx);
            map_dff = fn_compute_map_dff (map_rescaled,  smoothing_3D_size, baselineF_2D_rescaled);
             key.map_activity_f = mean(map,3);
            key.map_activity_dff = mean(map_dff,3);
            insert(self,key);
            
       
            % average over sample epoch
            key.trial_epoch_name = 'sample';
            frame_idx = psth_timestamps>=typical_time_sample_start & psth_timestamps<typical_time_sample_end;
                map = M_avg(:,:,frame_idx);
            map_rescaled = M_avg_rescaled(:,:,frame_idx);
            map_dff = fn_compute_map_dff (map_rescaled,  smoothing_3D_size, baselineF_2D_rescaled);
             key.map_activity_f = mean(map,3);
            key.map_activity_dff = mean(map_dff,3);
            insert(self,key);

            % average over sample epoch
            key.trial_epoch_name = 'delay';
            frame_idx = psth_timestamps>=typical_time_sample_end & psth_timestamps<0;
               map = M_avg(:,:,frame_idx);
            map_rescaled = M_avg_rescaled(:,:,frame_idx);
            map_dff = fn_compute_map_dff (map_rescaled,  smoothing_3D_size, baselineF_2D_rescaled);
            key.map_activity_f = mean(map,3);
            key.map_activity_dff = mean(map_dff,3);
                        insert(self,key);

            % average over sample epoch
            key.trial_epoch_name = 'response';
            frame_idx = psth_timestamps>=0;
             map = M_avg(:,:,frame_idx);
            map_rescaled = M_avg_rescaled(:,:,frame_idx);
            map_dff = fn_compute_map_dff (map_rescaled,  smoothing_3D_size, baselineF_2D_rescaled);
            key.map_activity_f = mean(map,3);
            key.map_activity_dff = mean(map_dff,3);
                        insert(self,key);

        end
    end
end