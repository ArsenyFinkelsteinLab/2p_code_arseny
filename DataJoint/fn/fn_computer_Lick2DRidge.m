function fn_computer_Lick2DRidge(key,self, rel_data,threshold_for_event)
smooth_window=3;

key_ROI1=fetch(IMG.ROI&key,'ORDER BY roi_number'); %


% go_time=fetchn(EXP2.BehaviorTrialEvent & key & 'trial_event_type="go"','trial_event_time','LIMIT 1');
frame_rate = fetchn(IMG.FOVEpoch & key,'imaging_frame_rate');


S=fetch(rel_data & key,'*');
if isfield(S,'spikes_trace') % to be able to run the code both on dff and on deconvulted "spikes" data
    [S.dff_trace] = S.spikes_trace;
    S = rmfield(S,'spikes_trace');
end


[predictor_vector,idx_frames] = fn_compute_ridge_predictors (key, frame_rate);

threshold_for_event_temp=threshold_for_event;
threshold_for_event_temp(threshold_for_event==0)=-inf;

ridge_k_vector = 0:1:10;

for i_thr=1:1:numel(threshold_for_event)
    
    for i_roi=1:1:size(S,1)
        
        key_ROI1(i_roi).session_epoch_type = key.session_epoch_type;
        key_ROI1(i_roi).session_epoch_number = key.session_epoch_number;
        
        %% correlation with lick-rate
        trace=S(i_roi).dff_trace;
        trace(trace<threshold_for_event_temp(i_thr)) =0;
        trace = smooth(trace,smooth_window);
     r = ridge(trace(idx_frames),predictor_vector,ridge_k_vector);

        key_ROI1(i_roi).corr_with_licks = r(2);
        key_ROI1(i_roi).threshold_for_event = threshold_for_event(i_thr);
    end
    insert(self, key_ROI1);
end
end