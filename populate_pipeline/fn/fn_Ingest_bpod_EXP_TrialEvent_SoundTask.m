function [data_TrialEvent, early_lick, trial_note_type, go_t] = fn_Ingest_bpod_EXP_TrialEvent_SoundTask (obj, key, iTrials, obj_trial, data_TrialEvent, action_event_time, currentFileName)

            
trigger_imaging_t = obj.RawEvents.Trial{obj_trial}.States.TrigTrialStart(1);
delay_t = obj.RawEvents.Trial{obj_trial}.States.DelayPeriod(1);
go_t = obj.RawEvents.Trial{obj_trial}.States.ResponseCue(1)+ 0.150;   % we add the presumable travel time of the zabor motors
sound_sample_start = obj.RawEvents.Trial{obj_trial}.States.SampleOn1(1);
sound_sample_end = obj.RawEvents.Trial{obj_trial}.States.SampleOn5(2);

delay_dur = go_t - delay_t;

trial_event_type ={'trigger imaging'; 'sound sample start'; 'sound sample end'; 'delay'; 'go'};
trial_event_time = [trigger_imaging_t; sound_sample_start; sound_sample_end; delay_t; go_t];
duration =         [0;      0;         0;       0;   0];

 
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

