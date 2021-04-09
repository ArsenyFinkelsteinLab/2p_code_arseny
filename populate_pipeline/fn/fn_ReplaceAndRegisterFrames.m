function fn_ReplaceAndRegisterFrames(session_info, flag_do_registration, flag_find_bad_frames_only)

dir_data =session_info.local_path_session_epoch;
dir_data_registered =session_info.local_path_session_epoch_registered;

dir_save_fig = [dir_data_registered 'photostim_timings\'];
dir_save_data = [dir_data_registered ];

is_dir = dir(dir_save_data);
if ~isempty(is_dir) % skips if if registration already exists
    return
end

num_sub_file=1; %number of small files to split ad save the original large .tif file


flag_replace_frames =session_info.flag_photostim_epoch; % replace frames only for photostim epochs
flag_use_existing_template=0; % 1 use template from a different day for registration;
if flag_use_existing_template==1
    dir_existing_template = [dir_base 'anm445105_AF11\20190413\Bphoto_registered\'];
    template=load([dir_existing_template 'img_mean.mat']);
    template=template.img_mean;
end



if flag_replace_frames ==1 || flag_do_registration==1
    %get files in that dir
    allFiles = dir(dir_data); %gets  the names of all files and nested directories in this folder
    allFileNames = {allFiles(~[allFiles.isdir]).name}; %gets only the names of all files
    file_list =allFileNames(contains(allFileNames,'.tif'))';
    
    % reading sequence filenames and ordering them
    filename_prefix = file_list{1}(1:strfind(file_list{1},'_')-1);
    sequence_filenames =allFileNames(contains(allFileNames,'Sequence'))';
    for i_ss=1:1:numel(sequence_filenames)
        s_name=sequence_filenames{i_ss};
        str_start=strfind(s_name,filename_prefix)+length(filename_prefix);
        str_end=strfind(s_name,'.mat')-1;
        sequence_filenames_number_start(i_ss)=str2num(s_name(str_start:str_end));
    end
    [sequence_filenames_number_start, temp_order]=sort(sequence_filenames_number_start);
    sequence_filenames_number_end= [sequence_filenames_number_start(2:end)-1, numel(file_list)];
    sequence_filenames=sequence_filenames(temp_order);
    seq_bout_counter=1;
    seq_bout_first_frame=1;
    
    %     % resaving important files in the new (registered) directory
    %     SI_sequence_filename =allFileNames(contains(allFileNames,'Sequence'))'; % assuming there is only one sequence file per folder
    %     Sequence=load([dir_data SI_sequence_filename{1}]);
    %     filename = [dir_save_data  '\' 'Sequence.mat'];
    %     save(filename,'-struct','Sequence');
    
    
    ws_sequence_filename =allFileNames(contains(allFileNames,'.h5'))'; % wavesurfer file name
    
    for i_ws = 1:1:numel(ws_sequence_filename) % this deals with cases in which SI crashes but WS continues to record additional sweeps
        temp_ws_start(i_ws,:) = str2num(ws_sequence_filename{i_ws}(end-11:1:end-8));
        temp_ws_end(i_ws,:) = str2num(ws_sequence_filename{i_ws}(end-6:1:end-3));
        
        ws_number_sweeps_good(i_ws,:) = temp_ws_end(i_ws,:) - (temp_ws_start(i_ws,:)-1);
        if i_ws>1
            ws_number_sweeps_good(i_ws-1,:) =  ws_number_sweeps_good(i_ws-1,:) - (temp_ws_end(i_ws-1,:) - temp_ws_start(i_ws,:)) -1;
        end
    end
    
    ws_counter=1;
    for i_ws = 1:1:numel(ws_sequence_filename)
        ws_struct = ws.loadDataFile([dir_data ws_sequence_filename{i_ws}]);
        fields = fieldnames(ws_struct);
        for i_field=2:1:(ws_number_sweeps_good(i_ws)+1)
            temp=eval(['ws_struct.' fields{i_field}]);
            if i_field==2
                typical_length=size(temp.analogScans,1);
            end
            current_length=size(temp.analogScans,1);
            %             if current_length~=typical_length %checking for abberant WS files (truncated prematurely)
            if current_length/typical_length<0.95 %checking for abberant WS files (truncated prematurely)
                continue;
            end
            w_sweeps{ws_counter}=temp;
            ws_counter=ws_counter+1;
        end
    end
    
    
    if isempty(ws_sequence_filename)
        return
    end
    WS_SampleRate=ws_struct.header.AcquisitionSampleRate; %Hz
    
    stim_frame_session_epoch =[];
    stim_sequence_session_epoch =[];
    stim_frame_session_epoch_python=[];
    
    file_suffix_counter=1;
    img_mean = 0;%zeros(nImage,mImage);
    
    for i_fl=1:1:numel(file_list)
        tic
        i_fl
        current_file_name= [file_list{i_fl}];
        
        if flag_find_bad_frames_only==0
            [h, Tstack]=scanimage.util.opentif( [dir_data current_file_name] );
            Tstack=(squeeze(Tstack));
        else
            [h]=scanimage.util.opentif( [dir_data current_file_name] );
        end
        number_frames=length(h.frameNumbers);
        
        
        %% Replace photostim frames
        if flag_replace_frames ==1
            if flag_find_bad_frames_only==0
                F_t=squeeze(mean(Tstack,1));
                F_t=squeeze(mean(F_t,1));
            end
            
            %             % Find photostimulation timing based on pockel cell responses (using WaveSurfer aquired data)
            %             fields = fieldnames(s);
            %             if numel(fields) <(i_fl+1)
            %                 return
            %             end
            %             w=eval(['s.' fields{i_fl+1}]);
            w=w_sweeps{i_fl}.analogScans(:,2);
            %             w=[zeros(100,1);w];
            w(w>max(w)*0.7)=max(w);
            [~,WS_stim_time_idx]=findpeaks(w,'MinPeakDistance',40,'MinPeakProminence',[max(w)*0.5]);
            
            time_WS=(0:1:typical_length-1)./WS_SampleRate;
            
            subplot(3,3,1:3);
            hold on;
            try
            plot(time_WS,w,'b');
            plot(time_WS(WS_stim_time_idx),w(WS_stim_time_idx),'.g');
            title(sprintf('%d peak WS ', numel(WS_stim_time_idx)));
            catch
            end
            axis tight;
            xlabel('Time(s)');
            ylabel('Pockel Cell (V)');
            xlim([time_WS(1) time_WS(end)]);
            
            
            % Fing the contaminated frames in ScanImage using based on pockel cell timing and peaks in mean flourescence in each frame
            %             stim_large_neighborhood = 1; % plus minus 2 frames
            WS_stim_time_sec = WS_stim_time_idx/WS_SampleRate;
            neighborhood = 1; % plus minus 2 frames
            frameTimestamps = h.frameTimestamps_sec - h.frameTimestamps_sec(1);
            SI_stim_frame_idx=[];
            for i_s=1:1:numel(WS_stim_time_idx)
                [~,idx_fr] =min(abs(frameTimestamps - WS_stim_time_sec(i_s)));
                fr_start = max([1,idx_fr-neighborhood]);
                fr_end = min([idx_fr+neighborhood, number_frames]);
                idx_replace=[fr_start,fr_end];
                if flag_find_bad_frames_only==0
                    Tstack(:,:,idx_fr) =  squeeze(mean(Tstack(:,:,idx_replace),3));
                end
                SI_stim_frame_idx(i_s) = idx_fr;
            end
            stim_frame_session_epoch = [stim_frame_session_epoch, SI_stim_frame_idx+(i_fl-1)*number_frames];
            stim_frame_session_epoch_python  = [stim_frame_session_epoch, SI_stim_frame_idx+(i_fl-1)*number_frames -1]; % we do it in python convention so that 1 is 0
            
            time_SI = frameTimestamps;
            if flag_find_bad_frames_only==0
                subplot(3,3,4:6);
                hold on;
                plot(time_SI,F_t,'-b');
                plot(time_SI(SI_stim_frame_idx) ,F_t(SI_stim_frame_idx),'.r');
                title(sprintf('%d peak SI ', numel(SI_stim_frame_idx)));
                axis tight;
                xlim([time_WS(1) time_WS(end)]);
                xlabel('Time(s)');
                ylabel('Mean Flourescence');
            end
            
            subplot(3,3,7:9);
            hold on;
            plot(diff(SI_stim_frame_idx),'-m');
            xlabel('Distance between frames with photostimulations')
            axis tight;
            
            %% Finding what group was photostimulated on every stimulation
            if i_fl>=sequence_filenames_number_end(seq_bout_counter)
                sequence=load([dir_data sequence_filenames{seq_bout_counter}]); sequence=sequence.sequence;
                num_frames_in_seq_bout = numel(stim_frame_session_epoch(seq_bout_first_frame:end));
                sequence= repmat(sequence,1,ceil(num_frames_in_seq_bout/numel(sequence)));
                sequence=sequence(1:num_frames_in_seq_bout);
                
                stim_sequence_session_epoch = [stim_sequence_session_epoch, sequence];
                seq_bout_counter=seq_bout_counter+1;
                seq_bout_first_frame=numel(stim_frame_session_epoch)+1;
            end
            
            
            
            photostim_session_epoch.stim_sequence = stim_sequence_session_epoch;
            photostim_session_epoch.stim_frame = stim_frame_session_epoch;
            
            %% Saving
            if isempty(dir(dir_save_fig))
                mkdir (dir_save_fig)
            end
            
            
            if isempty(dir(dir_save_data))
                mkdir (dir_save_data)
            end
            filename = [dir_save_data  '\' 'photostim_session_epoch.mat'];
            save(filename,'photostim_session_epoch');
            
            filename2 = [dir_save_data  '\' 'bad_frames.npy'];
            writeNPY(stim_frame_session_epoch_python, filename2)
            
            filename=['file_' num2str(i_fl)];
            figure_name_out=[ dir_save_fig filename];
            eval(['print ', figure_name_out, ' -dtiff  -r400']);
            % eval(['print ', figure_name_out, ' -dpdf -r200']);
            savefig(figure_name_out)
            
            clf
        end
        
        
        %% Registration
        if flag_do_registration==1
            if flag_use_existing_template~=1
                if ~exist('template')
                    template = mean(Tstack,3);
                else
                    template = img_mean;
                end
            end
            
            decimationFactor=1;
            phase=0;
            Tstack = fn_register(Tstack, template, phase, decimationFactor);
            
            img_mean = img_mean + mean(Tstack,3)/numel(file_list);
            
            
            % Save ammended Tiff
            save_file_name = [dir_save_data current_file_name];
            %     options.overwrite=true;
            %     saveastiff(Tstack, [dir_save_data amended_file_name],options);
            
            Tstack=int16(Tstack);
            T = cell(num_sub_file,1);
            counter=1;
            TnameSuffix =  cell(num_sub_file,1);
            base_suffix = '00000';
            for i_sub_file=1:1:num_sub_file
                ix_start = counter;
                ix_end = (ix_start-1) + number_frames/num_sub_file;
                counter = ix_end +1;
                T{i_sub_file}=Tstack(:,:,ix_start:ix_end);
                ss1=base_suffix;
                ss2=num2str(file_suffix_counter);
                ss1(end-(numel(ss2)-1):end)=ss2;
                TnameSuffix{i_sub_file} = ss1;
                file_suffix_counter=file_suffix_counter + 1;
            end
            %     toc
            %     tic
            parfor i_sub_file=1:1:num_sub_file
                
                saveastiff( T{i_sub_file} , [save_file_name(1:end-9) TnameSuffix{i_sub_file} '.tif']);
            end
            %     toc
            clear Tstack T;
            
            if isempty(dir(dir_save_data))
                mkdir (dir_save_data)
            end
            filename = [dir_save_data  '\' 'img_mean.mat'];
            save(filename,'img_mean');
        end
        toc
    end
end