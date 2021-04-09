
function   [information_per_spike] = fn_compute_spatial_info (timespent_binned,firing_rate_binned)


%   INFORMATION PER SPIKE  (typically computed for the SMOOTHED field):
%======================================================================
%
%    Information_per_spike = sum( p_i * ( r_i / r ) * log2( r_i / r ) )
%    Where:
%       r_i = firing rate in bin i ;
%       p_i = occupancy probability of bin i = time-spent by bat in bin i / total time spent in all bins ;
%       r = mean( r_i ) = overall mean firing rate (mean over all the pixels)
% See: Skaggs WE, McNaughton BL, Wilson MA, Barnes CA, Hippocampus 6(2), 149-172 (1996).

idx_notNaN= ~isnan(timespent_binned);
r_i= firing_rate_binned( idx_notNaN );
p_i = timespent_binned( idx_notNaN ) ./ sum( timespent_binned( idx_notNaN ) ) ;
r_i = r_i(:) ; p_i = p_i(:) ; % Turn r_i and p_i into Column vectors
r_mean = sum( r_i .* p_i );
information_per_spike = sum( p_i .* ( r_i / r_mean ) .* log2( ( r_i + eps ) / r_mean ) ) ; % I added a tiny number to avoid log(0)
