function fn_computer_Lick2Dangle_3bins(key,self, rel_data, fr_interval, dir_current_fig)

rel_ROI = (IMG.ROI - IMG.ROIBad) & key;
key_ROI1=fetch(rel_ROI,'ORDER BY roi_number');
key_ROI2=fetch(rel_ROI,'ORDER BY roi_number');

rel_data =rel_data & rel_ROI & key;

session_date = fetch1(EXP2.Session & key,'session_date');

smooth_window=1; %frames
timespent_min=3; %in trials per bin
smoothing_window_1D=1; % for angular tuning

number_of_bins=3;


[x_idx, z_idx] = fn_parse_2Dlicking_into_2Dbins(key,number_of_bins);
x_bins_centers=[-1,0,1];
z_bins_centers=[-1,0,1];
pos_x = x_bins_centers(x_idx);
pos_z = z_bins_centers(z_idx);
[theta, radius] = cart2pol(pos_x,pos_z);
theta=rad2deg(theta);

theta_bins = [-135, -90, -45, 0, 45, 90, 135, 180, inf];
theta_bins_centers=theta_bins(1:end-1);
theta_bins(end)=theta_bins(end) -1;

idx_center= (pos_x==0 & pos_z==0);
theta(idx_center)=NaN;
[~,~,theta_idx] = histcounts(theta,theta_bins);
theta_idx(idx_center)=NaN;


frame_rate = fetchn(IMG.FOVEpoch & key,'imaging_frame_rate');

[TRIAL_IDX, num_trials, start_file, end_file] = ...
    fn_parse_2Dlicking_into_trial_types(key,fr_interval);



S=fetch(rel_data,'*');
if isfield(S,'spikes_trace') % to be able to run the code both on dff and on deconvulted "spikes" data
    [S.dff_trace] = S.spikes_trace;
    S = rmfield(S,'spikes_trace');
    self2=LICK2D.ROILick2DangleStatsSpikes3bins;
else
    %     self2=LICK2D.ROILick2DmapPSTH;
    %     self3=LICK2D.ROILick2DmapStats;
    %     self4=LICK2D.ROILick2DSelectivity;
    %     self5=LICK2D.ROILick2DSelectivityStats;
end

for i_roi=1:1:size(S,1)
    
    f=S(i_roi).dff_trace;
    
    for i_tr = 1:1:numel(pos_x)
        
        if isnan(start_file(i_tr))
            fr_all(i_roi,i_tr)=NaN;
            continue
        end
        s=f(start_file(i_tr):end_file(i_tr));
        s=movmean(s,[smooth_window 0],'omitnan','Endpoints','shrink');
        time=(1:1:numel(s))/frame_rate + fr_interval(1);
        s_interval=s(time>fr_interval(1) & time<=fr_interval(2));
        fr_all(i_roi,i_tr)= sum(s_interval)/numel(s_interval); %taking mean fr
        %         fr_all(i_roi,i_tr)= max(s_interval); %taking the max
    end
    
    
    [THETA_TUNING] = fn_compute_angular_tuning_mean_and_stem (fr_all, i_roi, num_trials,  TRIAL_IDX.idx_regular, timespent_min, theta_bins_centers, theta_idx, smoothing_window_1D);
    
    THETA_TUNING.theta_tuning_mean=theta_tuning_mean;
    THETA_TUNING.theta_tuning_stem=theta_tuning_stem;
    
    THETA_TUNING.theta_tuning_mean_odd=theta_tuning_odd;
    THETA_TUNING.theta_tuning_mean_even=theta_tuning_even;
    
    THETA_TUNING.theta_tuning_stem_odd=theta_tuning_stem_odd;
    THETA_TUNING.theta_tuning_stem_even=theta_tuning_stem_even;
    
    THETA_TUNING.preferred_direction=preferred_theta;
    THETA_TUNING.preferred_direction_vmises=preferred_direction_vmises;
    THETA_TUNING.goodness_of_fit_vmises=goodness_of_fit_vmises;
    THETA_TUNING.theta_tuning_odd_even_corr=r_odd_even;
    THETA_TUNING.rayleigh_length = rayleigh_length;
    
    clear THETA_TUNING
    
    
    key_ROI1(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI1(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI1(i_roi).theta_curve = theta_firing_rate_smoothed;
    key_ROI1(i_roi).theta_curve_odd = theta_firing_rate_smoothed_odd;
    key_ROI1(i_roi).theta_curve_even = theta_firing_rate_smoothed_even;
    
    key_ROI1(i_roi).theta_bins_centers = theta_bins_centers;
    key_ROI1(i_roi).preferred_theta = preferred_theta;
    key_ROI1(i_roi).rayleigh_length = Rayleigh_length;
    key_ROI1(i_roi).theta_odd_even_corr = r_odd_even;
    
    key_ROI1(i_roi).theta_curve_vmises =theta_firing_rate_vmises;
    key_ROI1(i_roi).preferred_theta_vmises =preferred_direction_vmises;
    key_ROI1(i_roi).goodness_of_fit_vmises =r2_vmises;
    
    k2=key_ROI1(i_roi);
    insert(self, k2);
    
end



if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
filename=[num2str(key.subject_id) '_s' num2str( key.session) '_'  num2str(session_date) '_angles' ];
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r100']);
close all

end