function fn_compute_predictors (key, self)
rel_type = RIDGE.PredictorType;
key_insert =repmat(key,1,rel_type.count);


sampling_rate_2p = fetch1(IMG.FOVEpoch & key,'imaging_frame_rate','LIMIT 1'); %we assume that all epochs have the same frame rate


% start_frame_2p_trial=fetchn(IMG.FrameStartTrial & key,'session_epoch_trial_start_frame','ORDER BY trial'); %relative to beginning of the session epoch
% start_frame_2p_epoch=fetchn(IMG.SessionEpochFrame & key & 'session_epoch_type="behav_only"','session_epoch_start_frame'); %relative to beginning of the session 
% frame_timestamps=fetch1(IMG.FrameTime& key,'frame_timestamps');  %(s) frame times relative to the beginning of  the session
% frame_timestamps(start_frame_2p_epoch+start_frame_2p_trial)
 
tracking_start_time = fetchn(TRACKING.TrackingTrial & key,'tracking_start_time','LIMIT 1'); % relative to trial start

predictor_name = fetchn(RIDGE.PredictorType & 'predictor_category="move"','predictor_name');
counter = 1;
for i_p=1:1:numel(predictor_name)
    key_insert(counter).trial_predictor = fn_predictors_move(key,sampling_rate_2p, predictor_name{i_p}, tracking_start_time);
    key_insert(counter).predictor_name=predictor_name{i_p};
    counter=counter +1;
end

num_resampled_frames = numel(key_insert(i_p-1).trial_predictor);
predictor_name = fetchn(RIDGE.PredictorType & 'predictor_category="task" OR predictor_category="lick"','predictor_name');
for i_p=1:1:numel(predictor_name)
    key_insert(counter).trial_predictor = fn_predictors_task(key,sampling_rate_2p, predictor_name{i_p}, num_resampled_frames);
    key_insert(counter).predictor_name=predictor_name{i_p};
    counter=counter +1;
end

insert(self,key_insert);