function [data_TrialEvent, early_lick, trial_note_type, go_t] = fn_Ingest_bpod_EXP_TrialEvent_Lick2DTask (obj, key, iTrials, obj_trial, data_TrialEvent, action_event_time, currentFileName)

trigger_imaging_t = obj.RawEvents.Trial{obj_trial}.States.TrigTrialStart(1);
% go_t = obj.RawEvents.Trial{obj_trial}.States.AnswerPeriod(1)+ 0.150;   % we add the presumable travel time of the zabor motors
try
    go_t = obj.RawEvents.Trial{obj_trial}.States.AnswerPeriodFirstLick(1);
catch
    go_t = obj.RawEvents.Trial{obj_trial}.States.AnswerPeriodAutoWater(1);
end

bitcodestart_t=obj.RawEvents.Trial{obj_trial}.States.StartBitcodeTrialNumber(1);
trial_end_t = obj.RawEvents.Trial{obj_trial}.States.TrialEnd(1);
trial_event_type ={'trigger imaging'; 'go';'bitcodestart';'trialend'};
trial_event_time = [trigger_imaging_t; go_t; bitcodestart_t;trial_end_t];


if isfield(obj.RawEvents.Trial{obj_trial}.States,'LickIn1')
    if ~isnan((obj.RawEvents.Trial{obj_trial}.States.LickIn1(1)))
    LickIn1_t = obj.RawEvents.Trial{obj_trial}.States.LickIn1(1);
    trial_event_type {end+1} = 'firstlick';
    trial_event_time(end+1) = LickIn1_t;
end
end
if isfield(obj.RawEvents.Trial{obj_trial}.States,'RewardConsumption')
    if ~isnan((obj.RawEvents.Trial{obj_trial}.States.RewardConsumption(1)))
        reward = obj.RawEvents.Trial{obj_trial}.States.RewardConsumption(1);
        trial_event_type {end+1} = 'reward';
        trial_event_time(end+1) = reward;
    end
end



for iTrialEvent=1:1:numel(trial_event_time)
    data_TrialEvent (end+1) = struct(...
        'subject_id',  key.subject_id, 'session', key.session, 'trial', iTrials, 'trial_event_type',trial_event_type(iTrialEvent), 'trial_event_time',trial_event_time(iTrialEvent), 'duration',0 );
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


