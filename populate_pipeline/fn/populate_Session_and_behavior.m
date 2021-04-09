function populate_Session_and_behavior (dir_behavioral_data, user_name, rig)
close all;
% DJconnect; %connect to the database using stored user credentials


%% Insert/Populate Sessions and dependent tables
allFiles = dir(dir_behavioral_data); %gets  the names of all files and nested directories in this folder
allFileNames = {allFiles(~[allFiles.isdir]).name}; %gets only the names of all files


% % for DEBUG
% del_key=fetch(EXP2.SessionID,'ORDER BY session_uid');
% if ~isempty(del_key)
%     del_key=del_key(end);
%     del(EXP2.Session & del_key)
% end


for iFile = 1:1:numel (allFileNames)
    tic
    % Get the current session name/date
    currentFileName = allFileNames{iFile};
    currentSubject_id = str2num(currentFileName(6:11));
    currentSessionDate_bpod_format = currentFileName(16:23);
    currentSessionDate = char(datetime(currentSessionDate_bpod_format,'Format','yyyy-MM-dd','InputFormat','yyyyMMdd'));
    
    % Get the  name/date of sessions that are already in the DJ database
    exisitingSubject_id = fetchn(EXP2.Session,'subject_id');
    exisitingSession = fetchn(EXP2.Session,'session');
    exisitingSessionDate = fetchn(EXP2.Session,'session_date');
    
    key.subject_id = currentSubject_id;  key.session_date = currentSessionDate;
    
    key_test.subject_id = currentSubject_id;  key_test.session_date = currentSessionDate;
    % Insert a session (and all the dependent tables) only if the animalXsession combination doesn't exist
    if isempty( fetch(EXP2.Session & key_test))
        
        
        if  sum(currentSubject_id == exisitingSubject_id)>0 % test if to restart the session numbering
            temp_key.subject_id = key.subject_id;
            s_n = fetchn(EXP2.Session & temp_key,'session');
            currentSession = s_n(end) + 1;
        else
            currentSession =1;
        end
        
        key.session = currentSession;
        
        
        %% Insert Session
        insert(EXP2.Session, {currentSubject_id, currentSession, currentSessionDate, user_name ,rig} );
        populate(EXP2.SessionID);
        
        key_task.subject_id = key.subject_id;
        key_task.session = key.session;
        key_task.task = 'sound';
        key_task.task_protocol = 1;
        insert(EXP2.SessionTask, key_task);
        
        key_training.subject_id = key.subject_id;
        key_training.session = key.session;
        key_training.training_type = 'regular sound';
        insert(EXP2.SessionTraining, key_training);
        
        %initializing
        [data_SessionTrial] = fn_EmptyStruct ('EXP2.SessionTrial');
        [data_ActionEvent] = fn_EmptyStruct ('EXP2.ActionEvent');
        [data_TrialEvent] = fn_EmptyStruct ('EXP2.BehaviorTrialEvent');
        [data_BehaviorTrial] = fn_EmptyStruct ('EXP2.BehaviorTrial');
        [data_TrialName] = fn_EmptyStruct ('EXP2.TrialName');

        outcome_types = fetchn(EXP2.Outcome,'outcome');
        
        total_trials_in_database = numel(fetchn(EXP2.SessionTrial,'trial_uid'));
        
        
        total_trials_today=0;
        todayFileName=allFileNames(contains(allFileNames,currentSessionDate_bpod_format));
        for i_bpod_files= 1:1:numel(todayFileName) %in c ase the behavioral session is broken into multiple files in bpod
            currentFileName=todayFileName{i_bpod_files};
            %load session
            temp = load([dir_behavioral_data currentFileName]);
            obj=temp.SessionData;
            if i_bpod_files==1 % this is done to append the time of multiple bpod sessions
                session_time_offset=0;
            else
                session_time_offset=data_SessionTrial(iTrials).start_time;
            end
            
            obj.task = key_task.task_protocol';
            
            %% Insert Trial-based data
            for iTrials = (total_trials_today+1):1: (obj.nTrials + total_trials_today)
                obj_trial=iTrials-total_trials_today;
                
                % EXP2.SessionTrial
                data_SessionTrial (iTrials) = struct(...
                    'subject_id',  key.subject_id, 'session', key.session, 'trial', iTrials, 'trial_uid', total_trials_in_database + iTrials, 'start_time', (obj.TrialStartTimestamp(obj_trial) - obj.TrialStartTimestamp(1)) +session_time_offset );
                
                % EXP2.ActionEvent
                [data_ActionEvent,  action_event_time]  = fn_Ingest_bpod_EXP_ActionEvent_WaterCueTask (obj, key, iTrials,obj_trial, data_ActionEvent);
                
                % EXP2.TrialEvent
                [data_TrialEvent, early_lick, trial_note_type, go_t] = fn_Ingest_bpod_EXP_TrialEvent_WaterCueTask (obj, key, iTrials,obj_trial, data_TrialEvent, action_event_time, currentFileName);
                
                % EXP2.BehaviorTrial
                [data_BehaviorTrial, data_TrialName] = fn_Ingest_bpod_EXP_BehaviorTrial_SoundTask (obj, key, iTrials,obj_trial, data_BehaviorTrial, early_lick, go_t, action_event_time,outcome_types, data_TrialName);
                
                
                
                
            end
            total_trials_today=iTrials;
        end
        
        insert(EXP2.SessionTrial, data_SessionTrial);
        insert(EXP2.BehaviorTrial, data_BehaviorTrial);
        insert(EXP2.TrialName, data_TrialName);
        insert(EXP2.ActionEvent, data_ActionEvent);
        insert(EXP2.BehaviorTrialEvent, data_TrialEvent);
        toc
    end
end
