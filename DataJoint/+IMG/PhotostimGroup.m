%{
# Photostim Group
-> EXP2.SessionEpoch
photostim_group_num   : int #
---
photostim_start_frame :longblob     # relative to the beginning of the session epoch, *not* to the entire session
photostim_end_frame   :longblob     # relative to the beginning of the session epoch, *not* to the entire session
%}


classdef PhotostimGroup < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            %% HERE WE ASSUME THAT A PHOTOSTIMULATION HAPPENS BETWEEN "FRAMES", either between single *frames* during single plane imaging, or between *planes* during volumetric imaging
            %              photostim_duration_in_frames = 1; % this is experiment dependent. Here the photostim lasts exactly for one frame
            
            % below will also find if the same stimulus was applied for several consequetive frames
            % same_photostim_duration_in_frames    - determines sequence periodicity, i.e. if the same stimulus was applied for several consequetive frames
            
            
            %             photostim_duration_in_frames = 0.25; % this is experiment dependent. Here the photostim happens 4 times per "volumetric" plane
            %             photostim_duration_in_frames = 0.5; % this is experiment dependent. Here the photostim happens 2 times per "volumetric" plane
            
            dir_data = fetchn(EXP2.SessionEpochDirectory & key,'local_path_session_epoch_registered');
            dir_data = dir_data{1};
            
            
            try
                photostim_session_epoch = (load([dir_data 'photostim_session_epoch.mat'])); photostim_session_epoch=photostim_session_epoch.photostim_session_epoch;
                stim_frame=photostim_session_epoch.stim_frame(110:1:end-110); % to be able to analyze single trial traces of suffiecient length, aligned to photostim onset
                stim_sequence=photostim_session_epoch.stim_sequence(110:1:end-110);
            catch
                
                dir_data = fetchn(EXP2.SessionEpochDirectory & key,'local_path_session_epoch');
                dir_data = dir_data{1};
                allFiles = dir(dir_data); %gets  the names of all files and nested directories in this folder
                allFileNames = {allFiles(~[allFiles.isdir]).name}; %gets only the names of all files
                sequence_filenames =allFileNames(contains(allFileNames,'Sequence'))';
                session_epoch_start_frame = fetch1(IMG.SessionEpochFrame & key,'session_epoch_start_frame');
                session_epoch_end_frame = fetch1(IMG.SessionEpochFrame & key,'session_epoch_end_frame');
                
                
                
                seq = (load([dir_data sequence_filenames{1}])); %DEBUG to include multiple sequence names
                seq=seq.sequence;
                
                %determining sequence periodicity, i.e. if the same stimulus was applied for several consequetive frames
                seq_diff = diff(seq);
                seq_diff(seq_diff~=0) = 1;
                same_photostim_duration_in_frames = round(numel(seq)/(sum(seq_diff)+1)); % frames here will refer to frames or planes for single/multi plane imaging respectively
                
                
                num_of_planes = numel(fetchn(IMG.Plane & key,'plane_num'));
                
                photostim_volume_ratio = same_photostim_duration_in_frames/num_of_planes; % because of the volumetric imaging, a "frame" here is a volumetric frame. Therefore more than one photostim can happen in a volumetric frame
                stim_frame=session_epoch_start_frame : photostim_volume_ratio: session_epoch_end_frame;
                stim_frame= stim_frame - stim_frame(1) +1;  % relative to the beginning of the session epoch, *not* to the entire session
                
                seq = seq(1:same_photostim_duration_in_frames:end);
                seq=[seq seq seq seq seq seq seq seq seq seq seq seq seq seq seq seq seq seq seq seq seq seq seq]; % in case the sequence is too short and has to repeat itself
                seq=seq(1:1:numel(stim_frame));
                stim_sequence = seq;
                
                %% Populate IMG.PhotostimProtocol
                key2 = fetch(EXP2.SessionEpoch & key);
                key2.same_photostim_duration_in_frames = same_photostim_duration_in_frames;
                key2.photostim_volume_ratio = photostim_volume_ratio;
                insert(IMG.PhotostimProtocol, key2);
                
                
                %                 stim_sequence=seq(110:1:end-110);
                %                 stim_frame=stim_frame((110:1:end-110));
            end
            
            
            %             try
            %                 photostim_session_epoch = (load([dir_data 'photostim_session_epoch.mat'])); photostim_session_epoch=photostim_session_epoch.photostim_session_epoch;
            %                 stim_frame=photostim_session_epoch.stim_frame(110:1:end-110); % to be able to analyze single trial traces of suffiecient length, aligned to photostim onset
            %                 stim_sequence=photostim_session_epoch.stim_sequence(110:1:end-110);
            %             catch
            %
            %                 dir_data = fetchn(EXP2.SessionEpochDirectory & key,'local_path_session_epoch');
            %                 dir_data = dir_data{1};
            %                 allFiles = dir(dir_data); %gets  the names of all files and nested directories in this folder
            %                 allFileNames = {allFiles(~[allFiles.isdir]).name}; %gets only the names of all files
            %                 sequence_filenames =allFileNames(contains(allFileNames,'Sequence'))';
            %
            %                 stim_frame=fetch1(IMG.SessionEpochFrame & key,'session_epoch_start_frame'):1:fetch1(IMG.SessionEpochFrame & key,'session_epoch_end_frame');
            %                 stim_frame=1:1:numel(stim_frame);
            %                 seq = (load([dir_data sequence_filenames{1}])); %DEBUG to include multiple sequence names
            %                 seq=seq.sequence;
            %                 seq=[seq seq seq seq seq seq seq seq]; % in case the sequence is too short and has to repeat itself
            %                 seq=seq(1:1:numel(stim_frame));
            %
            %                 stim_sequence=seq(110:1:end-110);
            %                 stim_frame=stim_frame((110:1:end-110));
            %             end
            
            
            
            
            
            % load dat file containing the photostimulation groups info
            dir_data1 = fetch1(EXP2.SessionEpochDirectory & key,'local_path_session');
            allFiles = dir(dir_data1); %gets  the names of all files and nested directories in this folder
            allFileNames = {allFiles(~[allFiles.isdir]).name}; %gets only the names of all files
            allFileNames =allFileNames(contains(allFileNames,'dat.mat'))';
            if ~isempty(allFileNames) % if dat file is common to all session
                dat = (load([dir_data1 'dat.mat']));
            else %if there is a dat file specific to session epoch
                dir_data2 = fetch1(EXP2.SessionEpochDirectory & key,'local_path_session_epoch');
                dat = (load([dir_data2 'dat.mat']));
            end
            dat=dat.dat;
            
            
            
            if size(dat.photostim_groups,2)>5 %muiltiplexing 5 is just to make sure that the number of groups was not because of accidental clicking
                
                for i_g = 1:1:size(dat.photostim_groups,2)
                    group_rois (i_g,:)= find(dat.photostim_groups(i_g).powers);
                end
                
                
                group_list=unique(group_rois(:),'sorted');
                
                %             session_epoch_start_frame = fetchn(IMG.SessionEpochFrame & key,'session_epoch_start_frame');
                
                for i_g = 1:1:numel(group_list)
                    k=key;
                    k.photostim_group_num=i_g;
                    idx=[];
                    idx_group_with_this_roi=[];
                    for i_gg=1:1:size(group_rois,1)
                        idx_group_with_this_roi(i_gg)=sum(group_rois(i_gg,:)==group_list(i_g))>0;
                    end
                    idx_group_with_this_roi = find(idx_group_with_this_roi);
                    for iii = 1:1:numel(idx_group_with_this_roi)
                        idx_temp=find(stim_sequence==idx_group_with_this_roi(iii));
                        idx = [idx idx_temp];
                    end
                    %                                                     idx_g=find(stim_sequence==group_list(i_g));
                    idx = sort(idx);
                    for i_stim = 1:1:numel(idx)
                        f_start=stim_frame(idx(i_stim));
                        k.photostim_start_frame(i_stim) = floor(f_start);
                        k.photostim_end_frame (i_stim)= floor(f_start);%+ photostim_duration_in_frames -1; %DEBUG in case a stimulus lasts longer than a frame
                    end
                    insert(self,k);
                end
                
                
                
            else  % Not multiplexing
                
                
                group_list=unique(stim_sequence,'sorted');
                
                %             session_epoch_start_frame = fetchn(IMG.SessionEpochFrame & key,'session_epoch_start_frame');
                
                for i_g = 1:1:numel(group_list)
                    k=key;
                    k.photostim_group_num=i_g;
                    idx=find(stim_sequence==group_list(i_g));
                    for i_stim = 1:1:numel(idx)
                        f_start=stim_frame(idx(i_stim));
                        k.photostim_start_frame(i_stim) = floor(f_start);
                        k.photostim_end_frame (i_stim)= floor(f_start);%+ photostim_duration_in_frames -1; %DEBUG in case a stimulus lasts longer than a frame
                    end
                    insert(self,k);
                end
                
            end
            
        end
    end
end