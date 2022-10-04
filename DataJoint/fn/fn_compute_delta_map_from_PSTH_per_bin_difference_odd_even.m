function [delta_MAP_odd, delta_MAP_even, r ] = fn_compute_delta_map_from_PSTH_per_bin_difference_odd_even(PSTH_bins1,PSTH_bins2_odd,PSTH_bins2_even, psthmap_time, fr_interval_limit, meanFR1, meanFR2, min_percent_coverage)

A=PSTH_bins1;
B_odd=PSTH_bins2_odd;
B_even=PSTH_bins2_even;


idx_time = psthmap_time>=fr_interval_limit(1) & psthmap_time<fr_interval_limit(2);

bin_x=size(PSTH_bins1,1);
bin_y=size(PSTH_bins1,2);

for i_x = 1:1:bin_x
    for   i_y = 1:1:bin_y
        a_temp = A{i_x,i_y};
        b_temp_odd = B_odd{i_x,i_y};
        b_temp_even = B_even{i_x,i_y};
        if meanFR1>meanFR2 % we substract the map with lower mean FR  from map with higher mean FR
            delta_MAP_odd(i_x,i_y) = nanmean(a_temp(idx_time) - b_temp_odd(idx_time));
            delta_MAP_even(i_x,i_y) = nanmean(a_temp(idx_time) - b_temp_even(idx_time));
        else
            delta_MAP_odd(i_x,i_y) = nanmean(b_temp_odd(idx_time) - a_temp(idx_time));
            delta_MAP_even(i_x,i_y) = nanmean(b_temp_even(idx_time) - a_temp(idx_time));
        end
    end
end

percent_coverage_odd=100*(1-sum(isnan(delta_MAP_odd(:)))/numel(delta_MAP_odd(:)));
percent_coverage_even=100*(1-sum(isnan(delta_MAP_even(:)))/numel(delta_MAP_even(:)));

if  percent_coverage_odd>=min_percent_coverage & percent_coverage_even>=min_percent_coverage % minimal coverage needed for calculation

    r=corr([delta_MAP_odd(:),delta_MAP_even(:)],'Rows' ,'pairwise');
    r=r(2);
else
    r=NaN;
end