function r = fn_compute_correlations_between_positions(PSTH_bins, min_modulation)

PSTH_bins = cell2mat(PSTH_bins(:))';
mean_per_position = nanmean(PSTH_bins,1);
max_position = nanmax(mean_per_position);
mean_per_position=mean_per_position./max_position;
idx_include_position = mean_per_position>=min_modulation;
if sum(idx_include_position)<=1
    r=NaN;
else
    PSTH_bins_include = PSTH_bins(:,idx_include_position);
    r=corr(PSTH_bins_include,'Rows' ,'pairwise');
    idx_diag = find(diag(diag(r)));
    idx_tril=logical(tril(r));
    idx_tril(idx_diag)= 0;
    r=nanmean(r(idx_tril));
end