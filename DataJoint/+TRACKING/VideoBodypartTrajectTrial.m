%{
# Body parts trajectory, frames in which the bodypart is not visible are set to NaN
-> EXP2.BehaviorTrial
-> TRACKING.VideoBodypartType
---
traj_x       =null              : longblob                    # Medio-Lateral coordinate in mm, . Left negative, Right positive, relative to midline. Measured based on front/bottom camera
traj_y1       =null             : longblob                    # Anterior-Posterior coordinate in mm. Measured based on side camera
traj_y2       =null             : longblob                    # Anterior-Posterior coordinate  in mm. Measured based on front/bottom camera
traj_z       =null              : longblob                    # Dorso-Ventral coordinate in mm. Measured based on side camera
time_first_frame                : double                      # time of the first frame, relative to Go cue/ or movinglickport entrance in case lickport is moving
%}


%



classdef VideoBodypartTrajectTrial < dj.Computed
    properties
        keySource = (EXP2.Session  & TRACKING.VideoFiducialsTrial) ;
    end
    methods(Access=protected)
        
        function makeTuples(self, key)
        end
        
    end
end

