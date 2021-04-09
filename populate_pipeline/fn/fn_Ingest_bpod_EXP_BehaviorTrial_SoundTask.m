function [data_BehaviorTrial, data_TrialName] = fn_Ingest_bpod_EXP_BehaviorTrial_SoundTask (obj, key, iTrials,obj_trial, data_BehaviorTrial, early_lick, go_t, action_event_time, outcome_types, data_TrialName)

task =  'sound';
task_protocol = obj.task;


if sum(obj.TrialTypes(obj_trial) == 1)>0
    trial_instruction = 'left';
    trial_type_name='l';
else sum(obj.TrialTypes(obj_trial) == 0)>0;
    trial_instruction = 'right';
    trial_type_name='r';
end


for iOutcome = 1:1:length(outcome_types) % loop through outcomes (e.g. Hit, Ignore, Miss)
    if sum(action_event_time>go_t)>0
        if ~isnan(obj.RawEvents.Trial{obj_trial}.States.Reward(1))
            outcome = 'hit';
        else
            outcome = 'miss';
        end
    else
        outcome = 'ignore';
    end
end

data_BehaviorTrial (iTrials) = struct(...
    'subject_id',key.subject_id, 'session',key.session, 'trial',iTrials, 'task',task, 'task_protocol',task_protocol, 'trial_instruction',trial_instruction, 'early_lick',early_lick, 'outcome',outcome);
data_TrialName (iTrials) = struct(...
    'subject_id',key.subject_id, 'session',key.session, 'trial',iTrials, 'task',task, 'trial_type_name',trial_type_name);


