%{
# Field of View
-> IMG.FOV
---
map_baseline_f           : longblob      #  median activity of each pixel at presample period

%}


classdef FOVMapBaselineF < dj.Imported
    properties
        keySource = IMG.FOV & IMG.FOVRegisteredMovie;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            psth_timestamps = fetch1(IMG.FOVRegisteredMovie & key, 'psth_timestamps','ORDER BY outcome DESC LIMIT 1');
            frame_idx = psth_timestamps>=psth_timestamps(1) & psth_timestamps<(psth_timestamps(1)+1);
            movie_frame_number=find(frame_idx);
            counter=1;
            for i_f=1:1:numel(movie_frame_number)
                k.movie_frame_number = movie_frame_number(i_f);
                temp = fetchn(IMG.FOVRegisteredMovieFrame & key & k, 'fov_movie_trial_avg');
                %             M_avg=zeros([size(temp{1}),size(temp,1)]);
                for i_fr=1:1:size(temp,1)
                    M_avg(:,:,counter)=temp{i_fr};
                    counter=counter+1;
                end
            end
            
            
            %baseline flourescence for each pixel (based on 1 sec of the presample period)
            baselineF_2D=median(M_avg,3);
            key.map_baseline_f =baselineF_2D;
            insert(self, key);
        end
    end
end