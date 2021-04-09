%{
#
-> EXP2.Session
---
psth_roi_tr_fr            : longblob        # psth matrix (ROIs x Trials  X Frames)
typical_psth_timestamps   : longblob        # timestamps of each frame relative to go cue, typical refers to the case in which trial times would differ across sessions (e.g. when delay duration is different for different trials). In this this timestamps are only representative for the session, but may differ for indvidual trials.
typical_time_sample_start : double          # time of sample start relative to go cue
typical_time_sample_end   : double          # time of sample end relative to go cue
%}


classdef FPSTHMatrix < dj.Computed
        properties
        keySource = EXP2.Session  & IMG.ROI;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            roi_list=fetchn(IMG.ROI & key,'roi_number','ORDER BY roi_number');
            
            
            bEvent_all=fetch(  EXP2.BehaviorTrialEvent*EXP2.BehaviorTrial & key & 'early_lick="no early"','*','ORDER BY trial');
            
            trial_event_time_all = [bEvent_all.trial_event_time];
            typical_time_go = mode(trial_event_time_all (contains({bEvent_all.trial_event_type},'go')));
            typical_time_sample_start =mode(trial_event_time_all (contains({bEvent_all.trial_event_type},'sound sample start')))-typical_time_go;
            typical_time_sample_end = mode(trial_event_time_all (contains({bEvent_all.trial_event_type},'sound sample end')))-typical_time_go;

%          
            k=key;
            k.roi_number=1;
            frames_per_trial=fetchn(IMG.ROITrial & k,'frames_per_trial','ORDER BY trial');
            typical_num_frames_per_trial=mode(frames_per_trial);
            f_trace_timestamps=fetchn(IMG.ROITrial & k,'f_trace_timestamps','ORDER BY trial');
            [~,longest_trial_idx] = max(frames_per_trial);
            typical_psth_timestamps = f_trace_timestamps{longest_trial_idx}(1:typical_num_frames_per_trial);
            
%             frames_per_trial = frames_per_trial(b_trials);
%             f_trace_timestamps = f_trace_timestamps(b_trials);
            
            numberTrials = numel(frames_per_trial);

            FPSTH_roi_tr_fr = zeros(numel(roi_list),numberTrials,max(frames_per_trial)) + NaN;
            for iROI = 1:numel(roi_list)

                k.roi_number=roi_list(iROI);
                baseline_fl_trials=cell2mat(fetchn(IMG.ROI & k,'baseline_fl_trials'));
                smooth_b=smooth(baseline_fl_trials,10,'rlowess',1);
                
                ROITrial=fetchn(IMG.ROITrial & k,'f_trace','ORDER BY trial');
                
                for iTr=1:1:numberTrials
                    f_trial=(ROITrial{iTr} - smooth_b(iTr))/smooth_b(iTr); %deltaF/F
                    FPSTH_roi_tr_fr(iROI , iTr, 1:frames_per_trial(iTr))=f_trial;
                end

            end
            
            key.psth_roi_tr_fr = FPSTH_roi_tr_fr;
            key.typical_psth_timestamps =  typical_psth_timestamps -typical_time_go;
            key.typical_time_sample_start = typical_time_sample_start;
            key.typical_time_sample_end = typical_time_sample_end;
            insert(ANLI.FPSTHMatrix, key);

        end
    end
end