function [start_file, end_file ] = fn_parse_into_trials (key, frame_rate, time_bin)

TrialsStartFrame=fetchn((IMG.FrameStartTrial  & key) - TRACKING.VideoGroomingTrial,'session_epoch_trial_start_frame','ORDER BY trial');
trial_num=fetchn((IMG.FrameStartTrial  & key) - TRACKING.VideoGroomingTrial,'trial','ORDER BY trial');
if isempty(TrialsStartFrame) % if its not mesoscope recording, but old recording (e.g. photostim) IMG.FrameStartTrial does not contain trial number, but in fact in behavioral session each file correspond to a new trial. 
    TrialsStartFrame=fetchn((IMG.FrameStartFile & key),'session_epoch_file_start_frame', 'ORDER BY session_epoch_file_num');
    trial_num=fetchn((EXP2.BehaviorTrial  & key) - TRACKING.VideoGroomingTrial,'trial','ORDER BY trial');
    TrialsStartFrame = TrialsStartFrame(trial_num);
end

%We first try to align based on video, if it exists. We align to the first video-detected lick after lickport movement
LICK_VIDEO= fetch(((TRACKING.VideoNthLickTrial& key) - TRACKING.VideoGroomingTrial) & 'lick_number_relative_to_lickport_entrance=0','*');% we get the timing of  the first lick after lickport entrance


%If there is no video, we align based on electric lickport contact.  We align to the first electric-lickport detected lick after Go cue (there is some lag between GO cue and lickport movement)
go_time=fetchn(((EXP2.BehaviorTrialEvent & key) - TRACKING.VideoGroomingTrial) & 'trial_event_type="go"','trial_event_time','LIMIT 1');
LICK_ELECTRIC=fetch(((EXP2.ActionEvent & key) - TRACKING.VideoGroomingTrial),'*');


for i_tr = 1:1:numel(trial_num)
    if ~isempty(LICK_VIDEO)
        licks=[LICK_VIDEO(find([LICK_VIDEO.trial]==trial_num(i_tr))).lick_time_onset_relative_to_trial_start];
        if isnan(licks)
            licks=[];
        end
    else %use electric
        licks=[LICK_ELECTRIC(find([LICK_ELECTRIC.trial]==trial_num(i_tr))).action_event_time];
        licks=licks(licks>go_time);
    end
    
    if ~isempty(licks)
        try
            start_file(i_tr)=TrialsStartFrame(i_tr) + floor(licks(1)*frame_rate) + floor(time_bin(1)*frame_rate);
        catch
            a=1
        end
        end_file(i_tr)=start_file(i_tr)+floor([time_bin(2)-time_bin(1)]*frame_rate)-1;
        if start_file(i_tr)<=0
            start_file(i_tr)=NaN;
            
            end_file(i_tr)=NaN;
        end
    else
        start_file(i_tr)=NaN;
        end_file(i_tr)=NaN;
    end
end