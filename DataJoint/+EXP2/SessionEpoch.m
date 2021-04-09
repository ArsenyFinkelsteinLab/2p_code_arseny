%{
# Session epoch time
-> EXP2.Session
-> EXP2.SessionEpochType
session_epoch_number   : int      # session epoch number
---
session_epoch_start_time    : double   # (s) session epoch start time relative to the beginning of  the session
session_epoch_end_time      : double   # (s) session epoch start time relative to the beginning of  the session
flag_photostim_epoch        : double   # 1 if this epoch has photostimulation, 0 otherwise

%}


classdef SessionEpoch < dj.Imported
    properties
        keySource = EXP2.Session;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            local_path_orignal_session = fetchn(EXP2.SessionDirectory & key,'local_path_orignal_session');
            if isempty(local_path_orignal_session)
                dir_data = fetch1(IMG.Parameters & 'parameter_name="dir_raw_data_scan_image"','parameter_value');
                temp = dir(dir_data); %gets  the names of all files and nested directories in this folder
                subDirNames = {temp([temp.isdir]).name}; %gets only the names of all files
                subDirNames = subDirNames(3:end);
                
                subDirNames = subDirNames{contains(subDirNames,num2str(key.subject_id))};
                dir_data1 = [dir_data subDirNames '\'];
                
                
                
                currentSessionDate = fetch1(EXP2.Session & key,'session_date');
                currentSessionDate = char(datetime(currentSessionDate,'Format','yyyyMMdd','InputFormat','yyyy-MM-dd'));
                
                dir_data2 = [dir_data1  currentSessionDate];
            else
                dir_data2 = local_path_orignal_session{1};
            end
            temp = dir(dir_data2); %gets  the names of all files and nested directories in this folder
            subDirNames = {temp([temp.isdir]).name}; %gets only the names of all files
            subDirNames = subDirNames(3:end);
            
            k=key;
            
            
            session_epoch_types = fetchn(EXP2.SessionEpochType,'session_epoch_type');
            
            session_start_time = 0;
            session_start_frame = 0;
            session_frames_timestamps =[];
            for jDir = 1:1:numel (subDirNames)
                if sum(contains(session_epoch_types,subDirNames{jDir}(2:end)))>0
                    k.session_epoch_type = subDirNames{jDir}(2:end);
                else
                    continue
                end
                
                
                dir_data3 = [dir_data2 '\' subDirNames{jDir} '\'];
                
                k.session_epoch_number = jDir;
                k2=k;
                k3=k;
                
                allFiles = dir(dir_data3); %gets  the names of all files and nested directories in this folder
                allFileNames = {allFiles(~[allFiles.isdir]).name}; %gets only the names of all files
                allFileNames =allFileNames(contains(allFileNames,'.tif'))';
                
                
                %initialzing
                frames_file_timestamps=cell(numel(allFileNames),1);
                parfor ifile=1:1:numel(allFileNames)
                    [header]=scanimage.util.opentif([dir_data3,allFileNames{ifile}]);
                    frames_file_timestamps{ifile} = header.frameTimestamps_sec;
                end
                all_frames_timestamps=cell2mat(frames_file_timestamps');
                
                %checking for the number of planes
                [header]=scanimage.util.opentif([dir_data3,allFileNames{1}]);
                num_planes = header.SI.hFastZ.numFramesPerVolume; %number of planes
                if isempty(num_planes) %debug, not sure why this is happening
                    num_planes=1;
                end
                             
                % in case of multiplane imaging we take only the first frame of each volume as the timestamp. Not all frames within this volume will have the "same" timestamp
                frames_timestamps = all_frames_timestamps(1:num_planes:end);
                
%                 load([dir_data2 '_registered\suite2p\plane0\Fall.mat'],'ops'); % we take the first plane in suite2p to check how many 'volumetric frames' are there
%                 number_of_frames_in_suite2p = ops.frames_per_folder(jDir) -1;  % we discard the last 'volumetric frame' to ensture that all planes have the same number of frames
%                 frames_timestamps = frames_timestamps(1:1:number_of_frames_in_suite2p);
                
                session_frames_timestamps = [session_frames_timestamps, frames_timestamps+ session_start_time];
                
                
                %% POPULATE EXP2.SessionEpoch
                if contains(subDirNames{jDir},'photo')
                    k2.flag_photostim_epoch = 1;
                else
                    k2.flag_photostim_epoch = 0;
                end
                
                k2.session_epoch_start_time =  frames_timestamps(1) ;
                k2.session_epoch_end_time = frames_timestamps(end);
                
                insert(EXP2.SessionEpoch, k2 );
                session_start_time = k2.session_epoch_end_time + 100;
                
                %% Populate FrameTimeFiles
                key_file=k;
                key_file=repmat(key_file,1,numel(allFileNames));
                frame_counter=1;
                for ifile=1:1:numel(allFileNames)
                    key_file(ifile).session_epoch_file_num = ifile;
                    key_file(ifile).session_epoch_file_start_frame = frame_counter;
                    key_file(ifile).session_epoch_file_end_frame = frame_counter + numel(frames_file_timestamps{ifile})/num_planes -1;
                    frame_counter = frame_counter +  numel(frames_file_timestamps{ifile})/num_planes;
                end
                %                 frame_counter=frame_counter-1;
                
                insert(IMG.FrameStartFile, key_file);
                
                
                %% Reading trials and files start times from the mesoscope
                timeline_file = {allFiles(~[allFiles.isdir]).name}; %gets only the names of all files
                idx_timeline_file = contains(timeline_file,'Timeline');
                if sum(idx_timeline_file)>0
                timeline_file_name =timeline_file{idx_timeline_file};
                else 
                    timeline_file_name=[];
                end
                if ~isempty(timeline_file_name) && contains(k2.session_epoch_type,'behav')
                    Timeline = load ([dir_data3 timeline_file_name]);
                    Timeline=Timeline.Timeline.data;
                    timeline_sampling_rate = 5000;
                    [~,idx_frames_detected]=findpeaks(diff([0;Timeline(:,2)]),'MinPeakHeight',1); % getting the beginning of each frame aquisition
                    
                    if numel(idx_frames_detected)~= numel(all_frames_timestamps)
                        mismatch_in_frames =numel(idx_frames_detected)-numel(all_frames_timestamps);
                        tf=idx_frames_detected/timeline_sampling_rate;
                        if numel(tf)>all_frames_timestamps
                            tf=tf(1:1:numel(all_frames_timestamps));
                            max_offset_ms = max(abs(diff([tf-tf(1)]'-all_frames_timestamps)));
                        end
                        if  mismatch_in_frames<=3 && max_offset_ms<5/1000 %% DEBUG why 1 and not 2 extra frames. 1 extra frame detected happens if SI before the frame finished. In this case, the missed frame  starts but because it shorter than the other frames it is not saved by SI, but its on and off (rise/fall) will be detected
                            idx_frames_detected=idx_frames_detected(1:1:numel(all_frames_timestamps));
                        else
                            error('Mismatch in number of frames detected on the mesoscope');
                        end
                    end
                    %
                    
                    [~,temp_idx_trials]=findpeaks(diff([0;Timeline(:,3)]),'MinPeakHeight',3); % getting the beginning of each trial aquisition (the time of the bitcode onset)
                    
                    idx_trials = temp_idx_trials([inf;diff(temp_idx_trials)]>timeline_sampling_rate*2);
                    
                    bitcodestart_t =fetchn(EXP2.BehaviorTrialEvent & 'trial_event_type="bitcodestart"' & k2,'trial_event_time', 'ORDER BY trial');
                    
                    if numel(idx_trials)~= numel(bitcodestart_t)
                        error('Mismatch in number of trial detected on the mesoscope');
                        %                             idx_trials = idx_trials(1:numel(bitcodestart_t)); % in case of mismatch
                    end
                    %                     hold on;
                    %                     %                                 plot(Timeline(:,3))
                    %                     plot(diff([0;Timeline(:,3)]))
                    %                     plot(idx_trials,5,'*')
                    closest_frame=[];
                    for i_tr = 1:1:numel(idx_trials)
                        idx_begin_trial = idx_trials(i_tr) - bitcodestart_t(i_tr)*timeline_sampling_rate;
                        [~,closest_frame(i_tr)] = min(abs(idx_frames_detected-idx_begin_trial));
                    end
                    closest_frame = floor(closest_frame/num_planes);
                    key_frametrial=k;
                    key_frametrial=repmat(key_frametrial,1,numel(idx_trials));
                    for i_tr = 1:1:numel(idx_trials)
                        key_frametrial(i_tr).trial =i_tr;
                        key_frametrial(i_tr).session_epoch_trial_bitcode = NaN;
                        key_frametrial(i_tr).session_epoch_trial_start_frame = closest_frame(i_tr);
                        if i_tr<numel(idx_trials)
                            key_frametrial(i_tr).session_epoch_trial_end_frame = closest_frame(i_tr+1)-2;
                        else
                            key_frametrial(i_tr).session_epoch_trial_end_frame = floor(numel(idx_frames_detected)/num_planes)-1;
                        end
                    end
                    insert(IMG.FrameStartTrial, key_frametrial);
                    
                end
                
                %% POPULATE EXP2.SessionEpochFrame
                k3.session_epoch_start_frame = 1 + session_start_frame;
                k3.session_epoch_end_frame = numel(frames_timestamps) + session_start_frame;
%                 if jDir ==numel (subDirNames)
%                     k3.session_epoch_end_frame= k3.session_epoch_end_frame -5; % in case of accumulating frame mismatch due to volumetric imaging
%                 end
                insert(IMG.SessionEpochFrame, k3 );
                session_start_frame = k3.session_epoch_end_frame;
                
                %% POPULATE EXP2.SessionEpochDirectory
                k4=k;
                k4.local_path_session = [dir_data2 '\'];
                k4.local_path_session_registered = [dir_data2 '_registered\'];
                k4.local_path_session_epoch = dir_data3;
                k4.local_path_session_epoch_registered = [dir_data2 '_registered\' subDirNames{jDir} '\'];
                insert(EXP2.SessionEpochDirectory, k4);
                
            end
            
            %% POPULATE EXP2.FrameTime
            k5=key;
            k5.frame_timestamps = session_frames_timestamps;
            insert(IMG.FrameTime, k5);
            
            
        end
    end
end