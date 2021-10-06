%{
# units are cm, deg, and seconds
-> EXP2.BehaviorTrial
lick_number                                        : int                 # first lick in trial,  second lick in trial
---
lick_touch_number                                  : int                 # in case  there was a touch, what touch number it is. 1 is first touch; -1 if the lick did not result in touch of the lickport
lick_number_relative_to_firsttouch=null            : int                 # first lick with touch is 0, the next lick after it (not necessarily with touch) is 1, etc. the last lick before touch is -1, the one before it -2 etc
lick_number_relative_to_lickport_entrance          : int                 # first lick after the lickport_entrance is 0, next one is 1 etc; the lick before lickport_entrance cue is -1, the one before it -2, etc
lick_number_relative_to_lickport_exit              : int                 # first lick after the lickport_exit is 0, next one is 1 etc; the lick before lickport_exit cue is -1, the one before it -2, etc
lick_number_with_touch_relative_to_reward=null     : int                 # 1 is first touch, 2 is second lick with touch after reward delivery etc. -1 licks with touch before reward delivery
flag_trial_has_licks_after_lickport_entrance       : int                 # 1 if trial has licks after lickport entrance, 0 if not


lick_peak_x=null                                    : double                # tongue Medio-Lateral coordinate at the peak of the lick, relative to midline. Left negative, Right positive. Measured based on tongue center
lick_peak_y1=null                                   : double                # tongue Anterior-Posterior coordinate at the peak of the lick. Positive is forward. Measured based on tongue tip
lick_peak_y2=null                                   : double                # tongue Anterior-Posterior coordinate at the peak of the lick. Positive is forward. Measured based on tongue center
lick_peak_z=null                                    : double                # tongue Dorso-Ventral coordinate at the peak of the lick. Positive is downwards. Measured based on tongue tip
lick_peak_yaw=null                                  : double                # tongue yaw at the peak of the lick. Left negative, Right positive

lick_peak_yaw_avg_across_licks_with_touch=null     : double                # tongue yaw at the peak, median across all licks with touch
lick_peak_yaw_avg_across_licks_before_lickportentrance=null         :double                # tongue yaw at the peak, median across all licks occuring before lickportentrance
lick_peak_yaw_avg_across_licks_after_lickportentrance=null         :double                # tongue yaw at the peak, median across all licks occuring after lickportentrance


lick_touch_x = null            : double              # tongue Medio-Lateral coordinate during electric touch, relative to midline. Left negative, Right positive. Measured based on tongue center
lick_touch_y1 = null           : double              # tongue Anterior-Posterior coordinate during electric touch. Positive is forward. Measured based on tongue tip
lick_touch_y2 = null           : double              # tongue Anterior-Posterior coordinate during electric touch. Positive is forward. Measured based on tongue center
lick_touch_z = null            : double              # tongue Dorso-Ventral coordinate during electric touch. Positive is downwards. Measured based on tongue tip
lick_touch_yaw = null          : double              # tongue yaw during electric touch. Left negative, Right positive




lick_yaw_lickbout=null                                   : double                # tongue yaw averaged (median) during the entire outbound lick, i.e. from onset to peak
lick_yaw_lickbout_avg_across_licks_with_touch=null              : double                     # tongue yaw averaged (median) during the entire outbound lick, i.e. from onset to peaktongue yaw at the peak, median across all licks with touch
lick_yaw_lickbout_avg_across_licks_before_lickportentrance=null              : double                     #  median tongue yaw during the entire outbound lick, i.e. from onset to peaktongue yaw at the peak, median across  all licks occuring before lickportentrance
lick_yaw_lickbout_avg_across_licks_after_lickportentrance=null              : double                     #  median tongue yaw during the entire outbound lick, i.e. from onset to peaktongue yaw at the peak, median across  all licks occuring after lickportentrance

lick_vel_x_lickbout_avg=null                                 : double                # median tongue linear velocity during the entire outbound lick, i.e. from onset to peak
lick_vel_y1_lickbout_avg=null                                : double                # median tongue angular velocity during the entire outbound lick, i.e. from onset to peak
lick_vel_y2_lickbout_avg=null                                : double                # median tongue angular velocity during the entire outbound lick, i.e. from onset to peak
lick_vel_z_lickbout_avg=null                                 : double                # median tongue angular velocity during the entire outbound lick, i.e. from onset to peak

lick_time_onset                                     : double                # lick onset time, relative to Go cue/ or movinglickport entrance in case lickport is moving
lick_time_onset_relative_firstlick_after_lickportentrance=null   :double    # for trials in which there were licks after lickport entrance, we measure the onset of all licks in this trial relative to the onset of the first lick after lickport entrance
lick_time_onset_relative_to_trial_start             : double                # lick onset time, relative to trial start
lick_time_peak                                      : double                # lick peak time, relative to Go cue/ or movinglickport entrance in case lickport is moving
lick_duration_total                                 : double                # time from onset to end, i.e. complete retraction
lick_time_electric=null                             : double                #  electric lick port detection during lickbout, relative to Go cue/ or movinglickport entrance in case lickport is moving

lick_delta_x=null                                   : double                # maximal change in the tongue coordinate during the lick
lick_delta_y1=null                                  : double                # maximal change in the tongue coordinate during the lick
lick_delta_y2=null                                  : double                # maximal change in the tongue coordinate during the lick
lick_delta_z=null                                   : double                # maximal change in the tongue coordinate during the lick

%}


classdef VideoNthLickTrial < dj.Computed
    properties
        keySource = TRACKING.VideoTongueTrial;
    end
    methods(Access=protected)
        
        function makeTuples(self, key)
            
            
            T = fetch(TRACKING.VideoTongueTrial & key,'*');
            
            LickportMoving = fetch(TRACKING.VideoLickportTrial & key,'*');
            t_lickport_entrance = LickportMoving.lickport_t_entrance_start;
            t_lickport_exit = t_lickport_entrance + LickportMoving.lickport_lickable_duration;
            lickport_t_entrance_relative_to_trial_start = LickportMoving.lickport_t_entrance_relative_to_trial_start;
            t_reward = fetchn(EXP2.BehaviorTrialEvent & 'trial_event_type="reward"'& key, 'trial_event_time') -lickport_t_entrance_relative_to_trial_start; % relative to lickport entrance
            
            totalnum_licks = numel(T.licks_peak_x);
            if totalnum_licks==0
                return;
            end
            if sum(isnan(T.licks_peak_y1))>0
                return;
            end
            licks_time_onset  =T.licks_time_onset;
            licks_duration_total  =T.licks_duration_total;
            licks_time_peak  = T.licks_time_peak;
            t_elect = T.licks_time_electric;
            
            %finding only electric licks that occured during lickbouts (e.g. not by paw touching the lickport)
            idx_electric_during_lick=[];
            if numel(t_elect)>0
                for i_l=1:1:totalnum_licks
                    idx_electric_during_lick = [idx_electric_during_lick,find(  licks_time_onset(i_l)<=t_elect & (licks_time_onset(i_l)+licks_duration_total(i_l))>=t_elect ,1,'first' )];
                end
            end
            t_elect = t_elect(idx_electric_during_lick);
            
            key_insert =repmat(key,1,totalnum_licks);
            for i_l=1:1:totalnum_licks
                
                key_insert(i_l).lick_number = i_l;
                
                key_insert(i_l).lick_peak_x = T.licks_peak_x(i_l);
                key_insert(i_l).lick_peak_y1  = T.licks_peak_y1(i_l);
                key_insert(i_l).lick_peak_y2  = T.licks_peak_y2(i_l);
                key_insert(i_l).lick_peak_z  = T.licks_peak_z(i_l);
                key_insert(i_l).lick_peak_yaw  = T.licks_peak_yaw(i_l);
                
                key_insert(i_l).lick_yaw_lickbout  = T.licks_yaw_lickbout_avg(i_l);
                
                key_insert(i_l).lick_vel_x_lickbout_avg = T.licks_vel_x_lickbout_avg(i_l);
                key_insert(i_l).lick_vel_y1_lickbout_avg  = T.licks_vel_y1_lickbout_avg(i_l);
                key_insert(i_l).lick_vel_y2_lickbout_avg  = T.licks_vel_y2_lickbout_avg(i_l);
                key_insert(i_l).lick_vel_z_lickbout_avg  = T.licks_vel_z_lickbout_avg(i_l);
                
                key_insert(i_l).lick_time_onset = licks_time_onset(i_l);
                key_insert(i_l).lick_time_onset_relative_to_trial_start = licks_time_onset(i_l) + lickport_t_entrance_relative_to_trial_start;
                key_insert(i_l).lick_time_peak  = licks_time_peak(i_l);
                key_insert(i_l).lick_duration_total  = licks_duration_total(i_l);
                
                idx=find(licks_time_onset(i_l)<=t_elect & t_elect <=(licks_time_onset(i_l)+licks_duration_total(i_l)));
                if numel(t_elect)>0 & ~isempty(idx)
                    if numel(idx)>1
                        a=1;
                    end
                    key_insert(i_l).lick_time_electric  = t_elect(idx);
                    key_insert(i_l).lick_touch_number  = idx;
                    
                    key_insert(i_l).lick_touch_x =  T.licks_touch_x(idx);
                    key_insert(i_l).lick_touch_y1 =  T.licks_touch_y1(idx);
                    key_insert(i_l).lick_touch_y2 =  T.licks_touch_y2(idx);
                    key_insert(i_l).lick_touch_z =  T.licks_touch_z(idx);
                    key_insert(i_l).lick_touch_yaw = T.licks_touch_yaw(idx);
                    
                else
                    key_insert(i_l).lick_time_electric  = NaN;
                    key_insert(i_l).lick_touch_number  = -1;
                    
                    key_insert(i_l).lick_touch_x =  NaN;
                    key_insert(i_l).lick_touch_y1 =  NaN;
                    key_insert(i_l).lick_touch_y2 =  NaN;
                    key_insert(i_l).lick_touch_z =  NaN;
                    key_insert(i_l).lick_touch_yaw = NaN;
                end
               
                key_insert(i_l).lick_delta_x = T.licks_delta_x(i_l);
                key_insert(i_l).lick_delta_y1  = T.licks_delta_y1(i_l);
                key_insert(i_l).lick_delta_y2  = T.licks_delta_y2(i_l);
                key_insert(i_l).lick_delta_z  = T.licks_delta_z(i_l);
                
            end
            
            for i_l=1:1:totalnum_licks
                
                if numel(t_elect)>0
                    key_insert(i_l).lick_number_relative_to_firsttouch = (i_l) - find([key_insert.lick_touch_number]==1);
                else
                    key_insert(i_l).lick_number_relative_to_firsttouch = NaN;
                end
                
                if ~isempty(find([key_insert.lick_time_onset]>0,1,'first'))
                    key_insert(i_l).lick_number_relative_to_lickport_entrance = (i_l) -  find([key_insert.lick_time_onset]>0,1,'first');
                else
                    key_insert(i_l).lick_number_relative_to_lickport_entrance = (i_l-1) - totalnum_licks ;
                end
                
                if ~isempty(find([key_insert.lick_time_onset]>t_lickport_exit,1,'first'))
                    key_insert(i_l).lick_number_relative_to_lickport_exit = (i_l) -  find([key_insert.lick_time_onset]>t_lickport_exit,1,'first');
                else
                    key_insert(i_l).lick_number_relative_to_lickport_exit = (i_l-1)- totalnum_licks ;
                end
                
            end
            
            for i_l=1:1:totalnum_licks
                idx = find([key_insert.lick_number_relative_to_lickport_entrance]==0);
                if ~isempty(idx)
                    key_insert(i_l).flag_trial_has_licks_after_lickport_entrance=1;
                    key_insert(i_l).lick_time_onset_relative_firstlick_after_lickportentrance= key_insert(i_l).lick_time_onset - key_insert(idx).lick_time_onset;
                else
                    key_insert(i_l).flag_trial_has_licks_after_lickport_entrance=0;
                    key_insert(i_l).lick_time_onset_relative_firstlick_after_lickportentrance=NaN;
                end
            end
            
            for i_l=1:1:totalnum_licks
                
                if numel(t_elect)>0
                    lick_peak_yaw = [key_insert.lick_peak_yaw];
                    lick_yaw_lickbout = [key_insert.lick_yaw_lickbout];
                    key_insert(i_l).lick_peak_yaw_avg_across_licks_with_touch  = ...
                        nanmedian(lick_peak_yaw(~isnan([key_insert.lick_touch_number])));
                    key_insert(i_l).lick_yaw_lickbout_avg_across_licks_with_touch  = ...
                        nanmedian(lick_yaw_lickbout(~isnan([key_insert.lick_touch_number])));
                else
                    key_insert(i_l).lick_peak_yaw_avg_across_licks_with_touch  = NaN;
                    key_insert(i_l).lick_yaw_lickbout_avg_across_licks_with_touch  = NaN;
                end
            end
            
            for i_l=1:1:totalnum_licks
                idx = find([key_insert.lick_number_relative_to_lickport_entrance]<0);
                if sum(idx)>0
                    lick_peak_yaw = [key_insert.lick_peak_yaw];
                    lick_yaw_lickbout = [key_insert.lick_yaw_lickbout];
                    key_insert(i_l).lick_peak_yaw_avg_across_licks_before_lickportentrance  = ...
                        nanmedian(lick_peak_yaw(idx));
                    key_insert(i_l).lick_yaw_lickbout_avg_across_licks_before_lickportentrance  = ...
                        nanmedian(lick_yaw_lickbout(idx));
                else
                    key_insert(i_l).lick_peak_yaw_avg_across_licks_before_lickportentrance  = NaN;
                    key_insert(i_l).lick_yaw_lickbout_avg_across_licks_before_lickportentrance  = NaN;
                end
            end
            
            for i_l=1:1:totalnum_licks
                idx = find([key_insert.lick_number_relative_to_lickport_entrance]>=0);
                if sum(idx)>0
                    lick_peak_yaw = [key_insert.lick_peak_yaw];
                    lick_yaw_lickbout = [key_insert.lick_yaw_lickbout];
                    key_insert(i_l).lick_peak_yaw_avg_across_licks_after_lickportentrance  = ...
                        nanmedian(lick_peak_yaw(idx));
                    key_insert(i_l).lick_yaw_lickbout_avg_across_licks_after_lickportentrance  = ...
                        nanmedian(lick_yaw_lickbout(idx));
                else
                    key_insert(i_l).lick_peak_yaw_avg_across_licks_after_lickportentrance  = NaN;
                    key_insert(i_l).lick_yaw_lickbout_avg_across_licks_after_lickportentrance  = NaN;
                end
            end
            
            counter_post_reward=1;
            for i_l=1:1:totalnum_licks
                if key_insert(i_l).lick_touch_number>-1 & key_insert(i_l).lick_time_electric>=t_reward
                    key_insert(i_l).lick_number_with_touch_relative_to_reward=counter_post_reward;
                    counter_post_reward=counter_post_reward+1;
                else
                    key_insert(i_l).lick_number_with_touch_relative_to_reward=-1;
                end
            end
            
              insert(self,key_insert)

        end
    end
end

