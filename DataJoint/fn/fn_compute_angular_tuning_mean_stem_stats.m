function [THETA_TUNING] = fn_compute_angular_tuning_mean_stem_stats (fr_all, i_roi, num_trials,  idx_trials, timespent_min, theta_bins_centers, theta_idx, smoothing_window_1D, min_percent_coverage)

%% per angular bin
for i_theta=1:1:numel(theta_bins_centers)
    idx_bin= find( (theta_idx==i_theta));
    idx_trials_at_bin=find(ismember(1:1:num_trials,idx_bin) & idx_trials);
    
    if numel(idx_trials_at_bin)>=timespent_min
        theta_tuning(i_theta) = mean(fr_all(i_roi,idx_trials_at_bin));
        theta_tuning_stem(i_theta) = std(fr_all(i_roi,idx_trials_at_bin))/sqrt(numel(idx_trials_at_bin));
        
        idx_odd=idx_trials_at_bin(1:2:end);
        theta_tuning_odd(i_theta) = mean(fr_all(i_roi,idx_odd));
        theta_tuning_stem_odd(i_theta) = std(fr_all(i_roi,idx_odd))/sqrt(numel(idx_odd));
        
        idx_even=idx_trials_at_bin(2:2:end);
        theta_tuning_even(i_theta) = mean(fr_all(i_roi,idx_even));
        theta_tuning_stem_even(i_theta) = std(fr_all(i_roi,idx_even))/sqrt(numel(idx_even));
        
    else
        theta_tuning(i_theta)=NaN;
        theta_tuning_stem(i_theta)=NaN;
        
        theta_tuning_odd(i_theta)=NaN;
        theta_tuning_stem_odd(i_theta)=NaN;
        
        theta_tuning_even(i_theta)=NaN;
        theta_tuning_stem_even(i_theta)=NaN;
    end
    
    
end


% to avoid negative "firing rates"
if min(theta_tuning)<0
    theta_tuning = theta_tuning - min(theta_tuning);
end
if min(theta_tuning_odd)<0
    theta_tuning_odd = theta_tuning_odd - min(theta_tuning_odd);
end
if min(theta_tuning_even)<0
    theta_tuning_even = theta_tuning_even - min(theta_tuning_even);
end

%% Minimal coverage condition check
percent_theta_coverage = 100*(sum(~isnan(theta_tuning))/numel(theta_tuning));
if percent_theta_coverage >=min_percent_coverage
    flag_NaN = 0;
else
    flag_NaN = NaN;
end

percent_theta_coverage_odd = 100*(sum(~isnan(theta_tuning_odd))/numel(theta_tuning_odd));
if percent_theta_coverage_odd >=min_percent_coverage
    flag_NaN_odd = 0;
else
    flag_NaN_odd = NaN;
end

percent_theta_coverage_even = 100*(sum(~isnan(theta_tuning_even))/numel(theta_tuning_even));
if percent_theta_coverage_even >=min_percent_coverage
    flag_NaN_even = 0;
else
    flag_NaN_even = NaN;
end

%% circula smoothing and statistics

[theta_tuning, theta_tuning_stem, preferred_theta, rayleigh_length]  = fn_circular_smoothing_and_stats ...
    (theta_tuning, theta_tuning_stem, theta_bins_centers, smoothing_window_1D, 1);

[~, preferred_direction_vmises, theta_tuning_vmises, goodness_of_fit_vmises] ...
    = fn_compute_von_mises (theta_tuning, theta_bins_centers+179);
preferred_direction_vmises=preferred_direction_vmises-179;

%odd
[theta_tuning_odd, theta_tuning_stem_odd, preferred_theta_odd, ~]  = fn_circular_smoothing_and_stats ...
    (theta_tuning_odd, theta_tuning_stem_odd, theta_bins_centers, smoothing_window_1D, 1);

[~, preferred_direction_vmises_odd, ~, ~] ...
    = fn_compute_von_mises (theta_tuning_odd, theta_bins_centers+179);
preferred_direction_vmises_odd=preferred_direction_vmises_odd-179;


%even
[theta_tuning_even, theta_tuning_stem_even, preferred_theta_even, ~]  = fn_circular_smoothing_and_stats ...
    (theta_tuning_even, theta_tuning_stem_even, theta_bins_centers, smoothing_window_1D, 1);

[~, preferred_direction_vmises_even, ~, ~] ...
    = fn_compute_von_mises (theta_tuning_even, theta_bins_centers+179);
preferred_direction_vmises_even=preferred_direction_vmises_even-179;


% Von mises fit - with baseline subtraction
%     baseline_FR = nanmin(theta_fr_mean_smoothed);
%     [~, preferred_direction_vmises, theta_fr_mean_vmises, r2_vmises] ...
%         = fn_compute_von_mises (theta_fr_mean_smoothed - baseline_FR, theta_bins_centers+180);
%     theta_fr_mean_vmises = theta_fr_mean_vmises+baseline_FR;

% Von mises fit - without baseline subtraction

r_odd_even=corr([theta_tuning_odd',theta_tuning_even'],'Rows' ,'pairwise');
r_odd_even=r_odd_even(2);





THETA_TUNING.theta_tuning=theta_tuning;
THETA_TUNING.theta_tuning_vmises=theta_tuning_vmises;
THETA_TUNING.theta_tuning_stem=theta_tuning_stem;
THETA_TUNING.preferred_direction=preferred_theta + flag_NaN;
THETA_TUNING.preferred_direction_vmises=preferred_direction_vmises + flag_NaN;
THETA_TUNING.goodness_of_fit_vmises=goodness_of_fit_vmises + flag_NaN;
THETA_TUNING.rayleigh_length = rayleigh_length+ flag_NaN;

THETA_TUNING.theta_tuning_odd=theta_tuning_odd;
THETA_TUNING.preferred_direction_odd=preferred_theta_odd + flag_NaN_odd;
THETA_TUNING.preferred_direction_vmises_odd=preferred_direction_vmises_odd  + flag_NaN_odd;

THETA_TUNING.theta_tuning_even=theta_tuning_even;
THETA_TUNING.preferred_direction_even=preferred_theta_even + flag_NaN_even;
THETA_TUNING.preferred_direction_vmises_even=preferred_direction_vmises_even  + flag_NaN_even;

THETA_TUNING.theta_tuning_odd_even_corr=r_odd_even + flag_NaN_even + flag_NaN_odd;

THETA_TUNING.percent_theta_coverage = percent_theta_coverage;
THETA_TUNING.percent_theta_coverage_odd   = percent_theta_coverage_odd;
THETA_TUNING.percent_theta_coverage_even  = percent_theta_coverage_even;
