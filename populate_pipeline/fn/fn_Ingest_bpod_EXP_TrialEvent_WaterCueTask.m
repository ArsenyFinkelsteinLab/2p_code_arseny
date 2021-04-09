function [data_TrialEvent, early_lick, trial_note_type, go_t] = fn_Ingest_bpod_EXP_TrialEvent_WaterCueTask (obj, key, iTrials, obj_trial, data_TrialEvent, action_event_time, currentFileName)

            
trigger_imaging_t = obj.RawEvents.Trial{obj_trial}.States.TrigTrialStart(1);
sample_start = obj.RawEvents.Trial{obj_trial}.States.Sample1(1);
sample_end = obj.RawEvents.Trial{obj_trial}.States.Delay1(2);
delay_start = obj.RawEvents.Trial{obj_trial}.States.Delay2(1);
go_t = obj.RawEvents.Trial{obj_trial}.States.ResponseCue(1);   

sample_dur = sample_end - sample_start;
delay_dur = go_t - delay_start;

trial_event_type ={'trigger imaging'; 'sample'; 'delay'; 'go'};
trial_event_time = [trigger_imaging_t; sample_start; delay_start;  go_t];
duration =         [0;         sample_dur;       delay_dur;   0];

 
for iTrialEvent=1:1:numel(trial_event_time)
    data_TrialEvent (end+1) = struct(...
        'subject_id',  key.subject_id, 'session', key.session, 'trial', iTrials, 'trial_event_type',trial_event_type(iTrialEvent), 'trial_event_time',trial_event_time(iTrialEvent), 'duration',duration(iTrialEvent) );
end


% Detecting early lick
%---------------------------------------------------------------------------
% early lick
if sum(action_event_time <= go_t) >0
    early_lick ='early'; 
else
    early_lick ='no early';
end

trial_note_type=[];

