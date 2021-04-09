function fn_populate_ROI_across_days(k, dates, dir_data_combined)

%loading suite2p output for sessions registered together
dir_data=[dir_data_combined '\suite2p\plane0\'];
S2P=load([dir_data 'Fall.mat']);
numberROI = numel(S2P.stat);


% getting uid for multiple sessions
multiple_sessions_uid_list = fetchn(IMG.FOVmultiSessions,'multiple_sessions_uid');
if isempty(multiple_sessions_uid_list)
    multiple_sessions_uid=1;
else
    multiple_sessions_uid = max(multiple_sessions_uid_list) +1;
end

% getting uid for ROIs recorded for multiple sessions
roi_number_uid_list = fetchn(IMG.ROI,'roi_number_uid');
if isempty(roi_number_uid_list)
    roi_number_uid_list = 1:numberROI;
else
    max_uid= max(roi_number_uid_list);
    roi_number_uid_list = (max_uid + 1) : (max_uid + numberROI);
end

%intializing
% first_frame_in_session (1) = 1;
total_frame_in_session (1) = 0;

for i_s = 1:1:numel(dates)
    dates{i_s}
    k.session_date=dates{i_s};
    
    key=fetch(EXP.Session & k);
    
    FOV=fetch(IMG.FOV & key,'*');
    first_frame_in_session (i_s) = sum(total_frame_in_session)+1;
    total_frame_in_session (i_s) = numel(FOV.frames_timestamps);
    
    key.fov_number=FOV.fov_number;
    
    key_coregistered=key;
    key_coregistered.multiple_sessions_uid=multiple_sessions_uid;
    
    
    numberTrials = numel(FOV.frames_start_trial);
    for iROI=1:1:numberROI
        key.roi_number = iROI;
        
        key_ROI=key;
        key_ROI.roi_number_uid = roi_number_uid_list(iROI);
        key_ROI.roi_centroid_x = S2P.stat{iROI}.med (2); %note the unintuitive order in suite2p outpyt
        key_ROI.roi_centroid_y = S2P.stat{iROI}.med(1);  %note the unintuitive order in suite2p output
        key_ROI.roi_x_pix = S2P.stat{iROI}.xpix;
        key_ROI.roi_y_pix = S2P.stat{iROI}.ypix;
        key_ROI.roi_pixel_weight = S2P.stat{iROI}.lam; %pixel mask (fluorescence = sum(pixel_weight * frames[ypix,xpix,:]))
        key_ROI.roi_radius = S2P.stat{iROI}.radius;
        
        key_ROI.neuropil_pixels = S2P.stat{iROI}.ipix_neuropil;
        
        key_ROITrial = key;
        key_ROITrial = repmat(key_ROITrial,1,numberTrials);
        
        for iTrial=1:1:numberTrials
            start_trial=FOV.frames_start_trial(iTrial);
            end_trial=FOV.frames_start_trial(iTrial)+FOV.number_of_frames_in_trial(iTrial)-1;
            start_trial_S2P = start_trial + first_frame_in_session(i_s)-1;
            end_trial_S2P = end_trial + first_frame_in_session(i_s)-1;
            
            f_trace = S2P.F(iROI,start_trial_S2P:end_trial_S2P);
            
            key_ROITrial(iTrial).trial = iTrial;
            key_ROITrial(iTrial).f_trace = f_trace;
            key_ROITrial(iTrial).f_trace_timestamps = FOV.frames_timestamps(start_trial:end_trial) - FOV.frames_timestamps(start_trial) ;
            key_ROITrial(iTrial).frames_per_trial = numel(start_trial:end_trial);
            baseline_fl_trials (iTrial)= mean(f_trace(1:ceil(FOV.imaging_frame_rate))); %taking the first second as baseline
        end
        key_ROI.baseline_fl_trials=baseline_fl_trials;
        key_ROI.baseline_fl_median=median(baseline_fl_trials);
        key_ROI.baseline_fl_stem=std(baseline_fl_trials)/sqrt(numberTrials);
        
        insert(IMG.ROI,key_ROI);
        insert(IMG.ROITrial,key_ROITrial);
        
    end
    insert(IMG.FOVmultiSessions,key_coregistered);
    
end

end