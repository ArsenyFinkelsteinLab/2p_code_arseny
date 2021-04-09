function [r_odd_even, information_per_spike]=fn_computer_Lick2Dmap_shuffle2(fr_all,x_bins_centers,z_bins_centers,x_bins,z_bins,  x_idx, z_idx, i_roi, sigma, hsize, timespent_min);

for i_x=1:1:numel(x_bins_centers)
    for i_z=1:1:numel(z_bins_centers)
        idx = find((x_idx==i_x) & (z_idx==i_z));
        idx_odd=idx(1:2:end);
        idx_even=idx(2:2:end);
        map_xz_spikes_binned(i_x,i_z) = sum(fr_all(i_roi,idx));
        map_xz_spikes_binned_odd(i_x,i_z) = sum(fr_all(i_roi,idx_odd));
        map_xz_spikes_binned_even(i_x,i_z) = sum(fr_all(i_roi,idx_even));
        
        map_xz_timespent_binned(i_x,i_z) = numel(idx);
        map_xz_timespent_binned_even(i_x,i_z) = numel(idx_odd);
        map_xz_timespent_binned_odd(i_x,i_z) = numel(idx_even);
        
    end
end


[~, ~, ~, information_per_spike, ~, ~, ~, ~] ...
    = fn_compute_generic_2D_field2 ...
    (x_bins, z_bins, map_xz_timespent_binned, map_xz_spikes_binned, timespent_min, sigma, hsize, 0);


[~, lickmap_fr_odd, ~, ~, ~, ~, ~, ~] ...
    = fn_compute_generic_2D_field2 ...
    (x_bins, z_bins, map_xz_timespent_binned_odd, map_xz_spikes_binned_odd, timespent_min, sigma, hsize, 0);

[~, lickmap_fr_even, ~, ~, ~, ~, ~, ~] ...
    = fn_compute_generic_2D_field2 ...
    (x_bins, z_bins, map_xz_timespent_binned_even, map_xz_spikes_binned_even, timespent_min, sigma, hsize, 0);

r_odd_even=corr([lickmap_fr_odd(:),lickmap_fr_even(:)],'Rows' ,'pairwise');
r_odd_even=r_odd_even(2);