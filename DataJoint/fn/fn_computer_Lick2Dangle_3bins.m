function fn_computer_Lick2Dangle_3bins(key,self, rel_data, fr_interval, flag_threshold_events, threshold_events_cutoff,dir_current_fig)
rel_ROI = (IMG.ROI - IMG.ROIBad) & key;
key_ROI=fetch(rel_ROI,'ORDER BY roi_number');

rel_data =rel_data & rel_ROI & key;

session_date = fetch1(EXP2.Session & key,'session_date');


smooth_window=1; %frames
timespent_min=15; %in trials
min_num_bins_for_smoothing=7;
smoothing_window_1D=3; % conditioned on number of bins. If number of bins is <min_num_bins_for_smoothing we set smoothing to 1
radius_threshold = 0.1;


if exist('flag_threshold_events')
    if flag_threshold_events==0
        threshold_events_cutoff=-inf;
    end
else
    threshold_events_cutoff=-inf;
end







[POS] = fn_rescale_and_rotate_lickport_pos (key);
pos_x = POS.pos_x;
pos_z = POS.pos_z;


[theta, radius] = cart2pol(pos_x,pos_z);
theta=rad2deg(theta);
% theta(radius==min(radius))=NaN;
%plot(pos_x,pos_z,'.')

% go_time=fetchn(EXP2.BehaviorTrialEvent & key & 'trial_event_type="go"','trial_event_time','LIMIT 1');
frame_rate = fetchn(IMG.FOVEpoch & key,'imaging_frame_rate');


% L=fetch(EXP2.ActionEvent & key,'*');

S=fetch(rel_data,'*');
if isfield(S,'spikes_trace') % to be able to run the code both on dff and on deconvulted "spikes" data
    [S.dff_trace] = S.spikes_trace;
    S = rmfield(S,'spikes_trace');
end
% figure
% [hhh_temp,bins_temp,theta_idx_temp] = histcounts(theta,1000);
% hhh_temp=[0,hhh_temp,0];
% bins_temp=[bins_temp,bins_temp(end)+mean(diff(bins_temp))];
% [~,idx_peaks]=findpeaks(hhh_temp,'MinPeakDistance',15,'MinPeakHeight',numel(hhh_temp)/50);
% hold on
%  plot(bins_temp,hhh_temp,'*');
%  plot(bins_temp(idx_peaks),100,'*r');

% theta_bins_centers = bins_temp(idx_peaks);
% theta_bins = [bins_temp(idx_peaks)-1,180];
% theta_bins=linspace(-180,180,9);
% theta_bins=linspace(-180,180,13);
%  theta_bins=-180:30:180;
% % theta_bins = theta_bins - mean(diff(theta_bins))/2;
% theta_bins_centers=theta_bins(1:end-1)+mean(diff(theta_bins))/2;

% theta_bins=linspace(-180,180,9) +45/2;
% theta_bins=[-inf, theta_bins];
% [temp,~,theta_idx] = histcounts(theta,theta_bins);
% theta_idx(theta_idx==max(theta_idx))=1;
% theta_bins_centers =linspace(-180,180,9);
% theta_bins_centers(end)=[];
%  theta_idx(theta_idx==0)=1;
% theta_bins_centers=theta_bins(1:end-1)+mean(diff(theta_bins))/2;

%
%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

%Step 1 We first take all theta values that were measured
theta = round(theta);
theta_bins = unique(theta);
[theta_binned,~,theta_idx] = histcounts(theta,theta_bins);
theta_bins_centers=round(theta_bins(1:end-1)+diff(theta_bins)/2);

% Plotting before binning
subplot(2,2,1)
hold on
plot(pos_x+rand(1,numel(pos_x))/10, pos_z+rand(1,numel(pos_x))/10,'.')
for i_x=1:1:numel(pos_x)
    text(pos_x(i_x),pos_z(i_x), sprintf('%.0f',theta(i_x)),'FontSize',9);
end
title(sprintf('anm%d %s session %d\nBefore angular binning',key.subject_id, session_date, key.session),'FontSize',10);


% Plotting before and after binning
subplot(2,2,2)
hold on
plot(theta_bins_centers,theta_binned,'.-b')
plot([theta_bins_centers(1) theta_bins_centers(end)],[timespent_min timespent_min],'-r');
set(gca,'FontSize',7)
ylabel('Counts');
xlabel('Angles (deg)');


% Step 2 We now take only bins that have enough data in them
idx_bad=[];
for i = 1:1:numel(theta_binned)
    if theta_binned(i)<=timespent_min
        theta_bad = mean(theta(theta_idx==i));
        idx_bad = [idx_bad i];
    end
end

theta_bins(idx_bad)=[];
theta_bins = [-180,theta_bins, 180];
theta_bins =unique(theta_bins);

theta_bins_centers=round(theta_bins(1:end-1)+diff(theta_bins)/2);
if sum(theta_bins_centers==180)
    theta_bins_centers(theta_bins_centers==180)=-180; % this is done to avoid some problems later
end
[theta_binned,~,theta_idx] = histcounts(theta,theta_bins);
plot(theta_bins_centers,theta_binned,'.-g')
ylim([0,max(theta_binned)])

% Plotting after binning
subplot(2,2,3)
hold on
plot(pos_x+rand(1,numel(pos_x))/10, pos_z+rand(1,numel(pos_x))/10,'.')
for i_x=1:1:numel(pos_x)
    text(pos_x(i_x),pos_z(i_x), sprintf('%.0f',theta_bins(theta_idx(i_x))),'FontSize',9);
end
title('After angular binning');

% Plotting radius
subplot(2,2,4)
hold on
plot(pos_x+rand(1,numel(pos_x))/10, pos_z+rand(1,numel(pos_x))/10,'.')
for i_x=1:1:numel(pos_x)
    text(pos_x(i_x),pos_z(i_x), sprintf('%.1f',radius(i_x)),'FontSize',9);
end
title('Radius');


[start_file, end_file ] = fn_parse_into_trials (key,frame_rate, fr_interval);



% we are going to smooth only if there are many bins
if numel(theta_bins_centers)<min_num_bins_for_smoothing
    smoothing_window_1D=1;
end


for i_roi=1:1:size(S,1)
    
    f=S(i_roi).dff_trace;
    f(f<threshold_events_cutoff)=0;
    
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
    
    
    for i_theta=1:1:numel(theta_bins_centers)
        idx= find( (theta_idx==i_theta)  & ~isnan(start_file) & radius>radius_threshold );
        theta_spikes_binned(i_theta) = sum(fr_all(i_roi,idx));
        theta_timespent_binned(i_theta)=numel(idx);
        
        idx_odd=idx(1:2:end);
        idx_even=idx(2:2:end);
        
        theta_spikes_binned_odd(i_theta) = sum(fr_all(i_roi,idx_odd));
        theta_timespent_binned_odd(i_theta)=numel(idx_odd);
        
        theta_spikes_binned_even(i_theta) = sum(fr_all(i_roi,idx_even));
        theta_timespent_binned_even(i_theta)=numel(idx_even);
    end
    
    
    % to avoid negative "firing rates"
    if min(theta_spikes_binned)<0
        theta_spikes_binned = theta_spikes_binned - min(theta_spikes_binned);
    end
    if min(theta_spikes_binned_odd)<0
        theta_spikes_binned_odd = theta_spikes_binned_odd - min(theta_spikes_binned_odd);
    end
    if min(theta_spikes_binned_even)<0
        theta_spikes_binned_even = theta_spikes_binned_even - min(theta_spikes_binned_even);
    end
    
    [~, theta_firing_rate_smoothed, preferred_theta,Rayleigh_length]  = fn_compute_generic_1D_tuning2 ...
        (theta_timespent_binned, theta_spikes_binned, theta_bins_centers, timespent_min,  smoothing_window_1D, 1, 1);
    
    [ ~, theta_firing_rate_smoothed_odd, ~ ,~]  = fn_compute_generic_1D_tuning2 ...
        (theta_timespent_binned_odd, theta_spikes_binned_odd, theta_bins_centers, timespent_min,  smoothing_window_1D, 1, 1);
    
    [ ~, theta_firing_rate_smoothed_even, ~ ,~]  = fn_compute_generic_1D_tuning2 ...
        (theta_timespent_binned_even, theta_spikes_binned_even, theta_bins_centers, timespent_min,  smoothing_window_1D, 1, 1);
    
    
    
    % Von mises fit - with baseline subtraction
    %     baseline_FR = nanmin(theta_firing_rate_smoothed);
    %     [~, preferred_direction_vmises, theta_firing_rate_vmises, r2_vmises] ...
    %         = fn_compute_von_mises (theta_firing_rate_smoothed - baseline_FR, theta_bins_centers+180);
    %     theta_firing_rate_vmises = theta_firing_rate_vmises+baseline_FR;
    
    % Von mises fit - without baseline subtraction
    [~, preferred_direction_vmises, theta_firing_rate_vmises, r2_vmises] ...
        = fn_compute_von_mises (theta_firing_rate_smoothed, theta_bins_centers+180);
    
    preferred_direction_vmises=preferred_direction_vmises-180;
    
    r_odd_even=corr([theta_firing_rate_smoothed_odd',theta_firing_rate_smoothed_even'],'Rows' ,'pairwise');
    r_odd_even=r_odd_even(2);
    
    key_ROI(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI(i_roi).session_epoch_number = key.session_epoch_number;
    
    
    key_ROI(i_roi).theta_tuning_curve = theta_firing_rate_smoothed;
    key_ROI(i_roi).theta_tuning_curve_odd = theta_firing_rate_smoothed_odd;
    key_ROI(i_roi).theta_tuning_curve_even = theta_firing_rate_smoothed_even;
    
    key_ROI(i_roi).theta_bins_centers = theta_bins_centers;
    key_ROI(i_roi).preferred_theta = preferred_theta;
    key_ROI(i_roi).rayleigh_length = Rayleigh_length;
    key_ROI(i_roi).theta_tuning_odd_even_corr = r_odd_even;
    
    key_ROI(i_roi).theta_tuning_curve_vmises =theta_firing_rate_vmises;
    key_ROI(i_roi).preferred_theta_vmises =preferred_direction_vmises;
    key_ROI(i_roi).goodness_of_fit_vmises =r2_vmises;
    
    k2=key_ROI(i_roi);
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