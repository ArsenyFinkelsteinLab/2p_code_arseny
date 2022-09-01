function fn_2d_map_per_roi (roi,P, key)


    %% PSTH
    spikes=S(i_roi).dff_trace;
    for i_tr = 1:1:numel(start_file)
        if idx_response(i_tr)==0 %its an ignore trial
            fr_all(i_roi,i_tr)=NaN;
            psth_all{i_roi,i_tr}=NaN;
            continue
        end
        s=spikes(start_file(i_tr):end_file(i_tr));
        s=movmean(s,[smooth_window_frames 0],'omitnan','Endpoints','shrink');
        time=(1:1:numel(s))/frame_rate + fr_interval(1);
        s_interval=s(time>fr_interval(1) & time<=fr_interval(2));
        fr_all(i_roi,i_tr)= sum(s_interval)/numel(s_interval); %taking mean fr
        %         fr_all(i_roi,i_tr)= max(s_interval); %taking the max
        psth_all{i_roi,i_tr}=s;
    end
    
    
    %% PSTH per position, and 2D maps
    for i_x=1:1:numel(x_bins_centers)
        for i_z=1:1:numel(z_bins_centers)
            %             idx = find((x_idx==i_x)  & ~isnan(start_file) &  (z_idx==i_z));
            idx = idx_xz{i_z,i_x};
            
            
            %% Binning for 2D 2D MAP calculation
            %spikes binned
            
            map_xz_spikes_regular(i_z,i_x) = sum(fr_all(i_roi, ismember(1:1:num_trials,idx) & idx_regular));
            map_xz_spikes_regular_odd(i_z,i_x) = sum(fr_all(i_roi, ismember(1:1:num_trials,idx) & idx_regular & idx_odd_regular   ));
            map_xz_spikes_regular_even(i_z,i_x) = sum(fr_all(i_roi,  ismember(1:1:num_trials,idx) & idx_regular & idx_even_regular   ));
            
            try
                map_xz_spikes_small(i_z,i_x) = sum(fr_all(i_roi, ismember(1:1:num_trials,idx) & idx_small));
                map_xz_spikes_large(i_z,i_x) = sum(fr_all(i_roi, ismember(1:1:num_trials,idx) & idx_large));
                map_xz_spikes_first(i_z,i_x) = sum(fr_all(i_roi, ismember(1:1:num_trials,idx)  & idx_first));
                map_xz_spikes_begin(i_z,i_x) = sum(fr_all(i_roi, ismember(1:1:num_trials,idx) & idx_begin));
                map_xz_spikes_mid(i_z,i_x) = sum(fr_all(i_roi, ismember(1:1:num_trials,idx)  & idx_mid));
                map_xz_spikes_end(i_z,i_x) = sum(fr_all(i_roi, ismember(1:1:num_trials,idx) & idx_end));
            catch end
            
            % timespent binned
            map_xz_timespent_regular(i_z,i_x) = sum( ismember(1:1:num_trials,idx) & idx_regular);
            
            map_xz_timespent_regular_odd(i_z,i_x) = sum( ismember(1:1:num_trials,idx) & idx_regular & idx_odd_regular);
            map_xz_timespent_regular_even(i_z,i_x) = sum( ismember(1:1:num_trials,idx) & idx_regular & idx_even_regular);
            try
                map_xz_timespent_small(i_z,i_x) = sum( ismember(1:1:num_trials,idx) & idx_small);
                map_xz_timespent_large(i_z,i_x) = sum( ismember(1:1:num_trials,idx) & idx_large);
                map_xz_timespent_first(i_z,i_x) = sum( ismember(1:1:num_trials,idx) & idx_first);
                map_xz_timespent_begin(i_z,i_x) = sum( ismember(1:1:num_trials,idx)  & idx_begin);
                map_xz_timespent_mid(i_z,i_x) = sum( ismember(1:1:num_trials,idx)  & idx_mid);
                map_xz_timespent_end(i_z,i_x) = sum( ismember(1:1:num_trials,idx)  & idx_end);
            catch end
            %% Binning for 2D PSTH calculation
            if numel(idx)>=timespent_min
                %mean
                psth_per_position_regular{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx) & idx_regular)   ]'),1));
                psth_per_position_regular_odd{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi,  ismember(1:1:num_trials,idx) & idx_regular & idx_odd_regular)  ]')  ,1)) ;
                psth_per_position_regular_even{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx) & idx_regular & idx_even_regular) ]') ,1));
                %stem
                psth_per_position_regular_stem{i_z,i_x}= double(std(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx) & idx_regular)   ]'),1) /sqrt(sum(ismember(1:1:num_trials,idx) & idx_regular)));
            else
                %mean
                psth_per_position_regular{i_z,i_x}=  time+NaN;
                psth_per_position_regular_odd{i_z,i_x}=  time+NaN;
                psth_per_position_regular_even{i_z,i_x}=  time+NaN;
                %stem
                psth_per_position_regular_stem{i_z,i_x}=  time+NaN;
            end
            
            try
                if numel(idx)>=timespent_min_partial
                    %mean
                    psth_per_position_small{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx) & idx_small)   ]'),1));
                    psth_per_position_large{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx) & idx_large)   ]'),1));
                    psth_per_position_first{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx) & idx_first)   ]'),1));
                    psth_per_position_begin {i_z,i_x}= double(mean(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx)  & idx_begin)   ]'),1));
                    psth_per_position_mid{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx) & idx_mid)   ]'),1));
                    psth_per_position_end{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx)  & idx_end)   ]'),1));
                    %stem
                    psth_per_position_small_stem{i_z,i_x}= double(std(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx) & idx_small)   ]'),1) /sqrt(sum(ismember(1:1:num_trials,idx) & idx_small)));
                    psth_per_position_large_stem{i_z,i_x}= double(std(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx) & idx_large)   ]'),1) /sqrt(sum(ismember(1:1:num_trials,idx) & idx_large)));
                    psth_per_position_first_stem{i_z,i_x}= double(std(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx) & idx_first)   ]'),1)/sqrt(sum(ismember(1:1:num_trials,idx) & idx_first)));
                    psth_per_position_begin_stem{i_z,i_x}= double(std(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx)  & idx_begin)   ]'),1) /sqrt(sum(ismember(1:1:num_trials,idx) & idx_begin)));
                    psth_per_position_mid_stem{i_z,i_x}= double(std(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx) & idx_mid)   ]'),1) /sqrt(sum(ismember(1:1:num_trials,idx) & idx_mid)));
                    psth_per_position_end_stem{i_z,i_x}= double(std(cell2mat([psth_all(i_roi, ismember(1:1:num_trials,idx)  & idx_end)   ]'),1) /sqrt(sum(ismember(1:1:num_trials,idx) & idx_end)));
                else
                    
                    %mean
                    psth_per_position_small{i_z,i_x}= time+NaN;
                    psth_per_position_large{i_z,i_x}=time+NaN;
                    psth_per_position_first{i_z,i_x}= time+NaN;
                    psth_per_position_begin {i_z,i_x}= time+NaN;
                    psth_per_position_mid{i_z,i_x}= time+NaN;
                    psth_per_position_end{i_z,i_x}= time+NaN;
                    %stem
                    psth_per_position_small_stem{i_z,i_x}= time+NaN;
                    psth_per_position_large_stem{i_z,i_x}=time+NaN;
                    psth_per_position_first_stem{i_z,i_x}= time+NaN;
                    psth_per_position_begin_stem {i_z,i_x}= time+NaN;
                    psth_per_position_mid_stem{i_z,i_x}= time+NaN;
                    psth_per_position_end_stem{i_z,i_x}= time+NaN;
                end
            catch end
            
        end
    end
    
    %% Actual 2D map calculation
    [~, lickmap_fr_regular, ~, information_per_spike_regular, ~, ~, ~, ~, field_size_regular, field_size_without_baseline_regular, ~, centroid_without_baseline_regular] ...
        = fn_compute_generic_2D_field3 ...
        (x_bins, z_bins, map_xz_timespent_regular, map_xz_spikes_regular, timespent_min, sigma, hsize, 0);
    
    [~, lickmap_fr_regular_odd] ...
        = fn_compute_generic_2D_field3 ...
        (x_bins, z_bins, map_xz_timespent_regular_odd, map_xz_spikes_regular_odd, timespent_min, sigma, hsize, 0);
    
    [~, lickmap_fr_regular_even] ...
        = fn_compute_generic_2D_field3 ...
        (x_bins, z_bins, map_xz_timespent_regular_even, map_xz_spikes_regular_even, timespent_min, sigma, hsize, 0);
    
    try
        [~, lickmap_fr_small, ~, information_per_spike_small, ~, ~, ~, ~, field_size_small, field_size_without_baseline_small, ~, centroid_without_baseline_small] ...
            = fn_compute_generic_2D_field3 ...
            (x_bins, z_bins, map_xz_timespent_small, map_xz_spikes_small, timespent_min, sigma, hsize, 0);
        
        [~, lickmap_fr_large, ~, information_per_spike_large, ~, ~, ~, ~, field_size_large, field_size_without_baseline_large, ~, centroid_without_baseline_large] ...
            = fn_compute_generic_2D_field3 ...
            (x_bins, z_bins, map_xz_timespent_large, map_xz_spikes_large, timespent_min, sigma, hsize, 0);
        
        [~, lickmap_fr_first, ~, information_per_spike_first, ~, ~, ~, ~, field_size_first, field_size_without_baseline_first, ~, centroid_without_baseline_first] ...
            = fn_compute_generic_2D_field3 ...
            (x_bins, z_bins, map_xz_timespent_first, map_xz_spikes_first, timespent_min, sigma, hsize, 0);
        
        [~, lickmap_fr_begin, ~, information_per_spike_begin, ~, ~, ~, ~, field_size_begin, field_size_without_baseline_begin, ~, centroid_without_baseline_begin] ...
            = fn_compute_generic_2D_field3 ...
            (x_bins, z_bins, map_xz_timespent_begin, map_xz_spikes_begin, timespent_min, sigma, hsize, 0);
        
        [~, lickmap_fr_mid, ~, information_per_spike_mid, ~, ~, ~, ~, field_size_mid, field_size_without_baseline_mid, ~, centroid_without_baseline_mid] ...
            = fn_compute_generic_2D_field3 ...
            (x_bins, z_bins, map_xz_timespent_mid, map_xz_spikes_mid, timespent_min, sigma, hsize, 0);
        
        [~, lickmap_fr_end, ~, information_per_spike_end, ~, ~, ~, ~, field_size_end, field_size_without_baseline_end, ~, centroid_without_baseline_end] ...
            = fn_compute_generic_2D_field3 ...
            (x_bins, z_bins, map_xz_timespent_end, map_xz_spikes_end, timespent_min, sigma, hsize, 0);
    catch end
    
    
    %% Correlations between 2D maps
    r_regular_odd_vs_even_corr=corr([lickmap_fr_regular_odd(:),lickmap_fr_regular_even(:)],'Rows' ,'pairwise');
    r_regular_odd_vs_even_corr=r_regular_odd_vs_even_corr(2);
    try
        r_regular_vs_small_corr=corr([lickmap_fr_regular(:),lickmap_fr_small(:)],'Rows' ,'pairwise');
        r_regular_vs_small_corr=r_regular_vs_small_corr(2);
        
        r_regular_vs_large_corr=corr([lickmap_fr_regular(:),lickmap_fr_large(:)],'Rows' ,'pairwise');
        r_regular_vs_large_corr=r_regular_vs_large_corr(2);
    catch end
    %% Preferred bin and radius on the 2D map (radius refers to when transforming the 2D tuning into polar plot)
    
    [preferred_bin_regular,idx_preferred_trials_regular, idx_non_preferred_trials_regular, preferred_radius_regular ] ...
        = fn_compute_Lick2D_preferred_2d_tuning_radius (lickmap_fr_regular, mat_x, mat_z, num_trials, idx_xz, key, idx_response, idx_regular);
    
    try
        [preferred_bin_small,idx_preferred_trials_small, idx_non_preferred_trials_small, preferred_radius_small ] ...
            = fn_compute_Lick2D_preferred_2d_tuning_radius (lickmap_fr_small, mat_x, mat_z, num_trials, idx_xz, key, idx_response, idx_small);
        
        [preferred_bin_large,idx_preferred_trials_large, idx_non_preferred_trials_large, preferred_radius_large ] ...
            = fn_compute_Lick2D_preferred_2d_tuning_radius (lickmap_fr_large, mat_x, mat_z, num_trials, idx_xz, key, idx_response, idx_large);
        
        [preferred_bin_first,idx_preferred_trials_first, idx_non_preferred_trials_first, preferred_radius_first ] ...
            = fn_compute_Lick2D_preferred_2d_tuning_radius (lickmap_fr_first, mat_x, mat_z, num_trials, idx_xz, key, idx_response, idx_first);
        
        [preferred_bin_begin,idx_preferred_trials_begin, idx_non_preferred_trials_begin, preferred_radius_begin ] ...
            = fn_compute_Lick2D_preferred_2d_tuning_radius (lickmap_fr_begin, mat_x, mat_z, num_trials, idx_xz, key, idx_response, idx_begin);
        
        [preferred_bin_mid,idx_preferred_trials_mid, idx_non_preferred_trials_mid, preferred_radius_mid ] ...
            = fn_compute_Lick2D_preferred_2d_tuning_radius (lickmap_fr_mid, mat_x, mat_z, num_trials, idx_xz, key, idx_response, idx_mid);
        
        [preferred_bin_end,idx_preferred_trials_end, idx_non_preferred_trials_end, preferred_radius_end ] ...
            = fn_compute_Lick2D_preferred_2d_tuning_radius (lickmap_fr_end, mat_x, mat_z, num_trials, idx_xz, key, idx_response, idx_end);
    catch end
    %--------------------------------------------------------------------------------------------------------------------------------------
    %% DJ insertion of 2D mAP
    key_ROI1(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI1(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI1(i_roi).number_of_bins = key.number_of_bins;
    key_ROI1(i_roi).lickmap_fr_regular = lickmap_fr_regular;
    try
        key_ROI1(i_roi).lickmap_fr_small = lickmap_fr_small;
        key_ROI1(i_roi).lickmap_fr_large = lickmap_fr_large;
        key_ROI1(i_roi).lickmap_fr_first = lickmap_fr_first;
        key_ROI1(i_roi).lickmap_fr_begin = lickmap_fr_begin;
        key_ROI1(i_roi).lickmap_fr_mid = lickmap_fr_mid;
        key_ROI1(i_roi).lickmap_fr_end = lickmap_fr_end;
    catch
    end
    key_ROI1(i_roi).lickmap_fr_regular_odd = lickmap_fr_regular_odd;
    key_ROI1(i_roi).lickmap_fr_regular_even = lickmap_fr_regular_even;
    key_ROI1(i_roi).pos_x_bins_centers = x_bins_centers;
    key_ROI1(i_roi).pos_z_bins_centers = z_bins_centers;
    
    
    %% DJ insertion of 2D map PSTH
    key_ROI2(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI2(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI2(i_roi).number_of_bins = key.number_of_bins;
    key_ROI2(i_roi).psthmap_time = time;
    key_ROI2(i_roi).psth_per_position_regular = psth_per_position_regular;
    try
        key_ROI2(i_roi).psth_per_position_small = psth_per_position_small;
        key_ROI2(i_roi).psth_per_position_large = psth_per_position_large;
        key_ROI2(i_roi).psth_per_position_first = psth_per_position_first;
        key_ROI2(i_roi).psth_per_position_begin = psth_per_position_begin;
        key_ROI2(i_roi).psth_per_position_mid = psth_per_position_mid;
        key_ROI2(i_roi).psth_per_position_end = psth_per_position_end;
    catch
    end
    key_ROI2(i_roi).psth_per_position_regular_odd = psth_per_position_regular_odd;
    key_ROI2(i_roi).psth_per_position_regular_even = psth_per_position_regular_even;
    
    key_ROI2(i_roi).psth_per_position_regular_stem = psth_per_position_regular_stem;
    try
        key_ROI2(i_roi).psth_per_position_small_stem = psth_per_position_small_stem;
        key_ROI2(i_roi).psth_per_position_large_stem = psth_per_position_large_stem;
        key_ROI2(i_roi).psth_per_position_first_stem = psth_per_position_first_stem;
        key_ROI2(i_roi).psth_per_position_begin_stem = psth_per_position_begin_stem;
        key_ROI2(i_roi).psth_per_position_mid_stem = psth_per_position_mid_stem;
        key_ROI2(i_roi).psth_per_position_end_stem = psth_per_position_end_stem;
    catch
    end
    key_ROI2(i_roi).pos_x_bins_centers = x_bins_centers;
    key_ROI2(i_roi).pos_z_bins_centers = z_bins_centers;
    
    
    
    %% DJ insertion of 2D map Stats
    key_ROI3(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI3(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI3(i_roi).number_of_bins = key.number_of_bins;
    key_ROI3(i_roi).lickmap_regular_odd_vs_even_corr = r_regular_odd_vs_even_corr;
    try
        key_ROI3(i_roi).lickmap_regular_vs_small_corr = r_regular_vs_small_corr;
        key_ROI3(i_roi).lickmap_regular_vs_large_corr = r_regular_vs_large_corr;
    catch end
    key_ROI3(i_roi).information_per_spike_regular = information_per_spike_regular;
    try
        key_ROI3(i_roi).information_per_spike_small = information_per_spike_small;
        key_ROI3(i_roi).information_per_spike_large = information_per_spike_large;
        key_ROI3(i_roi).information_per_spike_first = information_per_spike_first;
        key_ROI3(i_roi).information_per_spike_begin = information_per_spike_begin;
        key_ROI3(i_roi).information_per_spike_mid = information_per_spike_mid;
        key_ROI3(i_roi).information_per_spike_end = information_per_spike_end;
    catch end
    key_ROI3(i_roi).preferred_bin_regular = preferred_bin_regular;
    try
        key_ROI3(i_roi).preferred_bin_small = preferred_bin_small;
        key_ROI3(i_roi).preferred_bin_large = preferred_bin_large;
        key_ROI3(i_roi).preferred_bin_first = preferred_bin_first;
        key_ROI3(i_roi).preferred_bin_begin = preferred_bin_begin;
        key_ROI3(i_roi).preferred_bin_mid = preferred_bin_mid;
        key_ROI3(i_roi).preferred_bin_end = preferred_bin_end;
    catch end
    key_ROI3(i_roi).preferred_radius_regular = preferred_radius_regular;
    try
        key_ROI3(i_roi).preferred_radius_small = preferred_radius_small;
        key_ROI3(i_roi).preferred_radius_large = preferred_radius_large;
    catch end
    key_ROI3(i_roi).field_size_regular = field_size_regular;
    try
        key_ROI3(i_roi).field_size_small = field_size_small;
        key_ROI3(i_roi).field_size_large = field_size_large;
        key_ROI3(i_roi).field_size_first = field_size_first;
        key_ROI3(i_roi).field_size_begin = field_size_begin;
        key_ROI3(i_roi).field_size_mid = field_size_mid;
        key_ROI3(i_roi).field_size_end = field_size_end;
    catch end
    key_ROI3(i_roi).field_size_without_baseline_regular = field_size_without_baseline_regular;
    try
        key_ROI3(i_roi).field_size_without_baseline_small = field_size_without_baseline_small;
        key_ROI3(i_roi).field_size_without_baseline_large = field_size_without_baseline_large;
        key_ROI3(i_roi).field_size_without_baseline_first = field_size_without_baseline_first;
        key_ROI3(i_roi).field_size_without_baseline_begin = field_size_without_baseline_begin;
        key_ROI3(i_roi).field_size_without_baseline_mid = field_size_without_baseline_mid;
        key_ROI3(i_roi).field_size_without_baseline_end = field_size_without_baseline_end;
    catch end
    key_ROI3(i_roi).centroid_without_baseline_regular = centroid_without_baseline_regular;
    try
        key_ROI3(i_roi).centroid_without_baseline_small = centroid_without_baseline_small;
        key_ROI3(i_roi).centroid_without_baseline_large = centroid_without_baseline_large;
        key_ROI3(i_roi).centroid_without_baseline_first = centroid_without_baseline_first;
        key_ROI3(i_roi).centroid_without_baseline_begin = centroid_without_baseline_begin;
        key_ROI3(i_roi).centroid_without_baseline_mid = centroid_without_baseline_mid;
        key_ROI3(i_roi).centroid_without_baseline_end = centroid_without_baseline_end;
    catch end
    
    %% DJ Selectivity
    
    %preferred bins
    psth_preferred_regular =  nanmean(cell2mat(psth_all(i_roi, idx_preferred_trials_regular)'),1);
    psth_preferred_regular_stem =  nanstd(cell2mat(psth_all(i_roi, idx_preferred_trials_regular)'),0,1)/sqrt(sum(idx_preferred_trials_regular));
    
    psth_preferred_regular_odd =  nanmean(cell2mat(psth_all(i_roi, idx_preferred_trials_regular & idx_odd_regular)'),1);
    psth_preferred_regular_even = nanmean(cell2mat(psth_all(i_roi,idx_preferred_trials_regular  & idx_even_regular)'),1);
    
    
    %non preferred bins
    psth_non_preferred_regular =  nanmean(cell2mat(psth_all(i_roi, idx_non_preferred_trials_regular)'),1);
    psth_non_preferred_regular_stem =  nanstd(cell2mat(psth_all(i_roi, idx_non_preferred_trials_regular)'),0,1)/sqrt(sum(idx_non_preferred_trials_regular));
    
    psth_non_preferred_regular_odd =  nanmean(cell2mat(psth_all(i_roi, idx_non_preferred_trials_regular & idx_odd_regular)'),1);
    psth_non_preferred_regular_even = nanmean(cell2mat(psth_all(i_roi,idx_non_preferred_trials_regular  & idx_even_regular)'),1);
    
    
    
    
    %% DJ insetion of selectivity
    selectivity_regular =psth_preferred_regular - psth_non_preferred_regular;
    selectivity_regular_odd = psth_preferred_regular_odd - psth_non_preferred_regular_odd;
    selectivity_regular_even = psth_preferred_regular_even - psth_non_preferred_regular_even;
    
    key_ROI4(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI4(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI4(i_roi).number_of_bins = key.number_of_bins;
    key_ROI4(i_roi).psth_preferred_regular =  psth_preferred_regular;
    key_ROI4(i_roi).psth_preferred_regular_odd =  psth_preferred_regular_odd;
    key_ROI4(i_roi).psth_preferred_regular_even =  psth_preferred_regular_even;
    key_ROI4(i_roi).psth_non_preferred_regular = psth_non_preferred_regular;
    key_ROI4(i_roi).psth_preferred_regular_stem =  psth_preferred_regular_stem;
    key_ROI4(i_roi).psth_non_preferred_regular_stem = psth_non_preferred_regular_stem;
    
    key_ROI4(i_roi).selectivity_regular = selectivity_regular;
    key_ROI4(i_roi).selectivity_regular_odd = selectivity_regular_odd;
    key_ROI4(i_roi).selectivity_regular_even = selectivity_regular_even;
    key_ROI4(i_roi).psth_time = time;
    
    try
        %selectivity parsed by reward size
        if sum(idx_preferred_trials_small)>timespent_min
            selectivity_small =nanmean(cell2mat(psth_all(i_roi,idx_preferred_trials_small)'),1) -  nanmean(cell2mat(psth_all(i_roi,idx_non_preferred_trials_small)'),1);
        else
            selectivity_small=time + NaN;
        end
        if sum(idx_preferred_trials_large)>timespent_min
            selectivity_large =nanmean(cell2mat(psth_all(i_roi,idx_preferred_trials_large)'),1) -  nanmean(cell2mat(psth_all(i_roi,idx_non_preferred_trials_large)'),1);
        else
            selectivity_large=time + NaN;
        end
        
        
        % selectivity parsed by trial order in blocks
        if sum(idx_preferred_trials_first)>timespent_min
            selectivity_first = nanmean(cell2mat(psth_all(i_roi,idx_preferred_trials_first)'),1) -  nanmean(cell2mat(psth_all(i_roi,idx_non_preferred_trials_first)'),1);
        else
            selectivity_first=time + NaN;
        end
        
        if sum(idx_preferred_trials_begin)>timespent_min
            selectivity_begin = nanmean(cell2mat(psth_all(i_roi,idx_preferred_trials_begin)'),1) -  nanmean(cell2mat(psth_all(i_roi,idx_non_preferred_trials_begin)'),1);
        else
            selectivity_begin=time + NaN;
        end
        
        if sum(idx_preferred_trials_mid)>timespent_min
            selectivity_mid = nanmean(cell2mat(psth_all(i_roi,idx_preferred_trials_mid)'),1) -  nanmean(cell2mat(psth_all(i_roi,idx_non_preferred_trials_mid)'),1);
        else
            selectivity_mid=time + NaN;
        end
        
        if sum(idx_preferred_trials_end)>timespent_min
            selectivity_end = nanmean(cell2mat(psth_all(i_roi,idx_preferred_trials_end)'),1) -  nanmean(cell2mat(psth_all(i_roi,idx_non_preferred_trials_end)'),1);
        else
            selectivity_end=time + NaN;
        end
        
        key_ROI4(i_roi).selectivity_small = selectivity_small;
        key_ROI4(i_roi).selectivity_large = selectivity_large;
        key_ROI4(i_roi).selectivity_first = selectivity_first;
        key_ROI4(i_roi).selectivity_begin = selectivity_begin;
        key_ROI4(i_roi).selectivity_mid = selectivity_mid;
        key_ROI4(i_roi).selectivity_end = selectivity_end;
        
    catch end
    
    %% DJ Selectivity Stats
    
    key_ROI5(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI5(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI5(i_roi).number_of_bins = key.number_of_bins;
    
    r = corr([psth_preferred_regular_odd(:),psth_preferred_regular_even(:)+eps],'Rows' ,'pairwise');
    key_ROI5(i_roi).psth_preferred_regular_odd_even_corr = r(2);
    
    [~,idx_peak]=max(psth_preferred_regular);
    key_ROI5(i_roi).peaktime_preferred_regular = time(idx_peak);
    [~,idx_peak]=max(psth_preferred_regular_odd);
    key_ROI5(i_roi).peaktime_preferred_regular_odd = time(idx_peak);
    [~,idx_peak]=max(psth_preferred_regular_even);
    key_ROI5(i_roi).peaktime_preferred_regular_even = time(idx_peak);
    r = corr([selectivity_regular_odd(:),selectivity_regular_even(:)],'Rows' ,'pairwise');
    key_ROI5(i_roi).selectivity_odd_even_corr= r(2);
    r = corr([selectivity_regular_odd(:),selectivity_regular_even(:)],'Rows' ,'pairwise');
    key_ROI5(i_roi).selectivity_odd_even_corr = r(2);
    
    [~,idx_peak]=max(selectivity_regular);
    key_ROI5(i_roi).peaktime_selectivity_regular = time(idx_peak);
    [~,idx_peak]=max(selectivity_regular_odd);
    key_ROI5(i_roi).peaktime_selectivity_odd = time(idx_peak);
    [~,idx_peak]=max(selectivity_regular_even);
    key_ROI5(i_roi).peaktime_selectivity_even = time(idx_peak);
    
    try
        [~,idx_peak]=max(selectivity_small);
        key_ROI5(i_roi).peaktime_selectivity_small = time(idx_peak);
        [~,idx_peak]=max(selectivity_large);
        key_ROI5(i_roi).peaktime_selectivity_large = time(idx_peak);
        [~,idx_peak]=max(selectivity_first);
        key_ROI5(i_roi).peaktime_selectivity_first = time(idx_peak);
        [~,idx_peak]=max(selectivity_begin);
        key_ROI5(i_roi).peaktime_selectivity_begin = time(idx_peak);
        [~,idx_peak]=max(selectivity_mid);
        key_ROI5(i_roi).peaktime_selectivity_mid = time(idx_peak);
        [~,idx_peak]=max(selectivity_end);
        key_ROI5(i_roi).peaktime_selectivity_end = time(idx_peak);
    catch end
    
    
    % per ROI insertion
    %     k1=key_ROI1(i_roi);
    %     insert(self, k1);
    %
    %     k2=key_ROI2(i_roi);
    %     insert(self2, k2);
    %
    %     k3=key_ROI3(i_roi);
    %     insert(self3, k3);
    %
    %     k4=key_ROI4(i_roi);
    %     insert(self4, k4);
    %
    %     k5=key_ROI5(i_roi);
    %     insert(self5, k5);
end

