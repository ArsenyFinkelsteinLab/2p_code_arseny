%{
# Field of View
-> IMG.FOVRegisteredMovie
movie_frame_number           : int
---
fov_movie_trial_avg          : longblob

%}


classdef FOVRegisteredMovieFrame < dj.Part
     properties(SetAccess=protected)
        master= IMG.FOVRegisteredMovie
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
        end
    end
end