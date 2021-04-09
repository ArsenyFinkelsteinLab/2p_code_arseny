function [body_vector, idx_2pimaging_frames] = fn_compute_corr_with_bodypart (key, frame_rate_2pimaging)
smooth_body_window = 3; %video tracking frames, before downsampling

TrialsStartFrame=fetchn((IMG.FrameStartTrial  & key) - TRACKING.VideoGroomingTrial,'session_epoch_trial_start_frame','ORDER BY trial');
trial_num=fetchn((IMG.FrameStartTrial  & key) - TRACKING.VideoGroomingTrial,'trial','ORDER BY trial');
if isempty(TrialsStartFrame) % not mesoscope recordings
    TrialsStartFrame=fetchn((IMG.FrameStartFile & key) - TRACKING.VideoGroomingTrial,'session_epoch_file_start_frame', 'ORDER BY session_epoch_file_num');
    trial_num=fetchn((IMG.FrameStartFile  & key) - TRACKING.VideoGroomingTrial,'trial','ORDER BY trial');
end

%We first try to align based on video, if it exists. We align to the first video-detected lick after lickport movement
rel_video = (TRACKING.VideoBodypartTrajectTrial*TRACKING.VideoLickportTrial & key) - TRACKING.VideoGroomingTrial;

switch key.bodypart_name
    case 'pawfrontleft' %front view
        VIDEO= fetchn(rel_video,'traj_x','ORDER BY trial');%
        k.tracking_device_id=4;
    case 'pawfrontright' %front view
        VIDEO= fetchn(rel_video,'traj_x','ORDER BY trial');%
                k.tracking_device_id=4;
    case 'whiskers' %front view
        VIDEO= fetchn(rel_video,'traj_y1','ORDER BY trial');%
                k.tracking_device_id=4;
end
trial_num_video = fetchn(rel_video,'trial','ORDER BY trial');
t_first_video_frame = fetchn(rel_video,'time_first_frame','ORDER BY trial') + fetchn(rel_video,'lickport_t_entrance_relative_to_trial_start','ORDER BY trial'); % relative to trial start
tracking_sampling_rate_trials =fetchn(rel_video*TRACKING.TrackingTrial & k,'tracking_sampling_rate','ORDER BY trial');

%If there is no video, we align based on electric lickport contact.  We align to the first electric-lickport detected lick after Go cue (there is some lag between GO cue and lickport movement)
body_vector=[];
idx_2pimaging_frames=[];
for i_tr = 1:1:numel(trial_num)-1
    nnnn=find(trial_num_video==trial_num(i_tr));
    if isempty(nnnn)
        continue
    end
    current_body_vector=VIDEO{nnnn};
    
    time_tracking = [0:1:numel(current_body_vector)-1]/tracking_sampling_rate_trials(nnnn) + t_first_video_frame(trial_num_video==trial_num(i_tr));
    
    current_idx_2pimaging_frames = [TrialsStartFrame(i_tr):1: (TrialsStartFrame(i_tr+1)-1)];
    time_2pimaging = (current_idx_2pimaging_frames-current_idx_2pimaging_frames(1))/frame_rate_2pimaging;
    idx_overlaping = time_2pimaging>= time_tracking(1)  & time_2pimaging<=time_tracking(end) ;
    
    time_2pimaging =time_2pimaging(idx_overlaping);
    current_idx_2pimaging_frames =current_idx_2pimaging_frames(idx_overlaping);
    
    idx_2pimaging_frames= [idx_2pimaging_frames, current_idx_2pimaging_frames];
    
    current_body_vector =smooth(current_body_vector,smooth_body_window); %to interploate and eliminate NaNs
    
    time_2pimaging=[0,time_2pimaging];
    current_body_vector_resampled=[];
    for ii=1:1:numel(time_2pimaging)-1
        idx_b = time_tracking>=time_2pimaging(ii) & time_tracking <time_2pimaging(ii+1);
        current_body_vector_resampled(ii) =  nanmedian(current_body_vector(idx_b)); %downsampling, to match the imaging frame rate
    end
    body_vector= [body_vector, current_body_vector_resampled];
end


