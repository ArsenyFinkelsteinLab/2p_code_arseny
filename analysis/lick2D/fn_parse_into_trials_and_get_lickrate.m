function [start_file, end_file, lick_tr_times_relative_to_first_lick_after_go,lick_tr_total ] = fn_parse_into_trials_and_get_lickrate (key, frame_rate, time_bin, flag_electric_video)

TrialsStartFrame=fetchn((IMG.FrameStartTrial  & key) - TRACKING.VideoGroomingTrial,'session_epoch_trial_start_frame','ORDER BY trial');
trial_num=fetchn((IMG.FrameStartTrial  & key) - TRACKING.VideoGroomingTrial,'trial','ORDER BY trial');
if isempty(TrialsStartFrame) % if its not mesoscope recording, but old recording (e.g. photostim) IMG.FrameStartTrial does not contain trial number, but in fact in behavioral session each file correspond to a new trial. 
    TrialsStartFrame=fetchn((IMG.FrameStartFile & key),'session_epoch_file_start_frame', 'ORDER BY session_epoch_file_num');
    trial_num=fetchn((EXP2.BehaviorTrial  & key) - TRACKING.VideoGroomingTrial,'trial','ORDER BY trial');
    TrialsStartFrame = TrialsStartFrame(trial_num);
end

if flag_electric_video==1
    LICK_VIDEO=[]; %We align based on electric lickport, even if video does exist
elseif flag_electric_video==2 %We  try to align based on video, if it exists.
    % We align to the first video-detected lick after lickport movement
    LICK_VIDEO= fetch(((TRACKING.VideoNthLickTrial& key) - TRACKING.VideoGroomingTrial),'lick_time_onset_relative_to_trial_start');% we use it to get the timing of licks after lickport entrance
end

%If there is no video, we align based on electric lickport contact.  We align to the first electric-lickport detected lick after Go cue (there is some lag between GO cue and lickport movement)
go_time=fetchn(((EXP2.BehaviorTrialEvent & key) - TRACKING.VideoGroomingTrial) & 'trial_event_type="go"','trial_event_time');
LICK_ELECTRIC=fetch(((EXP2.ActionEvent & key) - TRACKING.VideoGroomingTrial),'*');

lick_tr_times_relative_to_first_lick_after_go =[];
lick_tr_total =[];

for i_tr = 1:1:numel(trial_num)
    if ~isempty(LICK_VIDEO)
        all_licks=[LICK_VIDEO(find([LICK_VIDEO.trial]==trial_num(i_tr))).lick_time_onset_relative_to_trial_start];
        licks_after_go=all_licks(all_licks>go_time(i_tr));
    else %use electric
        all_licks=[LICK_ELECTRIC(find([LICK_ELECTRIC.trial]==trial_num(i_tr))).action_event_time];
        licks_after_go=all_licks(all_licks>go_time(i_tr));
    end
    
    if ~isempty(licks_after_go)
        start_file(i_tr)=TrialsStartFrame(i_tr) + floor(licks_after_go(1)*frame_rate) + floor(time_bin(1)*frame_rate);
        end_file(i_tr)=start_file(i_tr)+floor([time_bin(2)-time_bin(1)]*frame_rate)-1;
        
        lick_tr_times_relative_to_first_lick_after_go{i_tr}=all_licks-licks_after_go(1);
        lick_tr_total(i_tr)=sum( lick_tr_times_relative_to_first_lick_after_go{i_tr}>=time_bin(1) & lick_tr_times_relative_to_first_lick_after_go{i_tr}<=time_bin(end));
        if start_file(i_tr)<=0
            start_file(i_tr)=NaN;
            end_file(i_tr)=NaN;
        end
    else
        start_file(i_tr)=NaN;
        end_file(i_tr)=NaN;
        lick_tr_total(i_tr)=0;
        lick_tr_times_relative_to_first_lick_after_go{i_tr}=[];
    end
end