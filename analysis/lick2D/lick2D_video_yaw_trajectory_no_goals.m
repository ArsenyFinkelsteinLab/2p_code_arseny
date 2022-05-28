function    lick2D_video_yaw_trajectory()
clf
key=[];
% key.subject_id = 463189;
% key.subject_id = 464724;
% key.subject_id = 464725;
% key.subject_id = 463190;
% key.subject_id = 462455; % AF23
key.subject_id = 462458; %AF17
% key.subject_id = 463192; %AF25
% key.subject_id = 463195; %AF24
% key.subject_id = 464728; %AF32


sessions_list = fetchn(EXP2.Session & TRACKING.VideoNthLickTrial & key, 'session');

for i_s = 3:1:numel(sessions_list)
    
    i_s
    clf
    key.session = sessions_list(i_s);
    roll = mean(fetchn((EXP2.TrialLickBlock & key) - TRACKING.VideoGroomingTrial,'roll_deg'));
    if isnan(roll) %if there is no roll
        roll=0;
    end
    %     Tx=fetchn(TRACKING.VideoTongueTrial& key,'licks_peak_x');
    %     Tx= [Tx{:}];
    %     Tz=fetchn(TRACKING.VideoTongueTrial& key,'licks_peak_z');
    %     Tz= [Tz{:}];
    
    post_list =unique(fetchn(EXP2.TrialLickPort & key,'lickport_pos_number'));
    colors = jet(numel(post_list));
    
    %% Extract roll from video
    %     T_all= fetch((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*TRACKING.VideoLickportPositionTrial*EXP2.TrialLickPort & key)-TRACKING.VideoGroomingTrial & 'trial>100' & 'lick_number_relative_to_firsttouch=1','lick_peak_x','lick_peak_z','lickport_x','lickport_z');
    %     x_l= [T_all.lickport_x];
    %     z_l= [T_all.lickport_z];
    num_bins=round(sqrt(numel(post_list)));
    M=[];
    roll=[];
    for i_b=1:1:num_bins
        row_x=[];
        row_z=[];
        for i_bb=1:1:num_bins
            kk.lickport_pos_number = i_b + (i_bb-1)*num_bins;
            T_bin= fetch((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*TRACKING.VideoLickportPositionTrial*EXP2.TrialLickPort & key & kk)-TRACKING.VideoGroomingTrial & 'trial>100' & 'lick_number_relative_to_firsttouch>1','lickport_x','lickport_z');
            row_x=[row_x,[T_bin.lickport_x]];
            row_z=[row_z,[T_bin.lickport_z]];
            %             hold on
            %             plot(row_x,row_z,'.')
        end
        p = polyfit(row_x,row_z,1);
        
        roll(i_b) = atand(p(1));
    end
    roll=-1*median(roll);
    
    
    
    %% repeating again to correct for shearing
    %
    %             R = [cosd(roll) -sind(roll); sind(roll) cosd(roll)];
    %
    %         pos_x= [T.lickport_x];
    %         pos_z= [T.lickport_z];
    %         for i_tr = 1:1:numel(pos_x)
    %             point = [pos_x(i_tr);pos_z(i_tr)];
    %             rotpoint = R*point;
    %             pos_x(i_tr) = rotpoint(1);
    %             pos_z(i_tr) = rotpoint(2);
    %         end
    
    
    
    
    
    for i_p=1:1:numel(post_list)
        k.lickport_pos_number = post_list(i_p);
        
        T= fetch((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*TRACKING.VideoLickportPositionTrial*EXP2.TrialLickPort & key & k)-TRACKING.VideoGroomingTrial & 'trial>100' & 'lick_touch_number>1','lick_peak_x','lick_peak_z','lickport_x','lickport_z','lick_yaw_lickbout');
        % %                 T= fetch((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*TRACKING.VideoLickportPositionTrial*EXP2.TrialLickPort & key & k)-TRACKING.VideoGroomingTrial & 'trial>100' & 'lick_touch_number>1','lick_touch_x','lick_touch_z','lickport_x','lickport_z');
        %         T= fetch((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*TRACKING.VideoLickportPositionTrial*EXP2.TrialLickPort & key & k)-TRACKING.VideoGroomingTrial & 'trial>100' & 'lick_number_relative_to_lickport_entrance<0','lick_peak_x','lick_peak_z','lickport_x','lickport_z');
        
        
        
        
        
        [pos_x, pos_z]=  fn_roll_correction(roll, [T.lickport_x],[T.lickport_z] );
        
        
        
        
        %
        %
        %         % Rescale and center the positions again after rotation
        %         %----------------------------
        %         x_scaling = max(pos_x(idx_trials_for_boundaries)) - min(pos_x(idx_trials_for_boundaries));
        %         z_scaling = max(pos_z(idx_trials_for_boundaries)) - min(pos_z(idx_trials_for_boundaries));
        %
        %         pos_x = pos_x-min(pos_x(idx_trials_for_boundaries));
        %         pos_z = pos_z-min(pos_z(idx_trials_for_boundaries));
        %
        %
        %         pos_x = pos_x/x_scaling;
        %         pos_z = pos_z/z_scaling;
        %
        %         pos_x = 2*(pos_x-0.5);
        %         pos_z = 2*(pos_z-0.5);
        
        
        
        
        
        
        
        subplot(2,2,1)
        
        hold on
        % lickport position:
%         plot(nanmean(pos_x),nanmean(pos_z),'o','MarkerSize',25,'Color',colors(i_p,:))
        %     plot(Tx,Tz,'.g')
        try
            [pos_x, pos_z]=  fn_roll_correction(roll, [T.lick_touch_x],[T.lick_touch_z] );
        catch
            [pos_x, pos_z]=  fn_roll_correction(roll, [T.lick_peak_x],[T.lick_peak_z] );
        end
        
        %                   [pos_x, pos_z]=  fn_roll_correction(roll, [T.lick_peak_x],[T.lick_peak_z] );
        %         plot(pos_x,pos_z,'.','Color',colors(i_p,:))
        
        plot(nanmean(pos_x),nanmean(pos_z),'.','Color',colors(i_p,:),'MarkerSize',25)
        set(gca,'YDir','reverse')
        %                 set(gca,'XDir','reverse')
        axis equal
                xlabel('ML position (pixels)');
               ylabel('DV position (pixels)');
        
        
        subplot(2,2,2)
        hold on
        plot(nanmean(pos_x),nanmean([T.lick_yaw_lickbout]),'.','Color',colors(i_p,:),'MarkerSize',25)
%         xlabel('ML position (pixels)');
%         ylabel('Theta angle (deg)');

        
    end
end
