%{
# Field of View
-> IMG.FOV
-> EXP2.Outcome
-> EXP2.TrialNameType
---
typical_time_sample_start           : double
typical_time_sample_end             : double
psth_timestamps                     : blob
movie_frame_rate                    : double
%}


classdef FOVRegisteredMovie < dj.Imported
    properties
        keySource = (IMG.FOV & 'fov_name="fov2"') * (EXP2.TrialNameType & 'task="sound"')  * EXP2.Outcome;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            reg_tiff_dir = 'Z:\users\Arseny\Projects\Learning\imaging2p\Registered\AF09_anm437545\suite2p\2019_02_04_08\suite2p\plane0\reg_tif\';
            trial_in_chunk=10; % average trials in chunks of 10
            frames_in_regestired_tiff = 400;
            
            trial_list=fetchn(EXP2.BehaviorTrial*EXP2.TrialName & key & 'early_lick="no early"', 'trial','ORDER BY trial');
            
            if numel(trial_list)<=trial_in_chunk
                return
            end
            
            rel_multi=(IMG.FOVmultiSessionsFirstFrame & key);
            if rel_multi.count>0
                first_frame_in_session_out_of_multisession = fetchn(rel_multi & key,'first_frame_in_session_out_of_multisession');
            else
                first_frame_in_session_out_of_multisession=1;
            end
            
            reg_tiff_list=dir(reg_tiff_dir);
            reg_tiff_list=reg_tiff_list(~[reg_tiff_list.isdir]);
            file_list={reg_tiff_list.name};
            file_list=file_list(contains(file_list,'.tif'));
            
            
            
            FOV=fetch(IMG.FOV & key,'*');
            frame_rate = FOV.imaging_frame_rate;
            typical_time_sample_start=fetchn(ANLI.FPSTHMatrix & key,'typical_time_sample_start');
            typical_time_sample_end=fetchn(ANLI.FPSTHMatrix & key,'typical_time_sample_end');
            typical_psth_timestamps=cell2mat(fetchn(ANLI.FPSTHMatrix & key,'typical_psth_timestamps'));
            
            
            idx_frames =typical_psth_timestamps<=2;
            number_of_frames = sum(idx_frames);
            
            
            FileTif=[reg_tiff_dir file_list{1}];
            
            InfoImage=imfinfo(FileTif);
            mImage=InfoImage(1).Width;
            nImage=InfoImage(1).Height;
            
            M_avg=zeros(nImage,mImage,number_of_frames);
            M_var=zeros(nImage,mImage,number_of_frames);
            
            
            k_movie = key;
            k_movie_frame = key;
            
            k_movie_frame=repmat(k_movie_frame,1,number_of_frames);
            
            k_movie.typical_time_sample_start = typical_time_sample_start;
            k_movie.typical_time_sample_end      = typical_time_sample_end;
            k_movie.psth_timestamps  = typical_psth_timestamps(idx_frames);
            k_movie.movie_frame_rate  = frame_rate;
            insert(self,k_movie);
            
            tic
            number_of_chunks = floor(numel(trial_list)/trial_in_chunk); % I ignore trials in the last chunk - should fix later
            parfor i_fr=1:1:number_of_frames
                % i_fr
                M_trials_chunk=zeros(nImage,mImage);
                
                for i_tr_chunk=1:1:number_of_chunks 
                    M=zeros(nImage,mImage);
                    
                    for i_tr=1:1:trial_in_chunk
                        current_trial=(i_tr + (i_tr_chunk-1)*trial_in_chunk);
                        tr = trial_list(current_trial);
                        frames_start_trial=FOV.frames_start_trial(tr);
                        
                        current_frame = frames_start_trial + i_fr -1 + (first_frame_in_session_out_of_multisession-1);
                        
                        tiff_number = ceil(current_frame/frames_in_regestired_tiff);
                        frame2read = mod(current_frame,frames_in_regestired_tiff);
                        
                        if frame2read==0
                            if tiff_number>1
                                tiff_number=tiff_number-1;
                                frame2read=1;
                            elseif tiff_number==1
                                frame2read=400;
                            end
                        end
                        
                        FileTif=[reg_tiff_dir file_list{tiff_number}];
                        TifLink = Tiff(FileTif, 'r');
                        TifLink.setDirectory(frame2read);
                        M= M + double(TifLink.read())/trial_in_chunk; %averaging without using memory
                        TifLink.close();
                    end
                    M_trials_chunk= M_trials_chunk + M/number_of_chunks; %averaging without using memory
                end
                k_movie_frame(i_fr).movie_frame_number = i_fr;
                k_movie_frame(i_fr).fov_movie_trial_avg = M_trials_chunk;
                
            end
            toc
            insert(IMG.FOVRegisteredMovieFrame,k_movie_frame);
            
            
        end
    end
end