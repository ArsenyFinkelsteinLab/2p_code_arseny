function fn_save_movies_fov (M_avg, blank_percentile, smoothing_3D_size, video_quality, frame_rate, dir_save_fig, filename_prefix)


%% Movies dir
if isempty(dir(dir_save_fig))
    mkdir (dir_save_fig)
end


Mavg2D=squeeze(mean(M_avg,3));
Blank_2D_idx = Mavg2D<prctile(Mavg2D(:),blank_percentile);


%% f video gray
M_avg_temp = M_avg;

minp=prctile (M_avg_temp(:),5);
maxp=prctile (M_avg_temp(:),99.99);

cmp = gray(256); % 16 element colormap
M_avg_temp = uint8(256*mat2gray(M_avg_temp,[minp,maxp]));

% saving video
myVideo = VideoWriter([dir_save_fig filename_prefix '_Fgray.avi'],'Motion JPEG AVI');
myVideo.FrameRate = frame_rate;
myVideo.Quality = video_quality;    % Default 75
open(myVideo);
for i_fr=1:1:size(M_avg_temp,3)
    RGB = ind2rgb(squeeze(M_avg_temp(:,:,i_fr)),cmp);
    writeVideo(myVideo, RGB);
end
close(myVideo);


%% df/f video 
M_avg_temp = M_avg;
M_avg_temp=rescale(M_avg_temp);
baselineF_2D = median(M_avg_temp(:,:,1:floor(frame_rate)),3); %baseline flourescence for each pixel (based on 1 sec of the presample period)
for i_fr=1:1:size(M_avg,3)
    f=M_avg_temp(:,:,i_fr);
    M_avg_temp(:,:,i_fr) = (f-baselineF_2D)./baselineF_2D; %pixel by pixel bf/f
end

minp=prctile (M_avg_temp(:),10);
maxp=prctile (M_avg_temp(:),99.9);

M_avg_temp = smooth3(M_avg_temp,'gaussian',smoothing_3D_size); %3D smoothing in x-y-z


%% df/f video color
M_avg_temp1=M_avg_temp;
cmp = jet(256); % 16 element colormap
M_avg_temp1 = uint8(256*mat2gray(M_avg_temp1,[minp,maxp]));

% saving video
myVideo = VideoWriter([dir_save_fig filename_prefix '_dFFcolor.avi'],'Motion JPEG AVI');
myVideo.FrameRate = frame_rate;
myVideo.Quality = video_quality;    % Default 75
open(myVideo);
for i_fr=1:1:size(M_avg_temp1,3)
    current2D =squeeze(M_avg_temp1(:,:,i_fr));
    current2D(Blank_2D_idx)=256/2;
    RGB = ind2rgb(current2D,cmp);
    writeVideo(myVideo, RGB);
end
close(myVideo);

%% saving df/f video gray
M_avg_temp2=M_avg_temp;
cmp = gray(256); % 16 element colormap
M_avg_temp2 = uint8(256*mat2gray(M_avg_temp2,[minp,maxp]));

% saving video
myVideo = VideoWriter([dir_save_fig filename_prefix '_dFFgray.avi'],'Motion JPEG AVI');
myVideo.FrameRate = frame_rate;
myVideo.Quality = video_quality;    % Default 75
open(myVideo);
for i_fr=1:1:size(M_avg,3)
    current2D =squeeze(M_avg_temp2(:,:,i_fr));
    current2D(Blank_2D_idx)=256/2;
    RGB = ind2rgb(current2D,cmp);
    writeVideo(myVideo, RGB);
end
close(myVideo);
% cmp = flip(redblue(16)); % 16 element colormap