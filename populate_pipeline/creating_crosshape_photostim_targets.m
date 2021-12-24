function creating_crosshape_photostim_targets()

%% IMPORTANT: to run this script, in SI using photostim_group_old one should select 1 target -- the target neuron
% this target will be in dat variable. In the end of the script we will
% create a cross-shape targets around this target. The first target will be
% actually a "parking" target outside of the FOV

roi_vector_micr = [10, 20, 30, 50, 75, 100]; % in microns
roi_radius=4.5; %not sure is needed -- for DAT file assembly
pix2dist=1.4418;

%% 
%--------------------
% either load dat
% load('F:\Arseny\2p\data\anm492791_AF38\20211011_registered\dat.mat')
% or if its already loaded in SI make it global

% if you don't know the pixdist -- run this before hand from DJ
% key.subject_id = 492791;
% key.session =2;
% key.session_epoch_number = 1;
% key.plane_num = 1; %assuming photostimulation happens at the top plane
% zoom =fetch1(IMG.FOVEpoch & key,'zoom');
% kkk.scanimage_zoom = zoom;
% pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');
%
%--------------------


global dat


roi_vector_pix = roi_vector_micr/pix2dist;

centroid_reference_session = cell2mat({dat.roi.centroid}');

XY_target = centroid_reference_session(1,:); % this would be the center of the cross

XY_chosen=XY_target;
for i=1:1:numel(roi_vector_pix)
    
    XY_chosen(end+1,1) = XY_target(1) + roi_vector_pix(i);
    XY_chosen(end,2) = XY_target(2);
    
    XY_chosen(end+1,1) = XY_target(1) - roi_vector_pix(i);
    XY_chosen(end,2) = XY_target(2);
    
    
    XY_chosen(end+1,1) = XY_target(1);
    XY_chosen(end,2) = XY_target(2) + roi_vector_pix(i);
    
    XY_chosen(end+1,1) = XY_target(1);
    XY_chosen(end,2) = XY_target(2) - roi_vector_pix(i);
    
end


XY_chosen=[  [-100,-100]; XY_chosen]; %% this adds a "parking" position so that the first ROI is in fact never stimulated

% plot(XY_chosen(:,1),XY_chosen(:,2),'*k');
% hold on
% plot(XY_target(:,1),XY_target(:,2),'*c');


%% This update the dat file
dat.roi=[];
mean_img =dat.IM;
m=size(mean_img,1);
n=size(mean_img,2);
[I,J] = ndgrid(1:m,1:n);
plane=1;

for i=1:size(XY_chosen,1)
    x=round( XY_chosen(i,1) );
    y=round( XY_chosen(i,2) );
    M = double((I-y).^2+(J-x).^2<=roi_radius^2); % <-- M should be your desired array
    pixel_list = find(M);
    addROI([x,y],[],pixel_list,plane);
end

% dir_save_file = [];
% filename_save = 'dat_crosshape.mat';
% save([dir_save_file filename_save],'dat');


end






