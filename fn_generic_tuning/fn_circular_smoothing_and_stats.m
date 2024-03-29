function [X_firing_rate_smoothed, X_firing_rate_stem_smoothed, prefered_X, Rayleigh_length] ...
    = fn_circular_smoothing_and_stats ...
    (X_firing_rate, X_firing_rate_stem, X_bins_vector_of_centers, smoothing_window_1D, perform_circular_smoothing)

% Smoothing of mean vector
%--------------------------------------------------------------------------
if perform_circular_smoothing == 1 %perform circular smoothing (assumin X is a cyclical variable)
    X_firing_rate_smoothed = smooth ([X_firing_rate,X_firing_rate,X_firing_rate],smoothing_window_1D);
    X_firing_rate_smoothed = X_firing_rate_smoothed (length(X_bins_vector_of_centers)+1: 2*length(X_bins_vector_of_centers));
else %perform regular smoothing
    X_firing_rate_smoothed = smooth (X_firing_rate,smoothing_window_1D);
end
%putting back potentials NaN values, that could have been  filled during smoothing
X_firing_rate_smoothed = X_firing_rate_smoothed'+(X_firing_rate.*0);


% Smoothing of stem vector
%--------------------------------------------------------------------------
if perform_circular_smoothing == 1 %perform circular smoothing (assumin X is a cyclical variable)
    X_firing_rate_stem_smoothed = smooth ([X_firing_rate_stem,X_firing_rate_stem,X_firing_rate_stem],smoothing_window_1D);
    X_firing_rate_stem_smoothed = X_firing_rate_stem_smoothed (length(X_bins_vector_of_centers)+1: 2*length(X_bins_vector_of_centers));
else %perform regular smoothing
    X_firing_rate_stem_smoothed = smooth (X_firing_rate_stem_smoothed,smoothing_window_1D);
end
%putting back potentials NaN values, that could have been  filled during smoothing
X_firing_rate_stem_smoothed = X_firing_rate_stem_smoothed'+(X_firing_rate.*0);

% Prefered X
%--------------------------------------------------------------------------
[~, prefered_X_idx]=nanmax(X_firing_rate_smoothed);
prefered_X=X_bins_vector_of_centers(prefered_X_idx);


% Rayleigh Vector length
%--------------------------------------------------------------------------
X_firing_rate(isnan(X_firing_rate))=0; %replaces NaN with 0
%circular smoothing
X_firing_rate_nan_replaced_smoothed = smooth([X_firing_rate X_firing_rate X_firing_rate],smoothing_window_1D);
X_firing_rate_nan_replaced_smoothed = X_firing_rate_nan_replaced_smoothed(1+length(X_bins_vector_of_centers):(2*(length(X_bins_vector_of_centers))));
X_firing_rate_nan_replaced_smoothed=X_firing_rate_nan_replaced_smoothed+eps;
Rayleigh_length=((pi/length(X_bins_vector_of_centers))/sin(pi/length(X_bins_vector_of_centers))...
    *abs(sum(X_firing_rate_nan_replaced_smoothed'.*exp(1i*(pi/180)*...
    [360/length(X_bins_vector_of_centers):360/length(X_bins_vector_of_centers):360]))))...
    ./sum(X_firing_rate_nan_replaced_smoothed');



