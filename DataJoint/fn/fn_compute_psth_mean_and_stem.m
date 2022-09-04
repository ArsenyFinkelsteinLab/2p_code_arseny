function [psth_mean,psth_stem,psth_mean_odd,psth_mean_even,psth_stem_odd,psth_stem_even] = fn_compute_psth_mean_and_stem (psth_all, i_roi, num_trials, idx_bin, idx_trials, timespent_min, time)

idx_trials_at_bin=find(ismember(1:1:num_trials,idx_bin) & idx_trials);

if numel(idx_trials_at_bin)>=timespent_min
    %mean
    psth_mean= single(mean(cell2mat([psth_all(i_roi, idx_trials_at_bin)]'),1));
    %standard error of the mean
    psth_stem= single(std(cell2mat([psth_all(i_roi,idx_trials_at_bin)]'),1) /sqrt(numel(idx_trials_at_bin)));
else
    psth_mean = time+NaN;
    psth_stem = time+NaN;
end


%% odd trials
if numel(idx_trials_at_bin)>=timespent_min
    idx_trials_at_bin_odd=idx_trials_at_bin(1:2:end);
    %mean
    psth_mean_odd= single(mean(cell2mat([psth_all(i_roi, idx_trials_at_bin_odd)]'),1));
    %standard error of the mean
    psth_stem_odd= single(std(cell2mat([psth_all(i_roi,idx_trials_at_bin_odd)]'),1) /sqrt(numel(idx_trials_at_bin_odd)));
else
    psth_mean_odd = time+NaN;
    psth_stem_odd = time+NaN;
end

%% even trials
%% odd trials
if numel(idx_trials_at_bin)>=timespent_min
    idx_trials_at_bin_even=idx_trials_at_bin(2:2:end);
    %mean
    psth_mean_even= single(mean(cell2mat([psth_all(i_roi, idx_trials_at_bin_even)]'),1));
    %standard error of the mean
    psth_stem_even= single(std(cell2mat([psth_all(i_roi,idx_trials_at_bin_even)]'),1) /sqrt(numel(idx_trials_at_bin_even)));
else
    psth_mean_even = time+NaN;
    psth_stem_even = time+NaN;
end
