function [StimStat] = fn_compute_photostim_delta_influence5_1st2nd_half (f_trace, photostim_start_frame,baseline_start_frame, timewind_response,time)



% target sites
% tic
num_frames_pre =  sum(time<0);
num_frames_post =  sum(time>=0);
photostim_start_frame=photostim_start_frame((photostim_start_frame-num_frames_pre>0) & (photostim_start_frame+num_frames_post<=numel(f_trace)));
F=zeros(numel(photostim_start_frame),(num_frames_pre+num_frames_post));
for i_stim=1:1:numel(photostim_start_frame)
    s_fr = photostim_start_frame(i_stim);
    F(i_stim,:)=f_trace(s_fr- num_frames_pre :1:s_fr+num_frames_post-1);
end
% toc
num_trials_used = numel(photostim_start_frame);
idx_trials = 1:1:num_trials_used;

idx_1half_trials=idx_trials(1:1:(ceil(num_trials_used/2)));
idx_2half_trials=idx_trials((ceil(num_trials_used/2)+1):1:end);

% idx_odd_trials=idx_trials(1:2:end);
% idx_even_trials=idx_trials(2:2:end);


%control sites
% tic
num_frames_pre =  sum(time<0);
num_frames_post =  sum(time>=0);
baseline_start_frame=baseline_start_frame((baseline_start_frame-num_frames_pre>0) & (baseline_start_frame+num_frames_post<=numel(f_trace)));
F_baseline=zeros(numel(baseline_start_frame),(num_frames_pre+num_frames_post));
for i_stim=1:1:numel(baseline_start_frame)
    s_fr = baseline_start_frame(i_stim);
    F_baseline(i_stim,:)=f_trace(s_fr- num_frames_pre :1:s_fr+num_frames_post-1);
end
F_baseline_mean = mean(F_baseline,1);
% toc


idx_response(1)=find(time>(timewind_response(1)),1,'first');
idx_response(2)=find(time<=(timewind_response(2)),1,'last');

% idx_not_response = 1:1:numel(time);
% idx_not_response(idx_response) = [];


% idx_response=idx_response+1;


delta_trace_trials = single(F -F_baseline_mean);
delta_response_trials=single(mean(delta_trace_trials(:, idx_response(1):idx_response(2)),2));

% F_response_trials = single(mean(F(:, idx_response(1):idx_response(2)),2));
% F_baseline_trials = single(mean(F_baseline(:, idx_response(1):idx_response(2)),2));



% delta_response_trials_1half = delta_response_trials(idx_1half_trials);
% delta_response_trials_2half = delta_response_trials(idx_2half_trials);
delta_response_trials_1half = delta_response_trials(idx_1half_trials);
delta_response_trials_2half = delta_response_trials(idx_2half_trials);

% StimStat.response_min_1half = min(mean(delta_trace_trials(idx_1half_trials,idx_response),1));
% StimStat.response_max_1half = max(mean(delta_trace_trials(idx_1half_trials,idx_response),1));
% StimStat.non_response_min_1half = min(mean(delta_trace_trials(idx_1half_trials,idx_not_response),1));
% StimStat.non_response_max_1half = max(mean(delta_trace_trials(idx_1half_trials,idx_not_response),1));



%% Statistics, all trials
StimStat.response_mean = mean(delta_response_trials);
StimStat.response_max = max(delta_response_trials);
StimStat.response_min = min(delta_response_trials);
StimStat.response_std = std(delta_response_trials);
StimStat.response_mean_over_std  = mean(delta_response_trials)/std(f_trace);
StimStat.response_stem= StimStat.response_std/sqrt(numel(delta_response_trials));
StimStat.response_coefvar = StimStat.response_std/(StimStat.response_mean + eps);  % coefficient of variation
StimStat.response_fanofactor= var(delta_response_trials)/(StimStat.response_mean + eps);  % fano factor
% [~, StimStat.response_p_value,~, stats] = ttest2(baseline_trials,response_trials);
[~, StimStat.response_p_value1,~, stats] = ttest(delta_response_trials);
StimStat.response_tstat = stats.tstat;


% [StimStat.response_p_value2] = ranksum(F_response_trials,F_baseline_trials);
% [StimStat.response_p_value2_1half] = ranksum(F_response_trials(idx_1half_trials),F_baseline_trials);
% [StimStat.response_p_value2_2half] = ranksum(F_response_trials(idx_2half_trials),F_baseline_trials);


% % Statistics 1st half of the trials
% StimStat.response_mean_1half = mean(delta_response_trials_1half);
% [~, StimStat.response_p_value1_1half] = ttest(delta_response_trials(idx_1half_trials));
% % [~, StimStat.response_p_value2_1half] = ttest(delta_baseline_trials1(idx_1half_trials));
% % [~, StimStat.response_p_value3_1half] =  ttest(delta_baseline_trials2(idx_1half_trials));
%
% % Statistics 2nd half of the trials
% StimStat.response_mean_2half = mean(delta_response_trials_2half);
% [~, StimStat.response_p_value1_2half] = ttest(delta_response_trials(idx_2half_trials));
% % [~, StimStat.response_p_value2_2half] =ttest(delta_baseline_trials1(idx_2half_trials));
% % [~, StimStat.response_p_value3_2half] = ttest(delta_baseline_trials2(idx_2half_trials));

% Statistics 1half trials
StimStat.response_mean_1half = mean(delta_response_trials_1half);
StimStat.response_mean_over_std_1half = mean(delta_response_trials_1half)/std(f_trace);
[~, StimStat.response_p_value1_1half] = ttest(delta_response_trials(idx_1half_trials));
% [~, StimStat.response_p_value2_1half] = ttest(delta_baseline_trials1(idx_1half_trials));
% [~, StimStat.response_p_value3_1half] =ttest(delta_baseline_trials2(idx_1half_trials));

% Statistics 2half trials
StimStat.response_mean_2half = mean(delta_response_trials_2half);
StimStat.response_mean_over_std_2half = mean(delta_response_trials_2half)/std(f_trace);
[~, StimStat.response_p_value1_2half] = ttest(delta_response_trials(idx_2half_trials));
% [~, StimStat.response_p_value2_2half] = ttest(delta_baseline_trials1(idx_2half_trials));
% [~, StimStat.response_p_value3_2half] = ttest(delta_baseline_trials2(idx_2half_trials));

[~, StimStat.p_value_1half_vs_2half]  = ttest2(delta_response_trials_1half,delta_response_trials_2half);
    

% % StimTrace.F_trials = single(F);
% StimTrace.response_trace_mean = single(mean(delta_trace_trials,1));
% % StimTrace.response_trace_stem = single(std(delta_trace_trials,1)./sqrt(size(delta_trace_trials,1)));
% StimTrace.response_trace_mean_1half = single(mean(delta_trace_trials(idx_1half_trials,:),1));
% StimTrace.response_trace_mean_2half = single(mean(delta_trace_trials(idx_2half_trials,:),1));

% StimTrace.response_trace_mean_over_std = single(mean(delta_trace_trials,1)/std(f_trace));
% StimTrace.response_trace_mean_over_std_1half = single(mean(delta_trace_trials(idx_1half_trials,:),1)/std(f_trace));
% StimTrace.response_trace_mean_over_std_2half = single(mean(delta_trace_trials(idx_2half_trials,:),1)/std(f_trace));

% StimTrace.baseline_trace_mean = single(F_baseline_mean);
% StimTrace.responseraw_trace_mean = single(mean(F,1));





% clf
% subplot(2,2,1:2)
% hold on
% plot([1:1:numel(f_trace)],f_trace,'-k');
% % plot(baseline_start_frame,f_trace(baseline_start_frame),'.b')
% % plot(photostim_start_frame,f_trace(photostim_start_frame),'or');
% plot(photostim_start_frame+1,f_trace(photostim_start_frame+1),'og');
% plot(photostim_start_frame+2,f_trace(photostim_start_frame+2),'ob');
% % plot(photostim_start_frame+3,f_trace(photostim_start_frame+3),'oy');
% 
% 
% mean(f_trace(baseline_start_frame));
% 
% subplot(2,2,3)
% hold on
% plot(time, single(mean(delta_trace_trials,1)))
% 
% subplot(2,2,4)
% hold on
% plot(time, F_baseline_mean,'-k')
% % plot(time, mean(F,1),'-g')
% plot(time, mean(F(idx_1half_trials,:),1),'-r')
% plot(time, mean(F(idx_2half_trials,:),1),'-b')
% 
% 
% % if StimStat.response_p_value1_1half<=0.01 & (StimStat.response_min_1half<StimStat.non_response_min_1half || StimStat.response_max_1half>StimStat.non_response_max_1half)
% if    StimStat.response_p_value1_1half<=0.01 & StimStat.response_mean_1half>0 %& StimStat.response_p_value1<0.01 %&  (StimStat.response_min_1half<StimStat.non_response_min_1half) 
% %     a=1
% %     mean(f_trace(photostim_start_frame))
% % mean(f_trace(photostim_start_frame+1))
% % mean(f_trace(photostim_start_frame+2))
% % mean(f_trace(photostim_start_frame+3))
% StimStat.response_p_value1
% end