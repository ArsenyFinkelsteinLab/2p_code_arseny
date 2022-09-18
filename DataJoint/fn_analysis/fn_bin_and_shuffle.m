function [hist_bins_centers, y_binned_mean,y_binned_stem, y_binned_shuffled_mean, y_binned_shuffled_stem] = fn_bin_and_shuffle (hist_bins, num_shuffles, k, y);

hist_bins_centers = hist_bins(1:end-1) + diff(hist_bins(1:1:2))/2;
x=k;
[y_binned_mean, y_binned_stem]= fn_bin_data(x,y,hist_bins);


%% shuffle x
temp=[];
for i_s=1:1:num_shuffles
    x=k(randperm(numel(k)));
[y_binned_mean_shuffled_temp]= fn_bin_data(x,y,hist_bins);
temp(i_s,:) = y_binned_mean_shuffled_temp;
end
y_binned_shuffled_mean = nanmean(temp,1);
y_binned_shuffled_stem = nanstd(temp,[],1)/sqrt(num_shuffles);