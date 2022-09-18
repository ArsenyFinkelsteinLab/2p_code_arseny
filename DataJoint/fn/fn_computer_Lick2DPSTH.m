function fn_computer_Lick2DPSTH(key,self, rel_data, fr_interval,fr_interval_limit, flag_electric_video, time_resample_bin)

smooth_window_sec=0.2; %frames for PSTH

rel_ROI = (IMG.ROI-IMG.ROIBad) & key;
key_ROI1=fetch(rel_ROI,'ORDER BY roi_number'); % LICK2D.ROILick2DPSTHSpikes
key_ROI2=fetch(rel_ROI,'ORDER BY roi_number'); % LICK2D.ROILick2DPSTHStatsSpikes
key_ROI3=fetch(rel_ROI,'ORDER BY roi_number'); % LICK2D.ROILick2DPSTHBlockSpikes
key_ROI4=fetch(rel_ROI,'ORDER BY roi_number'); % LICK2D.ROILick2DPSTHBlockStatsSpikes

rel_data =rel_data & rel_ROI & key;

try
    frame_rate = fetch1(IMG.FOVEpoch & key,'imaging_frame_rate');
catch
    frame_rate = fetch1(IMG.FOV & key,'imaging_frame_rate');
end

smooth_window_frames = ceil(smooth_window_sec*frame_rate); %frames for PSTH


% L=fetch(EXP2.ActionEvent & key,'*');
R=fetch((EXP2.TrialRewardSize & key) - TRACKING.VideoGroomingTrial,'*','ORDER BY trial');
Block=fetch((EXP2.TrialLickBlock & key) - TRACKING.VideoGroomingTrial,'*','ORDER BY trial');

S=fetch(rel_data,'*');
if isfield(S,'spikes_trace') % to be able to run the code both on dff and on deconvulted "spikes" data
    [S.dff_trace] = S.spikes_trace;
    S = rmfield(S,'spikes_trace');
    if isempty(time_resample_bin)
        self2=LICK2D.ROILick2DPSTHStatsSpikes;
        self3=LICK2D.ROILick2DPSTHBlockSpikes;
        self4=LICK2D.ROILick2DPSTHBlockStatsSpikes;
    else
        self2=LICK2D.ROILick2DPSTHStatsSpikesResampledlikePoisson;
        self3=LICK2D.ROILick2DPSTHBlockSpikesResampledlikePoisson;
        self4=LICK2D.ROILick2DPSTHBlockStatsSpikesResampledlikePoisson;
    end
else
%     self2=LICK2D.ROILick2DPSTHStatsSpikes;
%     self3=LICK2D.ROILick2DPSTHBlockSpikes;
%     self4=LICK2D.ROILick2DPSTHBlockStatsSpikes;
end

% num_trials = numel(TrialsStartFrame);
[start_file, end_file ] = fn_parse_into_trials_and_get_lickrate (key, frame_rate, fr_interval, flag_electric_video);

num_trials =numel(start_file);
idx_response = (~isnan(start_file));
try
    % idx reward
    idx_regular = find(strcmp({R.reward_size_type},'regular')  & idx_response);
    idx_regular_temp = strcmp({R.reward_size_type},'regular')  & idx_response;
    idx_small= find(strcmp({R.reward_size_type},'omission')  & idx_response);
    idx_large= find(strcmp({R.reward_size_type},'large')  & idx_response);
    
    idx_odd_small = idx_regular(1:2:numel(idx_small));
    idx_even_small = idx_regular(2:2:numel(idx_small));
    
    idx_odd_large = idx_regular(1:2:numel(idx_large));
    idx_even_large = idx_regular(2:2:numel(idx_large));
    
catch
    idx_regular = find(1:1:num_trials  & idx_response);
    idx_regular_temp = 1:1:num_trials  & idx_response;
end
idx_odd_regular = idx_regular(1:2:numel(idx_regular));
idx_even_regular = idx_regular(2:2:numel(idx_regular));

try
    % idx order in a block
    num_trials_in_block=mode([Block.num_trials_in_block]); %the most frequently occurring number of trials per block (in case num trials in block change within session)
    begin_mid_end_bins = linspace(2,num_trials_in_block,4);
    idx_first = find([Block.current_trial_num_in_block]==1 & idx_response & idx_regular_temp);
    idx_begin = find(([Block.current_trial_num_in_block]>=begin_mid_end_bins(1) & [Block.current_trial_num_in_block]<=floor(begin_mid_end_bins(2)) ) & idx_response & idx_regular_temp);
    idx_mid=   find(([Block.current_trial_num_in_block]>begin_mid_end_bins(2) & [Block.current_trial_num_in_block]<=round(begin_mid_end_bins(3)) ) & idx_response & idx_regular_temp);
    idx_end=   find(([Block.current_trial_num_in_block]>begin_mid_end_bins(3) & [Block.current_trial_num_in_block]<=ceil(begin_mid_end_bins(4)) ) & idx_response & idx_regular_temp);
    
    
    idx_odd_first = idx_regular(1:2:numel(idx_first));
    idx_even_first = idx_regular(2:2:numel(idx_first));
    
    idx_odd_begin = idx_regular(1:2:numel(idx_begin));
    idx_even_begin = idx_regular(2:2:numel(idx_begin));
    
    idx_odd_mid = idx_regular(1:2:numel(idx_mid));
    idx_even_mid = idx_regular(2:2:numel(idx_mid));
    
    idx_odd_end = idx_regular(1:2:numel(idx_end));
    idx_even_end = idx_regular(2:2:numel(idx_end));
catch
end

for i_roi=1:1:size(S,1)
    
    key_ROI1(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI1(i_roi).session_epoch_number = key.session_epoch_number;
    
    key_ROI2(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI2(i_roi).session_epoch_number = key.session_epoch_number;
    
    key_ROI3(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI3(i_roi).session_epoch_number = key.session_epoch_number;
    
    key_ROI4(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI4(i_roi).session_epoch_number = key.session_epoch_number;
    
    %% PSTH
    spikes=S(i_roi).dff_trace;

    if isempty(time_resample_bin)
        for i_tr = 1:1:numel(start_file)
            if idx_response(i_tr)==0 %its an ignore trial
                psth_all{i_tr}=NaN;
                continue
            end
            s=spikes(start_file(i_tr):end_file(i_tr));
            s=movmean(s,[smooth_window_frames 0],'omitnan','Endpoints','shrink');
            time=(1:1:numel(s))/frame_rate + fr_interval(1);
            %         s_interval=s(time>fr_interval(1) & time<=fr_interval(2));
            %         fr_all(i_roi,i_tr)= max(s_interval); %taking the max
            psth_all{i_tr}=s;
        end
    else
        time_new_bins = [fr_interval(1):time_resample_bin:fr_interval(end)];
        time_new = time_new_bins(1:end-1)+mean(diff(time_new_bins)/2);
        for i_tr = 1:1:numel(start_file)
            if idx_response(i_tr)==0 %its an ignore trial
                psth_all{i_tr}=NaN;
                continue
            end
            s=spikes(start_file(i_tr):end_file(i_tr));
            s=movmean(s,[smooth_window_frames 0],'omitnan','Endpoints','shrink');
            time=(1:1:numel(s))/frame_rate + fr_interval(1);
            for i_t = 1:numel(time_new_bins)-1
                idx_t = time>time_new_bins(i_t) & time<=time_new_bins(i_t+1);
                s_resampled(i_t) = mean(s(idx_t));
            end
            psth_all{i_tr}=s_resampled;
        end
        time = time_new;
    end
    
    psth_regular = mean(cell2mat(psth_all(idx_regular)'),1);
    psth_regular_stem = std(cell2mat(psth_all(idx_regular)'),1)/sqrt(numel(idx_regular));
    psth_regular_odd =  nanmean(cell2mat(psth_all(idx_odd_regular)'),1);
    psth_regular_even =  nanmean(cell2mat(psth_all(idx_even_regular)'),1);
    
    key_ROI1(i_roi).psth_regular = psth_regular;
    key_ROI1(i_roi).psth_regular_stem = psth_regular_stem;
    key_ROI1(i_roi).psth_regular_odd = psth_regular_odd;
    key_ROI1(i_roi).psth_regular_even = psth_regular_even;
    key_ROI1(i_roi).psth_time = time;
    
    r = corr([psth_regular_odd(:),psth_regular_even(:)],'Rows' ,'pairwise');
    key_ROI2(i_roi).psth_regular_odd_vs_even_corr = r(2);
    
    [~,idx_peak]=max(psth_regular);
    key_ROI2(i_roi).peaktime_psth_regular = time(idx_peak);
    [~,idx_peak]=max(psth_regular_odd);
    key_ROI2(i_roi).peaktime_psth_regular_odd = time(idx_peak);
    [~,idx_peak]=max(psth_regular_even);
    key_ROI2(i_roi).peaktime_psth_regular_even = time(idx_peak);
    
    
    try
        %% Reward
        % Taking the mean PSTH across trials
        psth_small =  nanmean(cell2mat(psth_all(idx_small)'),1);
        psth_small_stem = std(cell2mat(psth_all(idx_small)'),1)/sqrt(numel(idx_small));
        psth_small_odd =  nanmean(cell2mat(psth_all(idx_odd_small)'),1);
        psth_small_even =  nanmean(cell2mat(psth_all(idx_even_small)'),1);
        
        psth_large =  nanmean(cell2mat(psth_all(idx_large)'),1);
        psth_large_stem = std(cell2mat(psth_all(idx_large)'),1)/sqrt(numel(idx_large));
        psth_large_odd =  nanmean(cell2mat(psth_all(idx_odd_large)'),1);
        psth_large_even =  nanmean(cell2mat(psth_all(idx_even_large)'),1);
        
        key_ROI1(i_roi).psth_small = psth_small;
        key_ROI1(i_roi).psth_small_stem = psth_small_stem;
        key_ROI1(i_roi).psth_small_odd = psth_small_odd;
        key_ROI1(i_roi).psth_small_even = psth_small_even;
        
        key_ROI1(i_roi).psth_large = psth_large;
        key_ROI1(i_roi).psth_large_stem = psth_large_stem;
        key_ROI1(i_roi).psth_large_odd = psth_large_odd;
        key_ROI1(i_roi).psth_large_even = psth_large_even;
        
        
        r = corr([psth_small_odd(:),psth_small_even(:)],'Rows' ,'pairwise');
        key_ROI2(i_roi).psth_small_odd_vs_even_corr = r(2);
        
        r = corr([psth_large_odd(:),psth_large_even(:)],'Rows' ,'pairwise');
        key_ROI2(i_roi).psth_large_odd_vs_even_corr = r(2);
        
        r = corr([psth_regular(:),psth_small(:)],'Rows' ,'pairwise');
        key_ROI2(i_roi).psth_regular_vs_small_corr = r(2);
        
        r = corr([psth_regular(:),psth_large(:)],'Rows' ,'pairwise');
        key_ROI2(i_roi).psth_regular_vs_large_corr = r(2);
        
        r = corr([psth_small(:),psth_large(:)],'Rows' ,'pairwise');
        key_ROI2(i_roi).psth_small_vs_large_corr = r(2);
        
        
        [~,idx_peak_small]=max(psth_small);
        key_ROI2(i_roi).peaktime_psth_small = time(idx_peak_small);
        [~,idx_peak_regular]=max(psth_regular);
        key_ROI2(i_roi).peaktime_psth_regular = time(idx_peak_regular);
        [~,idx_peak_large]=max(psth_large);
        key_ROI2(i_roi).peaktime_psth_large = time(idx_peak_large);
        
        % single trials, averaged across all time duration in a specific time interval (e.g. after the  licport onset (t>=0))
        idx_onset = time>=fr_interval_limit(1) & time <fr_interval_limit(2);
        temp=cell2mat(psth_all(idx_regular)');
        psth_regular_trials =  nanmean(temp(:,idx_onset),2);
        temp=cell2mat(psth_all(idx_small)');
        psth_small_trials =  nanmean(temp(:,idx_onset),2);
        temp=cell2mat(psth_all(idx_large)');
        psth_large_trials =  nanmean(temp(:,idx_onset),2);
        
        [p,~] = ranksum(psth_regular_trials,psth_small_trials);
        key_ROI2(i_roi).reward_mean_pval_regular_small = p;
        [p,~] = ranksum(psth_regular_trials,psth_large_trials);
        key_ROI2(i_roi).reward_mean_pval_regular_large = p;
        [p,~] = ranksum(psth_small_trials,psth_large_trials);
        key_ROI2(i_roi).reward_mean_pval_small_large = p;
        
        key_ROI2(i_roi).reward_mean_regular = nanmean(psth_regular_trials);
        key_ROI2(i_roi).reward_mean_small = nanmean(psth_small_trials);
        key_ROI2(i_roi).reward_mean_large = nanmean(psth_large_trials);
        
        
        % at peak response time
        temp =  cell2mat(psth_all(idx_regular)');
        psth_regular_trials_peak = temp(:,idx_peak_regular);
        temp =  cell2mat(psth_all(idx_small)');
        psth_small_trials_peak = temp(:,idx_peak_small);
        temp =  cell2mat(psth_all(idx_large)');
        psth_large_trials_peak = temp(:,idx_peak_large);
        
        key_ROI2(i_roi).reward_peak_regular = nanmean(psth_regular_trials_peak);
        key_ROI2(i_roi).reward_peak_small = nanmean(psth_small_trials_peak);
        key_ROI2(i_roi).reward_peak_large = nanmean(psth_large_trials_peak);
        
        [p,~] = ranksum(psth_regular_trials_peak,psth_small_trials_peak);
        key_ROI2(i_roi).reward_peak_pval_regular_small = p;
        [p,~] = ranksum(psth_regular_trials_peak,psth_large_trials_peak);
        key_ROI2(i_roi).reward_peak_pval_regular_large = p;
        [p,~] = ranksum(psth_small_trials_peak,psth_large_trials_peak);
        key_ROI2(i_roi).reward_peak_pval_small_large = p;
        
        %         k2=key_ROI3(i_roi);
        %         insert(self3, k2);
    catch
    end
    
    try
        %% BLOCK
        % Taking the mean PSTH across trials
        psth_first =   nanmean(cell2mat(psth_all(idx_first)'),1);
        psth_first_stem = std(cell2mat(psth_all(idx_first)'),1)/sqrt(numel(idx_first));
        psth_first_odd =  nanmean(cell2mat(psth_all(idx_odd_first)'),1);
        psth_first_even =  nanmean(cell2mat(psth_all(idx_even_first)'),1);
        
        psth_begin =  nanmean(cell2mat(psth_all(idx_begin)'),1);
        psth_begin_stem = std(cell2mat(psth_all(idx_begin)'),1)/sqrt(numel(idx_begin));
        psth_begin_odd =  nanmean(cell2mat(psth_all(idx_odd_begin)'),1);
        psth_begin_even =  nanmean(cell2mat(psth_all(idx_even_begin)'),1);
        
        psth_mid =  nanmean(cell2mat(psth_all(idx_mid)'),1);
        psth_mid_stem = std(cell2mat(psth_all(idx_mid)'),1)/sqrt(numel(idx_mid));
        psth_mid_odd =  nanmean(cell2mat(psth_all(idx_odd_mid)'),1);
        psth_mid_even =  nanmean(cell2mat(psth_all(idx_even_mid)'),1);
        
        psth_end =  nanmean(cell2mat(psth_all(idx_end)'),1);
        psth_end_stem = std(cell2mat(psth_all(idx_end)'),1)/sqrt(numel(idx_end));
        psth_end_odd =  nanmean(cell2mat(psth_all(idx_odd_end)'),1);
        psth_end_even =  nanmean(cell2mat(psth_all(idx_even_end)'),1);
        
        
        
        
        key_ROI3(i_roi).psth_first = psth_first;
        key_ROI3(i_roi).psth_first_stem = psth_first_stem;
        key_ROI3(i_roi).psth_first_odd = psth_first_odd;
        key_ROI3(i_roi).psth_first_even= psth_first_even;
        
        key_ROI3(i_roi).psth_begin = psth_begin;
        key_ROI3(i_roi).psth_begin_stem = psth_begin_stem;
        key_ROI3(i_roi).psth_begin_odd = psth_begin_odd;
        key_ROI3(i_roi).psth_begin_even= psth_begin_even;
        
        key_ROI3(i_roi).psth_mid = psth_mid;
        key_ROI3(i_roi).psth_mid_stem = psth_mid_stem;
        key_ROI3(i_roi).psth_mid_odd = psth_mid_odd;
        key_ROI3(i_roi).psth_mid_even= psth_mid_even;
        
        key_ROI3(i_roi).psth_end = psth_end;
        key_ROI3(i_roi).psth_end_stem = psth_end_stem;
        key_ROI3(i_roi).psth_end_odd = psth_end_odd;
        key_ROI3(i_roi).psth_end_even= psth_end_even;
        
        %Stability
        r = corr([psth_first_odd(:),psth_first_even(:)],'Rows' ,'pairwise');
        key_ROI4(i_roi).psth_first_odd_vs_even_corr = r(2);
        
        r = corr([psth_begin_odd(:),psth_begin_even(:)],'Rows' ,'pairwise');
        key_ROI4(i_roi).psth_begin_odd_vs_even_corr = r(2);
        
        r = corr([psth_mid_odd(:),psth_mid_even(:)],'Rows' ,'pairwise');
        key_ROI4(i_roi).psth_mid_odd_vs_even_corr = r(2);
        
        r = corr([psth_end_odd(:),psth_end_even(:)],'Rows' ,'pairwise');
        key_ROI4(i_roi).psth_end_odd_vs_even_corr = r(2);
        
        %Between conditions
        r = corr([psth_first(:),psth_begin(:)],'Rows' ,'pairwise');
        key_ROI4(i_roi).psth_first_vs_begin_corr = r(2);
        
        r = corr([psth_first(:),psth_mid(:)],'Rows' ,'pairwise');
        key_ROI4(i_roi).psth_first_vs_mid_corr = r(2);
        
        r = corr([psth_first(:),psth_end(:)],'Rows' ,'pairwise');
        key_ROI4(i_roi).psth_first_vs_end_corr = r(2);
        
        r = corr([psth_begin(:),psth_end(:)],'Rows' ,'pairwise');
        key_ROI4(i_roi).psth_begin_vs_end_corr = r(2);
        
        r = corr([psth_begin(:),psth_mid(:)],'Rows' ,'pairwise');
        key_ROI4(i_roi).psth_begin_vs_mid_corr = r(2);
        
        r = corr([psth_mid(:),psth_end(:)],'Rows' ,'pairwise');
        key_ROI4(i_roi).psth_mid_vs_end_corr = r(2);
        
        
        [~,idx_peak_first]=max(psth_first);
        key_ROI4(i_roi).peaktime_psth_first = time(idx_peak_first);
        [~,idx_peak_begin]=max(psth_begin);
        key_ROI4(i_roi).peaktime_psth_begin = time(idx_peak_begin);
        [~,idx_peak_mid]=max(psth_mid);
        key_ROI4(i_roi).peaktime_psth_mid = time(idx_peak_mid);
        [~,idx_peak_end]=max(psth_end);
        key_ROI4(i_roi).peaktime_psth_end = time(idx_peak_end);
        
        % single trials, averaged across all time duration in a specific time interval (e.g. after the  licport onset (t>=0))
        idx_onset = time>=fr_interval_limit(1) & time <fr_interval_limit(2);
        temp=cell2mat(psth_all(idx_first)');
        psth_first_trials =  nanmean(temp(:,idx_onset),2);
        temp=cell2mat(psth_all(idx_begin)');
        psth_begin_trials =  nanmean(temp(:,idx_onset),2);
        temp=cell2mat(psth_all(idx_mid)');
        psth_mid_trials =  nanmean(temp(:,idx_onset),2);
        temp=cell2mat(psth_all(idx_end)');
        psth_end_trials =  nanmean(temp(:,idx_onset),2);
        

        key_ROI4(i_roi).block_mean_first = nanmean(psth_first_trials);
        key_ROI4(i_roi).block_mean_begin = nanmean(psth_begin_trials);
        key_ROI4(i_roi).block_mean_mid = nanmean(psth_mid_trials);
        key_ROI4(i_roi).block_mean_end = nanmean(psth_end_trials);
        
        [p,~] = ranksum(psth_first_trials,psth_begin_trials);
        key_ROI4(i_roi).block_mean_pval_first_begin = p;
        [p,~] = ranksum(psth_first_trials,psth_end_trials);
        key_ROI4(i_roi).block_mean_pval_first_end = p;
        [p,~] = ranksum(psth_begin_trials,psth_end_trials);
        key_ROI4(i_roi).block_mean_pval_begin_end = p;
        
        
        % at peak response time
        temp =  cell2mat(psth_all(idx_first)');
        psth_first_trials_peak = temp(:,idx_peak_first);
        temp =  cell2mat(psth_all(idx_begin)');
        psth_begin_trials_peak = temp(:,idx_peak_begin);
        temp =  cell2mat(psth_all(idx_mid)');
        psth_mid_trials_peak = temp(:,idx_peak_mid);
        temp =  cell2mat(psth_all(idx_end)');
        psth_end_trials_peak = temp(:,idx_peak_end);
        
        key_ROI4(i_roi).block_peak_first = nanmean(psth_first_trials_peak);
        key_ROI4(i_roi).block_peak_begin = nanmean(psth_begin_trials_peak);
        key_ROI4(i_roi).block_peak_mid = nanmean(psth_mid_trials_peak);
        key_ROI4(i_roi).block_peak_end = nanmean(psth_end_trials_peak);
        
        [p,~] = ranksum(psth_first_trials_peak,psth_begin_trials_peak);
        key_ROI4(i_roi).block_peak_pval_first_begin = p;
        [p,~] = ranksum(psth_first_trials_peak,psth_end_trials_peak);
        key_ROI4(i_roi).block_peak_pval_first_end = p;
        [p,~] = ranksum(psth_begin_trials_peak,psth_end_trials_peak);
        key_ROI4(i_roi).block_peak_pval_begin_end = p;
        
        
        %         k2=key_ROI4(i_roi);
        %         insert(self4, k2);
        
    catch
    end
    
    %     k2=key_ROI1(i_roi);
    %     insert(self, k2);
    %     k2=key_ROI2(i_roi);
    %     insert(self2, k2);
    
end
insert(self, key_ROI1);
insert(self2, key_ROI2);
try
    insert(self3, key_ROI3);
catch
end
try
    insert(self4, key_ROI4);
catch
end