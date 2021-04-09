function [img] =  fn_read_frames( file_list,file_idx, frames_to_read,nImage,mImage, dir_data)

FileTif=file_list(file_idx);
NumberImages=length(frames_to_read);
Tstack=zeros(nImage,mImage,NumberImages,'uint16');
parfor i =1:1:NumberImages
    % I don't know why using the temp variable is faster, but it is
    temp = imread([dir_data FileTif{i}], frames_to_read(i));
    Tstack(:,:,i)     = temp;
end

img=mean(Tstack,3);