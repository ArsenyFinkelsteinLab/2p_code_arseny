function fn_computer_Lick2Dmap(key,self)

timespent_min=10; %in trials
time_bin=[-3,3]; %2 sec for PSTH, aligned to lick
fr_interval=[key.fr_interval_start,key.fr_interval_end]/1000;

smooth_window=1; %frames for PSTH
sigma=1;
hsize=1;

key_ROI=fetch(IMG.ROI&key,'ORDER BY roi_number');

%% Rescaling, rotation, and binning
[POS] = fn_rescale_and_rotate_lickport_pos (key);
pos_x = POS.pos_x;
pos_z = POS.pos_z;

x_bins = linspace(-1, 1,key.number_of_bins+1);
x_bins_centers=x_bins(1:end-1)+mean(diff(x_bins))/2;

z_bins = linspace(-1,1,key.number_of_bins+1);
z_bins_centers=z_bins(1:end-1)+mean(diff(z_bins))/2;

x_bins(1)= -inf;
x_bins(end)= inf;
z_bins(1)= -inf;
z_bins(end)= inf;



%% Compute maps
[hhhhh, ~, ~, x_idx, z_idx] = histcounts2(pos_x,pos_z,x_bins,z_bins);

%plot(pos_x,pos_z,'.')

mat_x=repmat(x_bins_centers,key.number_of_bins,1);
mat_z=repmat(z_bins_centers',1,key.number_of_bins);


go_time=fetchn(EXP2.BehaviorTrialEvent & key & 'trial_event_type="go"','trial_event_time','LIMIT 1');
frame_rate = fetchn(IMG.FOVEpoch & key,'imaging_frame_rate');

Files=fetch(IMG.FrameStartFile & key,'*');
L=fetch(EXP2.ActionEvent & key,'*');

S=fetch(IMG.ROISpikes & key,'*');


for i_tr = 1:1:numel(pos_x)
    licks=[L(find([L.trial]==i_tr)).action_event_time];
    licks=licks(licks>go_time);
    if ~isempty(licks)
        start_file(i_tr)=Files(i_tr).session_epoch_file_start_frame + floor(licks(1)*frame_rate) + floor(time_bin(1)*frame_rate);
        end_file(i_tr)=start_file(i_tr)+ceil([time_bin(2)-time_bin(1)]*frame_rate);
        if start_file(i_tr)<=0
            start_file(i_tr)=NaN;
            end_file(i_tr)=NaN;
        end
    else
        start_file(i_tr)=NaN;
        end_file(i_tr)=NaN;
    end
end



for i_roi=1:1:size(S,1)
    
    spikes=S(i_roi).spikes_trace;
    for i_tr = 1:1:numel(pos_x)
        if isnan(start_file(i_tr))
            fr_all(i_roi,i_tr)=NaN;
            psth_all{i_roi,i_tr}=NaN;
            continue
        end
        s=spikes(start_file(i_tr):end_file(i_tr));
        s=movmean(s,[smooth_window 0],'omitnan','Endpoints','shrink');
        time=(1:1:numel(s))/frame_rate + time_bin(1);
        s_interval=s(time>fr_interval(1) & time<=fr_interval(2));
        fr_all(i_roi,i_tr)= sum(s_interval)/numel(s_interval); %taking mean fr
        %         fr_all(i_roi,i_tr)= max(s_interval); %taking the max
        psth_all{i_roi,i_tr}=s;
    end
    
    
    for i_x=1:1:numel(x_bins_centers)
        for i_z=1:1:numel(z_bins_centers)
            idx = find((x_idx==i_x)  & ~isnan(start_file) &  (z_idx==i_z));
            idx_odd=idx(1:2:end);
            idx_even=idx(2:2:end);
            map_xz_spikes_binned(i_z,i_x) = sum(fr_all(i_roi,idx));
            map_xz_spikes_binned_odd(i_z,i_x) = sum(fr_all(i_roi,idx_odd));
            map_xz_spikes_binned_even(i_z,i_x) = sum(fr_all(i_roi,idx_even));
            
            map_xz_timespent_binned(i_z,i_x) = numel(idx);
            map_xz_timespent_binned_even(i_z,i_x) = numel(idx_even);
            map_xz_timespent_binned_odd(i_z,i_x) = numel(idx_odd);
            
            if numel(idx)<timespent_min
                psth_per_position{i_z,i_x}=  time+NaN;
                psth_per_position_odd{i_z,i_x}= time+NaN;
                psth_per_position_even{i_z,i_x}= time+NaN;
            else
                psth_per_position{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi,idx)]'),1));
                psth_per_position_odd{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi,idx_odd)]'),1));
                psth_per_position_even{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi,idx_even)]'),1));
            end
        end
    end
    
    
    [~, lickmap_fr, ~, information_per_spike, ~, ~, ~, ~] ...
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
    
    [~,preferred_bin_idx]=nanmax(lickmap_fr(:));
    preferred_radius = sqrt(mat_x(preferred_bin_idx)^2 + mat_z(preferred_bin_idx)^2) ;
    
    
    %preferred versus non preferred bins
    [B,I_max]=sort(lickmap_fr(:));
    two_preferred_bin = I_max(end-1:end);
    psth_preferred =  nanmean(cell2mat({psth_per_position{two_preferred_bin}}'),1);
    psth_preferred_odd =  nanmean(cell2mat({psth_per_position_odd{two_preferred_bin}}'),1);
    psth_preferred_even =  nanmean(cell2mat({psth_per_position_even{two_preferred_bin}}'),1);

    key_ROI(i_roi).psth_preferred =  psth_preferred;
    key_ROI(i_roi).psth_preferred_odd =  psth_preferred_odd;
    key_ROI(i_roi).psth_preferred_even =  psth_preferred_even;

    r = corr([psth_preferred_odd(:),psth_preferred_even(:)],'Rows' ,'pairwise');
    key_ROI(i_roi).psth_preferred_odd_even_corr = r(2);

    non_preferred_bin_idx = 1:1:length(lickmap_fr(:));
    non_preferred_bin_idx(preferred_bin_idx)=[];
    psth_non_preferred=nanmean(cell2mat({psth_per_position{non_preferred_bin_idx}}'),1);
    psth_non_preferred_odd=nanmean(cell2mat({psth_per_position_odd{non_preferred_bin_idx}}'),1);
    psth_non_preferred_even=nanmean(cell2mat({psth_per_position_even{non_preferred_bin_idx}}'),1);

    r = corr([psth_non_preferred_odd(:),psth_non_preferred_even(:)],'Rows' ,'pairwise');
    key_ROI(i_roi).psth_non_preferred_odd_even_corr = r(2); 

        
    key_ROI(i_roi).psth_non_preferred = psth_non_preferred;
    key_ROI(i_roi).psth_non_preferred_odd = psth_non_preferred_odd;
    key_ROI(i_roi).psth_non_preferred_even = psth_non_preferred_even;

    selectivity =psth_preferred - psth_non_preferred;
    selectivity_odd = psth_preferred_odd - psth_non_preferred_odd;
    selectivity_even = psth_preferred_even - psth_non_preferred_even;

    key_ROI(i_roi).selectivity = selectivity;
    key_ROI(i_roi).selectivity_odd = selectivity_odd;
    key_ROI(i_roi).selectivity_even = selectivity_even;
    
     r = corr([selectivity_odd(:),selectivity_even(:)],'Rows' ,'pairwise');
     key_ROI(i_roi).psth_selectivity_odd_even_corr= r(2);


    key_ROI(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI(i_roi).number_of_bins = key.number_of_bins;
    key_ROI(i_roi).fr_interval_start =key.fr_interval_start;
    key_ROI(i_roi).fr_interval_end =key.fr_interval_end;
    
    
    key_ROI(i_roi).psth_per_position = psth_per_position;
    key_ROI(i_roi).psth_per_position_odd = psth_per_position_odd;
    key_ROI(i_roi).psth_per_position_even = psth_per_position_even;
    key_ROI(i_roi).psth_time = time;
    key_ROI(i_roi).lickmap_fr = lickmap_fr;
    key_ROI(i_roi).lickmap_fr_odd = lickmap_fr_odd;
    key_ROI(i_roi).lickmap_fr_even = lickmap_fr_even;
    key_ROI(i_roi).lickmap_odd_even_corr = r_odd_even;
    key_ROI(i_roi).pos_x_bins_centers = x_bins_centers;
    key_ROI(i_roi).pos_z_bins_centers = z_bins_centers;
    key_ROI(i_roi).information_per_spike = information_per_spike;
    key_ROI(i_roi).preferred_bin = preferred_bin_idx;
    key_ROI(i_roi).preferred_radius = preferred_radius;
    
    k2=key_ROI(i_roi);
    insert(self, k2);
end