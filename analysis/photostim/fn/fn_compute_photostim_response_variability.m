function [StimStat, StimTrace] = fn_compute_photostim_response_variability (f_trace, photostim_start_frame, timewind_response, timewind_baseline1,timewind_baseline2,timewind_baseline3, flag_baseline_trial_or_avg, global_baseline, time)


counter=0;
num_frames_pre =  sum(time<0);
num_frames_post =  sum(time>0);
for i_stim=1:1:numel(photostim_start_frame)
    s_fr = photostim_start_frame(i_stim);
    if  (s_fr-num_frames_pre)>0 && (s_fr+num_frames_post)<=length(f_trace) % if the time window is within the full trace
        counter = counter+1;
        F(counter,:)=f_trace(s_fr- num_frames_pre :1:s_fr+num_frames_post-1);
    end
end
idx_include=1:1:counter;
idx_1half_trials=idx_include(1:1:(ceil(counter/2)));
idx_2half_trials=idx_include((ceil(counter/2)+1):1:end);
idx_odd_trials=idx_include(1:2:end);
idx_even_trials=idx_include(2:2:end);


idx_response(1)=find(time>(timewind_response(1)),1,'first');
idx_response(2)=find(time<=(timewind_response(2)),1,'last');

idx_baseline1(1)=find(time<=timewind_baseline1(1),1,'last');
idx_baseline1(2)=find(time<timewind_baseline1(2),1,'last');

idx_baseline2(1)=find(time<=timewind_baseline2(1),1,'last');
idx_baseline2(2)=find(time<timewind_baseline2(2),1,'last');

idx_baseline3(1)=find(time<=(timewind_baseline3(1)),1,'last');
idx_baseline3(2)=find(time<(timewind_baseline3(2)),1,'last');


if flag_baseline_trial_or_avg<3
    if flag_baseline_trial_or_avg==0 %baseline averaged across trials
        baseline= mean(mean(F(:,idx_baseline1(1):idx_baseline1(2))));
    elseif flag_baseline_trial_or_avg==1 % baseline per trial
        baseline= mean(F(:,idx_baseline1(1):idx_baseline1(2)),2);
    elseif flag_baseline_trial_or_avg==2 % global baseline
        baseline= global_baseline;
    end
    F =(F- baseline)./baseline;
elseif flag_baseline_trial_or_avg==3
    F=F;
end

response_trials=single(mean(F(:, idx_response(1):idx_response(2)),2));  %activity after stimulation, for each trial, averaged over response window
baseline_trials1=single(mean(F(:,idx_baseline1(1):idx_baseline1(2)),2)); % activity before stimulation for each trial, averaged over baseline window
baseline_trials2=single(mean(F(:,idx_baseline2(1):idx_baseline2(2)),2)); % activity before stimulation for each trial, averaged over baseline window
baseline_trials3=single(mean(F(:, idx_baseline3(1):idx_baseline3(2)),2));  %activity after stimulation, for each trial, averaged over response window

% delta_response_trials = response_trials - baseline_trials;
delta_response_trials = response_trials -baseline_trials2;

delta_response_peak_trials = single(max(F(:, idx_response(1):idx_response(2)),[],2)) -baseline_trials2;


delta_response_trials_1half = delta_response_trials(idx_1half_trials);
delta_response_trials_2half = delta_response_trials(idx_2half_trials);
delta_response_trials_odd = delta_response_trials(idx_odd_trials);
delta_response_trials_even = delta_response_trials(idx_even_trials);

%% Statistics, all trials
StimStat.response_mean = mean(delta_response_trials)+eps; % we add epsilon to avoid division by 0 in case the mean ie exactly zero
StimStat.response_max = max(delta_response_trials);
StimStat.response_min = min(delta_response_trials);
StimStat.response_std = std(delta_response_trials);
StimStat.response_mean_over_std  = mean(delta_response_trials)./(std(delta_response_trials)+eps);
StimStat.response_stem= StimStat.response_std/sqrt(numel(delta_response_trials));
StimStat.response_coefvar = StimStat.response_std/StimStat.response_mean;  % coefficient of variation
StimStat.response_fanofactor= var(delta_response_trials)/StimStat.response_mean;  % fano factor
% [~, StimStat.response_p_value,~, stats] = ttest2(baseline_trials,response_trials);
[~, StimStat.response_p_value1,~, stats] = ttest(response_trials, baseline_trials1);
StimStat.response_tstat = stats.tstat;
[~, StimStat.response_p_value2,~, ~] = ttest(response_trials, baseline_trials2);
[~, StimStat.response_p_value3,~, ~] = ttest(response_trials, baseline_trials3);


StimStat.response_trials = delta_response_trials;
StimStat.response_peak_trials = delta_response_peak_trials;


% Statistics 1st half of the trials
StimStat.response_mean_1half = mean(delta_response_trials_1half);
[~, StimStat.response_p_value1_1half] = ttest(response_trials(idx_1half_trials),baseline_trials1(idx_1half_trials));
[~, StimStat.response_p_value2_1half] = ttest(response_trials(idx_1half_trials),baseline_trials2(idx_1half_trials));
[~, StimStat.response_p_value3_1half] = ttest(response_trials(idx_1half_trials),baseline_trials3(idx_1half_trials));

% Statistics 2nd half of the trials
StimStat.response_mean_2half = mean(delta_response_trials_2half);
[~, StimStat.response_p_value1_2half] = ttest(response_trials(idx_2half_trials),baseline_trials1(idx_2half_trials));
[~, StimStat.response_p_value2_2half] = ttest(response_trials(idx_2half_trials),baseline_trials2(idx_2half_trials));
[~, StimStat.response_p_value3_2half] = ttest(response_trials(idx_2half_trials),baseline_trials3(idx_2half_trials));

% Statistics odd trials
StimStat.response_mean_odd = mean(delta_response_trials_odd);
[~, StimStat.response_p_value1_odd] = ttest(response_trials(idx_odd_trials),baseline_trials1(idx_odd_trials));
[~, StimStat.response_p_value2_odd] = ttest(response_trials(idx_odd_trials),baseline_trials2(idx_odd_trials));
[~, StimStat.response_p_value3_odd] = ttest(response_trials(idx_odd_trials),baseline_trials3(idx_odd_trials));

% Statistics odd trials
StimStat.response_mean_even = mean(delta_response_trials_even);
[~, StimStat.response_p_value1_even] = ttest(response_trials(idx_even_trials),baseline_trials1(idx_even_trials));
[~, StimStat.response_p_value2_even] = ttest(response_trials(idx_even_trials),baseline_trials2(idx_even_trials));
[~, StimStat.response_p_value3_even] = ttest(response_trials(idx_even_trials),baseline_trials3(idx_even_trials));




% StimTrace.F_trials = single(F);
StimTrace.response_trace_mean = single(mean(F,1));
StimTrace.response_trace_stem = single(std(F,1)./sqrt(size(F,1)));
StimTrace.response_trace_mean_1half = single(mean(F(idx_1half_trials,:),1));
StimTrace.response_trace_mean_2half = single(mean(F(idx_2half_trials,:),1));
StimTrace.response_trace_mean_odd = single(mean(F(idx_odd_trials,:),1));
StimTrace.response_trace_mean_even = single(mean(F(idx_even_trials,:),1));

StimTrace.response_trace_trials = single(F);



