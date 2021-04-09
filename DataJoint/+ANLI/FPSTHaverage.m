%{
#
-> IMG.ROI
-> EXP2.TrialNameType
-> EXP2.Outcome
---
num_trials_averaged             : int         # number of trials averaged per condition, for this ROI
psth_avg                        : longblob    # trial-type averaged PSTH aligned to go cue time, expressed as deltaF/F, where F is the baseline flourescene in the beginning of each trial
psth_stem                       : longblob    # standard error of the mean of the above, expressed as deltaF/F
psth_timestamps                 : longblob    # timestamps of each frame relative to go cue
time_sample_start               : double      # time of sample start relative to go cue
time_sample_end                 : double      # time of sample end relative to go cue
%}


classdef FPSTHaverage < dj.Computed
    properties
        keySource = (IMG.FOV  & IMG.ROI) * (EXP2.TrialNameType)  * EXP2.Outcome;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            roi_list=fetchn(IMG.ROI & key,'roi_number');
            
            b=fetch((EXP2.BehaviorTrial*EXP2.TrialName) & key,'*','ORDER BY trial');
            if isempty(b)
                return;
            end
            b=struct2table(b); b_trials=[b.trial];
            b_trials=b_trials(contains(b.early_lick,'no early'));
            if isempty(b_trials)
                return;
            end
            
            
            % for all conditions and trial-types
            kk=key;
            kk=rmfield(kk,'trial_type_name');
            kk=rmfield(kk,'outcome');
            
            bEvent_all=fetch(  EXP2.BehaviorTrialEvent*EXP2.BehaviorTrial & kk & 'early_lick="no early"','*','ORDER BY trial');
            
            trial_event_time_all = [bEvent_all.trial_event_time];
            typical_time_go = mode(trial_event_time_all (contains({bEvent_all.trial_event_type},'go')));
            typical_time_sample_start =mode(trial_event_time_all (contains({bEvent_all.trial_event_type},'sound sample start')))-typical_time_go;
            typical_time_sample_end = mode(trial_event_time_all (contains({bEvent_all.trial_event_type},'sound sample end')))-typical_time_go;
            
            
            % for this conditions and trial-type combination
            bEvent=fetch(  EXP2.BehaviorTrialEvent&((EXP2.BehaviorTrial*EXP2.TrialName)& key),'*','ORDER BY trial');
            trial_event_time = [bEvent.trial_event_time];
            time_go = trial_event_time (contains({bEvent.trial_event_type},'go'));
            time_sample_start =trial_event_time (contains({bEvent.trial_event_type},'sound sample start'));
            time_sample_end = trial_event_time (contains({bEvent.trial_event_type},'sound sample end'));
            
            
            key.roi_number=1;
            frames_per_trial=fetchn(IMG.ROITrial & key,'frames_per_trial','ORDER BY trial');
            typical_num_frames_per_trial=mode(frames_per_trial);
            f_trace_timestamps=fetchn(IMG.ROITrial & key,'f_trace_timestamps','ORDER BY trial');
            [~,longest_trial_idx] = max(frames_per_trial);
            typical_psth_timestamps = f_trace_timestamps{longest_trial_idx}(1:typical_num_frames_per_trial);
            
            frames_per_trial = frames_per_trial(b_trials);
            f_trace_timestamps = f_trace_timestamps(b_trials);
            
            numberTrials = numel(frames_per_trial);
            
            for iROI = 1:numel(roi_list)
                F=zeros(numberTrials,max(frames_per_trial)) + NaN;
                
                key.roi_number=roi_list(iROI);
                baseline_fl_trials=cell2mat(fetchn(IMG.ROI & key,'baseline_fl_trials'));
                %                 smooth_b=smooth(baseline_fl_trials,10,'sgolay',1);
                smooth_b=smooth(baseline_fl_trials,10,'rlowess',1);
                
                smooth_b=smooth_b(b_trials)';
                
                ROITrial=fetchn(IMG.ROITrial & key,'f_trace','ORDER BY trial');
                ROITrial = ROITrial (b_trials);
                
                key_FPSTHtrial = key;
                key_FPSTHtrial = repmat(key_FPSTHtrial,1,numberTrials);
                
                for iTr=1:1:numberTrials
                    f_trial=(ROITrial{iTr} - smooth_b(iTr))/smooth_b(iTr); %deltaF/F
                    F(iTr,1:frames_per_trial(iTr))=f_trial;
                    
                    key_FPSTHtrial(iTr).trial=b_trials(iTr);
                    key_FPSTHtrial(iTr).psth_trial = f_trial;
                    this_trial_time_go = time_go (iTr);
                    key_FPSTHtrial(iTr).psth_timestamps = f_trace_timestamps{iTr} - this_trial_time_go;
                    key_FPSTHtrial(iTr).time_sample_start   = time_sample_start(iTr) - this_trial_time_go;
                    key_FPSTHtrial(iTr).time_sample_end = time_sample_end(iTr)- this_trial_time_go;
                    
                end
                
                
                F=F(:,1:typical_num_frames_per_trial);
                psth_avg = nanmean(F,1);
                psth_stem = nanstd(F,1)/sqrt(numberTrials);
                
                key_FPSTHaverage=key;
                key_FPSTHaverage.num_trials_averaged=numberTrials;
                key_FPSTHaverage.psth_avg=psth_avg;
                key_FPSTHaverage.psth_stem=psth_stem;
                key_FPSTHaverage.psth_timestamps= typical_psth_timestamps -typical_time_go;
                key_FPSTHaverage.time_sample_start = typical_time_sample_start;
                key_FPSTHaverage.time_sample_end = typical_time_sample_end;
                
                insert(ANLI.FPSTHaverage, key_FPSTHaverage)
                insert(ANLI.FPSTHtrial, key_FPSTHtrial)
                
                
            end
        end
    end
end