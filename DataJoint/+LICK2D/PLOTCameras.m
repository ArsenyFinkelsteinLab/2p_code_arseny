%{
#
-> EXP2.Session
---
%}


classdef PLOTCameras < dj.Computed
    properties
        
        keySource = EXP2.Session & TRACKING.TrackingTrial;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\behavior\cameras\'];
            
            session_date = fetch1(EXP2.Session & key,'session_date');
            filename = [ 'camera_anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date];
            
            
            
            st=fetchn((TRACKING.TrackingTrial & key)-TRACKING.TrackingTrialBad,'tracking_start_time');
%             histogram([st],[-5:0.1:5])      
                        histogram([st])            

            title(sprintf('tracking start time to mouth\n anm %d s%d %s', key.subject_id, key.session, session_date));
            
            if isempty(dir(dir_current_fig))
                mkdir (dir_current_fig)
            end
            
            filename =[filename];
            
            % filename =[filename '_' sprintf('threshold%d',floor(100*(key.threshold_for_event)))];
            figure_name_out=[ dir_current_fig filename];
            eval(['print ', figure_name_out, ' -dtiff  -r200']);
            
            
            insert(self,key);
            
        end
    end
end