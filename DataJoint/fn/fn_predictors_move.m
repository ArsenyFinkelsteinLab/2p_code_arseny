% function [video_resampled_interp]= fn_predictors_move(key, sampling_rate_2p, predictor_name, tracking_start_time)
function [video_resampled_interp]= fn_predictors_move(key, time_bin, predictor_name, tracking_start_time)

% min_video_samples_without_NaN_in_bin=25;
min_video_samples_without_NaN_in_bin=5;

key.bodypart_name=predictor_name;

rel_video=TRACKING.VideoBodypartTrajectTrial & key;

is_mesoscope=IMG.Mesoscope & key;
if count(is_mesoscope)==0
    is_mesoscope=false;
else
    is_mesoscope=true;
end

switch predictor_name
    
    case 'PawFrontLeft' %front view
        video= fetch1(rel_video ,'traj_x');%
        if is_mesoscope
            k.tracking_device_id=4;
        else
            k.tracking_device_id=1;
        end
    case 'PawFrontRight' %front view
        video= fetch1(rel_video,'traj_x');%
        if is_mesoscope
            k.tracking_device_id=4;
        else
            k.tracking_device_id=1;
        end
    case 'Whiskers' %side view
        video= fetch1(rel_video,'traj_y1');%
        if is_mesoscope
            k.tracking_device_id=3;
        else
            k.tracking_device_id=0;
        end
    case 'Nose' %side view
        video= fetch1(rel_video,'traj_z');%
        if is_mesoscope
            k.tracking_device_id=3;
        else
            k.tracking_device_id=0;
        end
    case 'Jaw' %side view
        video= fetch1(rel_video,'traj_z');%
        if is_mesoscope
            k.tracking_device_id=3;
        else
            k.tracking_device_id=0;
        end
end
sampling_rate_video =fetchn(TRACKING.TrackingTrial & k & key,'tracking_sampling_rate');



% Resampling behavioral video according to 2p imaging frame rate
time = [0:1:numel(video)-1]/sampling_rate_video + tracking_start_time;


%debug
if is_mesoscope==0
    time_resampled = 0:time_bin:time(end);
else
    time_resampled = 0:1/sampling_rate_2p:time(end); %% for the mesoscope we binned the video according to the mesoscope frame rate because it was very slow anyway
end

for ii=1:1:numel(time_resampled)-1
    idx_b = time>=time_resampled(ii) & time <time_resampled(ii+1);
    if sum(~isnan(video(idx_b)))>=min_video_samples_without_NaN_in_bin
        video_resampled(ii) =  nanmean(video(idx_b)); %downsampling, to match the imaging frame rate. We do downsampling by taking the mean value of the datapoints within each time bin
    else
        video_resampled(ii) = NaN;
    end
end
time_resampled=time_resampled(1:end-1);

% %interpolation and extrapolation of missing (NaN) values using nearest neighbors
% if sum(~isnan(video_resampled))>=2 %we do interpolation/extrapolation only if there are enough data points
%     video_resampled_interp = interp1(time_resampled(~isnan(video_resampled)),video_resampled(~isnan(video_resampled)),time_resampled,'nearest','extrap'); %we interpolate missing values (that had NaNs in them)
% else
%     video_resampled_interp=video_resampled;
% end
 
video_resampled_interp=video_resampled;
 
%% For debug
% clf
% hold on
% plot(time, video,'-k')
% plot(time_resampled, video_resampled_interp,'-b')
% plot(time_resampled, video_resampled,'-r')


