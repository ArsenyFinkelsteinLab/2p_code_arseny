function [licks_vector, idx_frames] = fn_compute_corr_with_licking (key, frame_rate, smooth_window)

TrialsStartFrame=fetchn((IMG.FrameStartTrial  & key) - TRACKING.VideoGroomingTrial,'session_epoch_trial_start_frame','ORDER BY trial');
trial_num=fetchn((IMG.FrameStartTrial  & key) - TRACKING.VideoGroomingTrial,'trial','ORDER BY trial');
if isempty(TrialsStartFrame) % not mesoscope recordings
    TrialsStartFrame=fetchn((IMG.FrameStartFile & key) - TRACKING.VideoGroomingTrial,'session_epoch_file_start_frame', 'ORDER BY session_epoch_file_num');
    trial_num=fetchn((IMG.FrameStartFile  & key) - TRACKING.VideoGroomingTrial,'trial','ORDER BY trial');
end

%We first try to align based on video, if it exists. We align to the first video-detected lick after lickport movement
LICK_VIDEO= fetch(((TRACKING.VideoNthLickTrial& key) - TRACKING.VideoGroomingTrial),'*');% we get the timing of  the first lick after lickport entrance


%If there is no video, we align based on electric lickport contact.  We align to the first electric-lickport detected lick after Go cue (there is some lag between GO cue and lickport movement)
licks_vector=[];
idx_frames=[];
for i_tr = 1:1:numel(trial_num)-1
        licks=[LICK_VIDEO(find([LICK_VIDEO.trial]==trial_num(i_tr))).lick_time_onset_relative_to_trial_start];
        idx_frames = [idx_frames, TrialsStartFrame(i_tr):1: (TrialsStartFrame(i_tr+1)-1)];
        t_trial = ([TrialsStartFrame(i_tr):1: (TrialsStartFrame(i_tr+1))]-TrialsStartFrame(i_tr))/frame_rate;
        licks_vector = [licks_vector,histcounts(licks,t_trial)];
end

licks_vector =smooth(licks_vector,smooth_window);

