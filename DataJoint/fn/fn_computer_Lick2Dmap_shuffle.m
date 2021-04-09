function fn_computer_Lick2Dmap_shuffle(key,self)
num_shuffle=5;

timespent_min=10; %in trials
time_bin=[-3,3]; %2 sec for PSTH, aligned to lick
fr_interval=[key.fr_interval_start,key.fr_interval_end]/1000;

smooth_window=1; %frames for PSTH
sigma=1;
hsize=1;

key_ROI=fetch((IMG.ROI-IMG.ROIBad)&key,'ORDER BY roi_number');


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

x_idx = x_idx(~isnan(start_file));
z_idx = z_idx(~isnan(start_file));



for i_roi=1:1:size(S,1)
    
    spikes=S(i_roi).spikes_trace;
    for i_tr = 1:1:numel(pos_x)
        if isnan(start_file(i_tr))
            fr_all(i_roi,i_tr)=NaN;
            continue
        end
        s=spikes(start_file(i_tr):end_file(i_tr));
        s=movmean(s,[smooth_window 0],'omitnan','Endpoints','shrink');
        time=(1:1:numel(s))/frame_rate + time_bin(1);
        s_interval=s(time>fr_interval(1) & time<=fr_interval(2));
        fr_all(i_roi,i_tr)= sum(s_interval)/numel(s_interval); %taking mean fr
        %         fr_all(i_roi,i_tr)= max(s_interval); %taking the max
    end
    
    
    
    
    fr_all = fr_all(:,~isnan(start_file));
    for i_shuffle = 1:1:num_shuffle
        x_idx_shuffled = x_idx(randperm(numel(x_idx)));
        z_idx_shuffled = z_idx(randperm(numel(z_idx)));
        [r_odd_even_shuffled(i_shuffle), information_per_spike_shuffled(i_shuffle)] = fn_computer_Lick2Dmap_shuffle2(fr_all,x_bins_centers,z_bins_centers,x_bins,z_bins, x_idx_shuffled, z_idx_shuffled, i_roi, sigma, hsize, timespent_min);
    end
    
    [r_odd_even, information_per_spike] = fn_computer_Lick2Dmap_shuffle2(fr_all,x_bins_centers,z_bins_centers,x_bins,z_bins, x_idx, z_idx, i_roi, sigma, hsize, timespent_min);
    
    
    key_ROI(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI(i_roi).number_of_bins = key.number_of_bins;
    key_ROI(i_roi).fr_interval_start =key.fr_interval_start;
    key_ROI(i_roi).fr_interval_end =key.fr_interval_end;
    
    key_ROI(i_roi).pval_lickmap_odd_even_corr = sum(r_odd_even<=r_odd_even_shuffled)./num_shuffle;
    key_ROI(i_roi).pval_information_per_spike =sum(information_per_spike<=information_per_spike_shuffled)./num_shuffle;
    
    
    k2=key_ROI(i_roi);
    insert(self, k2);
end