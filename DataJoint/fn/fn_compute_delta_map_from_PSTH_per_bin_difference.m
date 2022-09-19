function delta_MAP = fn_compute_delta_map_from_PSTH_per_bin_difference(PSTH_bins1,PSTH_bins2, psthmap_time, fr_interval_limit, meanFR1, meanFR2)

if meanFR1>meanFR2 % we substract the map with lower mean FR  from map with higher mean FR
    A=PSTH_bins1;
    B=PSTH_bins2;
else
    B=PSTH_bins1;
    A=PSTH_bins2;
end

idx_time = psthmap_time>=fr_interval_limit(1) & psthmap_time<fr_interval_limit(2);

bin_x=size(PSTH_bins1,1);
bin_y=size(PSTH_bins1,2);

for i_x = 1:1:bin_x
    for   i_y = 1:1:bin_y
        a_temp = A{i_x,i_y};
        b_temp = B{i_x,i_y};
        delta_MAP(i_x,i_y) = nanmean(a_temp(idx_time) - b_temp(idx_time));
    end
end
