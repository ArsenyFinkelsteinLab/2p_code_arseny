function [X_timespent_binned, X_at_spikes_binned, X_firing_rate, X_firing_rate_smoothed, prefered_X,Rayleigh_length] ...
    = fn_compute_generic_1D_tuning ...
    (X_video, X_spikes, X_bins_vector_of_centers, time_spent_minimum_for_1D_bins, frames_per_second, smoothing_window_1D,perform_circular_smoothing,compute_Rayleigh_length)


% Computing a 1D-tuning curve
%--------------------------------------------------------------------------
X_timespent_binned=hist(X_video, X_bins_vector_of_centers)/frames_per_second;
X_at_spikes_binned=hist(X_spikes, X_bins_vector_of_centers);

X_firing_rate = (X_at_spikes_binned./X_timespent_binned);
% puts NaN in low occupancy bins
X_firing_rate (X_timespent_binned<(time_spent_minimum_for_1D_bins))=NaN;
X_timespent_binned=hist(X_video, X_bins_vector_of_centers)/frames_per_second;
X_at_spikes_binned=hist(X_spikes, X_bins_vector_of_centers);

X_firing_rate = (X_at_spikes_binned./X_timespent_binned);
% puts NaN in low occupancy bins
X_firing_rate (X_timespent_binned<(time_spent_minimum_for_1D_bins))=NaN;


% Smoothing
%--------------------------------------------------------------------------
if perform_circular_smoothing == 1 %perform circular smoothing (assumin X is a cyclical variable)
    X_firing_rate_smoothed = smooth ([X_firing_rate,X_firing_rate,X_firing_rate],smoothing_window_1D);
    X_firing_rate_smoothed = X_firing_rate_smoothed (length(X_bins_vector_of_centers)+1: 2*length(X_bins_vector_of_centers));
else %perform regular smoothing
    X_firing_rate_smoothed = smooth (X_firing_rate,smoothing_window_1D);
end
%puts NaN in low occupancy bins that were filled during smoothing
X_firing_rate_smoothed = X_firing_rate_smoothed'+(X_firing_rate.*0);


% Prefered X
%--------------------------------------------------------------------------
[temp prefered_X_idx]=nanmax(X_firing_rate_smoothed);
prefered_X=X_bins_vector_of_centers(prefered_X_idx);


% Rayleigh Vector length
%--------------------------------------------------------------------------
if compute_Rayleigh_length==1
X_firing_rate(isnan(X_firing_rate))=0; %replaces NaN with 0
%circular smoothing
X_firing_rate_nan_replaced_smoothed = smooth([X_firing_rate X_firing_rate X_firing_rate],smoothing_window_1D);
X_firing_rate_nan_replaced_smoothed = X_firing_rate_nan_replaced_smoothed(1+length(X_bins_vector_of_centers):(2*(length(X_bins_vector_of_centers))));
X_firing_rate_nan_replaced_smoothed=X_firing_rate_nan_replaced_smoothed+eps;
Rayleigh_length=((pi/length(X_bins_vector_of_centers))/sin(pi/length(X_bins_vector_of_centers))...
    *abs(sum(X_firing_rate_nan_replaced_smoothed'.*exp(1i*(pi/180)*...
    [360/length(X_bins_vector_of_centers):360/length(X_bins_vector_of_centers):360]))))...
    ./sum(X_firing_rate_nan_replaced_smoothed');
else
    Rayleigh_length=[];
end
