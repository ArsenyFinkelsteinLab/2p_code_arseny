function [TRIAL_IDX, num_trials, start_file, end_file] = ...
    fn_parse_2Dlicking_into_trial_types(key, fr_interval)

frame_rate = fetchn(IMG.FOVEpoch & key,'imaging_frame_rate');

R=fetch((EXP2.TrialRewardSize & key) - TRACKING.VideoGroomingTrial,'*','ORDER BY trial');
Block=fetch((EXP2.TrialLickBlock & key) - TRACKING.VideoGroomingTrial,'*','ORDER BY trial');

[start_file, end_file ] = fn_parse_into_trials (key,frame_rate, fr_interval);

num_trials =numel(start_file);
TRIAL_IDX.idx_response = (~isnan(start_file));

try
    % idx reward
    
    TRIAL_IDX.idx_regular = strcmp({R.reward_size_type},'regular')  & TRIAL_IDX.idx_response;
    temp = find(TRIAL_IDX.idx_regular);
    temp_idx_odd = temp(1:2:numel(temp));
    TRIAL_IDX.idx_regular_odd = ismember(1:1:num_trials, temp_idx_odd);
    temp_idx_even = temp(2:2:numel(temp));
    TRIAL_IDX.idx_regular_even = ismember(1:1:num_trials, temp_idx_even);
    
    TRIAL_IDX.idx_small = strcmp({R.reward_size_type},'omission')  & TRIAL_IDX.idx_response;
    temp = find(TRIAL_IDX.idx_small);
    temp_idx_odd = temp(1:2:numel(temp));
    TRIAL_IDX.idx_small_odd = ismember(1:1:num_trials, temp_idx_odd);
    temp_idx_even = temp(2:2:numel(temp));
    TRIAL_IDX.idx_small_even = ismember(1:1:num_trials, temp_idx_even);
    
    TRIAL_IDX.idx_large = strcmp({R.reward_size_type},'large')  & TRIAL_IDX.idx_response;
    temp = find(TRIAL_IDX.idx_large);
    temp_idx_odd = temp(1:2:numel(temp));
    TRIAL_IDX.idx_large_odd = ismember(1:1:num_trials, temp_idx_odd);
    temp_idx_even = temp(2:2:numel(temp));
    TRIAL_IDX.idx_large_even = ismember(1:1:num_trials, temp_idx_even);
    
catch
    TRIAL_IDX.idx_regular = 1:1:num_trials  & TRIAL_IDX.idx_response;
    TRIAL_IDX.idx_regular_odd = ismember(1:1:num_trials,1:2:num_trials) & TRIAL_IDX.idx_response;
    TRIAL_IDX.idx_regular_even =  ismember(1:1:num_trials,2:2:num_trials) & TRIAL_IDX.idx_response;
end

try
    % idx order in a block
    num_trials_in_block = mode([Block.num_trials_in_block]); %the most frequently occurring number of trials per block (in case num trials in block change within session)
    begin_mid_end_bins = linspace(2,num_trials_in_block,4);
    
    TRIAL_IDX.idx_first = [Block.current_trial_num_in_block]==1 & TRIAL_IDX.idx_regular;
    temp = find(TRIAL_IDX.idx_first);
    temp_idx_odd = temp(1:2:numel(temp));
    TRIAL_IDX.idx_first_odd = ismember(1:1:num_trials, temp_idx_odd);
    temp_idx_even = temp(2:2:numel(temp));
    TRIAL_IDX.idx_first_even = ismember(1:1:num_trials, temp_idx_even);
    
    TRIAL_IDX.idx_begin = ([Block.current_trial_num_in_block]>=begin_mid_end_bins(1) & [Block.current_trial_num_in_block]<=floor(begin_mid_end_bins(2)) )  & TRIAL_IDX.idx_regular;
    temp = find(TRIAL_IDX.idx_begin);
    temp_idx_odd = temp(1:2:numel(temp));
    TRIAL_IDX.idx_begin_odd = ismember(1:1:num_trials, temp_idx_odd);
    temp_idx_even = temp(2:2:numel(temp));
    TRIAL_IDX.idx_begin_even = ismember(1:1:num_trials, temp_idx_even);
    
    TRIAL_IDX.idx_mid = ([Block.current_trial_num_in_block]>begin_mid_end_bins(2) & [Block.current_trial_num_in_block]<=round(begin_mid_end_bins(3)) )  & TRIAL_IDX.idx_regular;
    temp = find(TRIAL_IDX.idx_mid);
    temp_idx_odd = temp(1:2:numel(temp));
    TRIAL_IDX.idx_mid_odd = ismember(1:1:num_trials, temp_idx_odd);
    temp_idx_even = temp(2:2:numel(temp));
    TRIAL_IDX.idx_mid_even = ismember(1:1:num_trials, temp_idx_even);
    
    TRIAL_IDX.idx_end = ([Block.current_trial_num_in_block]>begin_mid_end_bins(3) & [Block.current_trial_num_in_block]<=ceil(begin_mid_end_bins(4)) )  & TRIAL_IDX.idx_regular;
    temp = find(TRIAL_IDX.idx_end);
    temp_idx_odd = temp(1:2:numel(temp));
    TRIAL_IDX.idx_end_odd = ismember(1:1:num_trials, temp_idx_odd);
    temp_idx_even = temp(2:2:numel(temp));
    TRIAL_IDX.idx_end_even = ismember(1:1:num_trials, temp_idx_even);
    
catch
end

