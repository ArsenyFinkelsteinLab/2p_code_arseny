function [r_binned_all, r_binned_positive, r_binned_negative, corr_histogram_per_distance]=  fn_POP_binning_distance_corr(distance_bins,corr_histogram_bins, all_distance, i_d, all_corr, idx_positive_r, idx_negative_r)

idx_dist_bin=all_distance>=(distance_bins(i_d)) & all_distance<(distance_bins(i_d+1));

if sum(idx_dist_bin)>0
    r_binned_all=nanmean(all_corr(idx_dist_bin));
    r_binned_positive=nanmean(all_corr(idx_dist_bin & idx_positive_r));
    r_binned_negative=nanmean(all_corr(idx_dist_bin & idx_negative_r));
    corr_histogram_per_distance = histcounts(all_corr(idx_dist_bin),corr_histogram_bins);
else
    r_binned_all=NaN;
    r_binned_positive=NaN;
    r_binned_negative=NaN;
    corr_histogram_per_distance = zeros(1,numel(corr_histogram_bins)-1)+NaN;
end

