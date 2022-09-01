function [psth_mean,psth_stem] = fn_compute_psth_mean_and_stem (psth_all, i_roi, num_trials, idx_bin, idx_trials, timespent_min, time)

idx_trials_at_bin=ismember(1:1:num_trials,idx_bin) & idx_trials;
if sum(idx_trials_at_bin)>=timespent_min
    %mean
    psth_mean= double(mean(cell2mat([psth_all(i_roi, idx_trials_at_bin)]'),1));
    %standard error of the mean
    psth_stem= double(std(cell2mat([psth_all(i_roi,idx_trials_at_bin)]'),1) /sqrt(sum(idx_trials_at_bin)));
else
    psth_mean = time+NaN;
    psth_stem = time+NaN;
end