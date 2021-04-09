function [event_vector]= fn_predictors_task(key, sampling_rate_2p, predictor_name, num_resampled_frames)

rel_lickport = TRACKING.VideoLickportTrial & key;
rel_lick = TRACKING.VideoNthLickTrial & key;
rel_trial = EXP2.TrialRewardSize*EXP2.TrialLickBlock & key;
rel_trial_reward_time = EXP2.BehaviorTrialEvent & 'trial_event_type="reward"'& key;

event=[];
switch predictor_name
    case 'LickPortEntrance'
        event= fetch1(rel_lickport ,'lickport_t_entrance_relative_to_trial_start');
    case 'LickPortExit'
        event= fetch1(rel_lickport.proj('lickport_t_entrance_relative_to_trial_start + lickport_lickable_duration -> t_exit'),'t_exit');
    case 'Lick'
        event= fetchn(rel_lick,'lick_time_onset_relative_to_trial_start','ORDER BY LICK_NUMBER');%
    case 'LickTouch'
        event= fetchn(rel_lick & 'lick_touch_number>0', 'lick_time_onset_relative_to_trial_start','ORDER BY LICK_NUMBER');%
    case 'LickNoTouch'
        event= fetchn(rel_lick  & 'lick_touch_number=-1', 'lick_time_onset_relative_to_trial_start','ORDER BY LICK_NUMBER');%
    case 'LickTouchReward'
        event= fetchn(rel_lick  & 'lick_touch_number>0' & 'lick_number_with_touch_relative_to_reward>0', 'lick_time_onset_relative_to_trial_start','ORDER BY LICK_NUMBER');%
    case 'LickTouchNoReward'
        event= fetchn(rel_lick  & 'lick_touch_number>0' & 'lick_number_with_touch_relative_to_reward=-1', 'lick_time_onset_relative_to_trial_start', 'ORDER BY LICK_NUMBER');%
    case 'LickTouchNoRewardOmitted'
        if ~isempty(fetchn(rel_trial & 'reward_size_type="omission"','reward_size_type'))
            event= fetchn(rel_lick  & 'lick_touch_number>0' & 'lick_number_with_touch_relative_to_reward>0', 'lick_time_onset_relative_to_trial_start', 'ORDER BY LICK_NUMBER');%
        end
    case 'FirstLickTouch'
        event= fetchn(rel_lick & 'lick_touch_number=1', 'lick_time_onset_relative_to_trial_start' ,'ORDER BY LICK_NUMBER');%
    case 'FirstLickReward'
        event= fetchn(rel_lick & 'lick_number_with_touch_relative_to_reward=1','lick_time_onset_relative_to_trial_start' ,'ORDER BY LICK_NUMBER');%
    case 'RewardDelivery'
        event= fetchn(rel_trial_reward_time ,'trial_event_time');%
    case 'RewardSize'
        event= fetchn(rel_trial & 'reward_size_type="large"','reward_size_type');
        if ~isempty(event)
            event= fetchn(rel_trial_reward_time ,'trial_event_time');
        end
    case 'RewardOmission'
        event= fetchn(rel_trial & 'reward_size_type="omission"','reward_size_type');
        if ~isempty(event)
            event= fetchn(rel_trial_reward_time ,'trial_event_time');
        end
    case 'LickPortBlockStart'
        event= fetchn(rel_trial & 'current_trial_num_in_block=1','current_trial_num_in_block');%
        if ~isempty(event)
            event= fetch1(rel_lickport ,'lickport_t_entrance_relative_to_trial_start');
        end
    case 'AutoWater'
        event= fetchn(rel_trial & 'flag_auto_water_curret_trial=1','flag_auto_water_curret_trial');%
        if ~isempty(event)
            event= fetchn(rel_trial_reward_time ,'trial_event_time');%
        end
end

time_resampled = (0:1:num_resampled_frames)/sampling_rate_2p;

if isempty(event)
    event_vector = time_resampled(2:1:end)*0;
    return
end

for ii=1:1:numel(time_resampled)-1
    idx_b = event>=time_resampled(ii) & event <time_resampled(ii+1);
    event_vector(ii) =  sum(idx_b); %For each 2p imaging frame we save the number of events that happened in this bin.
end


