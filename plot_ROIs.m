flag_plot_dFoverF=0;
close all;
dir_data = 'E:\Arseny\suite2p\';
suffix='AF11_anm445105\2019_04_12\photoA_registered\';
dir_data=[dir_data suffix];
dir_current_fig = [dir_data  'photo_maps\'];

number_frames=100; % per registered tif file
mImage=768;
nImage=768;
num_frames_avg_after_stim=20; % number of frames to average following stimulation
num_frames_avg_before_stim=20; % number of frames to average before stimulation


load([dir_data 'dat.mat'])

allFiles = dir(dir_data); %gets  the names of all files and nested directories in this folder
allFileNames = {allFiles(~[allFiles.isdir]).name}; %gets only the names of all files

sequence_filename =allFileNames(contains(allFileNames,'Sequence'))'; % assuming there is only one sequence file per folder
stim_frame_session = (load([dir_data 'stim_frame_session.mat']));
stim_frame_session=stim_frame_session.stim_frame_session;
stim_frame_session=stim_frame_session(1:end-10);

seq=load([dir_data sequence_filename{1}]);
photostin_seq= repmat(seq.sequence,1,ceil(numel(stim_frame_session)/numel(seq.sequence)));
photostin_seq=photostin_seq(1:numel(stim_frame_session));
cell_list=unique(photostin_seq,'sorted');

    load([dir_data 'img_mean.mat']);
hold on
imagesc(img_mean)
for i_c=1:1:numel(cell_list)
        plot(    dat.roi(i_c).centroid(1)-8,dat.roi(i_c).centroid(2),'ok','MarkerSize',10)
        text(    dat.roi(i_c).centroid(1)-8,dat.roi(i_c).centroid(2),num2str(i_c))

end