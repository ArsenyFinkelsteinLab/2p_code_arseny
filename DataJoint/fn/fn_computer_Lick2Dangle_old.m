function fn_computer_Lick2Dangle_old(key,self)

time_bin=[-5,5]; %2 sec
fr_interval=[key.fr_interval_start,key.fr_interval_end]/1000;
smooth_window=3; %frames
timespent_min=5; %in trials
smoothing_window_1D=1;


key_ROI=fetch(IMG.ROI&key,'ORDER BY roi_number');



[POS] = fn_rescale_and_rotate_lickport_pos (key);
pos_x = POS.pos_x;
pos_z = POS.pos_z;


[theta, radius] = cart2pol(pos_x,pos_z);
theta=rad2deg(theta);

%plot(pos_x,pos_z,'.')

go_time=fetchn(EXP2.BehaviorTrialEvent & key & 'trial_event_type="go"','trial_event_time','LIMIT 1');
frame_rate = fetchn(IMG.FOVEpoch & key,'imaging_frame_rate');

TrialsStartFrame=fetchn(IMG.FrameStartTrial & key,'session_epoch_trial_start_frame','ORDER BY trial');
if isempty(TrialsStartFrame) % not mesoscope recordings
    TrialsStartFrame=fetchn(IMG.FrameStartFile & key,'session_epoch_file_start_frame', 'ORDER BY session_epoch_file_num');
end


L=fetch(EXP2.ActionEvent & key,'*');

S=fetch(IMG.ROISpikes & key,'*');

% figure
[hhh_temp,bins_temp,theta_idx_temp] = histcounts(theta,1000);
hhh_temp=[0,hhh_temp,0];
bins_temp=[bins_temp,bins_temp(end)+mean(diff(bins_temp))];
[~,idx_peaks]=findpeaks(hhh_temp,'MinPeakDistance',15,'MinPeakHeight',numel(hhh_temp)/50);
% hold on
%  plot(bins_temp,hhh_temp,'*');
%  plot(bins_temp(idx_peaks),100,'*r');

theta_bins_centers = bins_temp(idx_peaks);
theta_bins = [bins_temp(idx_peaks)-1,180];
% theta_bins=linspace(-180,180,9);
% theta_bins=linspace(-180,180,13);
%  theta_bins=-180:30:180;
% % theta_bins = theta_bins - mean(diff(theta_bins))/2;
% theta_bins_centers=theta_bins(1:end-1)+mean(diff(theta_bins))/2;

 
[temp,~,theta_idx] = histcounts(theta,theta_bins);

%  theta_idx(theta_idx==0)=1;

for i_tr = 1:1:numel(pos_x)
    licks=[L(find([L.trial]==i_tr)).action_event_time];
    licks=licks(licks>go_time);
    if ~isempty(licks)
        start_file(i_tr)=TrialsStartFrame(i_tr) + floor(licks(1)*frame_rate) + floor(time_bin(1)*frame_rate);
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
    
    
    for i_theta=1:1:numel(theta_bins_centers)
        idx= find( (theta_idx==i_theta)  & ~isnan(start_file) & radius>0.1 );
        theta_spikes_binned(i_theta) = sum(fr_all(i_roi,idx));
        theta_timespent_binned(i_theta)=numel(idx);
        
        idx_odd=idx(1:2:end);
        idx_even=idx(2:2:end);
        
        theta_spikes_binned_odd(i_theta) = sum(fr_all(i_roi,idx_odd));
        theta_timespent_binned_odd(i_theta)=numel(idx_odd);
        
        theta_spikes_binned_even(i_theta) = sum(fr_all(i_roi,idx_even));
        theta_timespent_binned_even(i_theta)=numel(idx_even);
    end
    
    [~, theta_firing_rate_smoothed(i_roi,:), preferred_theta(i_roi),Rayleigh_length(i_roi)]  = fn_compute_generic_1D_tuning2 ...
        (theta_timespent_binned, theta_spikes_binned, theta_bins_centers, timespent_min,  smoothing_window_1D, 1, 1);
    
    [ ~, theta_firing_rate_smoothed_odd(i_roi,:), ~ ,~]  = fn_compute_generic_1D_tuning2 ...
        (theta_timespent_binned_odd, theta_spikes_binned_odd, theta_bins_centers, timespent_min,  smoothing_window_1D, 1, 1);
    
    [ ~, theta_firing_rate_smoothed_even(i_roi,:), ~ ,~]  = fn_compute_generic_1D_tuning2 ...
        (theta_timespent_binned_even, theta_spikes_binned_even, theta_bins_centers, timespent_min,  smoothing_window_1D, 1, 1);
    
    r_odd_even=corr([theta_firing_rate_smoothed_odd(i_roi,:)',theta_firing_rate_smoothed_even(i_roi,:)'],'Rows' ,'pairwise');
    r_odd_even=r_odd_even(2);
    
    key_ROI(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI(i_roi).fr_interval_start =key.fr_interval_start;
    key_ROI(i_roi).fr_interval_end =key.fr_interval_end;
    
    key_ROI(i_roi).theta_tuning_curve = theta_firing_rate_smoothed(i_roi,:);
    key_ROI(i_roi).theta_tuning_curve_odd = theta_firing_rate_smoothed_odd(i_roi,:);
    key_ROI(i_roi).theta_tuning_curve_even = theta_firing_rate_smoothed_even(i_roi,:);
    
    key_ROI(i_roi).theta_bins_centers = theta_bins_centers;
    key_ROI(i_roi).preferred_theta = preferred_theta(i_roi);
    key_ROI(i_roi).rayleigh_length = Rayleigh_length(i_roi);
    key_ROI(i_roi).theta_tuning_odd_even_corr = r_odd_even;
    
    k2=key_ROI(i_roi);
    insert(self, k2);
    
end
end