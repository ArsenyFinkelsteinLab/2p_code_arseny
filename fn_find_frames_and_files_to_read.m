function [frames_to_read, file_idx ] =  fn_find_frames_and_files_to_read( frame_start_session,number_frames, num_frames_avg )

temp_file_idx=ceil(frame_start_session/number_frames);
if mod(frame_start_session,number_frames)==0
    temp_file_idx=temp_file_idx-1;
    frame_start=number_frames; %in that file
else
frame_start=mod(frame_start_session,number_frames); %in that file
end
frame_end=mod(frame_start+(num_frames_avg-1),number_frames);
frames_to_read=frame_start:frame_end;
if ~isempty(frames_to_read)
    file_idx(1:num_frames_avg)=temp_file_idx;
    
else
    nnn=numel(frame_start:1:number_frames);
    file_idx(1:nnn)=temp_file_idx;
    file_idx(nnn+1:num_frames_avg)=temp_file_idx + 1;
    frames_to_read(1:nnn)=frame_start:1:number_frames;
    frames_to_read(nnn+1:num_frames_avg)=1:1:(frame_end);
end

