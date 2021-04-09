function [data_BehaviorTrial, data_TrialLickPort, data_TrialRewardSize, data_TrialLickBlock] = fn_Ingest_bpod_EXP_BehaviorTrial_Lick2DTask (obj, key, iTrials,obj_trial, data_BehaviorTrial, early_lick, go_t, action_event_time, outcome_types, data_TrialLickPort, data_TrialRewardSize, data_TrialLickBlock)

task =  'lick2D';
task_protocol = obj.task;

trial_instruction = 'go';
lickport_pos_number = obj.TrialTypes(obj_trial);
lickport_pos_x=obj.X_positions_mat{obj_trial}(lickport_pos_number); %This is setup specific. On Kayvon's rig  x positve  means Right side (from mouse perspective) 
lickport_pos_y=NaN;
lickport_pos_z=obj.Z_positions_mat{obj_trial}(lickport_pos_number);
lickport_pos_x_bins=obj.X_positions_mat{obj_trial}(1,:);
lickport_pos_y_bins=NaN;
lickport_pos_z_bins=obj.Z_positions_mat{obj_trial}(:,1);

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
data_TrialLickPort (iTrials) = struct(...
    'subject_id',key.subject_id, 'session',key.session, 'trial',iTrials, 'lickport_pos_number',lickport_pos_number,...
    'lickport_pos_x',lickport_pos_x,'lickport_pos_y',lickport_pos_y,'lickport_pos_z',lickport_pos_z,...
    'lickport_pos_x_bins',lickport_pos_x_bins,'lickport_pos_y_bins',lickport_pos_y_bins,'lickport_pos_z_bins',lickport_pos_z_bins);

reward_flag = obj.TrialRewardFlag(obj_trial);

if reward_flag==0
    reward_size_type = 'omission';
elseif reward_flag == 1
    reward_size_type = 'regular';
elseif reward_flag ==2
    reward_size_type = 'large';
end

reward_size_valve_time=  obj.TrialRewardSize(obj_trial);
data_TrialRewardSize (iTrials) = struct(...
    'subject_id',key.subject_id, 'session',key.session, 'trial',iTrials, 'reward_size_valve_time',reward_size_valve_time, 'reward_size_type',reward_size_type);





num_trials_in_block = obj.TrialSettings(obj_trial).GUI.MaxSame;


first_trial_in_block = find([1,(diff(obj.TrialTypes)~=0)]);
counter =1;
for it=1:1:numel(obj.TrialTypes)
    if sum(first_trial_in_block==it)>0
        trial_num_in_block(it) = 1;
        counter=1;
    else
        trial_num_in_block(it) = counter;
    end
    counter = counter+ 1;
end

num_licks_for_reward = obj.TrialSettings(obj_trial).GUI.NumLicksForReward;
roll_deg = obj.TrialSettings(obj_trial).GUI.RollDeg;
flag_auto_water_settings = obj.TrialSettings(obj_trial).GUI.Autowater;
if flag_auto_water_settings~=1
    flag_auto_water_settings=0;
end

flag_auto_water_first_trial_in_block_settings = obj.TrialSettings(obj_trial).GUI.AutowaterFirstTrialInBlock;
if flag_auto_water_first_trial_in_block_settings~=1
    flag_auto_water_first_trial_in_block_settings=0;
end

if isfield(obj.RawEvents.Trial{obj_trial}.States,'GiveDrop')
    flag_auto_water_curret_trial = 1;
else
    flag_auto_water_curret_trial=0;
end

data_TrialLickBlock (iTrials) = struct(...
    'subject_id',key.subject_id, 'session',key.session, 'trial',iTrials, 'num_trials_in_block',num_trials_in_block, 'current_trial_num_in_block',trial_num_in_block(obj_trial),  'num_licks_for_reward',num_licks_for_reward, 'roll_deg',roll_deg, 'flag_auto_water_curret_trial',flag_auto_water_curret_trial,'flag_auto_water_settings',flag_auto_water_settings,'flag_auto_water_first_trial_in_block_settings',flag_auto_water_first_trial_in_block_settings);

