function fn_computer_Lick2Dangle_shuffle(key,self)

num_shuffle=1000;
time_bin=[-3,3]; %2 sec
fr_interval=[key.fr_interval_start,key.fr_interval_end]/1000;
smooth_window=1; %frames
timespent_min=10; %in trials
smoothing_window_1D=3;


key_ROI=fetch((IMG.ROI-IMG.ROIBad)&key,'ORDER BY roi_number');


[POS] = fn_rescale_and_rotate_lickport_pos (key);
pos_x = POS.pos_x;
pos_z = POS.pos_z;

[theta, radius] = cart2pol(pos_x,pos_z);
theta=rad2deg(theta);

%plot(pos_x,pos_z,'.')

go_time=fetchn(EXP2.BehaviorTrialEvent & key & 'trial_event_type="go"','trial_event_time','LIMIT 1');
frame_rate = fetchn(IMG.FOVEpoch & key,'imaging_frame_rate');

Files=fetch(IMG.FrameStartFile & key,'*');
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


theta_idx = theta_idx(~isnan(start_file)& radius>0.1);


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
    end
    
    
    fr_all = fr_all(:,~isnan(start_file)& radius>0.1 );
    %     theta_idx_double=[theta_idx,theta_idx];
    for i_shuffle = 1:1:num_shuffle
        %         shuffle_step=10 + i_shuffle;
        theta_idx_shuffled = theta_idx(randperm(numel(theta_idx)));
        %         theta_idx_shuffled=theta_idx_double(shuffle_step:shuffle_step+numel(theta_idx)-1);
        [RV_shuffle(i_shuffle), r_shuffle(i_shuffle)]= fn_computer_Lick2Dangle_shuffle2(fr_all,theta_idx_shuffled, theta_bins_centers, i_roi, timespent_min, smoothing_window_1D);
    end
    
    [RV, r_odd_even]= fn_computer_Lick2Dangle_shuffle2 (fr_all,theta_idx, theta_bins_centers, i_roi, timespent_min, smoothing_window_1D);
    
    
    key_ROI(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI(i_roi).fr_interval_start =key.fr_interval_start;
    key_ROI(i_roi).fr_interval_end =key.fr_interval_end;
    
    key_ROI(i_roi).pval_rayleigh_length = sum(RV<=RV_shuffle)./num_shuffle;
    key_ROI(i_roi).pval_theta_tuning_odd_even_corr = sum(r_odd_even<=r_shuffle)./num_shuffle;
    
    k2=key_ROI(i_roi);
    insert(self, k2);
    
end
end