function [Rayleigh_length, r_odd_even]=fn_computer_Lick2Dangle_shuffle2(fr_all,theta_idx, theta_bins_centers, i_roi, timespent_min, smoothing_window_1D)

for i_theta=1:1:numel(theta_bins_centers)
    idx= find( (theta_idx==i_theta) );
    theta_spikes_binned(i_theta) = sum(fr_all(i_roi,idx));
    theta_timespent_binned(i_theta)=numel(idx);
    
    idx_odd=idx(1:2:end);
    idx_even=idx(2:2:end);
    
    theta_spikes_binned_odd(i_theta) = sum(fr_all(i_roi,idx_odd));
    theta_timespent_binned_odd(i_theta)=numel(idx_odd);
    
    theta_spikes_binned_even(i_theta) = sum(fr_all(i_roi,idx_even));
    theta_timespent_binned_even(i_theta)=numel(idx_even);
end

[~, ~, ~,Rayleigh_length]  = fn_compute_generic_1D_tuning2 ...
    (theta_timespent_binned, theta_spikes_binned, theta_bins_centers, timespent_min,  smoothing_window_1D, 1, 1);

[ ~, theta_firing_rate_smoothed_odd, ~ ,~]  = fn_compute_generic_1D_tuning2 ...
    (theta_timespent_binned_odd, theta_spikes_binned_odd, theta_bins_centers, timespent_min,  smoothing_window_1D, 1, 1);

[ ~, theta_firing_rate_smoothed_even, ~ ,~]  = fn_compute_generic_1D_tuning2 ...
    (theta_timespent_binned_even, theta_spikes_binned_even, theta_bins_centers, timespent_min,  smoothing_window_1D, 1, 1);

r_odd_even=corr([theta_firing_rate_smoothed_odd',theta_firing_rate_smoothed_even'],'Rows' ,'pairwise');
r_odd_even=r_odd_even(2);

end