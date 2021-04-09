%{
#
-> EXP2.Session
---
%}


classdef PLOTLickport < dj.Computed
    properties
        
        keySource = EXP2.Session & TRACKING.VideoLickportPositionTrial;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\behavior\lickport_position_video\'];
            
            session_date = fetch1(EXP2.Session & key,'session_date');
            filename = [ 'lickport_anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date];
            
            
            
            L=fetch((TRACKING.VideoLickportPositionTrial*EXP2.TrialLickBlock & key)-TRACKING.VideoGroomingTrial,'*');
            roll=[L.roll_deg];
            
            
            if isnan(roll) %if there is no roll
                roll=0;
            end
            roll=mean(roll);
            
            x = [L.lickport_x];
            z=[L.lickport_z];
            
            
            for i = 1:1:numel(L)
                R = [cosd(roll) -sind(roll); sind(roll) cosd(roll)];
                point = [x(i);z(i)];
                rotpoint = R*point;
                x_rotated(i) = rotpoint(1);
                z_rotated(i) = rotpoint(2);
            end
            
            
            % We correct for Z that arrises from camera non-planarity with
            % the lickport motion 
            poly_fit  = polyfit(x_rotated',z_rotated',1);
            z_corrected = z_rotated -(x_rotated*poly_fit(1));
            

            subplot(2,2,1)
            plot(x,z,'.')
            xlabel('Medio-lateral (px)')
            ylabel('Dorsal-Ventral (px)');
            title(sprintf('Lickport position relative to mouth\n anm %d s%d %s', key.subject_id, key.session, session_date));
            
            subplot(2,2,2)
            plot(x_rotated,z_rotated,'.')
            xlabel('Medio-lateral (px)')
            ylabel('Dorsal-Ventral (px)');
            title(sprintf('Rotated roll=%.1f',mean(roll)));
            
            subplot(2,2,3)
            plot(x_rotated,z_corrected,'.')
            xlabel('Medio-lateral (px)')
            ylabel('Dorsal-Ventral (px)');
            title(sprintf('Z corrected'));
            
            
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