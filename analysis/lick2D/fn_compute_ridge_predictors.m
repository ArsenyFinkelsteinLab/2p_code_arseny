function [predictor_vector, idx_2pimaging_frames] = fn_compute_ridge_predictors (key, frame_rate_2pimaging)
smooth_body_window = 3; %video tracking frames, before downsampling

TrialsStartFrame=fetchn((IMG.FrameStartTrial  & key) - TRACKING.VideoGroomingTrial,'session_epoch_trial_start_frame','ORDER BY trial');
trial_num=fetchn((IMG.FrameStartTrial  & key) - TRACKING.VideoGroomingTrial,'trial','ORDER BY trial');
if isempty(TrialsStartFrame) % not mesoscope recordings
    TrialsStartFrame=fetchn((IMG.FrameStartFile & key) - TRACKING.VideoGroomingTrial,'session_epoch_file_start_frame', 'ORDER BY session_epoch_file_num');
    trial_num=fetchn((IMG.FrameStartFile  & key) - TRACKING.VideoGroomingTrial,'trial','ORDER BY trial');
end

%We first try to align based on video, if it exists. We align to the first video-detected lick after lickport movement
rel_video = (TRACKING.VideoBodypartTrajectTrial*TRACKING.VideoLickportTrial & key) - TRACKING.VideoGroomingTrial;

predictor_names = {'pawfrontleft','pawfrontright','whiskers'}
for i_p=1:1:numel(predictor_names)
    [predictor_vector(:,i_p),idx_2pimaging_frames]= fn_downsample_behavior_trace(key,rel_video,TrialsStartFrame,frame_rate_2pimaging, trial_num,predictor_names{i_p});
end
a=1;
