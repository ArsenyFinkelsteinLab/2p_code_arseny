function fn_computer_Lick2Dangle_3bins(key,self, rel_data, fr_interval)

rel_ROI = (IMG.ROI - IMG.ROIBad) & key;
key_ROI1=fetch(rel_ROI,'ORDER BY roi_number');
key_ROI2=fetch(rel_ROI,'ORDER BY roi_number'); %LICK2D.ROILick2DangleStatsSpikes3bins;
key_ROI3=fetch(rel_ROI,'ORDER BY roi_number'); %LICK2D.ROILick2DangleBlockSpikes3bins;
key_ROI4=fetch(rel_ROI,'ORDER BY roi_number'); %LICK2D.ROILick2DangleBlockStatsSpikes3bins; 

rel_data =rel_data & rel_ROI & key;

session_date = fetch1(EXP2.Session & key,'session_date');

smooth_window=1; %frames
timespent_min=3; %in trials per bin
smoothing_window_1D=1; % for angular tuning
min_percent_coverage=60; % minimal coverage needed for tuning curve calculation
number_of_bins=3; %what we are going to subsample the data to, in case its more than 3X3

[x_idx, z_idx] = fn_parse_2Dlicking_into_2Dbins(key,number_of_bins);
x_bins_centers=[-1,0,1];
z_bins_centers=[-1,0,1];
pos_x = x_bins_centers(x_idx);
pos_z = z_bins_centers(z_idx);
[theta, ~] = cart2pol(pos_x,pos_z);
theta=rad2deg(theta);

theta_bins = [-135, -90, -45, 0, 45, 90, 135, 180, inf];
theta_bins_centers=theta_bins(1:end-1);
theta_bins(end)=theta_bins(end) -1;

idx_center= (pos_x==0 & pos_z==0);
theta(idx_center)=NaN;
[~,~,theta_idx] = histcounts(theta,theta_bins);
theta_idx(idx_center)=NaN;


frame_rate = fetchn(IMG.FOVEpoch & key,'imaging_frame_rate');

[TRIAL_IDX, num_trials, start_file, end_file] = fn_parse_2Dlicking_into_trial_types(key,fr_interval);



S=fetch(rel_data,'*');
if isfield(S,'spikes_trace') % to be able to run the code both on dff and on deconvulted "spikes" data
    [S.dff_trace] = S.spikes_trace;
    S = rmfield(S,'spikes_trace');
    self2=LICK2D.ROILick2DangleStatsSpikes3bins;
    self3=LICK2D.ROILick2DangleBlockSpikes3bins; 
    self4=LICK2D.ROILick2DangleBlockStatsSpikes3bins;
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
    
    
    [THETA_TUNING_regular] = fn_compute_angular_tuning_mean_stem_stats (fr_all, i_roi, num_trials,  TRIAL_IDX.idx_regular, timespent_min, theta_bins_centers, theta_idx, smoothing_window_1D, min_percent_coverage);
    [THETA_TUNING_small] = fn_compute_angular_tuning_mean_stem_stats (fr_all, i_roi, num_trials,  TRIAL_IDX.idx_small, timespent_min, theta_bins_centers, theta_idx, smoothing_window_1D, min_percent_coverage);
    [THETA_TUNING_large] = fn_compute_angular_tuning_mean_stem_stats (fr_all, i_roi, num_trials,  TRIAL_IDX.idx_large, timespent_min, theta_bins_centers, theta_idx, smoothing_window_1D, min_percent_coverage);
    [THETA_TUNING_first] = fn_compute_angular_tuning_mean_stem_stats (fr_all, i_roi, num_trials,  TRIAL_IDX.idx_first, timespent_min, theta_bins_centers, theta_idx, smoothing_window_1D, min_percent_coverage);
    [THETA_TUNING_begin] = fn_compute_angular_tuning_mean_stem_stats (fr_all, i_roi, num_trials,  TRIAL_IDX.idx_begin, timespent_min, theta_bins_centers, theta_idx, smoothing_window_1D, min_percent_coverage);
    [THETA_TUNING_mid] = fn_compute_angular_tuning_mean_stem_stats (fr_all, i_roi, num_trials,  TRIAL_IDX.idx_mid, timespent_min, theta_bins_centers, theta_idx, smoothing_window_1D, min_percent_coverage);
    [THETA_TUNING_end] = fn_compute_angular_tuning_mean_stem_stats (fr_all, i_roi, num_trials,  TRIAL_IDX.idx_end, timespent_min, theta_bins_centers, theta_idx, smoothing_window_1D, min_percent_coverage);
    
    % LICK2D.ROILick2DangleSpikes3bins
    key_ROI1(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI1(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI1(i_roi).theta_bins_centers = theta_bins_centers;
    key_ROI1(i_roi).theta_tuning_regular = THETA_TUNING_regular.theta_tuning;
    key_ROI1(i_roi).theta_tuning_regular_odd = THETA_TUNING_regular.theta_tuning_odd;
    key_ROI1(i_roi).theta_tuning_regular_even = THETA_TUNING_regular.theta_tuning_even;
    key_ROI1(i_roi).theta_tuning_regular_vmises = THETA_TUNING_regular.theta_tuning_vmises(1:45:360);
    key_ROI1(i_roi).theta_tuning_regular_stem = THETA_TUNING_regular.theta_tuning_stem;
    
    try
        key_ROI1(i_roi).theta_tuning_small = THETA_TUNING_small.theta_tuning;
        key_ROI1(i_roi).theta_tuning_small_odd = THETA_TUNING_small.theta_tuning_odd;
        key_ROI1(i_roi).theta_tuning_small_even = THETA_TUNING_small.theta_tuning_even;
        key_ROI1(i_roi).theta_tuning_small_vmises = THETA_TUNING_small.theta_tuning_vmises(1:45:360);
        key_ROI1(i_roi).theta_tuning_small_stem = THETA_TUNING_small.theta_tuning_stem;
        
        key_ROI1(i_roi).theta_tuning_large = THETA_TUNING_large.theta_tuning;
        key_ROI1(i_roi).theta_tuning_large_odd = THETA_TUNING_large.theta_tuning_odd;
        key_ROI1(i_roi).theta_tuning_large_even = THETA_TUNING_large.theta_tuning_even;
        key_ROI1(i_roi).theta_tuning_large_vmises = THETA_TUNING_large.theta_tuning_vmises(1:45:360);
        key_ROI1(i_roi).theta_tuning_large_stem = THETA_TUNING_large.theta_tuning_stem;
        
    catch
    end
    
    
    % LICK2D.ROILick2DangleStatsSpikes3bins
    
    key_ROI2(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI2(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI2(i_roi).preferred_theta_regular = THETA_TUNING_regular.preferred_direction;
    key_ROI2(i_roi).preferred_theta_regular_odd = THETA_TUNING_regular.preferred_direction_odd;
    key_ROI2(i_roi).preferred_theta_regular_even = THETA_TUNING_regular.preferred_direction_even;
    key_ROI2(i_roi).rayleigh_length_regular = THETA_TUNING_regular.rayleigh_length;
    key_ROI2(i_roi).preferred_theta_vmises_regular = THETA_TUNING_regular.preferred_direction_vmises;
    key_ROI2(i_roi).preferred_theta_vmises_regular_odd = THETA_TUNING_regular.preferred_direction_vmises_odd;
    key_ROI2(i_roi).preferred_theta_vmises_regular_even = THETA_TUNING_regular.preferred_direction_vmises_even;
    key_ROI2(i_roi).goodness_of_fit_vmises_regular = THETA_TUNING_regular.goodness_of_fit_vmises;
    key_ROI2(i_roi).theta_tuning_odd_even_corr_regular = THETA_TUNING_regular.theta_tuning_odd_even_corr;
    
    key_ROI2(i_roi).percent_theta_coverage_regular = THETA_TUNING_regular.percent_theta_coverage;
    key_ROI2(i_roi).percent_theta_coverage_regular_odd   = THETA_TUNING_regular.percent_theta_coverage_odd;
    key_ROI2(i_roi).percent_theta_coverage_regular_even  = THETA_TUNING_regular.percent_theta_coverage_even;
    
    try
        key_ROI2(i_roi).preferred_theta_small = THETA_TUNING_small.preferred_direction;
        key_ROI2(i_roi).preferred_theta_small_odd = THETA_TUNING_small.preferred_direction_odd;
        key_ROI2(i_roi).preferred_theta_small_even = THETA_TUNING_small.preferred_direction_even;
        key_ROI2(i_roi).rayleigh_length_small = THETA_TUNING_small.rayleigh_length;
        key_ROI2(i_roi).preferred_theta_vmises_small = THETA_TUNING_small.preferred_direction_vmises;
        key_ROI2(i_roi).preferred_theta_vmises_small_odd = THETA_TUNING_small.preferred_direction_vmises_odd;
        key_ROI2(i_roi).preferred_theta_vmises_small_even = THETA_TUNING_small.preferred_direction_vmises_even;
        key_ROI2(i_roi).goodness_of_fit_vmises_small = THETA_TUNING_small.goodness_of_fit_vmises;
        key_ROI2(i_roi).theta_tuning_odd_even_corr_small = THETA_TUNING_small.theta_tuning_odd_even_corr;
        
        key_ROI2(i_roi).percent_theta_coverage_small = THETA_TUNING_small.percent_theta_coverage;
        key_ROI2(i_roi).percent_theta_coverage_small_odd   = THETA_TUNING_small.percent_theta_coverage_odd;
        key_ROI2(i_roi).percent_theta_coverage_small_even  = THETA_TUNING_small.percent_theta_coverage_even;
        
        key_ROI2(i_roi).preferred_theta_large = THETA_TUNING_large.preferred_direction;
        key_ROI2(i_roi).preferred_theta_large_odd = THETA_TUNING_large.preferred_direction_odd;
        key_ROI2(i_roi).preferred_theta_large_even = THETA_TUNING_large.preferred_direction_even;
        key_ROI2(i_roi).rayleigh_length_large = THETA_TUNING_large.rayleigh_length;
        key_ROI2(i_roi).preferred_theta_vmises_large = THETA_TUNING_large.preferred_direction_vmises;
        key_ROI2(i_roi).preferred_theta_vmises_large_odd = THETA_TUNING_large.preferred_direction_vmises_odd;
        key_ROI2(i_roi).preferred_theta_vmises_large_even = THETA_TUNING_large.preferred_direction_vmises_even;
        key_ROI2(i_roi).goodness_of_fit_vmises_large = THETA_TUNING_large.goodness_of_fit_vmises;
        key_ROI2(i_roi).theta_tuning_odd_even_corr_large = THETA_TUNING_large.theta_tuning_odd_even_corr;
        
        key_ROI2(i_roi).percent_theta_coverage_large = THETA_TUNING_large.percent_theta_coverage;
        key_ROI2(i_roi).percent_theta_coverage_large_odd   = THETA_TUNING_large.percent_theta_coverage_odd;
        key_ROI2(i_roi).percent_theta_coverage_large_even  = THETA_TUNING_large.percent_theta_coverage_even;
        
    catch
    end
    
    
    % LICK2D.ROILick2DangleBlockSpikes3bins
    key_ROI3(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI3(i_roi).session_epoch_number = key.session_epoch_number;
    try
        key_ROI3(i_roi).theta_tuning_first = THETA_TUNING_first.theta_tuning;
        key_ROI3(i_roi).theta_tuning_first_odd = THETA_TUNING_first.theta_tuning_odd;
        key_ROI3(i_roi).theta_tuning_first_even = THETA_TUNING_first.theta_tuning_even;
        key_ROI3(i_roi).theta_tuning_first_vmises = THETA_TUNING_first.theta_tuning_vmises(1:45:360);
        key_ROI3(i_roi).theta_tuning_first_stem = THETA_TUNING_first.theta_tuning_stem;
        
        key_ROI3(i_roi).theta_tuning_begin = THETA_TUNING_begin.theta_tuning;
        key_ROI3(i_roi).theta_tuning_begin_odd = THETA_TUNING_begin.theta_tuning_odd;
        key_ROI3(i_roi).theta_tuning_begin_even = THETA_TUNING_begin.theta_tuning_even;
        key_ROI3(i_roi).theta_tuning_begin_vmises = THETA_TUNING_begin.theta_tuning_vmises(1:45:360);
        key_ROI3(i_roi).theta_tuning_begin_stem = THETA_TUNING_begin.theta_tuning_stem;
        
        key_ROI3(i_roi).theta_tuning_mid = THETA_TUNING_mid.theta_tuning;
        key_ROI3(i_roi).theta_tuning_mid_odd = THETA_TUNING_mid.theta_tuning_odd;
        key_ROI3(i_roi).theta_tuning_mid_even = THETA_TUNING_mid.theta_tuning_even;
        key_ROI3(i_roi).theta_tuning_mid_vmises = THETA_TUNING_mid.theta_tuning_vmises(1:45:360);
        key_ROI3(i_roi).theta_tuning_mid_stem = THETA_TUNING_mid.theta_tuning_stem;
        
        key_ROI3(i_roi).theta_tuning_end = THETA_TUNING_end.theta_tuning;
        key_ROI3(i_roi).theta_tuning_end_odd = THETA_TUNING_end.theta_tuning_odd;
        key_ROI3(i_roi).theta_tuning_end_even = THETA_TUNING_end.theta_tuning_even;
        key_ROI3(i_roi).theta_tuning_end_vmises = THETA_TUNING_end.theta_tuning_vmises(1:45:360);
        key_ROI3(i_roi).theta_tuning_end_stem = THETA_TUNING_end.theta_tuning_stem;
    catch
    end
    
    
    try
        key_ROI4(i_roi).session_epoch_type = key.session_epoch_type;
        key_ROI4(i_roi).session_epoch_number = key.session_epoch_number;
        
        key_ROI4(i_roi).preferred_theta_first = THETA_TUNING_first.preferred_direction;
        key_ROI4(i_roi).preferred_theta_first_odd = THETA_TUNING_first.preferred_direction_odd;
        key_ROI4(i_roi).preferred_theta_first_even = THETA_TUNING_first.preferred_direction_even;
        key_ROI4(i_roi).rayleigh_length_first = THETA_TUNING_first.rayleigh_length;
        key_ROI4(i_roi).preferred_theta_vmises_first = THETA_TUNING_first.preferred_direction_vmises;
        key_ROI4(i_roi).preferred_theta_vmises_first_odd = THETA_TUNING_first.preferred_direction_vmises_odd;
        key_ROI4(i_roi).preferred_theta_vmises_first_even = THETA_TUNING_first.preferred_direction_vmises_even;
        key_ROI4(i_roi).goodness_of_fit_vmises_first = THETA_TUNING_first.goodness_of_fit_vmises;
        key_ROI4(i_roi).theta_tuning_odd_even_corr_first = THETA_TUNING_first.theta_tuning_odd_even_corr;
        key_ROI4(i_roi).percent_theta_coverage_first = THETA_TUNING_first.percent_theta_coverage;
        key_ROI4(i_roi).percent_theta_coverage_first_odd   = THETA_TUNING_first.percent_theta_coverage_odd;
        key_ROI4(i_roi).percent_theta_coverage_first_even  = THETA_TUNING_first.percent_theta_coverage_even;
        
        key_ROI4(i_roi).preferred_theta_begin = THETA_TUNING_begin.preferred_direction;
        key_ROI4(i_roi).preferred_theta_begin_odd = THETA_TUNING_begin.preferred_direction_odd;
        key_ROI4(i_roi).preferred_theta_begin_even = THETA_TUNING_begin.preferred_direction_even;
        key_ROI4(i_roi).rayleigh_length_begin = THETA_TUNING_begin.rayleigh_length;
        key_ROI4(i_roi).preferred_theta_vmises_begin = THETA_TUNING_begin.preferred_direction_vmises;
        key_ROI4(i_roi).preferred_theta_vmises_begin_odd = THETA_TUNING_begin.preferred_direction_vmises_odd;
        key_ROI4(i_roi).preferred_theta_vmises_begin_even = THETA_TUNING_begin.preferred_direction_vmises_even;
        key_ROI4(i_roi).goodness_of_fit_vmises_begin = THETA_TUNING_begin.goodness_of_fit_vmises;
        key_ROI4(i_roi).theta_tuning_odd_even_corr_begin = THETA_TUNING_begin.theta_tuning_odd_even_corr;
        key_ROI4(i_roi).percent_theta_coverage_begin = THETA_TUNING_begin.percent_theta_coverage;
        key_ROI4(i_roi).percent_theta_coverage_begin_odd   = THETA_TUNING_begin.percent_theta_coverage_odd;
        key_ROI4(i_roi).percent_theta_coverage_begin_even  = THETA_TUNING_begin.percent_theta_coverage_even;
        
        key_ROI4(i_roi).preferred_theta_mid = THETA_TUNING_mid.preferred_direction;
        key_ROI4(i_roi).preferred_theta_mid_odd = THETA_TUNING_mid.preferred_direction_odd;
        key_ROI4(i_roi).preferred_theta_mid_even = THETA_TUNING_mid.preferred_direction_even;
        key_ROI4(i_roi).rayleigh_length_mid = THETA_TUNING_mid.rayleigh_length;
        key_ROI4(i_roi).preferred_theta_vmises_mid = THETA_TUNING_mid.preferred_direction_vmises;
        key_ROI4(i_roi).preferred_theta_vmises_mid_odd = THETA_TUNING_mid.preferred_direction_vmises_odd;
        key_ROI4(i_roi).preferred_theta_vmises_mid_even = THETA_TUNING_mid.preferred_direction_vmises_even;
        key_ROI4(i_roi).goodness_of_fit_vmises_mid = THETA_TUNING_mid.goodness_of_fit_vmises;
        key_ROI4(i_roi).theta_tuning_odd_even_corr_mid = THETA_TUNING_mid.theta_tuning_odd_even_corr;
        key_ROI4(i_roi).percent_theta_coverage_mid = THETA_TUNING_mid.percent_theta_coverage;
        key_ROI4(i_roi).percent_theta_coverage_mid_odd   = THETA_TUNING_mid.percent_theta_coverage_odd;
        key_ROI4(i_roi).percent_theta_coverage_mid_even  = THETA_TUNING_mid.percent_theta_coverage_even;
        
        key_ROI4(i_roi).preferred_theta_end = THETA_TUNING_end.preferred_direction;
        key_ROI4(i_roi).preferred_theta_end_odd = THETA_TUNING_end.preferred_direction_odd;
        key_ROI4(i_roi).preferred_theta_end_even = THETA_TUNING_end.preferred_direction_even;
        key_ROI4(i_roi).rayleigh_length_end = THETA_TUNING_end.rayleigh_length;
        key_ROI4(i_roi).preferred_theta_vmises_end = THETA_TUNING_end.preferred_direction_vmises;
        key_ROI4(i_roi).preferred_theta_vmises_end_odd = THETA_TUNING_end.preferred_direction_vmises_odd;
        key_ROI4(i_roi).preferred_theta_vmises_end_even = THETA_TUNING_end.preferred_direction_vmises_even;
        key_ROI4(i_roi).goodness_of_fit_vmises_end = THETA_TUNING_end.goodness_of_fit_vmises;
        key_ROI4(i_roi).theta_tuning_odd_even_corr_end = THETA_TUNING_end.theta_tuning_odd_even_corr;
        key_ROI4(i_roi).percent_theta_coverage_even = THETA_TUNING_end.percent_theta_coverage;
        key_ROI4(i_roi).percent_theta_coverage_even_odd   = THETA_TUNING_end.percent_theta_coverage_odd;
        key_ROI4(i_roi).percent_theta_coverage_even_even  = THETA_TUNING_end.percent_theta_coverage_even;
    catch
    end
    %     k2=key_ROI1(i_roi);
end

insert(self, key_ROI1);
insert(self2, key_ROI2);
insert(self3, key_ROI3);
insert(self4, key_ROI4);

end