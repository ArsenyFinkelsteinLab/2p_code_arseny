function [idx_regular,idx_odd_regular,idx_even_regular,idx_small,idx_large,idx_first,idx_begin,idx_mid,idx_end, idx_response, num_trials, start_file, end_file] = ...
  fn_parse_2Dlicking_into_trial_types(key)

frame_rate = fetchn(IMG.FOVEpoch & key,'imaging_frame_rate');

R=fetch((EXP2.TrialRewardSize & key) - TRACKING.VideoGroomingTrial,'*','ORDER BY trial');
Block=fetch((EXP2.TrialLickBlock & key) - TRACKING.VideoGroomingTrial,'*','ORDER BY trial');

S=fetch(rel_data,'*');
if isfield(S,'spikes_trace') % to be able to run the code both on dff and on deconvulted "spikes" data
    [S.dff_trace] = S.spikes_trace;
    S = rmfield(S,'spikes_trace');
    self2=LICK2D.ROILick2DmapPSTHSpikes3bins;
    self3=LICK2D.ROILick2DmapPSTHStabilitySpikes3bins;
    self4=LICK2D.ROILick2DmapStatsSpikes3bins;
    self5=LICK2D.ROILick2DSelectivitySpikes3bins;
    self6=LICK2D.ROILick2DSelectivityStatsSpikes3bins;
else
    %     self2=LICK2D.ROILick2DmapPSTH;
    %     self3=LICK2D.ROILick2DmapStats;
    %     self4=LICK2D.ROILick2DSelectivity;
    %     self5=LICK2D.ROILick2DSelectivityStats;
end

% num_trials = numel(TrialsStartFrame);
[start_file, end_file ] = fn_parse_into_trials (key,frame_rate, fr_interval);

num_trials =numel(start_file);
idx_response = (~isnan(start_file));
try
    % idx reward
    idx_regular = strcmp({R.reward_size_type},'regular')  & idx_response;
    idx_small= strcmp({R.reward_size_type},'omission')  & idx_response;
    idx_large= strcmp({R.reward_size_type},'large')  & idx_response;
    
    idx_odd_regular = find(idx_regular);
    idx_odd_regular = idx_odd_regular(1:2:sum(idx_regular));
    idx_odd_regular = ismember(1:1:num_trials,idx_odd_regular);
    idx_even_regular = find(idx_regular);
    idx_even_regular = idx_even_regular(2:2:sum(idx_regular));
    idx_even_regular = ismember(1:1:num_trials,idx_even_regular);
catch
    idx_regular = 1:1:num_trials  & idx_response;
    idx_odd_regular = ismember(1:1:num_trials,1:2:num_trials) & idx_response;
    idx_even_regular =  ismember(1:1:num_trials,2:2:num_trials) & idx_response;
end

try
    % idx order in a block
    num_trials_in_block=mode([Block.num_trials_in_block]); %the most frequently occurring number of trials per block (in case num trials in block change within session)
    begin_mid_end_bins = linspace(2,num_trials_in_block,4);
    idx_first = [Block.current_trial_num_in_block]==1 & idx_response & idx_regular;
    idx_begin = ([Block.current_trial_num_in_block]>=begin_mid_end_bins(1) & [Block.current_trial_num_in_block]<=floor(begin_mid_end_bins(2)) ) & idx_response & idx_regular;
    idx_mid=   ([Block.current_trial_num_in_block]>begin_mid_end_bins(2) & [Block.current_trial_num_in_block]<=round(begin_mid_end_bins(3)) ) & idx_response & idx_regular;
    idx_end=   ([Block.current_trial_num_in_block]>begin_mid_end_bins(3) & [Block.current_trial_num_in_block]<=ceil(begin_mid_end_bins(4)) ) & idx_response & idx_regular;
catch
end

